; http://www.autoitscript.com/forum/topic/133224-filesearch-foldersearch/
; http://pastebin.com/AbzMyg1x
; http://azjio.ucoz.ru/publ/skripty_autoit3/funkcii/filesearch/11-1-0-33

; версия 1.0 от 2012.02.14

; _FileSearch
; _CorrectMask
; _FolderSearch

; Внутренние функции
; __FileSearchType
; __FileSearchMask
; __FileSearchAll
; __GetListMask
; __MaskUnique (#Obfuscator_Off и #Obfuscator_On)
; __FolderSearch
; __FolderSearchMask

; ============================================================================================
; Function Name ...: _FileSearch (__FileSearchType, __FileSearchMask, __FileSearchAll)
; AutoIt Version ....: 3.3.2.0+ , versions below this @extended should be replaced by of StringInStr(FileGetAttrib($sPath&'\'&$file), "D")
; Description ........: Search files by mask in subdirectories.
; Syntax................: _FileSearch($sPath[, $sMask = '*' [, $fInclude=True [, $iDepth=125 [, $iFull=1 [, $iArray=1 [, $iTypeMask=1]]]]]])
; Parameters:
;		$sPath - search path
;		$sMask - allowed two options for the mask: using symbols "*" and "?" with the separator "|", or a list of extensions with the separator "|"
;		$fInclude - (True / False) invert the mask, that is excluded from the search for these types of files
;		$iDepth - (0-125) nesting level (0 - root directory)
;		$iFull - (0,1,2,3)
;                  |0 - relative
;                  |1 - full path
;                  |2 - file names with extension
;                  |3 - file names without extension
;		$iArray - if the value other than zero, the result is an array (by default ),
;                  |0 - a list of paths separated by @CRLF
;                  |1 - array, where $iArray[0]=number of files ( by default)
;                  |2 - array, where $iArray[0] contains the first file
;		$iTypeMask - (0,1,2) defines the format mask
;                  |0 - auto detect
;                  |1 - forced mask, for example *.is?|s*.cp* (it is possible to specify a file name with no characters * or ? and no extension will be found)
;                  |2 - forced mask, for example tmp|bak|gid (that is, only files with the specified extension)
; Return values ....: Success - Array ($iArray[0]=number of files) or a list of paths separated by @CRLF
;					Failure - empty string, @error:
;                  |0 - no error
;                  |1 - Invalid path
;                  |2 - Invalid mask
;                  |3 - not found
; Author(s) ..........: AZJIO
; Remarks ..........: Use function _CorrectMask if it is required correct mask, which is entered by user
; ============================================================================================
; Имя функции ...: _FileSearch (__FileSearchType, __FileSearchMask, __FileSearchAll)
; Версия AutoIt ..: 3.3.2.0+ , в версиях ниже указанной нужно @extended заменить на StringInStr(FileGetAttrib($sPath&'\'&$file), "D")
; Описание ........: Поиск файлов по маске в подкаталогах.
; Синтаксис.......: _FileSearch($sPath[, $sMask = '*' [, $fInclude=True [, $iDepth=125 [, $iFull=1 [, $iArray=1 [, $iTypeMask=1]]]]]])
; Параметры:
;		$sPath - путь поиска
;		$sMask - допустимы два варианта маски: с использованием символов "*" и "?" с перечислением через "|", либо перечисление расширений через "|"
;		$fInclude - (True / False) инвертировать маску, то есть исключить из поиска указанные типы файлов
;		$iDepth - (0-125) уровень вложенности (0 - корневой каталог)
;		$iFull - (0,1,2,3)
;                  |0 - относительный
;                  |1 - полный путь
;                  |2 - имена файлов с расширением
;                  |3 - имена файлов без расширения
;		$iArray - (0,1,2) определяет вывод результата, массив или список
;                  |0 - список с разделителем @CRLF
;                  |1 -  массив, в котором $iArray[0]=количество файлов (по умолчанию)
;                  |2 -  массив, в котором $iArray[0] содержит первый файл
;		$iTypeMask - (0,1,2) определяет формат записи маски
;                  |0 - автоопределение
;                  |1 - принудительно маска вида *.is?|s*.cp* (то есть можно указать имя файла без символов * или ? и без расширения и будет найдено)
;                  |2 - принудительно маска вида tmp|bak|gid (по расширению, то есть только имена файлов с указанным расширением)
; Возвращаемое значение: Успешно - Массив ($iArray[0]=количество файлов) или список с разделителем @CRLF
;					Неудачно - пустая строка, @error:
;                  |0 - нет ошибок
;                  |1 - неверный путь
;                  |2 - неверная маска
;                  |3 - ничего не найдено
; Автор ..........: AZJIO
; Примечания ..: Используйте функцию _CorrectMask, если маска считывается из поля ввода и требуется проверка на корректность
; ============================================================================================
; функция проверки и подготовки входных параметров и обработка результирующего списка
Func _FileSearch($sPath, $sMask = '*', $fInclude = True, $iDepth = 125, $iFull = 1, $iArray = 1, $iTypeMask = 1)
	Local $FileList
	If $sMask = '|' Then Return SetError(2, 0, '')
	; If Not StringRegExp($sPath, '(?i)^[a-z]:[^/:*?"<>|]*$') Or StringInStr($sPath, '\\') Then Return SetError(1, 0, '')
	If Not FileExists($sPath) Then Return SetError(1, 0, '')
	If StringRight($sPath, 1) <> '\' Then $sPath &= '\'

	If $sMask = '*' Or $sMask = '' Then
		$FileList = StringTrimRight(__FileSearchAll($sPath, $iDepth), 2)
	Else
		Switch $iTypeMask
			Case 0
				If StringInStr($sMask, '*') Or StringInStr($sMask, '?') Or StringInStr($sMask, '.') Then
					__GetListMask($sPath, $sMask, $fInclude, $iDepth, $FileList)
				Else
					$FileList = StringTrimRight(__FileSearchType($sPath, '|' & $sMask & '|', $fInclude, $iDepth), 2)
				EndIf
			Case 1
				__GetListMask($sPath, $sMask, $fInclude, $iDepth, $FileList)
			Case Else
				If StringInStr($sMask, '*') Or StringInStr($sMask, '?') Or StringInStr($sMask, '.') Then Return SetError(2, 0, '')
				$FileList = StringTrimRight(__FileSearchType($sPath, '|' & $sMask & '|', $fInclude, $iDepth), 2)
		EndSwitch
	EndIf
	
	If Not $FileList Then Return SetError(3, 0, '')
	Switch $iFull
		Case 0
			$FileList = StringRegExpReplace($FileList, '(?m)^(?:.{' & StringLen($sPath) & '})(.*)$', '\1')
		Case 2
			$FileList = StringRegExpReplace($FileList, '(?m)^(?:.*\\)(.*)$', '\1')
		Case 3
			$FileList = StringRegExpReplace($FileList, '(?m)^(?:.*\\)([^\\]*?)(?:\.[^.]+)?$', '\1' & @CR)
			$FileList = StringTrimRight($FileList, 1)
	EndSwitch
	Switch $iArray
		Case 1
			$FileList = StringSplit($FileList, @CRLF, 1)
			; If @error And $FileList[1] = '' Then Dim $FileList[1] = [0]
		Case 2
			$FileList = StringSplit($FileList, @CRLF, 3)
			; If @error And $FileList[0]='' Then SetError(3, 0, '')
	EndSwitch
	Return $FileList
EndFunc   ;==>_FileSearch

; Получение списка и обработка регулярным выражением
Func __GetListMask($sPath, $sMask, $fInclude, $iDepth, ByRef $FileList)
	Local $aFileList, $i
	$FileList = StringTrimRight(__FileSearchMask($sPath, $iDepth), 2)
	$sMask = StringReplace(StringReplace(StringRegExpReplace($sMask, '[][$^.{}()+]', '\\$0'), '?', '.'), '*', '.*?')
	If $fInclude Then
		$aFileList = StringRegExp($FileList, '(?mi)^(.+\|(?:' & $sMask & '))(?:\r|\z)', 3)
		$FileList = ''
		For $i = 0 To UBound($aFileList) - 1
			$FileList &= $aFileList[$i] & @CRLF
		Next
	Else
		$FileList = StringRegExpReplace($FileList & @CRLF, '(?mi)^.+\|(' & $sMask & ')\r\n', '')
	EndIf
	$FileList = StringReplace(StringTrimRight($FileList, 2), '|', '')
EndFunc   ;==>__GetListMask

; поиск указанных типов файлов
Func __FileSearchType($sPath, $sMask, $fInclude, $iDepth, $LD = 0)
	Local $tmp, $FileList = '', $file, $s = FileFindFirstFile($sPath & '*')
	If $s = -1 Then Return ''
	While 1
		$file = FileFindNextFile($s)
		If @error Then ExitLoop
		If @extended Then
			If $LD >= $iDepth Then ContinueLoop
			$FileList &= __FileSearchType($sPath & $file & '\', $sMask, $fInclude, $iDepth, $LD + 1)
		Else
			$tmp = StringInStr($file, ".", 0, -1)
			If $tmp And StringInStr($sMask, '|' & StringTrimLeft($file, $tmp) & '|') = $fInclude Then
				$FileList &= $sPath & $file & @CRLF
			ElseIf Not $tmp And Not $fInclude Then
				$FileList &= $sPath & $file & @CRLF
			EndIf
		EndIf
	WEnd
	FileClose($s)
	Return $FileList
EndFunc   ;==>__FileSearchType

; поиск файлов по маске
Func __FileSearchMask($sPath, $iDepth, $LD = 0)
	Local $FileList = '', $file, $s = FileFindFirstFile($sPath & '*')
	If $s = -1 Then Return ''
	While 1
		$file = FileFindNextFile($s)
		If @error Then ExitLoop
		If @extended Then
			If $LD >= $iDepth Then ContinueLoop
			$FileList &= __FileSearchMask($sPath & $file & '\', $iDepth, $LD + 1)
		Else
			$FileList &= $sPath & '|' & $file & @CRLF
		EndIf
	WEnd
	FileClose($s)
	Return $FileList
EndFunc   ;==>__FileSearchMask

; поиск всех файлов
Func __FileSearchAll($sPath, $iDepth, $LD = 0)
	Local $FileList = '', $file, $s = FileFindFirstFile($sPath & '*')
	If $s = -1 Then Return ''
	While 1
		$file = FileFindNextFile($s)
		If @error Then ExitLoop
		If @extended Then
			If $LD >= $iDepth Then ContinueLoop
			$FileList &= __FileSearchAll($sPath & $file & '\', $iDepth, $LD + 1)
		Else
			$FileList &= $sPath & $file & @CRLF
		EndIf
	WEnd
	FileClose($s)
	Return $FileList
EndFunc   ;==>__FileSearchAll


; ============================================================================================
; Function Name ...: _CorrectMask (__MaskUnique)
; AutoIt Version ....: 3.3.0.0+
; Description ........: Corrects a mask
; Syntax................: _CorrectMask($sMask)
; Parameters........: $sMask - except symbol possible in names are allowed symbols of the substitution "*" and "?" and separator "|"
; Return values:
;					|Success -  Returns a string of a correct mask
;					|Failure - Returns a symbol "|" and @error=2
; Author(s) ..........: AZJIO
; Remarks ..........: Function corrects possible errors entered by the user
; ============================================================================================
; Имя функции ...: _CorrectMask (__MaskUnique)
; Версия AutoIt ..: 3.3.0.0+
; Описание ........: Корректировка маски
; Синтаксис.......: _CorrectMask($sMask)
; Параметры.....: $sMask - кроме символов допустимых в именах допускаются символы подстановки "*" и "?" и разделитель "|"
; Возвращаемое значение:
;					|Успешно -  Возвращает строку корректной маски
;					|Неудачно - Возвращает символ "|" и @error=2
; Автор ..........: AZJIO
; Примечания ..: Функция исправляет возможные ошибки ввода пользователем:
; удаляет пробелы и точки на конце каждого элемента маски, удаляет повторы звёздочки и разделителя.
; ============================================================================================
; корректировка маски
Func _CorrectMask($sMask)
	If StringRegExp($sMask, '[\\/:"<>]') Then Return SetError(2, 0, '|')
	If StringInStr($sMask, '**') Then $sMask = StringRegExpReplace($sMask, '\*+', '*')
	If StringRegExp($sMask&'|', '[\s|.]\|') Then $sMask = StringRegExpReplace($sMask&'|', '[\s|.]+\|', '|')
	If StringInStr('|' & $sMask & '|', '|*|') Then Return '*'
	If $sMask = '|' Then Return SetError(2, 0, '|')
	If StringRight($sMask, 1) = '|' Then $sMask = StringTrimRight($sMask, 1)
	If StringLeft($sMask, 1) = '|' Then $sMask = StringTrimLeft($sMask, 1)
	__MaskUnique($sMask)
	Return $sMask
EndFunc

; удаление повторяющихся элементов маски
#Obfuscator_Off
Func __MaskUnique(ByRef $sMask)
	Local $t=StringReplace($sMask, '[', Chr(1)), $a=StringSplit($t, '|'), $k=0, $i
	Assign('/', '', 1)
	For $i = 1 To $a[0]
		If Not IsDeclared($a[$i]&'/') Then
			$k+=1
			$a[$k]=$a[$i]
		EndIf
		Assign($a[$i]&'/', '', 1)
	Next
	If $k<>$a[0] Then
		$sMask=''
		For $i = 1 to $k
			$sMask&=$a[$i]&'|'
		Next
		$sMask=StringReplace(StringTrimRight($sMask, 1), Chr(1), '[')
	EndIf
EndFunc
#Obfuscator_On

; поиск файлов по маске, обычная маска функции FileFindFirstFile
; Func __FileSearchMask_Old($sPath, $sMask, $iDepth)
	; Local $FileList = '', $file, $s, $aFolder
	; If $iDepth > 0 Then
		; $aFolder = StringSplit(StringTrimRight($sPath&@CRLF&__FolderSearch($sPath, '*', $iDepth), 2), @CRLF, 1)
	; Else
		; Dim $aFolder[2]=[1, $sPath]
	; EndIf
	; For $i = 1 To $aFolder[0]
		; $s = FileFindFirstFile($aFolder[$i] & $sMask)
		; If $s = -1 Then ContinueLoop
		; While 1
			; $file = FileFindNextFile($s)
			; If @error Then ExitLoop
			; If Not @extended Then
				; $FileList &= $aFolder[$i] & $file & @CRLF
			; EndIf
		; WEnd
		; FileClose($s)
	; Next
	; Return $FileList
; EndFunc




; ============================================================================================
; Function Name ...: _FolderSearch
; AutoIt Version ....: 3.3.2.0+ , versions below this @extended should be replaced by of StringInStr(FileGetAttrib($sPath&'\'&$file), "D")
; Description ........: Search folders on a mask in the subdirectories.
; Syntax................: _FolderSearch($sPath[, $sMask = '*' [, $fInclude=True [, $iDepth=0 [, $iFull=1 [, $iArray=1]]]]])
; Parameters:
;		$sPath - search path
;		$sMask - mask using the characters "*" and "?" with the separator "|"
;		$fInclude - (True / False) invert the mask, that is excluded from the search of folders
;		$iDepth - (0-125) nesting level (0 - root directory)
;		$iFull - (0,1)
;                  |0 - relative
;                  |1 - full path
;		$iArray - (0,1,2) if the value other than zero, the result is an array (by default ),
;                  |0 - a list of paths separated by @CRLF
;                  |1 - array, where $iArray[0]=number of folders ( by default)
;                  |2 - array, where $iArray[0] contains the first folder
; Return values ....: Success - Array ($iArray[0]=number of folders) or a list of paths separated by @CRLF
;					Failure - empty string, @error:
;                  |0 - no error
;                  |1 - Invalid path
;                  |2 - Invalid mask
;                  |3 - not found
; Author(s) ..........: AZJIO
; Remarks ..........: Use function _CorrectMask if it is required correct mask, which is entered by user
; ============================================================================================
; Имя функции ...: _FolderSearch (__FolderSearch)
; Версия AutoIt ..: 3.3.2.0+ , в версиях ниже указанной нужно @extended заменить на StringInStr(FileGetAttrib($sPath&'\'&$file), "D")
; Описание ........: Поиск папок по маске в подкаталогах.
; Синтаксис.......: _FolderSearch($sPath[, $sMask = '*' [, $fInclude=True [, $iDepth=0 [, $iFull=1 [, $iArray=1]]]]])
; Параметры:
;		$sPath - путь поиска
;		$sMask - маска с использованием символов "*" и "?" с перечислением через "|". По умолчанию все папки.
;		$fInclude - (True / False) инвертировать маску, то есть исключить из поиска указанные папки
;		$iDepth - (0-125) уровень вложенности (0 - корневой каталог)
;		$iFull - (0,1)
;                  |0 - относительный
;                  |1 - полный путь
;		$iArray - (0,1,2) определяет вывод результата, массив или список
;                  |0 - список с разделителем @CRLF
;                  |1 -  массив, в котором $iArray[0]=количество папок (по умолчанию)
;                  |2 -  массив, в котором $iArray[0] содержит первую папку
; Возвращаемое значение: Успешно - Массив ($iArray[0]=количество папок) или список с разделителем @CRLF
;					Неудачно - пустая строка, @error:
;                  |0 - нет ошибок
;                  |1 - неверный путь
;                  |2 - неверная маска
;                  |3 - ничего не найдено
; Автор ..........: AZJIO
; Примечания ..: Используйте функцию _CorrectMask, если маска считывается из поля ввода и требуется проверка на корректность
; ============================================================================================
; функция проверки и подготовки входных параметров и обработка результирующего списка
Func _FolderSearch($sPath, $sMask = '*', $fInclude = True, $iDepth = 0, $iFull = 1, $iArray = 1)
	Local $FolderList, $aFolderList, $i
	If $sMask = '|' Then Return SetError(2, 0, '')
	; If Not StringRegExp($sPath, '(?i)^[a-z]:[^/:*?"<>|]*$') Or StringInStr($sPath, '\\') Then Return SetError(1, 0, '')
	If Not FileExists($sPath) Then Return SetError(1, 0, '')
	If StringRight($sPath, 1) <> '\' Then $sPath &= '\'
	
	If $sMask = '*' Or $sMask = '' Then
		$FolderList = StringTrimRight(__FolderSearch($sPath, $iDepth), 2)
	Else
		$FolderList = StringTrimRight(__FolderSearchMask($sPath, $iDepth), 2)
		$sMask = StringReplace(StringReplace(StringRegExpReplace($sMask, '[][$^.{}()+]', '\\$0'), '?', '.'), '*', '.*?')
		If $fInclude Then
			$aFolderList = StringRegExp($FolderList, '(?mi)^(.+\|(?:' & $sMask & '))(?:\r|\z)', 3)
			$FolderList = ''
			For $i = 0 To UBound($aFolderList) - 1
				$FolderList &= $aFolderList[$i] & @CRLF
			Next
		Else
			$FolderList = StringRegExpReplace($FolderList & @CRLF, '(?mi)^.+\|(' & $sMask & ')\r\n', '')
		EndIf
		$FolderList = StringReplace(StringTrimRight($FolderList, 2), '|', '')
	EndIf
	If Not $FolderList Then Return SetError(3, 0, '')
	
	If $iFull = 0 Then $FolderList = StringRegExpReplace($FolderList, '(?m)^(?:.{' & StringLen($sPath) & '})(.*)$', '\1')
	Switch $iArray
		Case 1
			$FolderList = StringSplit($FolderList, @CRLF, 1)
			; If @error And $FolderList[1] = '' Then Dim $FolderList[1] = [0]
		Case 2
			$FolderList = StringSplit($FolderList, @CRLF, 3)
			; If @error And $FolderList[0]='' Then SetError(3, 0, '')
	EndSwitch
	Return $FolderList
EndFunc   ;==>_FolderSearch

; поиск папок по маске
Func __FolderSearchMask($sPath, $iDepth, $LD = 0)
	Local $FolderList = '', $file, $s = FileFindFirstFile($sPath & '*')
	If $s = -1 Then Return ''
	While 1
		$file = FileFindNextFile($s)
		If @error Then ExitLoop
		If @extended Then
			If $LD < $iDepth Then
				$FolderList &= $sPath & '|' & $file & @CRLF
				$FolderList &= __FolderSearchMask($sPath & $file & '\', $iDepth, $LD + 1)
			ElseIf $LD = $iDepth Then
				$FolderList &= $sPath & '|' & $file & @CRLF
			EndIf
		EndIf
	WEnd
	FileClose($s)
	Return $FolderList
EndFunc   ;==>__FolderSearchMask

; поиск всех папок
Func __FolderSearch($sPath, $iDepth, $LD = 0)
	Local $FolderList = '', $file, $s = FileFindFirstFile($sPath & '*')
	If $s = -1 Then Return ''
	While 1
		$file = FileFindNextFile($s)
		If @error Then ExitLoop
		If @extended Then
			If $LD < $iDepth Then
				$FolderList &= $sPath & $file & @CRLF
				$FolderList &= __FolderSearch($sPath & $file & '\', $iDepth, $LD + 1)
			ElseIf $LD = $iDepth Then
				$FolderList &= $sPath & $file & @CRLF
			EndIf
		EndIf
	WEnd
	FileClose($s)
	Return $FolderList
EndFunc   ;==>__FolderSearch