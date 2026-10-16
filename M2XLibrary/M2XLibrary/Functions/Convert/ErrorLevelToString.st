/// Converts ErrorLevelEnum to its JSON text
FUNCTION ErrorLevelToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ErrorLevelToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts ErrorLevelEnum to its JSON text
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
  Value : ErrorLevelEnum;
END_VAR
  CASE Value OF
    ErrorLevelEnum.NONE                            : ErrorLevelToString := '';
    ErrorLevelEnum.WARNING                         : ErrorLevelToString := 'WARNING';
    ErrorLevelEnum.FATAL                           : ErrorLevelToString := 'FATAL';
  ELSE
    ErrorLevelToString := '';
  END_CASE
END_FUNCTION
