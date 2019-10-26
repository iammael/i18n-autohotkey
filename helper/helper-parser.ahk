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
    
    Class Command
        Properties:
            String FullLine -> Contains full line of code matching a Translate call
            String Call -> Contains the whole Translate call
            String Key -> Contains the key for INI translation
            Array Args -> Contains the arguments parameter
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
        /*i := 1
        Loop % this.Commands.MaxIndex()
        {
            For key, value in this.Commands[A_Index]
                MsgBox,, % key " #" i, % value
            i++
        }
        */
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