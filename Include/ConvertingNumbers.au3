#include <BigNum.au3> ; http://www.autoitscript.com/forum/topic/83529-bignum-udf/

; ============================================================================================
; Function Name ...: _NumToDec
; Description ........: Converts a number into a decimal
; Syntax.......: _NumToDec($num, $sSymbol)
; Parameters:
;		$num - number
;		$sSymbol - A set of symbols defining the sequence
;		$casesense - (0,1,2) corresponds to flag StringInStr
; Return values: Success - Returns a decimal number, @extended - the number of characters in the discharge
;					Failure - Returns $num, and sets @error:
;                  |1 - $sSymbol contains less than 2 characters
;                  |2 - The symbol is not found in the character set
; Author(s) ..........: AZJIO
; Remarks ..........: For the 16 - Dec
; ============================================================================================
; Имя функции ...: _NumToDec
; Описание ........: Конвертирует указанное число в десятичное
; Синтаксис.......: _NumToDec($num, $sSymbol[, $casesense = 0])
; Параметры:
;		$num - число
;		$sSymbol - Набор символов определяющих последовательность для каждого разряда
;		$casesense - Регистро-зависимость (0,1,2), соответствует флагам StringInStr
; Возвращаемое значение: Успешно - Возвращает десятичное число, @extended определяет предыдущее количество символов в разряде
;					Неудачно - Возвращает число переданное в параметре $num и устанавливает @error:
;                  |1 - $sSymbol содержит менее 2 символов
;                  |2 - Символ числа не найден в наборе символов
; Автор ..........: AZJIO
; Примечания ..: Не используйте функцию для конвертирования из 16 - ричных чисел, для этого есть Dec
; ============================================================================================
Func _NumToDec($num, $sSymbol, $casesense = 0)
	Local $i, $iPos, $Len, $n, $Out
	$Len = StringLen($sSymbol)
	If $Len < 2 Then Return SetError(1, 0, $num)
	
	$n = StringSplit($num, '')
	For $i = 1 To $n[0]
		$iPos = StringInStr($sSymbol, $n[$i], $casesense)
		If Not $iPos Then Return SetError(2, 0, $num)
		$Out = _BigNum_Add(_BigNum_Mul($iPos - 1, _BigNum_Pow($Len, $n[0] - $i)), $Out)
	Next
	Return SetError(0, $Len, $Out)
EndFunc

; ============================================================================================
; Function Name ...: _DecToNum
; Description ........: Converts a number from the decimal system to the specified
; Syntax.......: _DecToNum ( $iDec, $Symbol )
; Parameters:
;		$iDec - decimal number
;		$Symbol - A set of symbols defining the sequence
; Return values: Success - Returns the new number, @extended - the number of characters in the discharge
;					Failure - Returns $iDec, @error = 1
; Author(s) ..........: AZJIO
; Remarks ..........: For the 16, 8 - Hex, StringFormat
; ============================================================================================
; Имя функции ...: _DecToNum
; Описание ........: Конвертирует десятичное число в указанное
; Синтаксис.......: _DecToNum ( $iDec, $Symbol )
; Параметры:
;		$iDec - десятичное число
;		$Symbol - Набор символов определяющих последовательность в разряде
; Возвращаемое значение: Успешно - Возвращает число в новой разрядности, @extended определяет количество символов в разряде
;					Неудачно - Возвращает число переданное в параметре $iDec устанавливает @error равным 1
; Автор ..........: AZJIO
; Примечания ..: Не используйте функцию для конвертирования в 16, 8 - ричные числа, для этого есть Hex, StringFormat
; ============================================================================================
Func _DecToNum($iDec, $Symbol)
	Local $Out, $ost
	$Symbol = StringSplit($Symbol, '')
	If @error Or $Symbol[0] < 2 Then Return SetError(1, 0, $iDec)
	Do
		$ost = _BigNum_Mod($iDec, $Symbol[0])
		$iDec = _BigNum_Div(_BigNum_Sub($iDec, $ost), $Symbol[0])
		$Out = $Symbol[$ost + 1] & $Out
	Until Not Number($iDec)
	Return SetError(0, $Symbol[0], $Out)
EndFunc

; ============================================================================================
; Function Name ...: _DecToRoman
; Description ........: Convert decimal to Roman
; Syntax.......: _DecToRoman ( $iDec )
; Parameters:
;		$iDec - decimal number from 0 to 3999 (Adding thousands adds character "M")
; Return values: Success - Returns the string
;					Failure - Returns -1 (Number outside the specified range), @error - 1, 2
; Author(s) ..........: AZJIO, заимствовано здесь http://forum.algolist.ru/algorithm-maths-mathematical/663-rimskie-chisla.html
; Remarks ..........: If 0, the empty string
; ============================================================================================
; Имя функции ...: _DecToRoman
; Описание ........: Преобразует десятичное число в римское
; Синтаксис.......: _DecToRoman ( $iDec )
; Параметры:
;		$iDec - десятичное число от 0 до 3999 (Добавление тысяч добавляет символ "M")
; Возвращаемое значение: Успешно - Возвращает строку
;					Неудачно - Возвращает -1 (число вне указанного диапазона) и устанавливает @error 
; Автор ..........: AZJIO, Credits http://forum.algolist.ru/algorithm-maths-mathematical/663-rimskie-chisla.html
; Примечания ..: Если 0, то пустая строка
; ============================================================================================
Func _DecToRoman($iDec)
	$iDec = Int($iDec) ; берём целую часть числа
	If $iDec < 1 Then
		If $iDec < 0 Then Return SetError(1, 0, -1)
		Return SetError(0, 0, '')
	EndIf
	If $iDec > 3999 Then Return SetError(2, 0, -1) ; если огромное число
	Local $r[13] = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I']
	Local $n[13] = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	Local $sRim = ''
	
	For $i = 0 To 12
		While $iDec >= $n[$i]
			$iDec -= $n[$i]
			$sRim &= $r[$i]
		WEnd
	Next
	Return $sRim
