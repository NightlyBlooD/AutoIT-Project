#include <ASM.au3>

Func AsmCRC32($Data, $CRC32 = -1)
	Local $AsmObj = AsmInit()
	AsmAdd($AsmObj, "  enter   400h,0	           ")
	AsmAdd($AsmObj, "  push    ebx                 ")
	AsmAdd($AsmObj, "  mov     edx,0EDB88320h      ")
	AsmAdd($AsmObj, "  mov     ecx,100h            ")
	AsmAdd($AsmObj, "L3:                           ")
	AsmAdd($AsmObj, "  lea     eax,[ecx-1]         ")
	AsmAdd($AsmObj, "  push    ecx                 ")
	AsmAdd($AsmObj, "  push    8                   ")
	AsmAdd($AsmObj, "  pop     ecx                 ")
	AsmAdd($AsmObj, "L2:                           ")
	AsmAdd($AsmObj, "  shr     eax,1               ")
	AsmAdd($AsmObj, "  jnc     $+4                 ") ; jnc @L1
	AsmAdd($AsmObj, "  xor     eax,edx             ")
	AsmAdd($AsmObj, "L1:                           ")
	AsmAdd($AsmObj, "  loop    @L2                 ")
	AsmAdd($AsmObj, "  pop     ecx                 ")
	AsmAdd($AsmObj, "  mov     [ebp+ecx*4-404h],eax")
	AsmAdd($AsmObj, "  loop    @L3                 ")
	AsmAdd($AsmObj, "  mov     ebx,[ebp+8]         ")
	AsmAdd($AsmObj, "  mov     ecx,[ebp+0Ch]       ")
	AsmAdd($AsmObj, "  mov     eax,[ebp+10h]       ")
	AsmAdd($AsmObj, "  test    ebx,ebx             ")
	AsmAdd($AsmObj, "  je      $+19                ") ;je @L4
	AsmAdd($AsmObj, "  jecxz   $+17                ") ;jecxz @L4
	AsmAdd($AsmObj, "L5:                           ")
	AsmAdd($AsmObj, "  mov     dl,[ebx]            ")
	AsmAdd($AsmObj, "  xor     dl,al               ")
	AsmAdd($AsmObj, "  movzx   edx,dl              ")
	AsmAdd($AsmObj, "  shr     eax,8               ")
	AsmAdd($AsmObj, "  xor     eax,[ebp+edx*4-400h]")
	AsmAdd($AsmObj, "  inc     ebx                 ")
	AsmAdd($AsmObj, "  loop    @L5                 ")
	AsmAdd($AsmObj, "L4:                           ")
	AsmAdd($AsmObj, "  not     eax                 ")
	AsmAdd($AsmObj, "  pop     ebx                 ")
	AsmAdd($AsmObj, "  leave                       ")
	AsmAdd($AsmObj, "  ret                         ")
	
	Local $Input = DllStructCreate("byte[" & BinaryLen($Data) & "]")
	DllStructSetData($Input, 1, $Data)
	
	Local $Ret = MemoryFuncCall("uint:cdecl", AsmGetPtr($AsmObj), "ptr", DllStructGetPtr($Input), "uint", BinaryLen($Data), "int", $CRC32)
	AsmExit($AsmObj)
	
	Return $Ret[0]
EndFunc

$CRC32 = AsmCRC32("The quick brown fox jumps over the lazy dog")
MsgBox(0, 'Method 1 Result', Hex($CRC32))

