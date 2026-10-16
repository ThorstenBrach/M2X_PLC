/// Sends one request with a client and waits for FINISHED or FAILED (PLCopen behaviour)
FUNCTION_BLOCK RequestFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Sends one request with a client and waits for FINISHED or FAILED (PLCopen behaviour)
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
  /// Rising edge sends the request
  Execute     : BOOL;
  /// Request type
  RequestType : RequestTypeEnum;
  /// Request description (optional)
  Description : STRING(255);
  /// Timeout until FINISHED or FAILED
  Timeout     : TIME := T#30S;
END_VAR
VAR_IN_OUT
  /// Client of the target entity
  Client     : ClientBaseFB;
  /// Request parameters
  Parameters : RequestParameterData;
END_VAR
VAR_OUTPUT
  /// Request finished
  Done              : BOOL;
  /// Request is running
  Busy              : BOOL;
  /// Request failed, timed out or could not be sent
  Error             : BOOL;
  /// Reason of the error: SEND_FAILED, REQUEST_FAILED, TIMEOUT
  ErrorText         : STRING(32);
  /// Last status reported by the entity
  Status            : RequestStatusEnum;
  /// Id of the request
  RequestId         : STRING(64);
  /// Result description reported by the entity
  ResultDescription : STRING(255);
END_VAR
VAR
  /// Execute of the last cycle
 _execute : BOOL;
  /// Timeout timer
 _timer   : TON;
END_VAR
  // Rising edge: send
  IF (( Execute ) AND ( NOT _execute ))
  THEN
    Done              := FALSE;
    Error             := FALSE;
    ErrorText         := '';
    Status            := RequestStatusEnum.NONE;
    ResultDescription := '';
    RequestId         := Client.SendRequest(RequestType := RequestType, Description := Description, Parameters := Parameters);
    IF ( RequestId = '' )
    THEN
      Error     := TRUE;
      ErrorText := 'SEND_FAILED';
    ELSE
      Busy := TRUE;
     _timer(IN := FALSE);
    END_IF
  END_IF
 _execute := Execute;

  IF ( Busy )
  THEN
    Status            := Client.GetRequestStatus(RequestId := RequestId);
    ResultDescription := Client.GetResultDescription(RequestId := RequestId);
   _timer(IN := TRUE, PT := Timeout);
    IF ( Status = RequestStatusEnum.FINISHED )
    THEN
      Done := TRUE;
      Busy := FALSE;
    ELSIF ( Status = RequestStatusEnum.FAILED )
    THEN
      Error     := TRUE;
      ErrorText := 'REQUEST_FAILED';
      Busy      := FALSE;
    ELSIF ( _timer.Q )
    THEN
      Error     := TRUE;
      ErrorText := 'TIMEOUT';
      Busy      := FALSE;
    END_IF
  END_IF

  // Outputs are reset with Execute = FALSE
  IF (( NOT Execute ) AND ( NOT Busy ))
  THEN
    Done  := FALSE;
    Error := FALSE;
  END_IF
END_FUNCTION_BLOCK
