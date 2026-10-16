// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      AssignedElevatorData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Elevator assigned to a requestElevator
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
/// Elevator assigned to a requestElevator
TYPE AssignedElevatorData :
STRUCT
  /// Request id
  RequestId          : STRING(64);
  /// Assigned elevator
  AssignedElevatorId : STRING(64);
END_STRUCT
END_TYPE
