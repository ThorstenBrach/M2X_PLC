/// Load handling station server against two MR clients over the mock broker
FUNCTION_BLOCK LhsTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      LhsTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Load handling station server against two MR clients over the mock broker
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
 _broker           : MockBrokerFB;
  /// Transport of the server
 _serverTransport  : MockTransportFB;
  /// Transport of client 1
 _clientTransport1 : MockTransportFB;
  /// Transport of client 2
 _clientTransport2 : MockTransportFB;
  /// Station
 _server           : LhsServerFB;
  /// MR 1
 _client1          : LhsClientFB;
  /// MR 2
 _client2          : LhsClientFB;
  /// Request delivered to the application
 _request          : RequestData;
  /// Request block
 _requestFB        : RequestFB;
  /// Empty parameters
 _noParams         : RequestParameterData;
  /// Request ids
 _id               : STRING(64);
  /// Request ids
 _id2              : STRING(64);
  /// Initialized
 _initDone         : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
    Init();
  END_IF

  LHS_001_Connect();
  LHS_002_FullSequence();
  LHS_003_SequenceError();
  LHS_004_SecondMrWaits();
  LHS_005_OneActivePerSender();
  LHS_006_UnsupportedRequest();
  LHS_007_RequestFB();
  LHS_008_ContinueAfterFailure();
  LHS_009_ConnectionLoss();

METHOD PRIVATE AssertStatus
/// Asserts the status of a request seen by a client
VAR_IN_OUT
  /// Client
  Client : ClientBaseFB;
END_VAR
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
  /// Expected status
  Expected  : RequestStatusEnum;
  /// Message
  Message   : STRING(255);
END_VAR
  AssertEquals_STRING(Expected := RequestStatusToString(Expected),
                      Actual   := RequestStatusToString(Client.GetRequestStatus(RequestId := RequestId)),
                      Message  := Message);
END_METHOD

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
   _clientTransport1();
   _clientTransport2();
   _server();
   _client1();
   _client2();
  END_FOR
END_METHOD

METHOD PRIVATE FinishNext : DINT
/// Application: finishes the next delivered request; returns its point (0 = none)
VAR_INPUT
  /// Status set by the application
  Status : RequestStatusEnum;
END_VAR
  FinishNext := _server.GetNextRequest(Request := _request);
  IF ( FinishNext > 0 )
  THEN
   _server.SetRequestStatus(RequestId := _request.RequestId, Status := Status, ResultDescription := '');
  END_IF
  Cycle(Count := 1);
END_METHOD

METHOD PRIVATE Init
/// Configures and connects all endpoints
VAR_INPUT
END_VAR
 _serverTransport(Enable := TRUE, Broker := ADR(_broker));
 _clientTransport1(Enable := TRUE, Broker := ADR(_broker));
 _clientTransport2(Enable := TRUE, Broker := ADR(_broker));

 _server.PointCount                    := 2;
 _server.Points[1].LoadHandlingPointId := 'LHP1';
 _server.Points[2].LoadHandlingPointId := 'LHP2';
 _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'lhs_test'));
 _client1(Enable := TRUE, Transport := _clientTransport1, Config := MakeConfig(InterfaceName := '', EntityName := 'lhs_test'), SenderId := 'MR1');
 _client2(Enable := TRUE, Transport := _clientTransport2, Config := MakeConfig(InterfaceName := '', EntityName := 'lhs_test'), SenderId := 'MR2');

  Cycle(Count := 3);
 _initDone := TRUE;
END_METHOD

METHOD LHS_001_Connect
/// Clients receive state and factsheet
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_001_Connect');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := _server.Connected, Message := 'server connected');
  AssertTrue(Condition := _client1.StateReceived, Message := 'state received');
  AssertTrue(Condition := _client1.FactsheetReceived, Message := 'factsheet received');
  AssertTrue(Condition := ( _client1.RemoteConnectionState = ConnectionStateEnum.ONLINE ), Message := 'ONLINE');
  AssertEquals_DINT(Expected := 2, Actual := _client1.PointCount, Message := 'two points');
  AssertEquals_STRING(Expected := 'LHP2', Actual := _client1.Points[2].LoadHandlingPointId, Message := 'point id');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_002_FullSequence
