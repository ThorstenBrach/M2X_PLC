/// System dependent MQTT client (TwinCAT: Tc3_IotBase, TF6701)
FUNCTION_BLOCK SysDepMqttClientFB
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepMqttClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent MQTT client (TwinCAT: Tc3_IotBase, TF6701)
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
  /// Client configuration (read when Enable becomes TRUE)
  Config : SysDepMqttConfig;
END_VAR
VAR_OUTPUT
  /// Client is connected to the broker
  Connected : BOOL;
  /// Client reports an error
  Error     : BOOL;
  /// Error code of the platform
  ErrorId   : UDINT;
END_VAR
VAR
  /// MQTT client of Tc3_IotBase
 _client      : FB_IotMqttClient;
  /// Queue for received messages
 _queue       : FB_IotMqttMessageQueue;
  /// Message read from the queue
 _message     : FB_IotMqttMessage;
  /// Configuration was copied into the client
 _configured  : BOOL;
  /// Payload of the last will (must stay valid while connected)
 _willPayload : ARRAY [0..1023] OF BYTE;
END_VAR
  // Copy the configuration while not connected
  IF ( NOT _configured )
  THEN
   _client.sClientId     := Config.ClientId;
   _client.sHostName     := Config.HostName;
   _client.nHostPort     := Config.Port;
   _client.nKeepAlive    := Config.KeepAlive;
   _client.sUserName     := Config.UserName;
   _client.sUserPassword := Config.Password;

    IF ( Config.TlsEnabled )
    THEN
     _client.stTLS.sCA                := Config.TlsCaFile;
     _client.stTLS.sCert              := Config.TlsCertFile;
     _client.stTLS.sKeyFile           := Config.TlsKeyFile;
     _client.stTLS.sKeyPwd            := Config.TlsKeyPassword;
     _client.stTLS.bNoServerCertCheck := Config.TlsNoServerCertCheck;
    END_IF

   _client.ipMessageQueue := _queue;
   _configured            := TRUE;
  END_IF

 _client.Execute(bConnect := Enable);

  Connected := _client.bConnected;
  Error     := _client.bError;
  ErrorId   := DINT_TO_UDINT(_client.hrErrorCode);

  // Read the configuration again after a disconnect
  IF (( NOT Enable ) AND ( NOT Connected ))
  THEN
   _configured := FALSE;
  END_IF

METHOD Publish : BOOL
/// Publishes a message
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Quality of service
  QoS           : SysDepMqttQoS;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
  Publish := _client.Publish(sTopic       := Topic,
                             pPayload     := pPayload,
                             nPayloadSize := PayloadLength,
                             eQoS         := ToTcQoS(QoS),
                             bRetain      := RetainFlag,
                             bQueue       := FALSE);
END_METHOD

METHOD Receive : BOOL
/// Reads the next received message (FALSE if none)
VAR_INPUT
  /// Buffer for the topic (null-terminated string)
  pTopic      : POINTER TO BYTE;
  /// Size of the topic buffer in bytes
  TopicSize   : UDINT;
  /// Buffer for the payload
  pPayload    : POINTER TO BYTE;
  /// Size of the payload buffer in bytes
  PayloadSize : UDINT;
END_VAR
VAR_IN_OUT
  /// Length of the received payload
  PayloadLength : UDINT;
  /// Payload did not fit into the buffer
  Oversized     : BOOL;
END_VAR
VAR
  /// Number of topic bytes to copy
 _topicLength : UDINT;
END_VAR
  IF ( _queue.nQueuedMessages = 0 )
  THEN
    RETURN;
  END_IF

  IF ( NOT _queue.Dequeue(fbMessage := _message) )
  THEN
    RETURN;
  END_IF

  // Copy topic and terminate it
 _topicLength := MIN(UINT_TO_UDINT(_message.nTopicSize), TopicSize - 1);
  MEMCPY(destAddr := pTopic, srcAddr := _message.pTopic, n := _topicLength);
  pTopic[_topicLength] := 0;

  // Copy payload
  IF ( _message.nPayloadSize > PayloadSize )
  THEN
    Oversized     := TRUE;
    PayloadLength := 0;
  ELSE
    Oversized     := FALSE;
    PayloadLength := _message.nPayloadSize;
    MEMCPY(destAddr := pPayload, srcAddr := _message.pPayload, n := PayloadLength);
  END_IF

  Receive := TRUE;
END_METHOD

METHOD SetLastWill : BOOL
/// Sets the last will (used at the next connect)
VAR_INPUT
  /// Topic of the last will
  Topic         : STRING(255);
  /// Payload of the last will
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Quality of service
  QoS           : SysDepMqttQoS;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
  IF ( PayloadLength > SIZEOF(_willPayload) )
  THEN
    RETURN;
  END_IF

  MEMCPY(destAddr := ADR(_willPayload), srcAddr := pPayload, n := PayloadLength);
 _client.stWill.sTopic       := Topic;
 _client.stWill.pPayload     := ADR(_willPayload);
 _client.stWill.nPayloadSize := PayloadLength;
 _client.stWill.eQoS         := ToTcQoS(QoS);
 _client.stWill.bRetain      := RetainFlag;

  SetLastWill := TRUE;
END_METHOD

METHOD Subscribe : BOOL
/// Subscribes to a topic
VAR_INPUT
  /// Topic filter
  Topic : STRING(255);
  /// Quality of service
  QoS   : SysDepMqttQoS;
END_VAR
  Subscribe := _client.Subscribe(sTopic := Topic, eQoS := ToTcQoS(QoS));
END_METHOD

METHOD PRIVATE ToTcQoS : TcIotMqttQos
/// Converts the neutral QoS into the TwinCAT QoS
VAR_INPUT
  /// Neutral QoS
  QoS : SysDepMqttQoS;
END_VAR
  CASE QoS OF
    SysDepMqttQoS.AT_LEAST_ONCE:
      ToTcQoS := TcIotMqttQos.AtLeastOnceDelivery;
    SysDepMqttQoS.EXACTLY_ONCE:
      ToTcQoS := TcIotMqttQos.ExactlyOnceDelivery;
  ELSE
    ToTcQoS := TcIotMqttQos.AtMostOnceDelivery;
  END_CASE
END_METHOD

END_FUNCTION_BLOCK
