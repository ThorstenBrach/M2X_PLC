/// In-memory broker for tests without MQTT (synchronous delivery, retained messages, last will)
FUNCTION_BLOCK MockBrokerFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      MockBrokerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    In-memory broker for tests without MQTT (synchronous delivery, retained messages, last will)
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
VAR
  /// Connected transports
 _clients      : ARRAY [1..M2XLibraryParameter.MOCK_CLIENTS_MAX] OF POINTER TO MockTransportFB;
  /// Retained messages
 _retained     : ARRAY [1..M2XLibraryParameter.MOCK_RETAINED_MAX] OF MessageData;
  /// Retained message slot is used
 _retainedUsed : ARRAY [1..M2XLibraryParameter.MOCK_RETAINED_MAX] OF BOOL;
  /// Number of published messages
 _published    : UDINT;
END_VAR
END_FUNCTION_BLOCK

METHOD DeliverRetained
/// Delivers the matching retained messages to a new subscription
VAR_INPUT
  /// Transport
  Client : POINTER TO MockTransportFB;
  /// Topic filter of the new subscription
  Filter : STRING(255);
END_VAR
VAR
  /// Slot index
 _idx : DINT;
END_VAR
  IF ( Client = 0 )
  THEN
    RETURN;
  END_IF

  FOR _idx := 1 TO M2XLibraryParameter.MOCK_RETAINED_MAX
  DO
    IF ( _retainedUsed[_idx] )
    THEN
      IF ( TopicMatches(Filter := Filter, Topic := _retained[_idx].Topic) )
      THEN
        Client^.Deliver(Topic         := _retained[_idx].Topic,
                        pPayload      := ADR(_retained[_idx].Payload),
                        PayloadLength := _retained[_idx].PayloadLength);
      END_IF
    END_IF
  END_FOR
END_METHOD

METHOD Publish : BOOL
/// Publishes a message to all subscribed transports
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
VAR
  /// Slot index
 _idx  : DINT;
  /// Retained slot
 _slot : DINT;
END_VAR
  IF ( PayloadLength > M2XLibraryParameter.MESSAGE_SIZE_MAX )
  THEN
    RETURN;
  END_IF

 _published := _published + 1;

  IF ( RetainFlag )
  THEN
    // same topic replaces the retained message, an empty payload deletes it
   _slot := 0;
    FOR _idx := 1 TO M2XLibraryParameter.MOCK_RETAINED_MAX
    DO
      IF (( _retainedUsed[_idx] ) AND ( _retained[_idx].Topic = Topic ))
      THEN
       _slot := _idx;
        EXIT;
      END_IF
    END_FOR
    IF ( _slot = 0 )
    THEN
      FOR _idx := 1 TO M2XLibraryParameter.MOCK_RETAINED_MAX
      DO
        IF ( NOT _retainedUsed[_idx] )
        THEN
         _slot := _idx;
          EXIT;
        END_IF
      END_FOR
    END_IF
    IF ( _slot > 0 )
    THEN
      IF ( PayloadLength = 0 )
      THEN
       _retainedUsed[_slot] := FALSE;
      ELSE
       _retainedUsed[_slot]            := TRUE;
       _retained[_slot].Topic         := Topic;
       _retained[_slot].PayloadLength := PayloadLength;
       _retained[_slot].Oversized     := FALSE;
        SysDepMemCpy(pDest := ADR(_retained[_slot].Payload), pSrc := pPayload, DataLen := PayloadLength);
      END_IF
    END_IF
  END_IF

  FOR _idx := 1 TO M2XLibraryParameter.MOCK_CLIENTS_MAX
  DO
    IF ( _clients[_idx] <> 0 )
    THEN
     _clients[_idx]^.Deliver(Topic := Topic, pPayload := pPayload, PayloadLength := PayloadLength);
    END_IF
  END_FOR

  Publish := TRUE;
END_METHOD

PROPERTY PublishedCount : UDINT
/// Number of published messages
GET
VAR
END_VAR
  PublishedCount := _published;
END_GET
END_PROPERTY

METHOD Register : BOOL
/// Connects a transport
VAR_INPUT
  /// Transport
  Client : POINTER TO MockTransportFB;
END_VAR
VAR
  /// Slot index
 _idx : DINT;
END_VAR
  FOR _idx := 1 TO M2XLibraryParameter.MOCK_CLIENTS_MAX
  DO
    IF ( _clients[_idx] = Client )
    THEN
      Register := TRUE;
      RETURN;
    END_IF
  END_FOR

  FOR _idx := 1 TO M2XLibraryParameter.MOCK_CLIENTS_MAX
  DO
    IF ( _clients[_idx] = 0 )
    THEN
     _clients[_idx]  := Client;
      Register       := TRUE;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD Reset
/// Removes all transports and retained messages
VAR_INPUT
END_VAR
VAR
  /// Slot index
 _idx : DINT;
END_VAR
  FOR _idx := 1 TO M2XLibraryParameter.MOCK_CLIENTS_MAX
  DO
   _clients[_idx] := 0;
  END_FOR
  FOR _idx := 1 TO M2XLibraryParameter.MOCK_RETAINED_MAX
  DO
   _retainedUsed[_idx] := FALSE;
  END_FOR
 _published := 0;
END_METHOD

METHOD Unregister : BOOL
/// Disconnects a transport
VAR_INPUT
  /// Transport
  Client : POINTER TO MockTransportFB;
END_VAR
VAR
  /// Slot index
 _idx : DINT;
END_VAR
  FOR _idx := 1 TO M2XLibraryParameter.MOCK_CLIENTS_MAX
  DO
    IF ( _clients[_idx] = Client )
    THEN
     _clients[_idx]  := 0;
      Unregister     := TRUE;
    END_IF
  END_FOR
END_METHOD
