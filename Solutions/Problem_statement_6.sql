use healthcare;

-- Question 1 

-- The healthcare department wants a pharmacy report on the percentage of hospital-exclusive medicine prescribed in the year 2022.
-- Assist the healthcare department to view for each pharmacy, the pharmacy id, pharmacy name, 
-- total quantity of medicine prescribed in 2022, total quantity of hospital-exclusive medicine prescribed 
-- by the pharmacy in 2022, and the percentage of hospital-exclusive medicine to the total medicine prescribed in 2022.
-- Order the result in descending order of the percentage found. 

select * from pharmacy;
select * from medicine;
select * from treatment;
select * from prescription;
select * from contain;

select 
pharmacyid,
pharmacyname,
sum(quantity) as total_medicine_quantity,
sum(case when hospitalExclusive='s' then quantity end) as hospital_exclusive_quantity,
sum(case when hospitalExclusive='s' then quantity end)*100/sum(quantity) as percent
from pharmacy p 
inner join prescription p1 using(pharmacyid)
inner join treatment t using (treatmentid)
inner join contain c using(prescriptionid)
inner join medicine m using(medicineid)
where year(date)=2022
group by pharmacyID,pharmacyName;
 
 -- Question 2 
 
--  Sarah, from the healthcare department, has noticed many people do not claim insurance for their treatment.
--  She has requested a state-wise report of the percentage of treatments that took place without claiming insurance. 
--  Assist Sarah by creating a report as per her requirement.


select * from treatment;
select * from person;
select * from address;

select 
state,
count(treatmentid) as total_treatments,
count(case when claimid is null then 1 else null end) as no_claims,
count(case when claimid is null then 1 else null end)*100/count(treatmentid) as percent
from treatment t 
inner join person p on p.personID=t.patientID
inner join address a using(addressid)
group by state
order by state;




-- Question 3 


-- Sarah, from the healthcare department, is trying to understand if some diseases are spreading in a particular region.
--  Assist Sarah by creating a report which shows for each state, the number of the most and least treated 
--  diseases by the patients of that state in the year 2022.

with cte as (
select 
state,
diseasename,
count(treatmentID) as treatment_count,
dense_rank() over(partition by state order by count(treatmentID) desc) as rn
from treatment t 
inner join person p on p.personID=t.patientID
inner join address a using(addressid)
inner join disease d using(diseaseid)
where year(date)=2022
group by state,diseaseName
)
select 
state,
diseasename,
treatment_count 
from cte c1 
where rn=1 
or rn=(
select max(rn) from cte c2 where c1.state=c2.state);


-- question 4 


-- Manish, from the healthcare department, wants to know how many registered people are registered as 
-- patients as well, in each city. Generate a report that shows each city that has 10 or more registered 
-- people belonging to it and the number of patients from that city as well as the percentage of the patient 
-- with respect to the registered people. 

with cte as (
select
state, 
city,
count( personid) as person_count 
from address a 
inner join person p using(addressid)
group by state,city),
cte2 as (
select 
state,
city,
count( distinct personid) as patient_count
from address a 
inner join person p using(addressid)
inner join treatment t on t.patientid=p.personid
group by state,city)
select 
c1.state,
c1.city,
person_count,
patient_count
from cte c1
inner join cte2 c2 using(state,city);




-- Question 5

-- It is suspected by healthcare research department that the substance “ranitidine” might be causing 
-- some side effects. Find the top 3 companies using the substance in their medicine so that they can 
-- be informed about it. 


select 
companyname,
count(medicineid) as medicine_count 
from medicine 
where substanceName like '%ranitidina%' 
group by companyname
order by medicine_count desc 
limit 3;







