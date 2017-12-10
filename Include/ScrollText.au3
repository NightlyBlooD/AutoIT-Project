#Region Header

#CS
	Name:				ScrollText UDF
	Description:		Scrolling text module using GDI+.
	Author:				Copyright © 2012 CreatoR's Lab (G.Sandler), www.creator-lab.ucoz.ru, www.autoit-script.ru. All rights reserved.
	AutoIt version:		3.3.8.1
	UDF version:		0.3
	
	Notes:				* The scroll control can be dragged by mouse primary button.
						* Only one scroll control can be created each time.
	
	Credits:			UEZ (scrolling mechanism), Yashied (gradient cover)
	
	History:
	v0.3
	+ Added $iBorderStyle parameter.
	
	v0.2
	* Changed scrolling text format (check the example).
	+ Added Color and Style parameters to each line (check UDF header).
	+ Added $iLeft, $iTop, $iWidth and $iHeight parameters to set ScrollText control initial position.
	  Parameters are added before $bStartScroll.
	
	v0.1
	* First version.
	
#CE

;Includes
#include-once
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <Misc.au3>
#include <Timers.au3>

_GDIPlus_Startup()

#EndRegion Header

#Region Global Variables

Global $_ST_iWidth, $_ST_iHeight
Global $_ST_iLastMouseYPos, $_ST_aText, $_ST_hTimer, $_ST_hGraphicCntxt, $_ST_hStrFormat, $_ST_hBitmap, $_ST_hGraphic
Global $_ST_ahScroll_GUI, $_ST_hTopCoverBrush, $_ST_hBottomCoverBrush
Global $_ST_iCoverHeight = 70
Global $_ST_iBkColor = 0xFFFFFF ;_WinAPI_GetSysColor($COLOR_3DFACE)
Global $_ST_iScrollSpeed = 1 ;Scrolling speed
Global $_ST_iMouseScroll = 1 ;Enables scroll by mouse drag
Global $_ST_iIsPressedOut = 0
Global $_ST_iIsPressedIn = 0

Global $_ST_sDef_FontName = 'Arial'
Global $_ST_iDef_FontSize = 16
Global $_ST_iDef_Color = 0x00007F
Global $_ST_iDef_Style = 0

Global Enum _
	$_ST_iElmnt_sTxt, $_ST_iElmnt_sFntName, $_ST_iElmnt_iFntSize, $_ST_iElmnt_iColor, $_ST_iElmnt_iStyle, _
	$_ST_iElmnt_hFamily, $_ST_iElmnt_hFont, $_ST_iElmnt_iInfoHeight, $_ST_iElmnt_iWidth, $_ST_iElmnt_iHeight, _
	$_ST_iElmnt_iTotal ;This should be last

#EndRegion Global Variables

