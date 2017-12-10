#include-once

#CS Registry extended UDFs.
	Originaly by wraithdu (http://www.autoitscript.com/forum/index.php?showtopic=70108)
	Modified (at 01.12.2008) by MsCreatoR (CreatoR's Lab - http://creator-lab.ucoz.ru).
#CE

;Delete registry key by it's value
Func _RegDeleteEx($s_Key, $s_Val)
	Local $sCurrent_ValName, $iCount = 1
	
	While 1
		$sCurrent_ValName = RegEnumVal($s_Key, $iCount)
		If @error <> 0 Then ExitLoop
		
		If String(RegRead($s_Key, $sCurrent_ValName)) = $s_Val Then Return RegDelete($s_Key, $sCurrent_ValName)
		
		$iCount += 1
	WEnd
	
	Return @error
EndFunc   ;==>_RegDeleteEx

Func _RegCopyKey($s_Key, $d_Key, $iDelete = False)
	Local $i, $sVal, $sData, $sType, $sKey

	RegWrite($d_Key) ; write dest Key, in case Key empty
	If @error <> 0 Then Return @error ; some error
	
	; Value loop
	$i = 0
	
	While 1
		$i += 1
		
		$sVal = RegEnumVal($s_Key, $i)
		If @error <> 0 Then ExitLoop ; no more Values
		
		$sData = RegRead($s_Key, $sVal)
		If @error <> 0 Then ContinueLoop ; some error reading Value, skip it
		
		$sType = _RegGetExtendedType(@extended)
		RegWrite($d_Key, $sVal, $sType, $sData) ; write new Value
	WEnd
	
	; Key loop
	$i = 0
	
	While 1
		$i += 1
		$Key = RegEnumKey($s_Key, $i)
		If @error <> 0 Then ExitLoop ; no more Keys
		
		_RegCopyKey($s_Key & "\" & $sKey, $d_Key & "\" & $sKey) ; recurse
	WEnd
	
	; move Key
	If $iDelete Then RegDelete($s_Key)
EndFunc   ;==>_RegCopyKey

Func _RegMoveKey($s_Key, $d_Key)
	_RegCopyKey($s_Key, $d_Key, True)
EndFunc   ;==>_RegMoveKey

Func _RegCopyValue($s_Key, $s_Val, $d_Key, $d_Val, $iDelete = False)
	Local $sData, $sType

	$sData = RegRead($s_Key, $s_Val)
	If @error <> 0 Then Return SetError(1, 0, 0) ; some error reading Value, skip it
	
	$sType = _RegGetExtendedType(@extended)
	
	RegWrite($d_Key, $d_Val, $sType, $sData)
	If $iDelete Then RegDelete($s_Key, $s_Val)
EndFunc   ;==>_RegCopyValue

Func _RegMoveValue($s_Key, $s_Val, $d_Key, $d_Val)
	_RegCopyValue($s_Key, $s_Val, $d_Key, $d_Val, True)
EndFunc   ;==>_RegMoveValue

Func _RegKeyExists($s_Key)
	RegRead($s_Key, "")
	If @error <= 0 Then Return 1 ; Key exists
	
	Return 0
EndFunc   ;==>_RegKeyExists

Func _RegSubKeySearch($s_Key, $s_Search, $i_Mode = 0, $i_Case = 0)
	; success returns subKey index
	; failure returns 0
	Local $i = 1, $sKey, $iLen = StringLen($s_Search), $sString
	
	While 1
		$sKey = RegEnumKey($s_Key, $i)
		If @error <> 0 Then Return 0 ; no more Keys
		
		Switch $i_Mode
			Case 0 ; substring
				If StringInStr($sKey, $s_Search, $i_Case) Then Return $i
			Case 1 ; beginning of string
				$sString = StringLeft($sKey, $iLen)
				
				Switch $i_Case
					Case 0 ; case insensitive
						If $sString = $s_Search Then Return $i
					Case 1 ; case sensitive
						If $sString == $s_Search Then Return $i
				EndSwitch
		EndSwitch
		
		$i += 1
	WEnd
EndFunc   ;==>_RegSubKeySearch

Func _RegValueExists($s_Key, $s_Val)
	RegRead($s_Key, $s_Val)
	; @error == -2 is 'type not supported', implying Value exists
	If @error = -1 Or @error >= 1 Then Return 0 ; Value does not exist
	
	Return 1
EndFunc   ;==>_RegValueExists

Func _RegKeyEmpty($s_Key)
	Local $i_Error1 = 0, $i_Error2 = 0
	
	; check for Keys
	RegEnumKey($s_Key, 1)
	If @error <> 0 Then $i_Error1 = 1
	; check for Values
	RegEnumVal($s_Key, 1)
	If @error <> 0 Then $i_Error2 = 1
	
	; set return
	If $i_Error1 And $i_Error2 Then Return 1 ; empty
	
	Return 0
EndFunc   ;==>_RegKeyEmpty

Func _RegExport($sRegFile, $sKeyName, $sValueName="")
	If $sValueName <> "" Then
		Local $sRegRead = RegRead($sKeyName, $sValueName)
		Local $hOpen = FileOpen($sRegFile, 2)
		
		FileWrite($hOpen, 'Windows Registry Editor Version 5.00' & @CRLF & @CRLF & _
			"[" & $sKeyName & "]" & @CRLF & _
			'"' & $sValueName & '"="' & StringRegExpReplace($sRegRead, '([\\"])', '\\\1') & '"' & @CRLF)
		
		FileClose($hOpen)
	Else
		Run(@ComSpec & ' /c Reg Export "' & $sKeyName & '" "' & $sRegFile & '"', '', @SW_HIDE)
	EndIf
EndFunc   ;==>_RegExport

Func _RegImport($sRegFile)
	Run('RegEdit.exe /s "' & $sRegFile & '"')
EndFunc   ;==>_RegImport

Func _RegSetEnvironment($sEnv_Name, $sEnv_Value, $iReplace=0, $iKeyVal=0, $iEnv_Update=0)
	If $sEnv_Name = "" Then Return SetError(1, 0, 0)
	If $sEnv_Value = "" Then Return SetError(2, 0, 0)
	If $iReplace <> 0 And $iReplace <> 1 Then Return SetError(3, 0, 0)
	
	Local $iRet = 0, $iError = 0
	Local $sSystemRegKey = "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
	Local $sUserRegKey = "HKEY_CURRENT_USER\Environment"
	
	Local $sRegKey = $sSystemRegKey
	If $iKeyVal = 1 Then $sRegKey = $sUserRegKey
	
	If $iReplace = 1 Then
		$iRet = RegWrite($sRegKey, $sEnv_Name, "REG_SZ", $sEnv_Value)
		$iError = @error
	ElseIf RegRead($sRegKey, $sEnv_Name) = "" Then
		$iRet = RegWrite($sRegKey, $sEnv_Name, "REG_SZ", $sEnv_Value)
		$iError = @error
	EndIf
	
	If $iEnv_Update Then EnvUpdate()
	
	Return SetError($iError, 0, $iRet)
EndFunc   ;==>_RegSetEnvironment

Func _RegGetExtendedType($iExtended)
	Local $aRegTypeArr[8] = [7, "REG_SZ", "REG_EXPAND_SZ", "REG_BINARY", "REG_DWORD", _
		"REG_DWORD_BIG_ENDIAN", "REG_LINK", "REG_MULTI_SZ"]
	
	For $i = 1 To 7
		If $iExtended = $i Then Return $aRegTypeArr[$i]
	Next
	
	Return "REG_SZ"
EndFunc   ;==>_RegGetExtendedType

;==============================================================================================
;
; Description:		_RegSetFileExt($sExt, $sCommand, $sVerb[, $iDefault[, $sIcon = ""[, $sDescription = ""]]])
;					Registers a file type in Explorer
; Parameter(s):		$sExt - 	File Extension without period eg. "zip"
;					$sCommand - 	Program path with arguments eg. '"C:\test\testprog.exe" "%1"'
;							(%1 is 1st argument, %2 is 2nd, etc.)
;					$sVerb - Name of action to perform on file
;							eg. "Open with ProgramName" or "Extract Files"
;					$iDefault - 	Action is the default action for this filetype
;							(1 for true 0 for false)
;							If the file is not already associated, this will be the default.
;					$sIcon - Default icon for filetype including resource # if needed
;							eg. "C:\test\testprog.exe,0" or "C:\test\filetype.ico"
;					$sDescription - File Description eg. "Zip File" or "ProgramName Document"
;
;===============================================================================================
Func _RegSetFileExt($sExt, $sCommand, $sVerb, $iDefault = 0, $sIcon = "", $sDescription = "")
	Local $sExtRead = RegRead("HKCR\." & $sExt, "")
	
	If @error Then
		RegWrite("HKCR\." & $sExt, "", "REG_SZ", $sExt & "file")
		$sExtRead = $sExt & "file"
	EndIf
	
	Local $sCurrentDescription = RegRead("HKCR\" & $sExtRead, "")
	
	If @error Then
		If $sDescription <> "" Then RegWrite("HKCR\" & $sExtRead, "", "REG_SZ", $sDescription)
	Else
		If $sDescription <> "" And $sCurrentDescription <> $sDescription Then
			RegWrite("HKCR\" & $sExtRead, "", "REG_SZ", $sDescription)
			RegWrite("HKCR\" & $sExtRead, "olddesc", "REG_SZ", $sCurrentDescription)
		EndIf
		
		If $sCurrentDescription = "" And $sDescription <> "" Then RegWrite("HKCR\" & $sExtRead, "", "REG_SZ", $sDescription)
	EndIf
	
	Local $sCurrentVerb = RegRead("HKCR\" & $sExtRead & "\shell", "")
	Local $iError = @error
	
	If $iDefault = 1 Then
		RegWrite("HKCR\" & $sExtRead & "\shell\Open\Command", "", "REG_EXPAND_SZ", $sCommand)
		
		If $iError Then
			RegWrite("HKCR\" & $sExtRead & "\shell", "", "REG_SZ", $sVerb)
		Else
			RegWrite("HKCR\" & $sExtRead & "\shell", "", "REG_SZ", $sVerb)
			RegWrite("HKCR\" & $sExtRead & "\shell", "oldverb", "REG_SZ", $sCurrentVerb)
		EndIf
	EndIf
	
	Local $sCurrentCommand = RegRead("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "")
	
	If Not @error Then
		RegRead("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "oldcmd")
		If @error Then RegWrite("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "oldcmd", "REG_SZ", $sCurrentCommand)
	EndIf
	
	RegWrite("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "", "REG_SZ", $sCommand)
	
	If $sIcon <> "" Then
		Local $sCurrentIcon = RegRead("HKCR\" & $sExtRead & "\DefaultIcon", "")
		
		If @error Then
			RegWrite("HKCR\" & $sExtRead & "\DefaultIcon", "", "REG_SZ", $sIcon)
		Else
			RegWrite("HKCR\" & $sExtRead & "\DefaultIcon", "", "REG_SZ", $sIcon)
			RegWrite("HKCR\" & $sExtRead & "\DefaultIcon", "oldicon", "REG_SZ", $sCurrentIcon)
		EndIf
	EndIf
EndFunc   ;==>_RegSetFileExt

;===============================================================================
;
; Description:		_RegUnSetFileExt($sExt, $sVerb)
;					UnRegisters a verb for a file type in Explorer
; Parameter(s):		$sExt - File Extension without period eg. "zip"
;					$sVerb [Optional] - Name of file action to remove, eg. "Open with ProgramName" or "Extract Files"
;                     If $sVerb = "" (default) then this fuunction will remove the file type from registry completely.
;
;===============================================================================
Func _RegUnSetFileExt($sExt, $sVerb="")
	Local $sExtRead = RegRead("HKCR\." & $sExt, "")
	
	If Not @error Then
		If $sVerb = "" Then
			RegDelete("HKCR\." & $sExt)
			RegDelete("HKCR\" & $sExtRead)
			
			Return 1
		EndIf
		
		Local $sOldIcon = RegRead("HKCR\" & $sExtRead & "\shell", "oldicon")
		
		If Not @error Then
			RegWrite("HKCR\" & $sExtRead & "\DefaultIcon", "", "REG_SZ", $sOldIcon)
		Else
			RegDelete("HKCR\" & $sExtRead & "\DefaultIcon", "")
		EndIf
		
		Local $sOldVerb = RegRead("HKCR\" & $sExtRead & "\shell", "oldverb")
		
		If Not @error Then
			RegWrite("HKCR\" & $sExtRead & "\shell", "", "REG_SZ", $sOldVerb)
		Else
			RegDelete("HKCR\" & $sExtRead & "\shell", "")
		EndIf
		
		Local $sOldDesc = RegRead("HKCR\" & $sExtRead, "olddesc")
		
		If Not @error Then
			RegWrite("HKCR\" & $sExtRead, "", "REG_SZ", $sOldDesc)
		Else
			RegDelete("HKCR\" & $sExtRead, "")
		EndIf
		
		Local $sOldCmd = RegRead("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "oldcmd")
		
		If Not @error Then
			RegWrite("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "", "REG_SZ", $sOldCmd)
			RegDelete("HKCR\" & $sExtRead & "\shell\" & $sVerb & "\command", "oldcmd")
		Else
			RegDelete("HKCR\" & $sExtRead & "\shell\" & $sVerb)
		EndIf
	EndIf
EndFunc   ;==>_RegUnSetFileExt

Func _RegReadKeyValueToArray($s_Key, $iKey_Value_Mode=0)
	Local $aKeysListArr[1], $aSubKeysListArr, $iInstance = 0, $sEnum_KeyVal, $sCurrentKeyPath
	
	If Not _RegKeyExists($s_Key) Then Return SetError(1, 0, $aKeysListArr)
	
	While 1
		$iInstance += 1
		
		If $iKey_Value_Mode = 0 Then
			$sEnum_KeyVal = RegEnumKey($s_Key, $iInstance)
		Else
			$sEnum_KeyVal = RegEnumVal($s_Key, $iInstance)
		EndIf
		
		If @error <> 0 Then ExitLoop
        
		$sCurrentKeyPath = $s_Key & "\" & $sEnum_KeyVal
		
		$aKeysListArr[0] += 1
		ReDim $aKeysListArr[$aKeysListArr[0]+1]
		$aKeysListArr[$aKeysListArr[0]] = $sCurrentKeyPath
		
		$aSubKeysListArr = _RegReadKeyValueToArray($sCurrentKeyPath)
		
		For $j = 1 To $aSubKeysListArr[0]
			$aKeysListArr[0] += 1
			
			ReDim $aKeysListArr[$aKeysListArr[0]+1]
			$aKeysListArr[$aKeysListArr[0]] = $aSubKeysListArr[$j]
		Next
	WEnd
	
	Return $aKeysListArr
EndFunc   ;==>_RegReadKeyValueToArray


