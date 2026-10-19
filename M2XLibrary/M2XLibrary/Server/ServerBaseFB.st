/// Base of all M2X servers (device side): request table, one active request per sender, errors, state and factsheet
FUNCTION_BLOCK ServerBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ServerBaseFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Base of all M2X servers (device side): request table, one active request per sender, errors, state and factsheet
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
  /// Enable the server
  Enable    : BOOL;
  /// Transport (one per endpoint)
  Transport : ITransport;
  /// Endpoint configuration
  Config    : EndpointConfigData;
END_VAR
VAR_OUTPUT
  /// Transport is connected and the server is enabled
  Connected        : BOOL;
  /// Number of used request entries
  RequestCount     : DINT;
  /// Number of received messages
  MessagesReceived : UDINT;
  /// Number of messages that could not be parsed
  InvalidMessages  : UDINT;
  /// Number of published state messages
  StatesPublished  : UDINT;
END_VAR
VAR
  /// Request table
 _requests           : ARRAY [1..M2XLibraryParameter.REQUEST_ENTRIES_MAX] OF RequestEntryData;
  /// Active errors
 _errors             : ARRAY [1..M2XLibraryParameter.ERRORS_MAX] OF ErrorData;
  /// Number of active errors
 _errorCount         : DINT;
  /// Received message
 _message            : MessageData;
  /// JSON parser
 _parser             : JsonParserFB;
  /// JSON writer
 _writer             : JsonWriterFB;
  /// Request being processed
 _request            : RequestData;
  /// Empty request (to clear _request)
 _emptyRequest       : RequestData;
  /// Factsheet set by the application (raw JSON)
 _factsheet          : ARRAY [0..M2XLibraryParameter.MESSAGE_SIZE_MAX - 1] OF BYTE;
  /// Length of the factsheet set by the application
 _factsheetLength    : UDINT;
  /// Connection state written into the state
 _connectionState    : ConnectionStateEnum := ConnectionStateEnum.ONLINE;
  /// Enable of the last cycle
 _enabled            : BOOL;
  /// Request topic is subscribed
 _subscribed         : BOOL;
  /// Factsheet was published
 _factsheetPublished : BOOL;
  /// Last will was set
 _willSet            : BOOL;
  /// State must be published
 _stateChanged       : BOOL;
  /// Timer for the cyclic state
 _stateTimer         : TON;
  /// Arrival counter
 _sequence           : UDINT;
  /// Header id of the state topic
 _headerIdState      : UDINT;
  /// Header id of the factsheet topic
 _headerIdFactsheet  : UDINT;
  /// Request topic
 _requestTopic       : STRING(255);
  /// State topic
 _stateTopic         : STRING(255);
  /// Factsheet topic
 _factsheetTopic     : STRING(255);
  /// Loop index
 _idx                : DINT;
END_VAR
 _requestTopic   := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_REQUEST);
 _stateTopic     := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_STATE);
 _factsheetTopic := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_FACTSHEET);

  // Disabled: publish OFFLINE once
  IF (( NOT Enable ) OR ( Transport = 0 ))
  THEN
    IF (( _enabled ) AND ( Connected ) AND ( Transport <> 0 ))
    THEN
     _connectionState := ConnectionStateEnum.OFFLINE;
      PublishState();
    END_IF
   _enabled             := FALSE;
    Connected           := FALSE;
   _subscribed          := FALSE;
   _factsheetPublished  := FALSE;
    RETURN;
  END_IF

  IF ( NOT _enabled )
  THEN
   _enabled         := TRUE;
   _connectionState := ConnectionStateEnum.ONLINE;
   _stateChanged    := TRUE;
  END_IF

  // Last will before the transport connects
  IF ( NOT _willSet )
  THEN
   _willSet := SetWill();
  END_IF

  Connected := Transport.Connected;
  IF ( NOT Connected )
  THEN
   _subscribed         := FALSE;
   _factsheetPublished := FALSE;
    RETURN;
  END_IF

  IF ( NOT _subscribed )
  THEN
   _subscribed   := Transport.Subscribe(Topic := _requestTopic);
   _stateChanged := TRUE;
  END_IF

  IF ( NOT _factsheetPublished )
  THEN
   _factsheetPublished := PublishFactsheet();
  END_IF

  // Received requests
  FOR _idx := 1 TO UDINT_TO_DINT(M2XLibraryParameter.MESSAGE_QUEUE_MAX)
  DO
    IF ( NOT Transport.Receive(Message := _message) )
    THEN
      EXIT;
    END_IF
    HandleMessage();
  END_FOR

  PruneEntries();
  OnCycle();

  // State on change, otherwise cyclic
 _stateTimer(IN := TRUE, PT := M2XLibraryParameter.STATE_INTERVAL);
  IF (( _stateChanged ) OR ( _stateTimer.Q ))
  THEN
    PublishState();
  END_IF

  RequestCount := 0;
  FOR _idx := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF ( _requests[_idx].Used )
    THEN
      RequestCount := RequestCount + 1;
    END_IF
  END_FOR

