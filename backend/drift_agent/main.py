import argparse
import asyncio
import json
import os
import sys
from pathlib import Path
from .agent_loop import run_agent_loop
from .report_writer import validate_and_write_report
from drift_logic.report import build_drift_report


def write_fallback_report(output_path: str, user: str, message: str) -> bool:
    from drift_logic.models import TopAction

    fallback_report = build_drift_report(user=user)
    fallback_report = fallback_report.model_copy(
        update={"top_action": TopAction(text=message, type="none", url="")}
    )
    return validate_and_write_report(fallback_report, output_path)


async def run_scan(args):
    output_path = args.output

    if args.mock:
        print("Running in MOCK mode. Writing mock report...")
        frontend_asset_path = (
            Path(__file__).resolve().parents[2]
            / "frontend"
            / "assets"
            / "mock_drift_report.json"
        )

        try:
            mock_data = json.loads(frontend_asset_path.read_text(encoding="utf-8"))
            print(f"Loaded mock data from frontend asset: {frontend_asset_path}")
        except Exception as e:
            print(
                f"Warning: Failed to load mock from {frontend_asset_path}: {e}. Generating default skeleton."
            )
            from drift_logic.models import TopAction

            fallback = build_drift_report(user=args.user_name or "agp")
            fallback = fallback.model_copy(
                update={
                    "insight": "Mock data fallback.",
                    "top_action": TopAction(
                        text="No urgent drift action right now.", type="none", url=""
                    ),
                }
            )
            mock_data = fallback.to_dict()

        try:
            path = Path(output_path)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps(mock_data, indent=2), encoding="utf-8")
            print(f"Mock report written to {output_path} successfully.")
            return 0
        except Exception as e:
            print(f"Error writing mock report: {e}", file=sys.stderr)
            return 1

    github_username = args.github_username or os.getenv(
        "DRIFT_GITHUB_USERNAME", "AgroKING"
    )
    user_name = args.user_name or os.getenv("DRIFT_USER_NAME", "A G P")
    owner = args.owner or os.getenv("GITHUB_OWNER", "AgroKING")
    repo = args.repo or os.getenv("GITHUB_REPO", "drift")

    print("Running in LIVE mode.")
    print(
        f"Scanning target: owner={owner}, repo={repo}, user_name={user_name}, github_username={github_username}"
    )

    try:
        report_model = await run_agent_loop(
            github_username=github_username, user_name=user_name, owner=owner, repo=repo
        )

        success = validate_and_write_report(report_model, output_path)
        if success:
            return 0
        else:
            print(
                "Warning: live scan returned malformed report; writing fallback report.",
                file=sys.stderr,
            )
            fallback_success = write_fallback_report(
                output_path,
                user_name,
                (
                    "Live scan completed, but the model returned malformed data. "
                    "Review the backend console logs."
                ),
            )
            return 0 if fallback_success else 1
    except Exception as e:
        print(f"Error during agent scan: {e}", file=sys.stderr)
        if os.getenv("DRIFT_DEBUG"):
            import traceback

            traceback.print_exc()
        fallback_success = write_fallback_report(
            output_path,
            user_name,
            f"Live scan could not complete: {e}",
        )
        return 0 if fallback_success else 1


def main():
    parser = argparse.ArgumentParser(
        description="Drift Developer Attention Debt Tracker Agent"
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    scan_parser = subparsers.add_parser(
        "scan", help="Scan developer tools and generate attention debt report"
    )
    scan_parser.add_argument(
        "--mock",
        action="store_true",
        help="Generate mock report instead of running live scan",
    )
    scan_parser.add_argument(
        "--live", action="store_true", help="Run live scan (default)"
    )
    scan_parser.add_argument(
        "--output",
        default=str(
            Path(__file__).resolve().parent.parent / "data" / "drift_report.json"
        ),
        help="Path to write the output JSON report",
    )
    scan_parser.add_argument(
        "--github-username", help="GitHub username of the developer"
    )
    scan_parser.add_argument("--user-name", help="Display name of the developer")
    scan_parser.add_argument("--owner", help="GitHub owner/organization")
    scan_parser.add_argument("--repo", help="GitHub repository name")

    args = parser.parse_args()

    if args.command == "scan":
        sys.exit(asyncio.run(run_scan(args)))
    else:
        parser.print_help()
        sys.exit(1)


if __name__ == "__main__":
    main()
