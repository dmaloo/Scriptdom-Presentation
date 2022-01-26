function Find-TableReferenceRecursion 
{
    
    #Defining parameter for scriptname
    #scriptdata is string variable containing the script to be parsed and run rules against
    [CmdletBinding()]
    param(
           $TableReference,
           [int] $TableIteration
    )

    
    
    if ($tablereference.firsttablereference -eq $isnull)
        {
           #One table query
           $tablename = $tablereference.schemaobject.BaseIdentifier.value
           $alias =  $tablereference.alias.value
           $hint = $tablereference.tablehints.HintKind
           write-host $tablename
           write-host $alias
           write-host $hint
        }
    else
    {
    if ($tablereference.firsttablereference.gettype().name -eq 'NamedTableReference')
    
    {
        $firsttablename = $parsedObjects.batches[0].statements.statementlist.Statements[0].QueryExpression.FromClause.TableReferences.FirstTableReference.Schemaobject.BaseIdentifier.value
    

        if ($tablereference.secondtablereference.gettype().name -eq 'NamedTableReference')
        {
            $secondtablename = $parsedObjects.batches[0].statements.statementlist.Statements[0].QueryExpression.FromClause.TableReferences.SecondTableReference.Schemaobject.BaseIdentifier.value
        }
        write-host  $firsttablename
        write-host  $secondtablename
    }
    if ($tablereference.firsttablereference.gettype().name -eq 'QueryDerivedTable')
    {
                write-host 'In Query Derived Table 1'
    }
    if ($tablereference.secondtablereference.gettype().name -eq 'QueryDerivedTable')
    {
                write-host 'In Query Derived Table 2'
    }


    #if ($secondtablename -eq $null)
    #{
        $ctr =0
    #}
    #else
    #{
    $ctr = 1
    #}

    while($ctr -gt 0)
    {
        $ctr++
        
        $ctr
        $tablereference.gettype().name
        $firsttablename = $tablereference.firsttablereference.Schemaobject.BaseIdentifier.value
        $secondtablename =  $tablereference.secondtablereference.Schemaobject.BaseIdentifier.value
         
        if ($firsttablename -ne $null)
        {
            write-host '1' $firsttablename
        }

        if ($secondtablename -ne $null)
        {

            write-host  '2' $secondtablename
        }
        $tablereference = $tablereference.firsttablereference
        $join = $tablereference.QualifiedJoinType
        $join
        If ($join -eq $null) 
        {
           
            $ctr = 0
        }
        
    } 

  } #else for single table
}