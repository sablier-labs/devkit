import "./just/base.just"

[group("checks")]
@full-check:
    just _run-with-status prettier-check
    just _run-with-status biome-check
