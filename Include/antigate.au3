If Not @Compiled Then Opt('TrayIconDebug', 1)

HttpSetUserAgent('Antigate.com DEMO')

Global $_HTTPLastSocket = -1
Global $_HTTPRecvTimeout = 5000
TCPStartup()

Global $captcha_id = 0, $debug = 0 ;~ :42f9f7d34ded94d6d52bd23a6e51a3f1 - Виталя



Func AntiCaptcha($file,$key)
    If Not FileExists($file) Then
        MsgBox(16, 'No CAPTCHA file', $file)
        Return 'No CAPTCHA file'
    EndIf

    Local $data[10]
    $data[0] = "method=base64"
    $data[1] = "key=" & $key
    $data[2] = "ext=jpg" ; JPG, GIF или PNG

    ; НЕОБЯЗАТЕЛЬНЫЕ ПОЛЯ
    $data[3] = "phrase=0";soft_id=500" ; капча состоит из 2х и более слов. (0 по умолчанию, 1 помечает что у капчи 2-4 слова)
    $data[4] = "regsense=0" ; чувствительна к регистру. (0 по умолчанию, 1 помечает что текст капчи чувствителен к регистру)
    $data[5] = "numeric=1" ; цифровая капча. (0 по умолчанию, 1 помечает что текст капчи состоит только из цифр, 2 помечает что на капче нет цифр)
    $data[6] = "calc=0" ; сложить цифры на капче. (0 по умолчанию, 1 помечает что цифры на капче должны быть сплюсованы)
    $data[7] = "min_len=2" ; минимальная длина. 0..20 (0 по-умолчанию, помечает минимальную длину текста капчи)
	$data[8] = "max_len=2"
    $data[9] = "is_russian=1" ; отправить капчу русскоговорящему работнику. (0 по умолчанию, 1 помечает что вводить нужно только русский текст, 2 - русский или английский)


    Local $host = 'antigate.com'
    Local $page = '/in.php'

    While $captcha_id = 0
        _HTTPConnect($host)
        If @error Then ContinueLoop

        Do
            _HTTP_Post_CAPTCHA($host, $page, $data, $file)
        Until Not @error
$STime=TimerInit()
        While 1
            $captcha_id = _HTTP_Read_CAPTCHA_ID() ; Сперва получаем ID в ответ
            If @extended = 1 Then ; Если еще не готово, то ждем
                ContinueLoop
            ElseIf @error = 1 Or @error = 2 Then    ; Что-то с соединением
                ExitLoop
            ElseIf @error > 2 Then ; Если проблема посерьезнее, то закругляемся
                Return SetError(@error, 0, $captcha_id)
			ElseIf TimerDiff($STime) > 30000 Then
				ExitLoop
				ConsoleWrite('Time Out')
            Else
                ExitLoop
            EndIf
        WEnd

        _HTTPClose()
    WEnd

    TrayTip('ID: ' & $captcha_id, 'Капча послана на распознавание', 3)
    Sleep(5000) ; Спим 10 сек: 5 сейчас сразу, 5 еще в начале цикла каждый раз при запросе резалта

    $page = '/res.php?key=' & $key &'&'& $data[5]&'&'& $data[7]&'&'& $data[8]&'&'& $data[9]& '&action=get&id=' & $captcha_id
    $url = 'http://' & $host & $page

    $captcha_text = 0
    While $captcha_text = 0 Or StringInStr($captcha_text, 'CAPCHA_NOT_READY') Or StringInStr($captcha_text, 'ERROR_NO_SLOT_AVAILABLE')
        Sleep(5000)
        While 1
            $resp = InetRead($url, 1 + 2 + 16)
            If @error Then
                TrayTip('ID: ' & $captcha_id, 'Не удалось скачать резалт, жду 1 сек.', 3, 2)
                Sleep(1000) ; Не удалось скачать резалт, спим
            Else
                ExitLoop
            EndIf
        WEnd

        $data = BinaryToString($resp, 4) ; UTF8

        If Not @Compiled Or $debug = 1 Then FileWriteLine(@ScriptDir & '\response.txt', @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & '-' & @MIN & '-' & @SEC & @CRLF & 'ID:' & $captcha_id & ' > DATA:' & $data & @CRLF & @CRLF)

        $captcha_text = _GetInfo($data)
        $err = @error
        $ext = @extended
        If $err = 0 Then
            ExitLoop
        ElseIf @extended = 1 Then ; Если надо просто повторить попытку
            ContinueLoop
        ElseIf @error > 2 Then  ; Нужно разбираться с проблемой
            TrayTip($captcha_text, $data, 5, 2)
            ;Sleep(3000)
            Return SetError($err, $ext, $captcha_text)
        EndIf
    WEnd

    Return SetError($err, $ext, $captcha_text)

