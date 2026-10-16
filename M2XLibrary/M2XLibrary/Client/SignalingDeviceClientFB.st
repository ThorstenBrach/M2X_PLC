/// M2X client of a signaling device (MR/FM side)
FUNCTION_BLOCK SignalingDeviceClientFB EXTENDS ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      SignalingDeviceClientFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X client of a signaling device (MR/FM side)
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
VAR_OUTPUT
  /// Global signal of the last state
  GlobalSignalId        : STRING(64);
  /// Number of individual signals of the last state
  IndividualSignalCount : DINT;
END_VAR
VAR
  /// Individual signals of the last state
 _individual : ARRAY [1..M2XLibraryParameter.REQUEST_ENTRIES_MAX] OF IndividualSignalData;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_SIGNALING_DEVICE;
  END_IF

  SUPER^();
END_FUNCTION_BLOCK

METHOD GetIndividualSignal : STRING(64)
/// Individual signal shown for a request ('' = global signal applies)
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Index
 _i : DINT;
END_VAR
  FOR _i := 1 TO IndividualSignalCount
  DO
    IF ( _individual[_i].RequestId = RequestId )
    THEN
      GetIndividualSignal := _individual[_i].SignalId;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED ParseStateContent
/// State of the signaling device
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
VAR
  /// signalingDeviceState object
 _dev  : DINT;
  /// individualSignals array
 _arr  : DINT;
  /// Item token
 _item : DINT;
  /// Item index
 _i    : DINT;
END_VAR
  RemoteConnectionState := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'connectionState'));
 _dev            := _parser.FindKey(ObjectToken := Root, Key := 'signalingDeviceState');
  GlobalSignalId := _parser.GetStringByKey(ObjectToken := _parser.FindKey(ObjectToken := _dev, Key := 'globalSignal'), Key := 'signalId');

  IndividualSignalCount := 0;
 _arr := _parser.FindKey(ObjectToken := _dev, Key := 'individualSignals');
  FOR _i := 0 TO _parser.GetSize(Token := _arr) - 1
  DO
    IF ( IndividualSignalCount < M2XLibraryParameter.REQUEST_ENTRIES_MAX )
    THEN
     _item := _parser.GetArrayItem(ArrayToken := _arr, Index := _i);
      IndividualSignalCount := IndividualSignalCount + 1;
     _individual[IndividualSignalCount].RequestId := _parser.GetStringByKey(ObjectToken := _item, Key := 'requestId');
     _individual[IndividualSignalCount].SignalId  := _parser.GetStringByKey(ObjectToken := _item, Key := 'signalId');
    END_IF
  END_FOR

  ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := _dev, Key := 'requestStates'));
  ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := _dev, Key := 'errors'));
END_METHOD

METHOD RequestCancel : STRING(64)
/// Sends requestCancel (removes the own signal); returns the request id
VAR_INPUT
END_VAR
  ClearParameters();
  RequestCancel := SendRequest(RequestType := RequestTypeEnum.REQUEST_CANCEL, Description := '', Parameters := _params);
END_METHOD

METHOD RequestSignal : STRING(64)
/// Sends requestSignal; returns the request id
VAR_INPUT
  /// Signal id
  SignalId : STRING(64);
END_VAR
  ClearParameters();
 _params.SignalId  := SignalId;
  RequestSignal    := SendRequest(RequestType := RequestTypeEnum.REQUEST_SIGNAL, Description := '', Parameters := _params);
END_METHOD
