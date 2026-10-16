// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      MessageData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Message received from a transport
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
/// Message received from a transport
TYPE MessageData :
STRUCT
  /// Topic of the message
  Topic         : STRING(255);
  /// Length of the payload in bytes
  PayloadLength : UDINT;
  /// TRUE if the payload did not fit into the buffer (payload is empty then)
  Oversized     : BOOL;
  /// Payload
  Payload       : ARRAY [0..M2XLibraryParameter.MESSAGE_SIZE_MAX - 1] OF BYTE;
END_STRUCT
END_TYPE
