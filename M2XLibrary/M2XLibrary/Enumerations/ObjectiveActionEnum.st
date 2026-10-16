{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ObjectiveActionEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Action of an objective (WHAT)
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
/// Action of an objective (WHAT)
TYPE ObjectiveActionEnum :
(
  /// Not defined
  NONE := 0,
  /// Pick the load
  PICK := 1,
  /// Drop the load
  DROP := 2,
  /// Pass or wait at the destination
  VIA := 3
);
END_TYPE
