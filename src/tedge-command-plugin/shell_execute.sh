#!/bin/sh
set -e

info() {
    echo "$(date --iso-8601=seconds 2>/dev/null || date -Iseconds) INFO $*" >&2
}

usage() {
    cat <<EOT

Execute a shell command

FLAGS
    --command <cmd>     Command to execute
    --shell <path>      Shell to be used to execute the command

EXAMPLES
    $0 --execute "echo hello world"
    # Run a command
EOT
}

# Default values (can be overridden by the settings file)
SHELL_OPTIONS="bash sh"
SHELL_BIN=

# Load settings file
SETTINGS_FILE=/etc/c8y-command-plugin/env
if [ -f "$SETTINGS_FILE" ]; then
    FOUND_FILE=$(find "$SETTINGS_FILE" -perm 644 | head -n1)

    if [ -n "$FOUND_FILE" ]; then
        info "Loading settings: $FOUND_FILE"
        # shellcheck disable=SC1090
        . "$FOUND_FILE" ||:
    fi
fi


info "Parsing arguments: $*"

COMMAND=

while [ $# -gt 0 ]; do
    case "$1" in
        --command)
            COMMAND="$2"
            shift
            ;;
        --shell)
            SHELL_BIN="$2"
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
    esac
    shift
done


# Auto detect the shell. Match on the first available shell
# If the shell bin is invalid, then just let it fail (this might be useful to disable the shell function on the device)
if [ -z "$SHELL_BIN" ]; then
    for NAME in $SHELL_OPTIONS; do
        if command -V "$NAME" >/dev/null 2>&1; then
            SHELL_BIN="$NAME"
            break
        fi
    done
fi

if [ -z "$SHELL_BIN" ]; then
    SHELL_BIN="sh"
fi

info "Using shell: $SHELL_BIN"

# Write command output to a temporary file
TMP_OUTPUT=$(mktemp)

# shellcheck disable=SC2317
cleanup() {
    trap - EXIT
    rm -f "$TMP_OUTPUT"
}
trap cleanup EXIT

info "Writing command output to file. path=$TMP_OUTPUT"

EXIT_CODE=0
set +e
"$SHELL_BIN" -c "$COMMAND" >"$TMP_OUTPUT" 2>&1
EXIT_CODE=$?
set -e

if [ "${EXIT_CODE}" -ne 0 ]; then
    info "Command returned a non-zero exit code. code=$EXIT_CODE"
fi

echo :::begin-tedge:::
printf '{"result":%s}\n' "$(jq -R -s '.' < "$TMP_OUTPUT")"
echo :::end-tedge:::

exit "$EXIT_CODE"
