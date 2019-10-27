/*
    Helper main file
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
StringCaseSense On

#SingleInstance Force

#Include helper-gui.ahk
#Include helper-parser.ahk

; INI Settings
Global _TranslationsFolder := ""
Global _SourcesFolder := ""
PathIniSettings := "helper-settings.ini"
IniRead, _TranslationsFolder, %PathIniSettings%, Path, Translations
IniRead, _SourcesFolder, %PathIniSettings%, Path, Sources
IniRead, defaultMaster, %PathIniSettings%, Default, Master
IniRead, defaultCurrent, %PathIniSettings%, Default, Current

; Globals
Global _MasterTranslation := New Translation(_TranslationsFolder . "en-US.ini")
Global _CurrentTranslation := New Translation()
Global _NbKeys := 0
Global _CurrentKey := 1
Global _CurrentKeyName := ""
Global _MasterModifications = False
Global _CurrentModifications = False

; Main
GoSub, LoadGuiSettings
_CurrentTranslation.file := _TranslationsFolder . SelectCurrentTranslation ".ini"
Gosub, ParseSourceCode

_NbKeys := _MasterTranslation.translations.MaxIndex()
LoadGuiContent(_CurrentKey)

return ; End of main

Class Translation {
    file := ""
    translations := []

    __New(file := "") 
    {
        this.file := file
    }
}

/* 
    Functions
*/

IsAlreadyInList(currentKey)
{
    Loop, % _MasterTranslation.translations.MaxIndex()
        For key, value in _MasterTranslation.translations[A_Index]
            If (key = currentKey)
                return True
    return False
}

;To be revised
LoadGuiContent(index)
{
    SetProgress(index, _NbKeys)
    SetText("Step: " index "/" _NbKeys)
    GuiControl, , SliderKey, %index%
    GuiControl, +Range1-%_NbKeys%, SliderKey
    For key, value in _MasterTranslation.translations[index]
    {
        _CurrentKeyName := key
        AddTranslationToEditorInput("MasterTranslation", key, value)
        break
    }
    If (_MasterModifications = True)
    {
        _MasterModifications := !_MasterModifications
            Gui, Font, Normal s14
            GuiControl, Font, TextMasterTranslationTitle
            GuiControl,, TextMasterTranslationTitle, Master Translation
            Gui, Font, Normal
    }
    If (_CurrentModifications = True)
    {
        _CurrentModifications := !_CurrentModifications
            Gui, Font, Normal s14
            GuiControl, Font, TextCurrentTranslationTitle
            GuiControl,, TextCurrentTranslationTitle, Current Translation
            Gui, Font, Normal
    }
}

;To be revised
RetrieveTranslation(Byref obj, key){
    IniRead, readValue, % obj.file, Strings, %key%, %A_Space%
    ;Check for multiline message
    translationValue := readValue
    i := 2
    Loop {
        IniRead, readValue, % obj.file, Strings, %key%%i%, %A_Space%
        If !readValue
            return translationValue
        Else
            translationValue := translationValue . "`n" . readValue
        i++
        
    }
    return translationValue
}

;To be revised
AddTranslationToEditorInput(inputName, key, value)
{
    GuiControl, Text, % inputName "Key", % "Key: " key "📋"
    GuiControl, , % "Edit" inputName , %value%
    Gui, Submit, NoHide
}

