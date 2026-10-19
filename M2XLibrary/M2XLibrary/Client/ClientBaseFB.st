/// Base of all M2X clients (FM/MR side): sends requests and evaluates state and factsheet of one entity
FUNCTION_BLOCK ClientBaseFB
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      ClientBaseFB
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Base of all M2X clients (FM/MR side): sends requests and evaluates state and factsheet of one entity
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
  /// Enable the client
  Enable    : BOOL;
  /// Transport (one per endpoint)
  Transport : ITransport;
  /// Configuration of the target entity (interface name, version, entity name)
  Config    : EndpointConfigData;
  /// Own identity sent with every request (M2X proposal)
  SenderId  : STRING(64);
END_VAR
VAR_OUTPUT
  /// Transport is connected and the client is enabled
  Connected             : BOOL;
  /// At least one state was received
  StateReceived         : BOOL;
  /// The factsheet was received
  FactsheetReceived     : BOOL;
  /// Connection state reported by the entity
  RemoteConnectionState : ConnectionStateEnum;
  /// Number of received state messages
  StateCount            : UDINT;
  /// Number of errors in the last state
  ErrorCount            : DINT;
  /// Number of messages that could not be parsed
  InvalidMessages       : UDINT;
END_VAR
VAR
  /// Received message
 _message         : MessageData;
  /// JSON parser
 _parser          : JsonParserFB;
  /// JSON writer
 _writer          : JsonWriterFB;
  /// UUID generator for request ids
 _uuid            : UuidGeneratorFB;
  /// Header id of the request topic
 _headerId        : UDINT;
  /// Topics are subscribed
 _subscribed      : BOOL;
  /// Tracked requests
 _requests        : ARRAY [1..M2XLibraryParameter.CLIENT_REQUESTS_MAX] OF RequestStateData;
  /// Errors of the last state
 _errors          : ARRAY [1..M2XLibraryParameter.ERRORS_MAX] OF ErrorData;
  /// Factsheet (raw JSON)
 _factsheet       : ARRAY [0..M2XLibraryParameter.MESSAGE_SIZE_MAX - 1] OF BYTE;
  /// Length of the factsheet
 _factsheetLength : UDINT;
  /// Request parameters filled by the convenience methods of derived clients
 _params          : RequestParameterData;
  /// Empty parameters
 _noParameters    : RequestParameterData;
  /// Request topic
 _requestTopic    : STRING(255);
  /// State topic
 _stateTopic      : STRING(255);
  /// Factsheet topic
 _factsheetTopic  : STRING(255);
  /// Loop index
 _idx             : DINT;
END_VAR
 _requestTopic   := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_REQUEST);
 _stateTopic     := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_STATE);
 _factsheetTopic := BuildTopic(Config := Config, Topic := M2XLibraryConstants.TOPIC_FACTSHEET);

  IF (( NOT Enable ) OR ( Transport = 0 ))
  THEN
    Connected   := FALSE;
   _subscribed  := FALSE;
    RETURN;
  END_IF

  Connected := Transport.Connected;
  IF ( NOT Connected )
  THEN
   _subscribed := FALSE;
    RETURN;
  END_IF

  IF ( NOT _subscribed )
  THEN
   _subscribed := Transport.Subscribe(Topic := _stateTopic);
   _subscribed := Transport.Subscribe(Topic := _factsheetTopic) AND _subscribed;
  END_IF

  FOR _idx := 1 TO UDINT_TO_DINT(M2XLibraryParameter.MESSAGE_QUEUE_MAX)
  DO
    IF ( NOT Transport.Receive(Message := _message) )
    THEN
      EXIT;
    END_IF
    HandleMessage();
  END_FOR

METHOD PROTECTED ClearParameters
/// Clears the request parameters used by the convenience methods
VAR_INPUT
END_VAR
 _params := _noParameters;
END_METHOD

METHOD CopyFactsheet : UDINT
/// Copies the received factsheet (raw JSON); returns the length
VAR_INPUT
  /// Target buffer
  pDest    : POINTER TO BYTE;
  /// Size of the target buffer
  DestSize : UDINT;