EndFunc   ;==>_DecToRoman

; ============================================================================================
; Function Name ...: _RomanToDec
; Description ........: Converts Roman numbers to decimal
; Syntax.......: _RomanToDec ( $sRoman )
; Parameters:
;		$sRoman - Roman number
; Return values: Success - Returns decimal number
;					Failure - Returns -1, @error = -1, if the number doesn't correspond to a format
; Author(s) ..........: AZJIO, http://forum.algolist.ru/algorithm-maths-mathematical/663-rimskie-chisla.html
; Remarks ..........: Verify that number, i.e. not only the use but also the order of the characters. Only the canonical written, i.e. 99 is written as XCIX, not IC. If characters in lower case then @extended = 1
; ============================================================================================
; Имя функции ...: _RomanToDec
; Описание ........: Преобразует римские числа в десятичные
; Синтаксис.......: _RomanToDec ( $sRoman )
; Параметры:
;		$sRoman - римское число
; Возвращаемое значение: Успешно - Возвращает десятичное число
;					Неудачно - Возвращает -1, @error = -1, если число не соответствует формату
; Автор ..........: AZJIO, http://forum.algolist.ru/algorithm-maths-mathematical/663-rimskie-chisla.html
; Примечания ..: Прверяется правильность числа, т.е. не только использование символов но и порядок. Только каноническое написание, то есть 99 пишется как XCIX, а не IC. Если символы в нижнем регистре то @extended = 1
; ============================================================================================
Func _RomanToDec($sRoman)
	Local $extended = 0
	If Not StringIsUpper($sRoman) Then $extended = 1
	If StringRegExp($sRoman, '(?i)([VLD])\1') Or StringRegExp($sRoman, '(?i)([IVXLCDM])\1\1\1') Then Return SetError(-1, $extended, -1)
	Local $c[7] = ['C', 'C', 'X', 'X', 'I', 'I', ''], _
	$d[7] = [100, 100, 10, 10, 1, 1, 0], _
	$r[7] = ['M', 'D', 'C', 'L', 'X', 'V', 'I'], _
	$n[7] = [1000, 500, 100, 50, 10, 5, 1], _
	$iDec = 0
	
	For $i = 0 To 6
		$aTmp = StringRegExp($sRoman, '^(' & $r[$i] & '+' & $c[$i] & $r[$i] & '|' & $r[$i] & '+|' & $c[$i] & $r[$i] & ')(.*?)$', 3)
		If Not @error Then
			$iDec += StringLen($aTmp[0]) * $n[$i]
			If StringInStr($aTmp[0], $c[$i]) Then $iDec -= $d[$i] + $n[$i]
			$sRoman = $aTmp[1]
			If Not $sRoman Then ExitLoop
		EndIf
	Next
	If $sRoman Then Return SetError(-1, $extended, -1)
	Return $iDec
EndFunc   ;==>_RomanToDec

