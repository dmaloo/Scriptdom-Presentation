$ScriptData = @"
USE [WideWorldImporters]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [Website].[InsertCustomerOrders]
@Orders Website.OrderList READONLY,
@OrderLines Website.OrderLineList READONLY,
@OrdersCreatedByPersonID INT,
@SalespersonPersonID INT
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @OrdersToGenerate AS TABLE
    (
        OrderReference INT PRIMARY KEY,   -- reference from the application
        OrderID INT
    );

    -- allocate the new order numbers

    INSERT @OrdersToGenerate (OrderReference, OrderID)
    SELECT OrderReference, NEXT VALUE FOR Sequences.OrderID
    FROM
    @Orders;

    BEGIN TRY

        BEGIN TRAN;

        INSERT Sales.Orders
            (OrderID, CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonID, BackorderOrderID, OrderDate,
             ExpectedDeliveryDate, CustomerPurchaseOrderNumber, IsUndersupplyBackordered, Comments, DeliveryInstructions, InternalComments,
             PickingCompletedWhen, LastEditedBy, LastEditedWhen)
        SELECT otg.OrderID, o.CustomerID, @SalespersonPersonID, NULL, o.ContactPersonID, NULL, SYSDATETIME(),
               o.ExpectedDeliveryDate, o.CustomerPurchaseOrderNumber, o.IsUndersupplyBackordered, o.Comments, o.DeliveryInstructions, NULL,
               NULL, @OrdersCreatedByPersonID, SYSDATETIME()
        FROM @OrdersToGenerate AS otg
        InNER JOIN @Orders AS o
        ON otg.OrderReference = o.OrderReference;

        INSERT Sales.OrderLines
            (OrderID, StockItemID, [Description], PackageTypeID, Quantity, UnitPrice,
             TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy, LastEditedWhen)
        SELECT otg.OrderID, ol.StockItemID, ol.[Description], si.UnitPackageID, ol.Quantity,
               Website.CalculateCustomerPrice(o.CustomerID, ol.StockItemID, SYSDATETIME()),
               si.TaxRate, 0, NULL, @OrdersCreatedByPersonID, SYSDATETIME()
        FROM @OrdersToGenerate AS otg
        INNER JOIN @OrderLines AS ol
        ON otg.OrderReference = ol.OrderReference
		INNER JOIN @Orders AS o
		ON ol.OrderReference = o.OrderReference
        INNER JOIN Warehouse.StockItems AS si
        ON ol.StockItemID = si.StockItemID;

        COMMIT;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        PRINT N'Unable to create the customer orders.';
        THROW;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO



"@

Add-Type -Path "C:\ugpresentation\ScriptDom\Microsoft.SqlServer.TransactSql.ScriptDom.dll"
Write-Host "Attempting to parse..." 
$parser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser($true)
#object to handle parsing errors if any
$parseErrors = New-Object System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]
#object that handles strings script to parse
$stringReader = New-Object System.IO.StringReader($ScriptData)

#parser creates parsed objects from strings 
$parsedObjects = $parser.Parse($stringReader, [ref]$parseErrors)
if($parseErrors.Count -eq 0) {
        Write-Host "$($parser.GetType().Name): No parsing errors" -ForegroundColor Green
    }
    else {
        Write-Host "$($parser.GetType().Name): $($parseErrors.Count) parsing error(s): $(($parseErrors | ConvertTo-Json))" -ForegroundColor Yellow
    }

