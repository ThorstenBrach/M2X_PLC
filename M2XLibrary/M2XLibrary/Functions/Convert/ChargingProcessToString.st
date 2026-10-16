/// Converts ChargingProcessEnum to its JSON text
FUNCTION ChargingProcessToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingProcessToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts ChargingProcessEnum to its JSON text
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
  /// Value to convert
  Value : ChargingProcessEnum;
END_VAR
  CASE Value OF
    ChargingProcessEnum.NONE                            : ChargingProcessToString := '';
    ChargingProcessEnum.CHARGING                        : ChargingProcessToString := 'CHARGING';
    ChargingProcessEnum.DONE                            : ChargingProcessToString := 'DONE';
    ChargingProcessEnum.IDLE                            : ChargingProcessToString := 'IDLE';
  ELSE
    ChargingProcessToString := '';
  END_CASE
END_FUNCTION
