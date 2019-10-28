class View extends CGui
{
    MasterHasModifications := False
    CurrentHasModifications := False

    __New(aParams*){
		global BorderState

        this.title := "Translation Helper v1.0.0"
		
		base.__New(aParams*)
        this.GUI_WIDTH := 1200
        this.GUI_HEIGHT := 800
	}

    ShowGui()
    {
        this.LoadMenuBar()
        this.LoadTitle()
        this.LoadControls()
        this.AddControlsListeners()
        this.Show(, this.title)
        this.LoadStatusBar()
    }

    loadTitle()
    {
        Gui, Font, s16
        this.Gui("Add", "Text", "Center xm w" this.GUI_WIDTH, this.title)
        Gui, Font, s10
    }

    loadControls()
    {
        global

        this.BtnPreviousKey :=              this.Gui("Add", "Picture", "x" this.GUI_WIDTH / 2.3, "resources\arrow-previous.png")
        this.SliderKey :=                   this.Gui("Add", "Slider", "x+10", 0)
        this.BtnNextKey :=                  this.Gui("Add", "Picture", "x+10", "resources\arrow-next.png")
        Gui, Font,                          Bold
        this.TextCurrentKey :=              this.Gui("Add", "Text", "xm y+10 Center w" this.GUI_WIDTH, "No translation key found")
        Gui, Font,                          Normal


        ;Editor dynamic
        columnWidth := 580
        Gui, Font,                          s14
        this.TextMasterTranslationTitle :=  this.Gui("Add", "Text", "Center x10 w" columnWidth, "Master Translation")
        this.TextCurrentTranslationTitle := this.Gui("Add", "Text", "Center x+20 w" columnWidth, "Current Translation")
        Gui, Font,                          s10
        this.EditMasterTranslation :=       this.Gui("Add", "Edit", "y+10 x10 r5 w" columnWidth)
        this.EditCurrentTranslation :=      this.Gui("Add", "Edit", "x+20 r5 w" columnWidth)

        this.BtnPreviewMaster :=            this.Gui("Add", "Button", "Center x10 w" columnWidth, "Preview")
        this.BtnPreviewCurrent :=           this.Gui("Add", "Button", "Center x+20 w" columnWidth, "Preview")

        this.BtnSaveMaster :=               this.Gui("Add", "Button", "Center x10 w" columnWidth, "Save")
        this.BtnSaveCurrent :=              this.Gui("Add", "Button", "Center x+20 w" columnWidth, "Save")

        this.StatusBar :=                   this.Gui("Add", "StatusBar")
    }

    AddControlsListeners(){

        ;Edit fields
        this.GuiControl("+g", this.EditMasterTranslation, this.EditMasterTranslation_OnChanged)
        this.GuiControl("+g", this.EditCurrentTranslation, this.EditCurrentTranslation_OnChanged)

        ;Save
        this.GuiControl("+g", this.BtnSaveMaster, this.BtnSaveMaster_OnClick)
        this.GuiControl("+g", this.BtnSaveCurrent, this.BtnSaveCurrent_OnClick)
    }

    ;To be revised
    AddTranslationToEditorInput(id, key, value)
    {
        If (id = "Master")
            this.GuiControl("Text", this.TextCurrentKey, key " 📋")
        this.GuiControl(, (id = "Master") ? this.EditMasterTranslation : this.EditCurrentTranslation, value)
        Gui, Submit, NoHide
    }

    /*
        Style on modifications
    */

/*
    GuiControlGet, title, , Text%id%TranslationTitle
    Gui, Font, Italic s14
    GuiControl, Font, Text%id%TranslationTitle
    GuiControl,, Text%id%TranslationTitle, %title%*
    Gui, Font, Normal
    _%id%Modifications := !_%id%Modifications
*/
/*
    HasModifications(id)
    {
        If (this[id "HasModifications"])
            return
        titleElement := this["Text" id "TranslationTitle"]
        title := titleElement.value
        Gui, Font, Italic s14
        this.GuiControl("Font", titleElement)
        this.GuiControl(, titleElement, title "*")
        Gui, Font, Normal
        this[id "HasModifications"] := True
    }
*/
    ToggleModifications(id, hasModifications)
    {
        If (this[id "HasModifications"] = hasModifications)
            return
        titleElement := this["Text" id "TranslationTitle"]
        title := titleElement.value
        Gui, Font, % hasModifications ? "Italic s14" : "Normal s14"
        this.GuiControl("Font", titleElement)
        this.GuiControl(, titleElement, hasModifications ? title "*" : StrReplace(title, "*"))
        Gui, Font, Normal
        this[id "HasModifications"] := !this[id "HasModifications"]
    }

    /*
        Menu & status bar
    */

    loadMenuBar()
    {
        ;File
        Menu, FileMenu, Add,                Reload`tCtrl+R,Reload
        Menu, FileMenu, Add,                Save current keys`tCtrl+S,SaveCurrentKeys
        Menu, FileMenu, Add,                Quit`tShift+F12, Quit
        Menu, MyMenuBar, Add,               File, :FileMenu

        ;About
        Menu, AboutMenu, Add,               Visit GitHub, VisitGitHub
        Menu, MyMenuBar, Add,               ?, :AboutMenu

        Gui, Menu,                          MyMenuBar
    }

    LoadStatusBar(){
        SB_SetParts(this.GUI_WIDTH/2,this.GUI_WIDTH/2)
        barPartId := 1
        textPartId := 2

        hwnd := SB_SetProgress(0, barPartId)

        this.StatusBarSetProgress(100)
        this.StatusBarSetText("Step: 0/0")
    }

    StatusBarSetProgress(step, totalSteps := 0) {
        If (totalSteps = 0)
            SB_SetProgress(step)
        Else
        {
            progress := (step = totalSteps) ? 100 : step * Round(100 / totalSteps)
            SB_SetProgress(progress)
        }
    }

    StatusBarSetText(value) {
        SB_SetText(value, 2)
    }

    /* 
        EVENTS
    */

    ; OnChanged

    EditMasterTranslation_OnChanged(){
        Gui, Submit, NoHide
        this.ToggleModifications("Master", True)
        Sleep 3000
        this.ToggleModifications("Master", False)
    }

    EditCurrentTranslation_OnChanged(){
        Gui, Submit, NoHide
        this.ToggleModifications("Current", True)
    }

    ; OnClick

    BtnSaveMaster_OnClick() {
        this.Controller.BtnSave_Listener("Master")
    }
    BtnSaveCurrent_OnClick() {
        this.Controller.BtnSave_Listener("Current")
    }

    addListener(Controller)
    {
        this.Controller := Controller
    }
    
}