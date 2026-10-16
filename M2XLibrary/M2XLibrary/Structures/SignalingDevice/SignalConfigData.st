// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      SignalConfigData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Signal of a signaling device
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
/// Signal of a signaling device
TYPE SignalConfigData :
STRUCT
  /// Id of the signal
  SignalId      : STRING(64);
  /// Signal can be requested with requestSignal
  IsRequestable : BOOL;
  /// Description of the signal
  Descriptor    : STRING(64);
END_STRUCT
END_TYPE
