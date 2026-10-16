{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LhsPhaseEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Sequence phase of a load handling point
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
/// Sequence phase of a load handling point
TYPE LhsPhaseEnum :
(
  /// No session
  IDLE             := 0,
  /// requestAccess delivered to the application
  ACCESS_REQUESTED := 1,
  /// requestAccess finished: MR may enter
  ACCESS_GRANTED   := 2,
  /// requestLoadTransfer finished
  LOAD_TRANSFERRED := 3,
  /// requestExit finished: MR may leave
  EXIT_GRANTED     := 4,
  /// a request of the session failed (continue or release possible)
  FAILED           := 5
);
END_TYPE
