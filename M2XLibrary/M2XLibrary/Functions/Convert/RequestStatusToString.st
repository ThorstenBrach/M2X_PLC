/// Converts RequestStatusEnum to its JSON text
FUNCTION RequestStatusToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestStatusToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts RequestStatusEnum to its JSON text
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
  Value : RequestStatusEnum;
END_VAR
  CASE Value OF
    RequestStatusEnum.NONE                            : RequestStatusToString := '';
    RequestStatusEnum.PENDING                         : RequestStatusToString := 'PENDING';
    RequestStatusEnum.RUNNING                         : RequestStatusToString := 'RUNNING';
    RequestStatusEnum.PAUSED                          : RequestStatusToString := 'PAUSED';
    RequestStatusEnum.FINISHED                        : RequestStatusToString := 'FINISHED';
    RequestStatusEnum.FAILED                          : RequestStatusToString := 'FAILED';
  ELSE
    RequestStatusToString := '';
  END_CASE
END_FUNCTION
