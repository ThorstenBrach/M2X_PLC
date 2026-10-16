// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ElevatorConfigData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Configuration of an elevator of a group (server)
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
/// Configuration of an elevator of a group (server)
TYPE ElevatorConfigData :
STRUCT
  /// Id of the elevator
  ElevatorId   : STRING(64);
  /// Serial number
  SerialNumber : STRING(64);
  /// Manufacturer
  Manufacturer : STRING(64);
  /// Description for humans (optional)
  Descriptor   : STRING(64);
END_STRUCT
END_TYPE
