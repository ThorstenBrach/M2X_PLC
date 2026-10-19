/// M2X client of an elevator group (MR/FM side)
FUNCTION_BLOCK ElevatorClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ElevatorClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X client of an elevator group (MR/FM side)
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
  /// Id of the group in the last state
  GroupId       : STRING(64);
  /// Number of elevators in the last state
  ElevatorCount : DINT;
  /// Elevators of the last state
  Elevators     : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF ElevatorStateData;
END_VAR
VAR
  /// Assigned elevators of the last state
 _assigned      : ARRAY [1..M2XLibraryParameter.REQUEST_ENTRIES_MAX] OF AssignedElevatorData;
  /// Number of assigned elevators
 _assignedCount : DINT;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_ELEVATOR;
  END_IF

  SUPER^();

METHOD GetAssignedElevator : STRING(64)
/// Elevator assigned to a requestElevator ('' = not yet assigned)
VAR_INPUT
  /// Request id of requestElevator
  RequestId : STRING(64);
END_VAR
VAR
  /// Index
 _i : DINT;
END_VAR
  FOR _i := 1 TO _assignedCount
  DO
    IF ( _assigned[_i].RequestId = RequestId )
    THEN
      GetAssignedElevator := _assigned[_i].AssignedElevatorId;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED ParseStateContent
/// State of the elevator group
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// elevatorStates array
 _arr   : DINT;
  /// Item token
 _item  : DINT;
  /// currentFloor object
 _floor : DINT;
  /// assignedElevators array
 _ass   : DINT;
  /// Item index
 _i     : DINT;
  /// Assigned index
 _a     : DINT;
END_VAR
  GroupId        := _parser.GetStringByKey(ObjectToken := Root, Key := 'groupId');
  ElevatorCount  := 0;
 _assignedCount  := 0;
  RemoteConnectionState := ConnectionStateEnum.NONE;

 _arr := _parser.FindKey(ObjectToken := Root, Key := 'elevatorStates');
  FOR _i := 0 TO _parser.GetSize(Token := _arr) - 1
  DO
   _item := _parser.GetArrayItem(ArrayToken := _arr, Index := _i);
    IF ( ElevatorCount < M2XLibraryParameter.POINTS_MAX )
    THEN
      ElevatorCount := ElevatorCount + 1;
     _floor         := _parser.FindKey(ObjectToken := _item, Key := 'currentFloor');
      Elevators[ElevatorCount].ElevatorId        := _parser.GetStringByKey(ObjectToken := _item, Key := 'elevatorId');
      Elevators[ElevatorCount].ConnectionState   := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := _item, Key := 'connectionState'));
      Elevators[ElevatorCount].OperationMode     := OperationModeFromString(_parser.GetStringByKey(ObjectToken := _item, Key := 'operationMode'));
      Elevators[ElevatorCount].CurrentFloorName  := _parser.GetStringByKey(ObjectToken := _floor, Key := 'floorName');
      Elevators[ElevatorCount].CurrentFloorLevel := _parser.GetLRealByKey(ObjectToken := _floor, Key := 'floorLevel');
      IF ( RemoteConnectionState = ConnectionStateEnum.NONE )
      THEN
        RemoteConnectionState := Elevators[ElevatorCount].ConnectionState;
      END_IF
    END_IF

   _ass := _parser.FindKey(ObjectToken := _item, Key := 'assignedElevators');
    FOR _a := 0 TO _parser.GetSize(Token := _ass) - 1
    DO
      IF ( _assignedCount < M2XLibraryParameter.REQUEST_ENTRIES_MAX )
      THEN
       _assignedCount := _assignedCount + 1;
       _assigned[_assignedCount].RequestId          := _parser.GetStringByKey(ObjectToken := _parser.GetArrayItem(ArrayToken := _ass, Index := _a), Key := 'requestId');
       _assigned[_assignedCount].AssignedElevatorId := _parser.GetStringByKey(ObjectToken := _parser.GetArrayItem(ArrayToken := _ass, Index := _a), Key := 'assignedElevatorId');
      END_IF
    END_FOR

    ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := _item, Key := 'requestStates'));
    ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := _item, Key := 'errors'));
  END_FOR
END_METHOD

METHOD RequestElevator : STRING(64)
/// Sends requestElevator; returns the request id
VAR_INPUT
  /// Session id
  ElevatorSessionId   : STRING(64);
  /// Floor where the MR waits
  RequestedFloor      : STRING(64);
  /// Intended target floor
  IntendedTargetFloor : STRING(64);
  /// Vehicle type
  VehicleType         : STRING(64);
END_VAR
  ClearParameters();
 _params.ElevatorSessionId   := ElevatorSessionId;
 _params.RequestedFloor      := RequestedFloor;
 _params.IntendedTargetFloor := IntendedTargetFloor;
 _params.VehicleType         := VehicleType;
  RequestElevator := SendRequest(RequestType := RequestTypeEnum.REQUEST_ELEVATOR, Description := '', Parameters := _params);
END_METHOD

METHOD RequestManualMode : STRING(64)
/// Sends requestManualMode; returns the request id
VAR_INPUT
  /// Operation mode
  OperationMode : OperationModeEnum;
END_VAR
  ClearParameters();
 _params.OperationMode := OperationMode;
  RequestManualMode := SendRequest(RequestType := RequestTypeEnum.REQUEST_MANUAL_MODE, Description := '', Parameters := _params);
END_METHOD

METHOD RequestSessionStep : STRING(64)
/// Sends a request of the session (access, changeFloor, exit, release, cancel); returns the request id
VAR_INPUT
  /// Request type
  RequestType       : RequestTypeEnum;
  /// Session id
  ElevatorSessionId : STRING(64);
  /// Target floor (requestChangeFloor)
  TargetFloor       : STRING(64);
END_VAR
  ClearParameters();
 _params.ElevatorSessionId := ElevatorSessionId;
 _params.TargetFloor       := TargetFloor;
  RequestSessionStep := SendRequest(RequestType := RequestType, Description := '', Parameters := _params);
END_METHOD

END_FUNCTION_BLOCK
