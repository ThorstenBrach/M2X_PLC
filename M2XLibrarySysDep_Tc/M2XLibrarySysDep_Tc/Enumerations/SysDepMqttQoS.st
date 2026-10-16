{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepMqttQoS
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    MQTT quality of service
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
/// MQTT quality of service
TYPE SysDepMqttQoS :
(
  /// QoS 0
  AT_MOST_ONCE  := 0,
  /// QoS 1
  AT_LEAST_ONCE := 1,
  /// QoS 2
  EXACTLY_ONCE  := 2
);
END_TYPE
