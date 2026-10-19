/// M2X elevator group (server): requestElevator assigns an elevator; access, changeFloor, exit, release per session
FUNCTION_BLOCK ElevatorServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ElevatorServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X elevator group (server): requestElevator assigns an elevator; access, changeFloor, exit, release per session
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
  /// Id of the elevator group
  GroupId          : STRING(64);
  /// Description of the group (optional)
  GroupDescription : STRING(64);
  /// Number of elevators
  ElevatorCount    : DINT := 1;
  /// Elevators of the group
  Elevators        : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF ElevatorConfigData;
  /// Current data of the elevators (application)
  ElevatorInputs   : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF ElevatorInputData;
END_VAR
VAR
  /// Sessions of the elevators
 _sessions : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF SessionData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_ELEVATOR;
  END_IF

  SUPER^();

METHOD PROTECTED CheckRequest : STRING(64)
/// Checks the elevator sequence
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
VAR
  /// Session of the request is the session of the elevator
 _bound : BOOL;
  /// Elevator index
 _p     : DINT;
END_VAR
  IF ( _request.RequestType = RequestTypeEnum.REQUEST_MANUAL_MODE )
  THEN
    IF ( _sessions[PointIndex].Phase <> SessionPhaseEnum.IDLE )
    THEN
      CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
    END_IF
    RETURN;
  END_IF

  IF ( _request.Parameters.ElevatorSessionId = '' )
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
    RETURN;
  END_IF

 _bound := ( _sessions[PointIndex].Phase <> SessionPhaseEnum.IDLE ) AND
            ( _sessions[PointIndex].SessionId = _request.Parameters.ElevatorSessionId );

  CASE _request.RequestType OF
    RequestTypeEnum.REQUEST_ELEVATOR:
      FOR _p := 1 TO M2XLibraryParameter.POINTS_MAX
      DO
        IF (( _sessions[_p].Phase <> SessionPhaseEnum.IDLE ) AND ( _sessions[_p].SessionId = _request.Parameters.ElevatorSessionId ))
        THEN
          CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
        END_IF
      END_FOR

    RequestTypeEnum.REQUEST_ACCESS:
      IF (( NOT _bound ) OR ( _sessions[PointIndex].Phase <> SessionPhaseEnum.GRANTED ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_CHANGE_FLOOR:
      IF ( _request.Parameters.TargetFloor = '' )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
      ELSIF (( NOT _bound ) OR ( _sessions[PointIndex].Phase <> SessionPhaseEnum.ACTIVE ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_EXIT:
      IF (( NOT _bound ) OR ( _sessions[PointIndex].Phase <> SessionPhaseEnum.ACTIVE ))
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
/// Frees an elevator
VAR_INPUT
  /// Elevator index
  PointIndex : DINT;
END_VAR
 _sessions[PointIndex].Phase     := SessionPhaseEnum.IDLE;
 _sessions[PointIndex].SessionId := '';
 _sessions[PointIndex].SenderId  := '';
END_METHOD

METHOD GetPhase : SessionPhaseEnum
/// Sequence phase of an elevator session
VAR_INPUT
  /// Elevator index
  PointIndex : DINT;
END_VAR
  IF (( PointIndex >= 1 ) AND ( PointIndex <= M2XLibraryParameter.POINTS_MAX ))
  THEN
    GetPhase := _sessions[PointIndex].Phase;
  END_IF
END_METHOD

METHOD PROTECTED IsDeliverable : BOOL
/// requestElevator is delivered only when the elevator is free
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR )
  THEN
    IsDeliverable := ( _sessions[_requests[EntryIndex].PointIndex].Phase = SessionPhaseEnum.IDLE );
  ELSE
    IsDeliverable := TRUE;
  END_IF
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the elevator interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_ELEVATOR,
    RequestTypeEnum.REQUEST_ACCESS,
    RequestTypeEnum.REQUEST_CHANGE_FLOOR,
    RequestTypeEnum.REQUEST_EXIT,
    RequestTypeEnum.REQUEST_RELEASE,
    RequestTypeEnum.REQUEST_MANUAL_MODE,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PROTECTED OnCanceled
/// Canceled requestElevator frees the elevator
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Elevator index
 _p : DINT;
END_VAR
 _p := _requests[EntryIndex].PointIndex;
  IF (( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR ) AND
      ( _sessions[_p].SessionId = _requests[EntryIndex].Request.Parameters.ElevatorSessionId ))
  THEN
    ClearSession(PointIndex := _p);
  END_IF
END_METHOD

METHOD PROTECTED OnDelivered
/// requestElevator delivered: the session occupies the elevator
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Elevator index
 _p : DINT;
END_VAR
 _p := _requests[EntryIndex].PointIndex;
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR )
  THEN
   _sessions[_p].Phase     := SessionPhaseEnum.REQUESTED;
   _sessions[_p].SessionId := _requests[EntryIndex].Request.Parameters.ElevatorSessionId;
   _sessions[_p].SenderId  := _requests[EntryIndex].Request.SenderId;
  END_IF
END_METHOD

METHOD PROTECTED OnStatusChanged
/// Follows the elevator sequence
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Elevator index
 _p      : DINT;
  /// Status of the entry
 _status : RequestStatusEnum;
END_VAR
 _p      := _requests[EntryIndex].PointIndex;
 _status := _requests[EntryIndex].Status;

  CASE _requests[EntryIndex].Request.RequestType OF
    RequestTypeEnum.REQUEST_ELEVATOR:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _sessions[_p].Phase := SessionPhaseEnum.GRANTED;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
        ClearSession(PointIndex := _p);
      END_IF

    RequestTypeEnum.REQUEST_ACCESS:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _sessions[_p].Phase := SessionPhaseEnum.ACTIVE;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
       _sessions[_p].Phase := SessionPhaseEnum.FAILED;
      END_IF

    RequestTypeEnum.REQUEST_EXIT:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _sessions[_p].Phase := SessionPhaseEnum.EXITING;
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
/// requestElevator: free elevator with the fewest waiting requests; others: elevator of the session
VAR_INPUT
END_VAR
VAR
  /// Elevator index
 _p       : DINT;
  /// Entry index
 _i       : DINT;
  /// Waiting requests per elevator
 _pending : DINT;
  /// Best number of waiting requests
 _best    : DINT;
END_VAR
  IF ( _request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR )
  THEN
   _best := 16#7FFFFFFF;
    FOR _p := 1 TO MIN(ElevatorCount, M2XLibraryParameter.POINTS_MAX)
    DO
      IF (( ElevatorInputs[_p].Online ) AND ( ElevatorInputs[_p].OperationMode = OperationModeEnum.AUTOMATIC ))
      THEN
       _pending := 0;
        IF ( _sessions[_p].Phase <> SessionPhaseEnum.IDLE )
        THEN
         _pending := 1;
        END_IF
        FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
        DO
          IF (( _requests[_i].Used ) AND ( _requests[_i].PointIndex = _p ) AND
              ( _requests[_i].Status = RequestStatusEnum.PENDING ) AND
              ( _requests[_i].Request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR ))
          THEN
           _pending := _pending + 1;
          END_IF
        END_FOR
        IF ( _pending < _best )
        THEN
         _best         := _pending;
          ResolvePoint := _p;
        END_IF
      END_IF
    END_FOR
    RETURN;
  END_IF

  IF ( _request.Parameters.ElevatorSessionId <> '' )
  THEN
    FOR _p := 1 TO MIN(ElevatorCount, M2XLibraryParameter.POINTS_MAX)
    DO
      IF (( _sessions[_p].Phase <> SessionPhaseEnum.IDLE ) AND ( _sessions[_p].SessionId = _request.Parameters.ElevatorSessionId ))
      THEN
        ResolvePoint := _p;
        RETURN;
      END_IF
    END_FOR
    RETURN;
  END_IF

  IF ( _request.RequestType = RequestTypeEnum.REQUEST_MANUAL_MODE )
  THEN
    ResolvePoint := 1;
  END_IF
END_METHOD

METHOD PROTECTED WriteStateContent
/// State of the elevator group
VAR_INPUT
END_VAR
VAR
  /// Elevator index
 _p     : DINT;
  /// Entry index
 _i     : DINT;
  /// Connection state of the elevator
 _state : ConnectionStateEnum;
END_VAR
 _writer.AddString(Name := 'groupId', Value := GroupId);
 _writer.AddStringOptional(Name := 'groupDescription', Value := GroupDescription);
 _writer.Key(Name := 'elevatorStates');
 _writer.BeginArray();
  FOR _p := 1 TO MIN(ElevatorCount, M2XLibraryParameter.POINTS_MAX)
  DO
   _state := _connectionState;
    IF (( _state = ConnectionStateEnum.ONLINE ) AND ( NOT ElevatorInputs[_p].Online ))
    THEN
     _state := ConnectionStateEnum.CONNECTION_BROKEN;
    END_IF
   _writer.BeginObject();
   _writer.AddString(Name := 'elevatorId', Value := Elevators[_p].ElevatorId);
   _writer.AddStringOptional(Name := 'elevatorDescriptor', Value := Elevators[_p].Descriptor);
   _writer.AddString(Name := 'serialNumber',    Value := Elevators[_p].SerialNumber);
   _writer.AddString(Name := 'manufacturer',    Value := Elevators[_p].Manufacturer);
   _writer.AddString(Name := 'connectionState', Value := ConnectionStateToString(_state));
   _writer.AddString(Name := 'operationMode',   Value := OperationModeToString(ElevatorInputs[_p].OperationMode));
   _writer.Key(Name := 'currentFloor');
   _writer.BeginObject();
   _writer.AddString(Name := 'floorName',  Value := ElevatorInputs[_p].CurrentFloorName);
   _writer.AddNumber(Name := 'floorLevel', Value := ElevatorInputs[_p].CurrentFloorLevel);
   _writer.Key(Name := 'doorStates');
   _writer.BeginArray();
   _writer.EndArray();
   _writer.EndObject();
    WriteRequestStates(PointIndex := _p);
   _writer.Key(Name := 'assignedElevators');
   _writer.BeginArray();
    FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
    DO
      IF (( _requests[_i].Used ) AND ( _requests[_i].PointIndex = _p ) AND ( _requests[_i].Delivered ) AND
          ( _requests[_i].Request.RequestType = RequestTypeEnum.REQUEST_ELEVATOR ) AND
          ( _requests[_i].Status <> RequestStatusEnum.FAILED ))
      THEN
       _writer.BeginObject();
       _writer.AddString(Name := 'requestId',          Value := _requests[_i].Request.RequestId);
       _writer.AddString(Name := 'assignedElevatorId', Value := Elevators[_p].ElevatorId);
       _writer.EndObject();
      END_IF
    END_FOR
   _writer.EndArray();
    WriteErrors(PointIndex := _p);
   _writer.EndObject();
  END_FOR
 _writer.EndArray();
END_METHOD

END_FUNCTION_BLOCK
