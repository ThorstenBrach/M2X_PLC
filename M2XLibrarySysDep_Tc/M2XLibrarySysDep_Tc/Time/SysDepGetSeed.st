/// System dependent seed for the random number generator
FUNCTION SysDepGetSeed : UDINT
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepGetSeed
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent seed for the random number generator
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
VAR
  /// System time in 100 ns
 _now : ULINT;
END_VAR
 _now           := F_GetSystemTime();
  SysDepGetSeed := ULINT_TO_UDINT(_now) XOR ULINT_TO_UDINT(SHR(_now, 32));
END_FUNCTION
