{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ErrorLevelEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Level of an error
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
/// Level of an error
TYPE ErrorLevelEnum :
(
  /// No level
  NONE := 0,
  /// Self-resolving error
  WARNING := 1,
  /// Error that needs human intervention
  FATAL := 2
);
END_TYPE
