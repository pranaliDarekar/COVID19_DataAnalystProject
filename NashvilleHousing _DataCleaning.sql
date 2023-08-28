--DATA CLEANING USING SQL QUERIES

SELECT * FROM Portfolio_Project.dbo.[ Nashville_Housing ]

--Standardize sale date
SELECT SaleDateConverted, CONVERT(Date,SaleDate) FROM Portfolio_Project.dbo.[ Nashville_Housing ]


ALTER Table [ Nashville_Housing ]
ADD SaleDateConverted Date;

UPDATE [ Nashville_Housing ]
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populate Property Address data
SELECT PropertyAddress FROM Portfolio_Project.dbo.[ Nashville_Housing ]
Where PropertyAddress is null
-- here we see alot of null vallues and thus also notice that parcelid has only one addreess
--doing self join

SELECT a.PropertyAddress,a.ParcelID, b.ParcelID, a.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project.dbo.[ Nashville_Housing ] a
JOIN Portfolio_Project.dbo.[ Nashville_Housing ] b
ON a.ParcelID = b.ParcelID and a.UniqueID  != b.UniqueID 
Where a.PropertyAddress is null 
ORDER BY a.ParcelID 

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project.dbo.[ Nashville_Housing ] a
JOIN Portfolio_Project.dbo.[ Nashville_Housing ] b
ON a.ParcelID = b.ParcelID and a.UniqueID  != b.UniqueID 
Where a.PropertyAddress is null 
-- isnull check if the first entery is null if it is then it populates with the second entry separated by a comma 

--Breaking out Address into Individual Columns (Address,City,state)
SELECT PropertyAddress 
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

--ADDING THESE THREE COULMNS IN OUR CURRENT TABLE

ALTER Table [ Nashville_Housing ]
ADD Address Nvarchar(255);

UPDATE [ Nashville_Housing ]
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)


ALTER Table [ Nashville_Housing ]
ADD City Nvarchar(255);

UPDATE [ Nashville_Housing ]
SET City =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

--CHECKING RESULTS OF TWO COLUMNS
-- TWO COLUMNS ADDED AT THE END

SELECT *
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

--TO GET STATE
SELECT OwnerAddress
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

-- Easier one is parsename

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

--Updating in the table

ALTER Table [ Nashville_Housing ]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [ Nashville_Housing ]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER Table [ Nashville_Housing ]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [ Nashville_Housing ]
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER Table [ Nashville_Housing ]
ADD OwnerSplitState Nvarchar(255);

UPDATE [ Nashville_Housing ]
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


--Reviewing the table
SELECT *
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

--Change YES and no in "Sold as vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Portfolio_Project.dbo.[ Nashville_Housing ]
GROUP BY SoldAsVacant
ORDER BY COUNT(SoldAsVacant)

--HERE we see that there are 52 y values and 399 N values.Lets change it to yes or no

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
     WHEN SoldAsVacant ='N' THEN 'No'
     ELSE SoldAsVacant 
END 
FROM Portfolio_Project.dbo.[ Nashville_Housing ]



UPDATE [ Nashville_Housing ]
SET SoldAsVacant =  CASE 
                            WHEN SoldAsVacant ='Y' THEN 'Yes'
                            WHEN SoldAsVacant ='N' THEN 'No'
                            ELSE SoldAsVacant 
                    END

-- Updating is done correctly in SoldAsVacant

-- Removing Duplicates
-- parition should be done with unique column

WITH Row_Num_CTE AS 
(
SELECT *, ROW_NUMBER() OVER(PARTITION  BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference 
          ORDER BY UniqueID) as row_num
FROM Portfolio_Project.dbo.[ Nashville_Housing ]
--Order by ParcelID
)
-- Checking if the row_num greater than 1 then delete the row with same entry
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--deleting
DELETE 
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns

SELECT *
FROM Portfolio_Project.dbo.[ Nashville_Housing ]

ALTER TABLE Portfolio_Project.dbo.[ Nashville_Housing ]
DROP COLUMN Address, City, OwnerAddress, TaxDistrict, PropertyAddress, 

ALTER TABLE Portfolio_Project.dbo.[ Nashville_Housing ]
DROP COLUMN SaleDate

-- Unused rows are deleted