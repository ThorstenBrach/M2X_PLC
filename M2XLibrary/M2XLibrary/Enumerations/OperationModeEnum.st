{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      OperationModeEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Operation mode
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
/// Operation mode
TYPE OperationModeEnum :
(
  /// Not defined
  NONE := 0,
  /// Automatic operation
  AUTOMATIC := 1,
  /// Manual operation
  MANUAL := 2,
  /// Service operation
  SERVICE := 3
);
END_TYPE
