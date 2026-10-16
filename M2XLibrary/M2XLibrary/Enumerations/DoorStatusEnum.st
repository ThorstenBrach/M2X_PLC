{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      DoorStatusEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Status of a door
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
/// Status of a door
TYPE DoorStatusEnum :
(
  /// Unknown
  NONE := 0,
  /// Door is open
  OPEN := 1,
  /// Door is closed
  CLOSED := 2,
  /// Door is opening
  OPENING := 3,
  /// Door is closing
  CLOSING := 4
);
END_TYPE
