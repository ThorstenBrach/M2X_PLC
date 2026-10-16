/// Converts the JSON text to ErrorLevelEnum (ErrorLevelEnum.NONE if unknown)
FUNCTION ErrorLevelFromString : ErrorLevelEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ErrorLevelFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to ErrorLevelEnum (ErrorLevelEnum.NONE if unknown)
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
  ErrorLevelFromString := ErrorLevelEnum.NONE;

  IF ( Text = 'WARNING' )
  THEN
    ErrorLevelFromString := ErrorLevelEnum.WARNING;
    RETURN;
  END_IF

  IF ( Text = 'FATAL' )
  THEN
    ErrorLevelFromString := ErrorLevelEnum.FATAL;
    RETURN;
  END_IF
END_FUNCTION
