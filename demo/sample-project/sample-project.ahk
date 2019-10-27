﻿#Include ..\..\i18n.ahk

MyAppName := "Sample Project"

i18n := New i18n("i18n", "en-US")

MsgBox % Translate("HelloWorld")
MsgBox % Translate("Greetings", [MyAppName])

; You can dynamically change the language without reloading the program

i18n := New i18n("i18n", "fr-FR")

MsgBox % Translate("HelloWorld")
MsgBox % Translate("Greetings", [MyAppName])