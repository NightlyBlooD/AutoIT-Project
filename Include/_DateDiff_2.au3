#include-once
#include <Date.au3>

; ============================================================================================
; Function Name ...: _DateDiff_2 ( __DateDiff_2 )
; Description ........: Calculates the difference between dates
; Syntax.......: _DateDiff_2 ( $Old, $New[, $iArray = 1] )
; Parameters:
;		$Old - old date, for example birthday
;		$New - New date, for example current
; Return Value:
;		Success: - an array or a string containing the time difference. If @extended=1, then $Old > $New
;			|String format Г.ММ.ДД ЧЧ:ММ:СС
;			|Array format
;				$Array[0] = YEAR
;				$Array[1] = MON
;				$Array[2] = MDAY
;				$Array[3] = HOUR
;				$Array[4] = MIN
;				$Array[5] = SEC
;		Failure: - empty string, @error:
;			|1 - $Old не массив или менее 6 элементов
;			|2 - $New не массив или менее 6 элементов
; Author(s) ..........: AZJIO
; Remarks ..: Transmitted data in the arrays are not checked
; ============================================================================================
; Имя функции ...: _DateDiff_2 ( __DateDiff_2 )
; Описание ........: Вычисляет разницу между датами и временем
; Синтаксис.......: _DateDiff_2 ( $Old, $New[, $iArray = 1] )
; Параметры:
;		$Old - Старая дата, например день рождения
;		$New - Новая дата, например текущая
; Возвращаемое значение:
;		Успешно - массив или строка содержащие разницу во времени. Если @extended=1, то $Old > $New
;			|Строка в формате Г.ММ.ДД ЧЧ:ММ:СС
;			|Массив в формате
;				$Array[0] = YEAR
;				$Array[1] = MON
;				$Array[2] = MDAY
;				$Array[3] = HOUR
;				$Array[4] = MIN
;				$Array[5] = SEC
;		Неудачно - пустая строка, @error:
;			|1 - $Old не массив или менее 6 элементов
;			|2 - $New не массив или менее 6 элементов
; Автор ..........: AZJIO
; Примечания ..: Валидность данных в передаваемых массивах не проверяется
; ============================================================================================
Func _DateDiff_2($Old, $New, $iArray = 1)
	If Not IsArray($Old) Or UBound($Old) < 6 Then SetError(1, 0, '')
	If Not IsArray($New) Or UBound($New) < 6 Then SetError(2, 0, '')
	Local $Extended = 0
	For $i = 0 To 5
		If $Old[$i] <> $New[$i] Then
			If $Old[$i] < $New[$i] Then
				$d = __DateDiff_2($Old, $New)
			Else
				$d = __DateDiff_2($New, $Old)
				$Extended = 1
			EndIf
			ExitLoop
		EndIf
	Next

	If $iArray Then
		Return SetError(0, $Extended, $d)
	Else
		Return SetError(0, $Extended, StringFormat('%d.%02d.%02d %02d:%02d:%02d', $d[0], $d[1], $d[2], $d[3], $d[4], $d[5]))
	EndIf
EndFunc

Func __DateDiff_2($Old, $New)
	Local $i, $L, $t
	$t = 0
	Dim $L[6] = [5, 12, 0, 24, 60, 60]
	For $i = 5 To 1 Step -1
		If $i = 2 Then
			Switch $Old[1]
				Case 1, 3, 5, 7, 8, 10, 12
					$L[$i] = 31
				Case 2
					If _DateIsLeapYear($Old[0]) Then
						$L[$i] = 29
					Else
						$L[$i] = 28
					EndIf
				Case Else
					$L[$i] = 30
			EndSwitch
		EndIf
		If $New[$i] - $t < $Old[$i] Then
			$t = 1
			$Old[$i] = $New[$i] + $L[$i] - $t - $Old[$i]
		Else
			$Old[$i] = $New[$i] - $t - $Old[$i]
			$t = 0
		EndIf
	Next

	$Old[0] = $New[0] - $Old[0] - $t
	Return $Old
EndFunc