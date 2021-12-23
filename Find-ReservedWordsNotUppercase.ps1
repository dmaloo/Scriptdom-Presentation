#Find reserved words not upper cased (any script)
function Find-ReservedWordsNotUppercase
{
    
    #Defining parameter for scriptname
    #scriptdata is string variable containing the script to be parsed and run rules against
    [CmdletBinding()]
    param(
           
           $parsedobjects
          
    )

# Get the location of Scriptdom.dll
	
    
    Try
    {
    $nonreservedwords = 'Integer','MultiLineComment','SingleLineComment','MultiLineComment','Identifier','Variable','AsciiStringLiteral','WhiteSpace','Semicolon','EndofFile','Dot','QuotedIdentifier','EqualsSign','Comma','RightParenthesis','LeftParenthesis' 

    foreach ($token in $parsedobjects.ScriptTokenStream)
    {
        $rword = $token.text
        if ($nonreservedwords -contains $token.tokentype) 
        {
            
            
        }
        else
        {
            if ($rword -ceq $rword.Toupper())
            {
            }
            else
            {
                $startline = $token.line
                $Startcol = $token.column
                $length = $rword.length
                $errorline = "WARNING: Reserved Word not in upper case '$rword' found at "
                write-host $errorline $token.Line ":" $token.Column -BackgroundColor red

                
            } #if rword
        }
    } #token
  
       
    } #try

catch {
    throw
    }

} 