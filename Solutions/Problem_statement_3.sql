use healthcare;

-- Question 1

-- Some complaints have been lodged by patients that they have been prescribed hospital-exclusive medicine 
-- that they can’t find elsewhere and facing problems due to that. Joshua, from the pharmacy management, 
-- wants to get a report of which pharmacies have prescribed hospital-exclusive medicines the most in the
--  years 2021 and 2022. Assist Joshua to generate the report so that the pharmacies who prescribe hospital-exclusive
-- medicine more often are advised to avoid such practice if possible.   

select * from medicine;
select * from prescription;
select * from treatment;
select * from contain;

select 
pharmacyName,
count(m.medicineid) as medicine_count
from prescription p
inner join contain c on c.prescriptionID=p.prescriptionID
inner join medicine m on m.medicineID=c.medicineID
inner join treatment t on t.treatmentID=p.treatmentID
inner join pharmacy p1 on p.pharmacyID=p1.pharmacyID
where year(date) between 2021 and 2022
and hospitalExclusive='s'
group by pharmacyName
order by medicine_count desc;


-- Question 2


-- Insurance companies want to assess the performance of their insurance plans. 
-- Generate a report that shows each insurance plan, the company that issues the plan, 
-- and the number of treatments the plan was claimed for.

select * from insurancecompany;
select * from insuranceplan;
select * from treatment;
select * from claim;


select 
companyname,
planname,
count(t.claimID) as claim_count
from insurancecompany i
inner join insuranceplan ip on ip.companyid=i.companyID
inner join claim c on c.uin=ip.uin
inner join treatment t on t.claimID=c.claimID
group by companyName,planName 
order by claim_count desc ;


-- Question 3 

-- Insurance companies want to assess the performance of their insurance plans.
--  Generate a report that shows each insurance company's name with their most and least claimed insurance plans.


-- update  insurancecompany
--        set companyName='Aditya Birla Health Insurance Co. Ltd'
--        where companyName='Aditya Birla Health Insurance Co. Ltd.';
--        
-- start transaction;

-- UPDATE insurancecompany SET companyName = REPLACE(companyName, '�', '');

-- update insurancecompany set companyName=replace(companyName,'Ltd.','Ltd');

--  UPDATE insurancecompany SET companyName =trim(companyName);

select * from insurancecompany;
select * from insuranceplan;
select * from treatment;
select * from claim;

with cte as (
select 
companyname,
planName,
count(t.claimID) as claim_count
from insurancecompany i 
inner join insuranceplan ip on ip.companyID=i.companyID
inner join claim c on c.uin=ip.uin
inner join treatment t on t.claimID=c.claimID
group by companyName,planName
order by companyName,planName,claim_count desc
),
cte2 as (
select *,row_number() over(partition by companyname order by claim_count desc) as rn
from cte
)
select 
*
from cte2 c1 
where rn=1 
or rn=(
select 
max(rn) 
from cte2 c2 
where c1.companyname=c2.companyname
);
 
 
 
 -- question 4
 
 -- The healthcare department wants a state-wise health report to assess 
 -- which state requires more attention in the healthcare sector. 
 -- Generate a report for them that shows the state name, number of registered people in the state, 
 -- number of registered patients in the state, and the people-to-patient ratio. sort the data by people-to-patient ratio. 
 
 
 select * from person;
 select  * from address;
 select * from patient;
 
 with cte as (
 select 
 state,
 count(personid) as person_count from person p 
 inner join address a on a.addressID=p.addressID
 group by state)
 select
 a.state,
 person_count,
 count(patientid) as patient_count,
 person_count/count(patientid) as people_to_patient_ratio
 from person p
 inner join address a on a.addressid=p.addressid
 inner join patient p1 on p1.patientID=p.personID
 inner join cte on cte.state=a.state
 group by cte.state
 order by people_to_patient_ratio desc;
 
 
 -- question 5
 
 -- Jhonny, from the finance department of Arizona(AZ), has requested a report 
 -- that lists the total quantity of medicine each pharmacy in his state has prescribed 
 -- that falls under Tax criteria I for treatments that took place in 2021. Assist Jhonny in generating the report. 
 
 
 select * from prescription;
 select * from contain;
 select * from medicine;
 
 select 
 pharmacyname,
 sum(quantity) as medicine_quantity
 from contain c
 inner join prescription p on p.prescriptionID=c.prescriptionID
 inner join treatment t on t.treatmentID=p.treatmentID
 inner join pharmacy p2 on p2.pharmacyID=p.pharmacyID
 inner join medicine m on m.medicineID=c.medicineID
 inner join address a on a.addressID=p2.addressID
 where state='AZ'
 and taxCriteria='I'
 and year(date)=2021 
 group by pharmacyname
 order by pharmacyName;
 
 
 drop table insurancecompany;