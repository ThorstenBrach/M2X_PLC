/// Current UTC time in ISO8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)
FUNCTION GetTimestamp : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      GetTimestamp
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Current UTC time in ISO8601 format (YYYY-MM-DDTHH:mm:ss.sssZ)
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
VAR
  /// Current UTC time
 _now : SysDepDateTime;
END_VAR
  SysDepGetUtcTime(DateTime := _now);

  GetTimestamp := CONCAT(UintToPaddedString(Value := _now.Year,  Digits := 4), '-');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Month,  Digits := 2));
  GetTimestamp := CONCAT(GetTimestamp, '-');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Day,    Digits := 2));
  GetTimestamp := CONCAT(GetTimestamp, 'T');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Hour,   Digits := 2));
  GetTimestamp := CONCAT(GetTimestamp, ':');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Minute, Digits := 2));
  GetTimestamp := CONCAT(GetTimestamp, ':');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Second, Digits := 2));
  GetTimestamp := CONCAT(GetTimestamp, '.');
  GetTimestamp := CONCAT(GetTimestamp, UintToPaddedString(Value := _now.Millisecond, Digits := 3));
  GetTimestamp := CONCAT(GetTimestamp, 'Z');
END_FUNCTION
