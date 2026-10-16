/// System dependent check whether an LREAL is a finite number
FUNCTION SysDepIsValidLReal : BOOL
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepIsValidLReal
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent check whether an LREAL is a finite number
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
  /// Value to check
  Value : LREAL;
END_VAR
  SysDepIsValidLReal := IsFinite(F_LREAL(Value));
END_FUNCTION
