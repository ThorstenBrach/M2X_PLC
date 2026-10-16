// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      LoadHandlingUnitData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Load handling unit (LHU)
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
/// Load handling unit (LHU)
TYPE LoadHandlingUnitData :
STRUCT
  /// ID of the LHU (optional)
  LoadUnitId           : STRING(64);
  /// Type of the LHU, e.g. euro_pallet
  LoadHandlingUnitType : STRING(64);
  /// Weight is valid
  WeightValid          : BOOL;
  /// Weight of the load
  Weight               : LREAL;
  /// Height, width and length are valid
  DimensionsValid      : BOOL;
  /// Height (outer dimension)
  Height               : LREAL;
  /// Width (outer dimension)
  Width                : LREAL;
  /// Length (outer dimension)
  Length               : LREAL;
  /// Outer packaging (optional)
  OuterPackaging       : STRING(64);
  /// Symmetrical is valid
  SymmetricalValid     : BOOL;
  /// Orientation of the LHU is symmetrical
  Symmetrical          : BOOL;
END_STRUCT
END_TYPE
