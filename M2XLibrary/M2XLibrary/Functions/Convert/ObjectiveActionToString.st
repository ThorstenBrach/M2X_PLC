/// Converts ObjectiveActionEnum to its JSON text
FUNCTION ObjectiveActionToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ObjectiveActionToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts ObjectiveActionEnum to its JSON text
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
VAR_INPUT
  /// Value to convert
  Value : ObjectiveActionEnum;
END_VAR
  CASE Value OF
    ObjectiveActionEnum.NONE                            : ObjectiveActionToString := '';
    ObjectiveActionEnum.PICK                            : ObjectiveActionToString := 'PICK';
    ObjectiveActionEnum.DROP                            : ObjectiveActionToString := 'DROP';
    ObjectiveActionEnum.VIA                             : ObjectiveActionToString := 'VIA';
  ELSE
    ObjectiveActionToString := '';
  END_CASE
END_FUNCTION
