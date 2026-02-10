-- -------------------------------------------------------------------
-- Project Step 2 Draft: Normalized Schema + DDL with Sample Data
-- Schema cs340_newsotau
-- Team Name: Group 42
-- Team Members: Taurean Newsome & Chris Cheng
-- -------------------------------------------------------------------

SET FOREIGN_KEY_CHECKS = 0;
SET AUTOCOMMIT = 0;

-- -----------------------------------------------------
-- Table `Customers`
--
-- Description: Records the details of Customers who 
--              purchase products from X2Fed.
--
-- Relationship:
--  1. 1:M relationship with `Invoices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Customers` ;

CREATE TABLE `Customers` (
  `customerID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `customerName` VARCHAR(150) NOT NULL,
  `contactName` VARCHAR(100) NOT NULL,
  `contactEmail` VARCHAR(255) NOT NULL UNIQUE,
  `contactPhone` VARCHAR(20) NOT NULL
);


-- -----------------------------------------------------
-- Table `InvoiceStatuses`
--
-- Description: Defines and describes the state of the
--              Invoices entity.
--
-- Relationship:
--  1. 1:M relationship with `Invoices`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `InvoiceStatuses` ;

CREATE TABLE `InvoiceStatuses` (
  `invoiceStatusID` INT NOT NULL PRIMARY KEY,
  `statusName` VARCHAR(50) NOT NULL UNIQUE,
  `comments` VARCHAR(255) NULL
);


-- -----------------------------------------------------
-- Table `Manufacturers`
--
-- Description: Records the details of Manufactuers from
--              whom X2Fed purchses products.
--
-- Relationship:
--  1. 1:M relationship with `Products`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Manufacturers` ;

CREATE TABLE `Manufacturers` (
  `manufacturerID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `manufacturerName` VARCHAR(150) NOT NULL,
  `contactName` VARCHAR(100) NOT NULL,
  `contactEmail` VARCHAR(255) NOT NULL UNIQUE,
  `contactPhone` VARCHAR(20) NOT NULL
);


-- -----------------------------------------------------
-- Table `Products`
--
-- Description: Records the details of Products supplied
--              by Manufacturers that are in stock, as
--              well as per-unit cost and resale price.
--
-- Relationship:
--  1. M:1 relationship with `Manufacturers`
--  2. M:N relationship with `Invoices` via `InvoiceLineItems`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Products` ;

CREATE TABLE `Products` (
  `productID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `manufacturerID` INT NOT NULL,
  `productName` VARCHAR(150) NOT NULL,
  `description` VARCHAR(255) NOT NULL,
  `quantityInStock` INT NOT NULL,
  `unitCost` DECIMAL(12,2) NOT NULL,
  `resalePrice` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`manufacturerID`) REFERENCES `Manufacturers` (`manufacturerID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- -----------------------------------------------------
-- Table `Invoices`
--
-- Description: Records te details of Invoices for customer
--              transactions.
--
-- Relationship:
--  1. M:N relationship with `Products` via `InvoiceLineItems`
--  2. M:1 relationship with `Customers`
--  3. M:1 relationsip with `InvoiceStatuses`
--  4. 1:M relationship with `Shipments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `Invoices` ;

CREATE TABLE `Invoices` (
  `invoiceID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `customerID` INT NOT NULL,
  `invoiceStatusID` INT NOT NULL DEFAULT 1,
  `invoiceNumber` VARCHAR(30) NOT NULL UNIQUE,
  `createdAt` DATETIME NULL DEFAULT NULL,
  `paidAt` DATETIME NULL DEFAULT NULL,
  `closedAt` DATETIME NULL DEFAULT NULL,
  `totalAmount` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`customerID`) REFERENCES `Customers` (`customerID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (`invoiceStatusID`) REFERENCES `InvoiceStatuses` (`invoiceStatusID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- -----------------------------------------------------
-- Table `InvoiceLineItems`
-- 
-- Description: Enables X2FED to track inventory and 
--              historical pricing for auditing and 
--              reporting of line items at time of sale.
--
-- Relationship: 
--  1. Implements the M:N relationship between `Invoices`
--     and `Products`.
--  2. M:1 relationship with `Invoices`
--  3. M:1 relationship with `Products`
--  4. 1:M relationship with `ShipmentItems`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `InvoiceLineItems` ;

CREATE TABLE `InvoiceLineItems` (
  `invoiceLineItemID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `invoiceID` INT NOT NULL,
  `productID` INT NOT NULL,
  `quantitySold` INT NOT NULL,
  `unitPriceAtSale` DECIMAL(12,2) NOT NULL,
  `lineItemTotal` DECIMAL(12,2) NOT NULL,
  FOREIGN KEY (`invoiceID`) REFERENCES `Invoices` (`invoiceID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`productID`) REFERENCES `Products` (`productID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- -----------------------------------------------------
-- Table `ShipmentStatuses`
-- 
-- Description: Defines and describes the state of the
--              Shipments entity.
-- 
-- Relationship:
--  1. 1:M relationship with `Shipments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ShipmentStatuses` ;

CREATE TABLE `ShipmentStatuses` (
  `shipmentStatusID` INT NOT NULL PRIMARY KEY,
  `statusName` VARCHAR(50) NOT NULL UNIQUE,
  `comments` VARCHAR(255) NULL
);


-- -----------------------------------------------------------------------------------
-- Table `Shipments`
--
-- Description: Represents shipments associated with a single invoice.
--              
-- Relationship: 
--  1. M:1 relationship with `Invoices`
--  2. M:1 relationship with `ShipmentStatuses`
--  3. 1:M relationship with `ShipmentItems`
-- -----------------------------------------------------------------------------------
DROP TABLE IF EXISTS `Shipments` ;

CREATE TABLE `Shipments` (
  `shipmentID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `invoiceID` INT NOT NULL,
  `shipmentStatusID` INT NOT NULL DEFAULT 1,
  `trackingNumber` VARCHAR(50) NULL DEFAULT NULL,
  `shipmentDate` DATETIME NOT NULL,
  `deliveredAt` DATETIME NULL DEFAULT NULL,
  `shippingMethod` VARCHAR(50) NULL,
  FOREIGN KEY (`invoiceID`) REFERENCES `Invoices` (`invoiceID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  FOREIGN KEY (`shipmentStatusID`) REFERENCES `ShipmentStatuses` (`shipmentStatusID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- ----------------------------------------------------------------------------------------
-- Table `ShipmentItems`
--
-- Description: Intersection table implementing the M:N relationship between `Shipments` 
--              and `InvoiceLineItems`. Records `quantityShipped` to support partial 
--              fulfillment of shipments.
--              
-- Business Rules:
--   1. Each shipment can only contain items from a single invoice. 
--   2. Each invoice line item may be shipped in multiple shipments (partial shipments).
--
-- Purpose: Supports government audit requirements and procurement rules by tracking 
--          exactly which items from an invoice are shipped and in what quantity.
--
-- Relationship: 
--  1. M:1 relationship with `InvoiceLineItems`
--  2. M:1 relationship with `Shipments`
-------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS `ShipmentItems` ;

CREATE TABLE `ShipmentItems` (
  `shipmentItemID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `shipmentID` INT NOT NULL,
  `invoiceLineItemID` INT NOT NULL,
  `quantityShipped` INT NOT NULL,
  FOREIGN KEY (`shipmentID`) REFERENCES `Shipments` (`shipmentID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  FOREIGN KEY (`invoiceLineItemID`) REFERENCES `InvoiceLineItems` (`invoiceLineItemID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);


-- -----------------------------------------------------
-- Example Data for table `Customers`
-- -----------------------------------------------------
INSERT INTO `Customers` (`customerName`, `contactName`, `contactEmail`, `contactPhone`) 
VALUES 
  ('United States Department of State', 'Alan Castle', 'castle0132@stated.gov', '555-202-4321'),
  ('Chimera Global LLC', 'Richard Stovall', 'rstovall@chimerag.com', '555-910-1234'),
  ('Eagle Aviation', 'Joseph Hunter', 'jhunt@eav.net', '555-678-8765'),
  ('USSOCOM SOF AT&L', 'Bryan Kennedy', 'br.j.ken.civ@socoma.mil', '555-813-0987'),
  ('Anomaly Six', 'Brittany Hoffman', 'hoffmanb@revealt.io', '555-703-5678');


-- -----------------------------------------------------
-- Example Data for table `InvoiceStatuses`
-- -----------------------------------------------------
INSERT INTO `InvoiceStatuses` (`invoiceStatusID`, `statusName`, `comments`) 
VALUES 
  (1, 'Open', 'Invoice is created and awaiting payment.'),
  (2, 'Paid', 'Invoice has been fully paid by the customer.'),
  (3, 'Closed', 'Invoice is finalized and no further actions are required.');


-- -----------------------------------------------------
-- Example Data for table `Manufacturers`
-- -----------------------------------------------------
INSERT INTO `Manufacturers` (`manufacturerName`, `contactName`, `contactEmail`, `contactPhone`) 
VALUES 
  ('Shielding Resources Group Inc.', 'Matt Halweg', 'mhalweg@srg.io', '555-9181985'),
  ('Dell Technologies', 'Scott Miller', 'scott.miller@dell.net', '555-949-1607'),
  ('Strategic Solutions Unlimited', 'Patricia Glenn', 'patglenn@ssu.xyz', '555-910-8138'),
  ('Juniper Networks', 'Neil Carver', 'neil.carver@juniper.com', '555-973-6400');


-- -----------------------------------------------------
-- Example Data for table `Products`
-- -----------------------------------------------------
INSERT INTO `Products` (`manufacturerID`, `productName`, `description`, `quantityInStock`, `unitCost`, `resalePrice`) 
VALUES 
  (1, '40GHz Honeycomb Waveguide', '1/8\" x 1/2\" stainless steel', 40, 95.00, 550.00),
  (1, 'RF Shielded Door', '3 x 7 ft with 90 dB protection', 20, 18575.00, 35550.00),
  (2, 'Dell XPS 16 Laptop', 'Intel Core Ultra X7 Processor - secureOS', 300, 1600.00, 2300.00),
  (2, 'Dell PowerEdge R750', '2U Rack Server - Intel Xeon Scalable Processor - 32 DDR4 DIMM Slots - secureServer 2026', 80, 6000.00, 8000.00),
  (3, 'Modular Composite Shelter System (MCSS)', '84\" L x 84\" W x 94.5\" H - Fully pre-wired with 100A electrical panel and Hubbell connections', 24, 120000.00, 250000.00),
  (4, 'Juniper Networks SSR1200', '1RU Session Smart Router', 50, 20000.00, 25000.00),
  (4, 'Juniper Networks SSR1500', '1RU 512GB RAM 1TB SSD Smart Router', 50, 103000.00, 165000.00),
  (4, 'Juniper Networks SRX1500', '1RU Services Gateway - Security Appliance 5 Gbps Firewall', 50, 8000.00, 15000.00);


-- -----------------------------------------------------
-- Example Data for table `Invoices`
-- -----------------------------------------------------
INSERT INTO `Invoices` (`customerID`, `invoiceStatusID`, `invoiceNumber`, `createdAt`, `paidAt`, `closedAt`, `totalAmount`) 
VALUES 
  (1, 3, 'X2F-2026-000001', '2026-01-05 09:30:55', '2026-01-15 12:00:00', '2026-02-04 14:57:45', 5875.00),
  (1, 1, 'X2F-2026-000002', '2026-01-05 12:00:01', NULL, NULL, 8000.00),
  (2, 2, 'X2F-2026-000003', '2026-01-13 16:05:27', '2026-01-28 15:32:36', NULL, 10000.00),
  (3, 1, 'X2F-2026-000004', '2026-01-15 09:07:33', NULL, NULL, 225000.00),
  (4, 1, 'X2F-2026-000005', '2026-01-27 11:17:29', NULL, NULL, 2500.00);


-- -----------------------------------------------------
-- Example Data for table `InvoiceLineItems`
-- -----------------------------------------------------
INSERT INTO `InvoiceLineItems` (`invoiceID`, `productID`, `quantitySold`, `unitPriceAtSale`, `lineItemTotal`) 
VALUES 
  (1, 2, 2, 2150.00, 4300.00),
  (1, 1, 3, 525.00, 1575.00),
  (2, 3, 1, 8000.00, 8000.00),
  (3, 3, 1, 7800.00, 7800.00),
  (3, 2, 1, 2200.00, 2200.00),
  (4, 4, 1, 225000.00, 225000.00),
  (5, 1, 5, 500.00, 2500.00);


-- -----------------------------------------------------
-- Example Data for table `ShipmentStatuses`
-- -----------------------------------------------------
INSERT INTO `ShipmentStatuses` (`shipmentStatusID`, `statusName`, `comments`) 
VALUES 
  (1, 'Pending', 'Shipment has not yet been dispatched.'),
  (2, 'Shipped', 'Shipment is in transit but not yet delivered.'),
  (3, 'Delivered', 'Shipment has been successfully delivered to the customer.');


-- -----------------------------------------------------
-- Example Data for table `Shipments`
-- -----------------------------------------------------
INSERT INTO `Shipments` (`invoiceID`, `shipmentStatusID`, `trackingNumber`, `shipmentDate`, `deliveredAt`, `shippingMethod`) 
VALUES 
  (1, 3, 'FDX123456789', '2026-01-16 10:35:01', '2026-01-20 14:35:19', 'FedEx'),
  (1, 2, 'FDX987654321', '2026-01-18 09:15:12', NULL, 'FedEx'),
  (3, 2, 'UPS987654321', '2026-01-29 09:27:43', NULL, 'UPS');


-- ------------------------------------------------------------------------------
-- Example Data for table `ShipmentItems`
-- ------------------------------------------------------------------------------
INSERT INTO `ShipmentItems` (`shipmentID`, `invoiceLineItemID`, `quantityShipped`) 
VALUES 
  (1, 1, 2),
  (1, 2, 1),
  (2, 2, 2),
  (3, 4, 1),
  (3, 5, 1);


SET FOREIGN_KEY_CHECKS = 1;
COMMIT;