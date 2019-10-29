/*
    Class Model
*/

class Model
{    
    PathIniSettings := "helper-settings.ini"
    NbKeys := 0
    
    SaveTranslationKey(id, index, value)
    {
        obj := this[id "Translation"] ; LanguageDataList[currentKey].Value

        obj.LanguageDataList[index].Value := value

        ;Ini write
        value := StrSplit(value, "`n")
        msgbox, % value[1]
        this.DeleteKey(obj.file, obj.LanguageDataList[index].Key)
        IniWrite, % value[1], % obj.file, Strings, % obj.LanguageDataList[index].Key
        
        ;Write multiline
        i := 2
        Loop {
            If !value[i]
                break
            IniWrite, % value[i], % obj.file, Strings, % obj.LanguageDataList[index].Key . i
            i++
        }
    }

    DeleteKey(filename, keyName)
    {
        IniDelete, %filename%, Strings, %keyName%
        ;Multiline
        i := 2
        Loop {
            IniRead, output, %filename%, Strings, %keyName%%i%, %A_Space%
            If !output
                break
            IniDelete, %filename%, Strings, %keyName%%i%
            i++
        }
    }

    Commands := []

    __New(){
        this.Commands := []
        this.GetSettingsFromIni()
        this.ParseSourceCode()
        this.NbKeys := this.MasterTranslation.LanguageDataList.MaxIndex()
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
                    this.Commands := []
                    this.ParseLine(A_LoopReadLine)
                    Loop % this.Commands.MaxIndex()
                    {
                        currentKeyName := this.Commands[A_Index].Key
                        If this.MasterTranslation.IsAlreadyInList(currentKeyName)
                            break
                        this.MasterTranslation.AddNewLanguageData(i, currentKeyName, this.RetrieveTranslation(this.MasterTranslation.File, currentKeyName))
                        this.CurrentTranslation.AddNewLanguageData(i, currentKeyName, this.RetrieveTranslation(this.CurrentTranslation.File, currentKeyName))
                        i++
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

    ; Get translation from INI
    RetrieveTranslation(filename, key)
    {
        IniRead, readValue, %filename%, Strings, %key%, %A_Space%
        ;Check for multiline message
        translationValue := readValue
        i := 2
        Loop {
            IniRead, readValue, %filename%, Strings, %key%%i%, %A_Space%
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
        LanguageDataList := []

        GetKey(index) {
            return this.LanguageDataList[index].Key
        }

        GetValue(index) {
            return this.LanguageDataList[index].Value
        }

        __New(File := "") 
        {
            this.File := File
            this.LanguageDataList := []
        }

        DebugPrint()
        {
            i := 1
            Loop, % this.LanguageDataList.MaxIndex()
                MsgBox, % "Value for " this.LanguageDataList[A_Index].Key " is " this.LanguageDataList[A_Index].Value
        }

        AddNewLanguageData(index, key, value){
            this.LanguageDataList[index] := New this.LanguageData(key, value)
        }

        IsAlreadyInList(currentKey)
        {
            Loop, % this.LanguageDataList.MaxIndex()
                If (this.LanguageDataList[A_Index].Key = currentKey)
                    return True
            return False
        }

        Class LanguageData ; contains data for a key and it's corresponding value
        {
            Key := ""
            Value := ""

            __New(key, value){
                this.Key := key
                this.Value := value
            }
        }
    }
}

;To be revised
;To be moved inside model
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