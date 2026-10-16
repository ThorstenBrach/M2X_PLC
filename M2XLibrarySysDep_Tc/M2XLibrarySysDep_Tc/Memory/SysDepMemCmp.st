/// System dependent implementation of the memory compare function (0 = equal)
FUNCTION SysDepMemCmp : DINT
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepMemCmp
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent implementation of the memory compare function (0 = equal)
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
  /// Pointer to 1st memory area
  pData1  : POINTER TO BYTE;
  /// Pointer to 2nd memory area
  pData2  : POINTER TO BYTE;
  /// Amount of bytes to be compared
  DataLen : UDINT;
END_VAR
  SysDepMemCmp := MEMCMP(pBuf1 := pData1, pBuf2 := pData2, n := DataLen);
END_FUNCTION
