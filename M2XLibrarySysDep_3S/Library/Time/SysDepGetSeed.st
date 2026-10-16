/// System dependent seed for the random number generator
FUNCTION SysDepGetSeed : UDINT
VAR
	/// Real time clock in ms since 1970-01-01 (UTC)
	_now: ULINT;
	/// Result of the system call
	_result: RTS_IEC_RESULT;
END_VAR
 _result := SysTimeRtc.SysTimeRtcHighResGet(pTimestamp := ADR(_now));

  SysDepGetSeed := ULINT_TO_UDINT(_now) XOR ULINT_TO_UDINT(SHR(_now, 32));
END_FUNCTION