METHOD PROTECTED AddEntry : DINT
/// Adds an entry for _request (oldest final entry is replaced if the table is full); 0 = table full
VAR_INPUT
  /// Status of the new entry
  Status            : RequestStatusEnum;
  /// Point
  PointIndex        : DINT;
  /// Result description
  ResultDescription : STRING(255);
END_VAR
VAR
  /// Entry index
 _i    : DINT;
  /// Slot
 _slot : DINT;
END_VAR
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF ( NOT _requests[_i].Used )
    THEN
     _slot := _i;
      EXIT;
    END_IF
  END_FOR

  IF ( _slot = 0 )
  THEN
    FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
    DO
      IF (( IsFinalStatus(Status := _requests[_i].Status) ) AND ( NOT KeepEntry(EntryIndex := _i) ))
      THEN
        // OR_ELSE: _requests[_slot] must not be read while _slot = 0
        IF (( _slot = 0 ) OR_ELSE ( _requests[_i].Sequence < _requests[_slot].Sequence ))
        THEN
         _slot := _i;
        END_IF
      END_IF
    END_FOR
  END_IF

  IF ( _slot = 0 )
  THEN
    AddError(ErrorType        := M2XLibraryConstants.ERR_REQUEST_TABLE_FULL,
             ErrorLevel       := ErrorLevelEnum.WARNING,
             ErrorDescription := 'no free request entry',
             RequestId        := _request.RequestId,
             PointIndex       := 0);
    RETURN;
  END_IF

 _sequence := _sequence + 1;
 _requests[_slot].Used              := TRUE;
 _requests[_slot].Request           := _request;
 _requests[_slot].Status            := Status;
 _requests[_slot].ResultDescription := ResultDescription;
 _requests[_slot].PointIndex        := PointIndex;
 _requests[_slot].Delivered         := IsFinalStatus(Status := Status);
 _requests[_slot].Sequence          := _sequence;
 _requests[_slot].FinalTime         := TIME();

 _stateChanged  := TRUE;
  AddEntry      := _slot;
END_METHOD

METHOD AddError : BOOL
/// Adds or updates an error (same type and request id); the oldest error is dropped if the list is full
VAR_INPUT
  /// Error type
  ErrorType        : STRING(64);
  /// Error level
  ErrorLevel       : ErrorLevelEnum;
  /// Description
  ErrorDescription : STRING(255);
  /// Related request (optional)
  RequestId        : STRING(64);
  /// Point (0 = whole entity)
  PointIndex       : DINT;
END_VAR
VAR
  /// Error index
 _i    : DINT;
  /// Slot
 _slot : DINT;
END_VAR
  FOR _i := 1 TO _errorCount
  DO
    IF (( _errors[_i].ErrorType = ErrorType ) AND ( _errors[_i].RequestId = RequestId ))
    THEN
     _slot := _i;
      EXIT;
    END_IF
  END_FOR

  IF ( _slot = 0 )
  THEN
    IF ( _errorCount >= M2XLibraryParameter.ERRORS_MAX )
    THEN
      FOR _i := 1 TO M2XLibraryParameter.ERRORS_MAX - 1
      DO
       _errors[_i] := _errors[_i + 1];
      END_FOR
     _errorCount := M2XLibraryParameter.ERRORS_MAX - 1;
    END_IF
   _errorCount := _errorCount + 1;
   _slot       := _errorCount;
  END_IF

 _errors[_slot].ErrorType           := ErrorType;
 _errors[_slot].ErrorLevel          := ErrorLevel;
 _errors[_slot].ErrorDescription    := ErrorDescription;
 _errors[_slot].RequestId           := RequestId;
 _errors[_slot].PointIndex          := PointIndex;
 _errors[_slot].ErrorReferenceCount := 0;

 _stateChanged  := TRUE;
  AddError      := TRUE;
