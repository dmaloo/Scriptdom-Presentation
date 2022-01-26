function Find-LintingErrors
{
    
        #selectstatement contains the statement to be examined for existence of select *
    [CmdletBinding()]
    param(
          [string] $SelectStatement
    )
    
    try {

    Add-Type -Path "C:\ugpresentation\ScriptDom\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
    
    $DDLParser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser($true)
    $DDLparserErrors = New-Object System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]
    # create a StringReader for the script for parsing
    $stringReader = New-Object System.IO.StringReader($selectstatement)

    # parse the script
    $tSqlFragment = $DDLParser.Parse($stringReader, [ref]$DDLParsererrors)

    # raise an exception if any parsing errors occur
    if($DDLParsererrors.Count -gt 0) {
        throw "$($DDLParsererrors.Count) parsing error(s): $(($DDLParsererrors | ConvertTo-Json))"
    }

   #Find-NoLockHintWithPattern $tSqlFragment
   #Find-4PartNameWithPattern $tSqlFragment
   #Find-SelectStarWithPattern $tSqlFragment

   #Find-ReservedWordsNotUppercase $tSqlFragment
   Find-FixNoLockHint $tSqlFragment
}
catch {
    throw
}

}
