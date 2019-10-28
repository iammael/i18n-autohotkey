/*
    Main Controller
*/

class Controller
{
    model := ""
    view := ""

    __New( model, view)
    {
        this.model := model
        this.view  := view
        this.view.AddListener(this)
    }

    /*
        Menu
    */

    MenuReloadListener(){
        Reload
    }
    button1Listener()
    {
        this.model.aSimpleFunction()
        this.view.ed1.text := this.model.aTextVariable
    }
    BtnSave_Listener(id)
    {
        this.model.SaveTranslationKey(id)
    }
}

/*
    Gui controls
*/
/*
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

ButtonSave:
    Gui, Submit, NoHide
    id := (A_GuiControl = "SaveMaster") ? "Master" : "Current"
    SaveTranslation(id)
    return
*/
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
    ;SaveTranslation("Master")
    ;SaveTranslation("Current")
    return
#IfWinActive

+F12::
GuiClose:
Quit:
    ExitApp