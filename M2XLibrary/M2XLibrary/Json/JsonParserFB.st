/// Parses a JSON message into tokens (jsmn algorithm with parent links); the message buffer must stay valid
FUNCTION_BLOCK JsonParserFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      JsonParserFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Parses a JSON message into tokens (jsmn algorithm with parent links); the message buffer must stay valid
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
VAR
  /// Parsed message
 _pData      : POINTER TO BYTE;
  /// Length of the message
 _length     : DINT;
  /// Tokens
 _tokens     : ARRAY [0..M2XLibraryParameter.JSON_TOKEN_MAX - 1] OF JsonTokenData;
  /// Number of tokens
 _tokenCount : DINT;
  /// Position of the last parse error (-1 = none)
 _errorPos   : DINT := -1;
END_VAR

METHOD PRIVATE AllocToken : DINT
/// Reserves a new token (-1 if the token array is full)
VAR_INPUT
END_VAR
  IF ( _tokenCount >= M2XLibraryParameter.JSON_TOKEN_MAX )
  THEN
    AllocToken := -1;
    RETURN;
  END_IF

  AllocToken                  := _tokenCount;
 _tokens[_tokenCount].TokenType := JsonTokenTypeEnum.JSON_UNDEFINED;
 _tokens[_tokenCount].StartPos  := -1;
 _tokens[_tokenCount].EndPos    := -1;
 _tokens[_tokenCount].Size      := 0;
 _tokens[_tokenCount].Parent    := -1;
 _tokenCount                 := _tokenCount + 1;
END_METHOD

METHOD CopyRaw : UDINT
/// Copies the raw JSON text of a token (objects and arrays with brackets)
VAR_INPUT
  /// Token
  Token    : DINT;
  /// Target buffer
  pDest    : POINTER TO BYTE;
  /// Size of the target buffer
  DestSize : UDINT;
END_VAR
VAR
  /// Start including the quote of strings
 _start : DINT;
  /// End including the quote of strings
 _end   : DINT;
END_VAR
  IF (( Token < 0 ) OR ( Token >= _tokenCount ))
  THEN
    RETURN;
  END_IF

 _start := _tokens[Token].StartPos;
 _end   := _tokens[Token].EndPos;
  IF ( _tokens[Token].TokenType = JsonTokenTypeEnum.JSON_STRING )
  THEN
   _start := _start - 1;
   _end   := _end + 1;
  END_IF

  IF ( DINT_TO_UDINT(_end - _start) > DestSize )
  THEN
    RETURN;
  END_IF

  CopyRaw := DINT_TO_UDINT(_end - _start);
  SysDepMemCpy(pDest := pDest, pSrc := _pData + DINT_TO_UDINT(_start), DataLen := CopyRaw);
END_METHOD

PROPERTY ErrorPos : DINT
/// Position of the last parse error (-1 = no error)
GET
VAR
END_VAR
  ErrorPos := _errorPos;
END_GET
END_PROPERTY

METHOD FindKey : DINT
/// Value token of a key in an object (-1 if not found)
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
VAR
  /// Token index
 _idx : DINT;