END_VAR
  IF (( _factsheetLength = 0 ) OR ( _factsheetLength > DestSize ))
  THEN
    RETURN;
  END_IF

  SysDepMemCpy(pDest := pDest, pSrc := ADR(_factsheet), DataLen := _factsheetLength);
  CopyFactsheet := _factsheetLength;
END_METHOD

PROPERTY FactsheetLength : UDINT
/// Length of the received factsheet
GET
VAR
END_VAR
  FactsheetLength := _factsheetLength;
END_GET
END_PROPERTY

METHOD PROTECTED FindRequest : DINT
/// Slot of an own request (0 = unknown)
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Slot
 _i : DINT;
END_VAR
  IF ( RequestId = '' )
  THEN
    RETURN;
  END_IF

  FOR _i := 1 TO M2XLibraryParameter.CLIENT_REQUESTS_MAX
  DO
    IF (( _requests[_i].Used ) AND ( _requests[_i].RequestId = RequestId ))
    THEN
      FindRequest := _i;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD ForgetRequest : BOOL
/// Stops tracking a request
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Slot
 _i : DINT;
END_VAR
 _i := FindRequest(RequestId := RequestId);
  IF ( _i > 0 )
  THEN
   _requests[_i].Used  := FALSE;
    ForgetRequest      := TRUE;
  END_IF
END_METHOD

METHOD GetError : BOOL
/// Error of the last state (Index 1..ErrorCount)
VAR_INPUT
  /// Index 1..ErrorCount
  Index : DINT;
END_VAR
VAR_IN_OUT
  /// Error
  Error : ErrorData;
END_VAR
  IF (( Index < 1 ) OR ( Index > ErrorCount ))
  THEN
    RETURN;
  END_IF

  Error    := _errors[Index];
  GetError := TRUE;
END_METHOD

METHOD GetRequestStatus : RequestStatusEnum
/// Status of an own request reported by the entity (NONE = not yet reported or unknown)
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Slot
 _i : DINT;
END_VAR
 _i := FindRequest(RequestId := RequestId);
  IF ( _i > 0 )
  THEN
    GetRequestStatus := _requests[_i].RequestStatus;
  END_IF
END_METHOD

METHOD GetResultDescription : STRING(255)
/// Result description of an own request
VAR_INPUT
  /// Request id
  RequestId : STRING(64);
END_VAR
VAR
  /// Slot
 _i : DINT;
END_VAR
 _i := FindRequest(RequestId := RequestId);
  IF ( _i > 0 )
  THEN
    GetResultDescription := _requests[_i].ResultDescription;
  END_IF
END_METHOD

METHOD PRIVATE HandleMessage
/// Handles a received message
VAR_INPUT
END_VAR
  IF ( _message.Topic = _stateTopic )
  THEN
    IF (( _message.Oversized ) OR
        ( NOT _parser.Parse(pData := ADR(_message.Payload), Length := _message.PayloadLength) ) OR
        ( _parser.GetType(Token := 0) <> JsonTokenTypeEnum.JSON_OBJECT ))
    THEN
      InvalidMessages := InvalidMessages + 1;
      RETURN;
    END_IF
    StateReceived := TRUE;
    StateCount    := StateCount + 1;
    ErrorCount    := 0;
    ParseStateContent(Root := 0);

  ELSIF ( _message.Topic = _factsheetTopic )
  THEN
    IF ( _message.Oversized )
    THEN
      InvalidMessages := InvalidMessages + 1;
      RETURN;
    END_IF
    SysDepMemCpy(pDest := ADR(_factsheet), pSrc := ADR(_message.Payload), DataLen := _message.PayloadLength);
   _factsheetLength   := _message.PayloadLength;
    FactsheetReceived := TRUE;
    IF ( _parser.Parse(pData := ADR(_factsheet), Length := _factsheetLength) )
    THEN
      ParseFactsheetContent(Root := 0);
    END_IF
  END_IF
END_METHOD

