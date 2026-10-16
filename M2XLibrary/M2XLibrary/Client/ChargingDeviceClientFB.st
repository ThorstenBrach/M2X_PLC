/// M2X client of a charging device (MR/FM side)
FUNCTION_BLOCK ChargingDeviceClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingDeviceClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X client of a charging device (MR/FM side)
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
  /// Charging session of the last state
  CurrentChargingSessionId : STRING(64);
  /// Charging process of the last own request
  ChargingProcess          : ChargingProcessData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_CHARGING_DEVICE;
  END_IF

  SUPER^();
END_FUNCTION_BLOCK

METHOD PROTECTED ParseRequestStateExtras
/// chargingProcess of an own request
VAR_INPUT
  /// requestStates item
  Item : DINT;
  /// Slot of the own request
  Slot : DINT;
END_VAR
VAR
  /// chargingProcess object
 _proc : DINT;
END_VAR
 _proc := _parser.FindKey(ObjectToken := Item, Key := 'chargingProcess');
  IF ( _parser.GetType(Token := _proc) = JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    ChargingProcess.Charging     := ChargingProcessFromString(_parser.GetStringByKey(ObjectToken := _proc, Key := 'charging'));
    ChargingProcess.Temperature  := _parser.GetLRealByKey(ObjectToken := _proc, Key := 'temperature');
    ChargingProcess.ChargingRate := _parser.GetLRealByKey(ObjectToken := _proc, Key := 'chargingRate');
    ChargingProcess.Derating     := _parser.GetBoolByKey(ObjectToken := _proc, Key := 'derating');
  END_IF
END_METHOD

METHOD PROTECTED ParseStateContent
/// State of the charging device
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// chargingDeviceState object
 _dev : DINT;
END_VAR
  RemoteConnectionState    := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'connectionState'));
 _dev                      := _parser.FindKey(ObjectToken := Root, Key := 'chargingDeviceState');
  CurrentChargingSessionId := _parser.GetStringByKey(ObjectToken := _parser.FindKey(ObjectToken := _dev, Key := 'currentCharging'), Key := 'chargingSessionId');
  ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := _dev, Key := 'requestStates'));
  ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := _dev, Key := 'errors'));
END_METHOD

METHOD RequestCharging : STRING(64)
/// Sends a request of the charging session (access, startCharge, stopCharge, release, cancel); returns the request id
VAR_INPUT
  /// Request type
  RequestType       : RequestTypeEnum;
  /// Charging session id
  ChargingSessionId : STRING(64);
END_VAR
  ClearParameters();
 _params.ChargingSessionId := ChargingSessionId;
  RequestCharging := SendRequest(RequestType := RequestType, Description := '', Parameters := _params);
END_METHOD
