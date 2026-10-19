/// M2X client of a door (MR/FM side)
FUNCTION_BLOCK DoorClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      DoorClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X client of a door (MR/FM side)
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
  /// Id of the door in the last state
  DoorId     : STRING(64);
  /// Status of the door in the last state
  DoorStatus : DoorStatusEnum;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_DOOR;
  END_IF

  SUPER^();

METHOD PROTECTED ParseStateContent
/// State of the door
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// doorState object
 _door : DINT;
END_VAR
  RemoteConnectionState := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'connectionState'));
 _door       := _parser.FindKey(ObjectToken := Root, Key := 'doorState');
  DoorId     := _parser.GetStringByKey(ObjectToken := _door, Key := 'doorId');
  DoorStatus := DoorStatusFromString(_parser.GetStringByKey(ObjectToken := _door, Key := 'doorStatus'));
  ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := _door, Key := 'requestStates'));
  ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := _door, Key := 'errors'));
END_METHOD

METHOD RequestDoor : STRING(64)
/// Sends requestTransit, requestRelease or requestCancel; returns the request id
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
  /// Id of the door
  TargetDoorId : STRING(64);
END_VAR
  ClearParameters();
 _params.DoorId  := TargetDoorId;
  RequestDoor    := SendRequest(RequestType := RequestType, Description := '', Parameters := _params);
END_METHOD

END_FUNCTION_BLOCK
