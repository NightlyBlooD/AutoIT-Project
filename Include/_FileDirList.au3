; #FUNCTION# ====================================================================================================
; Name...........:  _FileDirList
; Description....:  Search files and\or folders in a specified path (uses system Dir command)
; Syntax.........:  _FileDirList($sPath [, $sFileMask = "*" [, $iFlag = 0 [, $iSubDir = 1 [, $iSort = 0]]]])
; Parameters.....:  $sPath     - Path to search the file.
;                   $sFileMask - [Optional] Filter to use, default is "*". Search the Autoit3 helpfile for the word "WildCards" For details.
;                   $iFlag     - [Optional] Specifies whether to return files folders or both:
;                                                                                               $iFlag = 0 - Files and folders (default)
;                                                                                               $iFlag = 1 - Only files
;                                                                                               $iFlag = 2 - Only folders
;                   $iSubDir   - [Optional] Specifies whether to search in subfolders or not:
;                                                                                               $iSubDir = 1 - Search in subfolders (default). Returns full pathes.
;                                                                                               $iSubDir = 0 - Search without subfolders (only in $sPath). Returns filenames only.
;                   $iSort     - [Optional] Specifies whether to sort the output list (in alphabetic order) or not (default is 0 - do not sort).
;
; Return values..:  Success    - An array with the following elements:
;                                                                      $aArray[0] = Number of Files\Folders returned
;                                                                      $aArray[1] = 1st File\Folder
;                                                                      $aArray[2] = 2nd File\Folder
;                                                                      $aArray[3] = 3rd File\Folder
;                                                                      $aArray[n] = nth File\Folder
;                   Failure    - 0
;                      @Error:    1 = Path not found or invalid
;                                 2 = No File(s) Found
;
; Author.........:  G.Sandler (CreatoR), amel27.
; Modified.......:
; Remarks........:  This function uses system Dir command, to speed up the search.
; Related........:
; Link...........:
; Example........:
; ===============================================================================================================
Func _FileDirList($sPath, $sFileMask = "*", $iFlag = 0, $iSubDir = 1, $iSort = 0)
	Local $sOutBin, $sOut, $aOut, $aMasks, $sRead, $hDir, $sAttrib, $sFiles

	If Not StringInStr(FileGetAttrib($sPath), "D") Then
		Return SetError(1, 0, 0)
	EndIf

	If $iSubDir = 1 Then
		$sAttrib &= ' /S'
	EndIf

	If $iSort = 1 Then
		$sAttrib &= ' /O:N'
	EndIf

	Switch $iFlag
		Case 1
			$sAttrib &= ' /A-D'
		Case 2
			$sAttrib &= ' /AD'
		Case Else
			$sAttrib &= ' /A'
	EndSwitch

	$sOut = StringToBinary('0' & @CRLF, 2)
	$sPath = StringRegExpReplace($sPath, '\\+$', '')
	$sFileMask = StringRegExpReplace($sFileMask, '^;+|;+$', '')
	$sFileMask = StringRegExpReplace($sFileMask, ';{2,}', ';')
	$aMasks = StringSplit($sFileMask, ';')

	For $i = 1 To $aMasks[0]
		If StringStripWS($aMasks[$i], 8) = "" Then
			ContinueLoop
		EndIf

		$sFiles &= '"' & $sPath & '\' & $aMasks[$i] & '"'

		If $i < $aMasks[0] Then
			$sFiles &= ';'
		EndIf
	Next

	$hDir = Run(@ComSpec & ' /U /C DIR ' & $sFiles & ' /B' & $sAttrib, @SystemDir, @SW_HIDE, 6)

	While ProcessExists($hDir)
		$sRead = StdoutRead($hDir, False, True)

		If @error Then
			ExitLoop
		EndIf

		If $sRead <> "" Then
			$sOut &= $sRead
		EndIf
	WEnd

	$aOut = StringRegExp(BinaryToString($sOut, 2), '[^\r\n]+', 3)

	If @error Or UBound($aOut) < 2 Then
		Return SetError(2, 0, 0)
	EndIf

	$aOut[0] = UBound($aOut) - 1
	Return $aOut
EndFunc