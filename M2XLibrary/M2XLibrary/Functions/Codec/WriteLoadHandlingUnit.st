/// Writes a load handling unit as JSON object
FUNCTION WriteLoadHandlingUnit : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteLoadHandlingUnit
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes a load handling unit as JSON object
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
  /// Load handling unit
  Lhu    : LoadHandlingUnitData;
END_VAR
  Writer.BeginObject();
  Writer.AddStringOptional(Name := 'loadUnitId', Value := Lhu.LoadUnitId);
  Writer.AddString(Name := 'loadHandlingUnitType', Value := Lhu.LoadHandlingUnitType);
  IF ( Lhu.WeightValid )
  THEN
    Writer.AddNumber(Name := 'weight', Value := Lhu.Weight);
  END_IF
  IF ( Lhu.DimensionsValid )
  THEN
    Writer.AddNumber(Name := 'height', Value := Lhu.Height);
    Writer.AddNumber(Name := 'width',  Value := Lhu.Width);
    Writer.AddNumber(Name := 'length', Value := Lhu.Length);
  END_IF
  Writer.AddStringOptional(Name := 'outerPackaging', Value := Lhu.OuterPackaging);
  IF ( Lhu.SymmetricalValid )
  THEN
    Writer.AddBool(Name := 'symmetrical', Value := Lhu.Symmetrical);
  END_IF
  Writer.EndObject();
  WriteLoadHandlingUnit := TRUE;
END_FUNCTION
