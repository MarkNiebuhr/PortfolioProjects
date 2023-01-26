--
-- Cleaning Data in SQL queries for Nashville Housing Data
--

SELECT * from NashvilleHousing



-- Standardize date formatting

ALTER TABLE NashvilleHousing
ADD SalesDateConverted Date

UPDATE NashvilleHousing
SET SalesDateConverted = CONVERT(date, SaleDate)

SELECT SaleDate, SalesDateConverted
FROM NashvilleHousing



-- Correct Null property address data

SELECT *
FROM NashvilleHousing
WHERE PropertyAddress is null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null

update a
set a.PropertyAddress = b.PropertyAddress
FROM NashvilleHousing a
join NashvilleHousing b 
	on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ] 
where a.PropertyAddress is null 
	and b.PropertyAddress is not null



-- Separate address data into individual columns

SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',' , propertyaddress) - 1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',' , propertyaddress) + 1, LEN(propertyaddress)) as city
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',' , propertyaddress) - 1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',' , propertyaddress) + 1, LEN(propertyaddress))

SELECT 
PARSENAME(replace(owneraddress, ', ', '.'), 3),
PARSENAME(replace(owneraddress, ', ', '.'), 2),
PARSENAME(replace(owneraddress, ', ', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(owneraddress, ', ', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(owneraddress, ', ', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(owneraddress, ', ', '.'), 1)



-- Correct "Y" and "N" values in SoldAsVacant to normalize column to "Yes" and "No" values

SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' then 'Yes'
	 WHEN SoldAsVacant = 'N' then 'No'
     ELSE SoldAsVacant END
FROM NashvilleHousing



-- Remove duplicates

WITH RowNumCTE AS (
SELECT *, 
ROW_NUMBER() OVER 
(Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) RowNum
FROM NashvilleHousing)
DELETE from RowNumCTE
WHERE RowNum > 1



-- Delete unnecessary columns

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
