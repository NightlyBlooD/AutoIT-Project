#Include <WinAPIEx.au3>

; Тестировалось на WindowsXP Sp3, Windows7

OnAutoItExitRegister("F_62845109")

Global $4A536B69[1][17] = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

#cs
   $4A536B69[$i][0]  = ID фона.
   $4A536B69[$i][1]  = Handle фона.
   $4A536B69[$i][2]  = Цвет рамки.
   $4A536B69[$i][3]  = 1й цвет фона.
   $4A536B69[$i][4]  = 2й цвет фона.
   $4A536B69[$i][5]  = ID прогресса.
   $4A536B69[$i][6]  = Handle прогресса.
   $4A536B69[$i][7]  = 1й цвет прогресса.
   $4A536B69[$i][8]  = 2й цвет прогресса.
   $4A536B69[$i][9]  = Координаты левого края элемента.
   $4A536B69[$i][10] = Координата верхнего края элемента.
   $4A536B69[$i][11] = Ширина элемента.
   $4A536B69[$i][12] = Высота элемента.
   $4A536B69[$i][13] = Значение элемента.
   $4A536B69[$i][14] = Тип элемента.
   $4A536B69[$i][15] = Вид градиента.
   $4A536B69[$i][16] = Ширина рамки элемента.
#ce

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_CreateProgressBar
; Description....: Создать в окне элемент Progress.
; Syntax.........: _JSkin_CreateProgressBar ($iLeft, $iTop, $iWidth, $iHeight, $Gradient, $iColor)
;                  $iLeft    - Координаты левого края элемента.
;                  $iTop     - Координата верхнего края элемента.
;                  $iWidth   - Ширина элемента.
;                  $iHeight  - Высота элемента.
;                  $iColor   - Массив с цветов элемента.
; Parameters.....:
; Return values..: ID элемента Progress.
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_CreateProgressBar($iLeft, $iTop, $iWidth, $iHeight, ByRef $iColor)

	Local $69466F6E, $68466F6E, $694C696E, $684C696E, $52018347, $61930287, $72904294 = 1

	If $iWidth > $iHeight Then $52018347 = 0
	If $iWidth < $iHeight Then $52018347 = 1

	If IsArray($iColor) Then
        $69466F6E = GUICtrlCreatePic("", $iLeft, $iTop, $iWidth, $iHeight)
        $68466F6E = GUICtrlGetHandle($69466F6E)
        GUICtrlSetState($69466F6E, 128)

	    $694C696E = GUICtrlCreatePic("", $iLeft + $72904294, $iTop + $72904294, $iWidth - ($72904294 * 2), $iHeight - ($72904294 * 2))
        $684C696E = GUICtrlGetHandle($694C696E)
	    GUICtrlSetState($694C696E, 128)

	    $4A536B69[0][0] += 1
	    ReDim $4A536B69[$4A536B69[0][0] + 1][UBound($4A536B69, 2)]
	    $4A536B69[$4A536B69[0][0]][0]  = $69466F6E
	    $4A536B69[$4A536B69[0][0]][1]  = $68466F6E
	    $4A536B69[$4A536B69[0][0]][2]  = $iColor[0]
	    $4A536B69[$4A536B69[0][0]][3]  = $iColor[1]
	    $4A536B69[$4A536B69[0][0]][4]  = $iColor[2]
	    $4A536B69[$4A536B69[0][0]][5]  = $694C696E
	    $4A536B69[$4A536B69[0][0]][6]  = $684C696E
	    $4A536B69[$4A536B69[0][0]][7]  = $iColor[3]
	    $4A536B69[$4A536B69[0][0]][8]  = $iColor[4]
	    $4A536B69[$4A536B69[0][0]][9]  = $iLeft
	    $4A536B69[$4A536B69[0][0]][10] = $iTop
	    $4A536B69[$4A536B69[0][0]][11] = $iWidth
	    $4A536B69[$4A536B69[0][0]][12] = $iHeight
	    $4A536B69[$4A536B69[0][0]][13] = 0
	    $4A536B69[$4A536B69[0][0]][14] = $52018347
	    $4A536B69[$4A536B69[0][0]][15] = $52018347
		$4A536B69[$4A536B69[0][0]][16] = $72904294

	    If F_53657446($68466F6E, $iWidth, $iHeight, $iColor[0], $iColor[1], $iColor[2]) <> 1 Then
           GUICtrlDelete($69466F6E)
		   GUICtrlDelete($694C696E)
        EndIf

	    Return $694C696E
	EndIf

EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_SetProgressBorder
; Description....: Увеличивает размер бордюра элемента Progress.
; Syntax.........: _JSkin_SetProgressBorder($iCtrlId, $iSize)
;                  $iCtrlId - ID элемента.
;                  $iSize   - Размер.
; Parameters.....:
; Return values..:
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_SetProgressBorder($iCtrlId, $iSize)
	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			$4A536B69[$i][16] = $iSize
			If F_53657446($4A536B69[$i][1], $4A536B69[$i][11], $4A536B69[$i][12], $4A536B69[$i][2], $4A536B69[$i][3], $4A536B69[$i][4]) <> 1 Then
               GUICtrlDelete($4A536B69[$i][5])
		       GUICtrlDelete($4A536B69[$i][5])
		    EndIf
			_WinAPI_SetWindowPos($4A536B69[$i][6], 1, $4A536B69[$i][9] + $4A536B69[$i][16], $4A536B69[$i][10] + $4A536B69[$i][16], $4A536B69[$i][11] - ($4A536B69[$i][16] * 2), $4A536B69[$i][12] - ($4A536B69[$i][16] * 2), BitOR(0x0010, 0x0004))
		EndIf
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_SetProgressStep
; Description....: Установит значение для элемента Progress.
; Syntax.........: _JSkin_SetProgressStep($iCtrlId, $iStep)
;                  $iCtrlId - ID элемента.
;                  $iStep   - Шаг заполнения.
; Parameters.....:
; Return values..:
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_SetProgressStep($iCtrlId, $iStep)

	Local $76537465, $69684443, $68446573, $68426974, $76574468, $47726164
	If $iStep >= 100 Then $iStep = 100
	If $iStep <= 0 Then $iStep = 0

	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			If $4A536B69[$i][14] = 0 Then
			    $76537465 = Round($iStep * (($4A536B69[$i][11] - $4A536B69[$i][16])/ 100))
			    $4A536B69[$i][13] = Round(($76537465 / (($4A536B69[$i][11] - $4A536B69[$i][16]) / 100)))
			    $69684443 = _WinAPI_GetDC($4A536B69[$i][6])
                $68446573 = _WinAPI_CreateCompatibleDC($69684443)
                $68426974 = _WinAPI_CreateCompatibleBitmapEx($69684443, $76537465 - $4A536B69[$i][16], $4A536B69[$i][12] - ($4A536B69[$i][16] * 2), 0x060606)
                $76574468 = _WinAPI_SelectObject($68446573, $68426974)
                Dim $47726164[2][3] = [[0, 0, $4A536B69[$i][7]], [$76537465 - $4A536B69[$i][16], $4A536B69[$i][12] - ($4A536B69[$i][16] * 2), $4A536B69[$i][8]]]
                _WinAPI_GradientFill($68446573, $47726164, 0, 2, $4A536B69[$i][15])
                _WinAPI_ReleaseDC($4A536B69[$i][6], $69684443)
                _WinAPI_SelectObject($68446573, $76574468)
                _WinAPI_DeleteDC($68446573)
                _SendMessage($4A536B69[$i][6], 0x0172, 0, $68426974)
				If ($4A536B69[$i][13] >= 101) Or ($4A536B69[$i][13] <= -1) Then GUICtrlSetState($4A536B69[$i][5], 16)

		    ElseIf $4A536B69[$i][14] = 1 Then
			    $76537465 = Round($iStep * (($4A536B69[$i][12] - $4A536B69[$i][16])/ 100))
			    $4A536B69[$i][13] = Round(($76537465 / (($4A536B69[$i][12] - $4A536B69[$i][16]) / 100)))
				_WinAPI_SetWindowPos($4A536B69[$i][6], 1, $4A536B69[$i][9] + $4A536B69[$i][16], ($4A536B69[$i][10] + $4A536B69[$i][12]) - $76537465 , $4A536B69[$i][11] - ($4A536B69[$i][16] * 2), ($4A536B69[$i][12] - $4A536B69[$i][12] - $4A536B69[$i][16]) + $76537465, BitOR(0x0010, 0x0004))
				$69684443 = _WinAPI_GetDC($4A536B69[$i][6])
                $68446573 = _WinAPI_CreateCompatibleDC($69684443)
                $68426974 = _WinAPI_CreateCompatibleBitmapEx($69684443, $4A536B69[$i][11] - ($4A536B69[$i][16] * 2), ($4A536B69[$i][12] - $4A536B69[$i][12] - $4A536B69[$i][16]) + $76537465, 0x060606)
                $76574468 = _WinAPI_SelectObject($68446573, $68426974)
                Dim $47726164[4][3] = [[0, 0, $4A536B69[$i][7]], _
                                       [$4A536B69[$i][11] - ($4A536B69[$i][16] * 2), ($4A536B69[$i][12] - $4A536B69[$i][12] - $4A536B69[$i][16]) + $76537465, $4A536B69[$i][8]], _
                                       [  0, ($4A536B69[$i][12] - $4A536B69[$i][12] - $4A536B69[$i][16]) + $76537465, $4A536B69[$i][8]], _
                                       [0, 0, $4A536B69[$i][7]]]
                _WinAPI_GradientFill($68446573, $47726164, 0, 1, $4A536B69[$i][15])
                _WinAPI_GradientFill($68446573, $47726164, 2, 3, $4A536B69[$i][15])
                _WinAPI_ReleaseDC($4A536B69[$i][6], $69684443)
                _WinAPI_SelectObject($68446573, $76574468)
                _WinAPI_DeleteDC($68446573)
                _SendMessage($4A536B69[$i][6], 0x0172, 0, $68426974)
				If ($4A536B69[$i][13] >= 101) Or ($4A536B69[$i][13] <= -1) Then GUICtrlSetState($4A536B69[$i][5], 16)
		    EndIf
        EndIf
    Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_GetProgressStep
