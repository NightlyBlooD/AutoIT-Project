#Region Header

#cs

	Title:			Hotkeys Input Control UDF Library for AutoIt3
	Filename:		HotKeyInput.au3
	Description:	Creates and manages an Hotkey Input control for the GUI
					(see "Shortcut key" input control in shortcut properties dialog box for example)
	Author:			Yashied
	Version:		1.2
	Requirements:	AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
	Uses:			StructureConstants.au3, WinAPI.au3, WindowsConstants.au3, vkArray.au3
	Notes:			-

	Available functions:
	
	_GUICtrlCreateHotKeyInput
	_GUICtrlDeleteHotKeyInput
	_GUICtrlReadHotKeyInput
	_GUICtrlSetHotKeyInput
	_GUICtrlReleaseHotKeyInput
	
	Additional features:
	
	_KeyLock
	_KeyUnlock
	_KeyLoadName
	_KeyToStr
	
	Example:

		#Include <GUIConstantsEx.au3>
		#Include <HotKeyInput.au3>

		Global $Form, $ButtonOk, $HotkeyInput1, $HotkeyInput2, $GUIMsg

		$Form = GUICreate('Test', 300, 160)
		GUISetFont(8.5, 400, 0, 'Tahoma', $Form)

		$HotkeyInput1 = _GUICtrlCreateHotKeyInput(0, 56, 55, 230, 20)
		$HotkeyInput2 = _GUICtrlCreateHotKeyInput(0, 56, 89, 230, 20)

		_KeyLock(0x062E) ; Lock CTRL-ALT-DEL for Hotkey Input control, but not for Windows

		GUICtrlCreateLabel('Hotkey1:', 10, 58, 44, 14)
		GUICtrlCreateLabel('Hotkey2:', 10, 92, 44, 14)
		GUICtrlCreateLabel('Click on Input box and hold a combination of keys.' & @CR & 'Press OK to view the code.', 10, 10, 280, 28)
		$ButtonOk = GUICtrlCreateButton('OK', 110, 124, 80, 23)
		GUICtrlSetState(-1, BitOR($GUI_DEFBUTTON, $GUI_FOCUS))
		GUISetState()

		While 1
			$GUIMsg = GUIGetMsg()
			Select
				Case $GUIMsg = $GUI_EVENT_CLOSE
					Exit
				Case $GUIMsg = $ButtonOk
					$t = '   Hotkey1:  0x' & StringRight(Hex(_GUICtrlReadHotKeyInput($HotkeyInput1)), 4) & '  (' & GUICtrlRead($HotkeyInput1) & ')   ' & @CR & @CR & _
						 '   Hotkey2:  0x' & StringRight(Hex(_GUICtrlReadHotKeyInput($HotkeyInput2)), 4) & '  (' & GUICtrlRead($HotkeyInput2) & ')   '
					MsgBox(0, 'Code', $t, 0, $Form)
			EndSelect
		WEnd

#ce

#Include-once

#Include <StructureConstants.au3>
#Include <WinAPI.au3>
#Include <WindowsConstants.au3>

#Include <vkArray.au3>

#EndRegion Header

#Region Local Variables and Constants

Global $OnHotKeyInputExit = Opt('OnExitFunc', 'OnHotKeyInputExit')

Dim $hkId[1][9] = [[0, 0, 0, 0, 0, 0, 0, 0]]

#cs
	
DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$hkId[0][0]   - Count item of array
	 [0][1]   - Interruption control flag (need to set this flag before changing $hkId array)
	 [0][2]   - Last key pressed (16-bit code)
	 [0][3]   - SCAW status (8-bit)
     [0][4]   - Handle to the user-defined DLL callback function (returned by DllCallbackRegister())
     [0][5]   - Handle to the hook procedure (returned by _WinAPI_SetWindowsHookEx())
	 [0][6]   - Index in array of the last control with the keyboard focus (don`t change it)
	 [0][7]   - Hold down key control flag
	 [0][8]   - Release key control flag
	 
$hkId[i][0]   - The control identifier (controlID) as returned by GUICtrlCreateInput()
	 [i][1]   - Handle of the given controlID (GUICtrlGetHandle($hkId[i][0]))
	 [i][2]   - Last hotkey code for Hotkey Input control
	 [i][3]   - Separating characters
	 [i][4-8] - Reserved
	
#ce

Dim $hkLock[1] = [0]

#cs
	
DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$hkLock[0] - Count item of array
	   [i] - Lock keys, these keys will not be blocked (16-bit code)

#ce

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlCreateHotKeyInput
; Description:		Creates a Hotkey Input control for the GUI.
; Syntax:			_GUICtrlCreateHotKeyInput ( $iKey, $iLeft, $iTop [, $iWidth [, $iHeight [, $iStyle [, $iExStyle [, $sSeparator]]]]] )
; Parameter(s):		$iKey       - Combined 16-bit hotkey code, which consists of upper and lower bytes. Value of bits shown in the following table.
;
;								  Hotkey code bits:
;
;								  0-7   - Specifies the virtual-key (VK) code of the key. Codes for the mouse buttons (0x01 - 0x06) are not supported.
;										 (http://msdn.microsoft.com/en-us/library/dd375731(VS.85).aspx)
;
;								  8     - SHIFT key
;								  9     - CONTROL key
;								  10    - ALT key
;								  11    - WIN key
;								  12-15 - Don`t used
;
;					$iLeft, $iTop, $iWidth, $iHeight, $iStyle, $iExStyle - See description for the GUICtrlCreateInput() function.
;					(http://www.autoitscript.com/autoit3/docs/functions/GUICtrlCreateInput.htm)
;
;					$sSeparator - Separating characters. Default is "-".
;
; Return Value(s):	Success: Returns the identifier (controlID) of the new control.
;					Failure: Returns 0.
; Author(s):		Yashied
;
; Note(s):			Use _GUICtrlDeleteHotKeyInput() to delete Hotkey Input control. DO NOT USE GUICtrlDelete()! To work with the Hotkey Input
;					control used functions designed to Input control. If you set the GUI_DISABLE state for control then Hotkey Input control
;					will not work until the state will be set to GUI_ENABLE. Before calling GUIDelete() remove all created Hotkey Input controls
;					by _GUICtrlReleaseHotKeyInput().
;====================================================================================================================================

Func _GUICtrlCreateHotKeyInput($iKey, $iLeft, $iTop, $iWidth = -1, $iHeight = -1, $iStyle = -1, $iExStyle = -1, $sSeparator = '-')

	Local $ID

	$iKey = BitAND($iKey, 0x0FFF)
	If BitAND($iKey, 0x00FF) = 0 Then
		$iKey = 0
	EndIf
	If $iStyle < 0 Then
		$iStyle = 0x0080
	EndIf
	If ($hkId[0][0] = 0) And ($hkId[0][5] = 0) Then
		$hkId[0][4] = DllCallbackRegister('_HotKeyInput_Hook', 'long', 'int;wparam;lparam')
		$hkId[0][5] = _WinAPI_SetWindowsHookEx($WH_KEYBOARD_LL, DllCallbackGetPtr($hkId[0][4]), _WinAPI_GetModuleHandle(0), 0)
		If (@error) Or ($hkId[0][5] = 0) Then
			Return 0
		EndIf
	EndIf
	$ID = GUICtrlCreateInput('', $iLeft, $iTop, $iWidth, $iHeight, BitOR($iStyle, 0x0800), $iExStyle)
	If $ID = 0 Then
		If $hkId[0][0] = 0 Then
			If _WinAPI_UnhookWindowsHookEx($hkId[0][5]) Then
				DllCallbackFree($hkId[0][4])
				$hkId[0][5] = 0
			EndIf
		EndIf
		Return 0
	EndIf
	GUICtrlSetBkColor($ID, 0xFFFFFF)
	GUICtrlSetData($ID, _KeyToStr($iKey, $sSeparator))
	ReDim $hkId[$hkId[0][0] + 2][UBound($hkId, 2)]
	$hkId[$hkId[0][0] + 1][0] = $ID
	$hkId[$hkId[0][0] + 1][1] = GUICtrlGetHandle($ID)
	$hkId[$hkId[0][0] + 1][2] = $iKey
	$hkId[$hkId[0][0] + 1][3] = $sSeparator
	$hkId[$hkId[0][0] + 1][4] = 0
	$hkId[$hkId[0][0] + 1][5] = 0
	$hkId[$hkId[0][0] + 1][6] = 0
	$hkId[$hkId[0][0] + 1][7] = 0
	$hkId[$hkId[0][0] + 1][8] = 0
	$hkId[0][0] += 1
	Return $ID
EndFunc   ;==>_GUICtrlCreateHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlDeleteHotKeyInput
; Description:		Deletes a Hotkey Input control.
; Syntax:			_GUICtrlDeleteHotKeyInput ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _GUICtrlDeleteHotKeyInput($controlID)

	Local $Index = _HotKeyInput_Focus(_WinAPI_GetFocus())

	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			$hkId[0][1] = 1
			If Not GUICtrlDelete($hkId[$i][0]) Then
;				$hkId[0][1] = 0
;				Return 0
			EndIf
			For $j = $i To $hkId[0][0] - 1
				For $k = 0 To UBound($hkId, 2) - 1
					$hkId[$j][$k] = $hkId[$j + 1][$k]
				Next
			Next
			$hkId[0][0] -= 1
			ReDim $hkId[$hkId[0][0] + 1][UBound($hkId, 2)]
			If $hkId[0][0] = 0 Then
				If _WinAPI_UnhookWindowsHookEx($hkId[0][5]) Then
					DllCallbackFree($hkId[0][4])
					$hkId[0][2] = 0
					$hkId[0][3] = 0
					$hkId[0][5] = 0
					$hkId[0][6] = 0
					$hkId[0][7] = 0
					$hkId[0][8] = 0
				EndIf
			EndIf
			If $i = $hkId[0][6] Then
				$hkId[0][6] = 0
			EndIf
			If $i = $Index Then
				$hkId[0][2] = 0
				$hkId[0][7] = 0
				$hkId[0][8] = 0
			EndIf
			$hkId[0][1] = 0
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_GUICtrlDeleteHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlReadHotKeyInput
; Description:		Reads a hotkey code from Hotkey Input control.
; Syntax:			_GUICtrlReadHotKeyInput ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
; Return Value(s):	Success: Returns combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			Use the GUICtrlRead() to obtain the string of hotkey.
;====================================================================================================================================

Func _GUICtrlReadHotKeyInput($controlID)

	Local $Ret = 0

	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			Return $hkId[$i][2]
		EndIf
	Next
	Return 0
EndFunc   ;==>_GUICtrlReadHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlSetHotKeyInput
; Description:		Modifies a data for a Hotkey Input control.
; Syntax:			_GUICtrlSetHotKeyInput ( $controlID, $iKey )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _GUICtrlCreateHotKeyInput() function.
;					$iKey      - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _GUICtrlSetHotKeyInput($controlID, $iKey)

	Local $Ret = 0

	$iKey = BitAND($iKey, 0x0FFF)
	If BitAND($iKey, 0x00FF) = 0 Then
		$iKey = 0
	EndIf
	For $i = 1 To $hkId[0][0]
		If $controlID = $hkId[$i][0] Then
			$hkId[0][1] = 1
			If GUICtrlSetData($hkId[$i][0], _KeyToStr($iKey, $hkId[$i][3])) Then
				If ($i = _HotKeyInput_Focus(_WinAPI_GetFocus())) And ($hkId[0][8] = 1) And (BitAND(BitXOR($iKey, $hkId[$i][2]), 0x00FF) > 0) Then
					$hkId[0][8] = 0
				EndIf
				$hkId[$i][2] = $iKey
				$Ret = 1
			EndIf
			ExitLoop
		EndIf
	Next
	$hkId[0][1] = 0
	Return $Ret
EndFunc   ;==>_GUICtrlSetHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_GUICtrlReleaseHotKeyInput
; Description:		Deletes all Hotkey Input control, which were created by a _GUICtrlCreateHotKeyInput() function.
; Syntax:			_GUICtrlReleaseHotKeyInput (  )
; Parameter(s):		None.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			Use this function before calling GUIDelete() to remove all created Hotkey Input controls.
;====================================================================================================================================

Func _GUICtrlReleaseHotKeyInput()

	Local $Ret = 1, $n = $hkId[0][0]

	While $n > 0
		If Not _GUICtrlDeleteHotKeyInput($hkId[$n][0]) Then
			$Ret = 0
		EndIf
		$n -= 1
	WEnd
	Return $Ret
EndFunc   ;==>_GUICtrlReleaseHotKeyInput

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyLock
; Description:		Locks a specified key combination for a Hotkey Input control.
; Syntax:			_KeyLock ( $iKey )
; Parameter(s):		$iKey - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	None.
; Author(s):		Yashied
;
; Note(s):			This function is independent and can be called at any time. The keys are blocked only for the Hotkey Input controls
;					and will be available for other applications. Using this function, you can not lock the key, but only with the combination
;					of this key. To completely lock the keys, use _KeyLoadName(). For example, this function can be used to lock for
;					Hotkey Input control "ALT-TAB". In this case, "ALT-TAB" will work as always. You can block any number of keys,
;					but no more than one in one function call.
;====================================================================================================================================

Func _KeyLock($iKey)
	$iKey = BitAND($iKey, 0x0FFF)
	For $i = 1 To $hkLock[0]
		If $hkLock[$i] = $iKey Then
			Return
		EndIf
	Next
	ReDim $hkLock[$hkLock[0] + 2]
	$hkLock[$hkLock[0] + 1] = $iKey
	$hkLock[0] += 1
EndFunc   ;==>_KeyLock

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyUnlock
; Description:		Unlocks a specified key combination for a Hotkey Input control.
; Syntax:			_KeyUnlock ( $iKey )
; Parameter(s):		$iKey - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
; Return Value(s):	None.
; Author(s):		Yashied
; Note(s):			This function is inverse to _KeyLock().
;====================================================================================================================================

Func _KeyUnlock($iKey)
	$iKey = BitAND($iKey, 0x0FFF)
	For $i = 1 To $hkLock[0]
		If $hkLock[$i] = $iKey Then
			For $j = $i To $hkLock[0] - 1
				$hkLock[$j] = $hkLock[$j + 1]
			Next
			$hkLock[0] -= 1
			ReDim $hkLock[$hkLock[0] + 1]
			Return
		EndIf
	Next
EndFunc   ;==>_KeyUnlock

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyLoadName
; Description:		Loads a names of keys.
; Syntax:			_KeyLoadName ( $aKeyName )
; Parameter(s):		$aKeyName - 256-string array that receives the name for each virtual key (see vkCodes.au3). If the name is not
;								specified ("") in array then the key will be ignored.
;
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
;
; Note(s):			You can use this function to replace the names of the keys in the Hotkey Input control, such as "Shift" => "SHIFT".
;					Also through this program can lock the keys.
;====================================================================================================================================

Func _KeyLoadName(ByRef $aKeyName)

	If (Not IsArray($aKeyName)) Or (UBound($aKeyName) < 256) Then
		Return SetError(1, 0, 0)
	EndIf

	For $i = 0 To 255
		$VK[$i] = $aKeyName[$i]
	Next
	For $i = 0 To $hkId[0][0]
		GUICtrlSetData($hkId[$i][0], _KeyToStr($hkId[$i][2], $hkId[$i][3]))
	Next
	Return SetError(1, 0, 0)
EndFunc   ;==>_KeyLoadName

; #FUNCTION# ========================================================================================================================
; Function Name:	_KeyToStr
; Description:		Places the key names of an hotkey into a single string, separated by the specified characters.
; Syntax:			_KeyToStr ( $iKey [, $sSeparator] )
;					$iKey       - Combined 16-bit hotkey code (see _GUICtrlCreateHotKeyInput()).
;					$sSeparator - Separating characters. Default is "-".
; Return Value(s):	Returns a string containing of a combination of the key names and separating characters, eg. "Alt-Shift-D".
; Author(s):		Yashied
; Note(s):			Use _KeyLoadName() to change the names of the keys in the Hotkey Input control.
;====================================================================================================================================

Func _KeyToStr($iKey, $sSeparator = '-')

	Local $Ret = '', $n = StringLen($sSeparator)

	If BitAND($iKey, 0x0200) = 0x0200 Then
		$Ret = $Ret & $VK[0xA2] & $sSeparator
	EndIf
	If BitAND($iKey, 0x0100) = 0x0100 Then
		$Ret = $Ret & $VK[0xA0] & $sSeparator
	EndIf
	If BitAND($iKey, 0x0400) = 0x0400 Then
		$Ret = $Ret & $VK[0xA4] & $sSeparator
	EndIf
	If BitAND($iKey, 0x0800) = 0x0800 Then
		$Ret = $Ret & $VK[0x5B] & $sSeparator
	EndIf
	If BitAND($iKey, 0x00FF) > 0 Then
		$Ret = $Ret & $VK[BitAND($iKey, 0x00FF)]
	Else
		If StringRight($Ret, $n) = $sSeparator Then
			$Ret = StringTrimRight($Ret, $n)
		EndIf
	EndIf
	If $Ret = '' Then
		$Ret = $VK[0x00]
	EndIf
	Return $Ret
EndFunc   ;==>_KeyToStr

#EndRegion Public Functions

#Region Internal Functions

Func _HotKeyInput_Check($ID)
	If ($hkId[0][6] > 0) And ($ID <> $hkId[0][6]) Then
;		If (($hkId[0][3] > 0) And ($hkId[$hkId[0][6]][2] = 0)) Or (($ID > 0) And ($hkId[0][7] = 1) And ($hkId[0][8] = 1)) Then
		If ($hkId[0][3] > 0) And ($hkId[$hkId[0][6]][2] = 0) Then
			GUICtrlSetData($hkId[$hkId[0][6]][0], $VK[0x00])
		EndIf
		$hkId[0][2] = 0
		$hkId[0][7] = 0
		$hkId[0][8] = 0
	EndIf
	$hkId[0][6] = $ID
EndFunc   ;==>_HotKeyInput_Check

Func _HotKeyInput_Focus($Focus)
	For $i = 1 To $hkId[0][0]
		If $Focus = $hkId[$i][1] Then
			Return $i
		EndIf
	Next
	Return 0
EndFunc   ;==>_HotKeyInput_Focus

Func _HotKeyInput_Hook($iCode, $wParam, $lParam)

	If ($iCode < 0) Or ($hkId[0][1] = 1) Then
		Switch $wParam
			Case $WM_KEYDOWN, $WM_SYSKEYDOWN
				If $iCode < 0 Then
					ContinueCase
				EndIf
				Return -1
			Case Else
				Return _WinAPI_CallNextHookEx($hkId[0][5], $iCode, $wParam, $lParam)
		EndSwitch
	EndIf

	Local $vkCode = DllStructGetData(DllStructCreate($tagKBDLLHOOKSTRUCT, $lParam), 'vkCode')
	Local $Key, $Return = True, $Index = _HotKeyInput_Focus(_WinAPI_GetFocus())

	_HotKeyInput_Check($Index)

	Switch $wParam
		Case $WM_KEYDOWN, $WM_SYSKEYDOWN
			Switch $vkCode
				Case 0xA0, 0xA1
					$hkId[0][3] = BitOR($hkId[0][3], 0x01)
				Case 0xA2, 0xA3
					$hkId[0][3] = BitOR($hkId[0][3], 0x02)
				Case 0xA4, 0xA5
					$hkId[0][3] = BitOR($hkId[0][3], 0x04)
				Case 0x5B, 0x5C
					$hkId[0][3] = BitOR($hkId[0][3], 0x08)
			EndSwitch
			If $Index > 0 Then
				If $vkCode = $hkId[0][2] Then
					Return -1
				EndIf
				$hkId[0][2] = $vkCode
				Switch $vkCode
					Case 0xA0 To 0xA5, 0x5B, 0x5C
						If $hkId[0][7] = 1 Then
							Return -1
						EndIf
						GUICtrlSetData($hkId[$Index][0], _KeyToStr(BitShift($hkId[0][3], -8), $hkId[$Index][3]))
						$hkId[$Index][2] = 0
					Case Else
						If $hkId[0][7] = 1 Then
							Return -1
						EndIf
						Switch $vkCode
							Case 0x08, 0x1B
								If $hkId[0][3] = 0 Then
									If $hkId[$Index][2] > 0 Then
										GUICtrlSetData($hkId[$Index][0], $VK[0x00])
										$hkId[$Index][2] = 0
									EndIf
									Return -1
								EndIf
						EndSwitch
						If $VK[$vkCode] > '' Then
							$Key = BitOR(BitShift($hkId[0][3], -8), $vkCode)
							If Not _HotKeyInput_Lock($Key) Then
								GUICtrlSetData($hkId[$Index][0], _KeyToStr($Key, $hkId[$Index][3]))
								$hkId[$Index][2] = $Key
								$hkId[0][7] = 1
								$hkId[0][8] = 1
							Else
								$Return = 0
							EndIf
						EndIf
				EndSwitch
				If $Return Then
					Return -1
				EndIf
			EndIf
		Case $WM_KEYUP, $WM_SYSKEYUP
			Switch $vkCode
				Case 0xA0, 0xA1
					$hkId[0][3] = BitAND($hkId[0][3], 0xFE)
				Case 0xA2, 0xA3
					$hkId[0][3] = BitAND($hkId[0][3], 0xFD)
				Case 0xA4, 0xA5
					$hkId[0][3] = BitAND($hkId[0][3], 0xFB)
				Case 0x5B, 0x5C
					$hkId[0][3] = BitAND($hkId[0][3], 0xF7)
			EndSwitch
			If $Index > 0 Then
				If $hkId[$Index][2] = 0 Then
					Switch $vkCode
						Case 0xA0 To 0xA5, 0x5B, 0x5C
							GUICtrlSetData($hkId[$Index][0], _KeyToStr(BitShift($hkId[0][3], -8), $hkId[$Index][3]))
					EndSwitch
				EndIf
			EndIf
			$hkId[0][2] = 0
			If $vkCode = BitAND($hkId[$Index][2], 0x00FF) Then
				$hkId[0][8] = 0
			EndIf
			If $hkId[0][3] = 0 Then
				If $hkId[0][8] = 0 Then
					$hkId[0][7] = 0
				EndIf
			EndIf
	EndSwitch

	Return _WinAPI_CallNextHookEx($hkId[0][5], $iCode, $wParam, $lParam)
EndFunc   ;==>_HotKeyInput_Hook

Func _HotKeyInput_Lock($iKey)
	For $i = 1 To $hkLock[0]
		If $iKey = $hkLock[$i] Then
			Return 1
		EndIf
	Next
	Return 0
EndFunc   ;==>_HotKeyInput_Lock

#EndRegion Internal Functions

#Region OnAutoItExit

Func OnHotKeyInputExit()
	_WinAPI_UnhookWindowsHookEx($hkId[0][5])
	DllCallbackFree($hkId[0][4])
	Call($OnHotKeyInputExit)
EndFunc   ;==>OnHotKeyInputExit

#EndRegion OnAutoItExit
