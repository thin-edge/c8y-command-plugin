#!/bin/sh
set -e

info() {
    echo "$(date --iso-8601=seconds 2>/dev/null || date -Iseconds) INFO $*" >&2
}

PAYLOAD="$1"

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
EXTERNAL_ID=$(printf '%s' "$PAYLOAD" | jq -r '.externalSource.externalId // ""')
TOPIC_ROOT=$(tedge config get mqtt.topic_root)
DEVICE_TOPIC_ID=$(get_device_topic_id "$EXTERNAL_ID")
CMD_ID=$(printf '%s' "$PAYLOAD"  | jq -r '.id')
TOPIC="$TOPIC_ROOT/$DEVICE_TOPIC_ID/cmd/shell_execute/c8y-mapper-$CMD_ID"

COMMAND_PAYLOAD=$(printf '%s' "$PAYLOAD" | jq -c '{"status":"init", "command": (.c8y_Command.text // "")}')

info "Publishing operation (to trigger workflow): $TOPIC $COMMAND_PAYLOAD"
tedge mqtt pub -q 1 -r "$TOPIC" "$COMMAND_PAYLOAD"

info "Waiting for operation to finish: $TOPIC"

# FIXME: Remove once the operations can also trigger workflows
# Wait for operation to complete
while :; do
    # TODO: Fixme this assumes messages are only 1 line! it breaks on pretty printed json
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