EndFunc   ;==>AntiCaptcha

Func _HTTP_Read_CAPTCHA_ID($socket = -1)
    #cs ----------------------------------------------------------------------------
        Errors:
        1 - соедиене закыто сервером
        2 - таймаут получения данных

        Returns:
        id капчи
        0 - в случае ошибки
    #ce ----------------------------------------------------------------------------
    Local $recv
    Local $data

    Local $end_data_flag = @CRLF & '0' & @CRLF

    If $socket == -1 Then
        If $_HTTPLastSocket == -1 Then
            SetError(1)
            Return 0
        EndIf
        $socket = $_HTTPLastSocket
    EndIf

    Local $timer = TimerInit()

    While 1
        Sleep(10)
        $recv = TCPRecv($socket, 16)
        If @error == 0 Then
            If $recv <> "" Then
                $timer = TimerInit()
                $data &= $recv
            EndIf

            If StringInStr($data, $end_data_flag) Then ExitLoop

            If TimerDiff($timer) > $_HTTPRecvTimeout Then Return SetError(2, 0, 0)
		Else
			For $i=1 To 10
            Return SetError(1, 0, 0)
			Next
			ExitLoop
        EndIf
    WEnd

    If Not @Compiled Or $debug = 1 Then FileWriteLine(@ScriptDir & '\response.txt', '========================================' & @CRLF & @YEAR & '-' & @MON & '-' & @MDAY & '_' & @HOUR & '-' & @MIN & '-' & @SEC & @CRLF & $data)

    $info = _GetInfo($data)
    $err = @error
    If @extended = 1 Then ; Если надо просто повторить попытку
        Return SetError(1, 1, $info)
    ElseIf @error = 1 Or @error = 2 Then    ; Что-то с соединением
        Return SetError($err, 0, $info)
    ElseIf @error > 2 Then
        TrayTip($info, $data, 5, 2)
        ;Sleep(3000)
        Return SetError($err, 0, $info)
		$captcha_text='error'
    EndIf

    Return SetError(0, 0, $info)

EndFunc   ;==>_HTTP_Read_CAPTCHA_ID

Func _GetInfo($sStr)
    Local $ERROR_KEY_DOES_NOT_EXIST = 'ERROR_KEY_DOES_NOT_EXIST' ; вы использовали неверный ключ в запросе
    Local $ERROR_NO_SLOT_AVAILABLE = 'ERROR_NO_SLOT_AVAILABLE' ; все работники в данный момент заняты, попробуйте позже
    Local $ERROR_ZERO_CAPTCHA_FILESIZE = 'ERROR_ZERO_CAPTCHA_FILESIZE' ; размер капчи которую вы закачиваете (либо указываете через url) равен нулю
    Local $ERROR_TOO_BIG_CAPTCHA_FILESIZE = 'ERROR_TOO_BIG_CAPTCHA_FILESIZE' ; ваша капча превышает лимит в 30 кб
    Local $ERROR_WRONG_FILE_EXTENSION = 'ERROR_WRONG_FILE_EXTENSION' ; расширение вашей капчи неверное, разрешены только форматы gif, jpg, png
    Local $ERROR_IP_NOT_ALLOWED = 'ERROR_IP_NOT_ALLOWED' ; Пожалуйста смотрите раздел управления доступом по IP здесь: http://antigate.com/panel.php?action=iplist
    Local $ERROR_IMAGE_IS_NOT_JPEG = 'ERROR_IMAGE_IS_NOT_JPEG' ; Не JPEG
    Local $ERROR_IMAGE_IS_NOT_GIF = 'ERROR_IMAGE_IS_NOT_GIF' ; Не GIF
    Local $ERROR_IMAGE_IS_NOT_PNG = 'ERROR_IMAGE_IS_NOT_PNG' ; Не PNG
    Local $ERROR_WRONG_ID_FORMAT = 'ERROR_WRONG_ID_FORMAT' ; Кривой ID
    Local $CAPCHA_NOT_READY = 'CAPCHA_NOT_READY' ; Ждем 5 сек
    Local $ERROR_NO_SUCH_CAPCHA_ID = 'ERROR_NO_SUCH_CAPCHA_ID' ; Нет такой капчи
    Local $ERROR_WRONG_USER_KEY = 'ERROR_WRONG_USER_KEY' ; Нет такой капчи
	Local $ERROR_ZERO_BALANCE='ERROR_ZERO_BALANCE' ; Закончились деньги

    Local $aSplit = StringSplit($sStr, @CRLF, 1)

    For $i = 1 To $aSplit[0]
        If StringLeft($aSplit[$i], 3) = 'OK|' Then Return SetError(0, 0, StringTrimLeft($aSplit[$i], 3)) ; OK|123456 - капча принята к разгадыванию, ее ID идет за вертикальной чертой. Либо при повторном запросе здесь уже будет распознанный текст.
        If StringInStr($aSplit[$i], $ERROR_KEY_DOES_NOT_EXIST) Then Return SetError(9, 0, $ERROR_KEY_DOES_NOT_EXIST) ; Критическая ошибка
        If StringInStr($aSplit[$i], $ERROR_NO_SLOT_AVAILABLE) Then Return SetError(1, 0, $ERROR_NO_SLOT_AVAILABLE) ; Надо повторить снова!
        If StringInStr($aSplit[$i], $ERROR_ZERO_CAPTCHA_FILESIZE) Then Return SetError(5, 0, $ERROR_ZERO_CAPTCHA_FILESIZE)
        If StringInStr($aSplit[$i], $ERROR_TOO_BIG_CAPTCHA_FILESIZE) Then Return SetError(5, 0, $ERROR_TOO_BIG_CAPTCHA_FILESIZE)
        If StringInStr($aSplit[$i], $ERROR_WRONG_FILE_EXTENSION) Then Return SetError(5, 0, $ERROR_WRONG_FILE_EXTENSION)
        If StringInStr($aSplit[$i], $ERROR_IP_NOT_ALLOWED) Then Return SetError(9, 0, $ERROR_IP_NOT_ALLOWED) ; Критическая ошибка
        If StringInStr($aSplit[$i], $ERROR_IMAGE_IS_NOT_JPEG) Then Return SetError(5, 0, $ERROR_IMAGE_IS_NOT_JPEG)
        If StringInStr($aSplit[$i], $ERROR_IMAGE_IS_NOT_GIF) Then Return SetError(5, 0, $ERROR_IMAGE_IS_NOT_GIF)
        If StringInStr($aSplit[$i], $ERROR_IMAGE_IS_NOT_PNG) Then Return SetError(5, 0, $ERROR_IMAGE_IS_NOT_PNG)
        If StringInStr($aSplit[$i], $ERROR_WRONG_ID_FORMAT) Then Return SetError(9, 0, $ERROR_WRONG_ID_FORMAT) ; Критическая ошибка
        If StringInStr($aSplit[$i], $CAPCHA_NOT_READY) Then Return SetError(1, 1, $CAPCHA_NOT_READY) ; Надо повторить снова!
        If StringInStr($aSplit[$i], $ERROR_NO_SUCH_CAPCHA_ID) Then Return SetError(9, 0, $ERROR_NO_SUCH_CAPCHA_ID) ; Критическая ошибка
        If StringInStr($aSplit[$i], $ERROR_WRONG_USER_KEY) Then Return SetError(9, 0, $ERROR_WRONG_USER_KEY) ; Критическая ошибка
		 If StringInStr($aSplit[$i], $ERROR_ZERO_BALANCE) Then Return SetError(9, 0, $ERROR_ZERO_BALANCE) ; Критическая ошибка
    Next

    Return SetError(6, 0, $sStr)
