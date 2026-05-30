"""LLM client for the Drift agent with built-in streaming and rate-limit retries."""

import asyncio
import logging
import random
import time
from typing import Any, Dict, List, Optional

import httpx
import openai
from openai import AsyncOpenAI
from pydantic import BaseModel

logger = logging.getLogger(__name__)

# Lazy singleton client

_client: AsyncOpenAI | None = None


def _get_client() -> AsyncOpenAI:
    """Return (and lazily create) the shared AsyncOpenAI client."""
    global _client
    if _client is None:
        from .config import MISTRAL_API_KEY, MISTRAL_BASE_URL

        _client = AsyncOpenAI(
            api_key=MISTRAL_API_KEY,
            base_url=MISTRAL_BASE_URL,
            # connect fast, allow up to 2 min for slow inference
            timeout=httpx.Timeout(connect=10.0, read=120.0, write=10.0, pool=5.0),
        )
    return _client


# Response models


class ToolCall(BaseModel):
    id: str
    name: str
    arguments: str


class LLMResponse(BaseModel):
    content: Optional[str] = None
    tool_calls: Optional[List[ToolCall]] = None


# Helpers


def convert_mcp_to_openai_tool(mcp_tool: Any) -> Dict[str, Any]:
    """Convert an MCP tool schema (dict or pydantic) to OpenAI format."""
    tool_dict = mcp_tool if isinstance(mcp_tool, dict) else mcp_tool.model_dump()
    return {
        "type": "function",
        "function": {
            "name": tool_dict["name"],
            "description": tool_dict.get("description", ""),
            "parameters": tool_dict.get(
                "inputSchema", {"type": "object", "properties": {}}
            ),
        },
    }


def _extract_retry_after(error: openai.RateLimitError) -> tuple[float, bool]:
    """Parse rate-limit headers from a 429 response, returning (wait_seconds, is_daily_exhaustion)."""
    DAILY_THRESHOLD = 600.0  # 10 min — anything longer means daily quota

    try:
        if hasattr(error, "response") and error.response:
            headers = error.response.headers

            # --- check standard Retry-After ---
            for key in ("Retry-After", "retry-after"):
                if key in headers:
                    val = float(headers[key])
                    if val > 1e12:
                        val = val / 1000.0
                    if val > 1e9:
                        delta = max(0.0, val - time.time())
                        if delta > DAILY_THRESHOLD:
                            return delta, True
                        return min(delta, 60.0), False
                    return min(max(val, 1.0), 60.0), False
    except Exception:
        pass
    return 10.0, False


class DailyQuotaExhaustedError(RuntimeError):
    """Raised when the OpenRouter free-tier daily request quota is used up."""


class EmptyResponseError(RuntimeError):
    """Raised when a model returns neither content nor tool calls."""


# Streaming response collector


async def _collect_stream(stream: Any) -> LLMResponse:
    """Collect a streamed chat completion into an LLMResponse, preventing silent timeouts."""
    full_content: list[str] = []
    # keyed by tool-call index (int), values are partial dicts
    tool_calls_map: dict[int, dict[str, str]] = {}

    async for chunk in stream:
        if not chunk.choices:
            continue
        delta = chunk.choices[0].delta

        if delta.content:
            full_content.append(delta.content)

        if delta.tool_calls:
            for tc in delta.tool_calls:
                idx = tc.index
                if idx not in tool_calls_map:
                    tool_calls_map[idx] = {"id": "", "name": "", "arguments": ""}
                entry = tool_calls_map[idx]
                # id and name arrive once on the first chunk for that index
                if tc.id:
                    entry["id"] = tc.id
                if tc.function and tc.function.name:
                    entry["name"] = tc.function.name
                # arguments stream in as fragments — concatenate them
                if tc.function and tc.function.arguments:
                    entry["arguments"] += tc.function.arguments

    content = "".join(full_content) or None

    res_tool_calls: list[ToolCall] | None = None
    if tool_calls_map:
        res_tool_calls = [
            ToolCall(id=v["id"], name=v["name"], arguments=v["arguments"])
            for v in tool_calls_map.values()
        ]

    result = LLMResponse(content=content, tool_calls=res_tool_calls)

    # A completely empty response means the model silently failed.
    # Raise so the caller can skip to the next model.
    if result.content is None and result.tool_calls is None:
        raise EmptyResponseError("Model returned empty content and no tool calls")

    return result


# Models to try in preference order, falling back on non-429 errors.
MISTRAL_MODELS = [
    "mistral-large-latest",
    "codestral-latest",
    "mistral-small-latest",
]


async def call_llm(
    messages: List[Dict[str, Any]],
    tools: Optional[List[Any]] = None,
) -> LLMResponse:
    """Call a Mistral API model with tool support via streaming and automatic fallback retries."""
    from .config import MISTRAL_MODEL

    client = _get_client()

    formatted_tools: list[dict] | None = None
    if tools:
        formatted_tools = [convert_mcp_to_openai_tool(t) for t in tools]

    # Build ordered, deduplicated model list starting with user's configured model
    models: list[str] = []
    seen: set[str] = set()
    for m in [MISTRAL_MODEL] + MISTRAL_MODELS:
        if m not in seen:
            models.append(m)
            seen.add(m)

    max_429_retries = 6  # per model — patient, but not infinite
    last_error: Exception | None = None

    for model in models:
        kwargs: Dict[str, Any] = {
            "model": model,
            "messages": messages,
            "stream": True,
        }
        if formatted_tools:
            kwargs["tools"] = formatted_tools
            kwargs["tool_choice"] = "auto"

        retries_429 = 0

        while retries_429 <= max_429_retries:
            # Small random jitter to avoid burst detection.
            # Skip on first attempt to keep the fast path fast.
            if retries_429 > 0:
                await asyncio.sleep(random.uniform(0.3, 1.5))

            try:
                logger.info("Calling %s (429-retry %d)", model, retries_429)
                print(
                    f"Calling LLM: {model} "
                    f"(attempt {retries_429 + 1}/{max_429_retries + 1})"
                )

                async with await client.chat.completions.create(**kwargs) as stream:
                    return await _collect_stream(stream)

            except openai.RateLimitError as exc:
                last_error = exc
                wait, is_daily = _extract_retry_after(exc)

                if is_daily:
                    hrs = wait / 3600
                    raise DailyQuotaExhaustedError(
                        f"Mistral API daily quota exhausted. "
                        f"Resets in ~{hrs:.1f} hours.\n"
                        f"Options:\n"
                        f"  1. Wait until reset\n"
                        f"  2. Check billing details on Mistral Console\n"
                        f"  3. Run with --mock for a demo report"
                    ) from exc

                retries_429 += 1
                if retries_429 > max_429_retries:
                    print(f"  Exhausted 429 retries on {model}, trying next model...")
                    break

                wait_with_jitter = wait + random.uniform(0.5, 2.0)
                print(f"  429 on {model}. Waiting {wait_with_jitter:.1f}s...")
                await asyncio.sleep(wait_with_jitter)

            except openai.NotFoundError as exc:
                last_error = exc
                print(f"  Model {model} not found, skipping.")
                break

            except EmptyResponseError as exc:
                last_error = exc
                print(f"  Empty response from {model}, skipping.")
                break

            except (httpx.ReadTimeout, httpx.ConnectTimeout) as exc:
                last_error = exc
                print(f"  Timeout on {model}, skipping.")
                break

            except Exception as exc:
                last_error = exc
                print(f"  Error on {model}: {exc}")
                break

    raise RuntimeError(
        f"All LLM models exhausted after patient retries. Last error: {last_error}"
    )
