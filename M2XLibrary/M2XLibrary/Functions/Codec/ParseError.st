/// Reads an error object
FUNCTION ParseError : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ParseError
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reads an error object
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
VAR_IN_OUT
  /// JSON parser
  Parser : JsonParserFB;
  /// Error
  Error  : ErrorData;
END_VAR
VAR_INPUT
  /// Object token
  Token : DINT;
END_VAR
VAR
  /// errorReferences array
 _refs : DINT;
  /// Reference item
 _item : DINT;
  /// Reference index
 _idx  : DINT;
END_VAR
  IF ( Parser.GetType(Token := Token) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  Error.ErrorType           := Parser.GetStringByKey(ObjectToken := Token, Key := 'errorType');
  Error.ErrorLevel          := ErrorLevelFromString(Parser.GetStringByKey(ObjectToken := Token, Key := 'errorLevel'));
  Error.ErrorDescription    := Parser.GetStringByKey(ObjectToken := Token, Key := 'errorDescription');
  Error.RequestId           := Parser.GetStringByKey(ObjectToken := Token, Key := 'requestId');
  Error.ErrorReferenceCount := 0;

 _refs := Parser.FindKey(ObjectToken := Token, Key := 'errorReferences');
  FOR _idx := 0 TO MIN(Parser.GetSize(Token := _refs), M2XLibraryParameter.ERROR_REFERENCES_MAX) - 1
  DO
   _item := Parser.GetArrayItem(ArrayToken := _refs, Index := _idx);
    Error.ErrorReferenceCount := Error.ErrorReferenceCount + 1;
    Error.ErrorReferences[Error.ErrorReferenceCount].ReferenceKey   := Parser.GetStringByKey(ObjectToken := _item, Key := 'referenceKey');
    Error.ErrorReferences[Error.ErrorReferenceCount].ReferenceValue := Parser.GetStringByKey(ObjectToken := _item, Key := 'referenceValue');
  END_FOR

  ParseError := ( Error.ErrorType <> '' );
END_FUNCTION
