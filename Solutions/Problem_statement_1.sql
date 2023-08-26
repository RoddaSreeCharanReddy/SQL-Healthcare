use healthcare;

-- Question 1

-- Jimmy, from the healthcare department, has requested a report that shows how the number of treatments 
-- each age category of patients has gone through in the year 2022. 
-- The age category is as follows, Children (00-14 years), Youth (15-24 years), Adults (25-64 years), and Seniors (65 years and over).

select * from treatment;
select * from patient;

with cte as (
select 
treatmentid,
case
when timestampdiff(year,dob,curdate()) between 0 and 14 then "children"
when timestampdiff(year,dob,curdate()) between 15 and 24 then "youth"
when timestampdiff(year,dob,curdate()) between 25 and 64 then "Adults"
when timestampdiff(year,dob,curdate())>=65 then "seniors"
else "unknown"
end as category
from treatment t 
inner join patient p on t.patientid=p.patientid
where year(date)=2022
)
select 
category,
count(treatmentid) as treatment_count 
from cte 
group by category 
order by treatment_count desc;


-- Question 2

-- Jimmy, from the healthcare department, wants to know which disease is infecting people of which gender more often.

select * from disease;
select * from treatment;
select * from person;

with cte as (
select 
diseasename,
gender
from treatment t 
inner join person p on p.personid=t.patientid
inner join disease d on d.diseaseid=t.diseaseid
)
select 
diseasename,
count(case when gender='male' then 1 end) as Male_count,
count(case when gender='female' then 1 end) as Female_count
from cte 
group by diseasename 
order by diseasename;


-- Question 3 

-- Jacob, from insurance management, has noticed that insurance claims are not made for all the treatments. 
-- He also wants to figure out if the gender of the patient has any impact on the insurance claim.
--  Assist Jacob in this situation by generating a report that finds for each gender the number of treatments, 
-- number of claims, and treatment-to-claim ratio. And notice if there is a significant difference between the 
-- treatment-to-claim ratio of male and female patients.

select * from person;
select * from treatment;

with cte as (
select 
gender,
count(treatmentid) as treatment_count,
count(claimid) as claim_count 
from treatment t 
inner join person p on patientid=personid 
group by gender
)
select *,
treatment_count/claim_count as treatment_to_claim_ratio 
from cte;


-- Question 4

-- The Healthcare department wants a report about the inventory of pharmacies. 
-- Generate a report on their behalf that shows how many units of medicine each pharmacy has in their inventory,
--  the total maximum retail price of those medicines, and the total price of all the medicines after discount. 
-- Note: discount field in keep signifies the percentage of discount on the maximum price.  


select * from keep;
select * from medicine;
select * from pharmacy;

select 
pharmacyname,
sum(k.quantity) as units,
sum(quantity*maxprice) as actual_amount,
round(sum((quantity*maxprice)-(quantity*maxprice*discount)/100),2)  as post_discount 
from keep k 
inner join medicine m on m.medicineid=k.medicineid
inner join pharmacy p on p.pharmacyid=k.pharmacyid
group by pharmacyname;



-- question 5 

-- The healthcare department suspects that some pharmacies prescribe more medicines than others in a single prescription, 
-- for them, generate a report that finds for each pharmacy the maximum, minimum and average number of medicines prescribed in their prescriptions. 


select * from prescription; 
select * from treatment;
select * from contain;

with cte as (
select 
pharmacyname,
p.prescriptionid,
sum(quantity) as medicines 
from prescription p
inner join contain c on c.prescriptionid=p.prescriptionid
inner join pharmacy p1 on p1.pharmacyid=p.pharmacyid
group by p.prescriptionid,pharmacyname 
order by pharmacyname,prescriptionid)
select 
pharmacyname,
max(medicines) as maximum,
min(medicines) as minimum,
avg(medicines) as average 
from cte
 group by pharmacyname; 