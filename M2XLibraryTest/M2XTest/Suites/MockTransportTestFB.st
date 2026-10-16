/// Tests of the mock broker and mock transport
FUNCTION_BLOCK MockTransportTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      MockTransportTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Tests of the mock broker and mock transport
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
  /// Broker
 _broker   : MockBrokerFB;
  /// Transport A
 _a        : MockTransportFB;
  /// Transport B
 _b        : MockTransportFB;
  /// Received message
 _message  : MessageData;
  /// Payload
 _payload  : STRING(255);
  /// Initialized
 _initDone : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _a(Enable := TRUE, Broker := ADR(_broker));
   _b(Enable := TRUE, Broker := ADR(_broker));
   _initDone := TRUE;
  END_IF

  MOCK_001_PublishSubscribe();
  MOCK_002_Wildcard();
  MOCK_003_Retained();
  MOCK_004_LastWill();
  MOCK_005_QueueOverflow();
END_FUNCTION_BLOCK

METHOD MOCK_001_PublishSubscribe
/// Message is delivered to a matching subscription only
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('MOCK_001_PublishSubscribe');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := _a.Connected AND _b.Connected, Message := 'connected');
  AssertTrue(Condition := _b.Subscribe(Topic := 't1/x'), Message := 'subscribe');
 _payload := 'hello';
  AssertTrue(Condition := _a.Publish(Topic := 't1/x', pPayload := ADR(_payload), PayloadLength := 5, RetainFlag := FALSE), Message := 'publish');
 _a.Publish(Topic := 't1/y', pPayload := ADR(_payload), PayloadLength := 5, RetainFlag := FALSE);

  AssertTrue(Condition := _b.Receive(Message := _message), Message := 'received');
  AssertEquals_STRING(Expected := 't1/x', Actual := _message.Topic, Message := 'topic');
  AssertEquals_UDINT(Expected := 5, Actual := _message.PayloadLength, Message := 'length');
  AssertFalse(Condition := _b.Receive(Message := _message), Message := 'no second message');
  AssertFalse(Condition := _a.Receive(Message := _message), Message := 'publisher without subscription');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD MOCK_002_Wildcard
/// Wildcard subscription
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('MOCK_002_Wildcard');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _b.Subscribe(Topic := 'w/+/state');
 _payload := '{}';
 _a.Publish(Topic := 'w/e1/state', pPayload := ADR(_payload), PayloadLength := 2, RetainFlag := FALSE);
 _a.Publish(Topic := 'w/e1/request', pPayload := ADR(_payload), PayloadLength := 2, RetainFlag := FALSE);
  AssertTrue(Condition := _b.Receive(Message := _message), Message := 'state received');
  AssertEquals_STRING(Expected := 'w/e1/state', Actual := _message.Topic, Message := 'topic');
  AssertFalse(Condition := _b.Receive(Message := _message), Message := 'request not received');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD MOCK_003_Retained
/// Retained message is delivered on subscribe
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('MOCK_003_Retained');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _payload := 'r1';
 _a.Publish(Topic := 'r/state', pPayload := ADR(_payload), PayloadLength := 2, RetainFlag := TRUE);
 _payload := 'r2';
 _a.Publish(Topic := 'r/state', pPayload := ADR(_payload), PayloadLength := 2, RetainFlag := TRUE);
 _b.Subscribe(Topic := 'r/state');
  AssertTrue(Condition := _b.Receive(Message := _message), Message := 'retained received');
  AssertEquals_BYTE(Expected := 50, Actual := _message.Payload[1], Message := 'latest retained message');
  AssertFalse(Condition := _b.Receive(Message := _message), Message := 'only one retained message');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD MOCK_004_LastWill
/// Last will is published on connection loss
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('MOCK_004_LastWill');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _b.Subscribe(Topic := 'will/a');
 _payload := 'gone';
 _a.SetLastWill(Topic := 'will/a', pPayload := ADR(_payload), PayloadLength := 4, RetainFlag := FALSE);
 _a.SimulateConnectionLoss();
  AssertFalse(Condition := _a.Connected, Message := 'disconnected');
  AssertTrue(Condition := _b.Receive(Message := _message), Message := 'will received');
  AssertEquals_STRING(Expected := 'will/a', Actual := _message.Topic, Message := 'will topic');

  // reconnect only after Enable = FALSE
 _a(Enable := TRUE);
  AssertFalse(Condition := _a.Connected, Message := 'no automatic reconnect');
 _a(Enable := FALSE);
 _a(Enable := TRUE);
  AssertTrue(Condition := _a.Connected, Message := 'reconnected');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD MOCK_005_QueueOverflow
/// Full queue counts overflows
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
VAR
  /// Loop index
 _i : UDINT;
END_VAR
  TEST('MOCK_005_QueueOverflow');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _b.Subscribe(Topic := 'q');
 _payload := 'x';
  FOR _i := 1 TO M2XLibraryParameter.MESSAGE_QUEUE_MAX + 2
  DO
   _a.Publish(Topic := 'q', pPayload := ADR(_payload), PayloadLength := 1, RetainFlag := FALSE);
  END_FOR
  AssertEquals_UDINT(Expected := M2XLibraryParameter.MESSAGE_QUEUE_MAX, Actual := _b.QueuedMessages, Message := 'queue full');
  AssertEquals_UDINT(Expected := 2, Actual := _b.Overflows, Message := 'overflows');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD
