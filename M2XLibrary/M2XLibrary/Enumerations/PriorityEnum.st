{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      PriorityEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Priority of a transport order
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
/// Priority of a transport order
TYPE PriorityEnum :
(
  /// Not defined
  NONE := 0,
  /// Very low
  VERY_LOW := 1,
  /// Low
  LOW := 2,
  /// Medium
  MEDIUM := 3,
  /// High
  HIGH := 4,
  /// Very high
  VERY_HIGH := 5
);
END_TYPE