; Description....: Вернуть значение заполнения элемента Progress.
; Syntax.........: _JSkin_GetProgressStep($iCtrlId)
;                  $iCtrlId - ID элемента.
; Parameters.....:
; Return values..: Значение элемента Progress.
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_GetProgressStep($iCtrlId)
	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			Return $4A536B69[$i][13]
		EndIf
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_SetProgressColor
; Description....: Установить новые цвета элемента Progress.
; Syntax.........: _JSkin_SetProgressColor($iCtrlId, $iColor)
;                  $iCtrlId - ID элемента.
;                  $iColor  - Массив цветов.
; Parameters.....:
; Return values..:
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_SetProgressColor($iCtrlId, ByRef $iColor)
	If IsArray($iColor) Then
	    For $i = 1 To $4A536B69[0][0]
		    If $4A536B69[$i][5] = $iCtrlId Then
	            $4A536B69[$i][2] = $iColor[0]
	            $4A536B69[$i][3] = $iColor[1]
	            $4A536B69[$i][4] = $iColor[2]
	            $4A536B69[$i][7] = $iColor[3]
	            $4A536B69[$i][8] = $iColor[4]
		    EndIf
	    Next
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_GetProgressColor
; Description....: Вернуть цвета элемента Progress.
; Syntax.........: _JSkin_GetProgressColor($iCtrlId)
;                  $iCtrlId - ID элемента.
; Parameters.....:
; Return values..: Массив цветов.
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_GetProgressColor($iCtrlId)
	Local $41727261[5]
	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			$41727261[0] = Binary("0x" & Hex($4A536B69[$i][2], 6))
			$41727261[1] = Binary("0x" & Hex($4A536B69[$i][3], 6))
			$41727261[2] = Binary("0x" & Hex($4A536B69[$i][4], 6))
			$41727261[3] = Binary("0x" & Hex($4A536B69[$i][7], 6))
			$41727261[4] = Binary("0x" & Hex($4A536B69[$i][8], 6))
			If IsArray($41727261) Then
			    Return $41727261
			EndIf
		EndIf
	Next
    Return 0
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_SetProgressPos
; Description....: Установить положение элемента Progress.
; Syntax.........: _JSkin_SetProgressPos($iCtrlId, $iLeft, $iTop[, $iWidth[, $iHeight]])
;                  $iCtrlId - ID элемента.
;                  $iLeft    - Координаты левого края элемента.
;                  $iTop     - Координата верхнего края элемента.
;                  $iWidth   - Ширина элемента (Стандартно = -1).
;                  $iHeight  - Высота элемента (Стандартно = -1).
; Parameters.....:
; Return values..:
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_SetProgressPos($iCtrlId, $iLeft, $iTop, $iWidth = -1, $iHeight = -1)
	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			$4A536B69[$i][9] = $iLeft
			$4A536B69[$i][10] = $iTop
			If ($iWidth <> -1) And ($iHeight <> -1) Then
			    $4A536B69[$i][11] = $iWidth
			    $4A536B69[$i][12] = $iHeight
			ElseIf ($iWidth = -1) And ($iHeight = -1) Then
				$iWidth = $4A536B69[$i][11]
				$iHeight = $4A536B69[$i][12]
			EndIf
			_WinAPI_SetWindowPos($4A536B69[$i][1], 1, $iLeft, $iTop, $iWidth, $iHeight, BitOR(0x0010, 0x0004))
			_WinAPI_SetWindowPos($4A536B69[$i][6], 1, $iLeft + $4A536B69[$i][16], $iTop + $4A536B69[$i][16], $iWidth - ($4A536B69[$i][16] * 2), $iHeight - ($4A536B69[$i][16] * 2), BitOR(0x0010, 0x0004))
		EndIf
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_GetProgressPos
; Description....: Вернуть положение элемента Progress.
; Syntax.........: _JSkin_GetProgressPos($iCtrlId)
;                  $iCtrlId - ID элемента.
; Parameters.....:
; Return values..: Массив координат.
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_GetProgressPos($iCtrlId)
	Local $41727261[4]
	For $i = 1 To $4A536B69[0][0]
		If $4A536B69[$i][5] = $iCtrlId Then
			$41727261[0] = $4A536B69[$i][9]
			$41727261[1] = $4A536B69[$i][10]
			$41727261[2] = $4A536B69[$i][11]
			$41727261[3] = $4A536B69[$i][12]
			Return $41727261
		EndIf
	Next
