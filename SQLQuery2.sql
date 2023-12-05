/*

Cleaning Data in SQL Queries
select  distinct datepart(year,SaleDate),*
from NashvilleHousing
where datepart(year,SaleDate)= '2019'

*/
select *
from NashvilleHousing

--Standardize Data Format 
select SaleDateConverted, CONVERT(Date,saledate)
from NashvilleHousing

update NashvilleHousing
SET SaleDate= CONVERT(Date,saledate)

Alter Table NashvilleHousing
Add SaleDateConverted Date

update NashvilleHousing
SET SaleDateConverted =CONVERT(Date,saledate)

--populate property Adress data

select * 
from NashvilleHousing
where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.propertyaddress,  b.ParcelID, b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
JOIN  NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
SET propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHousing a
JOIN  NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--Breaking out Address Ýnto Ýndividual Columns (Adress,City,State)

select PropertyAddress 
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress) -1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress)) as address

from NashvilleHousing

Alter Table NashvilleHousing
Add propertysplitaddress nvarchar(255)

update NashvilleHousing
SET propertysplitaddress =SUBSTRING(propertyaddress,1, CHARINDEX(',',propertyaddress) -1)

Alter Table NashvilleHousing
Add propertysplitcity nvarchar(255)

update NashvilleHousing
SET propertysplitcity =SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress))

select distinct propertysplitcity, count([UniqueID ])
from NashvilleHousing
group by propertysplitcity

--ANTIOCH(Antakya), Amerika Birleþik Devletleri'nin Kaliforniya eyaletindeki Contra Costa County'nin üçüncü büyük þehridir. 
--4 Temmuz 1851'deki kasaba pikniði sýrasýnda, kasabanýn yeni belediye baþkaný William, sakinleri kasabanýn adýný Ýncil'deki
--Antakya 'dan esinlenerek Antakya olarak deðiþtirmeye ikna etti.

select OwnerAddress
from NashvilleHousing

select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)

from NashvilleHousing

Alter Table NashvilleHousing
Add ownersplitaddress nvarchar(255)

update NashvilleHousing
SET ownersplitaddress =parsename(replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
Add ownersplitcity nvarchar(255)

update NashvilleHousing
SET ownersplitcity =parsename(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add ownersplitstate nvarchar(255)

update NashvilleHousing
SET ownersplitstate =parsename(replace(OwnerAddress,',','.'),1)

select distinct ownersplitstate, count(PropertyAddress)
from NashvilleHousing
group by ownersplitstate

select distinct soldasvacant,count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2

select soldasvacant,
case when soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant 
	 END
from nashvilleHousing 


UPDATE  nashvilleHousing
SET soldasvacant =case when soldasvacant = 'Y' THEN 'Yes'
     WHEN soldasvacant = 'N' THEN 'No'
	 ELSE soldasvacant 
	 END

	 --Remove Duplicates
with RowNumCte as(
select *,
ROW_NUMBER() OVER (PARTITION BY ParcelID, propertyaddress,saleprice,saledate,legalreference order by uniqueID) row_num
from nashvilleHousing) 
--order by ParcelID)
--DELETE
select *
from RowNumCte
where row_num>1
order by PropertyAddress

--Delete Unused Columns

select * 
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN Propertyaddress,owneraddress,saledate,taxdistrict