Const $ICQMOD_DLL = 'Plugin\ICQ.dll'

Const $PROXY_TYPE_SOCKS_4 = 1
Const $PROXY_TYPE_SOCKS_5 = 2

Const $AUTH_OK = 1
Const $AUTH_NO = 0

Const $ICQ_CONNECT_STATUS_OK = 0xFFFFFFFF
Const $ICQ_CONNECT_STATUS_RECV_ERROR = 0xFFFFFFFE
Const $ICQ_CONNECT_STATUS_SEND_ERROR = 0xFFFFFFFD
Const $ICQ_CONNECT_STATUS_CONNECT_ERROR = 0xFFFFFFFC
Const $ICQ_CONNECT_STATUS_AUTH_ERROR = 0xFFFFFFFB

Const $ICQ_CLIENT_STATUS_CONNECTED = 1
Const $ICQ_CLIENT_STATUS_DISCONNECTED = 2

Const $stICQ_CLIENT = DllStructCreate("byte status;ushort sequence;ulong sock")
$stPROXY_INFO = 0

Func ICQConnect($server,$login,$password,$proxy,$proxytype=2)
	if String($proxy) <> '0' Then
		$proxy = StringSplit($proxy,":",2)
		$stPROXY_INFO = DllStructCreate("ulong ProxyType;ulong ProxyIp;ushort ProxyPort")
		DllStructSetData($stPROXY_INFO, "ProxyType", $proxytype)
		DllStructSetData($stPROXY_INFO, "ProxyIp", $proxy[0])
		DllStructSetData($stPROXY_INFO, "ProxyPort", Int($proxy[1]))
	EndIf
	$srv = StringRegExp($server,"(.*):(.*)",3)
	if not @error Then
		$server = $srv[0]
		$port = $srv[1]
	Else
		Return 0
	EndIf
	$aRet = DllCall($ICQMOD_DLL, "dword", "ICQConnect", "ptr", DllStructGetPtr($stICQ_CLIENT), "str", $server, "word", $port, "str", $login, "str", $password, "ptr", $stPROXY_INFO)
	if $aRet[0] = $ICQ_CONNECT_STATUS_OK Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc

Func ICQSendMsg($to,$msg)
	DllCall($ICQMOD_DLL, "dword", "ICQSendMsg", "ptr", DllStructGetPtr($stICQ_CLIENT), "str", String($to), "str", $msg)
EndFunc

Func ICQAuth($who,$auth)
	DllCall($ICQMOD_DLL, "dword", "ICQAuth", "ptr", DllStructGetPtr($stICQ_CLIENT), "str", String($who), "str", $auth)
EndFunc

Func ICQAskAuth($who,$msg)
	DllCall($ICQMOD_DLL, "dword", "ICQSendAuth", "ptr", DllStructGetPtr($stICQ_CLIENT), "str", String($who), "str", $msg)
EndFunc

Func ICQClose()
	DllCall($ICQMOD_DLL, "dword", "ICQClose", "ptr", DllStructGetPtr($stICQ_CLIENT))
EndFunc

Func ICQReadMsg()
	$Call = DllCall($ICQMOD_DLL, "dword", "ICQReadMsg", "ptr", DllStructGetPtr($stICQ_CLIENT), "str", "UIN", "str", "msg", "int", "msglen")
	if $Call[0]=0 Then
		Return 0
	Else
		Local $a[2]
		$a[0] = $Call[2]
		$a[1] = $Call[3]
		Return $a
	EndIf
EndFunc