METHOD HasError : BOOL
/// The last state contains an error of the type (and request, if given)
VAR_INPUT
  /// Error type
  ErrorType : STRING(64);
  /// Request id ('' = any)
  RequestId : STRING(64);
END_VAR
VAR
  /// Error index
 _i : DINT;
END_VAR
  FOR _i := 1 TO ErrorCount
  DO
    IF (( _errors[_i].ErrorType = ErrorType ) AND (( RequestId = '' ) OR ( _errors[_i].RequestId = RequestId )))
    THEN
      HasError := TRUE;
      RETURN;
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED ParseErrors
/// Adds the errors of an errors array (duplicates are skipped)
VAR_INPUT
  /// errors array token
  ArrayToken : DINT;
END_VAR
VAR
  /// Item index
 _i     : DINT;
  /// Error index
 _e     : DINT;
  /// Duplicate found
 _dup   : BOOL;
END_VAR
  FOR _i := 0 TO _parser.GetSize(Token := ArrayToken) - 1
  DO
    IF ( ErrorCount >= M2XLibraryParameter.ERRORS_MAX )
    THEN
      RETURN;
    END_IF
    IF ( ParseError(Parser := _parser, Error := _errors[ErrorCount + 1], Token := _parser.GetArrayItem(ArrayToken := ArrayToken, Index := _i)) )
    THEN
     _dup := FALSE;
      FOR _e := 1 TO ErrorCount
      DO
        IF (( _errors[_e].ErrorType = _errors[ErrorCount + 1].ErrorType ) AND ( _errors[_e].RequestId = _errors[ErrorCount + 1].RequestId ))
        THEN
         _dup := TRUE;
        END_IF
      END_FOR
      IF ( NOT _dup )
      THEN
        ErrorCount := ErrorCount + 1;
      END_IF
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED ParseFactsheetContent
/// Hook: interface specific content of the factsheet
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
END_METHOD

METHOD PROTECTED ParseRequestStateExtras
/// Hook: interface specific fields of a requestStates item of an own request
VAR_INPUT
  /// requestStates item
  Item : DINT;
  /// Slot of the own request
  Slot : DINT;
END_VAR
END_METHOD

METHOD PROTECTED ParseRequestStates
/// Updates the own requests from a requestStates array
VAR_INPUT
  /// requestStates array token
  ArrayToken : DINT;
END_VAR
VAR
  /// Item token
 _item : DINT;
  /// Item index
 _i    : DINT;
  /// Slot of the own request
 _slot : DINT;
END_VAR
  FOR _i := 0 TO _parser.GetSize(Token := ArrayToken) - 1
  DO
   _item := _parser.GetArrayItem(ArrayToken := ArrayToken, Index := _i);
   _slot := FindRequest(RequestId := _parser.GetStringByKey(ObjectToken := _item, Key := 'requestId'));
    IF ( _slot > 0 )
    THEN
     _requests[_slot].RequestStatus     := RequestStatusFromString(_parser.GetStringByKey(ObjectToken := _item, Key := 'requestStatus'));
     _requests[_slot].ResultDescription := _parser.GetStringByKey(ObjectToken := _item, Key := 'resultDescription');
      ParseRequestStateExtras(Item := _item, Slot := _slot);
    END_IF
  END_FOR
END_METHOD

METHOD PROTECTED ParseStateContent
/// Hook: interface specific content of the state (default: connectionState, requestStates, errors at top level)
VAR_INPUT
  /// Root token
  Root : DINT;
END_VAR
  RemoteConnectionState := ConnectionStateFromString(_parser.GetStringByKey(ObjectToken := Root, Key := 'connectionState'));
  ParseRequestStates(ArrayToken := _parser.FindKey(ObjectToken := Root, Key := 'requestStates'));
  ParseErrors(ArrayToken := _parser.FindKey(ObjectToken := Root, Key := 'errors'));
END_METHOD

METHOD RequestFactsheet : STRING(64)
/// Requests the factsheet; returns the request id
VAR_INPUT
END_VAR
  RequestFactsheet := SendRequest(RequestType := RequestTypeEnum.REQUEST_FACTSHEET, Description := '', Parameters := _noParameters);
