/// Length of a null-terminated string in a buffer (without SIZE limit of the standard functions)
FUNCTION StringLength : UDINT
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      StringLength
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Length of a null-terminated string in a buffer (without SIZE limit of the standard functions)
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
  /// Pointer to the string
  pText : POINTER TO BYTE;
  /// Size of the buffer in bytes
  Size  : UDINT;
END_VAR
  IF ( pText = 0 )
  THEN
    RETURN;
  END_IF

  // AND_THEN: the byte behind the buffer is never read
  WHILE (( StringLength < Size ) AND_THEN ( pText[StringLength] <> 0 )) DO
    StringLength := StringLength + 1;
  END_WHILE
END_FUNCTION
