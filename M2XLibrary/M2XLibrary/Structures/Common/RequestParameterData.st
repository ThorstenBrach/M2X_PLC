// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      RequestParameterData
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Request parameters of all interfaces (empty string / NONE = parameter not set)
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
/// Request parameters of all interfaces (empty string / NONE = parameter not set)
TYPE RequestParameterData :
STRUCT
  /// Load handling: session id
  LoadHandlingSessionId    : STRING(64);
  /// Load handling: load handling point id
  LoadHandlingPointId      : STRING(64);
  /// Load handling / elevator: vehicle type
  VehicleType              : STRING(64);
  /// Load handling: PICK or DROP
  LoadAction               : LoadActionEnum;
  /// Load handling: load handling unit is set
  LoadHandlingUnitValid    : BOOL;
  /// Load handling: load handling unit
  LoadHandlingUnit         : LoadHandlingUnitData;
  /// Load handling: active load transfer device
  ActiveLoadTransferDevice : LoadTransferDeviceEnum;
  /// Door: door id
  DoorId                   : STRING(64);
  /// Door: requested door status
  DoorStatus               : DoorStatusEnum;
  /// Signaling device: signal id
  SignalId                 : STRING(64);
  /// Elevator: session id
  ElevatorSessionId        : STRING(64);
  /// Elevator: floor where the MR waits
  RequestedFloor           : STRING(64);
  /// Elevator: intended target floor
  IntendedTargetFloor      : STRING(64);
  /// Elevator: target floor of requestChangeFloor
  TargetFloor              : STRING(64);
  /// Elevator: operation mode of requestManualMode
  OperationMode            : OperationModeEnum;
  /// Charging device: session id
  ChargingSessionId        : STRING(64);
  /// Transport order: transport order id (requestCancel)
  TransportOrderId         : STRING(64);
  /// Transport order: IsCanceled is set
  IsCanceledValid          : BOOL;
  /// Transport order: cancel flag
  IsCanceled               : BOOL;
END_STRUCT
END_TYPE
