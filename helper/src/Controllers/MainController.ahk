/*
    Main Controller
*/

class Controller
{
    Model := ""
    View := ""

    CurrentKey := 1
    CurrentKeyName := ""
    MasterModifications := False
    CurrentModifications := False

    __New( Model, View)
    {
        this.Model := Model
        this.View  := View
        this.View.AddListener(this)
    }

    LoadGuiContent(index)
	{
        NbKeys := this.Model.NbKeys

		this.View.StatusBarSetProgress(index, NbKeys)
		this.View.StatusBarSetText("Step: " index "/" NbKeys)
        GuiControl, % this.View._hwnd ":+Range1-" NbKeys , % this.View.SliderKey._hwnd ; hijack library not working with sliders apparently
		For key, value in this.Model.MasterTranslation.LanguageData[index]
		{
			this.CurrentKeyName := key
			this.View.AddTranslationToEditorInput("Master", key, value)
			this.View.AddTranslationToEditorInput("Current", key, this.Model.CurrentTranslation.LanguageData[index][key])
			break
		}
		If (this.MasterModifications = True)
		{
			_MasterModifications := !_MasterModifications
			Gui, Font, Normal s14
			GuiControl, Font, TextMasterTranslationTitle
			GuiControl,, TextMasterTranslationTitle, Master Translation
			Gui, Font, Normal
		}
		If (this.CurrentModifications = True)
		{
			_CurrentModifications := !_CurrentModifications
			Gui, Font, Normal s14
			GuiControl, Font, TextCurrentTranslationTitle
			GuiControl,, TextCurrentTranslationTitle, Current Translation
			Gui, Font, Normal
		}
	}

    /*
        Menu
    */

    MenuReloadListener(){
        Reload
    }
    button1Listener()
    {
        this.Model.aSimpleFunction()
        this.View.ed1.text := this.Model.aTextVariable
    }
    BtnSave_Listener(id)
    {
        this.Model.SaveTranslationKey(id)
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