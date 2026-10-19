/// Tests of the JSON writer and parser and the core functions
FUNCTION_BLOCK JsonTestFB EXTENDS FB_TestSuite
// -------------------------------------------------------------------------
//  M2X Library Tests
// -------------------------------------------------------------------------
//
//  Object:      JsonTestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Tests of the JSON writer and parser and the core functions
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
  /// JSON writer
 _writer : JsonWriterFB;
  /// JSON parser
 _parser : JsonParserFB;
  /// UUID generator
 _uuid   : UuidGeneratorFB;
  /// Test message
 _text   : STRING(255);
  /// Parameters for the round trip
 _params : RequestParameterData;
  /// Parsed parameters
 _parsed : RequestParameterData;
END_VAR
  JSON_001_WriterObject();
  JSON_002_WriterEscape();
  JSON_003_WriterNumber();
  JSON_004_ParserBasics();
  JSON_005_ParserUnescape();
  JSON_006_ParserInvalid();
  JSON_007_ParserObjectKeys();
  JSON_008_TopicMatches();
  JSON_009_BuildTopic();
  JSON_010_Uuid();
  JSON_011_Timestamp();
  JSON_012_EnumConvert();
  JSON_013_ParameterRoundTrip();

METHOD JSON_001_WriterObject
/// Writer: object with all value types
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_001_WriterObject');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _writer.Reset();
 _writer.BeginObject();
 _writer.AddString(Name := 'a', Value := 'b');
 _writer.AddInteger(Name := 'n', Value := -5);
 _writer.AddBool(Name := 't', Value := TRUE);
 _writer.Key(Name := 'arr');
 _writer.BeginArray();
 _writer.ValueInteger(Value := 1);
 _writer.ValueInteger(Value := 2);
 _writer.BeginObject();
 _writer.EndObject();
 _writer.EndArray();
 _writer.Key(Name := 'z');
 _writer.ValueNull();
 _writer.EndObject();

  AssertEquals_STRING(Expected := '{"a":"b","n":-5,"t":true,"arr":[1,2,{}],"z":null}', Actual := _writer.GetText(), Message := 'writer output');
  AssertFalse(Condition := _writer.Overflow, Message := 'no overflow');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_002_WriterEscape
/// Writer: escaping of quotes, backslash and control characters
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_002_WriterEscape');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _writer.Reset();
 _writer.BeginObject();
 _writer.AddString(Name := 'q', Value := 'x"y\z$N$T');
 _writer.EndObject();

  AssertEquals_STRING(Expected := '{"q":"x\"y\\z\n\t"}', Actual := _writer.GetText(), Message := 'escaped output');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_003_WriterNumber
/// Writer: numbers and optional strings
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_003_WriterNumber');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _writer.Reset();
 _writer.BeginObject();
 _writer.AddNumber(Name := 'v', Value := 1.5);
 _writer.AddStringOptional(Name := 'empty', Value := '');
 _writer.AddStringOptional(Name := 'set',   Value := 'x');
 _writer.EndObject();

  AssertEquals_STRING(Expected := '{"v":1.5,"set":"x"}', Actual := _writer.GetText(), Message := 'number output');
  AssertTrue(Condition := _writer.EqualsText(Text := '{"v":1.5,"set":"x"}'), Message := 'EqualsText');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_004_ParserBasics
/// Parser: objects, arrays, primitives and lookups
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
VAR
  /// Array token
 _arr : DINT;
