

/* Create 4 tables */

Create table Customer
(
CustomerID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
CustFName varchar(25),
CustMName varchar(10),
CustLName varchar(25)
);

Create table Product (
ProductID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
ProductName varchar(25),
UnitPrice decimal (6,2),
QuantityInStock int
);


CREATE TABLE ProductOrder
(
OrderID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
OrderDate date,
CustomerID int,
FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID),
Total decimal (6,2)
);

Create table OrderLine (
OrderLineID int NOT NULL AUTO_INCREMENT PRIMARY KEY,
OrderID int,
FOREIGN KEY (OrderID) REFERENCES ProductOrder (OrderID),
ProductID int,
FOREIGN KEY (ProductID) REFERENCES Product (ProductID),
Quantity int
);



/* Insert values into tables */

INSERT INTO Customer (CustomerID, CustFName, CustMName, CustLName)
VALUES (129, "Linh", "Le Khanh", "Huynh");

INSERT INTO Customer (CustomerID, CustFName, CustMName, CustLName) 
VALUES (130, "Parteek", "Singh", "Manes");

INSERT INTO Customer (CustomerID, CustFName, CustMName, CustLName) 
VALUES (131, "John", "Smith", "James");

INSERT INTO Product (ProductID, ProductName, UnitPrice, QuantityinStock) 
VALUES (1, "Table", 27.99, 900);

INSERT INTO Product (ProductID, ProductName, UnitPrice, QuantityinStock) 
VALUES (2, "Chair", 22.99, 850);

INSERT INTO Product (ProductID, ProductName, UnitPrice, QuantityinStock) 
VALUES (3, "Sofa", 67.99, 800);

INSERT INTO Product (ProductID, ProductName, UnitPrice, QuantityinStock) 
VALUES (4, "Desk", 42.99, 750);

INSERT INTO Product (ProductID, ProductName, UnitPrice, QuantityinStock) 
VALUES (5, "Lamp", 25.99, 700);

INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (6001, 129, '2022-11-22');
INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (6002, 129, '2022-11-28');

INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (5001, 130, '2022-11-22');
INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (5002, 130, '2022-10-28');

INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (4001, 131, '2022-09-22');
INSERT INTO ProductOrder (OrderID, CustomerID, OrderDate)
VALUES (4002, 131, '2022-09-28');

INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (15001,4, 5001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (25001,5, 5001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (16001,2, 6001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (26001,4, 6001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (15002,3, 5002, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (25002,2, 5002, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (14001,5, 4001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (24001,2, 4001, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (16002,2, 6002, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (26002,4, 6002, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (14002,3, 4002, 1);
INSERT INTO OrderLine (OrderLineID, ProductID, OrderID, Quantity) VALUES (24002,2, 4002, 1);

/*  */

UPDATE ProductOrder 
SET Total = (
    SELECT SUM(Product.UnitPrice * OrderLine.Quantity) AS Total
    FROM OrderLine
    JOIN Product ON OrderLine.ProductID = Product.ProductID
    WHERE OrderLine.OrderID = ProductOrder.OrderID
)
WHERE OrderID IN (SELECT DISTINCT OrderID FROM OrderLine);

CREATE VIEW view_All_Order AS
SELECT * FROM ProductOrder;




DELIMITER //

CREATE PROCEDURE pro_List_oneDayOrder(IN TargetDate DATE)
BEGIN
    SELECT * 
    FROM ProductOrder 
    WHERE OrderDate = TargetDate;
END; //

CALL pro_List_oneDayOrder('2022-11-22');



DELIMITER //
CREATE TRIGGER updating_order
AFTER INSERT ON OrderLine
FOR EACH ROW
BEGIN
DECLARE ProductPrice decimal (6,2);
SELECT Product.UnitPrice INTO ProductPrice FROM Product
WHERE Product.ProductID = NEW.ProductID;
UPDATE ProductOrder p
SET p.Total = p.total + ProductPrice * NEW.Quantity
WHERE p.OrderID = NEW.OrderID;
END; //
DELIMITER ;


DELIMITER //
CREATE TRIGGER updating_inventory
AFTER INSERT ON OrderLine
FOR EACH ROW
BEGIN
UPDATE Product p
SET p.QuantityInStock = p.QuantityInStock - NEW.Quantity
WHERE p.ProductID = NEW.ProductID;
 END; //
DELIMITER ;
