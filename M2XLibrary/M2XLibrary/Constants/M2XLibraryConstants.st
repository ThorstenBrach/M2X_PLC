{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      M2XLibraryConstants
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Constants of the M2X protocol
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
/// Constants of the M2X protocol
VAR_GLOBAL CONSTANT
  /// Implemented M2X protocol version
  PROTOCOL_VERSION            : STRING(16) := '0.9.0';
  /// Version segment of the topic
  TOPIC_VERSION               : STRING(16) := 'v1';
  /// Interface name of the load handling interface
  INTERFACE_LHS               : STRING(32) := 'lhs';
  /// Interface name of the transport order interface
  INTERFACE_ORDER             : STRING(32) := 'order';
  /// Interface name of the door interface
  INTERFACE_DOOR              : STRING(32) := 'door';
  /// Interface name of the signaling device interface
  INTERFACE_SIGNALING_DEVICE  : STRING(32) := 'signal_light';
  /// Interface name of the elevator interface
  INTERFACE_ELEVATOR          : STRING(32) := 'elevator';
  /// Interface name of the charging device interface
  INTERFACE_CHARGING_DEVICE   : STRING(32) := 'charging_device';
  /// Topic for requests (one generic request topic per entity)
  TOPIC_REQUEST               : STRING(32) := 'request';
  /// Topic for the state
  TOPIC_STATE                 : STRING(32) := 'state';
  /// Topic for the factsheet
  TOPIC_FACTSHEET             : STRING(32) := 'factsheet';
  /// Error type: request type not supported by the entity
  ERR_REQUEST_NOT_SUPPORTED   : STRING(64) := 'REQUEST_NOT_SUPPORTED';
  /// Error type: the sender already has an active request
  ERR_REQUEST_ALREADY_ACTIVE  : STRING(64) := 'REQUEST_ALREADY_ACTIVE';
  /// Error type: a request parameter is missing or invalid
  ERR_INVALID_PARAMETER       : STRING(64) := 'INVALID_REQUEST_PARAMETER';
  /// Error type: the request is not allowed in the current sequence step
  ERR_REQUEST_SEQUENCE        : STRING(64) := 'REQUEST_SEQUENCE_ERROR';
  /// Error type: the received message could not be parsed
  ERR_INVALID_MESSAGE         : STRING(64) := 'INVALID_MESSAGE';
  /// Error type: no free request entry
  ERR_REQUEST_TABLE_FULL      : STRING(64) := 'REQUEST_TABLE_FULL';
  /// Error type: error during execution (predefined by the spec)
  ERR_DURING_EXECUTION        : STRING(64) := 'ERROR_DURING_EXECUTION';
  /// Error type: inconsistent transport order data (predefined by the spec)
  ERR_IN_VALIDATION           : STRING(64) := 'ERROR_IN_VALIDATION';
  /// Error type: objective already finished (predefined by the spec)
  ERR_OBJECTIVE_FINISHED      : STRING(64) := 'OBJECTIVE_ALREADY_FINISHED';
  /// Error type: objective already in execution (predefined by the spec)
  ERR_OBJECTIVE_IN_EXECUTION  : STRING(64) := 'OBJECTIVE_IN_EXECUTION';
  /// Error type: non-contiguous sequenceId (predefined by the spec)
  ERR_SEQUENCE_ID             : STRING(64) := 'SEQUENCE_ID_NON_CONTIGUOUS';
END_VAR
