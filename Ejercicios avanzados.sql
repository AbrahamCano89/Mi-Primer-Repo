--Ejercicio 1

SELECT 
	soh.TotalDue ,
	RANK () OVER (
	ORDER BY soh.TotalDue  DESC) AS Ranking
FROM Sales.SalesOrderHeader soh 

--Ejercicio 2

SELECT 
	st.Name AS Territory,
	soh.SalesOrderID,
	soh.OrderDate, 
	soh.TotalDue,
		RANK () OVER (
		PARTITION BY soh.TerritoryID 
		ORDER BY soh.TotalDue) AS Ranking
FROM Sales.SalesOrderHeader soh 
LEFT JOIN Sales.SalesTerritory st 
	ON soh.TerritoryID = st.TerritoryID
	
--Ejercicio 3

SELECT 
	sp.BusinessEntityID ,
	sp.SalesYTD ,
	sp.SalesYTD / SUM(sp.SalesYTD) OVER(
	) AS ContribucionVentas
FROM Sales.SalesPerson sp

-- Ejercicio 4

WITH Tabla AS (
	SELECT 
		cr.FromCurrencyCode ,
		cr.ToCurrencyCode  ,
		cr.CurrencyRateDate ,
		cr.AverageRate ,
		LAG(cr.AverageRate) OVER(
			ORDER BY cr.CurrencyRateDate) AS Cotizaciones
FROM Sales.CurrencyRate cr
WHERE cr.FromCurrencyCode = 'USD'
AND cr.ToCurrencyCode = 'EUR'
)
SELECT TOP 1 *, ABS(Cotizaciones - AverageRate) AS Fluctuacion
FROM Tabla 
ORDER BY ABS(Cotizaciones - AverageRate) DESC

-- Ejercicio 5

SELECT *
FROM (
	SELECT 
	soh.TerritoryID ,
	soh.TotalDue ,
	RANK() OVER(
		PARTITION BY soh.TerritoryID 
		ORDER BY soh.TotalDue DESC) AS MaxVentas
FROM Sales.SalesOrderHeader soh) AS Tabla
WHERE Tabla.MaxVentas <=2

-- Ejercicio 6 

SELECT *
FROM(
	SELECT 
	p.FirstName ,
	p.LastName ,
	e.JobTitle ,
	soh.SalesOrderID ,
	soh.SalesPersonID ,
	soh.OrderDate ,
	soh.TotalDue ,
	ROW_NUMBER () OVER (
		PARTITION BY soh.SalesPersonID 
		ORDER BY soh.TotalDue DESC
	) AS Ranking
FROM Sales.SalesOrderHeader soh
LEFT JOIN Person.Person p 
ON soh.SalesPersonID = p.BusinessEntityID 
LEFT JOIN HumanResources.Employee e 
ON soh.SalesPersonID = e.BusinessEntityID 
) tabla
WHERE Ranking <=5 AND tabla.SalesPersonID IN (
	SELECT TOP 2 sp.BusinessEntityID 
	FROM Sales.SalesPerson sp 
	ORDER BY SalesYTD DESC)
	
-- Ejercicio 7
	
SELECT 
	st.Name AS Territorio,
	pc.Name AS Categoria, 
	SUM (sod.OrderQty) AS Cantidad
FROM Sales.SalesOrderDetail sod
LEFT JOIN Sales.SalesOrderHeader soh 
ON sod.SalesOrderDetailID = soh.SalesOrderID 
LEFT JOIN Sales.SalesTerritory st 
ON soh.TerritoryID = st.TerritoryID 
LEFT JOIN Production.Product p 
ON sod.ProductID = p.ProductID 
LEFT JOIN Production.ProductSubcategory ps 
ON p.ProductSubcategoryID  =ps.ProductSubcategoryID 
LEFT JOIN Production.ProductCategory pc 
ON ps.productCategoryID = pc.ProductCategoryID 
GROUP BY pc.Name, st.Name
