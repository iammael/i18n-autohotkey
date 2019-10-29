class View extends CGui
{
    #Include src\Views\SettingsView.ahk

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

        this.BtnPreviousKey :=              this.Gui("Add", "Button", "x" this.GUI_WIDTH / 2.3, "←")
        this.SliderKey :=                   this.Gui("Add", "Slider", "x+10", 0)
        this.BtnNextKey :=                  this.Gui("Add", "Button", "x+10", "→")
        Gui, Font,                          Bold
        this.TextKeyName :=              this.Gui("Add", "Text", "xm y+10 Center w" this.GUI_WIDTH, "No translation key found")
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
        this.GuiControl("+g", this.EditMasterTranslation, this.EditMasterTranslation_OnChange)
        this.GuiControl("+g", this.EditCurrentTranslation, this.EditCurrentTranslation_OnChange)

        ;Update current key
        this.GuiControl("+g", this.SliderKey, this.SliderKey_OnChange)     
        this.GuiControl("+g", this.BtnPreviousKey, this.BtnPreviousKey_OnClick)
        this.GuiControl("+g", this.BtnNextKey, this.BtnNextKey_OnClick)

        ;Save
        this.GuiControl("+g", this.BtnSaveMaster, this.BtnSaveMaster_OnClick)
        this.GuiControl("+g", this.BtnSaveCurrent, this.BtnSaveCurrent_OnClick)
    }

    OpenSettingsView(){
        this.SettingsView := new this.SettingsView(this, "+Border +ToolWindow +AlwaysOnTop")
		this.SettingsView.ShowGui()
    }

    SetTextKeyNameContent(key) {
        this.GuiControl("Text", this.TextKeyName, key " 📋")
    }

    ;To be revised
    SetEditorContent(id, value)
    {            
        this.GuiControl(, (id = "Master") ? this.EditMasterTranslation : this.EditCurrentTranslation, value)
        Gui, Submit, NoHide
    }

    /*
        Style on modifications
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
        Menu, Tray, Icon,       resources\icon.ico, 1, 1

        ;File
        Menu, FileMenu, Add,                Save current keys`tCtrl+S, SaveCurrentKeys
        Menu, FileMenu, Add,                Previous Key`tCtrl+←, MenuPreviousKey
        Menu, FileMenu, Add,                Next Key`tCtrl+→, MenuNextKey
        Menu, FileMenu, Add,
        Menu, FileMenu, Add,                Settings...,MenuSettings
        Menu, FileMenu, Add,                Reload`tCtrl+R, Reload
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

    ChangeOnScreenKey(value) {
        If (this.CheckForModifications())
            return
        this.Controller.CurrentKey := value
        this.GuiControl(, this.SliderKey, this.Controller.CurrentKey)
        this.ToggleModifications("Master", False)
        this.ToggleModifications("Current", False)
    }

    /* 
        EVENTS
    */

    ; Navigation

    SliderKey_OnChange(){
        this.ChangeOnScreenKey(this.SliderKey.value)
    }

    BtnPreviousKey_OnClick() {
        this.ChangeOnScreenKey("-1")
    }

    BtnNextKey_OnClick() {
        this.ChangeOnScreenKey("+1")
    }

    ; OnChange to edit style on modifications

    EditMasterTranslation_OnChange(){
        Gui, Submit, NoHide
        this.ToggleModifications("Master", True)
    }

    EditCurrentTranslation_OnChange(){
        Gui, Submit, NoHide
        this.ToggleModifications("Current", True)
    }

    CheckForModifications()
    {
        If (this.MasterHasModifications || this.CurrentHasModifications)
        {
            MsgBox, % 49+4096, Alert, % "You have some unsaved edits for this key. Press Ok to discard them."
            IfMsgBox, Cancel
                Return True
        }
        Return False
    }

    ; Save

    BtnSaveMaster_OnClick() {
        this.Controller.BtnSave_Listener("Master", this.EditMasterTranslation.value)
    }
    BtnSaveCurrent_OnClick() {
        this.Controller.BtnSave_Listener("Current", this.EditCurrentTranslation.value)
    }

    addListener(Controller)
    {
        this.Controller := Controller
    }
}