; ============================================================================================
; Function Name ...: _NumberNumToName
; AutoIt Version ....: 3.2.12.1+
; Description ........: Converts a number to text consisting of words
; Syntax................: _NumberNumToName($iNum, $iRusLng = 0)
; Parameters:
;		$iNumber - любое целое число от 0 до 9223372036854775806
;		$iRusLng - (0, 1) language settings
;                  |0 - in English (Default)
;                  |1 - in Russian
; Return values ....: Success - Returns a string
;					Failure - empty string, @error = 1, if the string contains no numbers
; Author(s) ..........: AZJIO, G.Sandler (CreatoR) (transformation and modernization of the VBS-script found in Google)
; link ..................: http://forum.oszone.net/post-1900913.html#post1900913 discussion and adding CreatoR'om English language support
; ============================================================================================
; Имя функции ...: _NumberNumToName
; Описание ........: Преобразует число в запись прописью
; Синтаксис.......: _NumberNumToName($iNum, $iRusLng = 0)
; Параметры:
;		$iNumber - любое целое число от 0 до 9223372036854775806
;		$iRusLng - (0, 1) языковые установки
;                  |0 - на английском языке (по умолчанию)
;                  |1 - на русском языке
; Возвращаемое значение: Успешно - число прописью
;					Неудачно - пустая строка, @error = 1, если строка содержит не цифры
; Автор ..........: AZJIO, G.Sandler (CreatoR), преобразование и модернизация VBS-скрипта, найденного в Google
; Ссылка ..........: http://forum.oszone.net/post-1900913.html#post1900913 обсуждение и добавление CreatoR'ом поддержки английского языка
; ============================================================================================
Func _NumberNumToName($iNum, $iRusLng = 0)
	Local $aN, $aNum, $c, $i, $j, $n, $r, $sText

	$iNum = StringStripWS($iNum, 8) ; удаляем пробелы

	If $iNum = '0' Then
		If $iRusLng Then Return 'Ноль'
		Return 'Zero'
	EndIf

	$iNum = Int($iNum) ; берём целую часть числа
	If Not StringIsDigit($iNum) Or $iNum > 9223372036854775806 Or $iNum = 0 Then Return SetError(1, 0, '') ; если не цифры или огромное число, то вылет

	$iNum = StringRegExpReplace($iNum, '(\A\d{1,3}(?=(\d{3})+\z)|\d{3}(?=\d))', '\1 ') ; dwerf
	$aNum = StringSplit($iNum, ' ')

	If $iRusLng Then
		Dim $a[4][10] = _
				[ _
				[' десять', ' одиннадцать', ' двенадцать', ' тринадцать', ' четырнадцать', ' пятнадцать', ' шестнадцать', ' семнадцать', ' восемнадцать', ' девятнадцать'], _
				['', ' сто', ' двести', ' триста', ' четыреста', ' пятьсот', ' шестьсот', ' семьсот', ' восемьсот', ' девятьсот'], _
				['', '', ' двадцать', ' тридцать', ' сорок', ' пятьдесят', ' шестьдесят', ' семьдесят', ' восемьдесят', ' девяносто'], _
				['', '', '', ' три', ' четыре', ' пять', ' шесть', ' семь', ' восемь', ' девять'] _
				]

		Dim $aBitNum[7] = ['', ' тысяч', ' миллион', ' миллиард', ' триллион', ' квадриллион', ' квинтиллион']
	Else
		Dim $a[4][10] = _
				[ _
				[' ten', ' eleven', ' twelve', ' thirteen', ' fourteen', ' fifteen', ' sixteen', ' seventeen', ' eighteen', ' nineteen'], _
				['', 'hundred', ' two hundred', ' three hundred', ' four hundred', ' five hundred', ' six hundred', ' seven hundred', ' eight hundred', ' nine hundred'], _
				['', '', ' twenty', ' thirty', ' forty', ' fifty', ' sixty', ' seventy', ' eighty', ' ninety'], _
				['', '', '', ' three', ' four', ' five', ' six', ' seven', ' eight', ' nine'] _
				]

		Dim $aBitNum[7] = ['', ' thousand', ' million', ' billion', ' trillion', ' quadrillion', ' quintillion']
	EndIf

	$aNum[1] = StringFormat('%03s', $aNum[1]) ; дополняем нулями недостающие разряды
	$sText = ''

	For $i = 1 To $aNum[0]
		If $aNum[$i] = '000' Then ContinueLoop

		$aN = StringSplit($aNum[$i], '')
		$r = $aNum[0] - $i

		For $j = 1 To $aN[0]
			$n = Number($aN[$j])
			If Not $n Then ContinueLoop

			$c = $j

			Switch $j
				Case 3
					Switch $n ; для чисел 1 или 2
						Case 1
							If $iRusLng Then
								If $r = 1 Then ; разряд единиц (не десятков и сотен)
									$sText &= " одна"
								Else
									$sText &= " один"
								EndIf
							Else
								$sText &= " one"
							EndIf
						Case 2
							If $iRusLng Then
								If $r = 1 Then
									$sText &= " две"
								Else
									$sText &= " два"
								EndIf
							Else
								$sText &= " two"
							EndIf
					EndSwitch
				Case 2 ; для чисел от 10 до 19
					If $n = 1 Then
						$c = 0
						$n = Number($aN[3])
						$aN[3] = 0
					EndIf
			EndSwitch

			$sText &= $a[$c][$n] ; присоединения числа из массива
		Next

		$sText &= $aBitNum[$r]

		Switch $n ; окончания для раряда кратного 1000, при $j=3 в конце цикла
			Case 1
				If $r = 1 And $iRusLng Then ; одна тысяч<а>
					$sText &= "а"
				EndIf
			Case 2, 3, 4
				If $r = 1 Then ; 2,3,4 тысяч<и>
					If $iRusLng Then
						$sText &= "и"
					Else
						$sText &= "s"
					EndIf
				ElseIf $r > 1 Then ; 2,3,4 милион<а>
					If $iRusLng Then
						$sText &= "а"
					Else
						$sText &= "s"
					EndIf
				EndIf
			Case Else
				If $r > 1 Then ; 5-9 милион<ов>
					If $iRusLng Then
						$sText &= "ов"
					Else
						$sText &= "s"
					EndIf
				EndIf
		EndSwitch
	Next

	Return StringStripWS($sText, 3)
EndFunc