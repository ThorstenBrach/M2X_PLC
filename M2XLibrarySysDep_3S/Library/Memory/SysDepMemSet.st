/// System dependent implementation of the memory set function
FUNCTION SysDepMemSet : UDINT
VAR_INPUT
	/// Pointer to memory address to be filled (target)
	pDest: POINTER TO BYTE;
	/// Value with which the memory is initialized
	Value: BYTE;
	/// Amount of bytes to be initialized
	DataLen: UDINT;
END_VAR
  SysMem.SysMemSet(pDest := pDest, udiValue := BYTE_TO_UDINT(Value), udiCount := DataLen);
  SysDepMemSet := DataLen;
END_FUNCTION
