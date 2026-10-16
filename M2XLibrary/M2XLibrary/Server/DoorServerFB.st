/// M2X door (server): requestTransit and requestRelease; the door may stay open for several transits
FUNCTION_BLOCK DoorServerFB EXTENDS ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      DoorServerFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    M2X door (server): requestTransit and requestRelease; the door may stay open for several transits
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
  /// Id of the door
  DoorId     : STRING(64);
  /// Current status of the door (application)
  DoorStatus : DoorStatusEnum := DoorStatusEnum.CLOSED;
END_VAR
VAR
  /// Senders with a finished transit and without release
 _openTransits : ARRAY [1..M2XLibraryParameter.REQUEST_ENTRIES_MAX] OF STRING(64);
  /// Number of open transits
 _openCount    : DINT;
END_VAR
  IF ( Config.InterfaceName = '' )
  THEN
    Config.InterfaceName := M2XLibraryConstants.INTERFACE_DOOR;
  END_IF

  SUPER^();
END_FUNCTION_BLOCK

METHOD PROTECTED CheckRequest : STRING(64)
/// Checks door id and release after transit
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
  IF (( _request.Parameters.DoorId <> '' ) AND ( _request.Parameters.DoorId <> DoorId ))
  THEN
    CheckRequest := M2XLibraryConstants.ERR_INVALID_PARAMETER;
    RETURN;
  END_IF

  IF ( _request.RequestType = RequestTypeEnum.REQUEST_RELEASE )
  THEN
    IF (( _request.SenderId <> '' ) AND ( FindTransit(SenderId := _request.SenderId) = 0 ))
    THEN
      CheckRequest := M2XLibraryConstants.ERR_REQUEST_SEQUENCE;
    END_IF
  END_IF
END_METHOD

METHOD PRIVATE FindTransit : DINT
/// Index of the open transit of a sender (0 = none)
VAR_INPUT
  /// Sender id
  SenderId : STRING(64);
END_VAR
VAR
  /// Transit index
 _i : DINT;
END_VAR
  FOR _i := 1 TO _openCount
  DO
    IF ( _openTransits[_i] = SenderId )
    THEN
      FindTransit := _i;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Request types of the door interface
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  CASE RequestType OF
    RequestTypeEnum.REQUEST_TRANSIT,
    RequestTypeEnum.REQUEST_RELEASE,
    RequestTypeEnum.REQUEST_FACTSHEET,
    RequestTypeEnum.REQUEST_CANCEL:
      IsRequestSupported := TRUE;
  ELSE
    IsRequestSupported := FALSE;
  END_CASE
END_METHOD

METHOD PROTECTED OnStatusChanged
/// Tracks open transits
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
VAR
  /// Transit index
 _t : DINT;
  /// Read index
 _i : DINT;
END_VAR
  IF ( _requests[EntryIndex].Status <> RequestStatusEnum.FINISHED )
  THEN
    RETURN;
  END_IF

  IF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_TRANSIT )
  THEN
    IF (( FindTransit(SenderId := _requests[EntryIndex].Request.SenderId) = 0 ) AND ( _openCount < M2XLibraryParameter.REQUEST_ENTRIES_MAX ))
    THEN
     _openCount               := _openCount + 1;
     _openTransits[_openCount] := _requests[EntryIndex].Request.SenderId;
    END_IF

  ELSIF ( _requests[EntryIndex].Request.RequestType = RequestTypeEnum.REQUEST_RELEASE )
  THEN
   _t := FindTransit(SenderId := _requests[EntryIndex].Request.SenderId);
    IF ( _t = 0 )
    THEN
      // release without sender id: oldest transit
      IF ( _openCount > 0 )
      THEN
       _t := 1;
      END_IF
    END_IF
    IF ( _t > 0 )
    THEN
      FOR _i := _t TO _openCount - 1
      DO
       _openTransits[_i] := _openTransits[_i + 1];
      END_FOR
     _openCount := _openCount - 1;
    END_IF
  END_IF
END_METHOD

PROPERTY OpenTransitCount : DINT
/// Number of transits without release (the door may close at 0)
GET
VAR
END_VAR
  OpenTransitCount := _openCount;
END_GET
END_PROPERTY

METHOD PROTECTED WriteStateContent
/// State of the door
VAR_INPUT
END_VAR
 _writer.AddString(Name := 'serialNumber', Value := Config.SerialNumber);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'connectionState', Value := ConnectionStateToString(_connectionState));
 _writer.Key(Name := 'doorState');
 _writer.BeginObject();
 _writer.AddString(Name := 'doorId',     Value := DoorId);
 _writer.AddString(Name := 'doorStatus', Value := DoorStatusToString(DoorStatus));
  WriteRequestStates(PointIndex := 1);
  WriteErrors(PointIndex := 1);
 _writer.EndObject();
END_METHOD
