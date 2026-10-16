/// Elevator group server (2 elevators) against two MR clients over the mock broker
FUNCTION_BLOCK ElevatorTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      ElevatorTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Elevator group server (2 elevators) against two MR clients over the mock broker
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
  /// Elevator group
 _server           : ElevatorServerFB;
  /// MR 1
 _client1          : ElevatorClientFB;
  /// MR 2
 _client2          : ElevatorClientFB;
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
   _server.ElevatorCount                       := 2;
   _server.Elevators[1].ElevatorId             := 'E1';
   _server.Elevators[2].ElevatorId             := 'E2';
   _server.ElevatorInputs[1].CurrentFloorName  := '0';
   _server.ElevatorInputs[2].CurrentFloorName  := '1';
   _server.ElevatorInputs[2].CurrentFloorLevel := 4.5;
   _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'elevator_test'), GroupId := 'G1');
   _client1(Enable := TRUE, Transport := _clientTransport1, Config := MakeConfig(InterfaceName := '', EntityName := 'elevator_test'), SenderId := 'MR1');
   _client2(Enable := TRUE, Transport := _clientTransport2, Config := MakeConfig(InterfaceName := '', EntityName := 'elevator_test'), SenderId := 'MR2');
    Cycle(Count := 3);
   _initDone := TRUE;
  END_IF

  ELV_001_GroupState();
  ELV_002_TwoMrTwoElevators();
  ELV_003_ChangeFloorWithoutTarget();
END_FUNCTION_BLOCK

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

METHOD ELV_001_GroupState
/// State of the group with two elevators
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('ELV_001_GroupState');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertEquals_STRING(Expected := 'G1', Actual := _client1.GroupId, Message := 'group id');
  AssertEquals_DINT(Expected := 2, Actual := _client1.ElevatorCount, Message := 'elevator count');
  AssertEquals_STRING(Expected := 'E2', Actual := _client1.Elevators[2].ElevatorId, Message := 'elevator 2');
  AssertEquals_LREAL(Expected := 4.5, Actual := _client1.Elevators[2].CurrentFloorLevel, Delta := 0.001, Message := 'floor level');
  AssertTrue(Condition := ( _client1.RemoteConnectionState = ConnectionStateEnum.ONLINE ), Message := 'online');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD ELV_002_TwoMrTwoElevators
/// Two MR get two different elevators and ride
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('ELV_002_TwoMrTwoElevators');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client1.RequestElevator(ElevatorSessionId := 'ES1', RequestedFloor := '0', IntendedTargetFloor := '1', VehicleType := 'AMR');
  Cycle(Count := 1);
  FinishAll();
 _id2 := _client2.RequestElevator(ElevatorSessionId := 'ES2', RequestedFloor := '1', IntendedTargetFloor := '0', VehicleType := 'AMR');
  Cycle(Count := 1);
  FinishAll();
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'MR1 elevator assigned');
  AssertEquals_STRING(Expected := 'E1', Actual := _client1.GetAssignedElevator(RequestId := _id), Message := 'MR1 gets E1');
  AssertEquals_STRING(Expected := 'E2', Actual := _client2.GetAssignedElevator(RequestId := _id2), Message := 'MR2 gets E2');

 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_ACCESS, ElevatorSessionId := 'ES1', TargetFloor := '');
  Cycle(Count := 1);
  FinishAll();
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = SessionPhaseEnum.ACTIVE ), Message := 'MR1 inside');
 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_CHANGE_FLOOR, ElevatorSessionId := 'ES1', TargetFloor := '1');
  Cycle(Count := 1);
  AssertEquals_DINT(Expected := 1, Actual := _server.GetNextRequest(Request := _request), Message := 'change floor for E1');
  AssertEquals_STRING(Expected := '1', Actual := _request.Parameters.TargetFloor, Message := 'target floor');
 _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  Cycle(Count := 1);
 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_EXIT, ElevatorSessionId := 'ES1', TargetFloor := '');
  Cycle(Count := 1);
  FinishAll();
 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, ElevatorSessionId := 'ES1', TargetFloor := '');
  Cycle(Count := 1);
  FinishAll();
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'MR1 released');
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = SessionPhaseEnum.IDLE ), Message := 'E1 idle');

 _id2 := _client2.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, ElevatorSessionId := 'ES2', TargetFloor := '');
  Cycle(Count := 1);
  FinishAll();
  AssertTrue(Condition := ( _server.GetPhase(PointIndex := 2) = SessionPhaseEnum.IDLE ), Message := 'E2 idle');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD ELV_003_ChangeFloorWithoutTarget
/// requestChangeFloor without target floor is an invalid parameter
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('ELV_003_ChangeFloorWithoutTarget');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client1.RequestElevator(ElevatorSessionId := 'ES3', RequestedFloor := '0', IntendedTargetFloor := '1', VehicleType := 'AMR');
  Cycle(Count := 1);
  FinishAll();
 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_ACCESS, ElevatorSessionId := 'ES3', TargetFloor := '');
  Cycle(Count := 1);
  FinishAll();
 _id := _client1.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_CHANGE_FLOOR, ElevatorSessionId := 'ES3', TargetFloor := '');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client1.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FAILED ), Message := 'change floor failed');
  AssertTrue(Condition := _client1.HasError(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, RequestId := _id), Message := 'invalid parameter');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD PRIVATE FinishAll
/// Application finishes all deliverable requests
VAR_INPUT
END_VAR
VAR
  /// Guard
 _i : DINT;
END_VAR
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF ( _server.GetNextRequest(Request := _request) = 0 )
    THEN
      EXIT;
    END_IF
   _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  END_FOR
  Cycle(Count := 1);
END_METHOD
