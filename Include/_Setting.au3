#include-once

; =======================================
; Title .........: Setting
; AutoIt Version : 3.2.12.1+
; Language ......: English
; Description ...: Операции с конфигурационными данными
; Author .........: AZJIO
; =======================================

; #CURRENT# =============================
; _Setting_Read
; _Setting_Write
; _Setting_Delete
; _Setting_ReadSection
; _Setting_ReadSectionNames
; _Setting_WriteSection
; _Setting_RenameSection
; _Setting_MigrateIniToReg
; _Setting_MigrateRegToIni
; =======================================

; #FUNCTION# ;=================================================================================
; Description ........: Reads a value from ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$sValueName - Key or ValueName
;		$sDefault - by default
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - String
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_Read($sPath, $sSection, $sValueName, $sDefault, $iReg = 0)
	Local $sValue
	If $iReg Then
		$sValue = RegRead($sPath & '\' & $sSection, $sValueName)
		If @error Then $sValue = $sDefault
	Else
		$sValue = IniRead($sPath, $sSection, $sValueName, $sDefault)
	EndIf
	Return $sValue
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Writes a value to a ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$sValueName - Key or ValueName
;		$sValue - Value
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - 1
;					Failure - 0, @error = 1
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_Write($sPath, $sSection, $sValueName, $sValue, $iReg = 0)
	If $iReg Then
		$sValue = StringRegExpReplace($sValue, '^"(.*?)"$', '\1')
		$iRes = RegWrite($sPath & '\' & $sSection, $sValueName, "REG_SZ", $sValue)
	Else
		$iRes = IniWrite($sPath, $sSection, $sValueName, $sValue)
	EndIf
	Return SetError(Not $iRes, 0, $iRes)
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Writes a section to a ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$Data - Data, key=value, array or string, delimited by @LF
;		$iIndex - If an array is passed as data, this specifies the index to start writing from
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - 1
;					Failure - 0, @error = 1, @extended = count
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_WriteSection($sPath, $sSection, $Data, $iIndex = 1, $iReg = 0)
	Local $error = 0
	If $iReg Then
		If RegDelete($sPath & '\' & $sSection) = 2 Then Return SetError(2, 0, 0)
		If IsString($Data) Then
			$iIndex = 1
			Local $aString = StringSplit(StringStripWS($Data, 3), @LF)
			Dim $Data[$aString[0] + 1][2] = [[$aString[0]]]
			$j = 0
			For $i = 1 To $aString[0]
				$aTmp = StringRegExp($aString[$i], '^(\S+?)\s*=\s*(.*?)\s*$', 3)
				If @error Then
					$error += 1
					ContinueLoop
				EndIf
				$j += 1
				$aTmp[1] = StringRegExpReplace($aTmp[1], '^"(.*?)"$', '\1')
				$Data[$j][0] = $aTmp[0]
				$Data[$j][1] = $aTmp[1]
			Next
			ReDim $Data[$j + 1][2]
		EndIf
		For $i = $iIndex To UBound($Data) - 1
			If Not RegWrite($sPath & '\' & $sSection, $Data[$i][0], "REG_SZ", $Data[$i][1]) Then $error += 1
		Next
		If $error Then
			$iRes = 0
		Else
			$iRes = 1
		EndIf
	Else
		$iRes = IniWriteSection($sPath, $sSection, $Data, $iIndex)
	EndIf
	Return SetError(Not $iRes, $error, $iRes)
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Renames a section in a ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$sNewSection - The new Section/KeyName name
;		$flag - (0,1)
;                  |0 - Fail if "new section" already exists
;                  |1 - Overwrite "new section".
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - 1
;					Failure - 0, @error = 1
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_RenameSection($sPath, $sSection, $sNewSection, $flag = 0, $iReg = 0)
	If $iReg Then
		$aKeyValue = _Setting_ReadSection($sPath, $sSection, 1)
		If @error Then Return SetError(1, 0, 0)
		If _RegExists($sPath & '\' & $sNewSection) Then
			If $flag Then
				If RegDelete($sPath & '\' & $sNewSection) = 2 Then Return SetError(2, 0, 0)
			Else
				Return SetError(1, 0, 0)
			EndIf
		EndIf
		_Setting_WriteSection($sPath, $sNewSection, $aKeyValue, 1, 1)
		If @error Then
			$iRes = 0
		Else
			$iRes = 1
		EndIf
		If RegDelete($sPath & '\' & $sSection) = 2 Then Return SetError(3, 0, $iRes)
	Else
		$iRes = IniRenameSection($sPath, $sSection, $sNewSection, $flag)
	EndIf
	Return SetError(Not $iRes, 0, $iRes)
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Deletes a value from a ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$sValueName - Key or ValueName
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - True
;					Failure - False, @error = 1
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_Delete($sPath, $sSection, $sValueName = '', $iReg = 0)
	If $iReg Then
		If $sValueName == '' Then
			$fRes = (RegDelete($sPath & '\' & $sSection) = 2)
		Else
			$fRes = (RegDelete($sPath & '\' & $sSection, $sValueName) = 2)
		EndIf
	Else
		If $sValueName == '' Then
			$fRes = (IniDelete($sPath, $sSection) = 0)
		Else
			$fRes = (IniDelete($sPath, $sSection, $sValueName) = 0)
		EndIf
	EndIf
	Return SetError($fRes, 0, Not $fRes)
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Reads all key/value pairs from a section in ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$sSection - Section or KeyName
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - Returns a 2 dimensional array where Array[n][0] is the key and Array[n][1] is the value
;					Failure - @error = 1
; Remarks ..........: Array[0][0] = number of elements
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_ReadSection($sPath, $sSection, $iReg = 0)
	If $iReg Then
		Local $aKeyValue[1][2] = [[0]], $i = 0, $sValueName
		While 1
			$i += 1
			$sValueName = RegEnumVal($sPath & '\' & $sSection, $i)
			If @error Then ExitLoop
			ReDim $aKeyValue[$i + 1][2]
			$aKeyValue[$i][0] = $sValueName
			$aKeyValue[$i][1] = RegRead($sPath & '\' & $sSection, $sValueName)
		WEnd
		If $i = 1 Then Return SetError(1, 0, 1)
		$aKeyValue[0][0] = $i - 1
	Else
		Local $aKeyValue = IniReadSection($sPath, $sSection)
		If @error Then Return SetError(1, 0, 1)
	EndIf
	Return $aKeyValue
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Reads all sections in a ini-file or registry.
; Parameters:
;		$sPath - Path or Key
;		$iReg - (0,1)
;                  |0 - ini-file
;                  |1 - registry
; Return values ....: Success - Returns an array of all section names
;					Failure - 0, @error = 1
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_ReadSectionNames($sPath, $iReg = 0)
	If $iReg Then
		Local $sSection[1] = [0], $i = 0, $sKey
		While 1
			$i += 1
			$sKey = RegEnumKey($sPath, $i)
			If @error Then ExitLoop
			ReDim $sSection[$i + 1]
			$sSection[$i] = $sKey
		WEnd
		If $i = 0 Then Return SetError(1, 0, 0)
		$sSection[0] = $i - 1
	Else
		Local $sSection = IniReadSectionNames($sPath)
		If @error Then Return SetError(1, 0, 0)
	EndIf
	Return $sSection
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Copies given from registry in ini-file.
; Parameters:
;		$sPath - Path
;		$sKey - Key
;		$flag - (0, 1, 2)
;                  |0 - none (Default)
;                  |1 - Deletes the data in the registry before the migration
;                  |2 - Removes the .ini file after migration
; Return values ....: Success True - @error = 0, @extended = number of lines
;					Failure False - @error = number of errors, @extended = number of successful lines
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_MigrateIniToReg($sPath, $sKey, $flag = 0)
	Local $iFailure, $iSuccess, $aKeyValue, $i, $j, $sSection, $tmp
	If BitAND($flag, 1) Then RegDelete($sKey)
	$sSection = IniReadSectionNames($sPath)
	If @error Then Return SetError(1, 0, 0)
	For $i = 1 To $sSection[0]
		$aKeyValue = IniReadSection($sPath, $sSection[$i])
		If Not @error Then
			For $j = 1 To $aKeyValue[0][0]
				If RegWrite($sKey & '\' & $sSection[$i], $aKeyValue[$j][0], "REG_SZ", $aKeyValue[$j][1]) Then
					$iSuccess += 1
				Else
					$iFailure += 1
				EndIf
			Next
		EndIf
	Next
	If BitAND($flag, 2) Then FileDelete($sPath)
	Return SetError($iFailure, $iSuccess, Not $iFailure)
EndFunc

; #FUNCTION# ;=================================================================================
; Description ........: Copies given from ini-file in registry.
; Parameters:
;		$sKey - Key
;		$sPath - Path
;		$flag - (0, 1, 2)
;                  |0 - none (Default)
;                  |1 - Removes all sections in .ini file before migration
;                  |2 - Deletes the data in the registry after the migration
;                  |4 - use IniWrite instead of IniWriteSection, without removing existing
; Return values ....: Success - @error = 0, @extended = number of lines
;					Failure - @error = number of errors, @extended = number of successful lines
; Author(s) ..........: AZJIO
; ============================================================================================
Func _Setting_MigrateRegToIni($sKey, $sPath, $flag = 0)
	Local $iFailure, $iSuccess, $aKeyValue, $i, $j, $sSection, $tmp
	If BitAND($flag, 1) Then
		$tmp = IniReadSectionNames($sPath)
		If Not @error Then
			For $i = 1 To $tmp[0]
				IniDelete($sPath, $tmp[0])
			Next
		EndIf
	EndIf
	$sSection = _Setting_ReadSectionNames($sKey, 1)
	If @error Then Return SetError(1, 0, 0)
	For $i = 1 To $sSection[0]
		$aKeyValue = _Setting_ReadSection($sKey, $sSection[$i], 1)
		If Not @error Then
			For $j = 1 To $aKeyValue[0][0]
				If StringLeft($aKeyValue[$j][1], 1) = '"' And StringRight($aKeyValue[$j][1], 1) = '"' Then $aKeyValue[$j][1] = '"' & $aKeyValue[$j][1] & '"'
				If StringRegExp(StringLeft($aKeyValue[$j][1], 1) & StringRight($aKeyValue[$j][1], 1), '\h') Then $aKeyValue[$j][1] = '"' & $aKeyValue[$j][1] & '"'
			Next
			If BitAND($flag, 4) Then
				For $j = 1 To $aKeyValue[0][0]
					If IniWrite($sPath, $sSection[$i], $aKeyValue[$j][0], $aKeyValue[$j][1]) Then
						$iSuccess += 1
					Else
						$iFailure += 1
					EndIf
				Next
			Else
				If _Setting_WriteSection($sPath, $sSection[$i], $aKeyValue, 1, 0) Then
					$iSuccess += 1
				Else
					$iFailure += 1
				EndIf
			EndIf
		EndIf
	Next
	If BitAND($flag, 2) Then RegDelete($sKey)
	Return SetError($iFailure, $iSuccess, Not $iFailure)
EndFunc

Func _RegExists($sKey)
	RegRead($sKey, '')
	Return Not (@error > 0)
EndFunc