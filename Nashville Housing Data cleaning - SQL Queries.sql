/*
Cleaning data in SQL Queries
*/
use [Data Analytics Portfolio- DATA CLEANING USING SQL]
select * from Nashville_Housing;

---------------------------------------------------------

--1) Sale Date Formatting from DateTime to Date format

Select Nashville_Housing.SaleDate, CONVERT(Date,saledate) as Date_of_Sale
from Nashville_Housing;

Update Nashville_Housing 
Set SaleDate=CONVERT(Date,saledate) 
--Sometimes this command does not update then we will add a new column using Alter and update that column

Alter Table Nashville_housing
add Date_of_Sale Date;

Update Nashville_Housing
set Date_of_Sale= convert(Date,Saledate)

select * from Nashville_Housing

Alter Table Nashville_housing
drop column SaleDate ;

select * from Nashville_Housing

------------------------------------------------------------------------

--2) Handling missing values
--From excel, using the filter method, we get to know that there are null values in the Property address column.

--checking the total no of rows:
select count(*) from Nashville_Housing;

--checking the no of null values:
select count(*)
from Nashville_Housing
where PropertyAddress is Null;


--So there are basically 29 missing values in the PropertyAddress column.

select * from Nashville_Housing
where PropertyAddress is not null
order by ParcelID;

--By ordering it as per parcelId we see that mostly the addresses are common for the same initial part of parcelId.
--So using that concept we will try to replace the null addresses with addresses from the same parcelID.

--Let's form a temporary table of the old parcelID and old Propert address columns and new parcel ID and new property address column. 
--drop table #NV_temp;
--Create table #NV_temp
--(old_uniqueID float,
--old_ParcelID nvarchar(250),
--old_propertyaddress varchar(300),
--new_uniqueID float,
--new_ParcelId nvarchar(250),
--new_PropertyAddress varchar(300));


--Let's try to create commands to replace the null values in the property address by joining the table with itself but on the basis of same parcelid but not same uniqueid
select old.[UniqueID ],old.ParcelId, old.propertyaddress,new.[UniqueID ],new.parcelId, new.propertyaddress,
isnull(old.propertyaddress, new.PropertyAddress) as final_propadd
--the isnull function checks whether the first argument(old.propadd) is null and if yes then replaces it 
--the second argument(new.propadd).
from Nashville_Housing old
join Nashville_Housing new
on old.ParcelID=new.ParcelID and old.[UniqueID ]!=new.[UniqueID ]
--the above 'on' condition gives you the rows which have the exact same parcelID but not same uniqued ID, which comes around to 11000 rows.
where old.PropertyAddress is Null
--the where clause just picks out the records which has the old property address as Null, as we want to only change them.
--Here we can see that there are 35 records which contradicts with the original 29 null records. This is because
--here we see that there are the same old.unique id is matched with multiple new unique id's which have the same parcel id, ie why 35 number.
--but it is okay as you see eventhough they are multiple all the addresses are same.


--Updating the original table with the commands to replace the null vlaues as  done above

Update old
set old.propertyaddress= isnull(old.propertyaddress, new.PropertyAddress) 
from Nashville_Housing old
join Nashville_Housing new
on old.ParcelID=new.ParcelID and old.[UniqueID ]!=new.[UniqueID ]
where old.PropertyAddress is Null;

--when we execute the update command we see that 29 rows are affected which is the exact missing values and all the values are
--updated in the Property address of the 'old' table which is the original 'Nashville table'.

--Checking whether the 'old' table is updated.

select *,
isnull(old.propertyaddress, new.PropertyAddress) as final_propadd
from Nashville_Housing old
join Nashville_Housing new
on old.ParcelID=new.ParcelID and old.[UniqueID ]!=new.[UniqueID ]
where old.PropertyAddress is Null; 
--No records show up which means that the null values in the 'old' table 'property address' ahs been replaced.

-----------------------------------------------------------------------------------------------

--3) Breaking the Address into address column, city column and state column.

select count(*) from Nashville_Housing
where PropertyAddress is null;
--The above command is to Just check and see if the all the null vlaues had been replaced.

select PropertyAddress from Nashville_Housing;

select SUBSTRING(propertyaddress,1,(charindex(',',Propertyaddress)-1)),
SUBSTRING(propertyaddress,(charindex(',',Propertyaddress)+1),LEN(propertyaddress))
from Nashville_Housing;
-- Substring function extracts a string of a required length from a position specified.
--charindex function searches for a substring in a cloumn and returns its position.
--len() gives the length of the value passed.

--Adding two new columns in the table Nashville:
alter table Nashville_housing
add Property_Address varchar(300);

alter table Nashville_housing
add Property_City varchar(300);

--Updating the two columns with the split address and city:
update Nashville_Housing
set Property_Address=SUBSTRING(propertyaddress,1,(charindex(',',Propertyaddress)-1));

