import logging
from mcp import StdioServerParameters, ClientSession
from mcp.client.stdio import stdio_client

logger = logging.getLogger(__name__)


class CoralClient:
    def __init__(self):
        self.server_params = StdioServerParameters(command="coral", args=["mcp-stdio"])
        self._client_context = None
        self._session_context = None
        self.session = None

    async def __aenter__(self):
        self._client_context = stdio_client(self.server_params)
        read, write = await self._client_context.__aenter__()
        self._session_context = ClientSession(read, write)
        self.session = await self._session_context.__aenter__()
        await self.session.initialize()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if self._session_context:
            try:
                await self._session_context.__aexit__(exc_type, exc_val, exc_tb)
            except Exception:
                logger.debug(
                    "Suppressed error during MCP session cleanup", exc_info=True
                )
        if self._client_context:
            try:
                await self._client_context.__aexit__(exc_type, exc_val, exc_tb)
            except Exception:
                logger.debug(
                    "Suppressed error during stdio client cleanup", exc_info=True
                )

    async def list_tools(self):
        if not self.session:
            raise RuntimeError(
                "Coral session not initialized. Use async with CoralClient()."
            )
        result = await self.session.list_tools()
        if hasattr(result, "tools"):
            return result.tools
        return result

    async def call_tool(self, name: str, args: dict) -> str:
        if not self.session:
            raise RuntimeError(
                "Coral session not initialized. Use async with CoralClient()."
            )
        try:
            result = await self.session.call_tool(name, args)
            contents = getattr(result, "content", [])
            text_parts = []
            for item in contents:
                if hasattr(item, "text"):
                    text_parts.append(item.text)
                elif isinstance(item, dict) and "text" in item:
                    text_parts.append(item["text"])
                else:
                    text_parts.append(str(item))
            return "\n".join(text_parts)
        except Exception as e:
            logger.error(f"Error calling Coral tool '{name}' with args {args}: {e}")
            return f"Error executing tool '{name}': {e}"
