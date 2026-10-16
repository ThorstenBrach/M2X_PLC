/// Builds a topic interfaceName/version/entityName/topic
FUNCTION BuildTopic : STRING(255)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      BuildTopic
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Builds a topic interfaceName/version/entityName/topic
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
  /// Endpoint configuration (interface name, version, entity name)
  Config : EndpointConfigData;
  /// Last topic segment (request, state, factsheet)
  Topic  : STRING(32);
END_VAR
  BuildTopic := CONCAT(Config.InterfaceName, '/');
  BuildTopic := CONCAT(BuildTopic, Config.TopicVersion);
  BuildTopic := CONCAT(BuildTopic, '/');
  BuildTopic := CONCAT(BuildTopic, Config.EntityName);
  BuildTopic := CONCAT(BuildTopic, '/');
  BuildTopic := CONCAT(BuildTopic, Topic);
END_FUNCTION
