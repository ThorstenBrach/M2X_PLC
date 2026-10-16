/// Writes an objective (order: earliest/latest time, state: estimated time)
FUNCTION WriteObjective : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteObjective
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes an objective (order: earliest/latest time, state: estimated time)
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
  Writer    : JsonWriterFB;
  /// Objective
  Objective : ObjectiveData;
END_VAR
VAR_INPUT
  /// Write as objectiveState
  IsState : BOOL;
END_VAR
  Writer.BeginObject();
  Writer.AddString(Name := 'objectiveId', Value := Objective.ObjectiveId);
  Writer.AddInteger(Name := 'sequenceId', Value := Objective.SequenceId);
  Writer.AddString(Name := 'destination', Value := Objective.Destination);
  Writer.AddString(Name := 'action',      Value := ObjectiveActionToString(Objective.ObjectiveAction));
  Writer.AddStringOptional(Name := 'displayName', Value := Objective.DisplayName);
  IF ( Objective.LoadHandlingUnitValid )
  THEN
    Writer.Key(Name := 'loadHandlingUnit');
    WriteLoadHandlingUnit(Writer := Writer, Lhu := Objective.LoadHandlingUnit);
  END_IF
  IF ( IsState )
  THEN
    Writer.AddStringOptional(Name := 'estimatedCompletionTime', Value := Objective.EstimatedCompletionTime);
  ELSE
    Writer.AddStringOptional(Name := 'earliestCompletionTime', Value := Objective.EarliestCompletionTime);
    Writer.AddStringOptional(Name := 'latestCompletionTime',   Value := Objective.LatestCompletionTime);
  END_IF
  Writer.EndObject();
  WriteObjective := TRUE;
END_FUNCTION
