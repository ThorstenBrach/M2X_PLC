/// Door server against two MR clients over the mock broker
FUNCTION_BLOCK DoorTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      DoorTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Door server against two MR clients over the mock broker
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
  /// Door
 _server           : DoorServerFB;
  /// MR 1
 _client1          : DoorClientFB;
  /// MR 2
 _client2          : DoorClientFB;
  /// Request delivered to the application
 _request          : RequestData;
  /// Request ids
 _id               : STRING(64);
  /// Request ids
 _id2              : STRING(64);
  /// Initialized
 _initDone         : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _serverTransport(Enable := TRUE, Broker := ADR(_broker));
   _clientTransport1(Enable := TRUE, Broker := ADR(_broker));
   _clientTransport2(Enable := TRUE, Broker := ADR(_broker));
   _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'door_test'), DoorId := 'D1');
   _client1(Enable := TRUE, Transport := _clientTransport1, Config := MakeConfig(InterfaceName := '', EntityName := 'door_test'), SenderId := 'MR1');
   _client2(Enable := TRUE, Transport := _clientTransport2, Config := MakeConfig(InterfaceName := '', EntityName := 'door_test'), SenderId := 'MR2');
    Cycle(Count := 3);
   _initDone := TRUE;
  END_IF

  DOOR_001_TransitAndRelease();
  DOOR_002_ReleaseWithoutTransit();
  DOOR_003_WrongDoorId();

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

METHOD DOOR_001_TransitAndRelease
/// Two MR transit at the same time; the door stays open until both released
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('DOOR_001_TransitAndRelease');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := ( _client1.DoorStatus = DoorStatusEnum.CLOSED ), Message := 'door closed');
 _id  := _client1.RequestDoor(RequestType := RequestTypeEnum.REQUEST_TRANSIT, TargetDoorId := 'D1');
 _id2 := _client2.RequestDoor(RequestType := RequestTypeEnum.REQUEST_TRANSIT, TargetDoorId := 'D1');
  Cycle(Count := 1);

  // application opens the door and finishes both transits
 _server.DoorStatus := DoorStatusEnum.OPEN;
  WHILE ( _server.GetNextRequest(Request := _request) > 0 ) DO
   _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  END_WHILE
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'transit MR1 finished');
  AssertTrue(Condition := ( _client2.GetRequestStatus(RequestId := _id2) = RequestStatusEnum.FINISHED ), Message := 'transit MR2 finished');
  AssertTrue(Condition := ( _client1.DoorStatus = DoorStatusEnum.OPEN ), Message := 'door open in state');
  AssertEquals_DINT(Expected := 2, Actual := _server.OpenTransitCount, Message := 'two open transits');

 _id := _client1.RequestDoor(RequestType := RequestTypeEnum.REQUEST_RELEASE, TargetDoorId := 'D1');
  Cycle(Count := 1);
 _server.GetNextRequest(Request := _request);
 _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'release MR1 finished');
  AssertEquals_DINT(Expected := 1, Actual := _server.OpenTransitCount, Message := 'one open transit');

 _id2 := _client2.RequestDoor(RequestType := RequestTypeEnum.REQUEST_RELEASE, TargetDoorId := 'D1');
  Cycle(Count := 1);
 _server.GetNextRequest(Request := _request);
 _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
 _server.DoorStatus := DoorStatusEnum.CLOSED;
  Cycle(Count := 1);
  AssertEquals_DINT(Expected := 0, Actual := _server.OpenTransitCount, Message := 'no open transit');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD DOOR_002_ReleaseWithoutTransit
/// requestRelease without transit is a sequence error
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('DOOR_002_ReleaseWithoutTransit');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client1.RequestDoor(RequestType := RequestTypeEnum.REQUEST_RELEASE, TargetDoorId := 'D1');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FAILED ), Message := 'release failed');
  AssertTrue(Condition := _client1.HasError(ErrorType := M2XLibraryConstants.ERR_REQUEST_SEQUENCE, RequestId := _id), Message := 'sequence error');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD DOOR_003_WrongDoorId
/// Wrong door id is an invalid parameter
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('DOOR_003_WrongDoorId');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client2.RequestDoor(RequestType := RequestTypeEnum.REQUEST_TRANSIT, TargetDoorId := 'D99');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client2.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FAILED ), Message := 'transit failed');
  AssertTrue(Condition := _client2.HasError(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, RequestId := _id), Message := 'invalid parameter');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

END_FUNCTION_BLOCK
