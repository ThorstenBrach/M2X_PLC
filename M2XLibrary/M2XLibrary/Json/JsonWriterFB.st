/// Writes a JSON message into an internal buffer
FUNCTION_BLOCK JsonWriterFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      JsonWriterFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes a JSON message into an internal buffer
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
  /// Message buffer (always null-terminated)
 _buffer   : ARRAY [0..M2XLibraryParameter.MESSAGE_SIZE_MAX - 1] OF BYTE;
  /// Current length
 _length   : UDINT;
  /// Buffer was too small
 _overflow : BOOL;
  /// Current nesting depth
 _depth    : DINT;
  /// No element written yet at the depth
 _first    : ARRAY [0..M2XLibraryParameter.JSON_DEPTH_MAX] OF BOOL;
  /// A key was written, the value follows
 _afterKey : BOOL;
END_VAR
END_FUNCTION_BLOCK

METHOD AddBool
/// Writes "Name":true/false
VAR_INPUT
  /// Name of the key
  Name  : STRING(255);
  /// Value
  Value : BOOL;
END_VAR
  Key(Name := Name);
  ValueBool(Value := Value);
END_METHOD

METHOD AddInteger
/// Writes "Name":Value (integer)
VAR_INPUT
  /// Name of the key
  Name  : STRING(255);
  /// Value
  Value : LINT;
END_VAR
  Key(Name := Name);
  ValueInteger(Value := Value);
END_METHOD

METHOD AddNumber
/// Writes "Name":Value (number)
VAR_INPUT
  /// Name of the key
  Name  : STRING(255);
  /// Value
  Value : LREAL;
END_VAR
  Key(Name := Name);
  ValueNumber(Value := Value);
END_METHOD

METHOD AddString
/// Writes "Name":"Value"
VAR_INPUT
  /// Name of the key
  Name  : STRING(255);
  /// Value
  Value : STRING(255);
END_VAR
  Key(Name := Name);
  ValueString(Value := Value);
END_METHOD

METHOD AddStringOptional
/// Writes "Name":"Value" only if Value is not empty
VAR_INPUT
  /// Name of the key
  Name  : STRING(255);
  /// Value
  Value : STRING(255);
END_VAR
  IF ( Value <> '' )
  THEN
    Key(Name := Name);
    ValueString(Value := Value);
  END_IF
END_METHOD

METHOD PRIVATE AppendByte
/// Appends one byte
VAR_INPUT
  /// Byte to append
  Value : BYTE;
END_VAR
  IF ( _length < SIZEOF(_buffer) - 1 )
  THEN
   _buffer[_length] := Value;
   _length          := _length + 1;
   _buffer[_length] := 0;
  ELSE
   _overflow := TRUE;
  END_IF
END_METHOD

METHOD PRIVATE AppendEscaped
/// Appends a text as JSON string with quotes and escaping
VAR_INPUT
  /// Text
  Text : STRING(255);
END_VAR
VAR
  /// Position in the text
 _idx : UDINT;
  /// Current character
 _c   : BYTE;
END_VAR
  AppendByte(Value := 34);

  WHILE (( _idx < 255 ) AND ( Text[_idx] <> 0 )) DO
   _c := Text[_idx];
    CASE _c OF
      34, 92:
        AppendByte(Value := 92);
        AppendByte(Value := _c);
      8:
        AppendByte(Value := 92);
        AppendByte(Value := 98);
      9:
        AppendByte(Value := 92);
        AppendByte(Value := 116);
      10:
        AppendByte(Value := 92);
        AppendByte(Value := 110);
      12:
        AppendByte(Value := 92);
        AppendByte(Value := 102);
      13:
        AppendByte(Value := 92);
        AppendByte(Value := 114);
    ELSE
      IF ( _c < 32 )
      THEN
        // other control characters as \u00XX
        AppendText(Text := '\u00');
        AppendByte(Value := HexDigit(_c / 16));
        AppendByte(Value := HexDigit(_c MOD 16));
      ELSE
        AppendByte(Value := _c);
      END_IF
    END_CASE
   _idx := _idx + 1;
  END_WHILE

  AppendByte(Value := 34);
END_METHOD

METHOD PRIVATE AppendText
/// Appends a text without escaping
VAR_INPUT
  /// Text
  Text : STRING(255);
END_VAR
VAR
  /// Position in the text
 _idx : UDINT;
END_VAR
  WHILE (( _idx < 255 ) AND ( Text[_idx] <> 0 )) DO
    AppendByte(Value := Text[_idx]);
   _idx := _idx + 1;
  END_WHILE
END_METHOD

METHOD PRIVATE BeforeValue
/// Writes the comma before a value if needed
VAR_INPUT
END_VAR
  IF ( _afterKey )
  THEN
   _afterKey := FALSE;
    RETURN;
  END_IF

  IF ( NOT _first[_depth] )
  THEN
    AppendByte(Value := 44);
  END_IF
 _first[_depth] := FALSE;
END_METHOD

METHOD BeginArray
/// Starts an array
VAR_INPUT
END_VAR
  BeforeValue();
  AppendByte(Value := 91);
  OpenLevel();
END_METHOD

METHOD BeginObject
/// Starts an object
VAR_INPUT
END_VAR
  BeforeValue();
  AppendByte(Value := 123);
  OpenLevel();
END_METHOD

METHOD PRIVATE CloseLevel
/// Closes a nesting level
VAR_INPUT
END_VAR
  IF ( _depth > 0 )
  THEN
   _depth := _depth - 1;
  END_IF
END_METHOD

PROPERTY Data : POINTER TO BYTE
/// Pointer to the message
GET
VAR
END_VAR
  Data := ADR(_buffer);
END_GET
END_PROPERTY

METHOD EndArray
/// Ends an array
VAR_INPUT
END_VAR
  AppendByte(Value := 93);
  CloseLevel();
END_METHOD

METHOD EndObject
/// Ends an object
VAR_INPUT
END_VAR
  AppendByte(Value := 125);
  CloseLevel();
END_METHOD

METHOD EqualsText : BOOL
/// Compares the complete message with a text
VAR_INPUT
  /// Expected text
  Text : STRING(255);
END_VAR
VAR
  /// Length of the text
 _textLen : UDINT;
END_VAR
 _textLen := StringLength(pText := ADR(Text), Size := SIZEOF(Text));
  IF ( _textLen <> _length )
  THEN
    RETURN;
  END_IF

  EqualsText := ( SysDepMemCmp(pData1 := ADR(Text), pData2 := ADR(_buffer), DataLen := _length) = 0 );
END_METHOD

METHOD GetText : STRING(255)
/// Returns the first 255 characters of the message (diagnosis, tests)
VAR_INPUT
END_VAR
VAR
  /// Bytes to copy
 _n    : UDINT;
  /// Result
 _text : STRING(255);
END_VAR
 _n := MIN(_length, 255);
  SysDepMemCpy(pDest := ADR(_text), pSrc := ADR(_buffer), DataLen := _n);
 _text[_n]  := 0;
  GetText   := _text;
END_METHOD

METHOD PRIVATE HexDigit : BYTE
/// ASCII code of a hex digit
VAR_INPUT
  /// Value 0..15
  Value : BYTE;
END_VAR
  IF ( Value < 10 )
  THEN
    HexDigit := 48 + Value;
  ELSE
    HexDigit := 87 + Value;
  END_IF
END_METHOD

METHOD Key
/// Writes a key, the value must follow
VAR_INPUT
  /// Name of the key
  Name : STRING(255);
END_VAR
  BeforeValue();
  AppendEscaped(Text := Name);
  AppendByte(Value := 58);
 _afterKey := TRUE;
END_METHOD

PROPERTY Length : UDINT
/// Length of the message in bytes
GET
VAR
END_VAR
  Length := _length;
END_GET
END_PROPERTY

METHOD PRIVATE OpenLevel
/// Opens a nesting level
VAR_INPUT
END_VAR
  IF ( _depth < M2XLibraryParameter.JSON_DEPTH_MAX )
  THEN
   _depth         := _depth + 1;
   _first[_depth] := TRUE;
  ELSE
   _overflow := TRUE;
  END_IF
END_METHOD

PROPERTY Overflow : BOOL
/// Buffer was too small (message incomplete)
GET
VAR
END_VAR
  Overflow := _overflow;
END_GET
END_PROPERTY

METHOD Reset
/// Clears the buffer
VAR_INPUT
END_VAR
 _length    := 0;
 _overflow  := FALSE;
 _depth     := 0;
 _afterKey  := FALSE;
 _first[0]  := TRUE;
 _buffer[0] := 0;
END_METHOD

METHOD ValueBool
/// Writes a boolean value
VAR_INPUT
  /// Value
  Value : BOOL;
END_VAR
  BeforeValue();
  IF ( Value )
  THEN
    AppendText(Text := 'true');
  ELSE
    AppendText(Text := 'false');
  END_IF
END_METHOD

METHOD ValueInteger
/// Writes an integer value
VAR_INPUT
  /// Value
  Value : LINT;
END_VAR
  BeforeValue();
  AppendText(Text := LINT_TO_STRING(Value));
END_METHOD

METHOD ValueNull
/// Writes null
VAR_INPUT
END_VAR
  BeforeValue();
  AppendText(Text := 'null');
END_METHOD

METHOD ValueNumber
/// Writes a number value (null if not finite)
VAR_INPUT
  /// Value
  Value : LREAL;
END_VAR
  BeforeValue();
  IF ( SysDepIsValidLReal(Value := Value) )
  THEN
    AppendText(Text := LREAL_TO_STRING(Value));
  ELSE
    AppendText(Text := 'null');
  END_IF
END_METHOD

METHOD ValueRaw
/// Writes an already serialized JSON value (object, array ...) unchanged
VAR_INPUT
  /// Serialized JSON
  pData  : POINTER TO BYTE;
  /// Length in bytes
  Length : UDINT;
END_VAR
  BeforeValue();
  IF ( _length + Length >= SIZEOF(_buffer) )
  THEN
   _overflow := TRUE;
    RETURN;
  END_IF

  SysDepMemCpy(pDest := ADR(_buffer) + _length, pSrc := pData, DataLen := Length);
 _length         := _length + Length;
 _buffer[_length] := 0;
END_METHOD

METHOD ValueString
/// Writes a string value
VAR_INPUT
  /// Value
  Value : STRING(255);
END_VAR
  BeforeValue();
  AppendEscaped(Text := Value);
END_METHOD
