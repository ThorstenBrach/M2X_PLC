/// Reads a transport order object
FUNCTION ParseTransportOrder : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ParseTransportOrder
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reads a transport order object
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
  /// Transport order
  Order  : TransportOrderData;
END_VAR
VAR_INPUT
  /// Object token
  Token : DINT;
END_VAR
VAR
  /// objectives array
 _arr : DINT;
  /// Item index
 _idx : DINT;
END_VAR
  Order.ObjectiveCount := 0;
  IF ( Parser.GetType(Token := Token) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  Order.TransportOrderId        := Parser.GetStringByKey(ObjectToken := Token, Key := 'transportOrderId');
  Order.TransportOrderUpdateId  := LINT_TO_DINT(Parser.GetLintByKey(ObjectToken := Token, Key := 'transportOrderUpdateId'));
  Order.IsObjectiveListComplete := Parser.GetBoolByKey(ObjectToken := Token, Key := 'isObjectiveListComplete');
  Order.ResourceId              := Parser.GetStringByKey(ObjectToken := Token, Key := 'resourceId');
  Order.Priority                := PriorityFromString(Parser.GetStringByKey(ObjectToken := Token, Key := 'priority'));

 _arr := Parser.FindKey(ObjectToken := Token, Key := 'objectives');
  FOR _idx := 0 TO Parser.GetSize(Token := _arr) - 1
  DO
    IF ( Order.ObjectiveCount >= M2XLibraryParameter.OBJECTIVES_MAX )
    THEN
      EXIT;
    END_IF
    IF ( ParseObjective(Parser := Parser, Objective := Order.Objectives[Order.ObjectiveCount + 1], Token := Parser.GetArrayItem(ArrayToken := _arr, Index := _idx)) )
    THEN
      Order.ObjectiveCount := Order.ObjectiveCount + 1;
    END_IF
  END_FOR

  ParseTransportOrder := ( Order.TransportOrderId <> '' );
END_FUNCTION
