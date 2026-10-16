// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingProcessData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Charging process reported by the charging device
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
/// Charging process reported by the charging device
TYPE ChargingProcessData :
STRUCT
  /// CHARGING, DONE or IDLE
  Charging     : ChargingProcessEnum := ChargingProcessEnum.IDLE;
  /// Temperature during charging
  Temperature  : LREAL;
  /// Charging rate
  ChargingRate : LREAL;
  /// Derating active
  Derating     : BOOL;
END_STRUCT
END_TYPE
