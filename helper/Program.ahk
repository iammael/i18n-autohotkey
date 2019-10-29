/*
    Main Program
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
StringCaseSense On

#SingleInstance Force

Prog := new Program()
Prog.Main()
return

#Include lib\CGui.ahk
#Include lib\SB.ahk
#Include src\Models\MainModel.ahk
#Include src\Controllers\MainController.ahk
#Include src\Views\MainView.ahk

class Program
{
    Initialize()
    {
        SetWorkingDir,% A_ScriptDir
		this.View := new View()
		this.Model := new Model()
		this.Controller := new Controller(this.Model, this.View)
		this.View.showGui()
    }
	
	Main()
	{
        this.Initialize()

        If (this.Model.MasterTranslation.LanguageData.MaxIndex() > 0)
            this.Controller.CurrentKey := 1
        Else
            MsgBox, Didn't find any translation calls in source code.
	}
}