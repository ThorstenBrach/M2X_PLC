/// Converts OperationModeEnum to its JSON text
FUNCTION OperationModeToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      OperationModeToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts OperationModeEnum to its JSON text
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
  Value : OperationModeEnum;
END_VAR
  CASE Value OF
    OperationModeEnum.NONE                            : OperationModeToString := '';
    OperationModeEnum.AUTOMATIC                       : OperationModeToString := 'AUTOMATIC';
    OperationModeEnum.MANUAL                          : OperationModeToString := 'MANUAL';
    OperationModeEnum.SERVICE                         : OperationModeToString := 'SERVICE';
  ELSE
    OperationModeToString := '';
  END_CASE
END_FUNCTION