update Nashville_Housing
set Property_City=SUBSTRING(propertyaddress,(charindex(',',Propertyaddress)+1),LEN(propertyaddress)) ;

alter table Nashville_housing
Drop column PropertyAddress;

select * from Nashville_Housing


--Splitting the owner address:
-- You can split it using the 'substring()' and also the 'Parsename()'.
--Parsename() function return the part of the string separated by periods(.) and returns in the backwards order
--ie 1 means the last part of the string separated by period.

Select 
PARSENAME( replace(OwnerAddress,',','.'),3),
PARSENAME( replace(OwnerAddress,',','.'),2),
PARSENAME( replace(OwnerAddress,',','.'),1)
from Nashville_Housing;

--Adding three new columns in the table Nashville:
alter table Nashville_housing
add Owner_Address varchar(300);

alter table Nashville_housing
add Owner_City varchar(300);

alter table Nashville_housing
add Owner_State varchar(300);

--Updating the two columns with the split address and city:
update Nashville_Housing
set Owner_Address=PARSENAME( replace(OwnerAddress,',','.'),3);

update Nashville_Housing
set Owner_City=PARSENAME( replace(OwnerAddress,',','.'),2) ;

update Nashville_Housing
set Owner_State=PARSENAME( replace(OwnerAddress,',','.'),1) ;

alter table Nashville_housing
Drop column OwnerAddress;

Select * from Nashville_Housing


-------------------------------------------------------------------------------------------------------------------------------------

--4) Updating the Sold as Vacant to a numerical categorical column 

-- At a glance there seems to be multiple values in the column, so using 'Distinct' clause we will find the unique values.

Select Distinct(SoldasVacant)
from Nashville_Housing;

--So we will convert the N and No to 0 and Y ad Yes to 1;

Select SoldasVacant,
case
when SoldasVacant = 'N' or Soldasvacant = 'No' then 0
else 1
end as Sold_as_Vacant
from Nashville_Housing;

--Updating the table with the new values in the column SoldasVacant

Update Nashville_Housing
set SoldAsVacant=case
when SoldAsVacant = 'N' or SoldAsVacant = 'No' then 0
else 1
end 
from Nashville_Housing;

--Now to see whether all the values have changed to 0 or 1 and see the count of the total 1 and 0.
Select Distinct(SoldAsVacant),count(*) 
from Nashville_Housing
group by SoldAsVacant
order by SoldAsVacant;
-- So there are 51802 units which were sold as not vacant and 4675 units which were sold as vacant.


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--5) Deleting Duplicate rows.

Select * from Nashville_Housing

--let's take a data to be duplicate if it has the same ParcelID with same Property_Address with same Property_city,
--with same SalePrice, Date_of_Sale and Legalreference.
-- To identify these duplicate rows we use the Row_number() window function

Select *, ROW_NUMBER()
over (Partition By
ParcelID,
Property_Address,
Property_City,
SalePrice,
Date_of_Sale,
Legalreference
order by
uniqueID)
row_num
from Nashville_Housing;
--row_num is the name of the column which will have the Row_numbers.
--The over clause specifies the set of rows or Dataset on which the Row_number function is to be applied.The possible components of the OVER Clause is ORDER BY and PARTITION BY.
--The Partition By clause is optional. It can be used to specify the columns on basis of which the row_number has to be applied. If PARTITION BY clause is not specified, then the OVER clause operates on the all rows of the result set as a single data-set. The Partition clause may consist of one or more columns, a more complex expression, or even a sub-query.
--The order by clause in Over is mandatory to specify how the rows are to be arranged.


--So now for each unique combination of the columns ParcelID,Property_Address,Property_City,SalePrice,Date_of_Sale,Legalreference will be assigned a row_number 1 and any repetition will be assigned 2  and so on.
-- Thus all the row_numbers >1 will be duplicates and can be deleted.

--For doing that let's create a CTE

with cte_nv as
(Select *, ROW_NUMBER()
over (Partition By
ParcelID,
Property_Address,
Property_City,
SalePrice,
Date_of_Sale,
Legalreference
order by
uniqueID)
row_num
from Nashville_Housing)
Select * from cte_nv
where row_num>1;
--This shows that there are 104 duplicate records ie records with row_num>1.
--Let's delete them:

with cte_nv as
(Select *, ROW_NUMBER()
over (Partition By
ParcelID,
Property_Address,
Property_City,
SalePrice,
Date_of_Sale,
Legalreference
order by
uniqueID)
row_num
from Nashville_Housing)
Delete 
from cte_nv
where row_num>1;

--Just checking if there are any duplicate rows left:
with cte_nv as
(Select *, ROW_NUMBER()
over (Partition By
ParcelID,
Property_Address,
Property_City,
SalePrice,
Date_of_Sale,
Legalreference
order by
uniqueID)
row_num
from Nashville_Housing)
Select * from cte_nv
where row_num>1;
----No duplicate records left.

