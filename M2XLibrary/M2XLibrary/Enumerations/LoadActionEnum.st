{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadActionEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Load action at a load handling point
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
/// Load action at a load handling point
TYPE LoadActionEnum :
(
  /// No action
  NONE := 0,
  /// MR picks the load
  PICK := 1,
  /// MR drops the load
  DROP := 2
);
END_TYPE
