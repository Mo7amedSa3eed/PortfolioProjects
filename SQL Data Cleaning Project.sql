select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
Select saleDateCleaned, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing$


Update PortfolioProject..NashvilleHousing$
SET SaleDate = CONVERT(Date,SaleDate)

Select saleDateCleaned
From PortfolioProject..NashvilleHousing$

-- If it doesn't Update properly

alter table PortfolioProject..NashvilleHousing$
add SaleDateCleaned date

 update PortfolioProject..NashvilleHousing$
 set SaleDateCleaned = CONVERT(date,SaleDate)

select SaleDateCleaned
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select Nash1.[UniqueID ],Nash1.ParcelID,Nash1.PropertyAddress,NAsh2.[UniqueID ], Nash2.ParcelID,Nash2.PropertyAddress
from PortfolioProject..NashvilleHousing$ as Nash1 join PortfolioProject..NashvilleHousing$ as Nash2
	on Nash1.ParcelID = Nash2.ParcelID and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
where Nash1.PropertyAddress is null
order by Nash1.[UniqueID ]

update Nash1
set  PropertyAddress = ISNULL( Nash1.PropertyAddress,Nash2.PropertyAddress)
from PortfolioProject..NashvilleHousing$ as Nash1 join PortfolioProject..NashvilleHousing$ as Nash2
	on Nash1.ParcelID = Nash2.ParcelID and Nash1.[UniqueID ] <> Nash2.[UniqueID ]
where Nash1.PropertyAddress is null

select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject..NashvilleHousing$

alter table PortfolioProject..NashvilleHousing$
add Address NVArChar(255),City NVArChar(255)

 update PortfolioProject..NashvilleHousing$
 set Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1 ) 
	, City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1 ,LEN(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

select OwnerAddress
from PortfolioProject..NashvilleHousing$

alter table PortfolioProject..NashvilleHousing$
add OwnAddress NVArChar(255),OwnCity NVArChar(255),OwnState NVArChar(255)

 update PortfolioProject..NashvilleHousing$
 set OwnAddress = PARSENAME(Replace(OwnerAddress,',','.'),3) 
	, OwnCity = PARSENAME(Replace(OwnerAddress,',','.'),2)
	, OwnState = PARSENAME(Replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
select SoldAsVacant,count(SoldAsVacant)
from PortfolioProject..NashvilleHousing$
group by SoldAsVacant
order by 2


update PortfolioProject..NashvilleHousing$
set SoldAsVacant = Case 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						Else SoldAsVacant
					end 
from PortfolioProject..NashvilleHousing$

select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
With CTE_RowNumber as (
select *,ROW_NUMBER() Over ( Partition by ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldAsVacant
										,OwnerName,OwnerAddress,Acreage,TaxDistrict,LandValue,BuildingValue,TotalValue
										,YearBuilt,Bedrooms,FullBath,HalfBath order by UniqueID) as Row_Num
from PortfolioProject..NashvilleHousing$
)

delete
from CTE_RowNumber
where Row_Num > 1

select *
from PortfolioProject..NashvilleHousing$

-------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Alter Table PortfolioProject..NashvilleHousing$
Drop Column PropertyAddress,SaleDate,OwnerAddress

select*
from PortfolioProject..NashvilleHousing$