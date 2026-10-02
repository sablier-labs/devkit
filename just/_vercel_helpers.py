"""Shared helpers for Vercel Just recipes."""

import json
import os
import subprocess
import sys
from urllib.parse import urlsplit


def run(*cmd):
    """Run a command, exiting on failure."""
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)


def run_capture_url(*cmd) -> str:
    """Stream deployment output and return its plain-text or structured URL.

    Used to capture the deployment URL printed by `vercel deploy` while still streaming
    its output to the caller. Exits on non-zero return codes, mirroring `run`.
    """
    with subprocess.Popen(cmd, stdout=subprocess.PIPE, text=True, bufsize=1) as proc:
        assert proc.stdout is not None
        lines = []
        for line in proc.stdout:
            sys.stdout.write(line)
            sys.stdout.flush()
            lines.append(line)
    if proc.returncode != 0:
        sys.exit(proc.returncode)
    output = "".join(lines).strip()
    try:
        url = json.loads(output)["deployment"]["url"] if output.startswith("{") else output
        if not isinstance(url, str) or any(char.isspace() for char in url):
            raise ValueError("invalid URL")
        parsed = urlsplit(url)
        if parsed.scheme != "https" or not parsed.hostname:
            raise ValueError("invalid URL")
    except (ValueError, KeyError, TypeError):
        print("Error: Vercel returned no valid deployment URL.", file=sys.stderr)
        sys.exit(1)
    return url


def emit_deployment_url(url: str) -> None:
    """Publish the deployment URL to GitHub Actions and/or a caller-specified file.

    - If `GITHUB_OUTPUT` is set, appends `deployment_url=<url>` so workflow steps can read it
      via `steps.<id>.outputs.deployment_url`.
    - If `VERCEL_DEPLOYMENT_URL_FILE` is set, writes the URL to that path (useful for local
      scripts and non-GitHub CI systems).
    - Always prints a human-readable `Deployment URL: <url>` line to stdout.
    """
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a", encoding="utf-8") as fh:
            fh.write(f"deployment_url={url}\n")

    url_file = os.environ.get("VERCEL_DEPLOYMENT_URL_FILE")
    if url_file:
        with open(url_file, "w", encoding="utf-8") as fh:
            fh.write(url)

    print(f"\nDeployment URL: {url}")


def resolve_vercel_env(app, project_ids_json):
    """Resolve VERCEL_PROJECT_ID and VERCEL_TOKEN, setting them in os.environ.

    Precedence for project ID:
      1. VERCEL_PROJECT_ID already set in the environment
      2. Lookup `app` in the VERCEL_PROJECT_IDS JSON map

    Returns (project_id, token).
    """
    project_id = os.environ.get("VERCEL_PROJECT_ID", "")
    if not project_id:
        project_ids = json.loads(project_ids_json)
        if app not in project_ids:
            print(
                f"Error: unknown app '{app}'. Known apps: {', '.join(project_ids) or '(none)'}",
                file=sys.stderr,
            )
            sys.exit(1)
        project_id = project_ids[app]
    os.environ["VERCEL_PROJECT_ID"] = project_id

    token = os.environ.get("VERCEL_TOKEN", "")
    if not token:
        print("Error: VERCEL_TOKEN is not set.", file=sys.stderr)
        sys.exit(1)

    return project_id, token
