#Include <Misc.au3>
#include <WindowsConstants.au3>

Global $g_hInet_Update, $g_CurrentVersion_Update, $g_SilentMode_Update
Global $g_TempFileInfo_Update = @TempDir & "\MyApp_Update.inf"

Func _StartCheckForUpdate($url,$cur_version,$silent_mode = True)
	$g_CurrentVersion_Update = $cur_version
	$g_SilentMode_Update = $silent_mode

	; ------ Пингуем хост в нормальном режиме, прежде чем скачивать MyApp_Update.inf ----------
	If $g_SilentMode_Update <> True Then
		Local $host = StringRegExpReplace($url,".+?//(.+?)/.+","$1")
		If not Ping($host,1000) Then
			MsgBox(16,"Ошибка","Не могу подключиться к серверу!")
			Return
		EndIf
	EndIf
	;-------------------------------------------------------------------------------------------

	$g_hInet_Update = InetGet($url,$g_TempFileInfo_Update,1,1)
	AdlibRegister("_CheckUpdate",20)
EndFunc

Func _CheckUpdate()
	If InetGetInfo($g_hInet_Update,2) Then
		AdlibUnRegister("_CheckUpdate")

		Local $DowloadSuccesfull = InetGetInfo($g_hInet_Update,3)
		InetClose($g_hInet_Update)

		If $DowloadSuccesfull Then

			Local $error_in_section = False

			; ---------------------- Проверяем ключ "Update Version" --------------------
			Local $Last_Version = IniRead($g_TempFileInfo_Update,"Info","Update Version","")
			If $Last_Version = "" Then $error_in_section = True
			; ---------------------------------------------------------------------------

			; ---------------------- Проверяем ключ "Update File" -----------------------
			Local $Update_File = IniRead($g_TempFileInfo_Update,"Info","Update File","")
			If $Update_File = "" Then $error_in_section = True
			; ---------------------------------------------------------------------------

			; ---------------------- Выводим сообщение об ошибке, если в какой-то ключе произошла ошибка ---------------------------
			If $error_in_section Then
				If not $g_SilentMode_Update Then MsgBox(16,"Ошибка","Ошибка в файле, содержащем информацию о новой версии программы!")
				Return
			EndIf
			; ----------------------------------------------------------------------------------------------------------------------

			; ------------------ Проверяем ключ "Update Changes" -----------------------
			; --------------------- Этот ключ необязателен -----------------------------
			$Update_Changes = IniRead($g_TempFileInfo_Update,"Info","Update Changes","")
			; --------------------------------------------------------------------------

			FileDelete($g_TempFileInfo_Update)

			Local $CRLF = @CRLF

			Local $VersionCompare = _VersionCompare($g_CurrentVersion_Update,$Last_Version)
			If $VersionCompare = -1 Then
				; ------------ Формируем сообщение, которое будет выведено при обнаружении новой версии ---------------------
				Local $message_string = "Доступна новая версия программы: " & $Last_Version
				If $Update_Changes <> "" Then $message_string &= $CRLF & $CRLF & "Изменения в новой версии: " & $Update_Changes & $CRLF
				$message_string &= $CRLF & "Скачать новую версию программы?"
				; -----------------------------------------------------------------------------------------------------------

				Local $msg_ret = MsgBox(68,"Информация",$message_string)
				If $msg_ret = 6 Then
					_DownloadNewVerion($Update_File)
				Else
					return
				EndIf
			Elseif $VersionCompare = 0 Then
				If not $g_SilentMode_Update Then MsgBox(64,"Информация","У вас самая последняя версия!")
			EndIf
		Else
			If not $g_SilentMode_Update Then MsgBox(16,"Ошибка","Файл с информацией о новой версии программы не доступен на сервере!")
		EndIf
	EndIf
EndFunc

; Данная Функция скачивает новую версию программы, при этом отображая прогресс скачивания.
; По завершении скачивания программа завершается и запускается новая версия программы.
Func _DownloadNewVerion($Update_File)
	Local $Form_DownloadNewVersion, $Progress_Downloaded

	#Region ### START Koda GUI section ### Form=H:\AutoIT 3.3.0.0\Инструметы для AutoIt\koda_1.7.2.8_b247_2010-04-15\Forms\Form_download.kxf
	$Form_DownloadNewVersion = GUICreate("Скачивание новой версии...", 191, 26, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE))
	$Progress_Downloaded = GUICtrlCreateProgress(0, 0, 190, 25, 0)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	; ------- Пингуем сервер. В случае неудачи, отображаем сообщение ---------
	; ------- P.S. На пинг уходит меньше времени в случае, если инет выключен, ----
	; ------- чем просто при использовании InetGet ---------------------------
	Local $host = StringRegExpReplace($Update_File,".+?//(.+?)/.+","$1")
	If not Ping($host,1000) Then
		GUIDelete($Form_DownloadNewVersion)
		MsgBox(16,"Ошибка","Не могу подключиться к серверу для скачивания новой версии программы!")
		Return
	EndIf
	; -------------------------------------------------------------------------

	; ---- Выводим сообщение, если файл, указанный в MyApp_Update.inf, не доступен -----
	Local $FileSize = InetGetSize($Update_File,1)
	If @error Then
		GUIDelete($Form_DownloadNewVersion)
		MsgBox(16,"Ошибка","На сервере не найден файл с новой версией программы!")
		Return
	EndIf
	; -----------------------------------------------------------------------------------

	; --------------------------------------- Скачиваем новую версию программы и затем её запускаем --------------------------------
	Local $FileName = StringRegExpReplace($Update_File,".+/(.+)","$1")
	Local $FileInTempDir = @TempDir & "\" & $FileName
	Local $FileInScriptDir = @ScriptDir & "\" & $FileName

	Local $hInet = InetGet($Update_File,$FileInTempDir,1,1)
	Do
		Sleep(20)
		GUICtrlSetData($Progress_Downloaded,InetGetInfo($hInet,0)/$FileSize*100)
	Until InetGetInfo($hInet,2)

	GUIDelete($Form_DownloadNewVersion)

	Local $DowloadSuccesfull = InetGetInfo($hInet,3)
	InetClose($hInet)

	If $DowloadSuccesfull Then
		; Сюда можно вставить функцию для сохранения настроек перед выходом
		Run(@ComSpec & ' /c ping -n 2 localhost>nul & Move /y "' & $FileInTempDir & '" "' & $FileInScriptDir & '" & Start "" "' & $FileInScriptDir & '"', '', @SW_HIDE)
	Else
		MsgBox(16,"Ошибка","Не удалось скачать новую версию программы!" & @CRLF & "Возможно оборвалось интернет-соединение!")
	EndIf
	;-------------------------------------------------------------------------------------------------------------------------------

	Exit
EndFunc
