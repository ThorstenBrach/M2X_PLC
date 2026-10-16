// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      TransportOrderData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Transport order
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
/// Transport order
TYPE TransportOrderData :
STRUCT
  /// Transport order id
  TransportOrderId        : STRING(64);
  /// Update id (0 = initial order)
  TransportOrderUpdateId  : DINT;
  /// No further objectives will be added
  IsObjectiveListComplete : BOOL;
  /// Resource that shall execute the order (optional)
  ResourceId              : STRING(64);
  /// Priority (optional)
  Priority                : PriorityEnum;
  /// Number of objectives
  ObjectiveCount          : DINT;
  /// Objectives
  Objectives              : ARRAY [1..M2XLibraryParameter.OBJECTIVES_MAX] OF ObjectiveData;
END_STRUCT
END_TYPE
