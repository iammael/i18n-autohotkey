#Include ..\lib\i18n.ahk

MyAppName := "Sample Project"

Global i18nService := New i18n("i18n", "en-US")

MsgBox % Translate("HelloWord")
MsgBox % Translate("Greetings")

; You can dynamically change the language without reloading the program

i18nService := New i18n("i18n", "fr-FR")

MsgBox % Translate("HelloWord")
MsgBox % Translate("Greetings")