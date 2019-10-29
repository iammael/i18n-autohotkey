
Class SettingsView extends CGui 
{
    __New(aParams*){
        base.__New(aParams*)
        this.title := "Settings"
    }

    ShowGui()
    {
        this.LoadControls()
        this.AddControlsListeners()
        this.Show(, this.title)
    }

    LoadTitle()
    {
        Gui, Font, s16
        this.Gui("Add", "Text", "Center xm w" this.GUI_WIDTH, this.title)
        Gui, Font, s10
    }

    LoadControls() {
        ;PATHS
        this.Gui("Add", "GroupBox", "y+10 x10 h80 w500", "Paths")

        ;Sources
        this.Gui("Add", "Text", "ys+20 xs+10 w60", "Sources")
        this.EditPathSources := this.Gui("Add", "Edit", "x+10 w350")
        this.BtnBrowseSources := this.Gui("Add", "Button", "x+10 w50", "Browse")

        ;Translation
        this.Gui("Add", "Text", "y+10 xs+10 w60", "Translations")
        this.EditPathTranslations := this.Gui("Add", "Edit", "x+10 w350")
        this.BtnBrowseTranslations := this.Gui("Add", "Button", "x+10 w50", "Browse")

        ;TRANSLATIONS
        this.Gui("Add", "GroupBox", "y+10 x10 h100 w500", "Translations")

        ;Master
        this.Gui("Add","Text", "ys+100 xs+10 w60", "Master")
        this.SelectMasterTranslation := this.Gui("Add", "DropDownList", "x+10", "No translations files")
        this.BtnNewMaster := this.Gui("Add", "Button", "x+5", "New")
        this.BtnLoadMaster := this.Gui("Add", "Button", "x+5", "Load")

        ;Current
        this.Gui("Add","Text", "y+10 xs+10 w60", "Current")
        this.SelectCurrentTranslation := this.Gui("Add", "DropDownList", "x+10", "No translations files")
        this.BtnNewCurrent := this.Gui("Add", "Button", "x+5", "New")
        this.BtnLoadCurrent := this.Gui("Add", "Button", "x+5", "Load")

        ;Default
        this.CheckDefault := this.Gui("Add", "Checkbox", "y+10 xs+10", "Save as default")

        ;BUTTONS
        Gui, Font, s10
        this.BtnApply := this.Gui("Add", "Button", "y+20 w80", "Apply")
        this.BtnCancel := this.Gui("Add", "Button", "x+5 w80", "Cancel")
        Gui, Font, Normal

    }

    AddControlsListeners() {
        this.GuiControl("+g", this.BtnBrowseSources, this.BtnBrowseSources_OnClick)
        this.GuiControl("+g", this.BtnBrowseTranslations, this.BtnBrowseTranslations_OnClick)
    }

    BtnBrowseSources_OnClick() {
        this._parent.Controller.BrowseSources()
    }

    BtnBrowseTranslations_OnClick() {
        this._parent.Controller.BrowseTranslations()
    }
}