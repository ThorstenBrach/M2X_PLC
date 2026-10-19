/// M2X transport order receiver (FM or MR with local FM): accepts orders, updates and cancellations
FUNCTION_BLOCK TransportOrderServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      TransportOrderServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X transport order receiver (FM or MR with local FM): accepts orders, updates and cancellations
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
  /// Current transport order
 _order          : TransportOrderData;
  /// Order of the received request
 _received       : TransportOrderData;
  /// Received order is valid
 _receivedValid  : BOOL;
  /// A transport order exists
 _orderValid     : BOOL;
  /// Current order is canceled
 _isCanceled     : BOOL;
  /// Index of the last reached objective (0 = none)
 _lastObjective  : DINT;
  /// Request id of the current order
 _orderRequestId : STRING(64);
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_ORDER;
  END_IF

  SUPER^();

METHOD GetTransportOrder : BOOL
/// Current transport order (FALSE if none or canceled)
VAR_IN_OUT
  /// Transport order
  Order : TransportOrderData;
END_VAR
  IF (( NOT _orderValid ) OR ( _isCanceled ))
  THEN
    RETURN;
  END_IF

  Order             := _order;
  GetTransportOrder := TRUE;
END_METHOD

METHOD PROTECTED HandleRequest : BOOL
/// requestTransportOrder: new order or update of the current order
VAR_INPUT
END_VAR
  IF ( _request.RequestType <> RequestTypeEnum.REQUEST_TRANSPORT_ORDER )
  THEN
   _receivedValid := FALSE;
    RETURN;
  END_IF

  HandleRequest := TRUE;

  IF ( NOT _receivedValid )
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, PointIndex := 1, Description := 'transport order missing or invalid');
    RETURN;
  END_IF
 _receivedValid := FALSE;
 _request.Parameters.TransportOrderId := _received.TransportOrderId;

  // update of the current order
  IF (( _orderValid ) AND ( NOT _isCanceled ) AND ( _received.TransportOrderId = _order.TransportOrderId ))
  THEN
    IF ( _received.TransportOrderUpdateId <= _order.TransportOrderUpdateId )
    THEN
      Reject(ErrorType := M2XLibraryConstants.ERR_IN_VALIDATION, PointIndex := 1, Description := 'transportOrderUpdateId not increasing');
    ELSE
      MergeUpdate();
    END_IF
    RETURN;
  END_IF

  // new order only if the current order is finished, failed or canceled
  IF (( _orderValid ) AND ( NOT _isCanceled ) AND ( NOT IsFinalStatus(Status := GetRequestStatus(RequestId := _orderRequestId)) ))
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_REQUEST_ALREADY_ACTIVE, PointIndex := 1, Description := 'another transport order is active');
    RETURN;
  END_IF

  IF ( _received.ObjectiveCount = 0 )
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, PointIndex := 1, Description := 'transport order without objectives');
    RETURN;
  END_IF

 _order          := _received;
 _orderValid     := TRUE;
 _isCanceled     := FALSE;
 _lastObjective  := 0;
 _orderRequestId := _request.RequestId;
  AddEntry(Status := RequestStatusEnum.PENDING, PointIndex := 1, ResultDescription := '');
END_METHOD

PROPERTY IsCanceled : BOOL
/// Current transport order is canceled
GET
VAR
END_VAR
  IsCanceled := _isCanceled;
END_GET
END_PROPERTY

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the transport order interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_TRANSPORT_ORDER,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PRIVATE MergeUpdate
/// Applies an update: objectives from the first new sequenceId are replaced
VAR_INPUT
END_VAR
VAR
  /// First sequence id of the update
 _firstSeq : DINT;
  /// Last sequence id of the current order
 _lastSeq  : DINT;
  /// Objectives kept
 _keep     : DINT;
  /// Index
 _i        : DINT;
