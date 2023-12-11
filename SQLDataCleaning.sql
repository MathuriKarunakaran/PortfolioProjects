-- Cleaning Data in SQL Queries

Select * 
From NashvilleHousing

-- Change SaleDate Format

Select SaleDate, CONVERT(Date,SaleDate) 
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing 
ALTER COLUMN SaleDate DATE


-- Populate PropertyAddress Date

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Property Address into Individual Columns (Address, City)


Select PropertyAddress
From NashvilleHousing

Select 
SUBSTRING (PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1 ) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing


ALTER TABLE NashvilleHousing 
Add PropertySplitAddress Nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1 )

ALTER TABLE NashvilleHousing 
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))

Select * 
From NashvilleHousing


-- Breaking Owner Address into Individual Columns (Address, City, State)

Select OwnerAddress
From NashvilleHousing

Select 
PARSENAME (Replace(OwnerAddress,',','.'),3)
,PARSENAME (Replace(OwnerAddress,',','.'),2)
,PARSENAME (Replace(OwnerAddress,',','.'),1)
From NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (Replace(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (Replace(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (Replace(OwnerAddress,',','.'),1)


Select * 
From NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   End



-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) run_num
From NashvilleHousing
--Order by ParcelID
)
Select*
From RowNumCTE
Where run_num > 1
Order by PropertyAddress



WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() Over(
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) run_num
From NashvilleHousing
--Order by ParcelID
)
Delete
From RowNumCTE
Where run_num > 1
--Order by PropertyAddress



-- Delete Unused Columns (Property Address, Owner Address and TaxDistrict)

ALTER TABLE NashvilleHousing 
DROP COLUMN  PropertyAddress,OwnerAddress, TaxDistrict

Select * 
From NashvilleHousing