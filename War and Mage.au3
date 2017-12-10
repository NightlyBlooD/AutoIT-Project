#NoTrayIcon
#region Include start
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
Const $HeightForm = @DesktopHeight*0.90
Const $WidthForm = @DesktopWidth*0.75
Global $ConfigFiles = ""
Global $start = False
#region Global end

$GUI = GUICreate("War and Mage bot",$WidthForm,$HeightForm,1,1)
GUISetOnEvent($GUI_EVENT_CLOSE, "CloseWin")
$CloseWinButton = GUICtrlCreateButton("",-1,-1,0,0)
GUICtrlSetOnEvent($CloseWinButton, "CloseWin")
$Tab1 = GUICtrlCreateTab($WidthForm *0.61, 0, $WidthForm , 20)
$TabSheet1 = GUICtrlCreateTabItem("Main")
$OpenConfigFilesButtom = GUICtrlCreateButton("Config",$WidthForm*0.02, $HeightForm * 0.21, $WidthForm * 0.15,$HeightForm * 0.065)
GUICtrlSetOnEvent($OpenConfigFilesButtom, "OpenConfigFiles")
$StartButton = GUICtrlCreateButton("Старт", $WidthForm*0.02, $HeightForm * 0.91, $WidthForm * 0.15,$HeightForm * 0.065)
GUICtrlSetOnEvent($StartButton, "StartClick")
$Combo = GUICtrlCreateCombo("",$WidthForm*0.02, $HeightForm * 0.6, $WidthForm * 0.15,$HeightForm * 0.04,BitOR($GUI_SS_DEFAULT_COMBO, $CBS_SIMPLE))
GUICtrlSetData($Combo,"navigate|script|other","navigate")
$INP = GUICtrlCreateInput("",$WidthForm*0.02, $HeightForm * 0.63, $WidthForm * 0.15,$HeightForm * 0.04)
$INP2 = GUICtrlCreateInput("",$WidthForm*0.02, $HeightForm * 0.67, $WidthForm * 0.15,$HeightForm * 0.04)
$StartButton2 = GUICtrlCreateButton("click", $WidthForm*0.02, $HeightForm * 0.71, $WidthForm * 0.15,$HeightForm * 0.065)
GUICtrlSetOnEvent($StartButton2, "Click")
$oIE = ObjCreate("Shell.Explorer.2")
$WIE = GUICtrlCreateObj($oIE,  $WidthForm*0.2, $HeightForm * 0.05, $WidthForm*0.79, $HeightForm*0.99)
_IENavigate($oIE,"http://magegame.ru/index.php")

$TabSheet2 = GUICtrlCreateTabItem("Twink's")
$oIE2 = ObjCreate("Shell.Explorer.2")
$WIE2 = GUICtrlCreateObj($oIE2,$WidthForm*0.01, $HeightForm * 0.05, $WidthForm*0.5, $HeightForm*0.99)
;~ _IENavigate($oIE2,"http://magegame.ru/index.php")
$oIE3 = ObjCreate("Shell.Explorer.2")
$WIE3 = GUICtrlCreateObj($oIE3,$WidthForm*0.51, $HeightForm * 0.05, $WidthForm*0.5, $HeightForm*0.99)
;~ _IENavigate($oIE3,"http://magegame.ru/index.php")
$TabSheet3 = GUICtrlCreateTabItem("Setttings")
GUISetState(@SW_SHOW, $GUI)
;~ $oIE.document.parentWindow.execScript('var s="21"')
;~ $s = $oIE.document.parentWindow.eval("s")
;~ ConsoleWrite($s)
Func CloseWin()
	Exit
EndFunc

While 1
WEnd

Func Circle()
	$oIE.document.parentWindow.execScript("var head = 'null';var f= document.getElementsByTagName('frame'); for (i=0; i<f.length; i++)	{ if (f[i].name == 'head')	{head = f[i].contentWindow.document.body.innerHTML;}}")
	local $string = $oIE.document.parentWindow.eval("head")
	local $SearchExitCombat = StringRegExp($string, '(?i)orm3\saction\=action\.php\?act\=(\S+)\>')
	local $SearchPodgotovka = StringRegExp($string, '(?i)onclick\=idpodgot\d\.checked\=true')
	local $SearchAttack=StringRegExp($string, '(?i)INPUT\sid=(\D+)\stype')
	if  $SearchExitCombat == 1 Then
		 $oIE.document.parentWindow.execScript(JavaScript("script", "Выйти из боя"))
	Elseif $SearchPodgotovka == 1 Then
		if $SearchAttack==1 Then
			 $oIE.document.parentWindow.execScript(JavaScript("script", "Подготовка"))
			 $oIE.document.parentWindow.execScript(JavaScript("script", "actkudar"))
			 $oIE.document.parentWindow.execScript(JavaScript("script", "sendform"))
		Else
			 $oIE.document.parentWindow.execScript(JavaScript("script", "Подготовка"))
			 $oIE.document.parentWindow.execScript(JavaScript("script", "actotdoxnut"))
			 $oIE.document.parentWindow.execScript(JavaScript("script", "sendform"))
		EndIf
	EndIf
;~ 	 $oIE.document.parentWindow.execScript('var head = window.parent.head.document.getElementsByName("form3")[0].innerHTML;')



ConsoleWrite($SearchExitCombat&@CRLF)
ConsoleWrite($SearchPodgotovka&@CRLF)
ConsoleWrite($SearchAttack&@CRLF)
EndFunc

Func Click()
if $start == False Then
	AdlibRegister("Circle",5000)
	$start = True