;To be revised
ParseLineForTranslateCall(line)
{
    local keys := []
    startingPos := 1
    Loop {
        If ((startingPos++ := InStr(line, "Translate", , startingPos)) > 1)
            keys[A_Index] := StrSplit(line, """")[A_Index * 2] ; this line of code transform the parsed line in an array with a quote as delimiter. More infos at the end of the file.
        Else
            break
    }
    return keys
}

CheckForModifications()
{
    If (_MasterModifications || _CurrentModifications)
        MsgBox, % 49+4096, Alert, % "You have some unsaved edits for this key. Press Ok to discard them."
    IfMsgBox, Cancel
        Return False
    Return True
}

RefreshData()
{
    i := 1
    Loop, % _MasterTranslation.translations.MaxIndex()
        For key, value in _MasterTranslation.translations[A_Index]
            _MasterTranslation.translations[i++][key] := RetrieveTranslation(_MasterTranslation, key)
}

/*
    Main labels
*/

ParseSourceCode:
    i := 1
    IniRead, excludeStr, %PathIniSettings%, Path, Exclude, A_Space
    excludeList := StrSplit(excludeStr, ",")
    Loop Files, %_SourcesFolder%*.ahk, R
    {
        Loop % excludeList.MaxIndex()
            If (InStr(A_LoopFileFullPath, excludeList[A_Index]))
                isExcluded := True
        If !isExcluded
            Loop, Read, %A_LoopFileFullPath%
            {
                Parser := New Parser()
                Parser.ParseLine(A_LoopReadLine)
                Loop % Parser.Commands.MaxIndex()
                {
                    currentKey := Parser.Commands[A_Index].Key
                    If IsAlreadyInList(currentKey)
                        break
                    _MasterTranslation.translations[i] := Object(currentKey, RetrieveTranslation(_MasterTranslation, currentKey))
                    _CurrentTranslation.translations[i++] := Object(currentKey, RetrieveTranslation(_CurrentTranslation, currentKey))
                }
            }
    }
    return

ToggleModifications:
    Gui, Submit, NoHide
    id := (A_GuiControl = "EditMasterTranslation") ? "Master" : "Current"
    If _%id%Modifications
        return
    GuiControlGet, title, , Text%id%TranslationTitle
    Gui, Font, Italic s14
    GuiControl, Font, Text%id%TranslationTitle
    GuiControl,, Text%id%TranslationTitle, %title%*
    Gui, Font, Normal
    _%id%Modifications := !_%id%Modifications
    return

LoadMasterTranslation:
    Gui, Submit, NoHide
    _MasterTranslation.file := _TranslationsFolder SelectMasterTranslation ".ini"
    RefreshData()
    ;Gosub, ParseSourceCode
    LoadGuiContent(_CurrentKey)
    return

LoadCurrentTranslation:
    Gui, Submit, NoHide
    _CurrentTranslation.file := _TranslationsFolder SelectCurrentTranslation ".ini"
    Gosub, ParseSourceCode
    LoadGuiContent(_CurrentKey)
    return

LoadGuiSettings:
    translationsFiles := ""
    Loop %_TranslationsFolder%*.ini
    {
        If (A_LoopFileName = "en-US.ini")
            Continue
        translationsFiles := translationsFiles StrSplit(A_LoopFileName, .)[1] "|"
    }
    GuiControl, , SelectMasterTranslation, % "|en-US||" translationsFiles
    GuiControl, , SelectCurrentTranslation, % "|" translationsFiles "|"
    Gui, Submit, NoHide
    return

/*
    Gui controls
*/

GetKeyCodeInClipboard:
    Gui, Submit, NoHide
    Clipboard := "Translate(""" _CurrentKeyName """)"
    return

ButtonPreview:
    MsgBox, 32, Preview, % (A_GuiControl = "PreviewMaster") ? EditMasterTranslation : EditCurrentTranslation
    return

SliderUpdateKey:
    If (CheckForModifications())
        LoadGuiContent(SliderKey)
    return

NextKey:
    If (_CurrentKey < _NbKeys)
        If (CheckForModifications())
            LoadGuiContent(++_CurrentKey)
    return

PreviousKey:
    If (_CurrentKey > 1)
        If (CheckForModifications())
            LoadGuiContent(--_CurrentKey)
    return

;To be revised
SaveMaster:
    Gui, Submit, NoHide
    Gui, Font, Normal s14
    GuiControl, Font, TextMasterTranslationTitle
    GuiControl,, TextMasterTranslationTitle, Master Translation
    Gui, Font, Normal
    _MasterModifications := False
    IniWrite, %EditMasterTranslation%, % _MasterTranslation.file, Strings, % _CurrentKeyName
    return

;To be revised
SaveCurrent:
    Gui, Submit, NoHide
    Gui, Font, Normal s14
    GuiControl, Font, TextCurrentTranslationTitle
    GuiControl,, TextCurrentTranslationTitle, Current Translation
    Gui, Font, Normal
    _CurrentModifications := False
    IniWrite, %EditCurrentTranslation%, % _CurrentTranslation.file, Strings, % _CurrentKeyName
    return

VisitGitHub:
    Run "https://github.com/iammael/Translation-AHK"
    return

/*
    Shortcuts
*/

#IfWinActive, ahk_Class AutoHotkeyGUI
^R::
Reload:
    Reload
    return

^S::
SaveCurrentKeys:
    GoSub SaveMaster
    GoSub SaveCurrent
    return
#IfWinActive

+F12::
GuiClose:
Quit:
    ExitApp

/*
    REGARDING COMMENT IN ParseLine FUNCTION
    For example with this line: MsgBox, 65, % Translate("FirstStartTitle"), % Translate("FirstStart", [Settings.TitleApp])
    splittedLine[1] = MsgBox, 65, % Translate(
    splittedLine[2] = FirstStartTitle
    splittedLine[3] = % Translate(
    splittedLine[4] = FirstStart
    splittedLine[5] = , [Settings.TitleApp])
    We always want the cell which contains the key, hence why we are only retrieving the [A_Index * 2] value from StrSplit.
*/