#Region Public Functions

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_Create
; Description....: Creates scroll text control using GDI+.
; Syntax.........: _ScrollText_Create($hWnd, $sScrollData, $iLeft = -1, $iTop = -1, $iWidth = 500, $iHeight = 300, $bStartScroll = True, $iBorderStyle = 1)
; Parameters.....: $hWnd - Window handle.
;                  $sScrollData - String with data for scrolling text, format should be as follows:
;                                         $sScrollData = 'First text line(FontName,FontSize,Color,Style)\n(Arial,50)\nThird line'
;                                         Where each line is separated with \n, to set empty line omit the text.
;                                         Between the brackets at the end of line,
;                                           should be set line font name (FontName), line size (FontSize), text color (Color), and text style (Style).
;                                           The following flags can be used for Style:
;                                                                                      0 - Normal weight or thickness of the typeface (default)
;                                                                                      1 - Bold typeface
;                                                                                      2 - Italic typeface
;                                                                                      4 - Underline
;                                                                                      8 - Strikethrough
;                                         The parameters between the brackets can be omitted, in this case defaults will be used: (Arial,16,0x00007F,0).
;                  $iLeft - [Optional] Left position of ScrollText control. -1 (default) will set the control at the horizontal center of the parent GUI.
;                  $iTop - [Optional] Top position of ScrollText control. -1 (default) will set the control at the vertical center of the parent GUI.
;                  $iWidth - [Optional] Width of ScrollText control (minimum is 50, default is 300).
;                  $iHeight - [Optional] Height of ScrollText control (minimum is 40, default is 200).
;                  $bStartScroll - [Optional] If this parameter is True (default), then the scroll will start automatically, otherwise use _ScrollText_SetPause(False) later.
;                  $iBorderStyle - [Optional] Defines scroll text box border size. 0 - no style, 1 (default) - rounded corners, 2 - GUI border ($WS_BORDER).
;                  
;                 
; Return values..: Success - Returns 1.
;                  Failure - Returns 0 and set @error to 1 if unable to create the ScrollGUI.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: It is recommended to create ScrollText right *after* the main (parent) GUI is shown.
; Related........: 
; Link...........: 
; Example........: Yes.
; ===============================================================================================================
Func _ScrollText_Create($hWnd, $sScrollData, $iLeft = -1, $iTop = -1, $iWidth = 300, $iHeight = 200, $bStartScroll = True, $iBorderStyle = 1)
	Local $aParentSize, $aGUISize, $aInfo, $iInfoWidth, $iLineHeight
	Local $aSplitData, $aSplitParams, $sText, $sFont, $iSize, $iColor, $iStyle
	Local $iGUIStyle = $WS_CHILD
	
	If $iBorderStyle = 2 Then
		$iGUIStyle = BitOR($iGUIStyle, $WS_BORDER)
	EndIf
	
	$aParentSize = WinGetClientSize($hWnd)
	
	If $iLeft = -1 Then
		$iLeft = ($aParentSize[0] / 2) - ($iWidth / 2)
	EndIf
	
	If $iTop = -1 Then
		$iTop = ($aParentSize[1] / 2) - ($iHeight / 2)
	EndIf
	
	If $iWidth < 50 Then
		$iWidth = 50
	EndIf
	
	If $iHeight < 40 Then
		$iHeight = 40
	EndIf
	
	$_ST_ahScroll_GUI = GUICreate('', $iWidth, $iHeight, $iLeft, $iTop, $iGUIStyle, -1, $hWnd)
	If @error Then Return SetError(1, 0, 0)
	
	If @OSBuild < 7600 Then
		WinSetTrans($_ST_ahScroll_GUI, "", 0xFF)
	EndIf
	
	If $iBorderStyle = 1 Then
		__ST_GUIRoundCorners($_ST_ahScroll_GUI, 5, 5, 30, 30)
	EndIf
	
	$aGUISize = WinGetClientSize($_ST_ahScroll_GUI)
	
	$_ST_iWidth = $aGUISize[0]
	$_ST_iHeight = $aGUISize[1]
	
	$_ST_iBkColor = Hex($_ST_iBkColor, 6)
	
	;=== Gradient ===
	$tRect = DllStructCreate($tagGDIPRECTF)
	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, 0)
	DllStructSetData($tRect, 3, $_ST_iWidth)
	DllStructSetData($tRect, 4, $_ST_iCoverHeight)
	$_ST_hTopCoverBrush = __ST_GDIPlus_LineBrushCreateFromRect($tRect, '0xFF' & $_ST_iBkColor, '0x00' & $_ST_iBkColor, 1)
	DllStructSetData($tRect, 1, 0)
	DllStructSetData($tRect, 2, $_ST_iHeight - $_ST_iCoverHeight)
	DllStructSetData($tRect, 3, $_ST_iWidth)
	DllStructSetData($tRect, 4, $_ST_iCoverHeight)
	$_ST_hBottomCoverBrush = __ST_GDIPlus_LineBrushCreateFromRect($tRect, '0x00' & $_ST_iBkColor, '0xFF' & $_ST_iBkColor, 1)
	
	GUISetState(@SW_SHOW, $_ST_ahScroll_GUI)
	
	$aSplitData = StringSplit($sScrollData, '\n', 1)
	
	Dim $_ST_aText[UBound($aSplitData)-1][$_ST_iElmnt_iTotal]
	
	For $i = 1 To $aSplitData[0]
		$sText = StringRegExpReplace($aSplitData[$i], '\h*\([^)]*\)$', '')
		
		If $sText = '' Then
			$sText = ' '
		EndIf
		
		$aSplitParams = StringSplit(StringRegExpReplace($aSplitData[$i], '.*?(\(([^)]*)\)|)$', '\2'), ',')
		ReDim $aSplitParams[5]
		
		For $j = 1 To $aSplitParams[0]
			$aSplitParams[$j] = StringStripWS($aSplitParams[$j], 3)
		Next
		
		$sFont = _Iif($aSplitParams[1] = '', $_ST_sDef_FontName, $aSplitParams[1])
		$iSize = _Iif($aSplitParams[2] = '', $_ST_iDef_FontSize, $aSplitParams[2])
		$iColor = Hex(_Iif($aSplitParams[3] = '', $_ST_iDef_Color, $aSplitParams[3]), 6)
		$iStyle = _Iif($aSplitParams[4] = '', $_ST_iDef_Style, $aSplitParams[4])
		
		;ConsoleWrite($sText & ", " & $sFont & ", " & $iSize & ", " & $iColor & ", " & $iStyle & @LF)
		
		$_ST_aText[$i-1][$_ST_iElmnt_sTxt] = $sText
		$_ST_aText[$i-1][$_ST_iElmnt_sFntName] = $sFont
		$_ST_aText[$i-1][$_ST_iElmnt_iFntSize] = Number($iSize)
		$_ST_aText[$i-1][$_ST_iElmnt_iColor] = $iColor
		$_ST_aText[$i-1][$_ST_iElmnt_iStyle] = $iStyle
		$_ST_aText[$i-1][$_ST_iElmnt_hFamily] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_hFont] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iInfoHeight] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iWidth] = 0
		$_ST_aText[$i-1][$_ST_iElmnt_iHeight] = 0
	Next
	
	; Draw a string
	$_ST_hGraphic = _GDIPlus_GraphicsCreateFromHWND($_ST_ahScroll_GUI)
	$_ST_hBitmap = _GDIPlus_BitmapCreateFromGraphics($_ST_iWidth, $_ST_iHeight, $_ST_hGraphic)
	$_ST_hGraphicCntxt = _GDIPlus_ImageGetGraphicsContext($_ST_hBitmap)
	_GDIPlus_GraphicsClear($_ST_hGraphicCntxt, '0xFF' & $_ST_iBkColor)
	_GDIPlus_GraphicsSetSmoothingMode($_ST_hGraphicCntxt, 2)
	DllCall($ghGDIPDll, "uint", "GdipSetTextRenderingHint", "handle", $_ST_hGraphicCntxt, "int", 4)
	
	$_ST_hStrFormat = _GDIPlus_StringFormatCreate()
	$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
	
	For $z = 0 To UBound($_ST_aText) - 1
		$_ST_aText[$z][$_ST_iElmnt_hFamily] = _GDIPlus_FontFamilyCreate($_ST_aText[$z][$_ST_iElmnt_sFntName]) ;$hFamily
		$_ST_aText[$z][$_ST_iElmnt_hFont] = _GDIPlus_FontCreate($_ST_aText[$z][$_ST_iElmnt_hFamily], $_ST_aText[$z][$_ST_iElmnt_iFntSize], $_ST_aText[$z][$_ST_iElmnt_iStyle]) ;$hFont
		$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
		$iInfoWidth = Floor(DllStructGetData($aInfo[0], "Width"))
		$_ST_aText[$z][$_ST_iElmnt_iInfoHeight] = Floor(DllStructGetData($aInfo[0], "Height"))
		$_ST_aText[$z][$_ST_iElmnt_iWidth] = Floor($_ST_iWidth / 2 - ($iInfoWidth / 2))
		$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor($_ST_iHeight + $iLineHeight)
		$iLineHeight += $_ST_aText[$z][$_ST_iElmnt_iInfoHeight]
	Next
	
	_ScrollText_SetPos($_ST_iScrollSpeed)
	_ScrollText_SetPause(Not $bStartScroll)
	
	Return 1
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_Destroy
; Description....: Destroys ScrollText control.
; Syntax.........: _ScrollText_Destroy()
; Parameters.....: None.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_Destroy()
	_Timer_KillTimer($_ST_ahScroll_GUI, $_ST_hTimer)
	
	For $z = 0 To UBound($_ST_aText) - 1
		_GDIPlus_FontDispose($_ST_aText[$z][$_ST_iElmnt_hFont])
		_GDIPlus_FontFamilyDispose($_ST_aText[$z][$_ST_iElmnt_hFamily])
	Next
	
	_GDIPlus_StringFormatDispose($_ST_hStrFormat)
	_GDIPlus_BitmapDispose($_ST_hBitmap)
	_GDIPlus_GraphicsDispose($_ST_hGraphicCntxt)
	_GDIPlus_GraphicsDispose($_ST_hGraphic)
	
	_GDIPlus_BrushDispose($_ST_hTopCoverBrush)
	_GDIPlus_BrushDispose($_ST_hBottomCoverBrush)
	
	GUIDelete($_ST_ahScroll_GUI)
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_SetPause
; Description....: 
; Syntax.........: _ScrollText_SetPause($bPause = True)
; Parameters.....: $bPause [Optional] - Determines whether to pause the scrolling or not.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_SetPause($bPause = True)
	If $bPause Then
		If $_ST_hTimer Then
			_Timer_KillTimer($_ST_ahScroll_GUI, $_ST_hTimer)
			$_ST_hTimer = 0
		EndIf
	Else
		$_ST_hTimer = _Timer_SetTimer($_ST_ahScroll_GUI, 10, "__ST_Handler")
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================
; Name...........: _ScrollText_SetPos
; Description....: Sets scrolling position, used to move the ScrollText by mouse drag (up/down).
; Syntax.........: _ScrollText_SetPos($iPos)
; Parameters.....: $iPos - Vertical position move to.
;                  
;                 
; Return values..: None.
;
; Author.........: G.Sandler
; Modified.......: 
; Remarks........: 
; Related........: 
; Link...........: 
; Example........: 
; ===============================================================================================================
Func _ScrollText_SetPos($iPos)
	Local $tLayout, $hBrush
	
	_GDIPlus_GraphicsClear($_ST_hGraphicCntxt, '0xFF' & $_ST_iBkColor)
	
	For $z = 0 To UBound($_ST_aText) - 1
		If $_ST_aText[$z][$_ST_iElmnt_iHeight] < $_ST_iHeight And $_ST_aText[$z][$_ST_iElmnt_iInfoHeight] > - $_ST_aText[$z][$_ST_iElmnt_iHeight] Then
			$tLayout = _GDIPlus_RectFCreate($_ST_aText[$z][$_ST_iElmnt_iWidth], $_ST_aText[$z][$_ST_iElmnt_iHeight], 0, 0)
			$hBrush = _GDIPlus_BrushCreateSolid('0xFF' & $_ST_aText[$z][$_ST_iElmnt_iColor])
			_GDIPlus_GraphicsDrawStringEx($_ST_hGraphicCntxt, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat, $hBrush)
			_GDIPlus_BrushDispose($hBrush)
		EndIf
		
		$_ST_aText[$z][$_ST_iElmnt_iHeight] -= $iPos
	Next
	
	_GDIPlus_GraphicsFillRect($_ST_hGraphicCntxt, 0, -1, $_ST_iWidth, $_ST_iCoverHeight, $_ST_hTopCoverBrush)
	_GDIPlus_GraphicsFillRect($_ST_hGraphicCntxt, 0, $_ST_iHeight - $_ST_iCoverHeight, $_ST_iWidth, $_ST_iCoverHeight, $_ST_hBottomCoverBrush)
	
	_GDIPlus_GraphicsDrawImageRect($_ST_hGraphic, $_ST_hBitmap, 0, 0, $_ST_iWidth, $_ST_iHeight)