END_VAR
  IF ( _received.ObjectiveCount > 0 )
  THEN
   _firstSeq := _received.Objectives[1].SequenceId;
   _lastSeq  := _order.Objectives[MAX(_order.ObjectiveCount, 1)].SequenceId;

    // already reached objectives cannot be changed (AND_THEN: no index 0)
    IF (( _lastObjective > 0 ) AND_THEN ( _firstSeq <= _order.Objectives[_lastObjective].SequenceId ))
    THEN
      Reject(ErrorType := M2XLibraryConstants.ERR_OBJECTIVE_FINISHED, PointIndex := 1, Description := 'objective already finished');
      RETURN;
    END_IF

    IF ( _firstSeq > _lastSeq + 1 )
    THEN
      Reject(ErrorType := M2XLibraryConstants.ERR_SEQUENCE_ID, PointIndex := 1, Description := 'sequenceId non-contiguous');
      RETURN;
    END_IF

   _keep := 0;
    FOR _i := 1 TO _order.ObjectiveCount
    DO
      IF ( _order.Objectives[_i].SequenceId < _firstSeq )
      THEN
       _keep := _i;
      END_IF
    END_FOR

   _order.ObjectiveCount := _keep;
    FOR _i := 1 TO _received.ObjectiveCount
    DO
      IF ( _order.ObjectiveCount < M2XLibraryParameter.OBJECTIVES_MAX )
      THEN
       _order.ObjectiveCount := _order.ObjectiveCount + 1;
       _order.Objectives[_order.ObjectiveCount] := _received.Objectives[_i];
      END_IF
    END_FOR
  END_IF

 _order.TransportOrderUpdateId  := _received.TransportOrderUpdateId;
 _order.IsObjectiveListComplete := _received.IsObjectiveListComplete;
  IF ( _received.Priority <> PriorityEnum.NONE )
  THEN
   _order.Priority := _received.Priority;
  END_IF

  AddEntry(Status := RequestStatusEnum.FINISHED, PointIndex := 1, ResultDescription := 'update accepted');
END_METHOD

METHOD PROTECTED OnCanceled
/// Canceled order request: order is canceled
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestId = _orderRequestId )
  THEN
   _isCanceled := TRUE;
  END_IF
END_METHOD

PROPERTY OrderRequestId : STRING(64)
/// Request id of the current transport order (status with SetRequestStatus)
GET
VAR
END_VAR
  OrderRequestId := _orderRequestId;
END_GET
END_PROPERTY

METHOD PROTECTED ParseCustomParameter : BOOL
/// Transport order parameter (key transportOrder or transport_order)
VAR_INPUT
  /// Key
  Key        : STRING(64);
  /// Value token
  ValueToken : DINT;
END_VAR
  IF (( Key = 'transportOrder' ) OR ( Key = 'transport_order' ))
  THEN
   _receivedValid        := ParseTransportOrder(Parser := _parser, Order := _received, Token := ValueToken);
    ParseCustomParameter := TRUE;
  END_IF
END_METHOD

METHOD SetObjectiveReached : BOOL
/// Reports the objective that was reached last
VAR_INPUT
  /// Objective id
  ObjectiveId : STRING(64);
END_VAR
VAR
  /// Objective index
 _i : DINT;
END_VAR
  FOR _i := 1 TO _order.ObjectiveCount
  DO
    IF ( _order.Objectives[_i].ObjectiveId = ObjectiveId )
    THEN
     _lastObjective       := _i;
     _stateChanged        := TRUE;
      SetObjectiveReached := TRUE;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED WriteStateContent
/// State of the transport order
VAR_INPUT
END_VAR
VAR
  /// Objective index
 _i : DINT;
END_VAR
 _writer.AddString(Name := 'transportOrderId', Value := _order.TransportOrderId);
 _writer.AddInteger(Name := 'transportOrderUpdateId', Value := _order.TransportOrderUpdateId);
  IF ( _lastObjective > 0 )
  THEN
   _writer.AddString(Name := 'lastObjectiveId', Value := _order.Objectives[_lastObjective].ObjectiveId);
  ELSE
   _writer.AddString(Name := 'lastObjectiveId', Value := '');
  END_IF
 _writer.AddStringOptional(Name := 'resourceId', Value := _order.ResourceId);
 _writer.AddStringOptional(Name := 'priority',   Value := PriorityToString(_order.Priority));
 _writer.AddBool(Name := 'isCanceled', Value := _isCanceled);
 _writer.Key(Name := 'objectiveStates');
 _writer.BeginArray();
  IF (( _orderValid ) AND ( NOT _isCanceled ))
  THEN
    FOR _i := _lastObjective + 1 TO _order.ObjectiveCount
    DO
      WriteObjective(Writer := _writer, Objective := _order.Objectives[_i], IsState := TRUE);
    END_FOR
  END_IF
 _writer.EndArray();
  WriteRequestStates(PointIndex := 1);
  WriteErrors(PointIndex := 1);
END_METHOD

END_FUNCTION_BLOCK
