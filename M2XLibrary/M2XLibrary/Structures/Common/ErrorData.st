// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ErrorData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Error of an entity (common error object for all interfaces)
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
/// Error of an entity (common error object for all interfaces)
TYPE ErrorData :
STRUCT
  /// Type of the error
  ErrorType           : STRING(64);
  /// Level of the error
  ErrorLevel          : ErrorLevelEnum;
  /// Verbose description
  ErrorDescription    : STRING(255);
  /// Request that caused the error (optional)
  RequestId           : STRING(64);
  /// Point the error belongs to (0 = whole entity, not serialized)
  PointIndex          : DINT;
  /// Number of valid error references
  ErrorReferenceCount : DINT;
  /// Error references
  ErrorReferences     : ARRAY [1..M2XLibraryParameter.ERROR_REFERENCES_MAX] OF ErrorReferenceData;
END_STRUCT
END_TYPE
