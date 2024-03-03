select * from 	housing_data;


-- Change column name 
show columns from housing_data;
ALTER TABLE housing_data
CHANGE COLUMN `ï»¿UniqueID` UniqueID INT;

show columns from housing_data;

-- Populate  Property address
select * from housing_data
order by ParcelID;

select a.ParcelID, a.PropertyAddress,
b.ParcelID, b.PropertyAddress, 
 IF(a.PropertyAddress = '', b.PropertyAddress, a.PropertyAddress) AS a_PropertyAddress
from housing_data as a join housing_data as b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress = '';

-- enable update
SET SQL_SAFE_UPDATES = 0;

UPDATE housing_data AS a
JOIN housing_data AS b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress = '' AND b.PropertyAddress <> '';

-- disable update
SET SQL_SAFE_UPDATES = 1;
-- Addition of columns to represent address, city columns
-- Property and Owner's address split
select substring_index(PropertyAddress,',',1) as address,
substring_index(PropertyAddress,',',-1) as city
from housing_data;

alter table housing_data
add City Varchar(244);
SET SQL_SAFE_UPDATES = 1;

update housing_data
set city = substring_index(PropertyAddress,',',-1) ;
-- Column Address
alter table housing_data
add Address Varchar(244);
SET SQL_SAFE_UPDATES = 1;
update housing_data
set address = substring_index(PropertyAddress,',',1) ;

select substring_index(OwnerAddress,',',1) as OwnerAddress,
substring_index(substring_index(OwnerAddress,',',2),',',-1) as City,
substring_index(OwnerAddress,',',-1) as State
from housing_data;

alter table housing_data
add owneraddress1 varchar(255);
SET SQL_SAFE_UPDATES = 0;
update housing_data
set owneraddress1 = substring_index(OwnerAddress,',',1);

alter table housing_data
add Owner_city varchar(255);
alter table housing_data
add Owner_state varchar(255);

update housing_data
set owner_City = substring_index(substring_index(OwnerAddress,',',2),',',-1); 

update housing_data
set owner_State = substring_index(OwnerAddress,',',-1) ;

SET SQL_SAFE_UPDATES = 1;


-- Change Y and N to Yes and No in 'Sold to Vacant'

select distinct(SoldAsVacant),count(SoldAsVacant)
from housing_data
group by SoldAsVacant;

select 
case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end as SoldAsVacant,SoldAsVacant
from housing_data 
where soldasvacant in ('Y','N') limit 1000;


set SQL_SAFE_UPDATES = 0;
Update housing_data
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
else SoldAsVacant end;



-- Remove Duplicates
with rownumCTE as (	
select *,
	row_number() over( 
		partition by ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate
                    order by UniqueID
					  ) as row1
 from housing_data
 )
 
select * from rownumCTE where row1  = 1;

-- Delete Unused Columns
select * from housing_data;

alter table housing_data
drop column OwnerAddress, 
drop column TaxDistrict,
drop column PropertyAddress;
 

 

 
 