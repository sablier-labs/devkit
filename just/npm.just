import "./settings.just"

# ---------------------------------------------------------------------------- #
#                                 DEPENDENCIES                                 #
# ---------------------------------------------------------------------------- #

# Jq
jq := require("jq")

# Npm
npm := require("npm")

# ---------------------------------------------------------------------------- #
#                                    SCRIPTS                                   #
# ---------------------------------------------------------------------------- #

# Publish the npm package, e.g. v1.0.0
[group("publish")]
publish *args:
  npm publish {{ args }}
  @just tag $(jq -r '.version' package.json)

# Publish using the `beta` tag, e.g. v1.0.0-beta.1
[group("publish")]
publish-beta *args:
  @just check-beta-version
  npm publish --tag beta {{ args }}

# Tag the new version
[group("publish")]
tag *version:
  git tag -am "{{ version }}" {{ version }}
  git push origin --tags

# ---------------------------------------------------------------------------- #
#                                PRIVATE HELPERS                               #
# ---------------------------------------------------------------------------- #


# Check that package.json version includes -beta.x suffix
[private, script("bash")]
@check-beta-version:
  # Extract version from package.json using jq for reliable JSON parsing
  version=$(jq -r '.version' package.json)

  # Check if version contains -beta suffix
  if [[ "$version" =~ -beta\.[0-9]+$ ]]; then
    echo "✓ Version $version includes beta suffix"
  else
    echo "✗ Error: Version $version does not include -beta.x suffix"
    echo "Please update package.json version to include -beta.x (e.g., 1.0.0-beta.1)"
    exit 1
  fi
