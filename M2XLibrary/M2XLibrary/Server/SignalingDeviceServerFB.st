/// M2X signaling device (server): global signal and individual signals per request
FUNCTION_BLOCK SignalingDeviceServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      SignalingDeviceServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X signaling device (server): global signal and individual signals per request
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
  /// Id of the signaling device
  SignalingDeviceId : STRING(64);
  /// Number of signals
  SignalCount       : DINT;
  /// Signals of the device
  Signals           : ARRAY [1..M2XLibraryParameter.SIGNALS_MAX] OF SignalConfigData;
  /// Signal for all participants without individual signal
  GlobalSignalId    : STRING(64);
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_SIGNALING_DEVICE;
  END_IF

  SUPER^();

METHOD PROTECTED CancelFinished : BOOL
/// requestCancel removes the finished signal of the sender
VAR_INPUT
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( IsActiveSignal(EntryIndex := _i) ) AND ( _requests[_i].Request.SenderId = _request.SenderId ))
    THEN
     _requests[_i].Used  := FALSE;
      CancelFinished     := TRUE;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED CheckRequest : STRING(64)
/// Signal must exist and be requestable
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
VAR
  /// Signal index
 _s : DINT;
END_VAR
 _s := FindSignal(SignalId := _request.Parameters.SignalId);
  IF ( _s = 0 )
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
  ELSIF ( NOT Signals[_s].IsRequestable )
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
  END_IF
END_METHOD

METHOD PRIVATE FindSignal : DINT
/// Index of a signal (0 = unknown)
VAR_INPUT
  /// Signal id
  SignalId : STRING(64);
END_VAR
VAR
  /// Signal index
 _s : DINT;
END_VAR
  IF ( SignalId = '' )
  THEN
    RETURN;
  END_IF

  FOR _s := 1 TO MIN(SignalCount, M2XLibraryParameter.SIGNALS_MAX)
  DO
    IF ( Signals[_s].SignalId = SignalId )
    THEN
      FindSignal := _s;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD GetActiveSignal : BOOL
/// Active individual signal (Index 1..n); FALSE if none
VAR_INPUT
  /// Index 1..n
  Index : DINT;
END_VAR
VAR_IN_OUT
  /// Request of the signal
  RequestId : STRING(64);
  /// Signal id
  SignalId  : STRING(64);
END_VAR
VAR
  /// Entry index
 _i     : DINT;
  /// Counter
 _count : DINT;
END_VAR
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF ( IsActiveSignal(EntryIndex := _i) )
    THEN
     _count := _count + 1;
      IF ( _count = Index )
      THEN
        RequestId       := _requests[_i].Request.RequestId;
        SignalId        := _requests[_i].Request.Parameters.SignalId;
        GetActiveSignal := TRUE;
        RETURN;
      END_IF
    END_IF
  END_FOR
END_METHOD

METHOD PRIVATE IsActiveSignal : BOOL
/// Entry is a finished requestSignal
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IsActiveSignal := ( _requests[EntryIndex].Used ) AND
                    ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_SIGNAL ) AND
                    ( _requests[EntryIndex].Status = RequestStatusEnum.FINISHED );
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the signaling device interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_SIGNAL,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PROTECTED KeepEntry : BOOL
/// Finished signals stay until they are replaced or canceled
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  KeepEntry := IsActiveSignal(EntryIndex := EntryIndex);
END_METHOD

METHOD PROTECTED OnStatusChanged
/// A new finished signal replaces the previous signal of the sender
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
  IF (( _requests[EntryIndex].Status <> RequestStatusEnum.FINISHED ) OR ( _requests[EntryIndex].Request.SenderId = '' ))
  THEN
    RETURN;
  END_IF

  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _i <> EntryIndex ) AND ( IsActiveSignal(EntryIndex := _i) ) AND
        ( _requests[_i].Request.SenderId = _requests[EntryIndex].Request.SenderId ))
    THEN
     _requests[_i].Used := FALSE;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED WriteRequestStateExtras
/// requestedSignal of a requestStates item
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_SIGNAL )
  THEN
   _writer.Key(Name := 'requestedSignal');
    WriteSignal(SignalId := _requests[EntryIndex].Request.Parameters.SignalId, RequestId := '');
  END_IF
END_METHOD

METHOD PRIVATE WriteSignal
/// Writes {"requestId":..,"signalId":..,"descriptor":..}
VAR_INPUT
  /// Signal id
  SignalId  : STRING(64);
  /// Request id (optional)
  RequestId : STRING(64);
END_VAR
VAR
  /// Signal index
 _s : DINT;
END_VAR
 _s := FindSignal(SignalId := SignalId);
 _writer.BeginObject();
 _writer.AddStringOptional(Name := 'requestId', Value := RequestId);
 _writer.AddString(Name := 'signalId', Value := SignalId);
  IF ( _s > 0 )
  THEN
   _writer.AddString(Name := 'descriptor', Value := Signals[_s].Descriptor);
  END_IF
 _writer.EndObject();
END_METHOD

METHOD PROTECTED WriteStateContent
/// State of the signaling device
VAR_INPUT
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
 _writer.AddString(Name := 'serialNumber', Value := Config.SerialNumber);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'connectionState', Value := ConnectionStateToString(_connectionState));
 _writer.Key(Name := 'signalingDeviceState');
 _writer.BeginObject();
 _writer.AddString(Name := 'signalingDeviceId', Value := SignalingDeviceId);
 _writer.Key(Name := 'globalSignal');
  WriteSignal(SignalId := GlobalSignalId, RequestId := '');
 _writer.Key(Name := 'individualSignals');
 _writer.BeginArray();
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF ( IsActiveSignal(EntryIndex := _i) )
    THEN
      WriteSignal(SignalId := _requests[_i].Request.Parameters.SignalId, RequestId := _requests[_i].Request.RequestId);
    END_IF
  END_FOR
 _writer.EndArray();
 _writer.Key(Name := 'plannedSignals');
 _writer.BeginArray();
 _writer.EndArray();
  WriteRequestStates(PointIndex := 1);
  WriteErrors(PointIndex := 1);
 _writer.EndObject();
END_METHOD

END_FUNCTION_BLOCK
