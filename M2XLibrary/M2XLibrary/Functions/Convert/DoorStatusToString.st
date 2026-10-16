/// Converts DoorStatusEnum to its JSON text
FUNCTION DoorStatusToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      DoorStatusToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts DoorStatusEnum to its JSON text
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
  Value : DoorStatusEnum;
END_VAR
  CASE Value OF
    DoorStatusEnum.NONE                            : DoorStatusToString := '';
    DoorStatusEnum.OPEN                            : DoorStatusToString := 'OPEN';
    DoorStatusEnum.CLOSED                          : DoorStatusToString := 'CLOSED';
    DoorStatusEnum.OPENING                         : DoorStatusToString := 'OPENING';
    DoorStatusEnum.CLOSING                         : DoorStatusToString := 'CLOSING';
  ELSE
    DoorStatusToString := '';
  END_CASE
END_FUNCTION
