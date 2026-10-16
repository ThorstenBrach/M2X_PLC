/// System dependent implementation of the memory compare function (0 = equal)
FUNCTION SysDepMemCmp : DINT
VAR_INPUT
	/// Pointer to 1st memory area
	pData1: POINTER TO BYTE;
	/// Pointer to 2nd memory area
	pData2: POINTER TO BYTE;
	/// Amount of bytes to be compared
	DataLen: UDINT;
END_VAR
  SysDepMemCmp := SysMem.SysMemCmp(pBuffer1 := pData1, pBuffer2 := pData2, udiCount := DataLen);
END_FUNCTION
