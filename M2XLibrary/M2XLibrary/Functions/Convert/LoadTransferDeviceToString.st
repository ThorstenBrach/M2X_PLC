/// Converts LoadTransferDeviceEnum to its JSON text
FUNCTION LoadTransferDeviceToString : STRING(32)
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadTransferDeviceToString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts LoadTransferDeviceEnum to its JSON text
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
  /// Value to convert
  Value : LoadTransferDeviceEnum;
END_VAR
  CASE Value OF
    LoadTransferDeviceEnum.NONE                            : LoadTransferDeviceToString := '';
    LoadTransferDeviceEnum.MR                              : LoadTransferDeviceToString := 'MR';
    LoadTransferDeviceEnum.LHS                             : LoadTransferDeviceToString := 'LHS';
  ELSE
    LoadTransferDeviceToString := '';
  END_CASE
END_FUNCTION
