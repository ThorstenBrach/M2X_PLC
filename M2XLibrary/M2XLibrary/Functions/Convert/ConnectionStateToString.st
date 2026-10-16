/// Converts ConnectionStateEnum to its JSON text
FUNCTION ConnectionStateToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ConnectionStateToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts ConnectionStateEnum to its JSON text
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
  Value : ConnectionStateEnum;
END_VAR
  CASE Value OF
    ConnectionStateEnum.NONE                            : ConnectionStateToString := '';
    ConnectionStateEnum.ONLINE                          : ConnectionStateToString := 'ONLINE';
    ConnectionStateEnum.OFFLINE                         : ConnectionStateToString := 'OFFLINE';
    ConnectionStateEnum.CONNECTION_BROKEN               : ConnectionStateToString := 'CONNECTION_BROKEN';
  ELSE
    ConnectionStateToString := '';
  END_CASE
END_FUNCTION
