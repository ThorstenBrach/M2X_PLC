/// Transport order receiver against an order sender over the mock broker
FUNCTION_BLOCK TransportOrderTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      TransportOrderTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Transport order receiver against an order sender over the mock broker
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
  /// FM / MR with local FM
 _server          : TransportOrderServerFB;
  /// Upper layer system
 _client          : TransportOrderClientFB;
  /// Order to send
 _order           : TransportOrderData;
  /// Order received by the application
 _received        : TransportOrderData;
  /// Request delivered to the application
 _request         : RequestData;
  /// Request id of the order
 _orderId         : STRING(64);
  /// Request id
 _id              : STRING(64);
  /// Initialized
 _initDone        : BOOL;
END_VAR
  IF ( NOT _initDone )
  THEN
   _serverTransport(Enable := TRUE, Broker := ADR(_broker));
   _clientTransport(Enable := TRUE, Broker := ADR(_broker));
   _server(Enable := TRUE, Transport := _serverTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'fm_test'));
   _client(Enable := TRUE, Transport := _clientTransport, Config := MakeConfig(InterfaceName := '', EntityName := 'fm_test'), SenderId := 'WMS');
    Cycle(Count := 3);
   _initDone := TRUE;
  END_IF

  TO_001_NewOrder();
  TO_002_UpdateOrder();
  TO_003_StaleUpdate();
  TO_004_CancelOrder();
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
   _clientTransport();
   _server();
   _client();
  END_FOR
END_METHOD

METHOD TO_001_NewOrder
/// New order with two objectives; first objective reached
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('TO_001_NewOrder');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _order.TransportOrderId       := 'TO-1';
 _order.TransportOrderUpdateId := 0;
 _order.Priority               := PriorityEnum.HIGH;
 _order.ObjectiveCount         := 2;
 _order.Objectives[1].ObjectiveId     := 'O1';
 _order.Objectives[1].SequenceId      := 0;
 _order.Objectives[1].Destination     := 'LHS1';
 _order.Objectives[1].ObjectiveAction := ObjectiveActionEnum.PICK;
 _order.Objectives[1].LoadHandlingUnitValid                 := TRUE;
 _order.Objectives[1].LoadHandlingUnit.LoadHandlingUnitType := 'euro_pallet';
 _order.Objectives[2].ObjectiveId     := 'O2';
 _order.Objectives[2].SequenceId      := 1;
 _order.Objectives[2].Destination     := 'STORE5';
 _order.Objectives[2].ObjectiveAction := ObjectiveActionEnum.DROP;

 _orderId := _client.SendTransportOrder(Order := _order);
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _orderId) = RequestStatusEnum.PENDING ), Message := 'order pending');
  AssertTrue(Condition := _server.GetTransportOrder(Order := _received), Message := 'order available');
  AssertEquals_DINT(Expected := 2, Actual := _received.ObjectiveCount, Message := 'objectives');
  AssertEquals_STRING(Expected := 'STORE5', Actual := _received.Objectives[2].Destination, Message := 'destination');
  AssertEquals_STRING(Expected := 'euro_pallet', Actual := _received.Objectives[1].LoadHandlingUnit.LoadHandlingUnitType, Message := 'lhu');
  AssertTrue(Condition := ( _received.Priority = PriorityEnum.HIGH ), Message := 'priority');
  AssertEquals_STRING(Expected := _orderId, Actual := _server.OrderRequestId, Message := 'order request id');

 _server.SetRequestStatus(RequestId := _orderId, Status := RequestStatusEnum.RUNNING, ResultDescription := '');
 _server.SetObjectiveReached(ObjectiveId := 'O1');
  Cycle(Count := 1);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _orderId) = RequestStatusEnum.RUNNING ), Message := 'order running');
  AssertEquals_STRING(Expected := 'O1', Actual := _client.OrderState.LastObjectiveId, Message := 'last objective');
  AssertEquals_DINT(Expected := 1, Actual := _client.OrderState.ObjectiveCount, Message := 'one open objective');
  AssertEquals_STRING(Expected := 'O2', Actual := _client.OrderState.Objectives[1].ObjectiveId, Message := 'open objective');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD TO_002_UpdateOrder
/// Update replaces the objectives from the first new sequenceId
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('TO_002_UpdateOrder');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _order.TransportOrderUpdateId  := 1;
 _order.IsObjectiveListComplete := TRUE;
 _order.ObjectiveCount          := 2;
 _order.Objectives[1].ObjectiveId     := 'O2b';
 _order.Objectives[1].SequenceId      := 1;
 _order.Objectives[1].Destination     := 'STORE7';
 _order.Objectives[1].ObjectiveAction := ObjectiveActionEnum.VIA;
 _order.Objectives[1].LoadHandlingUnitValid := FALSE;
 _order.Objectives[2].ObjectiveId     := 'O3';
 _order.Objectives[2].SequenceId      := 2;
 _order.Objectives[2].Destination     := 'STORE9';
 _order.Objectives[2].ObjectiveAction := ObjectiveActionEnum.DROP;

 _id := _client.SendTransportOrder(Order := _order);
  Cycle(Count := 2);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'update accepted');
  AssertTrue(Condition := _server.GetTransportOrder(Order := _received), Message := 'order available');
  AssertEquals_DINT(Expected := 3, Actual := _received.ObjectiveCount, Message := 'O1 kept, O2 replaced, O3 added');
  AssertEquals_STRING(Expected := 'STORE7', Actual := _received.Objectives[2].Destination, Message := 'replaced objective');
  AssertEquals_DINT(Expected := 1, Actual := _client.OrderState.TransportOrderUpdateId, Message := 'update id in state');
  AssertEquals_DINT(Expected := 2, Actual := _client.OrderState.ObjectiveCount, Message := 'two open objectives');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD TO_003_StaleUpdate
/// Update with an old update id is rejected
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('TO_003_StaleUpdate');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client.SendTransportOrder(Order := _order);
  Cycle(Count := 2);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FAILED ), Message := 'update rejected');
  AssertTrue(Condition := _client.HasError(ErrorType := M2XLibraryConstants.ERR_IN_VALIDATION, RequestId := _id), Message := 'validation error');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD TO_004_CancelOrder
/// requestCancel cancels the order
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('TO_004_CancelOrder');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _id := _client.CancelTransportOrder(TransportOrderId := 'TO-1');
  Cycle(Count := 2);
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _id) = RequestStatusEnum.FINISHED ), Message := 'cancel finished');
  AssertTrue(Condition := ( _client.GetRequestStatus(RequestId := _orderId) = RequestStatusEnum.FAILED ), Message := 'order failed');
  AssertTrue(Condition := _client.OrderState.IsCanceled, Message := 'isCanceled in state');
  AssertTrue(Condition := _server.IsCanceled, Message := 'server canceled');
  AssertFalse(Condition := _server.GetTransportOrder(Order := _received), Message := 'no order for the application');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD
