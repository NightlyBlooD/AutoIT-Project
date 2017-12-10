#Region Header

#cs

    Title:          Management of Script Communications UDF Library for AutoIt3
    Filename:       Messages.au3
    Description:    Exchange of data between scripts
    Author:         Yashied
    Version:        1.1
    Requirements:   AutoIt v3.3 +, Developed/Tested on WindowsXP Pro Service Pack 2
    Uses:           None
    Notes:          This library based on the MessageHandler.au3
                    (http://www.autoitscript.com/forum/index.php?act=attach&type=post&id=22855)

    Available functions:

    _MsgReceiverList
    _MsgRegister
    _MsgRelease
    _MsgSend
    _MsgTimerInterval
    _MsgWindowHandle

    Additional features:

    _IsReceiver

    Example:

        #Include <EditConstants.au3>
        #Include <GUIConstantsEx.au3>
        #Include <GUIEdit.au3>
        #Include <GUISlider.au3>
        #Include <StaticConstants.au3>
        #Include <WindowsConstants.au3>
        #Include <Messages.au3>

        #NoTrayIcon

        If  Not @compiled Then
            MsgBox(64, 'Messages UDF Library Demonstration', 'To run this script, you must first compile it and then run the (.exe) file.')
            Exit
        EndIf

        Opt('MustDeclareVars', 1)

        If $CmdLine[0] = 0 Then
            ShellExecute(@ScriptFullPath, '1')
            ShellExecute(@ScriptFullPath, '2')
            ShellExecute(@ScriptFullPath, '3')
            Exit
        EndIf

        Global $Form, $Input1, $Input2, $Radio1, $Radio2, $Radio3, $ButtonSend, $Edit, $Slider, $Check

        Switch $CmdLine[1]
            Case '1', '2', '3'
                _Main(Int($CmdLine[1]))
            Case Else

        EndSwitch

        Func _Main($Index)

            Local $GUIMsg, $nScript, $Data, $Timer = _MsgTimerInterval(0)

            $Form = GUICreate('Script' & $Index, 324, 384, (@DesktopWidth - 1018) / 2 + ($Index - 1) * 344, (@DesktopHeight - 440) / 2, BitOR($WS_CAPTION, $WS_SYSMENU), $WS_EX_TOPMOST)

            GUISetFont(8.5, 400, 0, 'Tahoma', $Form)

            GUICtrlCreateLabel('Message:', 14, 22, 48, 14)
            $Input1 = GUICtrlCreateInput('', 64, 19, 246, 20)
            GUICtrlCreateLabel('Send to:', 14, 56, 48, 14)

            GUIStartGroup()

            $Radio1 = GUICtrlCreateRadio('Script1', 64, 56, 56, 14)
            GUICtrlSetState(-1, $GUI_CHECKED)
            $Radio2 = GUICtrlCreateRadio('Script2', 130, 56, 56, 14)
            $Radio3 = GUICtrlCreateRadio('Script3', 196, 56, 56, 14)

            $ButtonSend = GUICtrlCreateButton('Send', 236, 88, 75, 23)
            GUICtrlSetState(-1, $GUI_DEFBUTTON)
            GUICtrlCreateLabel('', 14, 128, 299, 2, $SS_ETCHEDHORZ)
            GUICtrlCreateLabel('Received message:', 14, 142, 98, 14)
            $Edit = GUICtrlCreateEdit('', 14, 160, 296, 129, BitOR($ES_READONLY, $WS_VSCROLL, $WS_HSCROLL))
            GUICtrlSetBkColor(-1, 0xFFFFFF)
            GUICtrlCreateLabel('Timer interval (ms):', 14, 316, 98, 14)
            $Slider = GUICtrlCreateSlider(110, 312, 162, 26, BitOR($TBS_AUTOTICKS, $WS_TABSTOP))
            GUICtrlSetLimit(-1, 20, 1)
            GUICtrlSetData(-1, $Timer / 50)
            _GUICtrlSlider_SetTicFreq(-1, 1)
            $Input2 = GUICtrlCreateInput($Timer, 274, 313, 36, 20, $ES_READONLY)
            GUICtrlSetBkColor(-1, 0xFFFFFF)
            $Check = GUICtrlCreateCheckbox('Enable receiver', 14, 354, 96, 19)
            GUICtrlSetState(-1, $GUI_CHECKED)

            Opt('GUICloseOnESC', 0)

            GUISetState()

            _MsgRegister('Script' & $Index, '_Receiver')

            While 1
                $GUIMsg = GUIGetMsg()
                Select
                    Case $GUIMsg = $GUI_EVENT_CLOSE
                        Exit
                    Case $GUIMsg = $ButtonSend
                        For $i = $Radio1 To $Radio3
                            If GUICtrlRead($i) = $GUI_CHECKED Then
                                $nScript = 1 + $i - $Radio1
                                ExitLoop
                            EndIf
                        Next
                        $Data = GUICtrlRead($Input1)
                        If StringStripWS($Data, 3) = '' Then
                            $Data = '(empty)'
                        EndIf
                        If _IsReceiver('Script' & $nScript) Then
                            _MsgSend('Script' & $nScript, 'From Script' & $Index & ':  ' & $Data)
                        EndIf
                    Case $GUIMsg = $Slider
                        _MsgTimerInterval($Timer)
                    Case $GUIMsg = $Check
                        If GUICtrlRead($Check) = $GUI_CHECKED Then
                            _MsgRegister('Script' & $Index, '_Receiver')
                            GUICtrlSetState($Edit, $GUI_ENABLE)
                            GUICtrlSetBkColor($Edit, 0xFFFFFF)
                            GUICtrlSetState($Slider, $GUI_ENABLE)
                            GUICtrlSetState($Input2, $GUI_ENABLE)
                        Else
                            _MsgRegister('Script' & $Index, '')
                            GUICtrlSetState($Edit, $GUI_DISABLE)
                            GUICtrlSetBkColor($Edit, $GUI_BKCOLOR_TRANSPARENT)
                            GUICtrlSetState($Slider, $GUI_DISABLE)
                            GUICtrlSetState($Input2, $GUI_DISABLE)
                        EndIf
                EndSelect
                $Data = GUICtrlRead($Slider) * 50
                If BitXOR($Data, $Timer) Then
                    GUICtrlSetData($Input2, $Timer)
                    $Timer = $Data
                EndIf
            WEnd
        EndFunc   ;==>_Main

        Func _Receiver($sMessage)
            _GUICtrlEdit_AppendText($Edit, $sMessage & @CRLF)
            Return 0
        EndFunc   ;==>_Receiver

#ce

#Include-once

#EndRegion Header

#Region Local Variables and Constants

Global Const $MSG_WM_COPYDATA = 0x004A

OnAutoItExitRegister('OnMessagesExit')

Global $wmInt = 0
Global $qeInt = 0

Dim $msgId[1][6] = [[0, 0, 100, DllCallbackRegister('_queue', 'none', ''), 0, 'lib10rsZd']]

#cs

DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$msgId[0][0]   - Count item of array
	  [0][1]   - Reserved
	  [0][2]   - Message timer interval, ms (see _MsgTimerInterval())
	  [0][3]   - Handle to callback function
	  [0][4]   - The control identifier as returned by "SetTimer" function (see _MsgRegister())
	  [0][5]   - Suffix of the title registered window (Don`t change it)

$msgId[i][0]   - The control identifier (controlID) as returned by _MsgRegister()
	  [i][1]   - Registered receiver ID name
	  [i][2]   - Registered user function
	  [i][3]   - Handle to registered window
	  [i][4-5] - Reserved

#ce

Dim $msgQueue[1][2] = [[0]]

#cs

DO NOT USE THIS ARRAY IN THE SCRIPT, INTERNAL USE ONLY!

$msgQueue[0][0] - Count item of array
	     [0][1] - Don`t used

$msgQueue[i][0] - Registered user function ($msgId[i][2])
	     [i][1] - Message data

#ce

#EndRegion Local Variables and Constants

#Region Public Functions

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgReceiverList
; Description:		Retrieves a list of receivers.
; Syntax:			_MsgReceiverList (  )
; Parameter(s):		None.
; Return Value(s):	Returns an array of matching receiver names that have been registered by a _MsgRegister() function.
;					The zeroth array element contains the number of receivers.
; Author(s):		Yashied
; Note(s):			Returned variable will always be an array and a dimension of not less than 1.
;====================================================================================================================================

Func _MsgReceiverList()

	Local $wList = WinList(), $Lenght = StringLen($msgId[0][5])

	Dim $rList[1] = [0]
	For $i = 1 To $wList[0][0]
		If StringRight($wList[$i][0], $Lenght) = $msgId[0][5] Then
			ReDim $rList[$rList[0] + 2]
			$rList[0] += 1
			$rList[$rList[0]] = StringTrimRight($wList[$i][0], $Lenght)
		EndIf
	Next
	Return $rList
EndFunc   ;==>_MsgReceiverList

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgRegister
; Description:		Creates a registers the specified function as a receiver.
; Syntax:			_MsgRegister ( $sIdentifier, $sFunction )
; Parameter(s):		$sIdentifier - Local identifier (any name) to be registered at the receive of messages. If the receiver with the
;								   specified identifier already exists in the system will be sets @error flag.
;					$sFunction   - The name of the function to call when a message is received. Not specifying this parameter
;								   will be removed the receiver associated with the $sIdentifier. The function cannot be a built-in AutoIt
;								   function or plug-in function and must have the following header:
;
;								   func _MyReceiver($sMessage)
;
;								   IMPORTANT! The function should return 0 for successful completion, otherwise the functions will be called
;								   again later, etc. until it is returned to zero. This is necessary to control access to shared data (if any).
;								   For this purpose you can use specifying additional control flags:
;
;								   Local $IntFlag = 0
;
;								   _MsgRegister('my_local_receiver_id_name', '_MyReceiver')
;
;								   ...
;
;								   $IntFlag = 1
;
;								   ; At this point, the _MyReceiver() is locked.
;
;								   $IntFlag = 0
;
;								   ...
;
;								   Func _MyReceiver($sMessage)
;									   If $IntFlag = 1 Then
;										   Return 1
;									   EndIf
;
;									   ...
;
;									   Return 0
;								   EndFunc; _MyReceiver
;
; Return Value(s):	Success: Returns the identifier (controlID) of the new registered receiver.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgRegister($sIdentifier, $sFunction)

	Local $ID, $Title
	Local $i, $j = 0, $k, $l, $b, $t

	If (Not IsString($sIdentifier)) Or (Not IsString($sFunction)) Or ($msgId[0][3] = 0) Or (StringStripWS($sIdentifier, 8) = '') Then
		Return SetError(1, 0, 0)
	EndIf

	$sFunction = StringStripWS($sFunction, 3)
	$t = StringLower($sIdentifier)
	For $i = 1 To $msgId[0][0]
		If StringLower($msgId[$i][1]) = $t Then
			$j = $i
			ExitLoop
		EndIf
	Next

	If $j = 0 Then
		$Title = $sIdentifier & $msgId[0][5]
		If ($sFunction = '') Or (IsHWnd(_winhandle($Title))) Then
			Return SetError(0, 0, 1)
		EndIf
		$ID = 1
		Do
			$b = 1
			For $i = 1 To $msgId[0][0]
				If $msgId[$i][0] = $ID Then
					$ID += 1
					$b = 0
					ExitLoop
				EndIf
			Next
		Until $b
		If $msgId[0][0] = 0 Then
			_start()
			If @error Then
				Return 0
			EndIf
		EndIf
		ReDim $msgId[$msgId[0][0] + 2][UBound($msgId, 2)]
		$msgId[$msgId[0][0] + 1][0] = $ID
		$msgId[$msgId[0][0] + 1][1] = $sIdentifier
		$msgId[$msgId[0][0] + 1][2] = $sFunction
		$msgId[$msgId[0][0] + 1][3] = GUICreate($Title)
		$msgId[$msgId[0][0] + 1][4] = 0
		$msgId[$msgId[0][0] + 1][5] = 0
		$msgId[0][0] += 1
		If $msgId[0][0] = 1 Then
			GUIRegisterMsg($MSG_WM_COPYDATA, 'MSG_WM_COPYDATA')
		EndIf
		Return SetError(0, 0, $ID)
	EndIf

	If $sFunction > '' Then
		$msgId[$j][2] = $sFunction
		$ID = $msgId[$j][0]
	Else
		$wmInt = 1

		$k = 1
		$t = StringLower($msgId[$j][2])
		While $k <= $msgQueue[0][0]
			If StringLower($msgQueue[$k][0]) = $t Then
				For $i = $k To $msgQueue[0][0] - 1
					For $l = 0 To 1
						$msgQueue[$i][$l] = $msgQueue[$i + 1][$l]
					Next
				Next
				ReDim $msgQueue[$msgQueue[0][0]][UBound($msgQueue, 2)]
				$msgQueue[0][0] -= 1
				ContinueLoop
			EndIf
			$k += 1
		WEnd
		If $msgId[0][0] = 1 Then
			GUIRegisterMsg($MSG_WM_COPYDATA, '')
			_stop()
		EndIf
		GUIDelete($msgId[$j][3])
		For $i = $j To $msgId[0][0] - 1
			For $l = 0 To 5
				$msgId[$i][$l] = $msgId[$i + 1][$l]
			Next
		Next
		ReDim $msgId[$msgId[0][0]][UBound($msgId, 2)]
		$msgId[0][0] -= 1
		$ID = 0

		$wmInt = 0
	EndIf

	Return SetError(0, 0, $ID)
EndFunc   ;==>_MsgRegister

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgRelease
; Description:		Removes all registered local receivers.
; Syntax:			_MsgRelease (  )
; Parameter(s):		None.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgRelease()

	$wmInt = 1

	ReDim $msgQueue[1][UBound($msgQueue, 2)]
	$msgQueue[0][0] = 0
	GUIRegisterMsg($MSG_WM_COPYDATA, '')
	For $i = 1 To $msgId[0][0]
		GUIDelete($msgId[$i][3])
	Next
	ReDim $msgId[1][UBound($msgId, 2)]
	$msgId[0][0] = 0
	_stop()

	$wmInt = 0

	Return SetError(@error, 0, (Not @error))
EndFunc   ;==>_MsgRelease

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgSend
; Description:		Sends a data to the registered receiver.
; Syntax:			_MsgSend ( $sIdentifier, $sMessage )
; Parameter(s):		$sIdentifier - The identifier (name) of the registered receiver.
;					$sMessage    - The string of data to send.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 and sets the @error flag to non-zero. @extended flag can also be set to following values:
;							-1 - if message queue busy
;							 2 - if registered window not found
;
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgSend($sIdentifier, $sMessage)

	Local $hWnd, $SendErr = False, $aRet, $tMessage, $tCOPYDATA

	If (Not IsString($sIdentifier)) Or (Not IsString($sMessage)) Or (StringStripWS($sIdentifier, 8) = '') Then
		Return SetError(1, 0, 0)
	EndIf

	$hWnd = _winhandle($sIdentifier & $msgId[0][5])
	If $hWnd = 0 Then
		Return SetError(1, 2, 0)
	EndIf

	$tMessage = DllStructCreate('char[' & StringLen($sMessage) + 1 & ']')
	DllStructSetData($tMessage, 1, $sMessage)
	$tCOPYDATA = DllStructCreate('dword;dword;ptr')
	DllStructSetData($tCOPYDATA, 2, StringLen($sMessage) + 1)
	DllStructSetData($tCOPYDATA, 3, DllStructGetPtr($tMessage))
	$aRet = DllCall('user32.dll', 'lparam', 'SendMessage', 'hwnd', $hWnd, 'int', $MSG_WM_COPYDATA, 'wparam', 0, 'lparam', DllStructGetPtr($tCOPYDATA))
	If @error Then
		$SendErr = 1
	EndIf
	$tCOPYDATA = 0
	$tMessage = 0
	If $SendErr Then
		Return SetError(1, 0, 0)
	EndIf
	If $aRet[0] = -1 Then
		Return SetError(1, -1, 0)
	EndIf
	Return 1
EndFunc   ;==>_MsgSend

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgTimerInterval
; Description:		Sets a frequency of the processing queue messages.
; Syntax:			_MsgTimerInterval ( $iTimerInterval )
; Parameter(s):		$iTimerInterval - Timer interval in millisecond.
; Return Value(s):	Success: Returns a new timer interval.
;					Failure: Returns a previous (or new) timer interval is used and sets the @error flag to non-zero.
; Author(s):		Yashied
; Note(s):			The time interval during which messages reach the receiver. The initial (at the start of the script) value of the
;					timer interval is 100.
;====================================================================================================================================

Func _MsgTimerInterval($iTimerInterval)
	If Not IsInt($iTimerInterval) Then
		Return SetError(1, 0, $msgId[0][2])
	EndIf
	If $iTimerInterval = 0 Then
		Return SetError(0, 0, $msgId[0][2])
	EndIf
	If $iTimerInterval < 50 Then
		$iTimerInterval = 50
	EndIf
	_stop()
	If @error Then
		Return SetError(1, 0, $msgId[0][2])
	EndIf
	$msgId[0][2] = $iTimerInterval
	_start()
	If @error Then
		GUIRegisterMsg($MSG_WM_COPYDATA, '')
		Return SetError(1, 0, $msgId[0][2])
	EndIf
	Return $msgId[0][2]
EndFunc   ;==>_MsgTimerInterval

; #FUNCTION# ========================================================================================================================
; Function Name:	_MsgWindowHandle
; Description:		Retrieves an internal handle of a window associated with the receiver.
; Syntax:			_MsgWindowHandle ( $controlID )
; Parameter(s):		$controlID - The control identifier (controlID) as returned by a _MsgRegister() function.
; Return Value(s):	Success: Returns handle to registered window.
;					Failure: Returns 0.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _MsgWindowHandle($controlID)
	For $i = 1 To $msgId[0][0]
		If $msgId[$i][0] = $controlID Then
			Return $msgId[$i][3]
		EndIf
	Next
	Return 0
EndFunc   ;==>_MsgWindowHandle

; #FUNCTION# ========================================================================================================================
; Function Name:	_IsReceiver
; Description:		Check if the identifier associated with the receiver.
; Syntax:			_IsReceiver ( $sIdentifier )
; Parameter(s):		$sIdentifier - The identifier (name) to check.
; Return Value(s):	Success: Returns 1.
;					Failure: Returns 0 if identifier is not associated with the receiver.
; Author(s):		Yashied
; Note(s):			-
;====================================================================================================================================

Func _IsReceiver($sIdentifier)
	If (Not IsString($sIdentifier)) Or (_winhandle($sIdentifier & $msgId[0][5]) = 0) Then
		Return 0
	EndIf
	Return 1
EndFunc   ;==>_IsReceiver

#EndRegion Public Functions

#Region Internal Functions

Func _function($hWnd)
	For $i = 0 To $msgId[0][0]
		If $msgId[$i][3] = $hWnd Then
			Return $msgId[$i][2]
		EndIf
	Next
	Return 0
EndFunc   ;==>_function

Func _message($sFunction, $sMessage)
	ReDim $msgQueue[$msgQueue[0][0] + 2][UBound($msgQueue, 2)]
	$msgQueue[$msgQueue[0][0] + 1][0] = $sFunction
	$msgQueue[$msgQueue[0][0] + 1][1] = $sMessage
	$msgQueue[0][0] += 1
EndFunc   ;==>_message

Func _queue()

	If ($wmInt = 1) Or ($qeInt = 1) Or ($msgQueue[0][0] = 0) Then
		Return
	EndIf

	$qeInt = 1

	Local $Ret = Call($msgQueue[1][0], $msgQueue[1][1])

	If (@error = 0xDEAD) And (@extended = 0xBEEF) Then
;		$wmInt = 1
;		_WinAPI_ShowError($msgQueue[1][0] & '(): Function does not exist or invalid number of parameters.')
;		Exit
	Else

		Local $Lenght = $msgQueue[0][0] - 1

		Switch $Ret
			Case 0
				For $i = 1 To $Lenght
					For $j = 0 To 1
						$msgQueue[$i][$j] = $msgQueue[$i + 1][$j]
					Next
				Next
;				If $msgQueue[0][0] > $Lenght + 1 Then
;					$wmInt = 1
;					_WinAPI_ShowError('The message(s) was lost.')
;					Exit
;				EndIf
				ReDim $msgQueue[$Lenght + 1][UBound($msgQueue, 2)]
				$msgQueue[0][0] = $Lenght
			Case Else
				If $Lenght > 1 Then
					_swap(1, 2)
				EndIf
		EndSwitch
	EndIf

	$qeInt = 0
EndFunc   ;==>_queue

Func _start()

	Local $aRet

	If $msgId[0][4] = 0 Then
		$aRet = DllCall('user32.dll', 'int', 'SetTimer', 'hwnd', 0, 'int', 0, 'int', $msgId[0][2], 'ptr', DllCallbackGetPtr($msgId[0][3]))
		If (@error) Or ($aRet[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
		$msgId[0][4] = $aRet[0]
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_start

Func _stop()

	Local $aRet

	If $msgId[0][4] > 0 Then
		$aRet = DllCall('user32.dll', 'int', 'KillTimer', 'hwnd', 0, 'int', $msgId[0][4])
		If (@error) Or ($aRet[0] = 0) Then
			Return SetError(1, 0, 0)
		EndIf
		$msgId[0][4] = 0
	EndIf
	Return SetError(0, 0, 1)
EndFunc   ;==>_stop

Func _swap($Index1, $Index2)

	Local $tmp

	For $i = 0 To 1
		$tmp = $msgQueue[$Index1][$i]
		$msgQueue[$Index1][$i] = $msgQueue[$Index2][$i]
		$msgQueue[$Index2][$i] = $tmp
	Next
EndFunc   ;==>_swap

Func _winhandle($sTitle)

	Local $wList = WinList()

	$sTitle = StringLower($sTitle)
	For $i = 1 To $wList[0][0]
		If StringLower($wList[$i][0]) = $sTitle Then
			Return $wList[$i][1]
		EndIf
	Next
	Return 0
EndFunc   ;==>_winhandle

#EndRegion Internal Functions

#Region Windows Message Functions

Func MSG_WM_COPYDATA($hWnd, $iMsg, $wParam, $lParam)

	If ($wmInt = 1) Then
		Return -1
	EndIf

	Local $Function = _function($hWnd)

	If $Function > '' Then

		Local $tCOPYDATA = DllStructCreate('dword;dword;ptr', $lParam)
		Local $tMsg = DllStructCreate('char[' & DllStructGetData($tCOPYDATA, 2) & ']', DllStructGetData($tCOPYDATA, 3))

		_message($Function, DllStructGetData($tMsg, 1))
		Return 0
	EndIf
	Return 'GUI_RUNDEFMSG'
EndFunc   ;==>MSG_WM_COPYDATA

#EndRegion Windows Message Functions

#Region OnAutoItExit

Func OnMessagesExit()
	GUIRegisterMsg($MSG_WM_COPYDATA, '')
	_stop()
	DllCallbackFree($msgId[0][3])
EndFunc   ;==>OnMessagesExit

#EndRegion OnAutoItExit
