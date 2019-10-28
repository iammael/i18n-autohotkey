/*
    Main Program
*/

#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
StringCaseSense On

#SingleInstance Force

progObj := new Program()
progObj.main()
return

#Include lib\CGui.ahk
#Include src\Models\MainModel.ahk
#Include src\Controllers\MainController.ahk
#Include src\Views\MainView.ahk

class Program
{
    main()
    {
        SetWorkingDir,% A_ScriptDir
        this.view := new View()
        this.model := new Model()
        this.controller := new Controller(this.model, this.view)
        this.view.showGui()
    }
}