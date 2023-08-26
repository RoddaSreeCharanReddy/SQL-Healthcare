use healthcare;

-- Johansson is trying to prepare a report on patients who have gone through treatments more than once.
--  Help Johansson prepare a report that shows the patient's name, the number of treatments they have undergone, 
-- and their age, Sort the data in a way that the patients who have undergone more treatments appear on top.

select * from person;
select * from treatment;
select * from patient;

select personname,
timestampdiff(year,dob,curdate()) as age,
count(treatmentid) as treatment_count
from person p 
inner join patient p1 on p1.patientID=p.personID
inner join treatment t on t.patientID=p1.patientID
group by personname,age
order by treatment_count desc;



--  Question 2 

-- Bharat is researching the impact of gender on different diseases, He wants to analyze 
-- if a certain disease is more likely to infect a certain gender or not.
-- Help Bharat analyze this by creating a report showing 
-- for every disease how many males and females underwent treatment for each in the year 2021. 
-- It would also be helpful for Bharat if the male-to-female ratio is also shown.


select * from disease;
select * from person;
select * from treatment;

with cte as (
select 
diseasename,
treatmentID,
gender
from disease d
inner join treatment t on t.diseaseID=d.diseaseID
inner join person p on p.personID=t.patientID
where year(date)=2021)
select diseasename,
count(case when gender='male' then treatmentid end) as male_count,
count(case when gender='female' then treatmentid end) as female_count,
count(case when gender='male' then treatmentid end)/count(case when gender='female' then treatmentid end) as male_to_female_ratio
from cte
group by diseasename
order by diseasename;


-- question 3 


-- Kelly, from the Fortis Hospital management, has requested a report that shows for each disease, 
-- the top 3 cities that had the most number treatment for that disease.
-- Generate a report for Kelly’s requirement.


select * from disease;
select * from address;
select * from treatment;
select * from person;

with cte as (
select 
diseasename,
city,
count(treatmentID) as treatment_count
from disease d
inner join treatment t on t.diseaseID=d.diseaseID
inner join person p on p.personID=t.patientID
inner join address a on a.addressID=p.addressID
group by diseaseName,city),
cte2 as (
select *,
row_number() over (partition by diseasename order by treatment_count desc) as rn
from cte)
select diseasename,city,treatment_count from cte2 where rn<4;
 
 
 
 -- question 4
 
--  Brooke is trying to figure out if patients with a particular disease are preferring 
-- some pharmacies over others or not, For this purpose, she has requested a detailed pharmacy report 
-- that shows each pharmacy name, and how many prescriptions they have prescribed for each disease
--  in 2021 and 2022, She expects the number of prescriptions prescribed in 2021 and 2022 be displayed in two separate columns.
-- Write a query for Brooke’s requirement.


select * from treatment;
select * from pharmacy;
select * from prescription;

select 
pharmacyname,
diseasename,
count(case when year(date)=2021 then p1.prescriptionID end) as 2021_count,
count(case when year(date)=2022 then p1.prescriptionID end) as 2022_count
from pharmacy p
inner join prescription p1 on p1.pharmacyID=p.pharmacyID
inner join treatment t on t.treatmentID=p1.treatmentID
inner join disease d on t.diseaseID=d.diseaseID
group by pharmacyName,diseasename
having 2021_count>0 or 2022_count>0
order by pharmacyName,diseaseName;


-- Question 5 


-- Walde, from Rock tower insurance, has sent a requirement for a report that presents 
-- which insurance company is targeting the patients of which state the most. 
-- Write a query for Walde that fulfills the requirement of Walde.
-- Note: We can assume that the insurance company is targeting a region more if the patients of that region are claiming more insurance of that company.
 
 select * from claim;
 select * from insurancecompany;
 select * from insuranceplan;
 select * from address;
 select * from person;
 select * from treatment;
 
 with cte as (
 select 
 companyname,
 state,
 count(t.claimID) as claim_count
 from insurancecompany i 
 inner join insuranceplan ip on ip.companyID=i.companyID
 inner join claim c on c.uin=ip.uin
 inner join treatment t on t.claimID=c.claimID
 inner join person p on p.personID=t.patientID
 inner join address a on a.addressID=p.addressID
 group by companyName,state
 ),
cte2 as (
 select *,
 rank() over(partition by companyname order by claim_count desc) as rn
 from cte )
 select companyname,state,claim_count from cte2 where rn=1;