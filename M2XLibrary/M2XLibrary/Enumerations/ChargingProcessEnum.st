{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingProcessEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    State of a charging process
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
/// State of a charging process
TYPE ChargingProcessEnum :
(
  /// Not defined
  NONE := 0,
  /// Charging is running
  CHARGING := 1,
  /// Charging is done
  DONE := 2,
  /// Charging device is idle
  IDLE := 3
);
END_TYPE