END_VAR
  FindKey := -1;

  IF ( GetType(Token := ObjectToken) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  FOR _idx := ObjectToken + 1 TO _tokenCount - 2
  DO
    IF (( _tokens[_idx].Parent    = ObjectToken                ) AND
        ( _tokens[_idx].TokenType = JsonTokenTypeEnum.JSON_STRING   ))
    THEN
      IF ( TokenEquals(Token := _idx, Text := Key) )
      THEN
        FindKey := _idx + 1;
        RETURN;
      END_IF
    END_IF
    // children of later siblings start behind the end of the object
    IF ( _tokens[_idx].StartPos >= _tokens[ObjectToken].EndPos )
    THEN
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD GetArrayItem : DINT
/// Item token of an array (Index 0-based, -1 if not found)
VAR_INPUT
  /// Array token
  ArrayToken : DINT;
  /// Index of the item (0-based)
  Index      : DINT;
END_VAR
VAR
  /// Token index
 _idx   : DINT;
  /// Counter of children
 _count : DINT;
END_VAR
  GetArrayItem := -1;

  IF ( GetType(Token := ArrayToken) <> JsonTokenTypeEnum.JSON_ARRAY )
  THEN
    RETURN;
  END_IF

  FOR _idx := ArrayToken + 1 TO _tokenCount - 1
  DO
    IF ( _tokens[_idx].StartPos >= _tokens[ArrayToken].EndPos )
    THEN
      RETURN;
    END_IF
    IF ( _tokens[_idx].Parent = ArrayToken )
    THEN
      IF ( _count = Index )
      THEN
        GetArrayItem := _idx;
        RETURN;
      END_IF
     _count := _count + 1;
    END_IF
  END_FOR
END_METHOD

METHOD GetBool : BOOL
/// Boolean value of a token (true)
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
  IF ( GetType(Token := Token) = JsonTokenTypeEnum.JSON_PRIMITIVE )
  THEN
    GetBool := ( _pData[_tokens[Token].StartPos] = 116 );
  END_IF
END_METHOD

METHOD GetBoolByKey : BOOL
/// Boolean value of a key (FALSE if not found)
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
  GetBoolByKey := GetBool(Token := FindKey(ObjectToken := ObjectToken, Key := Key));
END_METHOD

METHOD GetLint : LINT
/// Integer value of a token
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
VAR
  /// Raw text
 _text : STRING(255);
END_VAR
  IF ( GetType(Token := Token) <> JsonTokenTypeEnum.JSON_PRIMITIVE )
  THEN
    RETURN;
  END_IF

 _text := GetString(Token := Token);
  IF (( FIND(_text, '.') > 0 ) OR ( FIND(_text, 'e') > 0 ) OR ( FIND(_text, 'E') > 0 ))
  THEN
    GetLint := LREAL_TO_LINT(STRING_TO_LREAL(_text));
  ELSE
    GetLint := STRING_TO_LINT(_text);
  END_IF
END_METHOD

METHOD GetLintByKey : LINT
/// Integer value of a key (0 if not found)
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
  GetLintByKey := GetLint(Token := FindKey(ObjectToken := ObjectToken, Key := Key));
END_METHOD

METHOD GetLReal : LREAL
/// Number value of a token
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
  IF ( GetType(Token := Token) = JsonTokenTypeEnum.JSON_PRIMITIVE )
  THEN
    GetLReal := STRING_TO_LREAL(GetString(Token := Token));
  END_IF
END_METHOD

METHOD GetLRealByKey : LREAL
/// Number value of a key (0 if not found)
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
  GetLRealByKey := GetLReal(Token := FindKey(ObjectToken := ObjectToken, Key := Key));
END_METHOD

METHOD GetObjectKey : DINT
/// Key token of an object (Index 0-based, -1 if not found); the value token is key + 1
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Index of the key (0-based)
  Index       : DINT;
END_VAR
VAR
  /// Token index
 _idx   : DINT;
  /// Counter of keys
 _count : DINT;
END_VAR
  GetObjectKey := -1;

  IF ( GetType(Token := ObjectToken) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  FOR _idx := ObjectToken + 1 TO _tokenCount - 1
  DO
    IF ( _tokens[_idx].StartPos >= _tokens[ObjectToken].EndPos )
    THEN
      RETURN;
    END_IF
    IF ( _tokens[_idx].Parent = ObjectToken )
    THEN
      IF ( _count = Index )
      THEN
        GetObjectKey := _idx;
        RETURN;
      END_IF
     _count := _count + 1;
    END_IF
  END_FOR
END_METHOD

METHOD GetSize : DINT
/// Number of children of a token (array items, object keys)
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
  IF (( Token >= 0 ) AND ( Token < _tokenCount ))
  THEN
    GetSize := _tokens[Token].Size;
  END_IF
END_METHOD

METHOD GetString : STRING(255)
/// String value of a token (unescaped, max. 255 bytes; raw text for primitives)
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
VAR
  /// Result
 _result  : STRING(255);
  /// Pointer to the result
 _pResult : POINTER TO BYTE;
  /// Write position
 _n       : DINT;
  /// Read position
 _pos     : DINT;
  /// End position
 _end     : DINT;
  /// Current character
 _c       : BYTE;
  /// Unicode code point of \uXXXX
 _code    : UDINT;
  /// Hex digit counter
 _idx     : DINT;
  /// Value of a hex digit
 _digit   : BYTE;
END_VAR
  IF (( Token < 0 ) OR ( Token >= _tokenCount ))
  THEN
    RETURN;
  END_IF

 _pResult := ADR(_result);
 _pos     := _tokens[Token].StartPos;
 _end     := _tokens[Token].EndPos;

  WHILE (( _pos < _end ) AND ( _n < 255 )) DO
   _c := _pData[_pos];
    IF (( _c = 92 ) AND ( _pos + 1 < _end ))
    THEN
     _pos := _pos + 1;
     _c   := _pData[_pos];
      CASE _c OF
        98:  _c := 8;
        102: _c := 12;
        110: _c := 10;
        114: _c := 13;
        116: _c := 9;
        117:
          // \uXXXX
         _code := 0;
          FOR _idx := 1 TO 4
          DO
            IF ( _pos + 1 < _end )
            THEN
             _pos   := _pos + 1;
             _digit := _pData[_pos];
              IF (( _digit >= 48 ) AND ( _digit <= 57 ))
              THEN
               _code := _code * 16 + ( _digit - 48 );
              ELSIF (( _digit >= 65 ) AND ( _digit <= 70 ))
              THEN
               _code := _code * 16 + ( _digit - 55 );
              ELSIF (( _digit >= 97 ) AND ( _digit <= 102 ))
              THEN
               _code := _code * 16 + ( _digit - 87 );
              END_IF
            END_IF
          END_FOR
          // UTF-8 encoding (surrogates are not combined)
          IF ( _code < 16#80 )
          THEN
           _c := UDINT_TO_BYTE(_code);
          ELSIF (( _code < 16#800 ) AND ( _n < 254 ))
          THEN
           _pResult[_n] := UDINT_TO_BYTE(16#C0 OR SHR(_code, 6));
           _n           := _n + 1;
           _c           := UDINT_TO_BYTE(16#80 OR ( _code AND 16#3F ));
          ELSIF ( _n < 253 )
          THEN
           _pResult[_n]     := UDINT_TO_BYTE(16#E0 OR SHR(_code, 12));
           _pResult[_n + 1] := UDINT_TO_BYTE(16#80 OR ( SHR(_code, 6) AND 16#3F ));
           _n               := _n + 2;
           _c               := UDINT_TO_BYTE(16#80 OR ( _code AND 16#3F ));
          ELSE
           _c := 63;
          END_IF
      ELSE
        // ", \, / and unknown escapes: the character itself
        ;
      END_CASE
    END_IF
   _pResult[_n] := _c;
   _n           := _n + 1;
   _pos         := _pos + 1;
  END_WHILE

 _pResult[_n]  := 0;
  GetString    := _result;
END_METHOD

METHOD GetStringByKey : STRING(255)
/// String value of a key ('' if not found)
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
VAR
  /// Value token
 _tok : DINT;
END_VAR
 _tok := FindKey(ObjectToken := ObjectToken, Key := Key);
  IF ( GetType(Token := _tok) = JsonTokenTypeEnum.JSON_STRING )
  THEN
    GetStringByKey := GetString(Token := _tok);
  END_IF
END_METHOD

METHOD GetType : JsonTokenTypeEnum
/// Type of a token (UNDEFINED if invalid)
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
  IF (( Token < 0 ) OR ( Token >= _tokenCount ))
  THEN
    GetType := JsonTokenTypeEnum.JSON_UNDEFINED;
  ELSE
    GetType := _tokens[Token].TokenType;
  END_IF
END_METHOD

METHOD HasKey : BOOL
/// Object has the key
VAR_INPUT
  /// Object token
  ObjectToken : DINT;
  /// Key
  Key         : STRING(64);
END_VAR
  HasKey := ( FindKey(ObjectToken := ObjectToken, Key := Key) >= 0 );
END_METHOD

METHOD IsNull : BOOL
/// Token is the literal null
VAR_INPUT
  /// Token
  Token : DINT;
END_VAR
  IF ( GetType(Token := Token) = JsonTokenTypeEnum.JSON_PRIMITIVE )
  THEN
    IsNull := ( _pData[_tokens[Token].StartPos] = 110 );
  END_IF
END_METHOD

METHOD Parse : BOOL
/// Parses a message; token 0 is the root
VAR_INPUT
  /// Message
  pData  : POINTER TO BYTE;
  /// Length in bytes
  Length : UDINT;
END_VAR
VAR
  /// Position
 _pos   : DINT;
  /// Current super token
 _super : DINT;
  /// Token index
 _tok   : DINT;
  /// Walk index
 _idx   : DINT;
  /// Loop guard
 _guard : DINT;
  /// Start of a string or primitive
 _start : DINT;
  /// Current character
 _c     : BYTE;
  /// Type of a closing bracket
 _type  : JsonTokenTypeEnum;
  /// End quote found
 _found : BOOL;
END_VAR
 _pData      := pData;
 _length     := UDINT_TO_DINT(Length);
 _tokenCount := 0;
 _errorPos   := -1;
 _super      := -1;

  IF (( pData = 0 ) OR ( _length = 0 ))
  THEN
   _errorPos := 0;
    RETURN;
  END_IF

  WHILE ( _pos < _length ) DO
   _c := _pData[_pos];

    CASE _c OF
      123, 91:
        // '{' or '['
       _tok := AllocToken();
        IF ( _tok < 0 )
        THEN
         _errorPos := _pos;
          RETURN;
        END_IF
        IF ( _super <> -1 )
        THEN
          IF ( _tokens[_super].TokenType = JsonTokenTypeEnum.JSON_OBJECT )
          THEN
            // an object or array cannot be a key
           _errorPos := _pos;
            RETURN;
          END_IF
         _tokens[_super].Size := _tokens[_super].Size + 1;
         _tokens[_tok].Parent := _super;
        END_IF
        IF ( _c = 123 )
        THEN
         _tokens[_tok].TokenType := JsonTokenTypeEnum.JSON_OBJECT;
        ELSE
         _tokens[_tok].TokenType := JsonTokenTypeEnum.JSON_ARRAY;
        END_IF
       _tokens[_tok].StartPos := _pos;
       _super                 := _tok;

      125, 93:
        // '}' or ']'
        IF ( _c = 125 )
        THEN
         _type := JsonTokenTypeEnum.JSON_OBJECT;
        ELSE
         _type := JsonTokenTypeEnum.JSON_ARRAY;
        END_IF
        IF ( _tokenCount < 1 )
        THEN
         _errorPos := _pos;
          RETURN;
        END_IF
       _idx := _tokenCount - 1;
        FOR _guard := 0 TO M2XLibraryParameter.JSON_TOKEN_MAX
        DO
          IF (( _tokens[_idx].StartPos <> -1 ) AND ( _tokens[_idx].EndPos = -1 ))
          THEN
            IF ( _tokens[_idx].TokenType <> _type )
            THEN
             _errorPos := _pos;
              RETURN;
            END_IF
           _tokens[_idx].EndPos := _pos + 1;
           _super               := _tokens[_idx].Parent;
            EXIT;
          END_IF
          IF ( _tokens[_idx].Parent = -1 )
          THEN
            IF (( _tokens[_idx].TokenType <> _type ) OR ( _super = -1 ))
            THEN
             _errorPos := _pos;
              RETURN;
            END_IF
            EXIT;
          END_IF
         _idx := _tokens[_idx].Parent;
        END_FOR

      34:
        // string
       _start := _pos + 1;
       _pos   := _pos + 1;
       _found := FALSE;
        WHILE ( _pos < _length ) DO
          IF ( _pData[_pos] = 34 )
          THEN
           _found := TRUE;
            EXIT;
          END_IF
          IF ( _pData[_pos] = 92 )
          THEN
            // skip the escaped character
           _pos := _pos + 1;
          END_IF
         _pos := _pos + 1;
        END_WHILE
        IF ( NOT _found )
        THEN
         _errorPos := _start;
          RETURN;
        END_IF
       _tok := AllocToken();
        IF ( _tok < 0 )
        THEN
         _errorPos := _pos;
          RETURN;
        END_IF
       _tokens[_tok].TokenType := JsonTokenTypeEnum.JSON_STRING;
       _tokens[_tok].StartPos  := _start;
       _tokens[_tok].EndPos    := _pos;
       _tokens[_tok].Parent    := _super;
        IF ( _super <> -1 )
        THEN
         _tokens[_super].Size := _tokens[_super].Size + 1;
        END_IF

      9, 10, 13, 32:
        // whitespace
        ;

      58:
        // ':' - the key is the new super token
       _super := _tokenCount - 1;

      44:
        // ',' - back from the key to the object
        IF ( _super <> -1 )
        THEN
          IF (( _tokens[_super].TokenType <> JsonTokenTypeEnum.JSON_ARRAY  ) AND
              ( _tokens[_super].TokenType <> JsonTokenTypeEnum.JSON_OBJECT ))
          THEN
           _super := _tokens[_super].Parent;
          END_IF
        END_IF

    ELSE
      // primitive: number, true, false, null
      IF ( _super <> -1 )
      THEN
        IF (( _tokens[_super].TokenType = JsonTokenTypeEnum.JSON_OBJECT ) OR
            (( _tokens[_super].TokenType = JsonTokenTypeEnum.JSON_STRING ) AND ( _tokens[_super].Size <> 0 )))
        THEN
         _errorPos := _pos;
          RETURN;
        END_IF
      END_IF
     _start := _pos;
      // read until a delimiter; the byte behind the message is never read
      WHILE ( _pos < _length ) DO
       _c := _pData[_pos];
        IF (( _c = 9 ) OR ( _c = 10 ) OR ( _c = 13 ) OR ( _c = 32 ) OR
            ( _c = 44 ) OR ( _c = 93 ) OR ( _c = 125 ) OR ( _c = 58 ))
        THEN
          EXIT;
        END_IF
       _pos := _pos + 1;
      END_WHILE
     _tok := AllocToken();
      IF ( _tok < 0 )
      THEN
       _errorPos := _pos;
        RETURN;
      END_IF
     _tokens[_tok].TokenType := JsonTokenTypeEnum.JSON_PRIMITIVE;
     _tokens[_tok].StartPos  := _start;
     _tokens[_tok].EndPos    := _pos;
     _tokens[_tok].Parent    := _super;
      IF ( _super <> -1 )
      THEN
       _tokens[_super].Size := _tokens[_super].Size + 1;
      END_IF
      // the loop increments the position again
     _pos := _pos - 1;
    END_CASE

   _pos := _pos + 1;
  END_WHILE

  // all objects and arrays must be closed
  FOR _idx := 0 TO _tokenCount - 1
  DO
    IF (( _tokens[_idx].StartPos <> -1 ) AND ( _tokens[_idx].EndPos = -1 ))
    THEN
     _errorPos := _tokens[_idx].StartPos;
      RETURN;
    END_IF
  END_FOR

  Parse := ( _tokenCount > 0 );
END_METHOD

PROPERTY TokenCount : DINT
/// Number of tokens of the last parse
GET
VAR
END_VAR
  TokenCount := _tokenCount;
END_GET
END_PROPERTY

METHOD TokenEquals : BOOL
/// Compares the raw text of a token with a text
VAR_INPUT
  /// Token
  Token : DINT;
  /// Text
  Text  : STRING(255);
END_VAR
VAR
  /// Length of the token
 _tokenLen : DINT;
END_VAR
  IF (( Token < 0 ) OR ( Token >= _tokenCount ))
  THEN
    RETURN;
  END_IF

 _tokenLen := _tokens[Token].EndPos - _tokens[Token].StartPos;
  IF ( UDINT_TO_DINT(StringLength(pText := ADR(Text), Size := SIZEOF(Text))) <> _tokenLen )
  THEN
    RETURN;
  END_IF

  TokenEquals := ( SysDepMemCmp(pData1  := _pData + DINT_TO_UDINT(_tokens[Token].StartPos),
                                pData2  := ADR(Text),
                                DataLen := DINT_TO_UDINT(_tokenLen)) = 0 );
END_METHOD

END_FUNCTION_BLOCK
