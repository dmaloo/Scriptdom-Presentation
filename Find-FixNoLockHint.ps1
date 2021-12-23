
#Find reserved words not upper cased (any script)
function Find-FixNoLockHint
{
    
    #Defining parameter for scriptname
    #scriptdata is string variable containing the script to be parsed and run rules against
    [CmdletBinding()]
    param(
           
           $tsqlfragmentforrule
          
    )
 

try {   



    class VisitorTableRef: Microsoft.SqlServer.TransactSql.ScriptDom.TSqlConcreteFragmentVisitor

    {                    

        [void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.NamedTableReference] $fragment)

        {

                foreach ($hint in $fragment.TableHints)
                {

                    if ($hint.HintKind -eq [Microsoft.SqlServer.TransactSql.ScriptDom.TableHintKind]::NoLock) 
                    {

                            write-host "Found a NOLOCK hint; removing"

                            $fragment.TableHints.Remove($hint)

                            break;

                    }

               }

        }   

    }

     
    $generator = [Microsoft.SqlServer.TransactSql.ScriptDom.Sql150ScriptGenerator]::New();

    $generate =     [Microsoft.SqlServer.TransactSql.ScriptDom.Sql150ScriptGenerator]($generator)

    $myvisitor = [VisitorTableRef]::new()

    $tSqlFragment.Accept($myvisitor)

    $modifiedtsqlfragment = $tSqlFragment
    $formattedoutput1 = ''


    $generate.GenerateScript($modifiedtsqlfragment,([ref]$formattedoutput1))

 

    write-host $formattedoutput1 -BackgroundColor blue

}   

catch {

    throw

}

} 