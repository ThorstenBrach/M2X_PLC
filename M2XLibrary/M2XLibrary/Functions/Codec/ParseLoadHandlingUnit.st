/// Reads a load handling unit from a JSON object (also nested as {"loadHandlingUnit":{...}})
FUNCTION ParseLoadHandlingUnit : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ParseLoadHandlingUnit
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reads a load handling unit from a JSON object (also nested as {"loadHandlingUnit":{...}})
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
  /// Load handling unit
  Lhu    : LoadHandlingUnitData;
END_VAR
VAR_INPUT
  /// Object token
  Token : DINT;
END_VAR
VAR
  /// Object with the LHU fields
 _obj : DINT;
END_VAR
 _obj := Token;
  IF ( Parser.GetType(Token := _obj) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  IF ( Parser.GetType(Token := Parser.FindKey(ObjectToken := _obj, Key := 'loadHandlingUnit')) = JsonTokenTypeEnum.JSON_OBJECT )
  THEN
   _obj := Parser.FindKey(ObjectToken := _obj, Key := 'loadHandlingUnit');
  END_IF

  Lhu.LoadUnitId           := Parser.GetStringByKey(ObjectToken := _obj, Key := 'loadUnitId');
  Lhu.LoadHandlingUnitType := Parser.GetStringByKey(ObjectToken := _obj, Key := 'loadHandlingUnitType');
  Lhu.OuterPackaging       := Parser.GetStringByKey(ObjectToken := _obj, Key := 'outerPackaging');

  Lhu.WeightValid := Parser.HasKey(ObjectToken := _obj, Key := 'weight');
  Lhu.Weight      := Parser.GetLRealByKey(ObjectToken := _obj, Key := 'weight');

  Lhu.DimensionsValid := Parser.HasKey(ObjectToken := _obj, Key := 'height') OR
                         Parser.HasKey(ObjectToken := _obj, Key := 'width')  OR
                         Parser.HasKey(ObjectToken := _obj, Key := 'length');
  Lhu.Height := Parser.GetLRealByKey(ObjectToken := _obj, Key := 'height');
  Lhu.Width  := Parser.GetLRealByKey(ObjectToken := _obj, Key := 'width');
  Lhu.Length := Parser.GetLRealByKey(ObjectToken := _obj, Key := 'length');

  Lhu.SymmetricalValid := Parser.HasKey(ObjectToken := _obj, Key := 'symmetrical');
  Lhu.Symmetrical      := Parser.GetBoolByKey(ObjectToken := _obj, Key := 'symmetrical');

  ParseLoadHandlingUnit := TRUE;
END_FUNCTION
