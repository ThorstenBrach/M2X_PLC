/// Writes an error object
FUNCTION WriteError : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteError
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes an error object
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
  /// Error
  Error  : ErrorData;
END_VAR
VAR
  /// Reference index
 _idx : DINT;
END_VAR
  Writer.BeginObject();
  Writer.AddString(Name := 'errorType',  Value := Error.ErrorType);
  Writer.AddString(Name := 'errorLevel', Value := ErrorLevelToString(Error.ErrorLevel));
  Writer.AddStringOptional(Name := 'errorDescription', Value := Error.ErrorDescription);
  Writer.AddStringOptional(Name := 'requestId',        Value := Error.RequestId);
  IF ( Error.ErrorReferenceCount > 0 )
  THEN
    Writer.Key(Name := 'errorReferences');
    Writer.BeginArray();
    FOR _idx := 1 TO MIN(Error.ErrorReferenceCount, M2XLibraryParameter.ERROR_REFERENCES_MAX)
    DO
      Writer.BeginObject();
      Writer.AddString(Name := 'referenceKey',   Value := Error.ErrorReferences[_idx].ReferenceKey);
      Writer.AddString(Name := 'referenceValue', Value := Error.ErrorReferences[_idx].ReferenceValue);
      Writer.EndObject();
    END_FOR
    Writer.EndArray();
  END_IF
  Writer.EndObject();
  WriteError := TRUE;
END_FUNCTION
