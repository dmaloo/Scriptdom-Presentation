#Find 4 part /linked server references in stored procedures/views/functions 
function Find-4PartNameWithPattern
{
    [CmdletBinding()]
    param(
           $TSqlfragmentforrule
    )

    Try
    {
       	class VisitorTableRef: Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragmentVisitor 
       	{
		
		[void]Visit ([Microsoft.SqlServer.TransactSql.ScriptDom.TableReferenceWithAlias] $fragment) 
		{
			$tablereference = $fragment
			$tablename = $tablereference.schemaobject.BaseIdentifier.value 
			$servername = $tablereference.schemaobject.ServerIdentifier.value
            
			if ($servername -eq $null)
			{
			}
			else
			{
				$errorline = "WARNING: Table $tablename with linked server $servername found"
				write-host $errorline $fragment.StartLine ":" $fragment.StartColumn ":" $fragment.FragmentLength -BackgroundColor red
                
                
                          
			}
		}
    
    	}
    
        $visitortableref = [VisitorTableRef]::new()
        $tSqlFragmentforrule.Accept($visitortableref)
       

} #end try
catch {
    throw
}

}