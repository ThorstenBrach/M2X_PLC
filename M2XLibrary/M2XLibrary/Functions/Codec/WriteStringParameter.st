/// Writes one request parameter {"key":Key,"value":Value} (nothing if Value is empty)
FUNCTION WriteStringParameter : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteStringParameter
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes one request parameter {"key":Key,"value":Value} (nothing if Value is empty)
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
  /// JSON writer
  Writer : JsonWriterFB;
END_VAR
VAR_INPUT
  /// Key of the parameter
  Key   : STRING(64);
  /// Value of the parameter
  Value : STRING(255);
END_VAR
  IF ( Value = '' )
  THEN
    RETURN;
  END_IF

  Writer.BeginObject();
  Writer.AddString(Name := 'key',   Value := Key);
  Writer.AddString(Name := 'value', Value := Value);
  Writer.EndObject();
  WriteStringParameter := TRUE;
END_FUNCTION
