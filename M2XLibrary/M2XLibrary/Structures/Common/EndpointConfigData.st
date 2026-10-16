// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      EndpointConfigData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Configuration of a client or server endpoint
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
/// Configuration of a client or server endpoint
TYPE EndpointConfigData :
STRUCT
  /// Interface name, first topic segment (e.g. lhs)
  InterfaceName   : STRING(32);
  /// Version segment of the topic
  TopicVersion    : STRING(16) := 'v1';
  /// Unique entity name (server: own name, client: name of the target entity)
  EntityName      : STRING(64);
  /// Serial number of the entity (server only)
  SerialNumber    : STRING(64);
  /// Manufacturer of the entity (server only)
  Manufacturer    : STRING(64);
  /// Protocol version written into the messages
  ProtocolVersion : STRING(16) := '0.9.0';
END_STRUCT
END_TYPE
