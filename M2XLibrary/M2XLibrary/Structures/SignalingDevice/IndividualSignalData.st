// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      IndividualSignalData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Individual signal of a request
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
/// Individual signal of a request
TYPE IndividualSignalData :
STRUCT
  /// Request of the signal
  RequestId : STRING(64);
  /// Id of the signal
  SignalId  : STRING(64);
END_STRUCT
END_TYPE
