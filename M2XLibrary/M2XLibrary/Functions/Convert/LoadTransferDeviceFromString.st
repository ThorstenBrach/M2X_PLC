/// Converts the JSON text to LoadTransferDeviceEnum (LoadTransferDeviceEnum.NONE if unknown)
FUNCTION LoadTransferDeviceFromString : LoadTransferDeviceEnum
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadTransferDeviceFromString
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Converts the JSON text to LoadTransferDeviceEnum (LoadTransferDeviceEnum.NONE if unknown)
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
  /// Text to convert
  Text : STRING(64);
END_VAR
  LoadTransferDeviceFromString := LoadTransferDeviceEnum.NONE;

  IF ( Text = 'MR' )
  THEN
    LoadTransferDeviceFromString := LoadTransferDeviceEnum.MR;
    RETURN;
  END_IF

  IF ( Text = 'LHS' )
  THEN
    LoadTransferDeviceFromString := LoadTransferDeviceEnum.LHS;
    RETURN;
  END_IF
END_FUNCTION
