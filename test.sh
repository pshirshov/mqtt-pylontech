#!/usr/bin/env bash
set -euo pipefail

RS485_HOST="${1:?Usage: $0 <rs485-converter-address> [rs485-port] [mqtt-port]}"
RS485_PORT="${2:-23}"
MQTT_PORT="${3:-1883}"

MQTT_TMPDIR="$(mktemp -d)"
trap 'kill "$MOSQUITTO_PID" 2>/dev/null; rm -rf "$MQTT_TMPDIR"' EXIT

cat > "$MQTT_TMPDIR/mosquitto.conf" <<EOF
listener ${MQTT_PORT} 127.0.0.1
allow_anonymous true
persistence false
log_dest stderr
EOF

echo "starting mosquitto on 127.0.0.1:${MQTT_PORT}..."
mosquitto -c "$MQTT_TMPDIR/mosquitto.conf" &
MOSQUITTO_PID=$!
sleep 1

if ! kill -0 "$MOSQUITTO_PID" 2>/dev/null; then
    echo "ERROR: mosquitto failed to start" >&2
    exit 1
fi
echo "mosquitto running (pid=$MOSQUITTO_PID)"

echo "starting pylontech-mqtt-adapter: source=${RS485_HOST}:${RS485_PORT} mqtt=127.0.0.1:${MQTT_PORT}"
cargo run -- \
    "$RS485_HOST" \
    --source-port "$RS485_PORT" \
    --mqtt-host 127.0.0.1 \
    --mqtt-port "$MQTT_PORT" \
    --stats-interval-millis 10000
