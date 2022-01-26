#Find no lock hint in views/stored procs/functions
function Find-NoLockHintWithPattern
{
    [CmdletBinding()]
    param(
           $tsqlfragmentforrule
    )

    Try
    {
         class VisitorTableHintRef: Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragmentVisitor {
        
         [void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.TableHint] $fragment) {
            
            $tablehint = $fragment
            if ($tablehint.HintKind -eq 'Nolock')
            {
                $errorline = "WARNING: NOLOCK hint found at "
                write-host $errorline $fragment.StartLine ":" $fragment.StartColumn ":" $fragment.FragmentLength -BackgroundColor Red


            }
        }
    
     }
     
        $visitortablehintref = [VisitorTableHintRef]::new()
        $tSqlFragmentforrule.Accept($visitortablehintref)
        
} 
catch {
    throw
}

}