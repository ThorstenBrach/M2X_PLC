/// System dependent implementation of the memory copy function
FUNCTION SysDepMemCpy : UDINT
VAR_INPUT
	/// Pointer to memory address to be copied to (target)
	pDest: POINTER TO BYTE;
	/// Pointer to memory address to be copied from (source)
	pSrc: POINTER TO BYTE;
	/// Amount of bytes to be copied
	DataLen: UDINT;
END_VAR
  SysMem.SysMemCpy(pDest := pDest, pSrc := pSrc, udiCount := DataLen);
  SysDepMemCpy := DataLen;
END_FUNCTION