EndFunc

; #FUNCTION# ====================================================================================================================
; Name...........: _JSkin_RevProgressStep
; Description....: Реверсировать заполнение элемента Progress.
; Syntax.........: _JSkin_RevProgressStep($iStep)
;                  $iStep - Шаг заполнения.
; Parameters.....:
; Return values..: Реверсированный шаг заполнения.
; Author.........: Viktor1703
; Modified.......:
; Remarks........: None
; Related........:
; Link...........:
; Example........: Yes
; ===============================================================================================================================
Func _JSkin_RevProgressStep($iStep)
	If IsNumber($iStep) Then
	    Return (100 - $iStep)
	EndIf
EndFunc

#Region Internal Functions
Func F_53657446($iCtrlId, $iWidth, $iHeight, $iFrame, $iTColor, $iBColor)

	Local $69684443, $68446573, $68426974, $76574468, $47726164

	$69684443 = _WinAPI_GetDC($iCtrlId)
    $68446573 = _WinAPI_CreateCompatibleDC($69684443)
    $68426974 = _WinAPI_CreateCompatibleBitmapEx($69684443, $iWidth, $iHeight, $iFrame)
    $76574468 = _WinAPI_SelectObject($68446573, $68426974)
	For $i = 0 To $4A536B69[0][0]
	    If $4A536B69[$i][1] = $iCtrlId Then
			If $4A536B69[$i][14] = 0 Then
                Dim $47726164[2][3] = [[$4A536B69[$i][16], $4A536B69[$i][16], $iTColor], [$iWidth - $4A536B69[$i][16], $iHeight - $4A536B69[$i][16], $iBColor]]
               _WinAPI_GradientFill($68446573, $47726164)
			Else
			   Dim $47726164[4][3] = [[$4A536B69[$i][16], $4A536B69[$i][16], $iTColor], _
									   [$iWidth - $4A536B69[$i][16], $iHeight - $4A536B69[$i][16], $iBColor], _
									   [  0, $iHeight - $4A536B69[$i][16], $iBColor], _
                                       [0, 0, $iTColor]]
				_WinAPI_GradientFill($68446573, $47726164, 0, 1, 2)
                _WinAPI_GradientFill($68446573, $47726164, 2, 3, 1)
		    EndIf
	    EndIf
	Next
    _WinAPI_ReleaseDC($iCtrlId, $69684443)
    _WinAPI_SelectObject($68446573, $76574468)
    _WinAPI_DeleteDC($68446573)
    _SendMessage($iCtrlId, 0x0172, 0, $68426974)
    If _SendMessage($iCtrlId, 0x0173) <> $68426974 Then
	    _WinAPI_DeleteObject($68426974)
		Return 0
    EndIf

	Return 1
EndFunc

Func F_62845109()
	Local $52871063, $44001832
	For $i = 0 To $4A536B69[0][0]
		_WinAPI_DeleteObject($4A536B69[$i][0])
		_WinAPI_DeleteObject($4A536B69[$i][1])
		_WinAPI_DeleteObject($4A536B69[$i][5])
		_WinAPI_DeleteObject($4A536B69[$i][6])
		GUICtrlDelete($4A536B69[$i][0])
		GUICtrlDelete($4A536B69[$i][5])
	Next
EndFunc
#EndRegion Internal Functions