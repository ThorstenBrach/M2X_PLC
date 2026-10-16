{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      M2XLibraryParameter
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Library parameters (sizes and timing) of the M2X library
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
/// Library parameters (sizes and timing) of the M2X library
VAR_GLOBAL CONSTANT
  /// Maximum size of one message (request, state or factsheet) in bytes
  MESSAGE_SIZE_MAX     : UDINT := 8192;
  /// Maximum number of messages buffered per transport
  MESSAGE_QUEUE_MAX    : UDINT := 8;
  /// Maximum size of the MQTT last will payload in bytes
  WILL_SIZE_MAX        : UDINT := 1024;
  /// Maximum number of JSON tokens of one message
  JSON_TOKEN_MAX       : DINT  := 512;
  /// Maximum nesting depth of a written JSON message
  JSON_DEPTH_MAX       : DINT  := 16;
  /// Maximum number of request entries of a server (all senders, all points)
  REQUEST_ENTRIES_MAX  : DINT  := 16;
  /// Maximum number of active errors of an endpoint
  ERRORS_MAX           : DINT  := 8;
  /// Maximum number of references of one error
  ERROR_REFERENCES_MAX : DINT  := 4;
  /// Maximum number of points of a server (load handling points, elevators of a group)
  POINTS_MAX           : DINT  := 4;
  /// Maximum number of signals of a signaling device
  SIGNALS_MAX          : DINT  := 8;
  /// Maximum number of objectives of a transport order
  OBJECTIVES_MAX       : DINT  := 16;
  /// Maximum number of requests tracked by a client
  CLIENT_REQUESTS_MAX  : DINT  := 16;
  /// Maximum number of subscriptions of a mock transport
  SUBSCRIPTIONS_MAX    : DINT  := 8;
  /// Maximum number of transports connected to a mock broker
  MOCK_CLIENTS_MAX     : DINT  := 16;
  /// Maximum number of retained messages of a mock broker
  MOCK_RETAINED_MAX    : DINT  := 16;
  /// Interval for the cyclic state message (spec: at least every 30 s)
  STATE_INTERVAL       : TIME  := T#30S;
  /// Time a finished or failed request stays in the state message
  REQUEST_RETENTION    : TIME  := T#60S;
END_VAR
