// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      TransportOrderStateData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    State of a transport order as seen by a client
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
/// State of a transport order as seen by a client
TYPE TransportOrderStateData :
STRUCT
  /// Transport order id
  TransportOrderId       : STRING(64);
  /// Accepted update id
  TransportOrderUpdateId : DINT;
  /// Last reached objective
  LastObjectiveId        : STRING(64);
  /// Resource (optional)
  ResourceId             : STRING(64);
  /// Priority (optional)
  Priority               : PriorityEnum;
  /// Order is canceled
  IsCanceled             : BOOL;
  /// Number of open objectives
  ObjectiveCount         : DINT;
  /// Open objectives
  Objectives             : ARRAY [1..M2XLibraryParameter.OBJECTIVES_MAX] OF ObjectiveData;
END_STRUCT
END_TYPE
