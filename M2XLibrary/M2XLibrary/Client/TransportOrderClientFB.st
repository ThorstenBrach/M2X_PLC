/// M2X transport order sender (upper layer system, e.g. a PLC with a call button)
FUNCTION_BLOCK TransportOrderClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      TransportOrderClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X transport order sender (upper layer system, e.g. a PLC with a call button)
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
VAR_OUTPUT
  /// State of the transport order of the last state message
  OrderState : TransportOrderStateData;
END_VAR
VAR
  /// Order to send
 _sendOrder      : TransportOrderData;
  /// _sendOrder is written into the next request
 _sendOrderValid : BOOL;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_ORDER;
  END_IF

  SUPER^();
END_FUNCTION_BLOCK

METHOD CancelTransportOrder : STRING(64)
/// Cancels a transport order; returns the request id
VAR_INPUT
  /// Transport order id
  TransportOrderId : STRING(64);
END_VAR
  ClearParameters();
 _params.TransportOrderId := TransportOrderId;
 _params.IsCanceledValid  := TRUE;
 _params.IsCanceled       := TRUE;
  CancelTransportOrder := SendRequest(RequestType := RequestTypeEnum.REQUEST_CANCEL, Description := '', Parameters := _params);
END_METHOD

METHOD PROTECTED ParseStateContent
/// State of the transport order
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// objectiveStates array
 _arr : DINT;
  /// Item index
 _i   : DINT;
END_VAR
  RemoteConnectionState             := ConnectionStateEnum.ONLINE;
  OrderState.TransportOrderId       := _parser.GetStringByKey(ObjectToken := Root, Key := 'transportOrderId');
  OrderState.TransportOrderUpdateId := LINT_TO_DINT(_parser.GetLintByKey(ObjectToken := Root, Key := 'transportOrderUpdateId'));
  OrderState.LastObjectiveId        := _parser.GetStringByKey(ObjectToken := Root, Key := 'lastObjectiveId');
  OrderState.ResourceId             := _parser.GetStringByKey(ObjectToken := Root, Key := 'resourceId');
  OrderState.Priority               := PriorityFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'priority'));
  OrderState.IsCanceled             := _parser.GetBoolByKey(ObjectToken := Root, Key := 'isCanceled');
  OrderState.ObjectiveCount         := 0;

 _arr := _parser.FindKey(ObjectToken := Root, Key := 'objectiveStates');
  FOR _i := 0 TO _parser.GetSize(Token := _arr) - 1
  DO
    IF ( OrderState.ObjectiveCount < M2XLibraryParameter.OBJECTIVES_MAX )
    THEN
      IF ( ParseObjective(Parser := _parser, Objective := OrderState.Objectives[OrderState.ObjectiveCount + 1], Token := _parser.GetArrayItem(ArrayToken := _arr, Index := _i)) )
      THEN
        OrderState.ObjectiveCount := OrderState.ObjectiveCount + 1;
      END_IF
    END_IF
  END_FOR

  ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := Root, Key := 'requestStates'));
  ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := Root, Key := 'errors'));
END_METHOD

METHOD SendTransportOrder : STRING(64)
/// Sends a new transport order or an update (same id, higher update id); returns the request id
VAR_IN_OUT
  /// Transport order
  Order : TransportOrderData;
END_VAR
 _sendOrder      := Order;
 _sendOrderValid := TRUE;
  ClearParameters();
  SendTransportOrder := SendRequest(RequestType := RequestTypeEnum.REQUEST_TRANSPORT_ORDER, Description := '', Parameters := _params);
 _sendOrderValid := FALSE;
END_METHOD

METHOD PROTECTED WriteCustomParameters
/// Writes the transport order parameter
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  IF (( RequestType = RequestTypeEnum.REQUEST_TRANSPORT_ORDER ) AND ( _sendOrderValid ))
  THEN
   _writer.BeginObject();
   _writer.AddString(Name := 'key', Value := 'transportOrder');
   _writer.Key(Name := 'value');
    WriteTransportOrder(Writer := _writer, Order := _sendOrder, Version := Config.ProtocolVersion);
   _writer.EndObject();
  END_IF
END_METHOD
