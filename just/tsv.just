import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

# Check TSV files using qsv: https://github.com/dathere/qsv
[group("checks")]
[script]
_tsv-check globs="data/*/*.tsv" schema="":
    if ! command -v qsv >/dev/null 2>&1; then
        echo "✗ qsv CLI not found"
        echo "Install it: https://github.com/dathere/qsv"
        exit 1
    fi

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
