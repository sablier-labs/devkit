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
# Note: if VERCEL_PROJECT_ID is already set in the environment, this map is ignored.
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
alias vb := build

# Deploy website to Vercel. Trailing args are forwarded to `vercel deploy`.
[arg("app", long)]
[arg("env", long)]
[arg("skip_build", long="skip-build", value="true")]
[confirm("Are you sure you want to deploy? [y/N]")]
[group("vercel")]
deploy app env="staging" skip_build="false" *args="":
    @just _vercel-deploy "{{ app }}" "{{ env }}" "{{ skip_build }}" {{ args }}
alias vd := deploy

# ---------------------------------------------------------------------------- #
#                                PRIVATE HELPERS                               #
# ---------------------------------------------------------------------------- #

# Core build: vercel pull + vercel build
[private, script("python3")]
_vercel-build app env:
    import sys; sys.path.insert(0, "{{ source_directory() }}")
    import os
    from _vercel_helpers import resolve_vercel_env, run

    # Workaround for https://github.com/vercel/vercel/issues/14666
    os.environ["VERCEL_TARGET_ENV"] = "{{ env }}"
    os.environ["NEXT_PUBLIC_VERCEL_TARGET_ENV"] = "{{ env }}"

    project_id, token = resolve_vercel_env("{{ app }}", '{{ VERCEL_PROJECT_IDS }}')

    # Pull the environment from the Vercel project
    run("na", "vercel", "pull", "--environment={{ env }}", f"--token={token}", "--yes")

    # Build the project
    run("na", "vercel", "build", "--target={{ env }}", f"--token={token}")

# Core deploy: optionally build, then deploy prebuilt artifacts
[private, script("python3")]
_vercel-deploy app env skip_build="false" *args="":
    import shlex, sys; sys.path.insert(0, "{{ source_directory() }}")
    import os
    from _vercel_helpers import emit_deployment_url, resolve_vercel_env, run, run_capture_url

    # Build the project if not skipped (calls the PUBLIC recipe so consumer overrides apply)
    if "{{ skip_build }}" != "true":
        run("just", "build", "--app={{ app }}", "--env={{ env }}")

    # Workaround for https://github.com/vercel/vercel/issues/14666
    os.environ["VERCEL_TARGET_ENV"] = "{{ env }}"
    os.environ["NEXT_PUBLIC_VERCEL_TARGET_ENV"] = "{{ env }}"

    project_id, token = resolve_vercel_env("{{ app }}", '{{ VERCEL_PROJECT_IDS }}')

    # Deploy the project to Vercel, capturing the deployment URL from stdout
    extra = shlex.split("""{{ args }}""")
    url = run_capture_url(
        "na", "vercel", "deploy", "--prebuilt", "--target={{ env }}", f"--token={token}", *extra
    )
    emit_deployment_url(url)
