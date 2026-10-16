{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestTypeEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Type of a request (requestType)
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
/// Type of a request (requestType)
TYPE RequestTypeEnum :
(
  /// Unknown request type
  UNKNOWN := 0,
  /// Request access
  REQUEST_ACCESS := 1,
  /// Request exit
  REQUEST_EXIT := 2,
  /// Request load transfer
  REQUEST_LOAD_TRANSFER := 3,
  /// Release occupancy
  REQUEST_RELEASE := 4,
  /// Request factsheet
  REQUEST_FACTSHEET := 5,
  /// Continue load transfer after an error
  REQUEST_CONTINUE_LOAD_TRANSFER := 6,
  /// Cancel the active request
  REQUEST_CANCEL := 7,
  /// Create or update a transport order
  REQUEST_TRANSPORT_ORDER := 8,
  /// Request door transit
  REQUEST_TRANSIT := 9,
  /// Request a signal
  REQUEST_SIGNAL := 10,
  /// Request an elevator
  REQUEST_ELEVATOR := 11,
  /// Request floor change
  REQUEST_CHANGE_FLOOR := 12,
  /// Request manual mode
  REQUEST_MANUAL_MODE := 13,
  /// Start charging
  REQUEST_START_CHARGE := 14,
  /// Stop charging
  REQUEST_STOP_CHARGE := 15
);
END_TYPE
