use healthcare;

-- Question 1 

-- Brian, the healthcare department, has requested for a report that shows for each state how many people 
-- underwent treatment for the disease “Autism”.  He expects the report to show the data for each state as 
-- well as each gender and for each state and gender combination. Prepare a report for Brian for his requirement.

select 
state,
gender,
count(treatmentid) as treatment_count
from treatment t
inner join person p on t.patientID=p.personID
inner join address using(addressid)
inner join disease using(diseaseid)
where diseasename='Autism'
group by state,gender
order by state;


-- Question 2 

-- Insurance companies want to evaluate the performance of different insurance plans they offer. 
-- Generate a report that shows each insurance plan, the company that issues the plan, and the number 
-- of treatments the plan was claimed for. The report would be more relevant if the data compares the
--  performance for different years(2020, 2021 and 2022) and if the report also includes the total number
-- of claims in the different years, as well as the total number of claims for each plan in all 3 years combined.

with cte as (
select
companyname, 
planname,
year(date) as year,
count(treatmentid) as treatment_count
from insurancecompany
left join insuranceplan using(companyid)
inner join claim using(uin)
inner join treatment using(claimid)
where year(date) in (2020,2021,2022)
group by companyname,planname,year(date)
order by companyName,planname,year)
select 
companyname,
planname,
ifnull(year,'sum') as year,
sum(treatment_count) as treatment_count
from cte 
group by companyname,planname,year with rollup;

-- Question 3

 -- Sarah, from the healthcare department, is trying to understand if some diseases are 
--  spreading in a particular region. Assist Sarah by creating a report which shows each 
--  state the number of the most and least treated diseases by the patients of that state 
--  in the year 2022. It would be helpful for Sarah if the aggregation for the different 
--  combinations is found as well. Assist Sarah to create this report. 

with cte as (
select 
state,
diseasename,
count(treatmentID) as treatment_count,
row_number() over(partition by state order by count(treatmentid) desc) as rn
from address a
inner join person p using(addressid)
inner join treatment t on t.patientID=p.personID
inner join disease using(diseaseid)
where year(date)=2022
group by state,diseasename
order by state)
select 
state,
diseasename,
treatment_count 
from cte c1 
where rn=1 
or rn=(
select 
max(rn) 
from cte c2 
where c1.state=c2.state
);


-- Question 4


-- Jackson has requested a detailed pharmacy report that shows each pharmacy name, and
--  how many prescriptions they have prescribed for each disease in the year 2022, along 
--  with this Jackson also needs to view how many prescriptions were prescribed by each
--  pharmacy, and the total number prescriptions were prescribed for each disease.
-- Assist Jackson to create this report. 

select * from prescription;
with cte as (
select
diseasename,
pharmacyname,
count(prescriptionID) as prescription_count
from pharmacy p 
inner join prescription using(pharmacyid)
inner join treatment using(treatmentid)
inner join disease using(diseaseid)
where year(date)=2022
group by pharmacyName,diseaseName
order by diseaseName)
select diseasename,ifnull(pharmacyname,'total'),sum(prescription_count) as prescription_count
from cte group by diseasename,pharmacyname with rollup;


-- Question 5 

-- Praveen has requested for a report that finds for every disease how many males and females 
-- underwent treatment for each in the year 2022. It would be helpful for Praveen if the 
-- aggregation for the different combinations is found as well. 


select 
diseasename,
gender,
count(treatmentID) as treatment_count
from treatment t
inner join disease using(diseaseid)
inner join person p on t.patientID=p.personID
where year(date)=2022
group by diseasename,gender
order by diseasename;
