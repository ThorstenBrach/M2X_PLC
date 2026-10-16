/// System dependent reading of the current UTC date and time
FUNCTION SysDepGetUtcTime : BOOL
// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepGetUtcTime
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    System dependent reading of the current UTC date and time
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
VAR_IN_OUT
  /// Current UTC date and time
  DateTime : SysDepDateTime;
END_VAR
VAR
  /// System time in 100 ns since 1601-01-01 (UTC)
 _now      : ULINT;
  /// File time
 _fileTime : T_FILETIME;
  /// System time structure
 _time     : TIMESTRUCT;
END_VAR
 _now                     := F_GetSystemTime();
 _fileTime.dwLowDateTime  := ULINT_TO_DWORD(_now AND 16#FFFFFFFF);
 _fileTime.dwHighDateTime := ULINT_TO_DWORD(SHR(_now, 32));
 _time                    := FILETIME_TO_SYSTEMTIME(_fileTime);

  DateTime.Year        := _time.wYear;
  DateTime.Month       := _time.wMonth;
  DateTime.Day         := _time.wDay;
  DateTime.Hour        := _time.wHour;
  DateTime.Minute      := _time.wMinute;
  DateTime.Second      := _time.wSecond;
  DateTime.Millisecond := _time.wMilliseconds;

  SysDepGetUtcTime := TRUE;
END_FUNCTION
