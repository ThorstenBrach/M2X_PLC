// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ElevatorStateData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    State of an elevator as seen by a client
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
/// State of an elevator as seen by a client
TYPE ElevatorStateData :
STRUCT
  /// Id of the elevator
  ElevatorId        : STRING(64);
  /// Connection state
  ConnectionState   : ConnectionStateEnum;
  /// Operation mode
  OperationMode     : OperationModeEnum;
  /// Name of the current floor
  CurrentFloorName  : STRING(64);
  /// Height of the current floor in m
  CurrentFloorLevel : LREAL;
END_STRUCT
END_TYPE
