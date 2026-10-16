{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      M2XTestParameter
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Parameters of the M2X tests
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
/// Parameters of the M2X tests
VAR_GLOBAL
  /// Run the MQTT loopback test (needs a broker and a TF6701 license)
  MQTT_TEST_ENABLED : BOOL := TRUE;
  /// Host of the MQTT broker
  MQTT_HOST         : STRING(255) := '127.0.0.1';
  /// Port of the MQTT broker
  MQTT_PORT         : UINT := 1883;
  /// Timeout of the MQTT loopback test
  MQTT_TIMEOUT      : TIME := T#20S;
END_VAR