END_METHOD

METHOD PRIVATE BuildState
/// Writes the complete state message into the writer
VAR_INPUT
END_VAR
 _writer.Reset();
 _writer.BeginObject();
 _writer.AddInteger(Name := 'headerId', Value := _headerIdState);
 _writer.AddString(Name := 'timestamp', Value := GetTimestamp());
 _writer.AddString(Name := 'version',   Value := Config.ProtocolVersion);
  WriteStateContent();
 _writer.EndObject();
END_METHOD

METHOD PROTECTED CancelFinished : BOOL
/// Hook: requestCancel without active request (e.g. remove a finished signal); TRUE = canceled
VAR_INPUT
END_VAR
  CancelFinished := FALSE;
END_METHOD

METHOD PROTECTED CheckRequest : STRING(64)
/// Hook: checks _request for the point; returns an error type or '' if the request is accepted
VAR_INPUT
  /// Point of the request
  PointIndex : DINT;
END_VAR
  CheckRequest := '';
END_METHOD

METHOD ClearErrors
/// Removes all errors
VAR_INPUT
END_VAR
  IF ( _errorCount > 0 )
  THEN
   _errorCount   := 0;
   _stateChanged := TRUE;
  END_IF
END_METHOD

PROPERTY ConnectionState : ConnectionStateEnum
/// Connection state written into the state
GET
VAR
END_VAR
  ConnectionState := _connectionState;
END_GET
END_PROPERTY

PROPERTY ErrorCount : DINT
/// Number of active errors
GET
VAR
END_VAR
  ErrorCount := _errorCount;
END_GET
END_PROPERTY

METHOD PROTECTED FindActiveBySender : DINT
/// Index of the active (pending, running, paused) entry of a sender (0 = none)
VAR_INPUT
  /// Sender id
  SenderId : STRING(64);
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
  IF ( SenderId = '' )
  THEN
    RETURN;
  END_IF

  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _requests[_i].Used ) AND
        ( _requests[_i].Request.SenderId = SenderId ) AND
        ( NOT IsFinalStatus(Status := _requests[_i].Status) ))
    THEN
      FindActiveBySender := _i;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED FindEntry : DINT
/// Index of the entry with the request id (0 = not found)
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
  IF ( RequestId = '' )
  THEN
    RETURN;
  END_IF

  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _requests[_i].Used ) AND ( _requests[_i].Request.RequestId = RequestId ))
    THEN
      FindEntry := _i;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD GetNextRequest : DINT
/// Returns the oldest pending request that is not yet delivered; result = point index (0 = none)
VAR_IN_OUT
  /// Request for the application
  Request : RequestData;
END_VAR
VAR
  /// Entry index
 _i    : DINT;
  /// Best entry
 _best : DINT;
END_VAR
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _requests[_i].Used                                ) AND
        ( _requests[_i].Status = RequestStatusEnum.PENDING  ) AND
        ( NOT _requests[_i].Delivered                       ))
    THEN
      IF ( IsDeliverable(EntryIndex := _i) )
      THEN
        // OR_ELSE: _requests[_best] must not be read while _best = 0
        IF (( _best = 0 ) OR_ELSE ( _requests[_i].Sequence < _requests[_best].Sequence ))
        THEN
         _best := _i;
        END_IF
      END_IF
    END_IF
  END_FOR

  IF ( _best = 0 )
  THEN
    RETURN;
  END_IF

 _requests[_best].Delivered := TRUE;
  OnDelivered(EntryIndex := _best);
  Request        := _requests[_best].Request;
  GetNextRequest := _requests[_best].PointIndex;
END_METHOD

METHOD GetRequestStatus : RequestStatusEnum
/// Status of a request (NONE if unknown)
VAR_INPUT
  /// Id of the request
  RequestId : STRING(64);
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
 _i := FindEntry(RequestId := RequestId);
  IF ( _i > 0 )
  THEN
    GetRequestStatus := _requests[_i].Status;
  END_IF
END_METHOD

