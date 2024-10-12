#!/bin/sh
set -e

info() {
    echo "$(date --iso-8601=seconds 2>/dev/null || date -Iseconds) INFO $*" >&2
}

CMD_ID=
COMMAND=
EXTERNAL_ID=
POSITIONAL_ARGS=

while [ $# -gt 0 ]; do
    case "$1" in
        --id)
            CMD_ID="$2"
            shift
            ;;
        --external-id)
            EXTERNAL_ID="$2"
            shift
            ;;
        --command)
            COMMAND="$2"
            shift
            ;;
        --*|-*) 
            echo "Unknown flag. $1" >&2
            exit 1
            ;;
        *)
            POSITIONAL_ARGS="$POSITIONAL_ARGS $1"
            ;;
    esac
    shift
done

set -- "$POSITIONAL_ARGS"

get_device_topic_id() {
    external_id="$1"
    DEVICE_ID=$(tedge config get device.id)

    if [ "$external_id" = "$DEVICE_ID" ]; then
        TARGET="device/main//"
    else
        TARGET=$(echo "$external_id" | cut -d: -f2- | sed 's/:/\//g')
        case "$TARGET" in
            */*/*/*)
                # Do nothing
                ;;
            */*/*)
                TARGET="$TARGET/"
                ;;
            */*)
                TARGET="$TARGET//"
                ;;
            *)
                TARGET="$TARGET///"
                ;;
        esac
    fi
    echo "$TARGET"
}

# Convert the cloud's external id to the local thin-edge.io topic id
TOPIC_ROOT=$(tedge config get mqtt.topic_root)
DEVICE_TOPIC_ID=$(get_device_topic_id "$EXTERNAL_ID")
CMD_ID=$(echo "$PAYLOAD" | jq -r '.id')
TOPIC="$TOPIC_ROOT/$DEVICE_TOPIC_ID/cmd/shell_execute/c8y-mapper-$CMD_ID"

COMMAND_PAYLOAD=$(echo "$PAYLOAD" | jq -c '{"status":"init", "command": (.c8y_Command.text // "")}')

info "Publishing operation (to trigger workflow): $TOPIC $COMMAND_PAYLOAD"
tedge mqtt pub -q 1 -r "$TOPIC" "$COMMAND_PAYLOAD"

info "Waiting for operation to finish: $TOPIC"

# Wait for operation to complete
while :; do
    LAST_MESSAGE=$(timeout 2 tedge mqtt sub "$TOPIC" --no-topic ||:)
    STATUS=$(printf '%s' "$LAST_MESSAGE" | jq -r '.status // ""' ||:)

    info "Waiting for operation to finish: $TOPIC, status=$STATUS"

    # Clear the operation on a terminal state
    # Note: use jq -j to exclude the newline character which is normally added to the output
    case "$STATUS" in
        successful)
            info "Operation successful"
            printf '%s' "$LAST_MESSAGE" | jq -jr '.result // ""'
            tedge mqtt pub -q 1 -r "$TOPIC" ''
            exit 0
            ;;

        failed)
            info "Operation failed"
            printf '%s' "$LAST_MESSAGE" | jq -jr '.result // ""'
            tedge mqtt pub -q 1 -r "$TOPIC" ''
            exit 1
            ;;
        *)
            info "Waiting for operation to finish: topic=$TOPIC, status=$STATUS"
            ;;
    esac
done
