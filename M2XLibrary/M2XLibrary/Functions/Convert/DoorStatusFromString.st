/// Converts the JSON text to DoorStatusEnum (DoorStatusEnum.NONE if unknown)
FUNCTION DoorStatusFromString : DoorStatusEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      DoorStatusFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to DoorStatusEnum (DoorStatusEnum.NONE if unknown)
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
  DoorStatusFromString := DoorStatusEnum.NONE;

  IF ( Text = 'OPEN' )
  THEN
    DoorStatusFromString := DoorStatusEnum.OPEN;
    RETURN;
  END_IF

  IF ( Text = 'CLOSED' )
  THEN
    DoorStatusFromString := DoorStatusEnum.CLOSED;
    RETURN;
  END_IF

  IF ( Text = 'OPENING' )
  THEN
    DoorStatusFromString := DoorStatusEnum.OPENING;
    RETURN;
  END_IF

  IF ( Text = 'CLOSING' )
  THEN
    DoorStatusFromString := DoorStatusEnum.CLOSING;
    RETURN;
  END_IF
END_FUNCTION
