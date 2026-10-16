{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestStatusEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Status of a request
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
/// Status of a request
TYPE RequestStatusEnum :
(
  /// No status (request unknown or not yet reported)
  NONE := 0,
  /// The request is pending and has not yet been executed
  PENDING := 1,
  /// The request is currently being executed
  RUNNING := 2,
  /// The request is paused
  PAUSED := 3,
  /// The request has been finished successfully
  FINISHED := 4,
  /// The request could not be finished
  FAILED := 5
);
END_TYPE
