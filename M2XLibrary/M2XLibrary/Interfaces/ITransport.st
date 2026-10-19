/// Publish/subscribe transport used by M2X clients and servers (one transport per endpoint)
INTERFACE ITransport
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ITransport
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Publish/subscribe transport used by M2X clients and servers (one transport per endpoint)
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

PROPERTY Connected : BOOL
/// Transport is connected
GET
VAR
END_VAR
END_GET
END_PROPERTY

METHOD Publish : BOOL
/// Publishes a message
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
END_METHOD

METHOD Receive : BOOL
/// Reads the next received message (FALSE if none)
VAR_IN_OUT
  /// Received message
  Message : MessageData;
END_VAR
END_METHOD

METHOD SetLastWill : BOOL
/// Sets the last will (published by the broker on an unexpected disconnect)
VAR_INPUT
  /// Topic
  Topic         : STRING(255);
  /// Payload
  pPayload      : POINTER TO BYTE;
  /// Length of the payload
  PayloadLength : UDINT;
  /// Retain flag
  RetainFlag        : BOOL;
END_VAR
END_METHOD

METHOD Subscribe : BOOL
/// Subscribes to a topic filter
VAR_INPUT
  /// Topic filter
  Topic : STRING(255);
END_VAR
END_METHOD

END_INTERFACE
