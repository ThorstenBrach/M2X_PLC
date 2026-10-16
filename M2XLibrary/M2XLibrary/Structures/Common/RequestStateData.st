// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestStateData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Request state as seen by a client
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
/// Request state as seen by a client
TYPE RequestStateData :
STRUCT
  /// Entry is used
  Used              : BOOL;
  /// Id of the request
  RequestId         : STRING(64);
  /// Type of the request
  RequestType       : RequestTypeEnum;
  /// Status reported by the server
  RequestStatus     : RequestStatusEnum;
  /// Result description reported by the server
  ResultDescription : STRING(255);
  /// Time when the request was sent
  SendTime          : TIME;
END_STRUCT
END_TYPE
