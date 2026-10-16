/// Writes all set request parameters as items of the requestParameters array
FUNCTION WriteRequestParameterItems : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteRequestParameterItems
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes all set request parameters as items of the requestParameters array
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
  /// JSON writer
  Writer     : JsonWriterFB;
  /// Request parameters
  Parameters : RequestParameterData;
END_VAR
  WriteStringParameter(Writer := Writer, Key := 'loadHandlingSessionId',    Value := Parameters.LoadHandlingSessionId);
  WriteStringParameter(Writer := Writer, Key := 'loadHandlingPointId',      Value := Parameters.LoadHandlingPointId);
  WriteStringParameter(Writer := Writer, Key := 'vehicleType',              Value := Parameters.VehicleType);
  WriteStringParameter(Writer := Writer, Key := 'loadAction',               Value := LoadActionToString(Parameters.LoadAction));
  WriteStringParameter(Writer := Writer, Key := 'activeLoadTransferDevice', Value := LoadTransferDeviceToString(Parameters.ActiveLoadTransferDevice));

  IF ( Parameters.LoadHandlingUnitValid )
  THEN
    Writer.BeginObject();
    Writer.AddString(Name := 'key', Value := 'loadHandlingUnit');
    Writer.Key(Name := 'value');
    WriteLoadHandlingUnit(Writer := Writer, Lhu := Parameters.LoadHandlingUnit);
    Writer.EndObject();
  END_IF

  WriteStringParameter(Writer := Writer, Key := 'doorId',              Value := Parameters.DoorId);
  WriteStringParameter(Writer := Writer, Key := 'doorStatus',          Value := DoorStatusToString(Parameters.DoorStatus));
  WriteStringParameter(Writer := Writer, Key := 'signalId',            Value := Parameters.SignalId);
  WriteStringParameter(Writer := Writer, Key := 'elevatorSessionId',   Value := Parameters.ElevatorSessionId);
  WriteStringParameter(Writer := Writer, Key := 'requestedFloor',      Value := Parameters.RequestedFloor);
  WriteStringParameter(Writer := Writer, Key := 'intendedTargetFloor', Value := Parameters.IntendedTargetFloor);
  WriteStringParameter(Writer := Writer, Key := 'targetFloor',         Value := Parameters.TargetFloor);
  WriteStringParameter(Writer := Writer, Key := 'operationMode',       Value := OperationModeToString(Parameters.OperationMode));
  WriteStringParameter(Writer := Writer, Key := 'chargingSessionId',   Value := Parameters.ChargingSessionId);
  WriteStringParameter(Writer := Writer, Key := 'transportOrderId',    Value := Parameters.TransportOrderId);

  IF ( Parameters.IsCanceledValid )
  THEN
    Writer.BeginObject();
    Writer.AddString(Name := 'key', Value := 'isCanceled');
    Writer.AddBool(Name := 'value', Value := Parameters.IsCanceled);
    Writer.EndObject();
  END_IF

  WriteRequestParameterItems := NOT Writer.Overflow;
END_FUNCTION