METHOD PRIVATE HandleMessage
/// Parses a received message and processes its requests
VAR_INPUT
END_VAR
VAR
  /// requests array
 _arr      : DINT;
  /// Request item
 _item     : DINT;
  /// Item index
 _i        : DINT;
  /// Sender id of the message
 _senderId : STRING(64);
END_VAR
  MessagesReceived := MessagesReceived + 1;

  IF ( _message.Topic <> _requestTopic )
  THEN
    RETURN;
  END_IF

  IF (( _message.Oversized ) OR
      ( NOT _parser.Parse(pData := ADR(_message.Payload), Length := _message.PayloadLength) ))
  THEN
    InvalidMessages := InvalidMessages + 1;
    AddError(ErrorType        := M2XLibraryConstants.ERR_INVALID_MESSAGE,
             ErrorLevel       := ErrorLevelEnum.WARNING,
             ErrorDescription := 'request message could not be parsed',
             RequestId        := '',
             PointIndex       := 0);
    RETURN;
  END_IF

 _arr := _parser.FindKey(ObjectToken := 0, Key := 'requests');
  IF ( _parser.GetType(Token := _arr) <> JsonTokenTypeEnum.JSON_ARRAY )
  THEN
    InvalidMessages := InvalidMessages + 1;
    AddError(ErrorType        := M2XLibraryConstants.ERR_INVALID_MESSAGE,
             ErrorLevel       := ErrorLevelEnum.WARNING,
             ErrorDescription := 'request message without requests array',
             RequestId        := '',
             PointIndex       := 0);
    RETURN;
  END_IF

  RemoveError(ErrorType := M2XLibraryConstants.ERR_INVALID_MESSAGE);
 _senderId := _parser.GetStringByKey(ObjectToken := 0, Key := 'senderId');

  FOR _i := 0 TO _parser.GetSize(Token := _arr) - 1
  DO
   _item := _parser.GetArrayItem(ArrayToken := _arr, Index := _i);
    IF ( _parser.GetType(Token := _item) = JsonTokenTypeEnum.JSON_OBJECT )
    THEN
      ParseRequest(Item := _item, SenderId := _senderId);
      ProcessRequest();
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED HandleRequest : BOOL
/// Hook: handles a request completely (TRUE = no generic processing); _request holds the request
VAR_INPUT
END_VAR
  HandleRequest := FALSE;
END_METHOD

METHOD PROTECTED IsDeliverable : BOOL
/// Hook: pending entry may be delivered to the application now
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  IsDeliverable := TRUE;
END_METHOD

METHOD PROTECTED IsFinalStatus : BOOL
/// Status is FINISHED or FAILED
VAR_INPUT
  /// Status
  Status : RequestStatusEnum;
END_VAR
  IsFinalStatus := ( Status = RequestStatusEnum.FINISHED ) OR ( Status = RequestStatusEnum.FAILED );
END_METHOD

METHOD PROTECTED IsRequestSupported : BOOL
/// Hook: request type supported by the entity
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
  IsRequestSupported := ( RequestType = RequestTypeEnum.REQUEST_FACTSHEET ) OR
                        ( RequestType = RequestTypeEnum.REQUEST_CANCEL );
END_METHOD

METHOD PROTECTED KeepEntry : BOOL
/// Hook: entry is kept although its retention time expired
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
  KeepEntry := FALSE;
END_METHOD

METHOD PROTECTED OnCanceled
/// Hook: an entry was canceled by requestCancel
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
END_METHOD

METHOD PROTECTED OnCycle
/// Hook: called every cycle while connected
VAR_INPUT
END_VAR
END_METHOD

METHOD PROTECTED OnDelivered
/// Hook: entry was delivered to the application
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
END_METHOD

METHOD PROTECTED OnStatusChanged
/// Hook: the application changed the status of an entry
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
END_METHOD

METHOD PROTECTED ParseCustomParameter : BOOL
/// Hook: request parameter that is not part of RequestParameterData (TRUE = handled)
VAR_INPUT
  /// Key
  Key        : STRING(64);
  /// Value token
  ValueToken : DINT;
END_VAR
  ParseCustomParameter := FALSE;
END_METHOD

METHOD PRIVATE ParseParameter
/// Reads one request parameter; an object value with nested parameters (format of the example schemas) is read too
VAR_INPUT
  /// Key
  Key        : STRING(64);
  /// Value token
  ValueToken : DINT;
END_VAR
VAR
  /// Nested key token
 _key : DINT;
  /// Key index
 _i   : DINT;
