/// M2X load handling station (server): sequence requestAccess -> requestLoadTransfer -> requestExit -> requestRelease per load handling point
FUNCTION_BLOCK LhsServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LhsServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X load handling station (server): sequence requestAccess -> requestLoadTransfer -> requestExit -> requestRelease per load handling point
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
VAR_INPUT
  /// Number of load handling points
  PointCount : DINT := 1;
  /// Load handling points
  Points     : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF LhpConfigData;
END_VAR
VAR
  /// Sessions of the load handling points
 _lhp : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF LhpSessionData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_LHS;
  END_IF

  SUPER^();

METHOD PROTECTED CheckRequest : STRING(64)
/// Checks the load handling sequence
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
VAR
  /// Session of the request is bound to the point
 _bound : BOOL;
END_VAR
  IF ( _request.Parameters.LoadHandlingSessionId = '' )
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
    RETURN;
  END_IF

 _bound := ( _lhp[PointIndex].Phase <> LhsPhaseEnum.IDLE ) AND
            ( _lhp[PointIndex].SessionId = _request.Parameters.LoadHandlingSessionId );

  CASE _request.RequestType OF
    RequestTypeEnum.REQUEST_ACCESS:
      IF ( _request.Parameters.LoadAction = LoadActionEnum.NONE )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
      ELSIF ( _bound )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      ELSIF (( NOT Points[PointIndex].Online ) OR ( Points[PointIndex].OperationMode <> OperationModeEnum.AUTOMATIC ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_DURING_EXECUTION;
      END_IF

    RequestTypeEnum.REQUEST_LOAD_TRANSFER:
      IF (( NOT _bound ) OR ( _lhp[PointIndex].Phase <> LhsPhaseEnum.ACCESS_GRANTED ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_EXIT:
      IF (( NOT _bound ) OR
          (( _lhp[PointIndex].Phase <> LhsPhaseEnum.ACCESS_GRANTED ) AND ( _lhp[PointIndex].Phase <> LhsPhaseEnum.LOAD_TRANSFERRED )))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER:
      IF (( NOT _bound ) OR ( _lhp[PointIndex].Phase <> LhsPhaseEnum.FAILED ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_RELEASE:
      IF ( NOT _bound )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF
  ELSE
    CheckRequest := M2XLibraryConstants.ERR_REQUEST_NOT_SUPPORTED;
  END_CASE
END_METHOD

METHOD PRIVATE ClearSession
/// Frees a load handling point
VAR_INPUT
  /// Point index
  PointIndex : DINT;
END_VAR
 _lhp[PointIndex].Phase     := LhsPhaseEnum.IDLE;
 _lhp[PointIndex].SessionId := '';
 _lhp[PointIndex].SenderId  := '';
END_METHOD

METHOD GetPhase : LhsPhaseEnum
/// Sequence phase of a load handling point
VAR_INPUT
  /// Point index
  PointIndex : DINT;
END_VAR
  IF (( PointIndex >= 1 ) AND ( PointIndex <= M2XLibraryParameter.POINTS_MAX ))
  THEN
    GetPhase := _lhp[PointIndex].Phase;
  END_IF
END_METHOD

METHOD GetSessionId : STRING(64)
/// Current session id of a load handling point
VAR_INPUT
  /// Point index
  PointIndex : DINT;
END_VAR
  IF (( PointIndex >= 1 ) AND ( PointIndex <= M2XLibraryParameter.POINTS_MAX ))
  THEN
    GetSessionId := _lhp[PointIndex].SessionId;
  END_IF
END_METHOD

METHOD PROTECTED IsDeliverable : BOOL
/// requestAccess is delivered only when the point is free
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS )
  THEN
    IsDeliverable := ( _lhp[_requests[EntryIndex].PointIndex].Phase = LhsPhaseEnum.IDLE );
  ELSE
    IsDeliverable := TRUE;
  END_IF
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the load handling interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_ACCESS,
    RequestTypeEnum.REQUEST_LOAD_TRANSFER,
    RequestTypeEnum.REQUEST_EXIT,
    RequestTypeEnum.REQUEST_RELEASE,
    RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PROTECTED OnCanceled
/// Canceled requestAccess frees the point
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Point index
 _p : DINT;
END_VAR
 _p := _requests[EntryIndex].PointIndex;
  IF (( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS ) AND
      ( _lhp[_p].SessionId = _requests[EntryIndex].Request.Parameters.LoadHandlingSessionId ))
  THEN
    ClearSession(PointIndex := _p);
  END_IF
END_METHOD

METHOD PROTECTED OnDelivered
/// requestAccess delivered: the session occupies the point
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Point index
 _p : DINT;
END_VAR
 _p := _requests[EntryIndex].PointIndex;
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS )
  THEN
   _lhp[_p].Phase     := LhsPhaseEnum.ACCESS_REQUESTED;
   _lhp[_p].SessionId := _requests[EntryIndex].Request.Parameters.LoadHandlingSessionId;
   _lhp[_p].SenderId  := _requests[EntryIndex].Request.SenderId;
  END_IF
END_METHOD

METHOD PROTECTED OnStatusChanged
/// Follows the sequence phase of the point
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Point index
 _p      : DINT;
  /// Status of the entry
 _status : RequestStatusEnum;
END_VAR
 _p      := _requests[EntryIndex].PointIndex;
 _status := _requests[EntryIndex].Status;

  CASE _requests[EntryIndex].Request.RequestType OF
    RequestTypeEnum.REQUEST_ACCESS:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.ACCESS_GRANTED;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
        ClearSession(PointIndex := _p);
      END_IF

    RequestTypeEnum.REQUEST_LOAD_TRANSFER:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.LOAD_TRANSFERRED;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.FAILED;
      END_IF

    RequestTypeEnum.REQUEST_EXIT:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.EXIT_GRANTED;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.FAILED;
      END_IF

    RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _lhp[_p].Phase := LhsPhaseEnum.ACCESS_GRANTED;
      END_IF

    RequestTypeEnum.REQUEST_RELEASE:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
        ClearSession(PointIndex := _p);
      END_IF
  ELSE
    ;
  END_CASE
END_METHOD

METHOD PROTECTED ResolvePoint : DINT
/// Point by loadHandlingPointId, otherwise by session; single point station: point 1
VAR_INPUT
END_VAR
VAR
  /// Point index
 _i : DINT;
END_VAR
  IF ( _request.Parameters.LoadHandlingPointId <> '' )
  THEN
    FOR _i := 1 TO MIN(PointCount, M2XLibraryParameter.POINTS_MAX)
    DO
      IF ( Points[_i].LoadHandlingPointId = _request.Parameters.LoadHandlingPointId )
      THEN
        ResolvePoint := _i;
        RETURN;
      END_IF
    END_FOR
    RETURN;
  END_IF

  IF ( _request.Parameters.LoadHandlingSessionId <> '' )
  THEN
    FOR _i := 1 TO MIN(PointCount, M2XLibraryParameter.POINTS_MAX)
    DO
      IF (( _lhp[_i].Phase <> LhsPhaseEnum.IDLE ) AND ( _lhp[_i].SessionId = _request.Parameters.LoadHandlingSessionId ))
      THEN
        ResolvePoint := _i;
        RETURN;
      END_IF
    END_FOR
  END_IF

  IF ( PointCount = 1 )
  THEN
    ResolvePoint := 1;
  END_IF
END_METHOD

METHOD PROTECTED WriteStateContent
/// State of the load handling station
VAR_INPUT
END_VAR
VAR
  /// Point index
 _i     : DINT;
  /// Connection state of the point
 _state : ConnectionStateEnum;
END_VAR
 _writer.AddString(Name := 'serialNumber', Value := Config.SerialNumber);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'connectionStateLHS', Value := ConnectionStateToString(_connectionState));
 _writer.Key(Name := 'loadHandlingPointStates');
 _writer.BeginArray();
  FOR _i := 1 TO MIN(PointCount, M2XLibraryParameter.POINTS_MAX)
  DO
   _state := _connectionState;
    IF (( _state = ConnectionStateEnum.ONLINE ) AND ( NOT Points[_i].Online ))
    THEN
     _state := ConnectionStateEnum.CONNECTION_BROKEN;
    END_IF
   _writer.BeginObject();
   _writer.AddString(Name := 'loadHandlingPointId',   Value := Points[_i].LoadHandlingPointId);
   _writer.AddString(Name := 'operationMode',         Value := OperationModeToString(Points[_i].OperationMode));
   _writer.AddString(Name := 'connectionStateLHP',    Value := ConnectionStateToString(_state));
   _writer.AddString(Name := 'loadHandlingSessionId', Value := _lhp[_i].SessionId);
    WriteRequestStates(PointIndex := _i);
    WriteErrors(PointIndex := _i);
   _writer.EndObject();
  END_FOR
 _writer.EndArray();
END_METHOD

END_FUNCTION_BLOCK
