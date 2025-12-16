import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

# Check CSV/TSV files using qsv: https://github.com/dathere/qsv
[group("checks"), script("python3")]
_csv-check globs="data/*/*.csv" ext="csv" schema="" ignore="*.csv.invalid|*.csv.valid|*validation-errors.csv":
    import fnmatch
    import glob as globmod
    import subprocess
    import sys

    # Check qsv is available
    if subprocess.run(["which", "qsv"], capture_output=True).returncode != 0:
        print("✗ qsv CLI not found")
        print("Install it: https://github.com/dathere/qsv")
        sys.exit(1)

    ext = "{{ ext }}" or "csv"
    ignore_patterns = "{{ ignore }}".split("|") if "{{ ignore }}" else []
    schema = "{{ schema }}" or None
    globs = "{{ globs }}"

    print(f"Validating {ext} files...")
    files = globmod.glob(globs)

    # Filter ignored files
    files = [f for f in files if not any(fnmatch.fnmatch(f, p) for p in ignore_patterns)]

    if not files:
        print(f"ℹ️  No {ext} files found to validate")
        sys.exit(0)

    for file in files:
        cmd = ["qsv", "validate", file]
        if schema:
            cmd.append(schema)
        result = subprocess.run(cmd, capture_output=True)
        if result.returncode != 0:
            print(f"❌ Validation failed for: {file}")
            subprocess.run(["just", "_csv-show-errors", file, ext])
            sys.exit(1)

    print(f"✅ All {ext} files are valid")

# Show validation errors for a CSV/TSV file
[group("checks"), script("python3")]
_csv-show-errors file ext="csv":
    import os
    import subprocess
    import sys

    file = "{{ file }}"
    # qsv always produces .validation-errors.tsv regardless of input format
    error_file = f"{file}.validation-errors.tsv"

    if not os.path.exists(error_file):
        print(f"Error file not found: {error_file}")
        sys.exit(0)

    # Count errors (qsv auto-detects delimiter based on file extension)
    result = subprocess.run(["qsv", "count", error_file], capture_output=True, text=True)
    try:
        total = int(result.stdout.strip()) if result.returncode == 0 and result.stdout.strip() else 0
    except ValueError:
        total = 0

    print()
    if total > 0:
        print(f"First 20 validation errors ({total} total):")
    else:
        print("Validation errors:")
    print()

    # Try qsv table for nice formatting, fall back to reading file directly
    slice_result = subprocess.run(
        ["qsv", "slice", "--start", "0", "--len", "21", error_file],
        capture_output=True, text=True
    )
    if slice_result.returncode == 0:
        table_result = subprocess.run(
            ["qsv", "table"],
            input=slice_result.stdout,
            capture_output=True, text=True
        )
        if table_result.returncode == 0:
            print(table_result.stdout)
        else:
            print(slice_result.stdout)
    else:
        with open(error_file) as f:
            for i, line in enumerate(f):
                if i >= 21:
                    break
                print(line, end="")

    if total > 20:
        print()
        print(f"... and {total - 20} more errors")
    print()
    print(f"Full details: {error_file}")
