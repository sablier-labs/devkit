import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

# Check TSV files using qsv: https://github.com/dathere/qsv
[group("checks")]
[script]
_tsv-check globs="data/*/*.tsv" schema="" ignore="*.tsv.invalid|*.tsv.valid|*validation-errors.tsv":
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
            {{ ignore }})
                continue
                ;;
        esac

        # Skip if no files match the pattern
        [ -e "$file" ] || continue

        found=$((found + 1))
        schema_arg="{{ schema }}"
        if ! qsv validate "$file" ${schema_arg:+"$schema_arg"} > /dev/null 2>&1; then
            echo "❌ Validation failed for: $file"
            just _tsv-show-errors "$file"
            exit 1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo "ℹ️  No TSV files found to validate"
    else
        echo "✅ All TSV files are valid"
    fi

# Show validation errors for a TSV file
[group("checks")]
[script]
_tsv-show-errors file:
    error_file="{{ file }}.validation-errors.tsv"

    if [ ! -f "$error_file" ]; then
        echo "Error file not found: $error_file"
        exit 0
    fi

    # Try to count total errors (subtract 1 for header row)
    total_errors=$(qsv count "$error_file" 2>/dev/null || echo "0")
    if [ "$total_errors" != "0" ]; then
        total_errors=$((total_errors - 1))
    fi

    echo ""
    if [ "$total_errors" != "0" ] && [ "$total_errors" -gt 0 ]; then
        echo "First 20 validation errors (${total_errors} total):"
    else
        echo "Validation errors:"
    fi
    echo ""

    # Try to use qsv table for nice formatting, fall back to basic display
    if qsv slice --start 0 --len 21 "$error_file" 2>/dev/null | qsv table 2>/dev/null; then
        :  # Success, output already shown
    else
        head -n 21 "$error_file"
    fi

    if [ "$total_errors" != "0" ] && [ "$total_errors" -gt 20 ]; then
        echo ""
        echo "... and $((total_errors - 20)) more errors"
    fi
    echo ""
    echo "Full details: $error_file"
