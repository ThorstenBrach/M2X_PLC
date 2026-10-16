/// Endpoint configuration for tests
FUNCTION MakeConfig : EndpointConfigData
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      MakeConfig
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Endpoint configuration for tests
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
VAR_INPUT
  /// Interface name ('' = default of the FB)
  InterfaceName : STRING(32);
  /// Entity name
  EntityName    : STRING(64);
END_VAR
  MakeConfig.InterfaceName := InterfaceName;
  MakeConfig.EntityName    := EntityName;
  MakeConfig.SerialNumber  := CONCAT('SN-', EntityName);
  MakeConfig.Manufacturer  := 'M2X Test';
END_FUNCTION
