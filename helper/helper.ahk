#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
StringCaseSense On

#SingleInstance Force

#Include helper-gui.ahk

; INI Settings
Global TranslationsFolder := ""
Global SourcesFolder := ""
PathIniSettings := "helper-settings.ini"
IniRead, TranslationsFolder, %PathIniSettings%, Path, Translations
IniRead, SourcesFolder, %PathIniSettings%, Path, Sources
IniRead, defaultMaster, %PathIniSettings%, Default, Master
IniRead, defaultCurrent, %PathIniSettings%, Default, Current

; Globals
Global MasterTranslation := New Translation(translationsFolder . "en-US.ini")
Global CurrentTranslation := New Translation()
Global NbKeys := 0
Global CurrentKey := 1
Global CurrentKeyName := ""
Global MasterModifications = False
Global CurrentModifications = False

; Main
GoSub, LoadGuiSettings
CurrentTranslation.file := translationsFolder . SelectCurrentTranslation ".ini"
Gosub, ParseSourceCode
NbKeys := MasterTranslation.translations.MaxIndex()
LoadGuiContent(CurrentKey)

return ; End of main

Class Translation {
    file := ""
    translations := []

    __New(file := "") 
    {
        this.file := file
        

    }
}

ParseSourceCode:
    i := 1
    Loop Files, %SourcesFolder%*.ahk, R
    {
        If (InStr(A_LoopFileFullPath, "Tools\") || InStr(A_LoopFileFullPath, "Resources\") || InStr(A_LoopFileFullPath, "i18n"))
            Continue
        Loop, Read, %A_LoopFileFullPath%
        {
            keys := ParseLineForTranslateCall(A_LoopReadLine)
            Loop % keys.MaxIndex()
            {
                MasterTranslation.translations[i] := Object(keys[A_Index], RetrieveTranslation(MasterTranslation, keys[A_Index]))
                CurrentTranslation.translations[i++] := Object(keys[A_Index], RetrieveTranslation(CurrentTranslation, keys[A_Index]))
            }
        }
    }
    return

/* 
    FUNCTIONS 
*/

LoadGuiContent(index)
{
    SetProgress(index, NbKeys)
    SetText("Step: " index "/" NbKeys)
    GuiControl, , SliderKey, %index%
    GuiControl, +Range1-%NbKeys%, SliderKey
    For key, value in MasterTranslation.translations[index]
    {
        CurrentKeyName := key
        AddTranslationToEditorInput("MasterTranslation", key, value)
        AddTranslationToEditorInput("CurrentTranslation", key, CurrentTranslation.translations[index][key])
    }
    If (MasterModifications = True)
    {
        MasterModifications := !MasterModifications
            Gui, Font, Normal s14
            GuiControl, Font, TextMasterTranslationTitle
            GuiControl,, TextMasterTranslationTitle, Master Translation
            Gui, Font, Normal
    }
    If (CurrentModifications = True)
    {
        CurrentModifications := !CurrentModifications
            Gui, Font, Normal s14
            GuiControl, Font, TextCurrentTranslationTitle
            GuiControl,, TextCurrentTranslationTitle, Current Translation
            Gui, Font, Normal
    }
}

DebugTranslation(filename){
    Loop % CurrentTranslation.translations.MaxIndex()
        For index, value in CurrentTranslation.translations[A_Index]
            MsgBox % "Item " index " is '" value "'"
}

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

AddTranslationToEditorInput(inputName, key, value)
{
    GuiControl, Text, % inputName "Key", % "Key: " key "📋"
    GuiControl, , % "Edit" inputName , %value%
    Gui, Submit, NoHide
}

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
    If (MasterModifications || CurrentModifications)
        MsgBox, % 49+4096, Alert, % "You have some unsaved edits for this key. Press Ok to discard them."
    IfMsgBox, Cancel
        Return False
    Return True
}

GetKeyCodeInClipboard:
    Gui, Submit, NoHide
    Clipboard := "Translate(""" CurrentKeyName """)"
    return

PreviewMaster:
    Gui, Submit, NoHide
    MsgBox, 32, Preview, %EditMasterTranslation%
    return
PreviewCurrent:
    Gui, Submit, NoHide
    MsgBox, 32, Preview, %EditCurrentTranslation%
    return

ToggleMasterModifications:
    Gui, Submit, NoHide
    If MasterModifications
        return
    GuiControlGet, title, , TextMasterTranslationTitle
    Gui, Font, Italic s14
    GuiControl, Font, TextMasterTranslationTitle
    GuiControl,, TextMasterTranslationTitle, %title%*
    Gui, Font, Normal
    MasterModifications := !MasterModifications
    return
ToggleCurrentModifications:
    Gui, Submit, NoHide
    If CurrentModifications
        return
    GuiControlGet, title, , TextCurrentTranslationTitle
    Gui, Font, Italic s14
    GuiControl, Font, TextCurrentTranslationTitle
    GuiControl,, TextCurrentTranslationTitle, %title%*
    Gui, Font, Normal
    CurrentModifications := !CurrentModifications
    return

LoadMasterTranslation:
    Gui, Submit, NoHide
    MasterTranslation.file := TranslationsFolder SelectMasterTranslation ".ini"
    Gosub, ParseSourceCode
    LoadGuiContent(CurrentKey)
    return
LoadCurrentTranslation:
    Gui, Submit, NoHide
    CurrentTranslation.file := TranslationsFolder SelectCurrentTranslation ".ini"
    Gosub, ParseSourceCode
    LoadGuiContent(CurrentKey)
    return

LoadGuiSettings:
    translationsFiles := ""
    Loop %translationsFolder%*.ini
    {
        If (A_LoopFileName = "en-US.ini")
            Continue
        translationsFiles := translationsFiles StrSplit(A_LoopFileName, .)[1] "|"
    }
    GuiControl, , SelectMasterTranslation, % "|en-US||" translationsFiles
    GuiControl, , SelectCurrentTranslation, % "|" translationsFiles "|"
    Gui, Submit, NoHide
    return

SliderUpdateKey:
    If (CheckForModifications())
        LoadGuiContent(SliderKey)
    return

NextKey:
    If (CurrentKey < NbKeys)
        If (CheckForModifications())
            LoadGuiContent(++CurrentKey)
    return

PreviousKey:
    If (CurrentKey > 1)
        If (CheckForModifications())
            LoadGuiContent(--CurrentKey)
    return

SaveMaster:
    Gui, Submit, NoHide
    Gui, Font, Normal s14
    GuiControl, Font, TextMasterTranslationTitle
    GuiControl,, TextMasterTranslationTitle, Master Translation
    Gui, Font, Normal
    MasterModifications := False
    IniWrite, %EditMasterTranslation%, % MasterTranslation.file, Strings, % CurrentKeyName
    return

SaveCurrent:
    Gui, Submit, NoHide
    Gui, Font, Normal s14
    GuiControl, Font, TextCurrentTranslationTitle
    GuiControl,, TextCurrentTranslationTitle, Current Translation
    Gui, Font, Normal
    CurrentModifications := False
    IniWrite, %EditCurrentTranslation%, % CurrentTranslation.file, Strings, % CurrentKeyName
    return

TestMsg:
    MsgBox It's working chief!
    return

+F12::
GuiClose:
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