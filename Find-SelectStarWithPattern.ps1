#Find references to select * in views/stored procs/functions
function Find-SelectStarWithPattern
{
    
    [CmdletBinding()]
    param(
        $TSQLFragmentForRule
    )

    Try
    {
        class VisitorSelectStar: Microsoft.SqlServer.TransactSql.ScriptDom.TSqlConcreteFragmentVisitor 
        {
            [void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.SelectStarExpression] $fragment) 
            {

                $errorline = "WARNING: 'SELECT * found at "
                write-host $errorline $fragment.StartLine ":" $fragment.StartColumn ":" $fragment.FragmentLength -BackgroundColor red

            }
    
        }
        
      	$visitorselectstar = [VisitorSelectStar]::new()
        $tSqlFragmentforrule.Accept($visitorselectstar)
       
    
   } #end try
catch {
    throw
}

}