// -------------------------------------------------------------------------
//  M2X Library System Dependencies
// -------------------------------------------------------------------------
//
//  Object:      SysDepDateTime
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Date and time (UTC) of the system dependencies
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
/// Date and time (UTC) of the system dependencies
TYPE SysDepDateTime :
STRUCT
  /// Year
  Year        : UINT;
  /// Month 1..12
  Month       : UINT;
  /// Day 1..31
  Day         : UINT;
  /// Hour 0..23
  Hour        : UINT;
  /// Minute 0..59
  Minute      : UINT;
  /// Second 0..59
  Second      : UINT;
  /// Millisecond 0..999
  Millisecond : UINT;
END_STRUCT
END_TYPE
