/// Charging device server against an MR client over the mock broker
FUNCTION_BLOCK ChargingDeviceTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      ChargingDeviceTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Charging device server against an MR client over the mock broker
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
  /// Charger
 _server          : ChargingDeviceServerFB;
  /// MR
 _client          : ChargingDeviceClientFB;
  /// Request delivered to the application
 _request         : RequestData;
  /// Request id
 _id              : STRING(64);
  /// Initialized
 _initDone        : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _serverTransport(Enable := TRUE, Broker := ADR(_broker));
   _clientTransport(Enable := TRUE, Broker := ADR(_broker));
   _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'charger_test'), ChargingDeviceId := 'C1');
   _client(Enable := TRUE, Transport := _clientTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'charger_test'), SenderId := 'MR1');
    Cycle(Count := 3);
   _initDone := TRUE;
  END_IF

  CHG_001_ChargingSequence();
  CHG_002_StopWithoutStart();
END_FUNCTION_BLOCK

METHOD CHG_001_ChargingSequence
/// access -> startCharge -> stopCharge -> release
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('CHG_001_ChargingSequence');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := ( Step(RequestType := RequestTypeEnum.REQUEST_ACCESS) = RequestStatusEnum.FINISHED ), Message := 'access');
  AssertTrue(Condition := ( _server.Phase = SessionPhaseEnum.GRANTED ), Message := 'phase granted');
 _server.ChargingProcess.Charging     := ChargingProcessEnum.CHARGING;
 _server.ChargingProcess.ChargingRate := 42.5;
  AssertTrue(Condition := ( Step(RequestType := RequestTypeEnum.REQUEST_START_CHARGE) = RequestStatusEnum.FINISHED ), Message := 'start charge');
  AssertTrue(Condition := ( _server.Phase = SessionPhaseEnum.ACTIVE ), Message := 'phase active');
  AssertEquals_STRING(Expected := 'CS1', Actual := _client.CurrentChargingSessionId, Message := 'session in state');
  AssertTrue(Condition := ( _client.ChargingProcess.Charging = ChargingProcessEnum.CHARGING ), Message := 'charging process');
  AssertEquals_LREAL(Expected := 42.5, Actual := _client.ChargingProcess.ChargingRate, Delta := 0.001, Message := 'charging rate');
 _server.ChargingProcess.Charging := ChargingProcessEnum.DONE;
  AssertTrue(Condition := ( Step(RequestType := RequestTypeEnum.REQUEST_STOP_CHARGE) = RequestStatusEnum.FINISHED ), Message := 'stop charge');
  AssertTrue(Condition := ( Step(RequestType := RequestTypeEnum.REQUEST_RELEASE) = RequestStatusEnum.FINISHED ), Message := 'release');
  AssertTrue(Condition := ( _server.Phase = SessionPhaseEnum.IDLE ), Message := 'phase idle');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD CHG_002_StopWithoutStart
/// requestStopCharge without session is a sequence error
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('CHG_002_StopWithoutStart');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := ( Step(RequestType := RequestTypeEnum.REQUEST_STOP_CHARGE) = RequestStatusEnum.FAILED ), Message := 'stop failed');
  AssertTrue(Condition := _client.HasError(ErrorType := M2XLibraryConstants.ERR_REQUEST_SEQUENCE, RequestId := _id), Message := 'sequence error');
  TEST_FINISHED();
 _finished := TRUE;
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
   _clientTransport();
   _server();
   _client();
  END_FOR
END_METHOD

METHOD PRIVATE Step : RequestStatusEnum
/// Sends a request of the session and lets the application finish it
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
 _id := _client.RequestCharging(RequestType := RequestType, ChargingSessionId := 'CS1');
  Cycle(Count := 1);
  IF ( _server.GetNextRequest(Request := _request) > 0 )
  THEN
   _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
  END_IF
  Cycle(Count := 1);
  Step := _client.GetRequestStatus(RequestId := _id);
END_METHOD
