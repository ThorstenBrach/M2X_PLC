/// System dependent check whether an LREAL is a finite number
FUNCTION SysDepIsValidLReal : BOOL
VAR_INPUT
	/// Value to check
	Value: LREAL;
END_VAR
VAR
	/// Pointer to the bit pattern of the value
	_pBits: POINTER TO LWORD;
	/// Exponent of the IEEE 754 double
	_exponent: LWORD;
END_VAR
  // IEEE 754: exponent 16#7FF = infinity or NaN
 _pBits    := ADR(Value);
 _exponent := SHR(_pBits^, 52) AND 16#7FF;

  SysDepIsValidLReal := ( _exponent <> 16#7FF );
END_FUNCTION
