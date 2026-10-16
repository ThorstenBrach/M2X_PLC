/// Reads an objective
FUNCTION ParseObjective : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ParseObjective
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Reads an objective
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
  Parser    : JsonParserFB;
  /// Objective
  Objective : ObjectiveData;
END_VAR
VAR_INPUT
  /// Object token
  Token : DINT;
END_VAR
  IF ( Parser.GetType(Token := Token) <> JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    RETURN;
  END_IF

  Objective.ObjectiveId             := Parser.GetStringByKey(ObjectToken := Token, Key := 'objectiveId');
  Objective.SequenceId              := LINT_TO_DINT(Parser.GetLintByKey(ObjectToken := Token, Key := 'sequenceId'));
  Objective.Destination             := Parser.GetStringByKey(ObjectToken := Token, Key := 'destination');
  Objective.ObjectiveAction                  := ObjectiveActionFromString(Parser.GetStringByKey(ObjectToken := Token, Key := 'action'));
  Objective.DisplayName             := Parser.GetStringByKey(ObjectToken := Token, Key := 'displayName');
  Objective.EarliestCompletionTime  := Parser.GetStringByKey(ObjectToken := Token, Key := 'earliestCompletionTime');
  Objective.LatestCompletionTime    := Parser.GetStringByKey(ObjectToken := Token, Key := 'latestCompletionTime');
  Objective.EstimatedCompletionTime := Parser.GetStringByKey(ObjectToken := Token, Key := 'estimatedCompletionTime');
  Objective.LoadHandlingUnitValid   := ParseLoadHandlingUnit(Parser := Parser,
                                                             Lhu    := Objective.LoadHandlingUnit,
                                                             Token  := Parser.FindKey(ObjectToken := Token, Key := 'loadHandlingUnit'));

  ParseObjective := ( Objective.ObjectiveId <> '' );
END_FUNCTION
