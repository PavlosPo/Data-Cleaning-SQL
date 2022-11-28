/* 

Cleaning Data in SQL Queries.

*/

--------------------------------------------------------------------------------
-- Date Conversion
--------------------------------------------------------------------------------

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject.dbo.Nashville_Housing 

-- Adding new Column 
ALTER TABLE PortfolioProject.dbo.Nashville_Housing 
ADD SaleDateConverted Date;

-- Seting the new Date column
UPDATE PortfolioProject.dbo.Nashville_Housing 
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Droping the old Date Column
ALTER TABLE PortfolioProject.dbo.Nashville_Housing 
DROP COLUMN SaleDate;


--------------------------------------------------------------------------------
-- Populate Property Addres Date
--------------------------------------------------------------------------------

SELECT *
FROM PortfolioProject.dbo.Nashville_Housing 
WHERE PropertyAddress = '' OR PropertyAddress IS NULL 

-- We can populate by the same ParceID.
SELECT nh1.ParcelID, nh1.PropertyAddress, nh2.ParcelID, nh2.PropertyAddress
FROM PortfolioProject.dbo.Nashville_Housing nh1
JOIN PortfolioProject.dbo.Nashville_Housing nh2
	ON nh1.ParcelID = nh2.ParcelID 
	AND nh1.[UniqueID ] <> nh2.[UniqueID ] 
WHERE nh1.PropertyAddress = '' AND nh2.PropertyAddress <> ''

-- Updating the table, Using Self Join technique
UPDATE nh1
SET nh1.PropertyAddress = nh2.PropertyAddress 
FROM PortfolioProject.dbo.Nashville_Housing nh1
JOIN PortfolioProject.dbo.Nashville_Housing nh2
	ON nh1.ParcelID = nh2.ParcelID 
	AND nh1.[UniqueID ] <> nh2.[UniqueID ] 
WHERE nh1.PropertyAddress = '' AND nh2.PropertyAddress <> ''

--------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)
--------------------------------------------------------------------------------

Select PropertyAddress 
FROM PortfolioProject.dbo.Nashville_Housing 

-- Breaking the Address using SUBSTRING, CHARINDEX, e.t.c. 
SELECT PropertyAddress
, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) ) As City
FROM PortfolioProject.dbo.Nashville_Housing

-- Creating Two new Columns
ALTER TABLE PortfolioProject.dbo.Nashville_Housing
ADD Address nvarchar(255), City nvarchar(255)

-- Updating the Data on the new columns.
UPDATE PortfolioProject.dbo.Nashville_Housing 
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
	City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress) )
	
-- Droping the old Adress Column
ALTER TABLE PortfolioProject.dbo.Nashville_Housing 
DROP COLUMN PropertyAddress


--------------------------------------------------------------------------------
-- Breaking out OwnerAddress into Individual Columns (Address, City, State)
--------------------------------------------------------------------------------

Select OwnerAddress 
FROM PortfolioProject.dbo.Nashville_Housing

-- Breaking the OwnerAdress using PARSENAME in combination with REPLACE method.
SELECT OwnerAddress 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) Owner_State
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) Owner_City
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) Owner_Adress
FROM PortfolioProject.dbo.Nashville_Housing

--Creating three new Columns
ALTER TABLE PortfolioProject.dbo.Nashville_Housing 
ADD Owner_Adress varchar(255), 
	Owner_State varchar(255), 
	Owner_City varchar(255)

-- Adding Values to the new columns
UPDATE PortfolioProject.dbo.Nashville_Housing 
SET Owner_Adress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	Owner_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
	
-- Droping the old OwnerAdress Column
ALTER TABLE PortfolioProject.dbo.Nashville_Housing 
DROP COLUMN OwnerAddress


--------------------------------------------------------------------------------
-- Changing 'Y' and 'N' to 'Yes' and 'No' in the SoldAsVacant Column
--------------------------------------------------------------------------------

-- Find the Distinct values
SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Nashville_Housing 
GROUP BY SoldAsVacant 
ORDER BY 2


-- Case statement to transform the values
SELECT SoldAsVacant
	,CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 ELSE SoldAsVacant 
	 END
FROM PortfolioProject.dbo.Nashville_Housing

-- Update the table
UPDATE PortfolioProject.dbo.Nashville_Housing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No'
	 					WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 					ELSE SoldAsVacant 
	 					END
	 					

--------------------------------------------------------------------------------
-- Removing Duplicates
--------------------------------------------------------------------------------

-- CTE, ROW_NUMBER and PARTION BY, Technique
WITH RowNumTable As (	 				
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, 
									PropertyAddress, 
									SalePrice, 
									LegalReference 
									ORDER BY ParcelID) AS ROW#
FROM PortfolioProject.dbo.Nashville_Housing nh 
	)

-- DELETING the rows with ROW# > 1
DELETE 
FROM RowNumTable
WHERE ROW# > 1








