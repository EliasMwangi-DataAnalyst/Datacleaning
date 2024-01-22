
--standardize date format
Select SaleDateConverted, Convert(Date,Saledate)
From NashvilleHousing

Update NashvilleHousing
Set Saledate = Convert(Date,Saledate)

Alter table nashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set Saledate = Convert(Date,Saledate)

Select SaleDateConverted, Convert(Date,Saledate)
From NashvilleHousing

--Populate property address data

Select *
From NashvilleHousing
--where PropertyAddress is Null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is Null

--breaking address into individual columns (address, city, state)

Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

Alter table nashvilleHousing
Add PropertySplitAddress NVarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

Alter table nashvilleHousing
Add PropertySplitCity NVarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From NashvilleHousing

-- Separating the owner Address using Parsename

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From NashvilleHousing

Alter table nashvilleHousing
Add OwnerSplitAdress NVarchar(255);

Update NashvilleHousing
Set OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

Alter table nashvilleHousing
Add OwnerSplitCity NVarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

Alter table nashvilleHousing
Add OwnerSplitState NVarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

Select *
From NashvilleHousing

--Change Y and N to Yes and No in SoldAsVacant

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'YES'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates

With RowNumCTE AS(
Select*,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by
			     UniqueID
				 ) row_num
From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress

--Deleting the duplicates

With RowNumCTE AS(
Select*,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   Order by
			     UniqueID
				 ) row_num
From NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--order by PropertyAddress

--Delete Unused columns
Select *
From NashvilleHousing

alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

