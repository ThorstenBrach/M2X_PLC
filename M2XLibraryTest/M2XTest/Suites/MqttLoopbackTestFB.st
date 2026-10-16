/// LHS server and client over a real MQTT broker (Mosquitto, TF6701)
FUNCTION_BLOCK MqttLoopbackTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      MqttLoopbackTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    LHS server and client over a real MQTT broker (Mosquitto, TF6701)
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
  /// MQTT transport of the server
 _serverTransport : MqttTransportFB;
  /// MQTT transport of the client
 _clientTransport : MqttTransportFB;
  /// Station
 _server          : LhsServerFB;
  /// MR
 _client          : LhsClientFB;
  /// Request delivered to the application
 _request         : RequestData;
  /// Request id
 _id              : STRING(64);
  /// Step of the test
 _step            : INT;
  /// Timeout of the test
 _timeout         : TON;
  /// Initialized
 _initDone        : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _serverTransport.Config.HostName := M2XTestParameter.MQTT_HOST;
   _serverTransport.Config.Port     := M2XTestParameter.MQTT_PORT;
   _serverTransport.Config.ClientId := 'm2x_test_server';
   _clientTransport.Config.HostName := M2XTestParameter.MQTT_HOST;
   _clientTransport.Config.Port     := M2XTestParameter.MQTT_PORT;
   _clientTransport.Config.ClientId := 'm2x_test_client';
   _server.Points[1].LoadHandlingPointId := 'LHP1';
   _server.Config := MakeConfig(InterfaceName := '', EntityName := 'lhs_mqtt_test');
   _client.Config := MakeConfig(InterfaceName := '', EntityName := 'lhs_mqtt_test');
   _client.SenderId := 'MR_MQTT';
   _initDone := TRUE;
  END_IF

  MQTT_001_LhsLoopback();
END_FUNCTION_BLOCK

METHOD MQTT_001_LhsLoopback
/// requestAccess and requestRelease over Mosquitto
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('MQTT_001_LhsLoopback');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  IF ( NOT M2XTestParameter.MQTT_TEST_ENABLED )
  THEN
    TEST_FINISHED();
   _finished := TRUE;
    RETURN;
  END_IF

  // server before its transport: the last will is set before the connect
 _server(Enable := TRUE, Transport := _serverTransport);
 _client(Enable := TRUE, Transport := _clientTransport);
 _serverTransport(Enable := TRUE);
 _clientTransport(Enable := TRUE);
 _timeout(IN := TRUE, PT := M2XTestParameter.MQTT_TIMEOUT);

  CASE _step OF
    0:
      // wait for the state of the station
      IF (( _client.StateReceived ) AND ( _client.RemoteConnectionState = ConnectionStateEnum.ONLINE ))
      THEN
       _id   := _client.RequestAccess(LoadHandlingSessionId    := 'MQTT-S1',
                                       LoadHandlingPointId      := 'LHP1',
                                       VehicleType              := 'AMR',
                                       LoadAction               := LoadActionEnum.PICK,
                                       ActiveLoadTransferDevice := LoadTransferDeviceEnum.MR);
       _step := 10;
      END_IF

    10:
      IF ( _server.GetNextRequest(Request := _request) > 0 )
      THEN
       _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := 'mqtt');
       _step := 20;
      END_IF

    20:
      IF ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED )
      THEN
        AssertEquals_STRING(Expected := 'mqtt', Actual := _client.GetResultDescription(RequestId := _id), Message := 'result over MQTT');
       _id   := _client.RequestSessionStep(RequestType := RequestTypeEnum.REQUEST_RELEASE, LoadHandlingSessionId := 'MQTT-S1', LoadHandlingPointId := 'LHP1');
       _step := 30;
      END_IF

    30:
      IF ( _server.GetNextRequest(Request := _request) > 0 )
      THEN
       _server.SetRequestStatus(RequestId := _request.RequestId, Status := RequestStatusEnum.FINISHED, ResultDescription := '');
       _step := 40;
      END_IF

    40:
      IF ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED )
      THEN
        AssertTrue(Condition := ( _server.GetPhase(PointIndex := 1) = LhsPhaseEnum.IDLE ), Message := 'station idle');
       _step := 50;
        TEST_FINISHED();
       _finished := TRUE;
      END_IF
  ELSE
    ;
  END_CASE

  IF (( _timeout.Q ) AND ( _step < 50 ))
  THEN
    AssertTrue(Condition := FALSE, Message := CONCAT(CONCAT('timeout in step ', INT_TO_STRING(_step)), CONCAT(' mqtt error ', UDINT_TO_STRING(_clientTransport.ErrorId))));
   _step := 99;
    TEST_FINISHED();
   _finished := TRUE;
  END_IF
END_METHOD
