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
    FROM myserver.mydb.dbo.Orders (NOLOCK);

    
    BEGIN TRY

        BEGIN TRAN;
        --Comment 1
        INSERT Sales.Orders
            (OrderID, CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonID, BackorderOrderID, OrderDate,
             ExpectedDeliveryDate, CustomerPurchaseOrderNumber, IsUndersupplyBackordered, Comments, DeliveryInstructions, InternalComments,
             PickingCompletedWhen, LastEditedBy, LastEditedWhen)
        SELECT otg.OrderID, o.CustomerID, @SalespersonPersonID, NULL, o.ContactPersonID, NULL, SYSDATETIME(),
               o.ExpectedDeliveryDate, o.CustomerPurchaseOrderNumber, o.IsUndersupplyBackordered, o.Comments, o.DeliveryInstructions, NULL,
               NULL, @OrdersCreatedByPersonID, SYSDATETIME()
        from dbo.OrdersToGenerate AS otg
        INNER JOIN dbo.Orders AS o
        ON otg.OrderReference = o.OrderReference;
        --Comment 2
        insert Sales.OrderLines
            (OrderID, StockItemID, [Description], PackageTypeID, Quantity, UnitPrice,
             TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy, LastEditedWhen)
        SELECT *
        FROM dbo.OrdersToGenerate AS otg
        INNER JOIN OrderLines AS ol
        ON otg.OrderReference = ol.OrderReference
		INNER JOIN dbo.Orders AS o
		ON ol.OrderReference = o.OrderReference
        INNER JOIN Warehouse.StockItems (nolock) AS si
        ON ol.StockItemID = si.StockItemID;

        COMMIT;

    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
        RETURN -1;
    END CATCH;

    RETURN 0;
END;
GO



"@

Find-LintingErrors $ScriptData 
