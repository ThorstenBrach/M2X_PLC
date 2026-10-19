# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** – incompatible API changes (FB interfaces, data types, behaviour on the wire)
- **MINOR** – new functions, backwards compatible
- **PATCH** – bug fixes, backwards compatible

The library version has a fourth digit (`MAJOR.MINOR.PATCH.BUILD`, as in the TwinCAT / CODESYS project information); the build number counts releases without functional change.

As long as the version starts with **0.**, the API is not stable yet – also because the M2X specification itself is still before 1.0. Breaking changes are then possible in a MINOR version and are marked with **BREAKING**.

| Library | M2X specification |
|---|---|
| 0.0.0.x | 0.9.0 (June 2026) |

## [Unreleased]

### Added
- **Example solution** `M2XLibraryExample/M2XLibraryExample.tnzip` (TwinCAT solution archive, PLC + HMI): an AMR picks a part at station A, passes door D1, traffic light T1 and elevator G1, delivers it to machine B and charges at charger C1
  - all six interfaces as client and server in one PLC, over the mock broker or MQTT (`GVL_Demo.bUseMqtt`)
  - fleet manager with transport orders, cancel and elevator manual mode; requests for factsheets of all devices
  - helpers `FB_ServerApp` (server side), `FB_M2XStep` (client side) and `FB_DemoTransport` (mock broker or MQTT)
  - TwinCAT HMI in German and English: plan, state of all participants, live M2X event log, test functions (fault at machine B, acknowledge, manual mode, automatic orders, AMR reset)
- **Documentation:** [Example](docs/Example.md) with structure, sequence, HMI and screenshots; README and repository structure updated

### Planned
- MQTT client in `M2XLibrarySysDep_3S` (CODESYS IIoT Libraries) and tests of the main library on CODESYS
- factsheet data types per interface
- release workflow

## [0.0.0.1] - 2026-10-16

First version. Server and client for all six M2X interfaces on TwinCAT 3, system dependencies for TwinCAT and CODESYS.

### Added
- **Servers:** `LhsServerFB`, `DoorServerFB`, `SignalingDeviceServerFB`, `ChargingDeviceServerFB`, `ElevatorServerFB`, `TransportOrderServerFB` on the common base `ServerBaseFB`
  - request table, request lifecycle PENDING → RUNNING ⇄ PAUSED → FINISHED / FAILED
  - one active request per sender, `requestCancel`, `requestFactsheet`
  - sequence checks: load handling (access → transfer → exit → release, continue after failure), charging, elevator sessions
  - queueing of `requestAccess` / `requestElevator` while a point or elevator is occupied
  - door may stay open for several transits (`OpenTransitCount`)
  - signaling device with global and individual signals
  - elevator group with assignment of the least busy elevator
  - transport order updates with `sequenceId` merge, cancel, `lastObjectiveId`
  - state on every change and every 30 s, retained; MQTT last will `CONNECTION_BROKEN`, `OFFLINE` on disable
  - error list with `AddError` / `RemoveError` / `ClearErrors`
- **Clients:** `LhsClientFB`, `DoorClientFB`, `SignalingDeviceClientFB`, `ChargingDeviceClientFB`, `ElevatorClientFB`, `TransportOrderClientFB` on the common base `ClientBaseFB`, plus `RequestFB` (Execute / Busy / Done / Error)
- **JSON:** `JsonWriterFB` and `JsonParserFB` in pure Structured Text (escaping, `\uXXXX` to UTF-8, messages up to `MESSAGE_SIZE_MAX`)
- **Transport:** `ITransport`, `MqttTransportFB`, `MockBrokerFB` / `MockTransportFB` (retained messages, wildcards, last will)
- **System dependencies TwinCAT:** `M2XLibrarySysDep_Tc` with memory functions, UTC time, seed and `SysDepMqttClientFB` (TF6701, TLS)
- **System dependencies CODESYS:** `M2XLibrarySysDep_3S` with the same signatures – memory (`SysMem`), UTC time (`SysTimeRtc`), seed, LREAL check; `SysDepMqttClientFB` as stub
- **Core:** topics, ISO 8601 timestamps, UUID v4 request ids, enum ↔ JSON text conversion
- **Tests:** 43 TcUnit tests in 9 suites, including an MQTT loopback over a real broker
- **Delivery:** not compiled libraries (`.library`) and PLCopen XML
- **Documentation:** README, M2X explanation, usage guide, diagrams

### Decisions on open points of M2X 0.9.0
- one generic request topic `…/request` per entity
- `headerId` in every message
- optional `senderId` in the request, echoed in `requestStates[]`
- one common error object with `errorReferences[]` for all interfaces

### Known issues
- the generated factsheet only contains the basic fields; the full factsheet is passed as JSON with `SetFactsheet()`
- CODESYS: the MQTT client of `M2XLibrarySysDep_3S` is not bound yet (`MqttTransportFB` reports `ErrorId 16#FFFF`); the main library has not been tested on CODESYS
- `M2XLibrarySysDep_3S` uses tabs instead of the project indentation (from the round trip via CODESYS)

[Unreleased]: https://github.com/ThorstenBrach/M2X_PLC/compare/v0.0.0.1...HEAD
[0.0.0.1]: https://github.com/ThorstenBrach/M2X_PLC/releases/tag/v0.0.0.1
