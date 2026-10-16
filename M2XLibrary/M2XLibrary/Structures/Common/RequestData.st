// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    One request
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
/// One request
TYPE RequestData :
STRUCT
  /// Type of the request
  RequestType        : RequestTypeEnum;
  /// Unique id of the request
  RequestId          : STRING(64);
  /// Additional information (optional)
  RequestDescription : STRING(255);
  /// Identity of the sender (M2X proposal, empty if not sent)
  SenderId           : STRING(64);
  /// Request parameters
  Parameters         : RequestParameterData;
END_STRUCT
END_TYPE