/// requestAccess -> requestLoadTransfer -> requestExit -> requestRelease
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_002_FullSequence');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client1.RequestAccess(LoadHandlingSessionId    := 'S1',
                                LoadHandlingPointId      := 'LHP1',
                                VehicleType              := 'AMR',
                                LoadAction               := LoadActionEnum.PICK,
                                ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
  AssertTrue(Condition := ( _id <> '' ), Message := 'access sent');
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.PENDING, Message := 'access pending');

  AssertEquals_DINT(Expected := 1, Actual := _server.GetNextRequest(Request := _request), Message := 'delivered for point 1');
  AssertEquals_STRING(Expected := _id, Actual := _request.RequestId, Message := 'request id');
  AssertEquals_STRING(Expected := 'MR1', Actual := _request.SenderId, Message := 'sender id');
  AssertTrue(Condition := ( _request.Parameters.LoadAction = LoadActionEnum.PICK ), Message := 'load action');
 _server.SetRequestStatus(RequestId := _id, Status := RequestStatusEnum.RUNNING, ResultDescription := '');
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.RUNNING, Message := 'access running');
 _server.SetRequestStatus(RequestId := _id, Status := RequestStatusEnum.FINISHED, ResultDescription := 'gate open');
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'access finished');
  AssertEquals_STRING(Expected := 'gate open', Actual := _client1.GetResultDescription(RequestId := _id), Message := 'result description');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = LhsPhaseEnum.ACCESS_GRANTED ), Message := 'phase access granted');
  AssertEquals_STRING(Expected := 'S1', Actual := _client1.Points[1].LoadHandlingSessionId, Message := 'session in state');

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_LOAD_TRANSFER, LoadHandlingSessionId := 'S1', LoadHandlingPointId := '');
  Cycle(Count := 1);
  AssertEquals_DINT(Expected := 1, Actual := FinishNext(Status := RequestStatusEnum.FINISHED), Message := 'load transfer delivered');
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'load transfer finished');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = LhsPhaseEnum.LOAD_TRANSFERRED ), Message := 'phase transferred');

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_EXIT, LoadHandlingSessionId := 'S1', LoadHandlingPointId := '');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'exit finished');

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, LoadHandlingSessionId := 'S1', LoadHandlingPointId := '');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'release finished');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = LhsPhaseEnum.IDLE ), Message := 'phase idle');
  AssertEquals_STRING(Expected := '', Actual := _client1.Points[1].LoadHandlingSessionId, Message := 'no session in state');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_003_SequenceError
/// requestLoadTransfer without access is rejected
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_003_SequenceError');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_LOAD_TRANSFER, LoadHandlingSessionId := 'S9', LoadHandlingPointId := 'LHP1');
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FAILED, Message := 'load transfer failed');
  AssertTrue(Condition := _client1.HasError(ErrorType := M2XLibraryConstants.ERR_REQUEST_SEQUENCE, RequestId := _id), Message := 'sequence error reported');
  AssertEquals_DINT(Expected := 0, Actual := _server.GetNextRequest(Request := _request), Message := 'nothing delivered');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_004_SecondMrWaits
/// Second MR waits (PENDING) until the first one released the point
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_004_SecondMrWaits');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id  := _client1.RequestAccess(LoadHandlingSessionId := 'S2', LoadHandlingPointId := 'LHP1', VehicleType := 'AMR', LoadAction := LoadActionEnum.DROP, ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
 _id2 := _client2.RequestAccess(LoadHandlingSessionId := 'S3', LoadHandlingPointId := 'LHP1', VehicleType := 'AMR', LoadAction := LoadActionEnum.PICK, ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
  Cycle(Count := 1);
  AssertStatus(Client := _client2, RequestId := _id2, Expected := RequestStatusEnum.PENDING, Message := 'MR2 pending');

  AssertEquals_DINT(Expected := 1, Actual := FinishNext(Status := RequestStatusEnum.FINISHED), Message := 'MR1 access delivered');
  AssertEquals_STRING(Expected := _id, Actual := _request.RequestId, Message := 'MR1 first');
  AssertEquals_DINT(Expected := 0, Actual := _server.GetNextRequest(Request := _request), Message := 'MR2 not delivered while LHP1 busy');
  AssertStatus(Client := _client2, RequestId := _id2, Expected := RequestStatusEnum.PENDING, Message := 'MR2 still pending');

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, LoadHandlingSessionId := 'S2', LoadHandlingPointId := '');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertStatus(Client := _client1, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'MR1 released');

  AssertEquals_DINT(Expected := 1, Actual := FinishNext(Status := RequestStatusEnum.FINISHED), Message := 'MR2 access delivered');
  AssertEquals_STRING(Expected := _id2, Actual := _request.RequestId, Message := 'MR2 now');
  AssertStatus(Client := _client2, RequestId := _id2, Expected := RequestStatusEnum.FINISHED, Message := 'MR2 access finished');

 _id2 := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, LoadHandlingSessionId := 'S3', LoadHandlingPointId := '');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = LhsPhaseEnum.IDLE ), Message := 'LHP1 free again');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_005_OneActivePerSender
