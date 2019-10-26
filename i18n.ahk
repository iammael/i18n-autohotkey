/*
    i18n
*/

Class i18n {
    __New(LanguageFolder, LanguageFile, DevMode := False)
    {
        this.LanguageFolder := LanguageFolder
        this.LanguageFile := LanguageFolder "\" LanguageFile ".ini"
        this.DevMode := DevMode
        If !FileExist(this.LanguageFile)
        {
            MsgBox, 16, Fatal Error, % "Couldn't load language file '" this.LanguageFile "'. Program aborted."
            ExitApp -1
        }
    }
}

Translate(key, args := 0)
{
    translatedText := TranslateX(key, i18nService.LanguageFile)
    ;Deal with error
    If !translatedText
    {
        If i18nService.DevMode {
            Loop {
                If translatedText
                    break
                MsgBox, % 16+2, Dev Mode, % "File " i18nService.LanguageFile " is missing string for key {" key "}.`nPress Ignore to continue anyway."
                IfMsgBox, Abort
                    ExitApp
                IfMsgBox, Retry
                    translatedText := TranslateX(key, languageFile)
                Else
                    return % "{" key "}"
            }
        }
        Else
            return % "{" key "}"
    }

    ;check and replace args ({1}, {2}, ...)
    If args
        Loop % args.MaxIndex()
            translatedText := TranslateReplaceArgs(translatedText, args[A_Index], A_Index)
    return translatedText
}

TranslateX(ByRef key, ByRef languageFile)
{
    IniRead, readValue, %languageFile%, Strings, %key%, %A_Space%
    
    If !readValue
        return readValue

    translatedText := readValue
    
    ;Check for multiline message (key2, key3 etc...)
    i := 2
    Loop {
        IniRead, readValue, %languageFile%, Strings, %key%%i%, %A_Space%
        If !readValue
            return translatedText
        Else
            translatedText := translatedText . "`n" . readValue
        i++
    }
}

TranslateReplaceArgs(textToParse, Byref var, ByRef index)
{
    If InStr(textToParse, "{" . index . "}")
        return StrReplace(textToParse, "{" . index . "}", var)
    return textToParse
}

/*
    Parser
*/

/*
    Class Parser
        Properties:
            Array       Commands        -> List of all commands for a line
        Methods:
            ParseLine   (String)        -> Fill the Commands array
            ParseCall   (Command, Int)  -> Fill the Call property of the current Commands iteration
*/

Class Parser {
    Commands := []

    __New(){
        this.Commands := []
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
}

/*
    Class Command
        Properties:
            String FullLine -> Contains full line of code matching a Translate call
            String Call -> Contains the whole Translate call
            String Key -> Contains the key for INI translation
            Array Args -> Contains the arguments parameter
*/

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
            return this.stored_call := this.stored_call . value
        }
    }
}