EndFunc

#EndRegion Public Functions

#Region Internal Functions

Func __ST_Handler($hWnd, $iMsg, $iIDTimer, $dwTime)
	Local $tLayout, $aInfo, $iLineHeight, $iPos
	Local $iMouseYPos = MouseGetPos(1)
	Local $tRect = _WinAPI_GetMousePos()
	Local $hWinFromPoint = _WinAPI_WindowFromPoint($tRect)
	Local $iIsPressed_Key = '01'
	
	If _WinAPI_GetSystemMetrics($SM_SWAPBUTTON) Then
		$iIsPressed_Key = '02'
	EndIf
	
	If Not $_ST_iIsPressedIn And _IsPressed($iIsPressed_Key) And $hWinFromPoint <> $hWnd Then
		$_ST_iIsPressedOut = 1
		$_ST_iIsPressedIn = 0
	ElseIf Not $_ST_iIsPressedOut And _IsPressed($iIsPressed_Key) And $hWinFromPoint = $hWnd Then
		$_ST_iIsPressedOut = 0
		$_ST_iIsPressedIn = 1
	EndIf
	
	If Not _IsPressed($iIsPressed_Key) Then
		$_ST_iIsPressedOut = 0
		$_ST_iIsPressedIn = 0
	EndIf
	
	Local $bScroll = ($_ST_iMouseScroll And $_ST_iIsPressedIn And _IsPressed($iIsPressed_Key))
	
	If $bScroll Then
		GUISetCursor(11, 1, $hWnd)
		
		If $iMouseYPos > $_ST_iLastMouseYPos Then
			$iPos -= ($iMouseYPos - $_ST_iLastMouseYPos)
			$_ST_iLastMouseYPos = $iMouseYPos
		ElseIf $iMouseYPos < $_ST_iLastMouseYPos Then
			$iPos += ($_ST_iLastMouseYPos - $iMouseYPos)
			$_ST_iLastMouseYPos = $iMouseYPos
		EndIf
	Else
		GUISetCursor(0, 1, $hWnd)
		
		$iPos = $_ST_iScrollSpeed
		$_ST_iLastMouseYPos = $iMouseYPos
	EndIf
	
	_ScrollText_SetPos($iPos)
	
	If $_ST_aText[UBound($_ST_aText) - 1][$_ST_iElmnt_iHeight] < - $_ST_aText[UBound($_ST_aText) - 1][$_ST_iElmnt_iInfoHeight] * 2.5 Then ;Reached the ceiling
		$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
		
		For $z = 0 To UBound($_ST_aText) - 1
			$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
			$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor($_ST_iHeight + $iLineHeight)
			$iLineHeight += Floor(DllStructGetData($aInfo[0], "Height"))
		Next
	ElseIf $bScroll And $_ST_aText[0][$_ST_iElmnt_iHeight] > $_ST_iHeight Then ;Reached the floor
		$tLayout = _GDIPlus_RectFCreate(0, 0, 0, 0)
		
		For $z = UBound($_ST_aText) - 1 To 0 Step -1
			$aInfo = _GDIPlus_GraphicsMeasureString($_ST_hGraphic, $_ST_aText[$z][$_ST_iElmnt_sTxt], $_ST_aText[$z][$_ST_iElmnt_hFont], $tLayout, $_ST_hStrFormat)
			$iLineHeight += Floor(DllStructGetData($aInfo[0], "Height"))
			$_ST_aText[$z][$_ST_iElmnt_iHeight] = Floor(-$iLineHeight)
		Next
	EndIf
