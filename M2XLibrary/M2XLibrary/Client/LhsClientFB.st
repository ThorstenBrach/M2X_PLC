/// M2X client of a load handling station (MR/FM side)
FUNCTION_BLOCK LhsClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LhsClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X client of a load handling station (MR/FM side)
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
  /// Number of load handling points in the last state
  PointCount : DINT;
  /// Load handling points of the last state
  Points     : ARRAY [1..M2XLibraryParameter.POINTS_MAX] OF LhpStateData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_LHS;
  END_IF

  SUPER^();
END_FUNCTION_BLOCK

METHOD PROTECTED ParseStateContent
/// State of the load handling station
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// loadHandlingPointStates array
 _arr  : DINT;
  /// Item token
 _item : DINT;
  /// Item index
 _i    : DINT;
END_VAR
  RemoteConnectionState := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'connectionStateLHS'));
  PointCount            := 0;

 _arr := _parser.FindKey(ObjectToken := Root, Key := 'loadHandlingPointStates');
  FOR _i := 0 TO _parser.GetSize(Token := _arr) - 1
  DO
   _item := _parser.GetArrayItem(ArrayToken := _arr, Index := _i);
    IF ( PointCount < M2XLibraryParameter.POINTS_MAX )
    THEN
      PointCount := PointCount + 1;
      Points[PointCount].LoadHandlingPointId   := _parser.GetStringByKey(ObjectToken := _item, Key := 'loadHandlingPointId');
      Points[PointCount].OperationMode         := OperationModeFromString(_parser.GetStringByKey(ObjectToken := _item, Key := 'operationMode'));
      Points[PointCount].ConnectionState       := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := _item, Key := 'connectionStateLHP'));
      Points[PointCount].LoadHandlingSessionId := _parser.GetStringByKey(ObjectToken := _item, Key := 'loadHandlingSessionId');
    END_IF
    ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := _item, Key := 'requestStates'));
    ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := _item, Key := 'errors'));
  END_FOR
END_METHOD

METHOD RequestAccess : STRING(64)
/// Sends requestAccess; returns the request id
VAR_INPUT
  /// Session id
  LoadHandlingSessionId    : STRING(64);
  /// Load handling point
  LoadHandlingPointId      : STRING(64);
  /// Vehicle type
  VehicleType              : STRING(64);
  /// PICK or DROP
  LoadAction               : LoadActionEnum;
  /// Active load transfer device
  ActiveLoadTransferDevice : LoadTransferDeviceEnum;
END_VAR
  ClearParameters();
 _params.LoadHandlingSessionId    := LoadHandlingSessionId;
 _params.LoadHandlingPointId      := LoadHandlingPointId;
 _params.VehicleType              := VehicleType;
 _params.LoadAction               := LoadAction;
 _params.ActiveLoadTransferDevice := ActiveLoadTransferDevice;
  RequestAccess := SendRequest(RequestType := RequestTypeEnum.REQUEST_ACCESS, Description := '', Parameters := _params);
END_METHOD

METHOD RequestSessionStep : STRING(64)
/// Sends a request of the session (loadTransfer, exit, release, continue, cancel); returns the request id
VAR_INPUT
  /// Request type
  RequestType           : RequestTypeEnum;
  /// Session id
  LoadHandlingSessionId : STRING(64);
  /// Load handling point (optional)
  LoadHandlingPointId   : STRING(64);
END_VAR
  ClearParameters();
 _params.LoadHandlingSessionId := LoadHandlingSessionId;
 _params.LoadHandlingPointId   := LoadHandlingPointId;
  RequestSessionStep := SendRequest(RequestType := RequestType, Description := '', Parameters := _params);
END_METHOD
