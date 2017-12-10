#cs ----------------------------------------------------------------------------
	AutoIt Version: 3.0 / 3.3.6.1
	Author:         Guezt Gutsy
	Script Function: Autorun script with Windows ; Автозапуск 	приложений
	Uses: AutoRun.au3
	Version:        1.2
	Available functions:

   *_AutoRunAdd()
   *_AutoRunDel()
#ce ----------------------------------------------------------------------------
#include-once
; #FUNCTION# ====================================================================================================================
; Name...........: _AutoRunAdd()
; Description....: Enables script starts with Windows
; Syntax.........: _AutoRunAdd([$iMethod[, $sName[,$sKeys]]])
; Parameters.....: $sName     - Name script write in Reg
;                             Default $sName = @ScripName
;   			   $iMethod   - 0 Current User
;                             - 1  All User
;							  Default $iMethod = 0
;				   $sKeys     Add parameters Keys
; Return values..: Success    - 0
;                  Failure    - 1
;                  Null       - 2 ; is exist register key
; Author.........: Guezt Gutsy

Func _AutoRunAdd($iMethod = 0, $sName = "",$sKeys = '' )
	If Number($iMethod) <> 1 Then
		$iMethod = "HKCU"
	Else
		If Not IsAdmin() Then Return 1
		$iMethod = "HKLM"
	EndIf
	If $sName = "" Then $sName = @ScriptName
	If RegRead($iMethod & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", String($sName)) = "" Or _
		Not StringInStr(RegRead($iMethod & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", String($sName)),@ScriptFullPath) Then
		RegWrite($iMethod & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", String($sName), "REG_SZ", '"'&@ScriptFullPath&'" '&$sKeys)
		If Not @error Then
			Return 0
		Else
			Return 1
		EndIf
	EndIf
	Return 2
EndFunc   ;==>_AutoRunAdd

; #FUNCTION# ====================================================================================================================
; Name...........: _AutoRunDel()
; Description....: Disables script starts with Windows
; Syntax.........: _AutoRunDel([$iMethod[, $sName]])
; Parameters.....: $sName     - Name script Del in Reg
;                             Default $sName = @ScripName
;   			   $iMethod   - 0 Current User
;                             - 1  All User
;							  Default $iMethod = 0
; Return values..: Success    - 0 Delete Key
;                  Failure    - 1 Error Delete
;    						  - 2 Not Found Key
; Author.........: Guezt Gutsy

Func _AutoRunDel($iMethod = 0, $sName = "")
	If Number($iMethod) <> 1 Then
		$iMethod = "HKCU"
	Else
		If Not IsAdmin() Then Return 1
		$iMethod = "HKLM"
	EndIf
	If $sName = "" Then $sName = @ScriptName
	RegRead($iMethod & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", String($sName))
	If @error Then
		Return 2
	EndIf
	RegDelete($iMethod & "\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", String($sName))
	If Not @error Then
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_AutoRunDel




