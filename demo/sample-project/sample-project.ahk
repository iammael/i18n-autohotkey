#Include ..\..\i18n.ahk

MyAppName := "Sample Project"

Global i18nService := New i18n("..\i18n-data", "en-US")

MsgBox % Translate("HelloWorld")
MsgBox % Translate("Greetings", [MyAppName])

; You can dynamically change the language without reloading the program

i18nService := New i18n("..\i18n-data", "fr-FR")

MsgBox % Translate("HelloWorld")
MsgBox % Translate("Greetings", [MyAppName])