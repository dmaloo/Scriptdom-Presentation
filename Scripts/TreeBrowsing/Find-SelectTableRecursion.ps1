function Find-SelectTableRecursion 
{
    
    #Defining parameter for scriptname
    #scriptdata is string variable containing the script to be parsed and run rules against
    [CmdletBinding()]
    param(
           $TableReference,
           [int] $TableIteration
    )

$TableReference
    
    $join = $tablereference.QualifiedJoinType

    if ($tablereference.firsttablereference -eq $isnull)
        {
           #One table query
           $tablename = $tablereference.schemaobject.BaseIdentifier.value
           $alias =  $tablereference.alias.value
           $hint = $tablereference.tablehints.HintKind
           $hintindex = $tablereferences.TableHints.indexvalues.Value

           If ($alias -ne $null)
            {
            $alias = '  ALIAS: ' + $alias
            }

            If ($hint -ne $null)
            {
            $hint = '  hint: ' + $alias
            }

           write-host $tablename $alias $hint $hintindex $TableReference.startline $TableReference.startcolumn $TableReference.fragmentlength -ForegroundColor darkYellow
           
        }
   

    while($join -ne $null)
    {
        $ctr++
        
        #$ctr
        #$tablereference.gettype().name
        $firsttablename = $null
        $firsttablealias = $null
        $firsttablehint = $null
        
        $secondtablename = $null
        $secondtablealias = $null
        $secondtablehint = $null
        
        $firsttablename = $tablereference.firsttablereference.Schemaobject.BaseIdentifier.value
        $firsttablealias = $tablereference.firsttablereference.Alias.value
        $firsttablehint = $tablereference.firsttablereference.tablehints.HintKind
        $firsthintindex = $tablereference.firsttablereference.TableHints.indexvalues.Value
        #$tablereference.firsttablereference.gettype()

        $secondtablename =  $tablereference.secondtablereference.Schemaobject.BaseIdentifier.value
        $secondtablealias = $tablereference.secondtablereference.Alias.value
        $secondtablehint =  $tablereference.secondtablereference.tablehints.HintKind
        $secondhintindex = $tablereference.secondtablereference.TableHints.indexvalues.Value
        #$tablereference.secondtablereference.gettype()
         
        if ($firsttablename -ne $null)
        {
            write-host 'Table' $firsttablename
            IF ($firsttablealias -ne $null)
            {
            write-host '  Alias' $firsttablealias
            }
            else
            {
            write-host 'NO ALIAS FOUND'
            }
            IF ($firsttablehint -ne $null)
            {
            write-host '  Hint found' $firsttablehint at $TableReference.startcolumn $TableReference.fragmentlength -ForegroundColor Red
            }
            IF ($firsthintindex -ne $null)
            {
            write-host '  Hint Index found' $firsthintindex 
            }

        }

        if ($secondtablename -ne $null)
        {

            write-host 'Table' $secondtablename
            IF ($secondtablealias -ne $null)
            {
            write-host '  Alias' $secondtablealias
            }
            else
            {
            write-host 'NO ALIAS FOUND'
            }

            IF ($secondtablehint -ne $null)
            {
            write-host '  Hint found' $secondtablehint at $TableReference.startcolumn $TableReference.fragmentlength -ForegroundColor red
            }
            IF ($secondhintindex -ne $null)
            {
            write-host '  Hint index found' $secondhintindex 
            }

        }
        
        if ($tablereference.secondtablereference.gettype().name -eq 'QueryDerivedTable')
        { $derivedtablereference = $tablereference.secondtablereference.QueryExpression.FromClause.TableReferences
         write-host 'Derived table found!'
         #write-host $derivedtablereference
          Find-SelectTableRecursion $derivedTableReference, 10
        }    
        
        $tablereference = $tablereference.firsttablereference
        $join = $tablereference.QualifiedJoinType
 
    } 


    }