/// A sender cannot have two active requests; requestCancel cancels the active one
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_005_OneActivePerSender');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id  := _client1.RequestAccess(LoadHandlingSessionId := 'S4', LoadHandlingPointId := 'LHP2', VehicleType := 'AMR', LoadAction := LoadActionEnum.PICK, ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
 _id2 := _client1.RequestAccess(LoadHandlingSessionId := 'S5', LoadHandlingPointId := 'LHP1', VehicleType := 'AMR', LoadAction := LoadActionEnum.PICK, ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id,  Expected := RequestStatusEnum.PENDING, Message := 'first pending');
  AssertStatus(Client := _client1, RequestId := _id2, Expected := RequestStatusEnum.FAILED,  Message := 'second failed');
  AssertTrue(Condition := _client1.HasError(ErrorType := M2XLibraryConstants.ERR_REQUEST_ALREADY_ACTIVE, RequestId := _id2), Message := 'already active error');

 _id2 := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_CANCEL, LoadHandlingSessionId := 'S4', LoadHandlingPointId := '');
  Cycle(Count := 1);
  AssertStatus(Client := _client1, RequestId := _id2, Expected := RequestStatusEnum.FINISHED, Message := 'cancel finished');
  AssertStatus(Client := _client1, RequestId := _id,  Expected := RequestStatusEnum.FAILED,   Message := 'canceled access failed');
  AssertEquals_DINT(Expected := 0, Actual := _server.GetNextRequest(Request := _request), Message := 'canceled request not delivered');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_006_UnsupportedRequest
/// Request types of other interfaces are rejected
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_006_UnsupportedRequest');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client2.SendRequest(RequestType := RequestTypeEnum.REQUEST_TRANSIT, Description := 'wrong interface', Parameters := _noParams);
  Cycle(Count := 1);
  AssertStatus(Client := _client2, RequestId := _id, Expected := RequestStatusEnum.FAILED, Message := 'transit failed');
  AssertTrue(Condition := _client2.HasError(ErrorType := M2XLibraryConstants.ERR_REQUEST_NOT_SUPPORTED, RequestId := _id), Message := 'not supported error');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_007_RequestFB
/// RequestFB with requestFactsheet
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_007_RequestFB');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _requestFB(Execute := TRUE, RequestType := RequestTypeEnum.REQUEST_FACTSHEET, Client := _client2, Parameters := _noParams);
  AssertTrue(Condition := _requestFB.Busy, Message := 'busy');
  Cycle(Count := 1);
 _requestFB(Execute := TRUE, Client := _client2, Parameters := _noParams);
  AssertTrue(Condition := _requestFB.Done, Message := 'done');
  AssertFalse(Condition := _requestFB.Error, Message := 'no error');
 _requestFB(Execute := FALSE, Client := _client2, Parameters := _noParams);
  AssertFalse(Condition := _requestFB.Done, Message := 'reset with Execute FALSE');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_008_ContinueAfterFailure
/// Failed load transfer, requestContinueLoadTransfer, then normal end
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_008_ContinueAfterFailure');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client2.RequestAccess(LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2', VehicleType := 'AMR', LoadAction := LoadActionEnum.DROP, ActiveLoadTransferDevice := LoadTransferDeviceEnum.LHS);
  Cycle(Count := 1);
  AssertEquals_DINT(Expected := 2, Actual := FinishNext(Status := RequestStatusEnum.FINISHED), Message := 'access on LHP2');

 _id := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_LOAD_TRANSFER, LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FAILED);
  AssertStatus(Client := _client2, RequestId := _id, Expected := RequestStatusEnum.FAILED, Message := 'transfer failed');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 2) = LhsPhaseEnum.FAILED ), Message := 'phase failed');

 _id := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER, LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertStatus(Client := _client2, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'continue finished');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 2) = LhsPhaseEnum.ACCESS_GRANTED ), Message := 'phase access granted');

 _id := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_LOAD_TRANSFER, LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
 _id := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_EXIT, LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
 _id := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, LoadHandlingSessionId := 'S6', LoadHandlingPointId := 'LHP2');
  Cycle(Count := 1);
  FinishNext(Status := RequestStatusEnum.FINISHED);
  AssertStatus(Client := _client2, RequestId := _id, Expected := RequestStatusEnum.FINISHED, Message := 'release finished');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 2) = LhsPhaseEnum.IDLE ), Message := 'LHP2 idle');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD LHS_009_ConnectionLoss
/// Connection loss: last will CONNECTION_BROKEN, after reconnect ONLINE
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('LHS_009_ConnectionLoss');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _serverTransport.SimulateConnectionLoss();
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client1.RemoteConnectionState = ConnectionStateEnum.CONNECTION_BROKEN ), Message := 'CONNECTION_BROKEN from last will');
  AssertFalse(Condition := _server.Connected, Message := 'server disconnected');

 _serverTransport(Enable := FALSE);
 _serverTransport(Enable := TRUE);
  Cycle(Count := 2);
  AssertTrue(Condition := _server.Connected, Message := 'server reconnected');
  AssertTrue(Condition := ( _client1.RemoteConnectionState = ConnectionStateEnum.ONLINE ), Message := 'ONLINE again');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

END_FUNCTION_BLOCK
