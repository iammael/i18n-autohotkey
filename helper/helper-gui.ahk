
/*
    Helper Gui
*/

#Include lib\SB.ahk

TitleApp := "Translation Helper"

;Colors
cWhite = FFFFFF
cBlack = 121212

;Scaling
guiWidth := 1200
guiHeight := 800
guiMargin := 10
guiLabelOptions = h20 0x200 w80
groupboxWidth := guiWidth

;Gui Settings
Gui, -dpiscale
Gui, Color, %cWhite%
Gui +Resize

Gui, Font,, MS Sans Serif
Gui, Font,, Arial
Gui, Font,, Open Sans ; Preferred font.
Gui, Font,, Muli ; Preferred font.

Menu, Tray, Icon,       resources\icon.ico, 1, 1
; Menu Bar
;File
Menu, FileMenu, Add,    Reload`tCtrl+R,Reload
Menu, FileMenu, Add,    Save current keys`tCtrl+S,SaveCurrentKeys
Menu, FileMenu, Add,    Quit`tShift+F12, Quit
Menu, MyMenuBar, Add,   File, :FileMenu
;About
Menu, AboutMenu, Add,   Visit GitHub, VisitGitHub
Menu, MyMenuBar, Add,   ?, :AboutMenu

Gui, Menu,              MyMenuBar

Gui, Font,              %cWhite% s10

;Settings
Gui, Add, GroupBox,     xm ym+10 y+10 Section w%groupboxWidth% h120, Settings
Gui, Add, Text,         ys+30 xs+10 w80, Master
Gui, Add, DropDownList, x+10 vSelectMasterTranslation, No translation files
Gui, Add, Button,       x+10 vLoadMaster gLoadTranslation, Load
Gui, Add, Text,         y+10 xs+10 w80, Current
Gui, Add, DropDownList, x+10 vSelectCurrentTranslation, No translation files
Gui, Add, Button,       x+10 vLoadCurrent gLoadTranslation, Load
;Gui, Add, Button,       ys+100 xs+10 w80,Start

;Translation editor
Gui, Add, GroupBox,     xm ym+10 y+30 Section w%groupBoxWidth% h450, Editor

Gui, Add, Picture,      % "ys+30 gPreviousKey vBtnPrevious xs+" guiWidth / 2.5, resources\arrow-previous.png
Gui, Add, Slider,       x+10 vSliderKey gSliderUpdateKey, 1
Gui, Add, Picture,      x+10 gNextKey vBtnNext, resources\arrow-next.png
Gui, Font,              Bold
Gui, Add, Text,         y+10 xs+10 Center w%guiWidth% vMasterTranslationKey gGetKeyCodeInClipboard, No translation key found
Gui, Font,              Normal

;Editor dynamic
columnWidth := 580
Gui, Font,              s14
Gui, Add, Text,         y+10 xs+10 w%columnWidth% Center vTextMasterTranslationTitle, Master Translation
Gui, Add, Text,         x+20 w%columnWidth% Center vTextCurrentTranslationTitle, Current Translation
Gui, Font,              s10
Gui, Add, Edit,         y+10 xs+10 r5 w%columnWidth% vEditMasterTranslation gToggleModifications
Gui, Add, Edit,         x+20 r5 w%columnWidth% vEditCurrentTranslation gToggleModifications

Gui, Add, Button,       y+10 xs+10 w%columnWidth% Center vPreviewMaster, Preview
Gui, Add, Button,       x+20 w%columnWidth% Center vPreviewCurrent, Preview
Gui, Add, Button,       y+10 xs+10 w%columnWidth% Center vSaveMaster, Save
Gui, Add, Button,       x+20 w%columnWidth% Center vSaveCurrent, Save



Gui, Add, StatusBar
Gui, Show, AutoSize w%guiWidth% h%guiHeight%, %TitleApp%

;Status bar

SB_SetParts(guiWidth/2,guiWidth/2)
barPartId := 1
textPartId := 2

hwnd := SB_SetProgress(0, barPartId)


SetProgress(100)
SetText("Step: 0/0")

SetProgress(step, totalSteps := 0) {
    If (totalSteps = 0)
        SB_SetProgress(step)
    Else
    {
        progress := (step = totalSteps) ? 100 : step * Round(100 / totalSteps)
        SB_SetProgress(progress)
    }
}
SetText(value) {
    SB_SetText(value, 2)
}