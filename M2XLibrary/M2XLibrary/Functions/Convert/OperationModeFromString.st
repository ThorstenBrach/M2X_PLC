/// Converts the JSON text to OperationModeEnum (OperationModeEnum.NONE if unknown)
FUNCTION OperationModeFromString : OperationModeEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      OperationModeFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to OperationModeEnum (OperationModeEnum.NONE if unknown)
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
  OperationModeFromString := OperationModeEnum.NONE;

  IF ( Text = 'AUTOMATIC' )
  THEN
    OperationModeFromString := OperationModeEnum.AUTOMATIC;
    RETURN;
  END_IF

  IF ( Text = 'MANUAL' )
  THEN
    OperationModeFromString := OperationModeEnum.MANUAL;
    RETURN;
  END_IF

  IF ( Text = 'SERVICE' )
  THEN
    OperationModeFromString := OperationModeEnum.SERVICE;
    RETURN;
  END_IF
END_FUNCTION
