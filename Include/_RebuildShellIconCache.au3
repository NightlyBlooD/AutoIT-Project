; Обновление кэша значков
; Не сработало на WIN7
; engine
; http://www.autoitscript.com/forum/topic/70433-rebuild-shell-icon-cache/page__view__findpost__p__531242

; _RebuildShellIconCache()

Func _RebuildShellIconCache()
    Local Const $sKeyName = "HKCU\Control Panel\Desktop\WindowMetrics"
    Local Const $sValue = "Shell Icon Size"
    
    $sDataRet = RegRead($sKeyName, $sValue)
    If @error Then Return SetError(1)
    
    RegWrite($sKeyName, $sValue, "REG_SZ", $sDataRet + 1)
    If @error Then Return SetError(1)
    
    $bcA = _BroadcastChange()
    
    RegWrite($sKeyName, $sValue, "REG_SZ", $sDataRet)
    
    $bcB = _BroadcastChange()
    
    If $bcA = 0 Or $bcB = 0 Then Return SetError(1)
    
    Return
EndFunc ;==> _RebuildShellIconCache()

Func _BroadcastChange()
    Local Const $HWND_BROADCAST = 0xffff
    Local Const $WM_SETTINGCHANGE = 0x1a
    Local Const $SPI_SETNONCLIENTMETRICS = 0x2a
    Local Const $SMTO_ABORTIFHUNG = 0x2
    
    $bcResult = DllCall("user32.dll", "lresult", "SendMessageTimeout", _
        "hwnd", $HWND_BROADCAST, _
            "uint", $WM_SETTINGCHANGE, _
                "wparam", $SPI_SETNONCLIENTMETRICS, _
                    "lparam", 0, _
                        "uint", $SMTO_ABORTIFHUNG, _
                            "uint", 10000, _
                                "dword*", "success")
    If @error Then Return 0
    
    Return $bcResult[0]
EndFunc ;==> _BroadcastChange()