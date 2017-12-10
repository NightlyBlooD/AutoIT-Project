#Region Header

#CS Info
	Title:          AboutBox UDF
    Filename:       AboutBox.au3
    Description:    Shows "About program" dialog box with few nice features.
    Author:         G.Sandler a.k.a (Mr)CreatoR (CreatoR's Lab - www.creator-lab.ucoz.ru, www.autoit-script.ru)
    Version:        0.7
    Requirements:   AutoIt v3.3.6.1 +, Developed/Tested on WinXP Service Pack 2/3, Win 7 (rus).
	
    Uses:           Constants.au3, GUIConstantsEx.au3, StaticConstants.au3, WindowsConstants.au3, GDIPlus.au3, Misc.au3, WinAPI.au3.
	Forum Link:     http://www.autoitscript.com/forum/index.php?showtopic=64738
    
	Notes:          * On Windows XP there is no fading cover for scrolling text.
					* Global variable (option) $ABX_PLAYSOUND can be used to set initial sound playing state.
	
	Credits:		Un4seen Developments (BASSMOD.dll), UEZ (Main scrolling text mechanism), Yashied (Help with cover for scrolling GUI).
	
	History:
	                v0.7
	                * UDF does not registers $WM_ACTIVATE and $WM_MOVE anymore.
					* Scrolling GUI now created using ScrollText UDF (uses GDI+).
					* Changed default background sound.
					* Renamed internal function names from __AboutBox_* to __ABx_*.
					* Public variable $ABOUTBOX_PlaySound replaced with $ABX_PLAYSOUND.
#CE

#CS Example
	#include "AboutBox.au3"
	
	_Example()
	
	Func _Example()
		Local $hParent_GUI, $iMainMenu, $iAbout_MenuItem, $aAccelKeys
		Local $sTitle, $sScrollText, $sMainLabel, $sCopyRLabel, $iLinkColor, $iBkColor, $aHyperLinks[4], $aData[5]
		
		$hParent_GUI = GUICreate('Parent For "About Program" Demo', 330, 100)
		
		$iMainMenu = GUICtrlCreateMenu("Help")
		$iAbout_MenuItem = GUICtrlCreateMenuItem("About...	(F1)", $iMainMenu)
		
		Dim $aAccelKeys[1][2] = [["{F1}", $iAbout_MenuItem]]
		GUISetAccelerators($aAccelKeys, $hParent_GUI)
		
		GUISetState(@SW_SHOW, $hParent_GUI)
		
		;Set for initial state
		$ABX_PLAYSOUND = 1
		
		While 1
			Switch GUIGetMsg()
				Case $GUI_EVENT_CLOSE
					Exit
				Case $iAbout_MenuItem
					$sTitle = "About Info"
					
					$aData[0] = "My program Name"
					$aData[1] = "Version: " & @CRLF & "v1.0"
					$aData[2] = "I want to express special gratitude to:(Georgia,12,0x000000)\n\n\n\nAutoIt Team(Impact,16)\nAutoIt Community(Impact,16)\nAutoIt Russian Community(Impact,16)\n\n\n\n... and many other good people"
					$aData[3] = "Copyright © " & @YEAR & " Company/Author. All rights reserved."
					$aData[4] = "Play sound"
					
					$iLinkColor = 0x0000FF
					$iBkColor = 0xFFFFFF
					
					$aHyperLinks[0] = UBound($aHyperLinks) - 1
					$aHyperLinks[1] = "App Web Page|http://www.autoitscript.com"
					$aHyperLinks[2] = "Email|mailto:my_email@mail.com"
					$aHyperLinks[3] = "Some additional link|http://personalwebpafe.com"
					
					_AboutBox($sTitle, $aData, $aHyperLinks, $hParent_GUI, @AutoItExe, $iLinkColor, $iBkColor)
			EndSwitch
		WEnd
	EndFunc
#CE

#include <Constants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Misc.au3>
#include <WinAPI.au3>

#include "ScrollText.au3"

#EndRegion Header

#Region Global Variables

Global $__ABx_hAboutGUI
Global $__ABx_iScrollWidth = 300, $__ABx_iScrollHeight = 200, $__ABx_iScrollCoverHeight = 50
Global $__ABx_iScrollSpeed = 0.7
Global $__ABx_sSoundFile = @SystemDir & "\oobe\images\title.wma"
Global $__ABx_sTmpDir = @TempDir

#EndRegion Global Variables

#Region Public Variables

Global $ABX_PLAYSOUND = 1

#EndRegion Public Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........:	_AboutBox
; Description....:	Shows "About program" dialog box.
;
; Syntax.........:	_AboutBox($sTitle, $aData, $aHyperLinks, $hParent = 0, $sIconFile = "", $iLinkColor = 0x0000FF, $iBkColor = 0xFFFFFF, $iScrlBorder = 1, $iStyle = -1, $iExStyle = -1)
;
; Parameters.....:	$sTitle         - Window title.
;					$aData          - 1D Array with text data, the data should be stored as follows:
;					                                              $aData[0] - Main text to be displayed at the top of About window.
;					                                              $aData[1] - The text to be displayed on the front of About window.
;					                                              $aData[2] - The text that will be scrolling from up to down.
;					                                              $aData[3] - Copyright line, displayed at the bottom of About window.
;					                                              $aData[4] - "Play sound" checkbox text.
;					$aHyperLinks    - 1D Array with hyperlinks info, the data should be stored as follows (up to 5 hyperlinks allowed):
;                                                                 $aHyperLinks[0] = 2
;                                                                 $aHyperLinks[1] = "App Web Page|http://www.autoitscript.com"
;                                                                 $aHyperLinks[2] = "Email|mailto:my_email@mail.com"
;					$hParent     - [Optional] Parent window handle (default is 0, no parent).
;					$sIconFile   - [Optional] Icon file, will be displayed at the left-top side of About window (default is "", no icon).
;					$iLinkColor  - [Optional] Initial color of the hyperlinks (default is 0x0000FF - Blue).
;					$iBkColor    - [Optional] Background color of the About window (default is 0xFFFFFF - White).
;					$iScrlBorder - [Optional] Defines whether the scrolling box will have a border or not (default is 1).
;					$iStyle      - [Optional] Defines the style of the window (use -1 for the default style, as used in AutoIt GUI window).
;					$iExStyle    - [Optional] Defines the extended style of the window (use -1 for the default exstyle, as used in AutoIt GUI window).
;					
; Return values..:	Success      - None.
;					Failure      - Returns 0 and sets @error as follows:
;                                                                        1 - $aHyperLinks includes more than 5 elements.
;                                                                        2 - The GUI window cannot be created.
;
; Author.........:	G.Sandler a.k.a (Mr)CreatoR (CreatoR's Lab - www.creator-lab.ucoz.ru, www.autoit-script.ru)
; Modified.......:	
; Remarks........:	
; Related........:	
; Link...........:	
; Example........:	Yes.
; ===============================================================================================================
Func _AboutBox($sTitle, $aData, $aHyperLinks, $hParent = 0, $sIconFile = "", $iLinkColor = 0x0000FF, $iBkColor = 0xFFFFFF, $iScrlBorder = 1, $iStyle = -1, $iExStyle = -1)
	Local $iWidth = 600, $iHeight = 400, $iLeft = -1, $iTop = -1
	Local $iHyperLinks_Count = UBound($aHyperLinks)
	Local $anLinkLabel[$iHyperLinks_Count][2] = [[$iHyperLinks_Count - 1]], $iElementsTop = 120, $iLinkTop = $iElementsTop, $iDelim_Pos, $sURL, $sURL_Title
	Local $sMainLabelText = $aData[0], $sBodyText = $aData[1], $sScrollText = $aData[2], $sCopyRText = $aData[3], $sPlaySndText = $aData[4]
	Local $ahAbout_Sound
	
	$_ST_iCoverHeight = $__ABx_iScrollCoverHeight
	$_ST_iBkColor = $iBkColor
	$_ST_iScrollSpeed = $__ABx_iScrollSpeed
	$_ST_sDef_FontName = 'Arial'
	$_ST_iDef_FontSize = 12
	
	If $iHyperLinks_Count > 6 Then
		Return SetError(1, 0, 0)
	EndIf
	
	Local $iOld_GOEM_Opt = Opt("GUIOnEventMode", 0)
	Local $iOld_WWD_Opt = Opt("WinWaitDelay", 0)
	
	;Forced/Default styles
	If $iExStyle = -1 Then $iExStyle = 0
	$iExStyle = BitOR($WS_EX_TOOLWINDOW, $iExStyle)
	
	If IsHWnd($hParent) Then
		WinSetState($hParent, "", @SW_DISABLE)
	Else
		$iExStyle = BitOR($WS_EX_APPWINDOW, $iExStyle)
	EndIf
	
	$__ABx_hAboutGUI = GUICreate($sTitle, $iWidth, $iHeight, $iLeft, $iTop, $iStyle, $iExStyle, $hParent)
	If @error Then Return SetError(2, 0, 0)
	
	GUISetBkColor($iBkColor)
	
	GUICtrlCreateLabel($sMainLabelText, 45, 20, $iWidth - 90, 40, $SS_CENTER, $GUI_WS_EX_PARENTDRAG)
	GUICtrlSetFont(-1, 14)
	
	GUICtrlCreateIcon($sIconFile, 0, 10, 20, 32, 32)
	GUICtrlSetState(-1, 128)
	
	GUICtrlCreateGraphic(5, 75, $iWidth - 10, 3, $SS_ETCHEDFRAME)
	
	For $i = 1 To $iHyperLinks_Count - 1
		$iDelim_Pos = StringInStr($aHyperLinks[$i], "|")
		$sURL = StringTrimLeft($aHyperLinks[$i], $iDelim_Pos)
		$sURL_Title = StringLeft($aHyperLinks[$i], $iDelim_Pos - 1)
		
		If $sURL = "" Then
			ContinueLoop
		EndIf
		
		$anLinkLabel[$i][0] = __ABx_GUICtrlHyperlink_Create($sURL_Title, $iWidth - 150, $iLinkTop, -1, 15, $iLinkColor, $sURL, $SS_CENTER)
		$anLinkLabel[$i][1] = $sURL
		
		$iLinkTop += 30
	Next
	
	$iPlayMusic_CB = GUICtrlCreateCheckbox($sPlaySndText, 10, 82, -1, 18)
	If $ABX_PLAYSOUND Then GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetFont(-1, 8)
	
	GUICtrlCreateLabel($sBodyText, 10, $iElementsTop, ($iWidth / 2) - ($__ABx_iScrollWidth / 2) - 20, $__ABx_iScrollHeight)
	GUICtrlSetFont(-1, 10, 600, 0, "Tahoma")
	
	GUICtrlCreateLabel($sCopyRText, 0, $iHeight - 20, $iWidth, -1, 1)
	GUICtrlSetColor(-1, 0x969696)
	GUICtrlSetState(-1, $GUI_DISABLE)
	
	GUISetState(@SW_SHOW, $__ABx_hAboutGUI)
	
	_ScrollText_Create($__ABx_hAboutGUI, $sScrollText, ($iWidth / 2) - ($__ABx_iScrollWidth / 2), $iElementsTop, $__ABx_iScrollWidth, $__ABx_iScrollHeight, True, 2)
	
	$bSndFilesExists = FileExists(@ScriptDir & "\Resources\BASSMOD.DLL") And FileExists(@ScriptDir & "\Resources\About.xm")
	
	If $bSndFilesExists Then
		FileChangeDir(@ScriptDir)
		FileInstall("Resources\BASSMOD.DLL", $__ABx_sTmpDir & "\BASSMOD.DLL", 1)
		FileInstall("Resources\About.xm", $__ABx_sTmpDir & "\About.xm", 1)
	EndIf
	
	If $ABX_PLAYSOUND Then
		If $bSndFilesExists Then
			$ahAbout_Sound = __ABx_BASSMOD_Start($__ABx_sTmpDir & "\BASSMOD.dll", $__ABx_sTmpDir & "\About.xm", 1024+4)
		EndIf
		
		If @error Or Not $bSndFilesExists Then
			SoundPlay($__ABx_sSoundFile, 0)
		EndIf
	EndIf
	
	While 1
		$iAbout_Msg = GUIGetMsg()
		
		Switch $iAbout_Msg
			Case $GUI_EVENT_CLOSE
				ExitLoop
			Case $iPlayMusic_CB
				If GUICtrlRead($iPlayMusic_CB) = $GUI_CHECKED Then
					$ABX_PLAYSOUND = 1
					
					If $ABX_PLAYSOUND Then
						If $bSndFilesExists Then
							$ahAbout_Sound = __ABx_BASSMOD_Start($__ABx_sTmpDir & "\BASSMOD.dll", $__ABx_sTmpDir & "\About.xm", 1024+4)
						EndIf
						
						If @error Or Not $bSndFilesExists Then
							SoundPlay($__ABx_sSoundFile, 0)
						EndIf
					EndIf
				Else
					$ABX_PLAYSOUND = 0
					
					If IsArray($ahAbout_Sound) Then
						__ABx_BASSMOD_Close($ahAbout_Sound[0], $ahAbout_Sound[1])
						If @error Then SoundPlay("")
					Else
						SoundPlay("")
					EndIf
				EndIf
			Case $anLinkLabel[1][0] To $anLinkLabel[$anLinkLabel[0][0]][0]
				For $i = 1 To $anLinkLabel[0][0]
					If $iAbout_Msg = $anLinkLabel[$i][0] Then
						__ABx_GUICtrlHyperlink_Handler($__ABx_hAboutGUI, $anLinkLabel[$i][0], $anLinkLabel[$i][1], -1, 0x551A8B)
						ExitLoop
					EndIf
				Next
		EndSwitch
	WEnd
	
	If IsArray($ahAbout_Sound) Then
		__ABx_BASSMOD_Close($ahAbout_Sound[0], $ahAbout_Sound[1])
		
		If Not @error Then
			FileDelete($__ABx_sTmpDir & "\BASSMOD.DLL")
			FileDelete($__ABx_sTmpDir & "\About.xm")
		Else
			SoundPlay("")
		EndIf
	Else
		SoundPlay("")
	EndIf
	
	If IsHWnd($hParent) Then
		WinSetState($hParent, "", @SW_ENABLE)
	EndIf
	
	_ScrollText_Destroy()
	
	GUIDelete($__ABx_hAboutGUI)
	GUISwitch($hParent)
	
	Opt("GUIOnEventMode", $iOld_GOEM_Opt)
	Opt("WinWaitDelay", $iOld_WWD_Opt)
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __ABx_GUICtrlHyperlink_Create($sText, $iLeft, $iTop, $iWidth = -1, $iHeight = -1, $iColor = 0x0000FF, $sToolTip = '', $iStyle = -1, $iExStyle = -1)
	If $iWidth = -1 Then
		$iWidth = __ABx_GUICtrlLabelGetTextWidth($sText)
		$iWidth = $iWidth[0]
		
		If Not $iWidth Then
			$iWidth = -1
		EndIf
	EndIf
	
	If $iStyle <> -1 And BitAND($iStyle, $SS_CENTER) Then
		$iLeft += -($iWidth / 2) + 70
	EndIf
	
	Local $ID = GUICtrlCreateLabel($sText, $iLeft, $iTop, $iWidth, $iHeight, $iStyle, $iExStyle)
	
	If $ID Then
		GUICtrlSetFont($ID, -1, -1, 4)
		GUICtrlSetColor($ID, $iColor)
		GUICtrlSetCursor($ID, 0)
		GUICtrlSetTip($ID, $sToolTip)
	EndIf
	
	Return $ID
EndFunc

Func __ABx_GUICtrlHyperlink_Handler($hWnd, $iCtrlID, $sActionURL, $iAction = -1, $iVisitedColor = 0x551A8B)
	Local $aCurInfo = GUIGetCursorInfo($hWnd)
	
	If Not IsArray($aCurInfo) Then
		Return SetError(1, 0, 0)
	EndIf
	
	While IsArray($aCurInfo) And $aCurInfo[2] = 1
		$aCurInfo = GUIGetCursorInfo($hWnd)
		
		If $aCurInfo[4] <> $iCtrlID Then
			GUISetCursor(7, 1, $hWnd)
		Else
			GUISetCursor(2, 0, $hWnd)
		EndIf
		
		Sleep(10)
	WEnd
	
	GUISetCursor(2, 0, $hWnd)
	
	If IsArray($aCurInfo) And $aCurInfo[4] = $iCtrlID Then
		If $iAction = 1 Then
			Execute($sActionURL)
		ElseIf $iAction = -1 Then
			__ABx_ShellExecuteEx($sActionURL)
		EndIf
		
		If @error = 0 And $iVisitedColor Then
			GUICtrlSetColor($iCtrlID, $iVisitedColor)
		EndIf
		
		Return 1
	EndIf
	
	Return SetError(1, 0, 0)
EndFunc

Func __ABx_GUICtrlLabelGetTextWidth($s_Data, $i_FontSize = 8.5, $i_FontWeight = -1, $s_TextFont = "Arial")
	Local Const $DEFAULT_CHARSET = 0 ; ANSI character set
	Local Const $OUT_CHARACTER_PRECIS = 2
	Local Const $CLIP_DEFAULT_PRECIS = 0
	Local Const $PROOF_QUALITY = 2
	Local Const $FIXED_PITCH = 1
	Local Const $RGN_XOR = 3
	Local Const $LOGPIXELSY = 90
	
	If $i_FontWeight = "" Or $i_FontWeight = -1 Then
		$i_FontWeight = 400 ; default Font weight
	EndIf
	
	Local $hDC = _WinAPI_GetDC(0)
	Local $intDeviceCap = _WinAPI_GetDeviceCaps($hDC, $LOGPIXELSY)
	Local $intFontHeight = _WinAPI_MulDiv($i_FontSize, $intDeviceCap, 72)
	Local $hFont = _WinAPI_CreateFont(-$intFontHeight, 0, 0, 0, $i_FontWeight, 0, 0, 0, _
		$DEFAULT_CHARSET, $OUT_CHARACTER_PRECIS, $CLIP_DEFAULT_PRECIS, $PROOF_QUALITY, $FIXED_PITCH, $s_TextFont)
	
	_WinAPI_SelectObject($hDC, $hFont)
	Local $stRet = _WinAPI_GetTextExtentPoint32($hDC, $s_Data)
	
	_WinAPI_DeleteObject($hFont)
    _WinAPI_ReleaseDC(0, $hDC)
    ;_WinAPI_InvalidateRect(0, 0)
	
	Local $a_RetLen[2] = [DllStructGetData($stRet, 1), DllStructGetData($stRet, 2)]
	Return $a_RetLen
EndFunc

Func __ABx_BASSMOD_Start($sDllFile, $sSoundFile, $iFlag)
	If Not FileExists($sDllFile) Then
		Return SetError(1, 0, -1)
	EndIf
	
	Local $aRet[2]
	Local $hDll = DllOpen($sDllFile)
	
	If $hDll = -1 Then
		SetError(2, 0, -1)
	EndIf
	
	Local $Init = DllCall($hDll, "int", "BASSMOD_Init", "int", -1, _  ;device
		"int", 44100, _  ;freq Hz
		"int", 0)       ;flag
	
	Local $stFileName = DllStructCreate("char[255]")
	DllStructSetData($stFileName, 1, $sSoundFile)
	
	Local $aMusicLoad = DllCall($hDll, "int", "BASSMOD_MusicLoad", "int", False, _  ;loading from memory
		"ptr", DllStructGetPtr($stFileName), _ ;file
		"int", 0, _   ;offset
		"int", 0, _   ;length
		"int", $iFlag) ;flag
	
	Local $hSound = $aMusicLoad[0]
	DllCall($hDll, "int:cdecl", "BASSMOD_MusicPlay", "int", $hSound)
	
	$aRet[0] = $hDll
	$aRet[1] = $hSound
	
	Return $aRet
EndFunc

Func __ABx_BASSMOD_Close($hDll, $hSound)
	If $hDll = -1 Then
		Return SetError(1, 0, -1)
	EndIf
	
	DllCall($hDll, "int:cdecl", "BASSMOD_Free", "int", $hSound) ;clear resource
	DllClose($hDll)
EndFunc

Func __ABx_ShellExecuteEx($sCmd, $Args = "", $sFolder = "", $Verb = "", $rState = @SW_SHOWNORMAL, $hWnd = 0)
	Local $struINFO = DllStructCreate("long;long;long;ptr;ptr;ptr;ptr;long;long;long;ptr;long;long;long;long")
	Local $struVerb = DllStructCreate("char[15];char")
	Local $struPath = DllStructCreate("char[255];char")
	Local $struArgs = DllStructCreate("char[255];char")
	Local $struWDir = DllStructCreate("char[255];char")
	
	DllStructSetData($struVerb, 1, $Verb)
	
	If StringRight($sCmd, 3) = "lnk" Then
		Local $aShortcutInfo = FileGetShortcut($sCmd)
		
		If IsArray($aShortcutInfo) Then
			DllStructSetData($struPath, 1, $aShortcutInfo[0])
			DllStructSetData($struWDir, 1, $aShortcutInfo[1])
			DllStructSetData($struArgs, 1, $aShortcutInfo[2])
			$rState = $aShortcutInfo[6]
		Else
			Return SetError(1, 0, 0)
		EndIf
	Else
		DllStructSetData($struPath, 1, $sCmd)
		DllStructSetData($struWDir, 1, $sFolder)
		DllStructSetData($struArgs, 1, $Args)
	EndIf

	DllStructSetData($struINFO, 1, DllStructGetSize($struINFO))
	DllStructSetData($struINFO, 2, BitOR(0xC, 0x40, 0x400))
	DllStructSetData($struINFO, 3, $hWnd)
	DllStructSetData($struINFO, 4, DllStructGetPtr($struVerb))
	DllStructSetData($struINFO, 5, DllStructGetPtr($struPath))
	DllStructSetData($struINFO, 6, DllStructGetPtr($struArgs))
	DllStructSetData($struINFO, 7, DllStructGetPtr($struWDir))
	DllStructSetData($struINFO, 8, $rState)

	Local $iRet = DllCall("shell32.dll", "int", "ShellExecuteEx", "ptr", DllStructGetPtr($struINFO))
	If Not IsArray($iRet) Or Not $iRet[0] Then Return SetError(2, 0, 0)
	
	Return 1
EndFunc

#EndRegion Internal Functions
