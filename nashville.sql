/* cleaning data in sql queries */ 


SELECT * 
FROM PortfolioProject..NashvilleHousing

--standarize date format 

SELECT SaleDate, convert(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

update NashvilleHousing
set SaleDate =CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date


update NashvilleHousing
set SaleDate =CONVERT(date,SaleDate)


SELECT  SaleDateConverted, convert(date,SaleDate)
FROM PortfolioProject..NashvilleHousing

--populate property adress data 

--SELECT  PropertyAddress
--FROM PortfolioProject..NashvilleHousing
--where PropertyAddress is null

select * 
from PortfolioProject..NashvilleHousing
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a 
join PortfolioProject..NashvilleHousing b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]

--breaking out adress into individual(adress , city , state) 

select PropertyAddress 
from PortfolioProject..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as adress 
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as adress 

from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);


update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCIty nvarchar(255)


update NashvilleHousing
set PropertySplitCIty = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))


select * 
from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is not null


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE porftolioPorject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing


--change y and n to yes and no in ''sold as vanact'' field 

select distinct(SoldAsVacant) ,count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2 


select SoldAsVacant,
case when SoldAsVacant = '/Y' then 'yes'
	when SoldAsVacant = '/n' then 'no' 
	else SoldAsVacant
	end
from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = '/Y' then 'yes'
	when SoldAsVacant = '/n' then 'no' 
	else SoldAsVacant
	end

	--remove duplicates 

	with RowNumCTE as (
	select * ,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				order by 
				UniqueID
				)row_num
	from PortfolioProject..NashvilleHousing
	)

	select * 
	from RowNumCTE
	where row_num>1 
	--order by PropertyAddress

	-------------------------------------------


	--delete unused colums 

	select * 
	from PortfolioProject..NashvilleHousing

	alter table PortfolioProject..NashvilleHousing
	drop column OwnerAddress,TaxDistrict,PropertyAddress
