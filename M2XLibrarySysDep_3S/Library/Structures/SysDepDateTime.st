/// Date and time (UTC) of the system dependencies
TYPE SysDepDateTime :
STRUCT
	/// Year
	Year: UINT;
	/// Month 1..12
	Month: UINT;
	/// Day 1..31
	Day: UINT;
	/// Hour 0..23
	Hour: UINT;
	/// Minute 0..59
	Minute: UINT;
	/// Second 0..59
	Second: UINT;
	/// Millisecond 0..999
	Millisecond: UINT;
END_STRUCT
END_TYPE
