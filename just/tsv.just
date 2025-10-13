import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# qsv: https://github.com/dathere/qsv
qsv := require("qsv")

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

# Check TSV files
[group("checks")]
[script]
tsv-check globs="data/*/*.tsv" schema="":
    echo "Validating TSV files..."
    found=0
    for file in {{ globs }}; do
        # Skip validation artifact files
        case "$file" in
            *.tsv.invalid|*.tsv.valid|*validation-errors.tsv)
                continue
                ;;
        esac

        # Skip if no files match the pattern
        [ -e "$file" ] || continue

        found=$((found + 1))
        if ! qsv validate "$file" {{ schema }} > /dev/null 2>&1; then
            echo "❌ Validation failed for: $file"
            echo "See $file.validation-errors.tsv for details"
            exit 1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "ℹ️  No TSV files found to validate"
    else
        echo "✅ All TSV files are valid"
    fi
