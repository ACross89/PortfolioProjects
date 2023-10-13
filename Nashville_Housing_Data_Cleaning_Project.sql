--standardnize the date format

select *
from PortfolioProject.dbo.NashvilleHousing

select SaleDateEdit, convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateEdit Date

update NashvilleHousing
set SaleDateEdit = convert(date,SaleDate)


--split the addresses by street, city, state
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null

select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress =  isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertyAddressSplit nvarchar(255)

update NashvilleHousing
set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertyCitySplit nvarchar(255)

update NashvilleHousing
set PropertyCitySplit = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))



--replaces the . with , then removes the ,
select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing




alter table NashvilleHousing
add OwnerAddressSplit nvarchar(255)

update NashvilleHousing
set OwnerAddressSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCitySplit nvarchar(255)

update NashvilleHousing
set OwnerCitySplit = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerStateSplit nvarchar(255)

update NashvilleHousing
set OwnerStateSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


--turns all the N and Y into No and Yes

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

--removes duplicates

with RowNumCTE as(
select *,
row_number() over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
Order by uniqueID
) row_num

from PortfolioProject.dbo.NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- delete unwanted columns
select*
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate
