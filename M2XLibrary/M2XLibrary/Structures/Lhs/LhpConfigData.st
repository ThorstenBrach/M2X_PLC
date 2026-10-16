// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LhpConfigData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Configuration of a load handling point (server)
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
/// Configuration of a load handling point (server)
TYPE LhpConfigData :
STRUCT
  /// Id of the load handling point
  LoadHandlingPointId : STRING(64);
  /// Operation mode of the point
  OperationMode       : OperationModeEnum := OperationModeEnum.AUTOMATIC;
  /// Point is connected (FALSE = CONNECTION_BROKEN)
  Online              : BOOL := TRUE;
END_STRUCT
END_TYPE
