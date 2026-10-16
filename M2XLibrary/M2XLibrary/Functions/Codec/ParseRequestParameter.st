/// Reads one known request parameter (FALSE if the key is unknown)
FUNCTION ParseRequestParameter : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ParseRequestParameter
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reads one known request parameter (FALSE if the key is unknown)
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
VAR_IN_OUT
  /// JSON parser
  Parser     : JsonParserFB;
  /// Request parameters
  Parameters : RequestParameterData;
END_VAR
VAR_INPUT
  /// Key of the parameter
  Key        : STRING(64);
  /// Value token
  ValueToken : DINT;
END_VAR
VAR
  /// Value as text
 _value : STRING(255);
END_VAR
 _value                 := Parser.GetString(Token := ValueToken);
  ParseRequestParameter := TRUE;

  IF ( Key = 'loadHandlingSessionId' )
  THEN
    Parameters.LoadHandlingSessionId := _value;
  ELSIF ( Key = 'loadHandlingPointId' )
  THEN
    Parameters.LoadHandlingPointId := _value;
  ELSIF ( Key = 'vehicleType' )
  THEN
    Parameters.VehicleType := _value;
  ELSIF ( Key = 'loadAction' )
  THEN
    Parameters.LoadAction := LoadActionFromString(_value);
  ELSIF ( Key = 'loadHandlingUnit' )
  THEN
    Parameters.LoadHandlingUnitValid := ParseLoadHandlingUnit(Parser := Parser, Lhu := Parameters.LoadHandlingUnit, Token := ValueToken);
  ELSIF ( Key = 'activeLoadTransferDevice' )
  THEN
    Parameters.ActiveLoadTransferDevice := LoadTransferDeviceFromString(_value);
  ELSIF ( Key = 'doorId' )
  THEN
    Parameters.DoorId := _value;
  ELSIF ( Key = 'doorStatus' )
  THEN
    Parameters.DoorStatus := DoorStatusFromString(_value);
  ELSIF ( Key = 'signalId' )
  THEN
    Parameters.SignalId := _value;
  ELSIF ( Key = 'elevatorSessionId' )
  THEN
    Parameters.ElevatorSessionId := _value;
  ELSIF ( Key = 'requestedFloor' )
  THEN
    Parameters.RequestedFloor := _value;
  ELSIF ( Key = 'intendedTargetFloor' )
  THEN
    Parameters.IntendedTargetFloor := _value;
  ELSIF ( Key = 'targetFloor' )
  THEN
    Parameters.TargetFloor := _value;
  ELSIF ( Key = 'operationMode' )
  THEN
    Parameters.OperationMode := OperationModeFromString(_value);
  ELSIF ( Key = 'chargingSessionId' )
  THEN
    Parameters.ChargingSessionId := _value;
  ELSIF ( Key = 'transportOrderId' )
  THEN
    Parameters.TransportOrderId := _value;
  ELSIF ( Key = 'isCanceled' )
  THEN
    Parameters.IsCanceledValid := TRUE;
    Parameters.IsCanceled      := Parser.GetBool(Token := ValueToken);
  ELSE
    ParseRequestParameter := FALSE;
  END_IF
END_FUNCTION
