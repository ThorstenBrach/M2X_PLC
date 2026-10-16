/// Converts the JSON text to RequestStatusEnum (RequestStatusEnum.NONE if unknown)
FUNCTION RequestStatusFromString : RequestStatusEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestStatusFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to RequestStatusEnum (RequestStatusEnum.NONE if unknown)
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
  /// Text to convert
  Text : STRING(64);
END_VAR
  RequestStatusFromString := RequestStatusEnum.NONE;

  IF ( Text = 'PENDING' )
  THEN
    RequestStatusFromString := RequestStatusEnum.PENDING;
    RETURN;
  END_IF

  IF ( Text = 'RUNNING' )
  THEN
    RequestStatusFromString := RequestStatusEnum.RUNNING;
    RETURN;
  END_IF

  IF ( Text = 'PAUSED' )
  THEN
    RequestStatusFromString := RequestStatusEnum.PAUSED;
    RETURN;
  END_IF

  IF ( Text = 'FINISHED' )
  THEN
    RequestStatusFromString := RequestStatusEnum.FINISHED;
    RETURN;
  END_IF

  IF ( Text = 'FAILED' )
  THEN
    RequestStatusFromString := RequestStatusEnum.FAILED;
    RETURN;
  END_IF
END_FUNCTION
