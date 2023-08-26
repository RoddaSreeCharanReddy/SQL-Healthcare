use healthcare;


-- Question 1 

-- Patients are complaining that it is often difficult to find some medicines. They move from pharmacy 
-- to pharmacy to get the required medicine. A system is required that finds the pharmacies and their 
-- contact number that have the required medicine in their inventory. So that the patients can contact 
-- the pharmacy and order the required medicine.Create a stored procedure that can fix the issue.

delimiter $$

create procedure pharmacy_analysis(
in medicine_name varchar(100)
)
begin 
select pharmacyname,
phone,
productname
from  pharmacy p
inner join prescription p1 using(pharmacyid)
inner join contain c using(prescriptionid)
inner join medicine using(medicineid)
where productname=medicine_name;
end
$$

delimiter ;

call pharmacy_analysis('OSTENAN');

drop procedure pharmacy_analysis;


-- Question 2 

-- The pharmacies are trying to estimate the average cost of all the prescribed medicines per prescription, 
-- for all the prescriptions they have prescribed in a particular year. Create a stored function that will 
-- return the required value when the pharmacyID and year are passed to it. Test the function with multiple values.


delimiter $$

create function cost_analysis(pharmacy_id int,inp_year int) returns int
deterministic
begin 
declare avg_val int;
select avg(maxPrice*quantity) into avg_val
from medicine m 
inner join contain c using(medicineid)
inner join prescription p using(prescriptionid)
inner join treatment t using(treatmentid)
where pharmacyID=pharmacy_id
and year(date)=inp_year
group by pharmacyID,year(date);
return avg_val;
end
$$

delimiter ;

drop function cost_analysis;

select cost_analysis(1008,2021);

select * from pharmacy;

-- Question 3 

-- The healthcare department has requested an application that finds out the disease that was spread
--  the most in a state for a given year. So that they can use the information to compare the historical 
--  data and gain some insight.
-- Create a stored function that returns the name of the disease for which the patients from a particular 
-- state had the most number of treatments for a particular year. Provided the name of the state and year 
-- is passed to the stored function.


delimiter $$ 
create function disease_analysis(state_name varchar(10),my_year int) returns varchar(100)
deterministic
begin
declare disease_name varchar(100);
with cte as (
select diseasename,count(treatmentID),
row_number() over(order by count(treatmentID) desc) as rn
from address a 
inner join person p using(addressid)
inner join treatment t on t.patientID=p.personID
inner join disease d using(diseaseid)
where state=state_name
and year(date)=my_year
group by state,diseaseName,year(date))
select diseasename into disease_name from cte where rn=1; 
return disease_name;
end
$$

delimiter ;
drop function disease_analysis;

select disease_analysis('al',2022);



-- Question 4 

-- The representative of the pharma union, Aubrey, has requested a system that she can use to find how many people 
-- in a specific city have been treated for a specific disease in a specific year.
-- Create a stored function for this purpose.

select 

delimiter $$

create function people_analysis(city_name varchar(100),disease_name varchar(100),my_year int)returns int
deterministic
begin 
declare treatment_count int;
select count(treatmentid) into treatment_count 
from treatment t
inner join person p on t.patientID=p.personID
inner join address using(addressid)
inner join disease d using(diseaseid)
where city=city_name
and year(date)=my_year
and diseaseName=disease_name;
return treatment_count;
end
$$

delimiter ;
select people_analysis('arvada','cancer',2021);


-- question 5 


-- The representative of the pharma union, Aubrey, is trying to audit different aspects of the pharmacies.
--  She has requested a system that can be used to find the average balance for claims submitted by a specific 
--  insurance company in the year 2022. 
-- Create a stored function that can be used in the requested application.

delimiter $$

create function pharmacy_analysis(company_id int)returns int
deterministic
begin
declare avg_balance int;
select avg(balance) into avg_balance 
from claim c
inner join insuranceplan using(uin)
inner join insurancecompany using(companyid)
inner join treatment using(claimid)
where year(date)=2022
and companyID=company_id
group by companyID;
return avg_balance;
end
$$

delimiter ;
select * from insurancecompany;
select pharmacy_analysis(1839);



 






