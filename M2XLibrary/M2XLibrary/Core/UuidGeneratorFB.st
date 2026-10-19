/// Generates random UUIDs (version 4) for request ids
FUNCTION_BLOCK UuidGeneratorFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      UuidGeneratorFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Generates random UUIDs (version 4) for request ids
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
  /// State of the xorshift generator
 _state : UDINT;
END_VAR

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

METHOD NewUuid : STRING(36)
/// Returns a new UUID, e.g. 3f2b8c1e-5d7a-4e21-9c4b-8a1f2e3d4c5b
VAR_INPUT
END_VAR
VAR
  /// Random bytes
 _bytes  : ARRAY [0..15] OF BYTE;
  /// Result
 _result : STRING(36);
  /// Pointer to the result
 _pRes   : POINTER TO BYTE;
  /// Byte index
 _idx    : DINT;
  /// Write position
 _n      : DINT;
  /// Random value
 _value  : UDINT;
END_VAR
VAR_STAT
  /// Number of seeded generators (shared by all instances, makes the seeds of
  /// generators started in the same cycle different)
 _instanceCounter : UDINT;
END_VAR
  IF ( _state = 0 )
  THEN
    // seed: system time mixed with a counter over all instances
   _instanceCounter := _instanceCounter + 1;
   _state := SysDepGetSeed() XOR ( _instanceCounter * 16#9E3779B9 );
    IF ( _state = 0 )
    THEN
     _state := 1;
    END_IF
  END_IF

  FOR _idx := 0 TO 15
  DO
    IF ( _idx MOD 4 = 0 )
    THEN
      // xorshift32
     _state := _state XOR SHL(_state, 13);
     _state := _state XOR SHR(_state, 17);
     _state := _state XOR SHL(_state, 5);
     _value := _state;
    END_IF
   _bytes[_idx] := UDINT_TO_BYTE(_value AND 16#FF);
   _value       := SHR(_value, 8);
  END_FOR

  // version 4 and RFC 4122 variant
 _bytes[6] := ( _bytes[6] AND 16#0F ) OR 16#40;
 _bytes[8] := ( _bytes[8] AND 16#3F ) OR 16#80;

 _pRes := ADR(_result);
  FOR _idx := 0 TO 15
  DO
    IF (( _idx = 4 ) OR ( _idx = 6 ) OR ( _idx = 8 ) OR ( _idx = 10 ))
    THEN
     _pRes[_n] := 45;
     _n        := _n + 1;
    END_IF
   _pRes[_n]     := HexDigit(Value := _bytes[_idx] / 16);
   _pRes[_n + 1] := HexDigit(Value := _bytes[_idx] MOD 16);
   _n            := _n + 2;
  END_FOR
 _pRes[_n] := 0;

  NewUuid := _result;
END_METHOD

END_FUNCTION_BLOCK
