// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ElevatorInputData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Current data of an elevator provided by the application (server)
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
/// Current data of an elevator provided by the application (server)
TYPE ElevatorInputData :
STRUCT
  /// Name of the current floor
  CurrentFloorName  : STRING(64);
  /// Height of the current floor in m
  CurrentFloorLevel : LREAL;
  /// Operation mode
  OperationMode     : OperationModeEnum := OperationModeEnum.AUTOMATIC;
  /// Elevator is connected
  Online            : BOOL := TRUE;
END_STRUCT
END_TYPE
