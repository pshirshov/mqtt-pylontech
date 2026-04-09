# pylontech-mqtt-adapter

Standalone Rust MQTT adapter for Pylontech lithium battery systems.

Connects directly to a Pylontech battery stack via a TCP-to-RS485 bridge, polls per-module telemetry, and publishes Home Assistant-compatible MQTT discovery payloads.

## Features

- Scans a configurable module address range
- Polls battery values, system parameters, and management info
- Publishes Home Assistant MQTT discovery (sensors + binary sensors)
- Publishes stack-level and per-module JSON state topics
- Exponential backoff reconnection on failure
- Periodic runtime statistics reporting

## Building

```bash
nix build
# or
nix develop -c cargo build --release
```

## Usage

```bash
pylontech-mqtt-adapter <rs485-bridge-host> \
  --mqtt-host mqtt.local \
  --mqtt-user mqtt \
  --mqtt-password-file /var/run/agenix/mqtt-user
```

### CLI options

| Flag | Default | Description |
|------|---------|-------------|
| `<source_host>` | *(required)* | TCP bridge host (RS485 converter address) |
| `--source-port` | `23` | TCP bridge port |
| `--timeout-millis` | `2000` | Read/write timeout |
| `--interval-millis` | `1000` | Polling interval |
| `--management-interval-millis` | `30000` | Management info polling interval |
| `--scan-start` | `2` | First module address to probe |
| `--scan-end` | `9` | Last module address to probe |
| `--mqtt-host` | *(required)* | MQTT broker host |
| `--mqtt-port` | `1883` | MQTT broker port |
| `--mqtt-user` | | MQTT username |
| `--mqtt-password` | | MQTT password |
| `--mqtt-password-file` | | Read MQTT password from file |
| `--discovery-prefix` | `homeassistant` | Home Assistant MQTT discovery prefix |
| `--topic-prefix` | `pylontech` | Base topic prefix |
| `--client-id` | `pylontech-rs-mqtt-adapter` | MQTT client id |

## MQTT topics

| Topic | Description |
|-------|-------------|
| `pylontech/status` | Availability (`online`/`offline`) |
| `pylontech/stack/state` | Aggregated stack state (disbalance) |
| `pylontech/module/<addr>/state` | Per-module telemetry |
| `pylontech/module/<addr>/system/state` | System parameter limits |
| `pylontech/module/<addr>/management/state` | Management flags and limits |
| `homeassistant/<component>/<id>/config` | HA discovery payloads |

## Testing

The included test script spawns a local mosquitto instance and runs the adapter:

```bash
./test.sh <rs485-converter-address> [rs485-port] [mqtt-port]
```
