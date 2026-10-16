/// MQTT quality of service
{attribute 'qualified_only' := ''}
TYPE SysDepMqttQoS :
(
	/// QoS 0
	AT_MOST_ONCE := 0,
	/// QoS 1
	AT_LEAST_ONCE := 1,
	/// QoS 2
	EXACTLY_ONCE := 2
);
END_TYPE