END_VAR
  IF ( ParseRequestParameter(Parser := _parser, Parameters := _request.Parameters, Key := Key, ValueToken := ValueToken) )
  THEN
    RETURN;
  END_IF

  IF ( ParseCustomParameter(Key := Key, ValueToken := ValueToken) )
  THEN
    RETURN;
  END_IF

  IF ( _parser.GetType(Token := ValueToken) = JsonTokenTypeEnum.JSON_OBJECT )
  THEN
    FOR _i := 0 TO _parser.GetSize(Token := ValueToken) - 1
    DO
     _key := _parser.GetObjectKey(ObjectToken := ValueToken, Index := _i);
      IF ( NOT ParseRequestParameter(Parser := _parser, Parameters := _request.Parameters, Key := _parser.GetString(Token := _key), ValueToken := _key + 1) )
      THEN
        ParseCustomParameter(Key := _parser.GetString(Token := _key), ValueToken := _key + 1);
      END_IF
    END_FOR
  END_IF
END_METHOD

METHOD PRIVATE ParseRequest
/// Reads one request item into _request
VAR_INPUT
  /// Request item token
  Item     : DINT;
  /// Sender id of the message
  SenderId : STRING(64);
END_VAR
VAR
  /// requestParameters array
 _params : DINT;
  /// Parameter item
 _param  : DINT;
  /// Item index
 _i      : DINT;
END_VAR
 _request                    := _emptyRequest;
 _request.RequestType        := RequestTypeFromString(_parser.GetStringByKey(ObjectToken := Item, Key := 'requestType'));
 _request.RequestId          := _parser.GetStringByKey(ObjectToken := Item, Key := 'requestId');
 _request.RequestDescription := _parser.GetStringByKey(ObjectToken := Item, Key := 'requestDescription');
 _request.SenderId           := SenderId;

 _params := _parser.FindKey(ObjectToken := Item, Key := 'requestParameters');
  FOR _i := 0 TO _parser.GetSize(Token := _params) - 1
  DO
   _param := _parser.GetArrayItem(ArrayToken := _params, Index := _i);
    ParseParameter(Key        := _parser.GetStringByKey(ObjectToken := _param, Key := 'key'),
                   ValueToken := _parser.FindKey(ObjectToken := _param, Key := 'value'));
  END_FOR
END_METHOD

METHOD PRIVATE ProcessCancel
/// Processes requestCancel: cancels the active request of the sender or of the session
VAR_INPUT
END_VAR
VAR
  /// Entry to cancel
 _target : DINT;
  /// Entry index
 _i      : DINT;
END_VAR
 _target := FindActiveBySender(SenderId := _request.SenderId);

  // without sender id: same session
  IF ( _target = 0 )
  THEN
    FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
    DO
      IF (( _requests[_i].Used ) AND ( NOT IsFinalStatus(Status := _requests[_i].Status) ))
      THEN
        IF ((( _request.Parameters.LoadHandlingSessionId <> '' ) AND ( _requests[_i].Request.Parameters.LoadHandlingSessionId = _request.Parameters.LoadHandlingSessionId )) OR
            (( _request.Parameters.ElevatorSessionId     <> '' ) AND ( _requests[_i].Request.Parameters.ElevatorSessionId     = _request.Parameters.ElevatorSessionId     )) OR
            (( _request.Parameters.ChargingSessionId     <> '' ) AND ( _requests[_i].Request.Parameters.ChargingSessionId     = _request.Parameters.ChargingSessionId     )) OR
            (( _request.Parameters.TransportOrderId      <> '' ) AND ( _requests[_i].Request.Parameters.TransportOrderId      = _request.Parameters.TransportOrderId      )))
        THEN
         _target := _i;
          EXIT;
        END_IF
      END_IF
    END_FOR
  END_IF

  IF ( _target > 0 )
  THEN
   _requests[_target].Status            := RequestStatusEnum.FAILED;
   _requests[_target].ResultDescription := 'canceled';
   _requests[_target].FinalTime         := TIME();
    OnCanceled(EntryIndex := _target);
    AddEntry(Status := RequestStatusEnum.FINISHED, PointIndex := _requests[_target].PointIndex, ResultDescription := 'request canceled');
  ELSIF ( CancelFinished() )
  THEN
    AddEntry(Status := RequestStatusEnum.FINISHED, PointIndex := 0, ResultDescription := 'request canceled');
  ELSE
    AddEntry(Status := RequestStatusEnum.FAILED, PointIndex := 0, ResultDescription := 'no active request to cancel');
  END_IF
