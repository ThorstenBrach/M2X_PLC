/// Converts RequestTypeEnum to its JSON text
FUNCTION RequestTypeToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestTypeToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts RequestTypeEnum to its JSON text
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
  Value : RequestTypeEnum;
END_VAR
  CASE Value OF
    RequestTypeEnum.UNKNOWN                         : RequestTypeToString := '';
    RequestTypeEnum.REQUEST_ACCESS                  : RequestTypeToString := 'requestAccess';
    RequestTypeEnum.REQUEST_EXIT                    : RequestTypeToString := 'requestExit';
    RequestTypeEnum.REQUEST_LOAD_TRANSFER           : RequestTypeToString := 'requestLoadTransfer';
    RequestTypeEnum.REQUEST_RELEASE                 : RequestTypeToString := 'requestRelease';
    RequestTypeEnum.REQUEST_FACTSHEET               : RequestTypeToString := 'requestFactsheet';
    RequestTypeEnum.REQUEST_CONTINUE_LOAD_TRANSFER  : RequestTypeToString := 'requestContinueLoadTransfer';
    RequestTypeEnum.REQUEST_CANCEL                  : RequestTypeToString := 'requestCancel';
    RequestTypeEnum.REQUEST_TRANSPORT_ORDER         : RequestTypeToString := 'requestTransportOrder';
    RequestTypeEnum.REQUEST_TRANSIT                 : RequestTypeToString := 'requestTransit';
    RequestTypeEnum.REQUEST_SIGNAL                  : RequestTypeToString := 'requestSignal';
    RequestTypeEnum.REQUEST_ELEVATOR                : RequestTypeToString := 'requestElevator';
    RequestTypeEnum.REQUEST_CHANGE_FLOOR            : RequestTypeToString := 'requestChangeFloor';
    RequestTypeEnum.REQUEST_MANUAL_MODE             : RequestTypeToString := 'requestManualMode';
    RequestTypeEnum.REQUEST_START_CHARGE            : RequestTypeToString := 'requestStartCharge';
    RequestTypeEnum.REQUEST_STOP_CHARGE             : RequestTypeToString := 'requestStopCharge';
  ELSE
    RequestTypeToString := '';
  END_CASE
END_FUNCTION