ElseIf $start == True Then
	AdlibUnRegister("Circle")
	$start = False
EndIf
;~  $oIE.document.parentWindow.execScript(JavaScript(GUICtrlRead($Combo),GUICtrlRead($INP)))
;~ ConsoleWrite(JavaScript(GUICtrlRead($Combo),GUICtrlRead($INP))&@CRLF)
;~ Local $string[10]

;~ 	ConsoleWrite("page"&@CRLF&$string&@CRLF)
;~ $string= $oIE.document.parentWindow.eval('document.getElementsByName("head")[0].innerHTML')
;~ $string[1] = $oIE.document.parentWindow.eval('window.parent.head.document.getElementsByName("form2")[0].innerHTML')
;~ $string[2] = $oIE.document.parentWindow.eval('window.parent.head.document.getElementsByName("form3")[0].innerHTML')
;~ $string[3] = $oIE.document.parentWindow.eval('window.parent.head.document.getElementsByName("form4")[0].innerHTML')
;~ $string[4] = $oIE.document.parentWindow.eval('window.parent.head.document.getElementsByName("form5")[0].innerHTML')
;~ $string[5] = $oIE.document.parentWindow.eval('window.parent.head.document.getElementsByName("form6")[0].innerHTML')
;~ ConsoleWrite($string[0]&@CRLF)
;~ ConsoleWrite($string[1]&@CRLF)
;~ ConsoleWrite($string[2]&@CRLF)
EndFunc



Func OpenConfigFiles()
Local $var = FileOpenDialog("", @ScriptDir& "\", "Config (*.conf)")
if not @error Then
	$ConfigFiles = $var
EndIf
ConsoleWrite($ConfigFiles)
EndFunc

Func StartClick()
	if $StartStatus == 0 Then
		GUICtrlSetData($StartButton, "Стоп")
		$StartStatus = 1
		Autorization($oIE,"NightlyBlooD","ghbdfn")


	Else
		GUICtrlSetData($StartButton, "Старт")
		$StartStatus = 0
	EndIf
EndFunc

Func Autorization($IE,$login,$mypass)
;~ 	local  $LogFile = FileOpen(@ScriptDir & '\log\' & @MDAY & '-' & @MON & '-' & @YEAR & ' (' & @HOUR & '-' & @MIN & '-' & @SEC & ')' & ".lcn", 9)
;~ 	FileWrite($LogFile, _IEDocReadHTML($IE))
	local $atnihack = StringRegExp(_IEBodyReadHTML($IE), '(?i)value\=(\S+)\sname=antihack', 3)
	if not @error then
;~ 	local $HexPass = StringRegExp(_StringToHex($mypass), '(\S{2})', 3)
;~ 	$pass = ""
;~ 	For $i = 0 to UBound($HexPass) - 1
;~ 		$pass = $pass &"%"&$HexPass[$i]
;~ 	Next
	if _IEPropertyGet($IE,"locationurl") == "http://magegame.ru/index.php" Or _IEPropertyGet($IE,"locationurl") == "http://magegame.ru/?" Then
	_IENavigate($IE,"http://magegame.ru/ru_join.php?&mynick="&$login&"&mysecure=main&crypt_pass=%3F%E5%E4%8E%10%3B&js=1&antihack="&$atnihack[0],0)
;~ Test($oIE)
	EndIf
;~ ConsoleWrite($pass)
EndIf
EndFunc




Func JavaScript($type, $param, $name=False)
	if $type == "navigate" Then
		if $param == "сражения" Then
			Return "window.parent.head.document.location.href='action.php?act=showzayavki'"
		ElseIf $param == "один на один" Then
			Return "window.parent.head.document.location.href='action.php?act=changetipboy&tipb=1'"
		EndIf
	ElseIf $type == "script" Then
		if $param == "Подать заявку" Then
			Return "var combatsearch = window.parent.head.document.getElementsByName('submit'); for (i=0; i<combatsearch.length; i++)	{ if (combatsearch[i].value == 'Подать заявку')		{combatsearch[i].click();}}"
		ElseIf $param == "Выйти из боя" Then
			Return "var combatleave = window.parent.head.document.getElementsByName('submit'); for (i=0; i<combatleave.length; i++)	{ if (combatleave[i].value == 'Выйти из боя')		{combatleave[i].click();}}"
		ElseIf $param == "Подготовка" Then
			Return "var podgotovka = window.parent.head.document.getElementById('idpodgot"&Round(Random(1,8))&"'); podgotovka.setAttribute('checked', 'checked');"
		ElseIf $param == "actkudar" Then
			Return "var actkudar = window.parent.head.document.getElementById('actkudar'); actkudar.setAttribute('checked', 'checked');"
		ElseIf $param == "actotdoxnut" Then
			Return "var actotdoxnut = window.parent.head.document.getElementById('actotdoxnut'); actotdoxnut.setAttribute('checked', 'checked');"
		ElseIf $param == "sendform" Then
			Return "window.parent.head.document.forms[0].submit();"
		ElseIf $param == "joincombat" Then
			Return "var inputs = window.parent.head.document.getElementsByTagName('input'); for (i=0; i<inputs.length; i++) {  if (inputs[i].getAttribute('name') == 'nickzayavka') {    if (inputs[i].getAttribute('value') == '"&$name&"') {inputs[i].setAttribute('checked', 'checked');}  }}  var combatsearch = window.parent.head.document.getElementsByName('submit'); for (i=0; i<combatsearch.length; i++)	{ if (combatsearch[i].value == 'Принять заявку')		{combatsearch[i].click();}}"
		EndIf
	EndIf
EndFunc

