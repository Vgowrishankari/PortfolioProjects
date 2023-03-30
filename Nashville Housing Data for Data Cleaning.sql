--Nashville Housing Data for Data Cleaning

/* Cleaning Data in SQL Queries */
-- Table: NashvilleHousing

select * from PortfolioProject..NashvilleHousing


/* 1. Standardize Date Format  */

select SaleDate, 
	   convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

--The below query wont update SaleDate directly
update PortfolioProject.dbo.NashvilleHousing
set SaleDate= convert(date,SaleDate)


--So add a new column with date Datatype into existing table

alter table PortfolioProject.dbo.NashvilleHousing
add SaleDateConverted date

--Update SaleDateConverted column as only date of SaleDate
update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted= convert(date,SaleDate)


select SaleDate, 
	   SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

--Drop the existing SaleDate column
alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate

--Rename the new Column SaleDateConverted into SaleDate in IDE itself by using Rename option
--Now you could see only the date part of SaleDate

select * from PortfolioProject.dbo.NashvilleHousing

-------------------------
/* 2. Populate Property Address Data */

--Find the records in which the propertyAddress field is Null
select * from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress is null
order by [UniqueID ]

--Found that if ParcelId is same then propertyaddress also be same
--So get the null propertyaddress records and the propertyaddress for the same based on parcelID 

select a.UniqueID,
	   a.ParcelID,
	   a.PropertyAddress,
	   b.UniqueID,
	   b.ParcelID,
	   b.PropertyAddress, 
	   isnull(a.propertyAddress,b.PropertyAddress) as UpdatedPropertyAddress
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID 
and a.PropertyAddress is null

--Update if the propertyaddress is Null then update it with exact propertyaddress based on parcelID
update a
set a.PropertyAddress= isnull(a.propertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
 on a.ParcelID=b.ParcelID
and a.UniqueID <>b.UniqueID 
and a.PropertyAddress is null

----------------------------------------------------------
/* 3. Breaking out PropertyAddress into Individual column (Address,City,State) */

select PropertyAddress,
	   substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
	   substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing 

--Add column for Address and City 

alter table PortfolioProject.dbo.NashvilleHousing 
add PropertySplitAddress nvarchar(255)


alter table PortfolioProject.dbo.NashvilleHousing 
add PropertySplitCity nvarchar(255)

--Update the new columns PropertySplitAddress,PropertySplitCity into splitted Address and City from PropertyAddress column

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

update PortfolioProject.dbo.NashvilleHousing
set PropertySplitCity =  substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select * from PortfolioProject.dbo.NashvilleHousing
---------------------------------------------------------
/* 4. Breaking out OwnerAddress into Individual column (Address,City,State) */

select OwnerAddress, 
	   PARSENAME(replace(owneraddress,',','.'),3) as Address,
	   PARSENAME(replace(owneraddress,',','.'),2) as City,
	   PARSENAME(replace(owneraddress,',','.'),1) as State
from PortfolioProject.dbo.NashvilleHousing

--Add column for Address, City and State

alter table PortfolioProject.dbo.NashvilleHousing 
add OwnerSplitAddress nvarchar(255)

alter table PortfolioProject.dbo.NashvilleHousing 
add OwnerSplitCity nvarchar(255)

alter table PortfolioProject.dbo.NashvilleHousing 
add OwnerSplitState nvarchar(255)

--Update the new columns OwnerSplitAddress,OwnerSplitCity,OwnerSplitState into splitted Address and City from OwnerAddress column

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress,',','.'),3) 

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress,',','.'),2) 

update PortfolioProject.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress,',','.'),1)

select * from PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------

/* 5. Change Y and N to Yes and No in 'SoldAsVacant' Field */


select distinct(SoldAsVacant), 
       count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by count(SoldAsVacant)

select SoldAsVacant, 
	   case when SoldAsVacant='N' then 'No'
			when SoldAsVacant ='Y' then 'Yes'
			else SoldAsVacant
	   End) as UpdatedSoldAsVacant
from PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant not in('Yes','No')

select count(*)
from PortfolioProject.dbo.NashvilleHousing
where SoldAsVacant not in('Yes','No')

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant=(case when SoldAsVacant='N' then 'No'
					   when SoldAsVacant ='Y' then 'Yes'
					   else SoldAsVacant
				  End)
where SoldAsVacant not in('Yes','No')

----------------------------------------------------------------------
/* 6. Remove Duplicates */

select * from PortfolioProject.dbo.NashvilleHousing

with CTE_Duplicate as(
select *, dense_rank() over(partition by 
							ParcelId,
							PropertyAddress,
							SalePrice,
							LegalReference,
							SaleDate
order by UniqueId)RowNumber
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelId desc
)
select * from CTE_Duplicate
where RowNumber>1
order by ParcelId desc

--Delete the duplicate records
with CTE_Duplicate as(
select *, dense_rank() over(partition by 
							ParcelId,
							PropertyAddress,
							SalePrice,
							LegalReference,
							SaleDate
order by UniqueId)RowNumber
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelId desc
)
delete from CTE_Duplicate
where RowNumber>1

---------------------------------------------------------------
/* 7. Remove unused Columns */


select * from PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress,TaxDistrict

