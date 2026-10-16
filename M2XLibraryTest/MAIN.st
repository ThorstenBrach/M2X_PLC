PROGRAM MAIN
VAR
  /// JSON writer/parser and core functions
  JsonTests            : JsonTestFB;
  /// Mock broker and mock transport
  MockTransportTests   : MockTransportTestFB;
  /// Load handling station server against clients
  LhsTests             : LhsTestFB;
  /// Door server against clients
  DoorTests            : DoorTestFB;
  /// Signaling device server against a client
  SignalingDeviceTests : SignalingDeviceTestFB;
  /// Charging device server against a client
  ChargingDeviceTests  : ChargingDeviceTestFB;
  /// Elevator group server against clients
  ElevatorTests        : ElevatorTestFB;
  /// Transport order receiver against a sender
  TransportOrderTests  : TransportOrderTestFB;
  /// LHS over a real MQTT broker
  MqttLoopbackTests    : MqttLoopbackTestFB;
  /// Cycle counter (diagnosis)
  CycleCount           : UDINT;
  /// All suites are finished
  AllFinished          : BOOL;
END_VAR
  CycleCount := CycleCount + 1;

  // Run all TcUnit test suites
  TcUnit.RUN();

  // Diagnosis for ADS: all suites finished
  AllFinished := JsonTests.AreAllTestsFinished()            AND MockTransportTests.AreAllTestsFinished()  AND
                 LhsTests.AreAllTestsFinished()             AND DoorTests.AreAllTestsFinished()           AND
                 SignalingDeviceTests.AreAllTestsFinished() AND ChargingDeviceTests.AreAllTestsFinished() AND
                 ElevatorTests.AreAllTestsFinished()        AND TransportOrderTests.AreAllTestsFinished() AND
                 MqttLoopbackTests.AreAllTestsFinished();
END_PROGRAM
