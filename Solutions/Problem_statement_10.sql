use healthcare;

-- Question 1 

-- The healthcare department has requested a system to analyze the performance of insurance companies and their plan.
-- For this purpose, create a stored procedure that returns the performance of different insurance plans of an insurance 
-- company. When passed the insurance company ID the procedure should generate and return all the insurance plan names 
-- the provided company issues, the number of treatments the plan was claimed for, and the name of the disease the plan 
-- was claimed for the most. The plans which are claimed more are expected to appear above the plans that are claimed less.

delimiter $$
create procedure insurance_analysis(
in id int
) 
begin 
with cte as (
select
companyid,
diseasename,
planname,
count(claimid) as treatment_count,
row_number() over(partition by planname order by count(treatmentID) desc) as rn
from insuranceplan ip 
inner join insurancecompany using(companyid)
inner join claim using(uin)
inner join treatment using(claimid)
inner join disease using(diseaseid)   
group by 1,2,3
order by 1,2,3 desc)
select planname,
diseasename,
treatment_count 
from cte where companyid=id and rn=1;
end
$$

delimiter ;

drop procedure insurance_analysis;
call insurance_analysis(1839);
 

-- Question 2 

-- It was reported by some unverified sources that some pharmacies are more popular for certain diseases.
--  The healthcare department wants to check the validity of this report.
-- Create a stored procedure that takes a disease name as a parameter and would return the top 3 pharmacies 
-- the patients are preferring for the treatment of that disease in 2021 as well as for 2022.
-- Check if there are common pharmacies in the top 3 list for a disease, in the years 2021 and the year 2022.
-- Call the stored procedure by passing the values “Asthma” and “Psoriasis” as disease names and draw a conclusion from the result.


delimiter $$

create procedure disease_analysis(
in d_name varchar(100)
)
begin 
with cte as (
select diseasename,
pharmacyname,
year(date) as year,
count(*) as m_count,
row_number() over(partition by diseasename,year(date) order by count(*) desc) as rn
from disease d
inner join treatment t using(diseaseid)
inner join prescription p using(treatmentid)
inner join pharmacy p1 using(pharmacyid)
where year(date) in (2021,2022)
group by 1,2,3
order by 1,3,4 desc)
select pharmacyname,year,m_count from cte where diseasename=d_name and rn<4;
end
$$

delimiter ;

drop procedure disease_analysis;
call disease_analysis('asthma');


-- Question 3 

-- Jacob, as a business strategist, wants to figure out if a state is appropriate for setting up an insurance company or not.
-- Write a stored procedure that finds the num_patients, num_insurance_companies, and insurance_patient_ratio, 
-- the stored procedure should also find the avg_insurance_patient_ratio and if the insurance_patient_ratio of 
-- the given state is less than the avg_insurance_patient_ratio then it Recommendation section can have the value 
-- “Recommended” otherwise the value can be “Not Recommended”.

-- Description of the terms used:
-- num_patients: number of registered patients in the given state
-- num_insurance_companies:  The number of registered insurance companies in the given state
-- insurance_patient_ratio: The ratio of registered patients and the number of insurance companies in the given state
-- avg_insurance_patient_ratio: The average of the ratio of registered patients and the number of insurance for all the states.

delimiter $$ 

create procedure state_analysis(
in state_name varchar(10)
)
begin 
select state,
count(personID) as person_count,
count(patientID) as patient_count,
count(companyid) as company_count,
count(companyid)/count(patientID) as insurance_patient_ratio
from patient p  
right join person p1 on p.patientID=p1.personID
inner join address a using(addressid)
left join insurancecompany ic using(addressid)
where state=state_name
group by 1;
end 
$$

delimiter ;
call state_analysis('ar');

select state,
count(personID) as person_count,
count(patientID) as patient_count,
count(companyid) as company_count,
count(companyid)/count(patientID) as insurance_patient_ratio
from patient p  
right join person p1 on p.patientID=p1.personID
inner join address a using(addressid)
left join insurancecompany ic using(addressid)
group by 1;

 
 
 -- Question 4
 
--  Currently, the data from every state is not in the database, The management has decided to add the data from 
--  other states and cities as well. It is felt by the management that it would be helpful if the date and time 
--  were to be stored whenever new city or state data is inserted.
-- The management has sent a requirement to create a PlacesAdded table if it doesn’t already exist, that has four 
-- attributes. placeID, placeName, placeType, and timeAdded.
-- Description
-- placeID: This is the primary key, it should be auto-incremented starting from 1
-- placeName: This is the name of the place which is added for the first time
-- placeType: This is the type of place that is added for the first time. The value can either be ‘city’ or ‘state’
-- timeAdded: This is the date and time when the new place is added

-- You have been given the responsibility to create a system that satisfies the requirements of the management.
--  Whenever some data is inserted in the Address table that has a new city or state name, the PlacesAdded table 
--  should be updated with relevant data. 

create table place_add (
placeid int auto_increment primary key,
place_name varchar(100),
place_type varchar(100),
time_added datetime default current_timestamp()
);

delimiter $$
create trigger place_add_trigger
before insert
on address
for each row
begin 
declare placename varchar(100);
declare placetype VARCHAR(100);
declare state_count INT;
    
select count(*) into state_count from address where state = new.state;
    
if state_count = 1 
then
set placename=new.city;
set placetype = 'city';
else
set placename=new.state;
set placetype = 'state';
end if;
insert into place_add(place_name,place_type) values(placename,placetype);
end
$$

delimiter ;

delete from address where addressID=999999;
insert into address(addressid,address1,city,state,zip) values(999999,'charan street','hyderabad','zi',500049);

select * from place_add;


drop table place_add;
drop trigger place_add_trigger;


-- Question 5

-- Some pharmacies suspect there is some discrepancy in their inventory management. The quantity in 
-- the ‘Keep’ is updated regularly and there is no record of it. They have requested to create a 
-- system that keeps track of all the transactions whenever the quantity of the inventory is updated.
-- You have been given the responsibility to create a system that automatically updates a Keep_Log table which has  the following fields:
-- id: It is a unique field that starts with 1 and increments by 1 for each new entry
-- medicineID: It is the medicineID of the medicine for which the quantity is updated.
-- quantity: The quantity of medicine which is to be added. If the quantity is reduced then the number can be negative.
-- For example:  If in Keep the old quantity was 700 and the new quantity to be updated is 1000, then in Keep_Log the quantity should be 300.
-- Example 2: If in Keep the old quantity was 700 and the new quantity to be updated is 100, then in Keep_Log the quantity should be -600.

  
create table keep_log(
id int auto_increment primary key,
medicine_id int,
quantity int
);


delimiter $$ 

create trigger keep_log_trigger
before update 
on keep 
for each row
begin
declare updated_quantity int;
set updated_quantity=new.quantity-old.quantity;
insert into keep_log(medicine_id,quantity) values(new.medicineid,updated_quantity);
end
$$ 

delimiter ;

select * from keep;

update keep set quantity=1737 where pharmacyid=3287 and medicineid=17648;

select * from keep_log;

drop table keep_log;

drop trigger keep_log_trigger;








