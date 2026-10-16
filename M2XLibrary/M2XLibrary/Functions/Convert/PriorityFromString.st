/// Converts the JSON text to PriorityEnum (PriorityEnum.NONE if unknown)
FUNCTION PriorityFromString : PriorityEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      PriorityFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to PriorityEnum (PriorityEnum.NONE if unknown)
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
  PriorityFromString := PriorityEnum.NONE;

  IF ( Text = 'VERY_LOW' )
  THEN
    PriorityFromString := PriorityEnum.VERY_LOW;
    RETURN;
  END_IF

  IF ( Text = 'LOW' )
  THEN
    PriorityFromString := PriorityEnum.LOW;
    RETURN;
  END_IF

  IF ( Text = 'MEDIUM' )
  THEN
    PriorityFromString := PriorityEnum.MEDIUM;
    RETURN;
  END_IF

  IF ( Text = 'HIGH' )
  THEN
    PriorityFromString := PriorityEnum.HIGH;
    RETURN;
  END_IF

  IF ( Text = 'VERY_HIGH' )
  THEN
    PriorityFromString := PriorityEnum.VERY_HIGH;
    RETURN;
  END_IF
END_FUNCTION