END_VAR
  TEST('JSON_004_ParserBasics');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _text := '{"a":"b","n":-12,"f":2.5,"t":true,"z":null,"o":{"k":"v","n2":{"d":4}},"arr":[1,"x",{"y":3}],"last":"end"}';
  AssertTrue(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'parse ok');

  AssertEquals_STRING(Expected := 'b', Actual := _parser.GetStringByKey(ObjectToken := 0, Key := 'a'), Message := 'string');
  AssertEquals_LINT(Expected := -12, Actual := _parser.GetLintByKey(ObjectToken := 0, Key := 'n'), Message := 'integer');
  AssertEquals_LREAL(Expected := 2.5, Actual := _parser.GetLRealByKey(ObjectToken := 0, Key := 'f'), Delta := 0.0001, Message := 'number');
  AssertTrue(Condition := _parser.GetBoolByKey(ObjectToken := 0, Key := 't'), Message := 'bool');
  AssertTrue(Condition := _parser.IsNull(Token := _parser.FindKey(ObjectToken := 0, Key := 'z')), Message := 'null');
  AssertEquals_STRING(Expected := 'v', Actual := _parser.GetStringByKey(ObjectToken := _parser.FindKey(ObjectToken := 0, Key := 'o'), Key := 'k'), Message := 'nested');
  AssertEquals_LINT(Expected := 4, Actual := _parser.GetLintByKey(ObjectToken := _parser.FindKey(ObjectToken := _parser.FindKey(ObjectToken := 0, Key := 'o'), Key := 'n2'), Key := 'd'), Message := 'nested 2');
  AssertEquals_DINT(Expected := -1, Actual := _parser.FindKey(ObjectToken := 0, Key := 'k'), Message := 'nested key not found at root');
  AssertEquals_DINT(Expected := -1, Actual := _parser.FindKey(ObjectToken := 0, Key := 'missing'), Message := 'missing key');
  AssertEquals_STRING(Expected := 'end', Actual := _parser.GetStringByKey(ObjectToken := 0, Key := 'last'), Message := 'key after nested objects');

 _arr := _parser.FindKey(ObjectToken := 0, Key := 'arr');
  AssertEquals_DINT(Expected := 3, Actual := _parser.GetSize(Token := _arr), Message := 'array size');
  AssertEquals_LINT(Expected := 1, Actual := _parser.GetLint(Token := _parser.GetArrayItem(ArrayToken := _arr, Index := 0)), Message := 'item 0');
  AssertEquals_STRING(Expected := 'x', Actual := _parser.GetString(Token := _parser.GetArrayItem(ArrayToken := _arr, Index := 1)), Message := 'item 1');
  AssertEquals_LINT(Expected := 3, Actual := _parser.GetLintByKey(ObjectToken := _parser.GetArrayItem(ArrayToken := _arr, Index := 2), Key := 'y'), Message := 'item 2');
  AssertEquals_DINT(Expected := -1, Actual := _parser.GetArrayItem(ArrayToken := _arr, Index := 3), Message := 'item 3 missing');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_005_ParserUnescape
/// Parser: escape sequences and \u
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_005_ParserUnescape');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _text := '{"s":"a\"b\\c\nd\u00e4"}';
  AssertTrue(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'parse ok');
  AssertEquals_STRING(Expected := 'a"b\c$Nd$C3$A4', Actual := _parser.GetStringByKey(ObjectToken := 0, Key := 's'), Message := 'unescaped');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_006_ParserInvalid
