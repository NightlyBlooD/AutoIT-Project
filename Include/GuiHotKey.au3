#include-once

#include <WindowsConstants.au3>
#include <WinAPI.au3>

; #VARIABLES# ===================================================================================================================
Global Const $HKM_SETHOTKEY = $WM_USER + 1
Global Const $HKM_GETHOTKEY = $WM_USER + 2
Global Const $HKM_SETRULES = $WM_USER + 3

Global Const $HOTKEYF_SHIFT   = 0x01
Global Const $HOTKEYF_CONTROL = 0x02
Global Const $HOTKEYF_ALT     = 0x04
;Global Const $HOTKEYF_EXT     = 0x80

Global Const $MOD_ALT     = 0x1
Global Const $MOD_CONTROL = 0x2
Global Const $MOD_SHIFT   = 0x4

Global Const $WM_HOTKEY = 0x312
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_Create
; Description ...: Create a HotKey control
; Syntax.........: _GuiCtrlHotKey_Create($hWnd, $sX, $sY[, $sWidth = 100[, $sHeight = 20[, $sStyle = 0]]])
; Parameters ....: $hWnd        - Handle to parent or owner window
;                  $iX          - Horizontal position of the control
;                  $iY          - Vertical position of the control
;                  $iWidth      - Control width
;                  $iHeight     - Control height
;                  $iStyle      - Control styles
; Return values .: Success      - Handle to the HotKey control
;                  Failure      - 0
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_Create($hWnd, $sX, $sY, $sWidth = 100, $sHeight = 20, $sStyle = 0)
	$sStyle = BitOR($sStyle, $WS_CHILD, $WS_VISIBLE, $WS_TABSTOP)
	
	Local $hHotkey = _WinAPI_CreateWindowEx(0, "msctls_hotkey32", "", $sStyle, $sX, $sY, $sWidth, $sHeight, $hWnd)
	_SendMessage($hHotkey, $WM_SETFONT, _WinAPI_GetStockObject($DEFAULT_GUI_FONT), True)
	
	Return $hHotkey
EndFunc   ;==>_GuiCtrlHotKey_Create

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_Destroy
; Description ...: Delete the HotKey control
; Syntax.........: _GuiCtrlHotKey_Destroy($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - True
;                  Failure      - False
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_Destroy($hWnd)
	Return _WinAPI_DestroyWindow($hWnd)
EndFunc   ;==>_GuiCtrlHotKey_Destroy

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_GetHotkey
; Description ...: Retrieve the virtual key code and modifier flags of a hot key from a HotKey control
; Syntax.........: _GuiCtrlHotKey_GetHotkey($hWnd)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - Array with the following format:
;				   |[0] - virtual key code
;				   |[1] - modifier flags
;                  Failure      - False
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_GetHotkey($hWnd)
	Local $iVal = _SendMessage($hWnd, $HKM_GETHOTKEY, 0, 0)
	
	If $iVal = 0 Then Return False
	
	Local $aRet[2]
	$aRet[0] = BitAND($iVal, 0x000000FF) ;The LOBYTE of the LOWORD is the virtual key code of the hot key
	$aRet[1] = BitShift($iVal, 8) 		 ;The HIBYTE of the LOWORD is the key modifier that specifies the keys that _
										 ;define a hot key combination
									 
	Return $aRet
EndFunc   ;==>_GuiCtrlHotKey_GetHotkey

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_SetHotkey
; Description ...: Set the virtual key code and modifier flags of an HotKey control
; Syntax.........: _GuiCtrlHotKey_SetHotkey($hWnd, $sVirtKey[, $sModKey])
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Always returns zero
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_SetHotkey($hWnd, $sVirtKey, $sModKey = 0)
	_SendMessage($hWnd, $HKM_SETHOTKEY, _MakeWord($sVirtKey, $sModKey), 0)
EndFunc   ;==>_GuiCtrlHotKey_SetHotkey

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_RegisterHotkey
; Description ...: Defines a system-wide hot key
; Syntax.........: _GuiCtrlHotKey_RegisterHotkey($hWnd, $sID, $sVirtKey, $sModKey)
; Parameters ....: $hWnd        - Handle to the main window that will receive messages generated by the hot key
;				   $sID			- The identifier of the hot key
;				   $sVirtKey	- The virtual-key code of the hot key
;				   $sModKey		- The modifier flags
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_RegisterHotkey($hWnd, $sID, $sVirtKey, $sModKey)
	Local $iModKey = 0
	
	If BitAND($sModKey, $HOTKEYF_SHIFT) Then $iModKey = BitOR($iModKey, $MOD_SHIFT)
	If BitAND($sModKey, $HOTKEYF_CONTROL) Then $iModKey = BitOR($iModKey, $HOTKEYF_CONTROL)
	If BitAND($sModKey, $HOTKEYF_ALT) Then $iModKey = BitOR($iModKey, $MOD_ALT)
	
	$aRet = DllCall("user32.dll", "int", "RegisterHotKey", _
											"hwnd", $hWnd, _
											"int", $sID, _
											"int", $iModKey, _
											"int", "0x" & Hex($sVirtKey, 2))
	
	If $aRet[0] <> 0 Then Return 1
EndFunc   ;==>_GuiCtrlHotKey_RegisterHotkey

; #FUNCTION# ====================================================================================================================
; Name...........: _GuiCtrlHotKey_UnregisterHotkey
; Description ...: Frees a hot key previously registered by the calling thread
; Syntax.........: _GuiCtrlHotKey_UnregisterHotkey($hWnd, $sID)
; Parameters ....: $hWnd        - Handle to the main window that will receive messages generated by the hot key
;				   $sID			- The identifier of the hot key
; Return values .: Success      - 1
;                  Failure      - 0
; Author ........: R. Gilman (rasim)
; ===============================================================================================================================
Func _GuiCtrlHotKey_UnregisterHotkey($hWnd, $sID)
	$aRet = DllCall("user32.dll", "int", "UnregisterHotKey", _
											"hwnd", $hWnd, _
											"int", $sID)
	
	If $aRet[0] <> 0 Then Return 1
EndFunc   ;==>_GuiCtrlHotKey_UnregisterHotkey

; #FUNCTION# ====================================================================================================================
; Name...........: _MakeWord
; Description ...: Creates a WORD value by concatenating the specified values
; Syntax.........: _MakeWord($sLoBite, $sHiByte)
; Parameters ....: $hWnd        - Handle to the control
;				   $sID			- The identifier of the hot key
; Return values .: The WORD value
; Author ........: R. Gilman (rasim)
; Remarks .......: Internal use only
; ===============================================================================================================================
Func _MakeWord($sLoBite, $sHiByte)
	Return BitOR($sLoBite, $sHiByte * 0x100)
EndFunc   ;==>_MakeWord