<#  
.SYNOPSIS  
    Format-TSQL will format tsql script supplied per options set
.DESCRIPTION  
    This script will strip supplied code of comments format per options
.NOTES  
    Author     : Mala Mahadevan (malathi.mahadevan@gmail.com)
  
.PARAMETERS
-InputScript: text file containing T-SQL
    -OutputScript: name of text file to be generated as output
.LIMITATIONS
Strips code of comments
.LINK  
    

.HISTORY
2021.08.08First version for sqlservercentral.com
#>
function Format-TSQL
{
   
    #Defining parameter for scriptname
    [CmdletBinding()]
    param(
           [System.IO.FileInfo[]]$InputScript,
           [String]$OutputScript
    )
    If ((Test-Path $InputScript -PathType Leaf) -eq $false)
    {
        $errormessage = "File $InputScript not found!"
        throw $errormessage
    }
    If ((Test-Path $OutputScript -IsValid) -eq $false)
    {
        $errormessage = "Path for $Outputscript not found!"
        throw $errormessage
    }
    #This may need to be modified to wherever the dll resides on your machine
    Add-Type -Path "C:\ugpresentation\ScriptDom\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
    $generator = [Microsoft.SqlServer.TransactSql.ScriptDom.Sql150ScriptGenerator]::New();
    #Include semi colons at end of every statement
    $generator.Options.IncludeSemicolons = $true
    #Aligns body inside of  blocks
    $generator.Options.AlignClauseBodies = $true
    #Aligns all column definitions for create view/table
    $generator.Options.AlignColumnDefinitionFields = $true
    #Aligns set statements
    $generator.Options.AlignSetClauseItem = $true
    #create or alter 'as' will be on its own line
    $generator.Options.AsKeywordOnOwnLine = $true
    #Define indentation - only spaces
    $generator.Options.IndentationSize = 10
    #Indent set clauses
    $generator.Options.IndentSetClause = $true
    #Indent body of view
    $generator.Options.IndentViewBody = $true
    #Set keyword casing
    $generator.Options.KeywordCasing =  1 #0 lower case 1 upper case 2 pascal case
    #Seperate each column on insert source statement to its own line
    $generator.Options.MultilineInsertSourcesList = $true
    #Seperate each column on insert target statement to its own line
    $generator.Options.MultilineInsertTargetsList = $true
    #Seperate each column on select statement to its own line
    $generator.Options.MultilineSelectElementsList = $true
    #Separate each item on set clause to its own line
    $generator.Options.MultilineSetClauseItems = $true
    #Separate each column on view to its own line
    $generator.Options.MultilineViewColumnsList = $true
    #Separate each line on where predicate to its own line
    $generator.Options.MultilineWherePredicatesList = $true
    #Insert a new line before ( on multi line list of columns
    $generator.Options.NewLineBeforeCloseParenthesisInMultilineList = $true
    #Insert a new line before from clause
    $generator.Options.NewLineBeforeFromClause = $true
    #Insert a new line before group by clause
    $generator.Options.NewLineBeforeGroupByClause = $true
    #Insert a new line before having clause
    $generator.Options.NewLineBeforeHavingClause = $true
    #Insert a new line before join
    $generator.Options.NewLineBeforeJoinClause = $true
    #Insert a new line before offset clause
    $generator.Options.NewLineBeforeOffsetClause = $true
    #Insert a new line before ) on multi line list of columns
    $generator.Options.NewLineBeforeOpenParenthesisInMultilineList = $true
    #Insert a new line before order by
    $generator.Options.NewLineBeforeOrderByClause = $true
    #Insert a new line before output clause
    $generator.Options.NewLineBeforeOutputClause = $true
    #Insert a new line before where clause
    $generator.Options.NewLineBeforeWhereClause = $true
    #Recognize syntax specific to engine type - to be safe use 0
    $generator.Options.SqlEngineType = 0 # 0 All 1 Engine 2 Azure
    #Version used 
    #1002
    #1103
    #1204
    #1305
    #1406 
    #1507
    #80    1
    #90    0 (default)
    $generator.Options.SqlVersion = 7
    #Read the string passed in
    $stringreader = New-Object -TypeName System.IO.StreamReader -ArgumentList $InputScript
   
    #Create generate object
    $generate =     [Microsoft.SqlServer.TransactSql.ScriptDom.Sql150ScriptGenerator]($generator)
    #Parse the string for errors and create tsqlfragment for formatting
    $parser = [Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser]($true)::New();
    
    if($parser -eq $null){
    throw 'ScriptDOM not installed or not accessible'
    }
    $parseerrors = $null
    $fragment = $parser.Parse($stringreader,([ref]$parseerrors))
    # raise an exception if any parsing errors occur
    if($parseerrors.Count -gt 0) {
        throw "$($parseErrors.Count) parsing error(s): $(($parseErrors | ConvertTo-Json))"
    } 
    $formattedoutput = ''
    #Format the string
    $generate.GenerateScript($fragment,([ref]$formattedoutput)) 
    write-host $formattedoutput -BackgroundColor blue
    $formattedoutput.ToString() | Out-File $OutputScript
        
}


format-tsql 'c:\ugpresentation\unformattedproc.sql' 'c:\ugpresentation\formattedproc.sql'
