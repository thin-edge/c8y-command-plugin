#!/bin/bash
# -------------------------------------------
# Build linux packages
# -------------------------------------------
set -e

# clean dist
if [ -d dist ]; then
    rm -rf dist
fi

mkdir -p dist

while [ $# -gt 0 ]; do
    case "$1" in
        --)
            # Stop parsing args as these will be passed as is to nfpm
            shift
            break
            ;;
        *)
            export SEMVER="$1"
            ;;
    esac
    shift
done

if [ -n "$SEMVER" ]; then
    echo "Using version: $SEMVER"
fi

packages=(
    deb
    apk
    rpm
)

for package_type in "${packages[@]}"; do
    echo ""
    nfpm package --packager "$package_type" --target ./dist/ "$@"
done

echo "Created all linux packages"
