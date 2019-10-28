class View extends CGui
{
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
        Controls 
    */

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