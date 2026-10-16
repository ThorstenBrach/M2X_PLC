/// Converts the JSON text to ChargingProcessEnum (ChargingProcessEnum.NONE if unknown)
FUNCTION ChargingProcessFromString : ChargingProcessEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingProcessFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to ChargingProcessEnum (ChargingProcessEnum.NONE if unknown)
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
  /// Text to convert
  Text : STRING(64);
END_VAR
  ChargingProcessFromString := ChargingProcessEnum.NONE;

  IF ( Text = 'CHARGING' )
  THEN
    ChargingProcessFromString := ChargingProcessEnum.CHARGING;
    RETURN;
  END_IF

  IF ( Text = 'DONE' )
  THEN
    ChargingProcessFromString := ChargingProcessEnum.DONE;
    RETURN;
  END_IF

  IF ( Text = 'IDLE' )
  THEN
    ChargingProcessFromString := ChargingProcessEnum.IDLE;
    RETURN;
  END_IF
END_FUNCTION