/// Parser: incomplete and invalid messages are rejected
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_006_ParserInvalid');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _text := '{"a":1';
  AssertFalse(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'unclosed object');
 _text := '[1,2}';
  AssertFalse(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'wrong bracket');
 _text := '{"a":"open}';
  AssertFalse(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'unclosed string');
  AssertFalse(Condition := _parser.Parse(pData := ADR(_text), Length := 0), Message := 'empty');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_007_ParserObjectKeys
/// Parser: iteration over object keys
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
VAR
  /// Key token
 _key : DINT;
END_VAR
  TEST('JSON_007_ParserObjectKeys');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _text := '{"first":{"x":1},"second":[1,2],"third":"3"}';
  AssertTrue(Condition := _parser.Parse(pData := ADR(_text), Length := StringLength(pText := ADR(_text), Size := SIZEOF(_text))), Message := 'parse ok');
  AssertEquals_DINT(Expected := 3, Actual := _parser.GetSize(Token := 0), Message := 'key count');
 _key := _parser.GetObjectKey(ObjectToken := 0, Index := 1);
  AssertEquals_STRING(Expected := 'second', Actual := _parser.GetString(Token := _key), Message := 'key 1');
  AssertEquals_DINT(Expected := 2, Actual := _parser.GetSize(Token := _key + 1), Message := 'value of key 1');
 _key := _parser.GetObjectKey(ObjectToken := 0, Index := 2);
  AssertEquals_STRING(Expected := '3', Actual := _parser.GetString(Token := _key + 1), Message := 'value of key 2');
  AssertEquals_DINT(Expected := -1, Actual := _parser.GetObjectKey(ObjectToken := 0, Index := 3), Message := 'no key 3');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_008_TopicMatches
/// MQTT topic filter matching
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_008_TopicMatches');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertTrue(Condition := TopicMatches(Filter := 'lhs/v1/a/state', Topic := 'lhs/v1/a/state'), Message := 'exact');
  AssertFalse(Condition := TopicMatches(Filter := 'lhs/v1/a/state', Topic := 'lhs/v1/b/state'), Message := 'other entity');
  AssertTrue(Condition := TopicMatches(Filter := 'lhs/v1/+/state', Topic := 'lhs/v1/b/state'), Message := 'plus');
  AssertFalse(Condition := TopicMatches(Filter := 'lhs/v1/+/state', Topic := 'lhs/v1/b/factsheet'), Message := 'plus mismatch');
  AssertTrue(Condition := TopicMatches(Filter := 'lhs/#', Topic := 'lhs/v1/b/factsheet'), Message := 'hash');
  AssertFalse(Condition := TopicMatches(Filter := 'lhs/v1/a', Topic := 'lhs/v1/a/state'), Message := 'shorter filter');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_009_BuildTopic
/// Topic of an endpoint
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_009_BuildTopic');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertEquals_STRING(Expected := 'lhs/v1/lhs_1/state',
                      Actual   := BuildTopic(Config := MakeConfig(InterfaceName := 'lhs', EntityName := 'lhs_1'), Topic := M2XLibraryConstants.TOPIC_STATE),
                      Message  := 'state topic');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_010_Uuid
/// UUID format (version 4) and uniqueness, also between generators started in the same cycle
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
  /// Second generator (seeded in the same cycle as _uuid)
 _uuid2    : UuidGeneratorFB;
END_VAR
VAR
  /// First UUID
 _a : STRING(36);
  /// Second UUID
 _b : STRING(36);
  /// UUID of the second generator
 _c : STRING(36);
END_VAR
  TEST('JSON_010_Uuid');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _a := _uuid.NewUuid();
 _c := _uuid2.NewUuid();
 _b := _uuid.NewUuid();
  AssertEquals_INT(Expected := 36, Actual := LEN(_a), Message := 'length');
  AssertEquals_BYTE(Expected := 45, Actual := _a[8], Message := 'dash 1');
  AssertEquals_BYTE(Expected := 52, Actual := _a[14], Message := 'version 4');
  AssertTrue(Condition := ( _a <> _b ), Message := 'unique');
  AssertTrue(Condition := ( _a <> _c ), Message := 'unique between two generators of the same cycle');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_011_Timestamp
/// Timestamp in ISO8601 format
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
VAR
  /// Timestamp
 _ts : STRING(32);
END_VAR
  TEST('JSON_011_Timestamp');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _ts := GetTimestamp();
  AssertEquals_INT(Expected := 24, Actual := LEN(_ts), Message := CONCAT('length of ', _ts));
  AssertEquals_BYTE(Expected := 84, Actual := _ts[10], Message := 'T');
  AssertEquals_BYTE(Expected := 90, Actual := _ts[23], Message := 'Z');
  AssertEquals_BYTE(Expected := 46, Actual := _ts[19], Message := 'milliseconds');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_012_EnumConvert
