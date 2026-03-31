select *
from nashville_housing_data_for_data_cleaning;

-- Standardize Data Format

select SaleDate
from nashville_housing_data_for_data_cleaning;

-- Populate Property Address Data
select PropertyAddress
from nashville_housing_data_for_data_cleaning
# where PropertyAddress is null
order by ParcelID;

select
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    ifnull(a.PropertyAddress, b.PropertyAddress)
from nashville_housing_data_for_data_cleaning a
join nashville_housing_data_for_data_cleaning b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update nashville_housing_data_for_data_cleaning a
join nashville_housing_data_for_data_cleaning b
    on a.ParcelID = b.ParcelID
    and a.UniqueID <> b.UniqueID
set a.PropertyAddress = ifnull(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress is null;

-- Breaking Put Address Into Columns (Address,City,state)
select PropertyAddress
from nashville_housing_data_for_data_cleaning;

select substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as address,
       substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress)) as city
from nashville_housing_data_for_data_cleaning;
-- Address
alter table nashville_housing_data_for_data_cleaning
add PropertySplitAddress varchar(255);

update nashville_housing_data_for_data_cleaning
set PropertySplitAddress = substring(PropertyAddress,1,locate(',',PropertyAddress)-1);
-- city
alter table nashville_housing_data_for_data_cleaning
add PropertySplitCity varchar(255);

update nashville_housing_data_for_data_cleaning
set PropertySplitCity = trim(substring(PropertyAddress, locate(',', PropertyAddress) + 1, length(PropertyAddress)));

-- Checking
select PropertySplitAddress
from nashville_housing_data_for_data_cleaning;

select PropertySplitCity
from nashville_housing_data_for_data_cleaning;
-- Breaking the Owner Address
select OwnerAddress
from nashville_housing_data_for_data_cleaning;

-- street
select substring_index(OwnerAddress, ',', 1) as street
from nashville_housing_data_for_data_cleaning;

-- city
select substring_index(substring_index(OwnerAddress, ',', 2), ',', -1) as city
from nashville_housing_data_for_data_cleaning;

-- state
select substring_index(OwnerAddress, ',', -1) as state
from nashville_housing_data_for_data_cleaning;


alter table nashville_housing_data_for_data_cleaning
add OwnerSplitStreet varchar(255),
add OwnerSplitCity varchar(255),
add OwnerSplitState varchar(255);

update nashville_housing_data_for_data_cleaning
set OwnerSplitStreet = substring_index(OwnerAddress, ',', 1),
    OwnerSplitCity = substring_index(substring_index(OwnerAddress, ',', 2), ',', -1),
    OwnerSplitState = substring_index(OwnerAddress, ',', -1);

-- Checking
select OwnerAddress,OwnerSplitStreet,OwnerSplitCity,OwnerSplitState
    from nashville_housing_data_for_data_cleaning;

-- change Y and N to Yes And No

select distinct SoldAsVacant,count(SoldAsVacant)
from nashville_housing_data_for_data_cleaning
group by SoldAsVacant
order by 2;

update nashville_housing_data_for_data_cleaning
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y';

update nashville_housing_data_for_data_cleaning
set SoldAsVacant = 'No'
where SoldAsVacant = 'N';

-- Remove the Duplicate

select *,row_number() over (partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference order by UniqueID) row_num
from nashville_housing_data_for_data_cleaning;

with row_num_cte as (
    select UniqueID,
        row_number() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                           order by UniqueID) as row_num
    from nashville_housing_data_for_data_cleaning
)
select *  from nashville_housing_data_for_data_cleaning
where UniqueID in (select UniqueID from row_num_cte where row_num > 1);


-- delete unused columns
alter table nashville_housing_data_for_data_cleaning
drop column SaleDate



















