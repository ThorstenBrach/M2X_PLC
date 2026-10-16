/// System dependent reading of the current UTC date and time
FUNCTION SysDepGetUtcTime : BOOL
VAR_IN_OUT
	/// Current UTC date and time
	DateTime: SysDepDateTime;
END_VAR
VAR
	/// Real time clock in ms since 1970-01-01 (UTC)
	_now: ULINT;
	/// Result of the system call
	_result: RTS_IEC_RESULT;
	/// Milliseconds of the current day
	_msOfDay: ULINT;
	/// Days since 1970-01-01, shifted to 0000-03-01
	_z: DINT;
	/// Era of 400 years
	_era: DINT;
	/// Day of the era 0..146096
	_doe: DINT;
	/// Year of the era 0..399
	_yoe: DINT;
	/// Day of the year, starting at March 1st
	_doy: DINT;
	/// Month, starting at March = 0
	_mp: DINT;
	/// Month 1..12
	_month: DINT;
	/// Year
	_year: DINT;
END_VAR
 _result := SysTimeRtc.SysTimeRtcHighResGet(pTimestamp := ADR(_now));
  IF ( _result <> 0 )
  THEN
    RETURN;
  END_IF

 _msOfDay := _now MOD 86400000;

  // Civil date from days since 1970-01-01 (H. Hinnant, days_from_civil inverse)
 _z     := ULINT_TO_DINT(_now / 86400000) + 719468;
 _era   := _z / 146097;
 _doe   := _z - _era * 146097;
 _yoe   := ( _doe - _doe / 1460 + _doe / 36524 - _doe / 146096 ) / 365;
 _doy   := _doe - ( 365 * _yoe + _yoe / 4 - _yoe / 100 );
 _mp    := ( 5 * _doy + 2 ) / 153;
 _year  := _yoe + _era * 400;

  IF ( _mp < 10 )
  THEN
   _month := _mp + 3;
  ELSE
   _month := _mp - 9;
  END_IF

  IF ( _month <= 2 )
  THEN
   _year := _year + 1;
  END_IF

  DateTime.Year        := DINT_TO_UINT(_year);
  DateTime.Month       := DINT_TO_UINT(_month);
  DateTime.Day         := DINT_TO_UINT(_doy - ( 153 * _mp + 2 ) / 5 + 1);
  DateTime.Hour        := ULINT_TO_UINT(_msOfDay / 3600000);
  DateTime.Minute      := ULINT_TO_UINT(( _msOfDay / 60000 ) MOD 60);
  DateTime.Second      := ULINT_TO_UINT(( _msOfDay / 1000 ) MOD 60);
  DateTime.Millisecond := ULINT_TO_UINT(_msOfDay MOD 1000);

  SysDepGetUtcTime := TRUE;
END_FUNCTION
