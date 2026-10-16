// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LhpStateData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    State of a load handling point as seen by a client
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
/// State of a load handling point as seen by a client
TYPE LhpStateData :
STRUCT
  /// Id of the load handling point
  LoadHandlingPointId   : STRING(64);
  /// Operation mode
  OperationMode         : OperationModeEnum;
  /// Connection state of the point
  ConnectionState       : ConnectionStateEnum;
  /// Current session id
  LoadHandlingSessionId : STRING(64);
END_STRUCT
END_TYPE
