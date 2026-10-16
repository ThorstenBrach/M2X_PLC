// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ObjectiveData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Objective of a transport order (WHAT and WHERE)
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
/// Objective of a transport order (WHAT and WHERE)
TYPE ObjectiveData :
STRUCT
  /// Unique id of the objective
  ObjectiveId             : STRING(64);
  /// Sequence id (strictly increasing)
  SequenceId              : DINT;
  /// Destination (WHERE)
  Destination             : STRING(64);
  /// Action (WHAT)
  ObjectiveAction         : ObjectiveActionEnum;
  /// Human readable name (optional)
  DisplayName             : STRING(64);
  /// Load handling unit is set
  LoadHandlingUnitValid   : BOOL;
  /// Load handling unit
  LoadHandlingUnit        : LoadHandlingUnitData;
  /// Earliest completion time (ISO8601, optional)
  EarliestCompletionTime  : STRING(32);
  /// Latest completion time (ISO8601, optional)
  LatestCompletionTime    : STRING(32);
  /// Estimated completion time (state only, optional)
  EstimatedCompletionTime : STRING(32);
END_STRUCT
END_TYPE