EndFunc

Func __ST_GUIRoundCorners($hWnd, $iX1, $iY1, $iX2, $iY2)
	Local $aWPos = WinGetPos($hWnd)
	
	If Not IsArray($aWPos) Then
		Return SetError(1, 0, 0)
	EndIf
	
	Local $aRet = DllCall("gdi32.dll", "long", "CreateRoundRectRgn", _
			"long", $iX1, _
			"long", $iX1, _
			"long", $aWPos[2], _
			"long", $aWPos[3], _
			"long", $iX2, _
			"long", $iY2)
	
	If IsArray($aRet) And $aRet[0] Then
		Return DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $hWnd, "long", $aRet[0], "int", 1)
	EndIf
	
	Return SetError(2, 0, 0)
EndFunc

Func __ST_GDIPlus_LineBrushCreateFromRect($tRectF, $iARGBClr1, $iARGBClr2, $iGradientMode = 0, $iWrapMode = 0)
	Local $pRectF, $aResult
	
	$pRectF = DllStructGetPtr($tRectF)
	$aResult = DllCall($ghGDIPDll, "uint", "GdipCreateLineBrushFromRect", "ptr", $pRectF, "uint", $iARGBClr1, "uint", $iARGBClr2, "int", $iGradientMode, "int", $iWrapMode, "int*", 0)
	
	If @error Then Return SetError(@error, @extended, 0)
	Return $aResult[6]
EndFunc

#EndRegion Internal Functions
