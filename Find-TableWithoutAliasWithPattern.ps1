#Find table references without alias
function Find-TableWithoutAliasWithPattern
{
    
    [CmdletBinding()]
    param(
           $Tsqlfragmentforrule
    )

    Try
    {
           
         #Using join table instead of  tableref to avoid error on single table queries
         class VisitorJoinTAble: Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragmentVisitor 
         {
             [void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.Jointablereference] $fragment) 
             {
            
                $table1alias = $fragment.firsttablereference.alias.value
                $table1 = $fragment.firsttablereference.schemaobject.baseidentifier.value
                if ($table1alias -eq $NULL)
                {
                    $errorline = "WARNING: Table $($Table1) without Alias found "
                    write-host $errorline $fragment.StartLine ":" $fragment.StartColumn ":" $fragment.FragmentLength -backgroundColor Red
                }

                $table2alias = $fragment.secondtablereference.alias.value
                $table2 = $fragment.secondtablereference.schemaobject.baseidentifier.value
                if ($table2alias -eq $NULL)
                {
                    $errorline = "WARNING: Table $($Table2) without Alias found "
                    write-host $errorline $fragment.StartLine ":" $fragment.StartColumn ":" $fragment.FragmentLength -backgroundColor Red
                }
                 
        }
    
    }
      	
        $VisitorJoinTable = [VisitorJoinTable]::new()
        $TSqlFragmentforrule.Accept($visitorjointable)

        
} #end try
catch {
    throw
}

}