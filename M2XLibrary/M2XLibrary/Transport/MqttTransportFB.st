/// MQTT transport (uses the system dependent MQTT client)
FUNCTION_BLOCK MqttTransportFB IMPLEMENTS ITransport
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      MqttTransportFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    MQTT transport (uses the system dependent MQTT client)
//
//  Copyright:
//    (C) 2026 Thorsten Brach. All rights reserved
//             Licensed under the MIT License.
//
//  Disclaimer:
//    This project is provided without any guarantee and can be used for
//    private and commercial purposes. Any use is at the user's
//    own risk and responsibility.
//
// -------------------------------------------------------------------------
VAR_INPUT
  /// Connect to the broker
  Enable : BOOL;
  /// MQTT configuration
  Config : SysDepMqttConfig;
  /// Quality of service of publish and subscribe
  QoS    : SysDepMqttQoS := SysDepMqttQoS.AT_LEAST_ONCE;
END_VAR
VAR_OUTPUT
  /// MQTT client reports an error
  Error   : BOOL;
  /// Error code of the platform
  ErrorId : UDINT;
END_VAR
VAR
  /// System dependent MQTT client
 _client : SysDepMqttClientFB;
END_VAR
 _client(Enable := Enable, Config := Config);
  Error   := _client.Error;
  ErrorId := _client.ErrorId;
END_FUNCTION_BLOCK

PROPERTY Connected : BOOL
/// Transport is connected
GET
VAR
END_VAR
  Connected := _client.Connected;
END_GET
END_PROPERTY

METHOD Publish : BOOL
/// Publishes a message
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
  Publish := _client.Publish(Topic         := Topic,
                             pPayload      := pPayload,
                             PayloadLength := PayloadLength,
                             QoS           := QoS,
                             RetainFlag        := RetainFlag);
END_METHOD

METHOD Receive : BOOL
/// Reads the next received message (FALSE if none)
VAR_IN_OUT
  /// Received message
  Message : MessageData;
END_VAR
  Receive := _client.Receive(pTopic        := ADR(Message.Topic),
                             TopicSize     := SIZEOF(Message.Topic),
                             pPayload      := ADR(Message.Payload),
                             PayloadSize   := SIZEOF(Message.Payload),
                             PayloadLength := Message.PayloadLength,
                             Oversized     := Message.Oversized);
END_METHOD

METHOD SetLastWill : BOOL
/// Sets the last will (used at the next connect)
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
  SetLastWill := _client.SetLastWill(Topic         := Topic,
                                     pPayload      := pPayload,
                                     PayloadLength := PayloadLength,
                                     QoS           := QoS,
                                     RetainFlag        := RetainFlag);
END_METHOD

METHOD Subscribe : BOOL
/// Subscribes to a topic filter
VAR_INPUT
  /// Topic filter
  Topic : STRING(255);
END_VAR
  Subscribe := _client.Subscribe(Topic := Topic, QoS := QoS);
END_METHOD
