/// Signaling device server against an MR client over the mock broker
FUNCTION_BLOCK SignalingDeviceTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      SignalingDeviceTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Signaling device server against an MR client over the mock broker
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
 _broker          : MockBrokerFB;
  /// Transport of the server
 _serverTransport : MockTransportFB;
  /// Transport of the client
 _clientTransport : MockTransportFB;
  /// Traffic light
 _server          : SignalingDeviceServerFB;
  /// MR
 _client          : SignalingDeviceClientFB;
  /// Request delivered to the application
 _request         : RequestData;
  /// Request ids
 _id              : STRING(64);
  /// Request ids
 _id2             : STRING(64);
  /// Active signal: request id
 _activeRequest   : STRING(64);
  /// Active signal: signal id
 _activeSignal    : STRING(64);
  /// Initialized
 _initDone        : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _serverTransport(Enable := TRUE, Broker := ADR(_broker));
   _clientTransport(Enable := TRUE, Broker := ADR(_broker));
   _server.SignalCount := 3;
   _server.Signals[1].SignalId := 'RED';
   _server.Signals[1].Descriptor := 'red light';
   _server.Signals[2].SignalId := 'GREEN';
   _server.Signals[2].IsRequestable := TRUE;
   _server.Signals[3].SignalId := 'YELLOW';
   _server.Signals[3].IsRequestable := TRUE;
   _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'signal_test'),
            SignalingDeviceId := 'TL1', GlobalSignalId := 'RED');
   _client(Enable := TRUE, Transport := _clientTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'signal_test'), SenderId := 'MR1');
    Cycle(Count := 3);
   _initDone := TRUE;
  END_IF

  SIG_001_RequestSignal();
  SIG_002_NotRequestable();
  SIG_003_CancelSignal();

METHOD PRIVATE Cycle
/// Calls all transports and endpoints
VAR_INPUT
  /// Number of cycles
  Count : DINT;
END_VAR
VAR
  /// Loop index
 _i : DINT;
END_VAR
  FOR _i := 1 TO Count
  DO
   _serverTransport();
   _clientTransport();
   _server();
   _client();
  END_FOR
END_METHOD

METHOD SIG_001_RequestSignal
/// Individual signal for the MR; a new signal replaces the old one
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('SIG_001_RequestSignal');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertEquals_STRING(Expected := 'RED', Actual := _client.GlobalSignalId, Message := 'global signal');
 _id := _client.RequestSignal(SignalId := 'GREEN');
  Cycle(Count := 1);
 _server.GetNextRequest(Request := _request);
 _server.SetRequestStatus(RequestId := _id, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'signal finished');
  AssertEquals_STRING(Expected := 'GREEN', Actual := _client.GetIndividualSignal(RequestId := _id), Message := 'individual signal');
  AssertTrue(Condition := _server.GetActiveSignal(Index := 1, RequestId := _activeRequest, SignalId := _activeSignal), Message := 'active signal on server');
  AssertEquals_STRING(Expected := 'GREEN', Actual := _activeSignal, Message := 'active signal id');

 _id2 := _client.RequestSignal(SignalId := 'YELLOW');
  Cycle(Count := 1);
 _server.GetNextRequest(Request := _request);
 _server.SetRequestStatus(RequestId := _id2, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  Cycle(Count := 1);
  AssertEquals_DINT(Expected := 1, Actual := _client.IndividualSignalCount, Message := 'one individual signal');
  AssertEquals_STRING(Expected := 'YELLOW', Actual := _client.GetIndividualSignal(RequestId := _id2), Message := 'replaced signal');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD SIG_002_NotRequestable
/// Signal that is not requestable is rejected
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('SIG_002_NotRequestable');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client.RequestSignal(SignalId := 'RED');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FAILED ), Message := 'failed');
  AssertTrue(Condition := _client.HasError(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, RequestId := _id), Message := 'invalid parameter');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD SIG_003_CancelSignal
/// requestCancel removes the individual signal
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('SIG_003_CancelSignal');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client.RequestCancel();
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'cancel finished');
  AssertEquals_DINT(Expected := 0, Actual := _client.IndividualSignalCount, Message := 'no individual signal');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

END_FUNCTION_BLOCK
