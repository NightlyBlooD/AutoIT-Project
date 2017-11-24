#NoTrayIcon
#region Include start
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
#include <String.au3>
#include <IE.au3>
#include <File.au3>
#include <Update.au3>
#include <Date.au3>
#include <GDIPlus.au3>
#include <antigate.au3>
#include <Array.au3>
#include <NotifyBox.au3>
#include  <Crypt.au3>
#include <AboutBox.au3>
#region Include  end

Opt("TrayAutoPause", 0)
Opt("GUIOnEventMode", 1)

#region Global
$StartStatus = 0
Const $HeightForm = @DesktopHeight*0.60
Const $WidthForm = @DesktopWidth*0.35
Global $ConfigFiles = ""
#region Global end

$GUI = GUICreate("War and Mage bot",$WidthForm,$HeightForm,100,100)
GUISetOnEvent($GUI_EVENT_CLOSE, "CloseWin")
$CloseWinButton = GUICtrlCreateButton("",-1,-1,0,0)
GUICtrlSetOnEvent($CloseWinButton, "CloseWin")
$Tab1 = GUICtrlCreateTab($WidthForm *0.61, 0, $WidthForm , 20)
$TabSheet1 = GUICtrlCreateTabItem("Основной")
$OpenConfigFilesButtom = GUICtrlCreateButton("Config",$WidthForm*0.02, $HeightForm * 0.21, $WidthForm * 0.3,$HeightForm * 0.065)
GUICtrlSetOnEvent($OpenConfigFilesButtom, "OpenConfigFiles")
$StartButton = GUICtrlCreateButton("Старт", $WidthForm*0.02, $HeightForm * 0.91, $WidthForm * 0.3,$HeightForm * 0.065)
GUICtrlSetOnEvent($StartButton, "StartClick")
$oIE = ObjCreate("Shell.Explorer.2")
$WIE = GUICtrlCreateObj($oIE,  $WidthForm*0.35, $HeightForm * 0.05, $WidthForm*0.64, $HeightForm*0.99)
_IENavigate($oIE,"http://magegame.ru/index.php")

$TabSheet2 = GUICtrlCreateTabItem("Мульты")
$oIE2 = ObjCreate("Shell.Explorer.2")
$WIE2 = GUICtrlCreateObj($oIE2,$WidthForm*0.01, $HeightForm * 0.05, $WidthForm*0.5, $HeightForm*0.99)
;~ _IENavigate($oIE2,"http://magegame.ru/index.php")
$oIE3 = ObjCreate("Shell.Explorer.2")
$WIE3 = GUICtrlCreateObj($oIE3,$WidthForm*0.51, $HeightForm * 0.05, $WidthForm*0.5, $HeightForm*0.99)
;~ _IENavigate($oIE3,"http://magegame.ru/index.php")
$TabSheet3 = GUICtrlCreateTabItem("Настройки")
GUISetState(@SW_SHOW, $GUI)

Func CloseWin()
	Exit
EndFunc

While 1
WEnd

Func OpenConfigFiles()
Local $var = FileOpenDialog("", @ScriptDir& "\", "Config (*.conf)")
if not @error Then
	$ConfigFiles = $var
EndIf
ConsoleWrite($ConfigFiles)
EndFunc

Func StartClick()
	if $StartStatus == 0 Then
		GUICtrlSetData($StartButton, "Остановить")
		$StartStatus = 1
		Autorization($oIE,"NightlyBlooD2","ghbdfn")


	Else
		GUICtrlSetData($StartButton, "Старт")
		$StartStatus = 0
	EndIf
EndFunc

Func Autorization($IE,$login,$mypass)
	local  $LogFile = FileOpen(@ScriptDir & '\log\' & @MDAY & '-' & @MON & '-' & @YEAR & ' (' & @HOUR & '-' & @MIN & '-' & @SEC & ')' & ".lcn", 9)
	FileWrite($LogFile, _IEDocReadHTML($IE))
	local $atnihack = StringRegExp(_IEBodyReadHTML($IE), '(?i)value\=(\S+)\sname=antihack', 3)
	if not @error then
;~ 	local $HexPass = StringRegExp(_StringToHex($mypass), '(\S{2})', 3)
;~ 	$pass = ""
;~ 	For $i = 0 to UBound($HexPass) - 1
;~ 		$pass = $pass &"%"&$HexPass[$i]
;~ 	Next
	if _IEPropertyGet($IE,"locationurl") == "http://magegame.ru/index.php" Or _IEPropertyGet($IE,"locationurl") == "http://magegame.ru/?" Then
;~ 	_IENavigate($IE,"http://magegame.ru/ru_join.php?&mynick="&$login&"&mysecure=main&crypt_pass=%3F%E5%E4%8E%10%3B&js=1&antihack="&$atnihack[0],0)
Test($oIE)
	EndIf
;~ ConsoleWrite($pass)
EndIf
EndFunc

Func Test($IE)
	Local $JS = ""
	$JS &= ' document.enter.what.value="join";'&@CRLF

 $JS &= ' document.enter2.nick.value="NightlyBlooD"'&@CRLF
 $JS &= ' ocument.enter2.pass.value="ghbdfn"'&@CRLF
 $JS &= ' document.enter2.submit()" '
 $IE.document.parentWindow.execScript($JS)
EndFunc