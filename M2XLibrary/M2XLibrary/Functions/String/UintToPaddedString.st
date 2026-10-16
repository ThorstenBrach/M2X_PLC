/// Converts an unsigned number to a string with leading zeros
FUNCTION UintToPaddedString : STRING(16)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      UintToPaddedString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts an unsigned number to a string with leading zeros
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
  Value  : UDINT;
  /// Minimum number of digits
  Digits : DINT;
END_VAR
VAR
  /// Loop guard
 _idx : DINT;
END_VAR
  UintToPaddedString := UDINT_TO_STRING(Value);

  FOR _idx := 1 TO 10
  DO
    IF ( LEN(UintToPaddedString) >= Digits )
    THEN
      EXIT;
    END_IF
    UintToPaddedString := CONCAT('0', UintToPaddedString);
  END_FOR
END_FUNCTION
