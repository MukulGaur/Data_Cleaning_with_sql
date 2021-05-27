Select *
From nashville_housing..nh



-- Standardize The Date Format


Select saleDate, CONVERT(Date,SaleDate) AS DATE
From nashville_housing..nh



ALTER TABLE nh
Add SaleDateConverted Date;

Update nh
SET SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Address data

Select *
From nashville_housing..nh
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_housing..nh a
JOIN nashville_housing..nh b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From nashville_housing..nh a
JOIN nashville_housing..nh b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From nashville_housing..nh


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From nashville_housing..nh


ALTER TABLE nh
Add PropertySplitAddress Nvarchar(255);

Update nh
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nh
Add PropertySplitCity Nvarchar(255);

Update nh
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From nashville_housing..nh





Select OwnerAddress
From nashville_housing..nh


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From nashville_housing..nh



ALTER TABLE nh
Add OwnerSplitAddress Nvarchar(255);

Update nh
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nh
Add OwnerSplitCity Nvarchar(255);

Update nh
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE nh
Add OwnerSplitState Nvarchar(255);

Update nh
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashville_housing..nh





-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashville_housing..nh
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing..nh

Update nh
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




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

From nashville_housing..nh
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From nashville_housing..nh




-- Delete Unused Columns



Select *
From nashville_housing..nh


ALTER TABLE nashville_housing..nh
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

