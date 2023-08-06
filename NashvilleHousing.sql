/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

--------------------------------------------------------------------------------

-- Populate Property Adress data

Select *
From PortfolioProject..NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is NULL

Select *
From PortfolioProject..NashvilleHousing
Where NashvilleHousing.PropertyAddress is NULL

--------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

	--> PropertyAddress

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select PortfolioProject..NashvilleHousing.PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

	--> OwnerAddress

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerySplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------

-- Change 1 and 0 to Yes and No in "Sold as vacant" field

Select Distinct(SoldAsVacant)
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SoldAsVacant nvarchar(50)

Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = '1' Then 'Yes'
				When SoldAsVacant = '0' Then 'No'
				END

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant


--------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1


--------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate