#NoEnv

; #1 - Basic translation
MsgBox,,    "#1", % Translate("Basic") " test"

; #2a - Argument
TitleApp := "Translation Helper"
MsgBox,,    "#2a", % Translate("Greetings", [TitleApp])

; #2b - Example multiple arguments
colors := ["blue", "white", "red"]
MsgBox,,    "#2b", % Translate("Flag", [colors[1], colors[2], colors[3]])

; #3 - Multiline

; #4 - Example complex MsgBox
MsgBox, 48, "#4", % Translate("GetVar("TitleApp")")

GetTitle(var){
    global
    return %var%
}