END_METHOD

METHOD PRIVATE ProcessRequest
/// Processes _request
VAR_INPUT
END_VAR
VAR
  /// Point of the request
 _point : DINT;
  /// Result of the check
 _check : STRING(64);
END_VAR
  IF ( _request.RequestId = '' )
  THEN
    InvalidMessages := InvalidMessages + 1;
    RETURN;
  END_IF

  // repeated request id: ignore
  IF ( FindEntry(RequestId := _request.RequestId) > 0 )
  THEN
    RETURN;
  END_IF

  IF ( HandleRequest() )
  THEN
    RETURN;
  END_IF

  IF ( NOT IsRequestSupported(RequestType := _request.RequestType) )
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_REQUEST_NOT_SUPPORTED, PointIndex := 0, Description := 'request type not supported');
    RETURN;
  END_IF

  IF ( _request.RequestType = RequestTypeEnum.REQUEST_FACTSHEET )
  THEN
    PublishFactsheet();
    AddEntry(Status := RequestStatusEnum.FINISHED, PointIndex := 0, ResultDescription := '');
    RETURN;
  END_IF

  IF ( _request.RequestType = RequestTypeEnum.REQUEST_CANCEL )
  THEN
    ProcessCancel();
    RETURN;
  END_IF

  // one active request per participant
  IF ( FindActiveBySender(SenderId := _request.SenderId) > 0 )
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_REQUEST_ALREADY_ACTIVE, PointIndex := 0, Description := 'sender already has an active request');
    RETURN;
  END_IF

 _point := ResolvePoint();
  IF (( _point < 1 ) OR ( _point > M2XLibraryParameter.POINTS_MAX ))
  THEN
    Reject(ErrorType := M2XLibraryConstants.ERR_INVALID_PARAMETER, PointIndex := 0, Description := 'unknown point or session');
    RETURN;
  END_IF

 _check := CheckRequest(PointIndex := _point);
  IF ( _check <> '' )
  THEN
    Reject(ErrorType := _check, PointIndex := _point, Description := 'request not allowed');
    RETURN;
  END_IF

  AddEntry(Status := RequestStatusEnum.PENDING, PointIndex := _point, ResultDescription := '');
END_METHOD

METHOD PRIVATE PruneEntries
/// Removes finished and failed entries after the retention time
VAR_INPUT
END_VAR
VAR
  /// Entry index
 _i   : DINT;
  /// Error index
 _e   : DINT;
  /// Write index for errors
 _n   : DINT;
  /// Current time
 _now : TIME;
END_VAR
 _now := TIME();
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _requests[_i].Used ) AND ( IsFinalStatus(Status := _requests[_i].Status) ))
    THEN
      IF (( _now - _requests[_i].FinalTime >= M2XLibraryParameter.REQUEST_RETENTION ) AND
          ( NOT KeepEntry(EntryIndex := _i) ))
      THEN
       _requests[_i].Used := FALSE;
       _stateChanged      := TRUE;
        // remove the errors of the request
       _n := 0;
        FOR _e := 1 TO _errorCount
        DO
          IF ( _errors[_e].RequestId <> _requests[_i].Request.RequestId )
          THEN
           _n := _n + 1;
            IF ( _n <> _e )
            THEN
             _errors[_n] := _errors[_e];
            END_IF
          END_IF
        END_FOR
       _errorCount := _n;
      END_IF
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED PublishFactsheet : BOOL
/// Publishes the factsheet (raw JSON of the application or generated)
VAR_INPUT
END_VAR
  IF ( _factsheetLength > 0 )
  THEN
    PublishFactsheet := Transport.Publish(Topic         := _factsheetTopic,
                                          pPayload      := ADR(_factsheet),
                                          PayloadLength := _factsheetLength,
                                          RetainFlag        := TRUE);
    RETURN;
  END_IF

 _writer.Reset();
 _writer.BeginObject();
 _writer.AddInteger(Name := 'headerId', Value := _headerIdFactsheet);
 _writer.AddString(Name := 'timestamp', Value := GetTimestamp());
 _writer.AddString(Name := 'version',   Value := Config.ProtocolVersion);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'serialNumber', Value := Config.SerialNumber);
  WriteFactsheetContent();
 _writer.EndObject();

  IF ( _writer.Overflow )
  THEN
    RETURN;
  END_IF

  PublishFactsheet := Transport.Publish(Topic         := _factsheetTopic,
                                        pPayload      := _writer.Data,
                                        PayloadLength := _writer.Length,
                                        RetainFlag        := TRUE);
 _headerIdFactsheet := _headerIdFactsheet + 1;