EndFunc   ;==>_GetInfo

Func _HTTP_Post_CAPTCHA($host, $page, $data, $sFilename, $socket = -1)
    ; ===================================================================
    ; _HTTP_Post_CAPTCHA($host, $page, [$socket], [$data], [$sFilename])
    ;
    ; Executes a POST request on an open socket.
    ; Parameters:
    ;   $host - IN - The hostname you want to get the page from. This should be in the format "www.google.com" or "localhost"
    ;   $page - IN - The the file you want to get. This should always start with a slash. Examples: "/" or "/somedirectory/submitform.php"
    ;   $socket - OPTIONAL IN - The socket opened by _HTTPConnect. If this is not supplied, the last socket opened with _HTTPConnect will be used.
    ;   $data - array of data to send in the post request. This should first be run through _HTTPEncodeString()
    ;   $sFilename - path for file to send
    ; Returns:
    ;   The number of bytes sent in the request.
    ; Author: Val Polyakh <scriptguru@gmail.com>
    ; Requires: Base64.au3
    ; Remarks:
    ;   Possible @errors:
    ;   1 - No socket supplied and no current socket exists
    ;   2 - Error sending to socket. Check @extended for Windows API WSAGetError return
    ; ===================================================================

    Local $b = "---------------------------0123456789012"
    Local $fh, $image, $str, $picdata, $fieldname, $arr, $header
    Local $command

    If $socket == -1 Then
        If $_HTTPLastSocket == -1 Then
            SetError(1)
            Return
        EndIf
        $socket = $_HTTPLastSocket
    EndIf

    $command = ""

    For $i = 0 To (UBound($data) - 1)
        $arr = StringSplit($data[$i], "=", 2)
        $command &= "--" & $b & @CRLF & "Content-Disposition: form-data; name=" & $arr[0] & @CRLF & @CRLF & $arr[1] & @CRLF

    Next

    $fh = FileOpen($sFilename, 16)
    $image = FileRead($fh)
    FileClose($fh)
    $str = _Base64Encode($image)
    $command &= "--" & $b _
             & @CRLF & "Content-Disposition: form-data; name=body" & @CRLF & @CRLF _
             & $str & @CRLF


    $command &= @CRLF & "--" & $b & "--" & @CRLF

    Dim $datasize = StringLen($command)
    $header = "POST http://" & $host & $page & " HTTP/1.1" & @CRLF
    $header &= "Host: " & $host & @CRLF
    $header &= "Content-Type: multipart/form-data; boundary=" & $b & @CRLF
    $header &= "Content-Length: " & $datasize & @CRLF
    $header &= "" & @CRLF

    $command = $header & $command

    Dim $bytessent = TCPSend($socket, $command)

    If $bytessent == 0 Then
        SetExtended(@error)
        SetError(2)
        Return 0
    EndIf

    SetError(0)
    Return $bytessent

EndFunc   ;==>_HTTP_Post_CAPTCHA

Func _HTTPConnect($host, $port = 80)
    ; ===================================================================
    ; _HTTPConnect($host, [$port])
    ;
    ; Opens a connection to $host on the port you supply (or 80 if you don't supply a port. Returns the socket of the connection.
    ; Parameters:
    ;    $host - IN - The hostname you want to connect to. This should be in the format "www.google.com" or "localhost"
    ;    $port - OPTIONAL IN - The port to connect on. 80 is default.
    ; Returns:
    ;    The socket of the connection.
    ; Remarks:
    ;   Possible @errors:
    ;   1 - Unable to open socket - @extended is set to Windows API WSAGetLasterror return
    ; ===================================================================

    Dim $ip = TCPNameToIP($host)
    Dim $socket = TCPConnect($ip, $port)

    If ($socket == -1) Then
        SetError(1, @error)
        Return -1
    EndIf

    $_HTTPLastSocket = $socket
    SetError(0)
    Return $socket
EndFunc   ;==>_HTTPConnect

Func _HTTPClose($socket = -1)
    ; Possible @errors:
    ; 1 - No socket

    If $socket == -1 Then
        If $_HTTPLastSocket == -1 Then
            SetError(1)
            Return 0
        EndIf
        $socket = $_HTTPLastSocket
    EndIf
    TCPCloseSocket($socket)

    SetError(0)
    Return 1
EndFunc   ;==>_HTTPClose

Func _Base64Decode($data)
    Local $Opcode = "0xC81000005356578365F800E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFF00FFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132338F45F08B7D0C8B5D0831D2E9910000008365FC00837DFC047D548A034384C0750383EA033C3D75094A803B3D75014AB00084C0751A837DFC047D0D8B75FCC64435F400FF45FCEBED6A018F45F8EB1F3C2B72193C7A77150FB6F083EE2B0375F08A068B75FC884435F4FF45FCEBA68D75F4668B06C0E002C0EC0408E08807668B4601C0E004C0EC0208E08847018A4602C0E00624C00A46038847028D7F038D5203837DF8000F8465FFFFFF89D05F5E5BC9C21000"

    Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]")
    DllStructSetData($CodeBuffer, 1, $Opcode)

    Local $Ouput = DllStructCreate("byte[" & BinaryLen($data) & "]")
    Local $Ret = DllCall("user32.dll", "int", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer), _
            "str", $data, _
            "ptr", DllStructGetPtr($Ouput), _
            "int", 0, _
            "int", 0)

    Return BinaryMid(DllStructGetData($Ouput, 1), 1, $Ret[0])
EndFunc   ;==>_Base64Decode

Func _Base64Encode($data, $LineBreak = 76)
    Local $Opcode = "0x5589E5FF7514535657E8410000004142434445464748494A4B4C4D4E4F505152535455565758595A6162636465666768696A6B6C6D6E6F707172737475767778797A303132333435363738392B2F005A8B5D088B7D108B4D0CE98F0000000FB633C1EE0201D68A06880731C083F901760C0FB6430125F0000000C1E8040FB63383E603C1E60409C601D68A0688470183F90176210FB6430225C0000000C1E8060FB6730183E60FC1E60209C601D68A06884702EB04C647023D83F90276100FB6730283E63F01D68A06884703EB04C647033D8D5B038D7F0483E903836DFC04750C8B45148945FC66B80D0A66AB85C90F8F69FFFFFFC607005F5E5BC9C21000"

    Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]")
    DllStructSetData($CodeBuffer, 1, $Opcode)

    $data = Binary($data)
    Local $Input = DllStructCreate("byte[" & BinaryLen($data) & "]")
    DllStructSetData($Input, 1, $data)

    $LineBreak = Floor($LineBreak / 4) * 4
    Local $OputputSize = Ceiling(BinaryLen($data) * 4 / 3)
    $OputputSize = $OputputSize + Ceiling($OputputSize / $LineBreak) * 2 + 4

    Local $Ouput = DllStructCreate("char[" & $OputputSize & "]")
    DllCall("user32.dll", "none", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer), _
            "ptr", DllStructGetPtr($Input), _
            "int", BinaryLen($data), _
            "ptr", DllStructGetPtr($Ouput), _
            "uint", $LineBreak)
    Return DllStructGetData($Ouput, 1)
EndFunc   ;==>_Base64Encode

