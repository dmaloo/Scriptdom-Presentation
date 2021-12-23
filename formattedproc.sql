USE [WideWorldImporters];


GO
SET ANSI_NULLS ON;


GO
SET QUOTED_IDENTIFIER ON;


GO
CREATE OR ALTER PROCEDURE [Website].[InsertCustomerOrders]
@Orders Website.OrderList READONLY, @OrderLines Website.OrderLineList READONLY, @OrdersCreatedByPersonID INT, @SalespersonPersonID INT
WITH EXECUTE AS OWNER
AS
BEGIN
          SET NOCOUNT ON;
          SET XACT_ABORT ON;
          DECLARE @OrdersToGenerate AS TABLE (
                    OrderReference INT PRIMARY KEY,
                    OrderID        INT);
          INSERT @OrdersToGenerate (OrderReference, OrderID)
          SELECT OrderReference,
                  NEXT VALUE FOR Sequences.OrderID
          FROM   @Orders;
          BEGIN TRY
                    BEGIN TRANSACTION;
                    INSERT Sales.Orders (OrderID, CustomerID, SalespersonPersonID, PickedByPersonID, ContactPersonID, BackorderOrderID, OrderDate, ExpectedDeliveryDate, CustomerPurchaseOrderNumber, IsUndersupplyBackordered, Comments, DeliveryInstructions, InternalComments, PickingCompletedWhen, LastEditedBy, LastEditedWhen)
                    SELECT otg.OrderID,
                           o.CustomerID,
                           @SalespersonPersonID,
                           NULL,
                           o.ContactPersonID,
                           NULL,
                           SYSDATETIME(),
                           o.ExpectedDeliveryDate,
                           o.CustomerPurchaseOrderNumber,
                           o.IsUndersupplyBackordered,
                           o.Comments,
                           o.DeliveryInstructions,
                           NULL,
                           NULL,
                           @OrdersCreatedByPersonID,
                           SYSDATETIME()
                    FROM   @OrdersToGenerate AS otg
                           INNER JOIN
                           @Orders AS o
                           ON otg.OrderReference = o.OrderReference;
                    INSERT Sales.OrderLines (OrderID, StockItemID, [Description], PackageTypeID, Quantity, UnitPrice, TaxRate, PickedQuantity, PickingCompletedWhen, LastEditedBy, LastEditedWhen)
                    SELECT otg.OrderID,
                           ol.StockItemID,
                           ol.[Description],
                           si.UnitPackageID,
                           ol.Quantity,
                           Website.CalculateCustomerPrice(o.CustomerID, ol.StockItemID, SYSDATETIME()),
                           si.TaxRate,
                           0,
                           NULL,
                           @OrdersCreatedByPersonID,
                           SYSDATETIME()
                    FROM   @OrdersToGenerate AS otg
                           INNER JOIN
                           @OrderLines AS ol
                           ON otg.OrderReference = ol.OrderReference
                           INNER JOIN
                           @Orders AS o
                           ON ol.OrderReference = o.OrderReference
                           INNER JOIN
                           Warehouse.StockItems AS si
                           ON ol.StockItemID = si.StockItemID;
                    COMMIT TRANSACTION;
          END TRY
          BEGIN CATCH
                    IF XACT_STATE() <> 0
                              ROLLBACK;
                    PRINT N'Unable to create the customer orders.';
                    THROW;
                    RETURN -1;
          END CATCH
          RETURN 0;
END


