/// Converts the JSON text to RequestTypeEnum (RequestTypeEnum.UNKNOWN if unknown)
FUNCTION RequestTypeFromString : RequestTypeEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestTypeFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to RequestTypeEnum (RequestTypeEnum.UNKNOWN if unknown)
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
  RequestTypeFromString := RequestTypeEnum.UNKNOWN;

  IF ( Text = 'requestAccess' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_ACCESS;
    RETURN;
  END_IF

  IF ( Text = 'requestExit' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_EXIT;
    RETURN;
  END_IF

  IF ( Text = 'requestLoadTransfer' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_LOAD_TRANSFER;
    RETURN;
  END_IF

  IF ( Text = 'requestRelease' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_RELEASE;
    RETURN;
  END_IF

  IF ( Text = 'requestFactsheet' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_FACTSHEET;
    RETURN;
  END_IF

  IF ( Text = 'requestContinueLoadTransfer' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER;
    RETURN;
  END_IF

  IF ( Text = 'requestCancel' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_CANCEL;
    RETURN;
  END_IF

  IF ( Text = 'requestTransportOrder' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_TRANSPORT_ORDER;
    RETURN;
  END_IF

  IF ( Text = 'requestTransit' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_TRANSIT;
    RETURN;
  END_IF

  IF ( Text = 'requestSignal' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_SIGNAL;
    RETURN;
  END_IF

  IF ( Text = 'requestElevator' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_ELEVATOR;
    RETURN;
  END_IF

  IF ( Text = 'requestChangeFloor' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_CHANGE_FLOOR;
    RETURN;
  END_IF

  IF ( Text = 'requestManualMode' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_MANUAL_MODE;
    RETURN;
  END_IF

  IF ( Text = 'requestStartCharge' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_START_CHARGE;
    RETURN;
  END_IF

  IF ( Text = 'requestStopCharge' )
  THEN
    RequestTypeFromString := RequestTypeEnum.REQUEST_STOP_CHARGE;
    RETURN;
  END_IF
END_FUNCTION