END_METHOD

METHOD PROTECTED PublishState : BOOL
/// Publishes the state
VAR_INPUT
END_VAR
  BuildState();
  IF ( _writer.Overflow )
  THEN
    RETURN;
  END_IF

  PublishState := Transport.Publish(Topic         := _stateTopic,
                                    pPayload      := _writer.Data,
                                    PayloadLength := _writer.Length,
                                    RetainFlag        := TRUE);
 _headerIdState := _headerIdState + 1;
 _stateChanged  := FALSE;
 _stateTimer(IN := FALSE);
  StatesPublished := StatesPublished + 1;
END_METHOD

METHOD PROTECTED Reject
/// Rejects _request: entry FAILED and error
VAR_INPUT
  /// Error type
  ErrorType   : STRING(64);
  /// Point
  PointIndex  : DINT;
  /// Description
  Description : STRING(255);
END_VAR
  AddEntry(Status := RequestStatusEnum.FAILED, PointIndex := PointIndex, ResultDescription := Description);
  AddError(ErrorType        := ErrorType,
           ErrorLevel       := ErrorLevelEnum.WARNING,
           ErrorDescription := Description,
           RequestId        := _request.RequestId,
           PointIndex       := PointIndex);
END_METHOD

METHOD RemoveError : BOOL
/// Removes all errors of a type
VAR_INPUT
  /// Error type
  ErrorType : STRING(64);
END_VAR
VAR
  /// Read index
 _i : DINT;
  /// Write index
 _n : DINT;
END_VAR
  FOR _i := 1 TO _errorCount
  DO
    IF ( _errors[_i].ErrorType <> ErrorType )
    THEN
     _n := _n + 1;
      IF ( _n <> _i )
      THEN
       _errors[_n] := _errors[_i];
      END_IF
    ELSE
      RemoveError := TRUE;
    END_IF
  END_FOR

  IF ( RemoveError )
  THEN
   _errorCount   := _n;
   _stateChanged := TRUE;
  END_IF
END_METHOD

METHOD PROTECTED ResolvePoint : DINT
/// Hook: point of the request in _request (0 = invalid)
VAR_INPUT
END_VAR
  ResolvePoint := 1;
END_METHOD

METHOD SetFactsheet : BOOL
/// Sets the factsheet as raw JSON (published retained; empty = generated minimal factsheet)
VAR_INPUT
  /// Factsheet JSON
  pData  : POINTER TO BYTE;
  /// Length in bytes
  Length : UDINT;
END_VAR
  IF ( Length > SIZEOF(_factsheet) )
  THEN
    RETURN;
  END_IF

  SysDepMemCpy(pDest := ADR(_factsheet), pSrc := pData, DataLen := Length);
 _factsheetLength     := Length;
 _factsheetPublished  := FALSE;
  SetFactsheet        := TRUE;
END_METHOD

METHOD SetRequestStatus : BOOL
/// Sets the status of a request (application); FALSE if unknown or already finished/failed
VAR_INPUT
  /// Id of the request
  RequestId         : STRING(64);
  /// New status
  Status            : RequestStatusEnum;
  /// Result description (optional)
  ResultDescription : STRING(255);
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
 _i := FindEntry(RequestId := RequestId);
  IF ( _i = 0 )
  THEN
    RETURN;
  END_IF

  IF ( IsFinalStatus(Status := _requests[_i].Status) )
  THEN
    RETURN;
  END_IF

  IF (( Status = RequestStatusEnum.NONE ) OR
      (( Status = RequestStatusEnum.PENDING ) AND ( _requests[_i].Status <> RequestStatusEnum.PENDING )))
  THEN
    RETURN;
  END_IF

  IF ( NOT _requests[_i].Delivered )
  THEN
   _requests[_i].Delivered := TRUE;
    OnDelivered(EntryIndex := _i);
  END_IF

 _requests[_i].Status            := Status;
 _requests[_i].ResultDescription := ResultDescription;
  IF ( IsFinalStatus(Status := Status) )
  THEN
   _requests[_i].FinalTime := TIME();
  END_IF

  OnStatusChanged(EntryIndex := _i);
 _stateChanged     := TRUE;
  SetRequestStatus := TRUE;
