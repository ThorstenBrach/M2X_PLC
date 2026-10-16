// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ErrorReferenceData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reference of an error (key/value pair)
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
/// Reference of an error (key/value pair)
TYPE ErrorReferenceData :
STRUCT
  /// Reference key (e.g. objectiveId)
  ReferenceKey   : STRING(64);
  /// Reference value
  ReferenceValue : STRING(255);
END_STRUCT
END_TYPE
