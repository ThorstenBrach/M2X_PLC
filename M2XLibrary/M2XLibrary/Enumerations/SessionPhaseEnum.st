{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      SessionPhaseEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Sequence phase of a session (charging device, elevator)
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
/// Sequence phase of a session (charging device, elevator)
TYPE SessionPhaseEnum :
(
  /// No session
  IDLE      := 0,
  /// Session opened (request delivered to the application)
  REQUESTED := 1,
  /// Session request finished
  GRANTED   := 2,
  /// Session is active (charging started, floor change finished ...)
  ACTIVE    := 3,
  /// Exit or stop finished, release expected
  EXITING   := 4,
  /// A request of the session failed
  FAILED    := 5
);
END_TYPE
