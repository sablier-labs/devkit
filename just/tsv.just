import "./csv.just"

# ---------------------------------------------------------------------------- #
#                                 TSV WRAPPERS                                 #
# ---------------------------------------------------------------------------- #

# Check TSV files using qsv: https://github.com/dathere/qsv
[group("checks")]
_tsv-check globs="data/*/*.tsv" schema="" ignore="*.tsv.invalid|*.tsv.valid|*validation-errors.tsv":
    @just _csv-check "{{ globs }}" "{{ schema }}" "{{ ignore }}" "TSV"

# Show validation errors for a TSV file
[group("checks")]
_tsv-show-errors file:
    @just _csv-show-errors "{{ file }}" "TSV"
