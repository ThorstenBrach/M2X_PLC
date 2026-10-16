// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      JsonTokenData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Token of the JSON parser
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
/// Token of the JSON parser
TYPE JsonTokenData :
STRUCT
  /// Token type
  TokenType : JsonTokenTypeEnum;
  /// Start position in the message (first byte; for strings without quote)
  StartPos  : DINT;
  /// End position in the message (exclusive)
  EndPos    : DINT;
  /// Number of children (object: keys, array: items, key: 1)
  Size      : DINT;
  /// Parent token (-1 = none)
  Parent    : DINT;
END_STRUCT
END_TYPE