END_METHOD

METHOD SendRequest : STRING(64)
/// Sends a request; returns the request id ('' if not sent)
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
  /// Request description (optional)
  Description : STRING(255);
END_VAR
VAR_IN_OUT
  /// Request parameters
  Parameters : RequestParameterData;
END_VAR
VAR
  /// New request id
 _requestId : STRING(64);
  /// Slot for tracking
 _slot      : DINT;
  /// Entry index
 _i         : DINT;
END_VAR
  IF ( NOT Connected )
  THEN
    RETURN;
  END_IF

 _requestId := _uuid.NewUuid();

 _writer.Reset();
 _writer.BeginObject();
 _writer.AddInteger(Name := 'headerId', Value := _headerId);
 _writer.AddString(Name := 'timestamp', Value := GetTimestamp());
 _writer.AddString(Name := 'version',   Value := Config.ProtocolVersion);
 _writer.AddStringOptional(Name := 'senderId', Value := SenderId);
 _writer.Key(Name := 'requests');
 _writer.BeginArray();
 _writer.BeginObject();
 _writer.AddString(Name := 'requestType', Value := RequestTypeToString(RequestType));
 _writer.AddString(Name := 'requestId',   Value := _requestId);
 _writer.AddStringOptional(Name := 'requestDescription', Value := Description);
 _writer.Key(Name := 'requestParameters');
 _writer.BeginArray();
  WriteRequestParameterItems(Writer := _writer, Parameters := Parameters);
  WriteCustomParameters(RequestType := RequestType);
 _writer.EndArray();
 _writer.EndObject();
 _writer.EndArray();
 _writer.EndObject();

  IF ( _writer.Overflow )
  THEN
    RETURN;
  END_IF

  IF ( NOT Transport.Publish(Topic := _requestTopic, pPayload := _writer.Data, PayloadLength := _writer.Length, RetainFlag := FALSE) )
  THEN
    RETURN;
  END_IF
 _headerId := _headerId + 1;

  // track the request: free slot, else oldest final, else oldest
  FOR _i := 1 TO M2XLibraryParameter.CLIENT_REQUESTS_MAX
  DO
    IF ( NOT _requests[_i].Used )
    THEN
     _slot := _i;
      EXIT;
    END_IF
  END_FOR
  IF ( _slot = 0 )
  THEN
    FOR _i := 1 TO M2XLibraryParameter.CLIENT_REQUESTS_MAX
    DO
      IF (( _requests[_i].RequestStatus = RequestStatusEnum.FINISHED ) OR ( _requests[_i].RequestStatus = RequestStatusEnum.FAILED ))
      THEN
        // OR_ELSE: _requests[_slot] must not be read while _slot = 0
        IF (( _slot = 0 ) OR_ELSE ( _requests[_i].SendTime < _requests[_slot].SendTime ))
        THEN
         _slot := _i;
        END_IF
      END_IF
    END_FOR
  END_IF
  IF ( _slot = 0 )
  THEN
   _slot := 1;
    FOR _i := 2 TO M2XLibraryParameter.CLIENT_REQUESTS_MAX
    DO
      IF ( _requests[_i].SendTime < _requests[_slot].SendTime )
      THEN
       _slot := _i;
      END_IF
    END_FOR
  END_IF

 _requests[_slot].Used              := TRUE;
 _requests[_slot].RequestId         := _requestId;
 _requests[_slot].RequestType       := RequestType;
 _requests[_slot].RequestStatus     := RequestStatusEnum.NONE;
 _requests[_slot].ResultDescription := '';
 _requests[_slot].SendTime          := TIME();

  SendRequest := _requestId;
END_METHOD

METHOD PROTECTED WriteCustomParameters
/// Hook: additional items of the requestParameters array (e.g. transport order)
VAR_INPUT
  /// Request type
  RequestType : RequestTypeEnum;
END_VAR
END_METHOD

END_FUNCTION_BLOCK
