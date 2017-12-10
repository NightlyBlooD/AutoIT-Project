; @AZJIO
Func _MusicBeep($aNote, $iRepeat = 1, $nTempo = 1, $iTone = 0)
	For $r = 1 To $iRepeat
		For $i = 0 To UBound($aNote) - 1
			$iFrequency = 440 * 2 ^ (($aNote[$i][0] + $iTone) / 12 + $aNote[$i][1] + 1 / 6 - 4)
			Beep($iFrequency, $aNote[$i][2] / $nTempo)
			If $aNote[$i][3] Then Sleep($aNote[$i][3] / $nTempo)
		Next
	Next
EndFunc

Func _StrToArr4($N)
	$N = StringSplit($N, '|')
	If @error And $N[1] = '' Then SetError(1)
	Dim $a[$N[0]][4]
	For $i = 0 To $N[0] - 1
		$tmp = StringSplit($N[$i + 1], ',')
		If @error Or $tmp[0] <> 4 Then
			SetError(1)
			ContinueLoop
		EndIf
		$a[$i][0] = $tmp[1]
		$a[$i][1] = $tmp[2]
		$a[$i][2] = $tmp[3]
		$a[$i][3] = $tmp[4]
	Next
	Return $a
EndFunc