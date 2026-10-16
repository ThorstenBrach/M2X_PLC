/// Converts the JSON text to LoadActionEnum (LoadActionEnum.NONE if unknown)
FUNCTION LoadActionFromString : LoadActionEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadActionFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to LoadActionEnum (LoadActionEnum.NONE if unknown)
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
  LoadActionFromString := LoadActionEnum.NONE;

  IF ( Text = 'PICK' )
  THEN
    LoadActionFromString := LoadActionEnum.PICK;
    RETURN;
  END_IF

  IF ( Text = 'DROP' )
  THEN
    LoadActionFromString := LoadActionEnum.DROP;
    RETURN;
  END_IF
END_FUNCTION