/// Enum to JSON text and back
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
  TEST('JSON_012_EnumConvert');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

  AssertEquals_STRING(Expected := 'requestLoadTransfer', Actual := RequestTypeToString(RequestTypeEnum.REQUEST_LOAD_TRANSFER), Message := 'request type to string');
  AssertTrue(Condition := ( RequestTypeFromString('requestCancel') = RequestTypeEnum.REQUEST_CANCEL ), Message := 'request type from string');
  AssertTrue(Condition := ( RequestTypeFromString('requestFoo') = RequestTypeEnum.UNKNOWN ), Message := 'unknown request type');
  AssertEquals_STRING(Expected := 'CONNECTION_BROKEN', Actual := ConnectionStateToString(ConnectionStateEnum.CONNECTION_BROKEN), Message := 'connection state');
  AssertTrue(Condition := ( RequestStatusFromString('PAUSED') = RequestStatusEnum.PAUSED ), Message := 'status from string');
  AssertEquals_STRING(Expected := '', Actual := LoadActionToString(LoadActionEnum.NONE), Message := 'NONE is empty');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

METHOD JSON_013_ParameterRoundTrip
/// Request parameters: write and read back
VAR_INPUT
END_VAR
VAR_INST
  /// Test is finished
 _finished : BOOL;
END_VAR
VAR
  /// Item index
 _i    : DINT;
  /// Item token
 _item : DINT;
END_VAR
  TEST('JSON_013_ParameterRoundTrip');
  IF ( _finished )
  THEN
    RETURN;
  END_IF

 _params.LoadHandlingSessionId                 := 'S-1';
 _params.LoadHandlingPointId                   := 'LHP1';
 _params.LoadAction                            := LoadActionEnum.DROP;
 _params.ActiveLoadTransferDevice              := LoadTransferDeviceEnum.LHS;
 _params.LoadHandlingUnitValid                 := TRUE;
 _params.LoadHandlingUnit.LoadHandlingUnitType := 'euro_pallet';
 _params.LoadHandlingUnit.WeightValid          := TRUE;
 _params.LoadHandlingUnit.Weight               := 250.0;
 _params.IsCanceledValid                       := TRUE;
 _params.IsCanceled                            := TRUE;

 _writer.Reset();
 _writer.BeginArray();
  WriteRequestParameterItems(Writer := _writer, Parameters := _params);
 _writer.EndArray();

  AssertTrue(Condition := _parser.Parse(pData := _writer.Data, Length := _writer.Length), Message := 'parse ok');
  AssertEquals_DINT(Expected := 6, Actual := _parser.GetSize(Token := 0), Message := 'parameter count');

  FOR _i := 0 TO _parser.GetSize(Token := 0) - 1
  DO
   _item := _parser.GetArrayItem(ArrayToken := 0, Index := _i);
    ParseRequestParameter(Parser     := _parser,
                          Parameters := _parsed,
                          Key        := _parser.GetStringByKey(ObjectToken := _item, Key := 'key'),
                          ValueToken := _parser.FindKey(ObjectToken := _item, Key := 'value'));
  END_FOR

  AssertEquals_STRING(Expected := 'S-1', Actual := _parsed.LoadHandlingSessionId, Message := 'session');
  AssertEquals_STRING(Expected := 'LHP1', Actual := _parsed.LoadHandlingPointId, Message := 'point');
  AssertTrue(Condition := ( _parsed.LoadAction = LoadActionEnum.DROP ), Message := 'load action');
  AssertTrue(Condition := ( _parsed.ActiveLoadTransferDevice = LoadTransferDeviceEnum.LHS ), Message := 'device');
  AssertTrue(Condition := _parsed.LoadHandlingUnitValid, Message := 'lhu valid');
  AssertEquals_STRING(Expected := 'euro_pallet', Actual := _parsed.LoadHandlingUnit.LoadHandlingUnitType, Message := 'lhu type');
  AssertEquals_LREAL(Expected := 250.0, Actual := _parsed.LoadHandlingUnit.Weight, Delta := 0.001, Message := 'lhu weight');
  AssertTrue(Condition := _parsed.IsCanceledValid AND _parsed.IsCanceled, Message := 'isCanceled');
  TEST_FINISHED();
 _finished := TRUE;
END_METHOD

END_FUNCTION_BLOCK
