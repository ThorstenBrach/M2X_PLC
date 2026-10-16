{attribute 'qualified_only'}
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      JsonTokenTypeEnum
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Type of a JSON token
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
/// Type of a JSON token
TYPE JsonTokenTypeEnum :
(
  /// Token not used
  JSON_UNDEFINED := 0,
  /// JSON object
  JSON_OBJECT    := 1,
  /// JSON array
  JSON_ARRAY     := 2,
  /// JSON string
  JSON_STRING    := 3,
  /// JSON number, true, false or null
  JSON_PRIMITIVE := 4
);
END_TYPE
