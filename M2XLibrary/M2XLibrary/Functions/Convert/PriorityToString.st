/// Converts PriorityEnum to its JSON text
FUNCTION PriorityToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      PriorityToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts PriorityEnum to its JSON text
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
  Value : PriorityEnum;
END_VAR
  CASE Value OF
    PriorityEnum.NONE                            : PriorityToString := '';
    PriorityEnum.VERY_LOW                        : PriorityToString := 'VERY_LOW';
    PriorityEnum.LOW                             : PriorityToString := 'LOW';
    PriorityEnum.MEDIUM                          : PriorityToString := 'MEDIUM';
    PriorityEnum.HIGH                            : PriorityToString := 'HIGH';
    PriorityEnum.VERY_HIGH                       : PriorityToString := 'VERY_HIGH';
  ELSE
    PriorityToString := '';
  END_CASE
END_FUNCTION
