class View extends CGui
{
    __New(aParams*){
		global BorderState

        this.title := "Translation Helper v1.0.0"
		
		base.__New(aParams*)
        this.GUI_WIDTH := 1200
        this.GUI_HEIGHT := 800
	}

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
        this.SliderKey :=                   this.Gui("Add", "Slider", "x+10", 1)
        this.BtnNextKey :=                  this.Gui("Add", "Picture", "x+10", "resources\arrow-next.png")
        Gui, Font,                          Bold
        this.TextMasterTranslationKey :=    this.Gui("Add", "Text", "xm y+10 Center w" this.GUI_WIDTH, "No translation key found")
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

        this.GuiControl("+g", this.BtnSaveMaster, this.BtnSaveMaster_OnClick)
        this.GuiControl("+g", this.BtnSaveCurrent, this.BtnSaveCurrent_OnClick)
    }

    BtnSaveMaster_OnClick() {
        this.controller.BtnSave_Listener("Master")
    }
    BtnSaveCurrent_OnClick() {
        this.controller.BtnSave_Listener("Current")
    }

    showGui()
    {
        this.loadMenuBar()
        this.loadTitle()
        this.loadControls()
        this.Show(, this.title)
    }


    
    addListener(controller)
    {
        this.controller := Controller
    }
    
}