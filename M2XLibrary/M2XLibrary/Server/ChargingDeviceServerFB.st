/// M2X charging device (server): requestAccess -> requestStartCharge -> requestStopCharge -> requestRelease
FUNCTION_BLOCK ChargingDeviceServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ChargingDeviceServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X charging device (server): requestAccess -> requestStartCharge -> requestStopCharge -> requestRelease
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
  /// Id of the charging device
  ChargingDeviceId : STRING(64);
  /// Current charging process (application)
  ChargingProcess  : ChargingProcessData;
  /// Total operating hours
  OperatingHours   : LREAL;
END_VAR
VAR
  /// Current charging session
 _session : SessionData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_CHARGING_DEVICE;
  END_IF

  SUPER^();

METHOD PROTECTED CheckRequest : STRING(64)
/// Checks the charging sequence
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
VAR
  /// Session of the request is the current session
 _bound : BOOL;
END_VAR
  IF ( _request.Parameters.ChargingSessionId = '' )
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
    RETURN;
  END_IF

 _bound := ( _session.Phase <> SessionPhaseEnum.IDLE ) AND ( _session.SessionId = _request.Parameters.ChargingSessionId );

  CASE _request.RequestType OF
    RequestTypeEnum.REQUEST_ACCESS:
      IF ( _bound )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_START_CHARGE:
      IF (( NOT _bound ) OR
          (( _session.Phase <> SessionPhaseEnum.GRANTED ) AND ( _session.Phase <> SessionPhaseEnum.EXITING ) AND ( _session.Phase <> SessionPhaseEnum.FAILED )))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_STOP_CHARGE:
      IF (( NOT _bound ) OR ( _session.Phase <> SessionPhaseEnum.ACTIVE ))
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF

    RequestTypeEnum.REQUEST_RELEASE:
      IF ( NOT _bound )
      THEN
        CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
      END_IF
  ELSE
    CheckRequest := M2XLibraryConstants.ERR_REQUEST_NOT_SUPPORTED;
  END_CASE
END_METHOD

METHOD PRIVATE ClearSession
/// Frees the charging device
VAR_INPUT
END_VAR
 _session.Phase     := SessionPhaseEnum.IDLE;
 _session.SessionId := '';
 _session.SenderId  := '';
END_METHOD

METHOD PROTECTED IsDeliverable : BOOL
/// requestAccess is delivered only when the charging device is free
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS )
  THEN
    IsDeliverable := ( _session.Phase = SessionPhaseEnum.IDLE );
  ELSE
    IsDeliverable := TRUE;
  END_IF
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the charging device interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_ACCESS,
    RequestTypeEnum.REQUEST_START_CHARGE,
    RequestTypeEnum.REQUEST_STOP_CHARGE,
    RequestTypeEnum.REQUEST_RELEASE,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PROTECTED OnCanceled
/// Canceled requestAccess frees the charging device
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF (( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS ) AND
      ( _session.SessionId = _requests[EntryIndex].Request.Parameters.ChargingSessionId ))
  THEN
    ClearSession();
  END_IF
END_METHOD

METHOD PROTECTED OnDelivered
/// requestAccess delivered: the session occupies the charging device
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_ACCESS )
  THEN
   _session.Phase     := SessionPhaseEnum.REQUESTED;
   _session.SessionId := _requests[EntryIndex].Request.Parameters.ChargingSessionId;
   _session.SenderId  := _requests[EntryIndex].Request.SenderId;
  END_IF
END_METHOD

METHOD PROTECTED OnStatusChanged
/// Follows the charging sequence
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Status of the entry
 _status : RequestStatusEnum;
END_VAR
 _status := _requests[EntryIndex].Status;

  CASE _requests[EntryIndex].Request.RequestType OF
    RequestTypeEnum.REQUEST_ACCESS:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _session.Phase := SessionPhaseEnum.GRANTED;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
        ClearSession();
      END_IF

    RequestTypeEnum.REQUEST_START_CHARGE:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _session.Phase := SessionPhaseEnum.ACTIVE;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
       _session.Phase := SessionPhaseEnum.FAILED;
      END_IF

    RequestTypeEnum.REQUEST_STOP_CHARGE:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
       _session.Phase := SessionPhaseEnum.EXITING;
      ELSIF ( _status = RequestStatusEnum.FAILED )
      THEN
       _session.Phase := SessionPhaseEnum.FAILED;
      END_IF

    RequestTypeEnum.REQUEST_RELEASE:
      IF ( _status = RequestStatusEnum.FINISHED )
      THEN
        ClearSession();
      END_IF
  ELSE
    ;
  END_CASE
END_METHOD

PROPERTY Phase : SessionPhaseEnum
/// Sequence phase of the charging session
GET
VAR
END_VAR
  Phase := _session.Phase;
END_GET
END_PROPERTY

PROPERTY SessionId : STRING(64)
/// Current charging session id
GET
VAR
END_VAR
  SessionId := _session.SessionId;
END_GET
END_PROPERTY

METHOD PROTECTED WriteRequestStateExtras
/// chargingProcess of a requestStates item
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
 _writer.Key(Name := 'chargingProcess');
 _writer.BeginObject();
 _writer.AddString(Name := 'charging',     Value := ChargingProcessToString(ChargingProcess.Charging));
 _writer.AddNumber(Name := 'temperature',  Value := ChargingProcess.Temperature);
 _writer.AddNumber(Name := 'chargingRate', Value := ChargingProcess.ChargingRate);
 _writer.AddBool(Name := 'derating',       Value := ChargingProcess.Derating);
 _writer.AddString(Name := 'descriptor',   Value := '');
 _writer.EndObject();
END_METHOD

METHOD PROTECTED WriteStateContent
/// State of the charging device
VAR_INPUT
END_VAR
 _writer.AddString(Name := 'serialNumber', Value := Config.SerialNumber);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'connectionState', Value := ConnectionStateToString(_connectionState));
 _writer.Key(Name := 'chargingDeviceState');
 _writer.BeginObject();
 _writer.AddString(Name := 'chargingDeviceId', Value := ChargingDeviceId);
 _writer.Key(Name := 'currentCharging');
 _writer.BeginObject();
 _writer.AddString(Name := 'chargingSessionId', Value := _session.SessionId);
 _writer.AddString(Name := 'descriptor',        Value := ChargingProcessToString(ChargingProcess.Charging));
 _writer.EndObject();
  WriteRequestStates(PointIndex := 1);
 _writer.AddNumber(Name := 'operatingHours', Value := OperatingHours);
  WriteErrors(PointIndex := 1);
 _writer.EndObject();
END_METHOD

END_FUNCTION_BLOCK
