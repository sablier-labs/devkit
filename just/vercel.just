import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# Ni: https://github.com/antfu-collective/ni
na := require("na")

# ---------------------------------------------------------------------------- #
#                                   CONSTANTS                                  #
# ---------------------------------------------------------------------------- #

# Consumer MUST override with a JSON map of app name → Vercel project ID.
# Example: '{"portal": "prj_xxx", "landing": "prj_yyy"}'
VERCEL_PROJECT_IDS := '{}'

# ---------------------------------------------------------------------------- #
#                                    RECIPES                                   #
# ---------------------------------------------------------------------------- #

# Build website for Vercel deployment
[arg("app", long)]
[arg("env", long)]
[group("vercel")]
build app env="staging":
    @just _vercel-build "{{ app }}" "{{ env }}"
alias b := build

# Deploy website to Vercel
[arg("app", long)]
[arg("env", long)]
[arg("skip_build", long="skip-build", value="true")]
[confirm("Are you sure you want to deploy? [y/N]")]
[group("vercel")]
deploy app env="staging" skip_build="false":
    @just _vercel-deploy "{{ app }}" "{{ env }}" "{{ skip_build }}"
alias d := deploy

# ---------------------------------------------------------------------------- #
#                                PRIVATE HELPERS                               #
# ---------------------------------------------------------------------------- #

# Core build: vercel pull + vercel build
[private, script("python3")]
_vercel-build app env:
    import json, os, subprocess, sys

    def run(*cmd):
        result = subprocess.run(cmd)
        if result.returncode != 0:
            sys.exit(result.returncode)

    # Workaround for https://github.com/vercel/vercel/issues/14666
    os.environ["VERCEL_TARGET_ENV"] = "{{ env }}"
    os.environ["NEXT_PUBLIC_VERCEL_TARGET_ENV"] = "{{ env }}"

    # Resolve project ID from app name
    project_ids = json.loads('{{ VERCEL_PROJECT_IDS }}')
    app = "{{ app }}"
    if app not in project_ids:
        print(f"Error: unknown app '{app}'. Known apps: {', '.join(project_ids) or '(none)'}", file=sys.stderr)
        sys.exit(1)
    os.environ["VERCEL_PROJECT_ID"] = project_ids[app]

    token = os.environ.get("VERCEL_TOKEN", "")
    if not token:
        print("Error: VERCEL_TOKEN is not set.", file=sys.stderr)
        sys.exit(1)

    # Pull the environment from the Vercel project
    run("na", "vercel", "pull", "--environment={{ env }}", f"--token={token}", "--yes")

    # Build the project
    run("na", "vercel", "build", "--target={{ env }}", f"--token={token}")

# Core deploy: optionally build, then deploy prebuilt artifacts
[private, script("python3")]
_vercel-deploy app env skip_build="false":
    import json, os, subprocess, sys

    def run(*cmd):
        result = subprocess.run(cmd)
        if result.returncode != 0:
            sys.exit(result.returncode)

    # Build the project if not skipped (calls the PUBLIC recipe so consumer overrides apply)
    if "{{ skip_build }}" != "true":
        run("just", "build", "--app={{ app }}", "--env={{ env }}")

    # Workaround for https://github.com/vercel/vercel/issues/14666
    os.environ["VERCEL_TARGET_ENV"] = "{{ env }}"
    os.environ["NEXT_PUBLIC_VERCEL_TARGET_ENV"] = "{{ env }}"

    # Resolve project ID from app name
    project_ids = json.loads('{{ VERCEL_PROJECT_IDS }}')
    app = "{{ app }}"
    if app not in project_ids:
        print(f"Error: unknown app '{app}'. Known apps: {', '.join(project_ids) or '(none)'}", file=sys.stderr)
        sys.exit(1)
    os.environ["VERCEL_PROJECT_ID"] = project_ids[app]

    token = os.environ.get("VERCEL_TOKEN", "")
    if not token:
        print("Error: VERCEL_TOKEN is not set.", file=sys.stderr)
        sys.exit(1)

    # Deploy the project to Vercel
    run("na", "vercel", "deploy", "--prebuilt", "--target={{ env }}", f"--token={token}")
