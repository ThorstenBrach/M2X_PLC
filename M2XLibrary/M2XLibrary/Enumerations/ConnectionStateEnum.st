{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ConnectionStateEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Connection state of an entity
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
/// Connection state of an entity
TYPE ConnectionStateEnum :
(
  /// Unknown
  NONE := 0,
  /// Connection to the broker is active
  ONLINE := 1,
  /// Connection went offline in a coordinated way
  OFFLINE := 2,
  /// Connection ended unexpectedly
  CONNECTION_BROKEN := 3
);
END_TYPE
