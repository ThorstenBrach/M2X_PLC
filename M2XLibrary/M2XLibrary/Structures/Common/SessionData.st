// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      SessionData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Session of a charging device or elevator (server)
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
/// Session of a charging device or elevator (server)
TYPE SessionData :
STRUCT
  /// Sequence phase
  Phase     : SessionPhaseEnum;
  /// Session id
  SessionId : STRING(64);
  /// Sender of the session
  SenderId  : STRING(64);
END_STRUCT
END_TYPE
