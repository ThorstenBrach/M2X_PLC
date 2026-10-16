/// System dependent implementation of the memory set function
FUNCTION SysDepMemSet : UDINT
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepMemSet
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent implementation of the memory set function
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
  /// Pointer to memory address to be filled (target)
  pDest   : POINTER TO BYTE;
  /// Value with which the memory is initialized
  Value   : BYTE;
  /// Amount of bytes to be initialized
  DataLen : UDINT;
END_VAR
  SysDepMemSet := MEMSET(destAddr := pDest, fillByte := Value, n := DataLen);
END_FUNCTION
