/// Writes a transport order object
FUNCTION WriteTransportOrder : BOOL
// -------------------------------------------------------------------------
//  M2X Library
// -------------------------------------------------------------------------
//
//  Object:      WriteTransportOrder
//  Author:      Thorsten Brach
//  Date:        2026-10-15
//
//  Description:
//    Writes a transport order object
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
  /// JSON writer
  Writer : JsonWriterFB;
  /// Transport order
  Order  : TransportOrderData;
END_VAR
VAR_INPUT
  /// Protocol version
  Version : STRING(16);
END_VAR
VAR
  /// Objective index
 _idx : DINT;
END_VAR
  Writer.BeginObject();
  Writer.AddString(Name := 'version',          Value := Version);
  Writer.AddString(Name := 'timestamp',        Value := GetTimestamp());
  Writer.AddString(Name := 'transportOrderId', Value := Order.TransportOrderId);
  Writer.AddInteger(Name := 'transportOrderUpdateId', Value := Order.TransportOrderUpdateId);
  Writer.AddBool(Name := 'isObjectiveListComplete',   Value := Order.IsObjectiveListComplete);
  Writer.AddStringOptional(Name := 'resourceId', Value := Order.ResourceId);
  Writer.AddStringOptional(Name := 'priority',   Value := PriorityToString(Order.Priority));
  Writer.Key(Name := 'objectives');
  Writer.BeginArray();
  FOR _idx := 1 TO MIN(Order.ObjectiveCount, M2XLibraryParameter.OBJECTIVES_MAX)
  DO
    WriteObjective(Writer := Writer, Objective := Order.Objectives[_idx], IsState := FALSE);
  END_FOR
  Writer.EndArray();
  Writer.EndObject();
  WriteTransportOrder := TRUE;
END_FUNCTION
