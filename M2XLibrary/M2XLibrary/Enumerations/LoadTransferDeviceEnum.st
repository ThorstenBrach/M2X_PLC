{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadTransferDeviceEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Device that actively transfers the load
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
/// Device that actively transfers the load
TYPE LoadTransferDeviceEnum :
(
  /// Not defined
  NONE := 0,
  /// Mobile robot is the active device
  MR := 1,
  /// Load handling station is the active device
  LHS := 2
);
END_TYPE
