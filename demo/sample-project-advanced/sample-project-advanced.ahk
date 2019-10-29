/*
    Demo file
*/

#NoEnv
#SingleInstance, Force

#Include ..\..\i18n.ahk

Global i18nService := New i18n("..\i18n-data", "en-US", True)

/*
    Gui
*/

Gui, Add, Button,   ,Switch Language
Gui, Add, Text,     vTextGui w150,% Translate("TextGui")
Gui, Add, Button,   ,Demo
Gui, Show,          w300 h200

toggled := False
return

GetVar(var){
    global
    return %var%
}

ButtonSwitchLanguage:
    If !toggled
        lang := "fr-FR"
    Else
        lang := "en-US"
    i18nService := New i18n("i18n", lang, True)
    GuiControl, Text, TextGui, % Translate("TextGui")
    toggled := !toggled
return

ButtonDemo:
    ; #1 - Basic translation
    MsgBox,,    % "#1", % Translate("Basic")

    ; #2a - Argument
    TitleApp := "Translation Helper"
    MsgBox,,    % "#2a", % Translate("Greetings", [TitleApp])

    ; #2b - Example multiple arguments
    colors :=   [Translate("Blue"), Translate("White"), Translate("Red")]
    MsgBox,,    % "#2b", % Translate("Flag", [colors[1], colors[2], colors[3]])

    ; #3 - Multiline
    ; To Do
    ; #4 - Example complex MsgBox
    MsgBox,     48, % "#4 " Translate("ComplexTitle", [GetVar("TitleApp")]), % Translate("Complex", [colors[3], colors[1]])
return

ButtonSwitchLanguage:
    If !toggled
        lang := "fr-FR"
    Else
        lang := "en-US"
    i18n := New i18n("i18n", lang, True)
    GuiControl, Text, TextGui, % Translate("TextGui")
    toggled := !toggled
return

F12::
    ExitApp
    return