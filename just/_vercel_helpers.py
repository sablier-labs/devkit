"""Shared helpers for Vercel Just recipes."""

import json
import os
import subprocess
import sys


def run(*cmd):
    """Run a command, exiting on failure."""
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)


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
