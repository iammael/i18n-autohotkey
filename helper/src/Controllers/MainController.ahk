/*
    Main Controller
*/

class Controller
{
    Model := ""
    View := ""

    ;CurrentKey := 1
    CurrentKeyName := ""
    HasLoaded := False

    __New( Model, View)
    {
        this.Model := Model
        this.View  := View
        this.View.AddListener(this)
    }

    CurrentKey {
        get { 
            return this.stored_CurrentKey
        }
        set {
            If (InStr(value, "+"))
                finalValue := this.CurrentKey + StrReplace(value, "+")
            Else If (InStr(value, "-"))
                finalValue := this.CurrentKey - StrReplace(value, "-")
            Else
                finalValue := value
            If (finalValue < 1 || finalValue > this.Model.NbKeys)
                return
            this.LoadContentOnGui(finalValue)
            return this.stored_CurrentKey := finalValue
        }
    }

    LoadContentOnGui(index)
	{
        NbKeys := this.Model.NbKeys

		this.View.StatusBarSetProgress(index, NbKeys)
		this.View.StatusBarSetText("Step: " index "/" NbKeys)
        GuiControl, % this.View._hwnd ":+Range1-" NbKeys , % this.View.SliderKey._hwnd ; hijack library not working with sliders apparently

        this.CurrentKeyName := this.Model.MasterTranslation.GetKey(index)
        this.View.SetTextKeyNameContent(this.CurrentKeyName)
        this.View.SetEditorContent("Master", this.Model.MasterTranslation.GetValue(index))
        this.View.SetEditorContent("Current", this.Model.CurrentTranslation.GetValue(index))
	}

    /*
        Menu
    */

    BtnSave_Listener(id)
    {
        this.Model.SaveTranslationKey(id, this.CurrentKey)
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
        LoadContentOnGui(SliderKey)
    return

NextKey:
    If (_CurrentKey < _NbKeys)
        If (CheckForModifications())
            LoadContentOnGui(++_CurrentKey)
    return

PreviousKey:
    If (_CurrentKey > 1)
        If (CheckForModifications())
            LoadContentOnGui(--_CurrentKey)
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

;Need to be rewritten with Hotkey function
^Left::
    MenuPreviousKey:
    Prog.View.ChangeOnScreenKey("-1")
    return

;Need to be rewritten with Hotkey function
^Right::
    MenuNextKey:
    Prog.View.ChangeOnScreenKey("+1")
    return

^S::
SaveCurrentKeys:
    ;SaveTranslation("Master")
    ;SaveTranslation("Current")
    return
#IfWinActive

Esc::
+F12::
GuiClose:
Quit:
    ExitApp