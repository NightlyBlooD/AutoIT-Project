#cs ----------------------------------------------------------------------------
 AutoIt Version: 3.3.0.0
 Author:         Kenneth P. Morrissey (ken82m)

 UDF Function:   Enabled skinning of AutoIT GUI's using SkinCrafter
                (Tested with SkinCrafter 3.3.3)

 Example
                #include <SkinCrafter.au3>
                _LoadSkinCrafter("SkinCrafterDLL.dll");Load SkinCrafter DLL

        ;GUI With Initial Skin
                $GUI_1 = GuiCreate("Test", -1, -1, 0, 0)
                _InitializeSkinCrafter($GUI_1, "ice-cold.skf")
                GUICtrlCreateButton("Test", 50, 50, 50)
                GUISetState()

        ;GUI With Additional Skin Loaded & Applied
                $GUI_2 = GuiCreate("Test2", -1, -1, 200, 0)
                GUICtrlCreateButton("Test", 10, 10, 50)
                _LoadSkin("skinastic.skf", 2)
                _ApplySkin($GUI_2, 2)
                GUISetState()

        ;GUI with no skin applied
                $GUI_3 = GuiCreate("Test3", -1, -1, 400, 0)
                GUICtrlCreateButton("Test", 10, 10, 50)
                _ExcludeSkin($GUI_3)
                GUISetState()

        ;GUI with initial skin automatically applied
                $GUI_4 = GuiCreate("Test4", -1, -1, 600, 0)
                GUICtrlCreateButton("Test", 10, 10, 50)
                GUISetState()

                While 1
                   If GuiGetMsg()=-3 Then Exit
                WEnd
#ce ----------------------------------------------------------------------------
Global $nSkinCrafterDll



#cs===================================================================================
 Fuction        _LoadSkinCrafter ( $nDLL )

 Description    Loads the SkinCrafter DLL into Memory
                This should be run before any GUI's are created.

 Parameter      $nDLL       The path to SkinCrafterDLL.dll

 Return         Success     1
                Failure     0   Sets @error:  1 - $nDLL   Does Not Exist
                                              2 - DLLOpen  Failed

 Author         Kenneth P. Morrissey (ken82m)
#ce===================================================================================
Func _LoadSkinCrafter($nDLL)
    $nSkinCrafterDll = DllOpen($nDLL)
    If Not FileExists($nDLL) Then
        SetError(1)
        Return 0
    EndIf
    If $nSkinCrafterDll = -1 Then
        SetError(2)
        Return 0
    EndIf
    DllCall($nSkinCrafterDll, "int:cdecl", "InitLicenKeys", "wstr","SKINCRAFTER", "wstr","SKINCRAFTER.COM", "wstr", "support@skincrafter.com","wstr","DEMOSKINCRAFTERLICENCE")
    DllCall($nSkinCrafterDll, "int:cdecl", "DefineLanguage", "int", 0)
    Return 1
EndFunc



#cs===================================================================================
 Fuction        _InitializeSkinCrafter ( $nHWND , $nSkin )

 Description    Load Initial Skin and Apply to GUI (Only Run ONCE)
                This should be run AFTER the GUI is created but BEFORE any controls.

                This skin will apply to all future GUI's by default.

 Parameter      $nHWND      Handle to the first GUI created
                $nSkin      Path to Skin File (SKF)

 Return         Success     1
                Failure     0   Sets @error:  1 - $nInitialGUI  Does Not Exist
                                              2 - $nSkin        Does Not Exist

 Author         Kenneth P. Morrissey (ken82m)
#ce===================================================================================
Func _InitializeSkinCrafter($nHWND, $nSkin)
    If Not WinExists($nHWND) Then
        SetError(1)
        Return 0
    EndIf
    If Not FileExists($nSkin) Then
        SetError(2)
        Return 0
    EndIf
    DllCall($nSkinCrafterDll, "int:cdecl", "InitDecoration", "int", 1)
    DllCall($nSkinCrafterDll, "int:cdecl", "LoadSkinFromFile", "wstr", $nSkin)
    DllCall($nSkinCrafterDll, "int:cdecl", "ApplySkin")
    DllCall($nSkinCrafterDll, "int:cdecl", "DecorateAs","long",$nHWND,"long",1)
    Return 1
EndFunc



#cs===================================================================================
 Fuction        _ApplySkin ( $nHWND , $nSkinID )

 Description    Load Initial Skin and Apply to GUI (Only Run ONCE)
                No restrictions, this can be run at any time during the script after InitializeSkinCrafter()

 Parameter      $nHWND      Handle to the first GUI created
                $nSkinID    ID of loaded skin to apply (Must be greater than 1)

 Return         Success     1
                Failure     0   Sets @error:  1 - $nHWND    Does Not Exist
                                              2 - $nSkinID  is invalid

 Author         Kenneth P. Morrissey (ken82m)
#ce===================================================================================
Func _ApplySkin($nHWND, $nSkinID)
    If Not WinExists($nHWND) Then
        SetError(1)
        Return 0
    EndIf
    If $nSkinID > 1 Then
        DllCall($nSkinCrafterDll, "int:cdecl", "ApplyAddedSkin","long",$nHWND,"long",$nSkinID)
        Return 1
    Else
        SetError(2)
        Return 0
    EndIf
EndFunc



#cs===================================================================================
 Fuction        _LoadSkin ( $nSkin , $nSkinID )

 Description    Load additional skin file.

 Parameter      $nSkin      Path to the skin file being loaded
                $nSkinID    ID to associate with the skin (Must be a number greater than 1)

 Return         Success     1
                Failure     0   Sets @error:  1 - $nSkin    Does Not Exist
                                              2 - $nSkinID  is Inavlid

 Author         Kenneth P. Morrissey (ken82m)
#ce===================================================================================
Func _LoadSkin($nSkin, $nSkinID)
    If Not FileExists($nSkin) Then
        SetError(1)
        Return 0
    EndIf
    If $nSkinID > 1 Then
        DllCall($nSkinCrafterDll, "int:cdecl", "AddSkinFromFile", "wstr", $nSkin, "short",$nSkinID)
        Return 1
    Else
        SetError(2)
        Return 0
    EndIf
EndFunc



#cs===================================================================================
 Fuction        _ExcludeSkin ( $nHWND )

 Description    Excludes a GUI from all loaded skins.

 Parameter      $nHWND      Handle to the GUI to exclude

 Return         Success     1
                Failure     0   Sets @error:  1 - $nHWND  Does Not Exist

 Author         Kenneth P. Morrissey (ken82m)
#ce===================================================================================
Func _ExcludeSkin($nHWND)
    If Not WinExists($nHWND) Then
        SetError(1)
        Return 0
    EndIf
    DllCall($nSkinCrafterDll, "int:cdecl", "ExcludeWnd", "long", $nHWND)
    Return 1
EndFunc