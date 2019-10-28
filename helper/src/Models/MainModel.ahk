/*
    Class Model
*/

class Model
{    
    PathIniSettings := "helper-settings.ini"
    NbKeys := 0
    
    SaveTranslationKey(id)
    {
        MsgBox, % "Model :)! Id=" id
    }

    Commands := []

    __New(){
        this.Commands := []
        this.GetSettingsFromIni()
        this.ParseSourceCode()
        this.NbKeys := this.MasterTranslation.LanguageData.MaxIndex()
    }

    GetSettingsFromIni()
    {
        IniRead, SourcesFolder, % this.PathIniSettings, Path, Sources
        IniRead, TranslationsFolder, % this.PathIniSettings, Path, Translations
        IniRead, DefaultMaster, % this.PathIniSettings, DefaultLanguage, Master
        IniRead, DefaultCurrent, % this.PathIniSettings, DefaultLanguage, Current
        IniRead, ExcludeStr, %PathIniSettings%, Path, Exclude, A_Space

        this.SourcesFolder := SourcesFolder
        this.TranslationsFolder := TranslationsFolder
        this.DefaultMaster := DefaultMaster
        this.DefaultCurrent := DefaultCurrent
        this.ExcludeStr := ExcludeStr

        this.MasterTranslation := New Model.Translation(this.TranslationsFolder DefaultMaster ".ini")
        this.CurrentTranslation := New Model.Translation(this.TranslationsFolder DefaultCurrent ".ini")
    }

    ParseSourceCode()
    {
        i := 1
        excludeList := StrSplit(this.ExcludeStr, ",")
        Loop Files, % this.SourcesFolder "*.ahk", R
        {
            Loop % excludeList.MaxIndex()
                If (InStr(A_LoopFileFullPath, excludeList[A_Index]))
                    isExcluded := True
            If !isExcluded
                Loop, Read, %A_LoopFileFullPath%
                {
                    this.ParseLine(A_LoopReadLine)
                    Loop % this.Commands.MaxIndex()
                    {
                        currentKey := this.Commands[A_Index].Key
                        If this.MasterTranslation.IsAlreadyInList(currentKey)
                            break
                        this.MasterTranslation.LanguageData[i] := Object(currentKey, this.RetrieveTranslation(this.MasterTranslation, currentKey))
                        this.CurrentTranslation.LanguageData[i++] := Object(currentKey, this.RetrieveTranslation(this.CurrentTranslation, currentKey))
                    }
                }   
        }
        return
    }

    ParseLine(line){
        index := 1
        pos := 1
        Loop
        {
            If ((pos := InStr(line, "Translate(", , pos)) = 0)
                break
            Else
            {
                cmd := New Command(line)
                this.ParseCall(cmd, pos)
                cmd.Key := StrSplit(cmd.Call, """")[2]
                this.Commands[index] := cmd
                pos++
                index++
            }
        }
    }

    ;To be revised (bug in todolist)
    ParseCall(ByRef cmd, pos)
    {
        openingBrackets := 0
        closingBrackets := 0
        Loop, Parse, % cmd.fullLine
        {
            If (A_Index < pos)  ; Skip until call
                Continue
            Switch A_LoopField
            {
                Case "(":
                    openingBrackets++
                Case ")":
                    closingBrackets++
            }
            cmd.Call := A_LoopField
            If (openingBrackets > 1 && openingBrackets = closingBrackets)
                break
        }
    }

    ;To be revised
    RetrieveTranslation(Byref obj, key)
    {
        IniRead, readValue, % obj.file, Strings, %key%, %A_Space%

        ;Check for multiline message
        translationValue := readValue
        i := 2
        Loop {
            IniRead, readValue, % obj.file, Strings, %key%%i%, %A_Space%
            If !readValue
                return translationValue
            Else
                translationValue := translationValue . "`n" . readValue
            i++
            
        }
        return translationValue
    }

    Class Translation 
    {
        File := ""
        LanguageData := [] ;contains keys and values of a translation

        __New(File := "") 
        {
            this.File := File
        }

        DebugPrint()
        {
            i := 1
            Loop % this.LanguageData.MaxIndex()
                For key, value in this.LanguageData[A_Index]
                    msgbox % this.LanguageData[i++][key]
        }

        IsAlreadyInList(currentKey)
        {
            Loop, % this.LanguageData.MaxIndex()
                For key, value in this.LanguageData[A_Index]
                    If (key = currentKey)
                        return True
            return False
        }
    }
}

;To be revised
Class Command {
    FullLine := ""
    Args := []
    Key := ""

    __New(fullLine){
        this.FullLine := fullLine
    }

    Call {
        get { 
            return this.stored_call
        }
        set { 
            return this.stored_call := this.stored_call . value ;char by char
        }
    }
}