$ScriptData = @"
SELECT TOP(@MaximumRowsToReturn)
           p.PersonID,
           p.FullName,
           p.PreferredName,
           CASE WHEN p.IsSalesperson <> 0 THEN N'Salesperson'
                WHEN p.IsEmployee <> 0 THEN N'Employee'
                WHEN c.CustomerID IS NOT NULL THEN N'Customer'
                WHEN sp.SupplierID IS NOT NULL THEN N'Supplier'
                WHEN sa.SupplierID IS NOT NULL THEN N'Supplier'
           END AS Relationship,
           COALESCE(c.CustomerName, sp.SupplierName, sa.SupplierName, N'WWI') AS Company
    FROM [Application].People AS p
    LEFT OUTER JOIN Sales.Customers (NOLOCK) AS c
    ON c.PrimaryContactPersonID = p.PersonID
    LEFT OUTER JOIN Purchasing.Suppliers (NOLOCK) AS sp
    ON sp.PrimaryContactPersonID = p.PersonID
    LEFT OUTER JOIN Purchasing.Suppliers AS sa
    ON sa.AlternateContactPersonID = p.PersonID
    WHERE p.SearchName LIKE N'%' + @SearchText + N'%'
    ORDER BY p.FullName
    FOR JSON AUTO, ROOT(N'People');


"@

Add-Type -Path "C:\ugpresentation\ScriptDom\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
Write-Host "Attempting to parse..." 
try {
    $parser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser($true)
    #object to handle parsing errors if any
    $parseErrors = New-Object System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]
    #object that handles strings script to parse
    $stringReader = New-Object System.IO.StringReader($ScriptData)

    #parser creates parsed objects from strings 
    $parsedObjects = $parser.Parse($stringReader, [ref]$parseErrors)

    $stmtcount = $parsedObjects.batches[0].statements.statementlist.statements.count

    for ( $index = 0; $index -lt $stmtcount; $index++)
    {
       $stmtype = $parsedobjects.batches[0].statements.StatementList.Statements[$index].GetType().name

       WRITE-HOST 'Statement type: ' $stmtype
    }
    

    # Table references
    #from clause
    write-host 'TABLES' 
    $tablereference = $parsedObjects.batches[0].statements.QueryExpression.FromClause.TableReferences
  
    Find-SelectTableRecursion $TableReference 1
    
    #where clause
    $whereclausetype = $parsedObjects.batches[0].statements.QueryExpression.WhereClause.SearchCondition.GetType().name
    if ($whereclausetype -eq $null)
    {
    }
    else
    {
     write-host 'Where clause is of type: ' $whereclausetype -ForegroundColor yellow
     $whereclause = $parsedObjects.batches[0].statements.QueryExpression.WhereClause
     #Find-SelectWhereRecursion $whereclause, 1
    }
        

    #orderby clause
    $orderbyclausecount = $parsedObjects.batches[0].statements.QueryExpression.OrderByClause.OrderByElements.Count
    if ($orderbyclausecount -gt 0)
    {
     write-host 'Order by clause has : ' $orderbyclausecount -ForegroundColor Yellow
    }

    
    #groupby clause
    $groupbyclausecount = $parsedObjects.batches[0].statements.QueryExpression.GroupByClause.GroupingSpecifications.count
    if ($groupbyclausecount -gt 0)
    {
     write-host 'Group by clause has : ' $groupbyclausecount -ForegroundColor Yellow
    }

    $havingclausetype = $parsedObjects.batches[0].statements.QueryExpression.havingClause
    if ($havingclausetype -eq $null)
    {
    }
    else
    {
     write-host 'having clause is of type: ' $havingclausetype -ForegroundColor Gray
    }
       

    if($parseErrors.Count -gt 0) {
        throw "$($parseErrors.Count) parsing error(s): $(($parseErrors | ConvertTo-Json))"
    }
    Write-Host "Complete!" -ForegroundColor Green
}
catch {
    throw
}

