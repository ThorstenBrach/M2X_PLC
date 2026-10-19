/// System dependent MQTT client (CODESYS: binding to the MQTT library still open)
FUNCTION_BLOCK SysDepMqttClientFB
VAR_INPUT
	/// Connect to the broker
	Enable: BOOL;
	/// Client configuration (read when Enable becomes TRUE)
	Config: SysDepMqttConfig;
END_VAR
VAR_OUTPUT
	/// Client is connected to the broker
	Connected: BOOL;
	/// Client reports an error
	Error: BOOL;
	/// Error code of the platform
	ErrorId: UDINT;
END_VAR
VAR CONSTANT
	/// Error code: no MQTT library bound yet
	ERROR_NOT_IMPLEMENTED: UDINT := 16#FFFF;
END_VAR
  // TODO: bind the MQTT library of the target (e.g. CODESYS IIoT Libraries SL)
  Connected := FALSE;
  Error     := Enable;

  IF ( Enable )
  THEN
    ErrorId := ERROR_NOT_IMPLEMENTED;
  ELSE
    ErrorId := 0;
  END_IF

METHOD Publish : BOOL
VAR_INPUT
	/// Topic
	Topic: STRING(255);
	/// Payload
	pPayload: POINTER TO BYTE;
	/// Length of the payload
	PayloadLength: UDINT;
	/// Quality of service
	QoS: SysDepMqttQoS;
	/// Retain flag
	RetainFlag: BOOL;
END_VAR
  Publish := FALSE;
END_METHOD

METHOD Receive : BOOL
VAR_INPUT
	/// Buffer for the topic (null-terminated string)
	pTopic: POINTER TO BYTE;
	/// Size of the topic buffer in bytes
	TopicSize: UDINT;
	/// Buffer for the payload
	pPayload: POINTER TO BYTE;
	/// Size of the payload buffer in bytes
	PayloadSize: UDINT;
END_VAR
VAR_IN_OUT
	/// Length of the received payload
	PayloadLength: UDINT;
	/// Payload did not fit into the buffer
	Oversized: BOOL;
END_VAR
  Receive := FALSE;
END_METHOD

METHOD SetLastWill : BOOL
VAR_INPUT
	/// Topic of the last will
	Topic: STRING(255);
	/// Payload of the last will
	pPayload: POINTER TO BYTE;
	/// Length of the payload
	PayloadLength: UDINT;
	/// Quality of service
	QoS: SysDepMqttQoS;
	/// Retain flag
	RetainFlag: BOOL;
END_VAR
  SetLastWill := FALSE;
END_METHOD

METHOD Subscribe : BOOL
VAR_INPUT
	/// Topic filter
	Topic: STRING(255);
	/// Quality of service
	QoS: SysDepMqttQoS;
END_VAR
  Subscribe := FALSE;
END_METHOD

END_FUNCTION_BLOCK
