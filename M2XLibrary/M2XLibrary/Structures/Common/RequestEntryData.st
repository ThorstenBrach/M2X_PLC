// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestEntryData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Request entry of a server
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
/// Request entry of a server
TYPE RequestEntryData :
STRUCT
  /// Entry is used
  Used              : BOOL;
  /// Received request
  Request           : RequestData;
  /// Current status
  Status            : RequestStatusEnum;
  /// Result description written into the state
  ResultDescription : STRING(255);
  /// Point of the entity the request belongs to (1..POINTS_MAX)
  PointIndex        : DINT;
  /// Request was handed to the application
  Delivered         : BOOL;
  /// Arrival order
  Sequence          : UDINT;
  /// Time when the request reached FINISHED or FAILED
  FinalTime         : TIME;
END_STRUCT
END_TYPE