END_METHOD

METHOD PRIVATE SetWill : BOOL
/// Sets the last will: state with CONNECTION_BROKEN
VAR_INPUT
END_VAR
VAR
  /// Saved connection state
 _saved : ConnectionStateEnum;
END_VAR
 _saved           := _connectionState;
 _connectionState := ConnectionStateEnum.CONNECTION_BROKEN;
  BuildState();
 _connectionState := _saved;

  IF ( _writer.Overflow )
  THEN
    RETURN;
  END_IF

  SetWill := Transport.SetLastWill(Topic         := _stateTopic,
                                   pPayload      := _writer.Data,
                                   PayloadLength := _writer.Length,
                                   RetainFlag        := TRUE);
END_METHOD

METHOD TriggerState
/// Requests a state message in the next cycle
VAR_INPUT
END_VAR
 _stateChanged := TRUE;
END_METHOD

METHOD PROTECTED WriteErrors
/// Writes "errors":[...] with the errors of the point and the errors of the whole entity
VAR_INPUT
  /// Point (errors with point 0 are written for every point)
  PointIndex : DINT;
END_VAR
VAR
  /// Error index
 _i : DINT;
END_VAR
 _writer.Key(Name := 'errors');
 _writer.BeginArray();
  FOR _i := 1 TO _errorCount
  DO
    IF (( _errors[_i].PointIndex = PointIndex ) OR ( _errors[_i].PointIndex = 0 ))
    THEN
      WriteError(Writer := _writer, Error := _errors[_i]);
    END_IF
  END_FOR
 _writer.EndArray();
END_METHOD

METHOD PROTECTED WriteFactsheetContent
/// Hook: writes interface specific content of the generated factsheet
VAR_INPUT
END_VAR
END_METHOD

METHOD PROTECTED WriteRequestStateExtras
/// Hook: writes interface specific fields into each item of requestStates
VAR_INPUT
  /// Entry index
  EntryIndex : DINT;
END_VAR
END_METHOD

METHOD PROTECTED WriteRequestStates
/// Writes "requestStates":[...] with the entries of the point and the entries without point
VAR_INPUT
  /// Point (entries with point 0 are written for every point)
  PointIndex : DINT;
END_VAR
VAR
  /// Entry index
 _i : DINT;
END_VAR
 _writer.Key(Name := 'requestStates');
 _writer.BeginArray();
  FOR _i := 1 TO M2XLibraryParameter.REQUEST_ENTRIES_MAX
  DO
    IF (( _requests[_i].Used ) AND
        (( _requests[_i].PointIndex = PointIndex ) OR ( _requests[_i].PointIndex = 0 )))
    THEN
     _writer.BeginObject();
     _writer.AddString(Name := 'requestId',     Value := _requests[_i].Request.RequestId);
     _writer.AddString(Name := 'requestType',   Value := RequestTypeToString(_requests[_i].Request.RequestType));
     _writer.AddString(Name := 'requestStatus', Value := RequestStatusToString(_requests[_i].Status));
     _writer.AddStringOptional(Name := 'resultDescription', Value := _requests[_i].ResultDescription);
     _writer.AddStringOptional(Name := 'senderId',          Value := _requests[_i].Request.SenderId);
      WriteRequestStateExtras(EntryIndex := _i);
     _writer.EndObject();
    END_IF
  END_FOR
 _writer.EndArray();
END_METHOD

METHOD PROTECTED WriteStateContent
/// Hook: writes the interface specific content of the state
VAR_INPUT
END_VAR
 _writer.AddString(Name := 'serialNumber',    Value := Config.SerialNumber);
 _writer.AddStringOptional(Name := 'manufacturer', Value := Config.Manufacturer);
 _writer.AddString(Name := 'connectionState', Value := ConnectionStateToString(_connectionState));
  WriteRequestStates(PointIndex := 1);
  WriteErrors(PointIndex := 1);
END_METHOD

END_FUNCTION_BLOCK
