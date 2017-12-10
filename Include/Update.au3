#Include <Misc.au3>
#include <WindowsConstants.au3>

Global $g_hInet_Update, $g_CurrentVersion_Update, $g_SilentMode_Update
Global $g_TempFileInfo_Update = @TempDir & "\MyApp_Update.inf"

Func _StartCheckForUpdate($url,$cur_version,$silent_mode = True)
	$g_CurrentVersion_Update = $cur_version
	$g_SilentMode_Update = $silent_mode

	; ------ ������� ���� � ���������� ������, ������ ��� ��������� MyApp_Update.inf ----------
	If $g_SilentMode_Update <> True Then
		Local $host = StringRegExpReplace($url,".+?//(.+?)/.+","$1")
		If not Ping($host,1000) Then
			MsgBox(16,"������","�� ���� ������������ � �������!")
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

			; ---------------------- ��������� ���� "Update Version" --------------------
			Local $Last_Version = IniRead($g_TempFileInfo_Update,"Info","Update Version","")
			If $Last_Version = "" Then $error_in_section = True
			; ---------------------------------------------------------------------------

			; ---------------------- ��������� ���� "Update File" -----------------------
			Local $Update_File = IniRead($g_TempFileInfo_Update,"Info","Update File","")
			If $Update_File = "" Then $error_in_section = True
			; ---------------------------------------------------------------------------

			; ---------------------- ������� ��������� �� ������, ���� � �����-�� ����� ��������� ������ ---------------------------
			If $error_in_section Then
				If not $g_SilentMode_Update Then MsgBox(16,"������","������ � �����, ���������� ���������� � ����� ������ ���������!")
				Return
			EndIf
			; ----------------------------------------------------------------------------------------------------------------------

			; ------------------ ��������� ���� "Update Changes" -----------------------
			; --------------------- ���� ���� ������������ -----------------------------
			$Update_Changes = IniRead($g_TempFileInfo_Update,"Info","Update Changes","")
			; --------------------------------------------------------------------------

			FileDelete($g_TempFileInfo_Update)

			Local $CRLF = @CRLF

			Local $VersionCompare = _VersionCompare($g_CurrentVersion_Update,$Last_Version)
			If $VersionCompare = -1 Then
				; ------------ ��������� ���������, ������� ����� �������� ��� ����������� ����� ������ ---------------------
				Local $message_string = "�������� ����� ������ ���������: " & $Last_Version
				If $Update_Changes <> "" Then $message_string &= $CRLF & $CRLF & "��������� � ����� ������: " & $Update_Changes & $CRLF
				$message_string &= $CRLF & "������� ����� ������ ���������?"
				; -----------------------------------------------------------------------------------------------------------

				Local $msg_ret = MsgBox(68,"����������",$message_string)
				If $msg_ret = 6 Then
					_DownloadNewVerion($Update_File)
				Else
					return
				EndIf
			Elseif $VersionCompare = 0 Then
				If not $g_SilentMode_Update Then MsgBox(64,"����������","� ��� ����� ��������� ������!")
			EndIf
		Else
			If not $g_SilentMode_Update Then MsgBox(16,"������","���� � ����������� � ����� ������ ��������� �� �������� �� �������!")
		EndIf
	EndIf
EndFunc

; ������ ������� ��������� ����� ������ ���������, ��� ���� ��������� �������� ����������.
; �� ���������� ���������� ��������� ����������� � ����������� ����� ������ ���������.
Func _DownloadNewVerion($Update_File)
	Local $Form_DownloadNewVersion, $Progress_Downloaded

	#Region ### START Koda GUI section ### Form=H:\AutoIT 3.3.0.0\���������� ��� AutoIt\koda_1.7.2.8_b247_2010-04-15\Forms\Form_download.kxf
	$Form_DownloadNewVersion = GUICreate("���������� ����� ������...", 191, 26, -1, -1, -1, BitOR($WS_EX_TOOLWINDOW,$WS_EX_WINDOWEDGE))
	$Progress_Downloaded = GUICtrlCreateProgress(0, 0, 190, 25, 0)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	; ------- ������� ������. � ������ �������, ���������� ��������� ---------
	; ------- P.S. �� ���� ������ ������ ������� � ������, ���� ���� ��������, ----
	; ------- ��� ������ ��� ������������� InetGet ---------------------------
	Local $host = StringRegExpReplace($Update_File,".+?//(.+?)/.+","$1")
	If not Ping($host,1000) Then
		GUIDelete($Form_DownloadNewVersion)
		MsgBox(16,"������","�� ���� ������������ � ������� ��� ���������� ����� ������ ���������!")
		Return
	EndIf
	; -------------------------------------------------------------------------

	; ---- ������� ���������, ���� ����, ��������� � MyApp_Update.inf, �� �������� -----
	Local $FileSize = InetGetSize($Update_File,1)
	If @error Then
		GUIDelete($Form_DownloadNewVersion)
		MsgBox(16,"������","�� ������� �� ������ ���� � ����� ������� ���������!")
		Return
	EndIf
	; -----------------------------------------------------------------------------------

	; --------------------------------------- ��������� ����� ������ ��������� � ����� � ��������� --------------------------------
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
		; ���� ����� �������� ������� ��� ���������� �������� ����� �������
		Run(@ComSpec & ' /c ping -n 2 localhost>nul & Move /y "' & $FileInTempDir & '" "' & $FileInScriptDir & '" & Start "" "' & $FileInScriptDir & '"', '', @SW_HIDE)
	Else
		MsgBox(16,"������","�� ������� ������� ����� ������ ���������!" & @CRLF & "�������� ���������� ��������-����������!")
	EndIf
	;-------------------------------------------------------------------------------------------------------------------------------

	Exit
EndFunc
