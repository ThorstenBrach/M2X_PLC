/// Transport connected to a MockBrokerFB (tests without MQTT)
FUNCTION_BLOCK MockTransportFB IMPLEMENTS ITransport
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      MockTransportFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Transport connected to a MockBrokerFB (tests without MQTT)
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
  /// Broker
  Broker : POINTER TO MockBrokerFB;
END_VAR
VAR_OUTPUT
  /// Number of lost messages because the queue was full
  Overflows : UDINT;
END_VAR
VAR
  /// Connected to the broker
 _connected         : BOOL;
  /// Connection loss was simulated (reconnect only after Enable = FALSE)
 _lost              : BOOL;
  /// Subscribed topic filters
 _subscriptions     : ARRAY [1..M2XLibraryParameter.SUBSCRIPTIONS_MAX] OF STRING(255);
  /// Number of subscriptions
 _subscriptionCount : DINT;
  /// Receive queue
 _queue             : ARRAY [0..M2XLibraryParameter.MESSAGE_QUEUE_MAX - 1] OF MessageData;
  /// Index of the oldest message
 _head              : UDINT;
  /// Number of queued messages
 _count             : UDINT;
  /// Topic of the last will
 _willTopic         : STRING(255);
  /// Payload of the last will
 _willPayload       : ARRAY [0..M2XLibraryParameter.WILL_SIZE_MAX - 1] OF BYTE;
  /// Length of the last will payload
 _willLength        : UDINT;
  /// Retain flag of the last will
 _willRetain        : BOOL;
  /// Last will is set
 _willSet           : BOOL;
END_VAR
  IF (( Enable ) AND ( NOT _connected ) AND ( NOT _lost ) AND ( Broker <> 0 ))
  THEN
   _connected := Broker^.Register(Client := THIS);
  ELSIF (( NOT Enable ) AND ( _connected ))
  THEN
    Broker^.Unregister(Client := THIS);
   _connected := FALSE;
  END_IF

  IF ( NOT Enable )
  THEN
   _lost              := FALSE;
   _subscriptionCount := 0;
   _count             := 0;
  END_IF

PROPERTY Connected : BOOL
/// Transport is connected
GET
VAR
END_VAR
  Connected := _connected;
END_GET
END_PROPERTY

METHOD Deliver : BOOL
/// Called by the broker: queues the message if a subscription matches
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
END_VAR
VAR
  /// Subscription index
 _idx   : DINT;
  /// Subscription matches
 _match : BOOL;
  /// Queue slot
 _slot  : UDINT;
END_VAR
  FOR _idx := 1 TO _subscriptionCount
  DO
    IF ( TopicMatches(Filter := _subscriptions[_idx], Topic := Topic) )
    THEN
     _match := TRUE;
      EXIT;
    END_IF
  END_FOR

  IF ( NOT _match )
  THEN
    RETURN;
  END_IF

  IF ( _count >= M2XLibraryParameter.MESSAGE_QUEUE_MAX )
  THEN
    Overflows := Overflows + 1;
    RETURN;
  END_IF

 _slot := ( _head + _count ) MOD M2XLibraryParameter.MESSAGE_QUEUE_MAX;
 _queue[_slot].Topic := Topic;
  IF ( PayloadLength > SIZEOF(_queue[_slot].Payload) )
  THEN
   _queue[_slot].Oversized     := TRUE;
   _queue[_slot].PayloadLength := 0;
  ELSE
   _queue[_slot].Oversized     := FALSE;
   _queue[_slot].PayloadLength := PayloadLength;
    SysDepMemCpy(pDest := ADR(_queue[_slot].Payload), pSrc := pPayload, DataLen := PayloadLength);
  END_IF
 _count   := _count + 1;
  Deliver := TRUE;
END_METHOD

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
  IF (( NOT _connected ) OR ( Broker = 0 ))
  THEN
    RETURN;
  END_IF

  Publish := Broker^.Publish(Topic := Topic, pPayload := pPayload, PayloadLength := PayloadLength, RetainFlag := RetainFlag);
END_METHOD

PROPERTY QueuedMessages : UDINT
/// Number of queued messages
GET
VAR
END_VAR
  QueuedMessages := _count;
END_GET
END_PROPERTY

METHOD Receive : BOOL
/// Reads the next received message (FALSE if none)
VAR_IN_OUT
  /// Received message
  Message : MessageData;
END_VAR
  IF ( _count = 0 )
  THEN
    RETURN;
  END_IF

  Message := _queue[_head];
 _head    := ( _head + 1 ) MOD M2XLibraryParameter.MESSAGE_QUEUE_MAX;
 _count   := _count - 1;
  Receive := TRUE;
END_METHOD

METHOD SetLastWill : BOOL
/// Stores the last will
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
  IF ( PayloadLength > M2XLibraryParameter.WILL_SIZE_MAX )
  THEN
    RETURN;
  END_IF

 _willTopic  := Topic;
 _willLength := PayloadLength;
 _willRetain := RetainFlag;
 _willSet    := TRUE;
  SysDepMemCpy(pDest := ADR(_willPayload), pSrc := pPayload, DataLen := PayloadLength);
  SetLastWill := TRUE;
END_METHOD

METHOD SimulateConnectionLoss
/// Simulates an unexpected connection loss: the broker publishes the last will
VAR_INPUT
END_VAR
  IF ( NOT _connected )
  THEN
    RETURN;
  END_IF

  Broker^.Unregister(Client := THIS);
 _connected := FALSE;
 _lost      := TRUE;

  IF ( _willSet )
  THEN
    Broker^.Publish(Topic := _willTopic, pPayload := ADR(_willPayload), PayloadLength := _willLength, RetainFlag := _willRetain);
  END_IF
END_METHOD

METHOD Subscribe : BOOL
/// Subscribes to a topic filter (retained messages are delivered immediately)
VAR_INPUT
  /// Topic filter
  Topic : STRING(255);
END_VAR
VAR
  /// Subscription index
 _idx : DINT;
END_VAR
  IF (( NOT _connected ) OR ( Broker = 0 ))
  THEN
    RETURN;
  END_IF

  FOR _idx := 1 TO _subscriptionCount
  DO
    IF ( _subscriptions[_idx] = Topic )
    THEN
      Subscribe := TRUE;
      RETURN;
    END_IF
  END_FOR

  IF ( _subscriptionCount >= M2XLibraryParameter.SUBSCRIPTIONS_MAX )
  THEN
    RETURN;
  END_IF

 _subscriptionCount                 := _subscriptionCount + 1;
 _subscriptions[_subscriptionCount] := Topic;
  Broker^.DeliverRetained(Client := THIS, Filter := Topic);
  Subscribe := TRUE;
END_METHOD

END_FUNCTION_BLOCK
