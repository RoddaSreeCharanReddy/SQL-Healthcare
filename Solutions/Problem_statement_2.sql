use healthcare;

-- question 1

-- A company needs to set up 3 new pharmacies, they have come up with an idea that the pharmacy 
-- can be set up in cities where the pharmacy-to-prescription ratio is the lowest and the number of 
-- prescriptions should exceed 100. Assist the company to identify those cities where the pharmacy can be set up. 

select * from pharmacy;
select * from address;

with cte as (
select 
pharmacyname,
p.pharmacyid,
p1.addressID,
count(prescriptionid) as prescription_count 
from prescription p
inner join pharmacy p1 on p1.pharmacyID=p.pharmacyID
group by pharmacyname,pharmacyid
),
cte2 as (
select 
pharmacyname,
prescription_count,
city 
from cte c 
inner join address a on a.addressid=c.addressid 
order by prescription_count desc
)
select 
city,
count(pharmacyname) as pharmacy_count,
sum(prescription_count) as prescription_count1,
sum(prescription_count)/count(pharmacyname) as pharmacy_to_prescription
from cte2 
group by city
having sum(prescription_count)>100
order by pharmacy_to_prescription limit 3;


-- Question 2 

-- The State of Alabama (AL) is trying to manage its healthcare resources more efficiently. 
-- For each city in their state, they need to identify the disease for which the maximum number 
-- of patients have gone for treatment. Assist the state for this purpose.
-- Note: The state of Alabama is represented as AL in Address Table.

select * from disease;
select * from treatment;
select * from person;
select distinct city from address where state='al';

with cte as (
select 
city,
diseasename,
count(personID) as person_count 
from person p
inner join treatment t on t.patientID=p.personid
inner join disease d on d.diseaseid=t.diseaseID
inner join address a on a.addressID=p.addressID
 where state='al'
 group by city,diseaseName),
 cte2 as (
select *,dense_rank() over(partition by city order by person_count desc) as rn from cte)
select city,diseasename,person_count from cte2 where rn=1;

-- question 3 


-- The healthcare department needs a report about insurance plans. The report is required 
-- to include the insurance plan, which was claimed the most and least for each disease.  Assist to create such a report.

select * from treatment;
select * from insuranceplan;
select * from claim;

with cte as (
select 
 diseasename,
planname,
count(t.claimID) as pcnt,
row_number() over(partition by diseasename order by count(t.claimid) desc) as my_rnk
from treatment t
inner join claim c on c.claimID=t.claimID
inner join insuranceplan i on i.uin=c.uin
inner join disease d on d.diseaseID=t.diseaseID
group by diseasename,planName),
 cte2 as (
 select
 diseasename,
 planname,
 pcnt,
 row_number() over (partition by diseasename order by pcnt desc) as rn
 from cte
 where my_rnk=1 or (diseasename,my_rnk) in (select diseasename,max(my_rnk) from cte group by diseasename)),
 cte3 as (
 select 
 diseasename,
 case when rn=1 then planname end as max_plan,
 case when rn=1 then pcnt end as max_claim_count,
 case when rn=2 then planname end as min_plan,
 case when rn=2 then pcnt end as min_claim_count
 from cte2)
 select 
 diseasename,
 max(max_plan),
 max(max_claim_count) as max_claim_count,
 max(min_plan) as min_plan,
 max(min_claim_count) as min_claim_count
 from cte3
 group by 1;
 
 
 


-- question 4 

-- The Healthcare department wants to know which disease is most likely to infect multiple people in the same household. 
-- For each disease find the number of households that has more than one patient with the same disease. 
-- Note: 2 people are considered to be in the same household if they have the same address. 
 
 with cte as (
 select 
 count(personID) as pcnt,
 addressid,
 diseaseID 
 from treatment t
 inner join person p on personID=patientID 
 group by addressID,diseaseID 
 order by pcnt desc)
 select diseasename,count(addressid) as cddress_count from cte 
inner join disease d on d.diseaseID=cte.diseaseID
where pcnt > 1 group by diseasename;
 
 
 
 -- question 5
 
 
 -- An Insurance company wants a state wise report of the treatments to claim ratio 
 -- between 1st April 2021 and 31st March 2022 (days both included). Assist them to create such a report.
 
 select * from claim;
 select * from insuranceplan;
 select * from address;
 select * from person;
 select * from treatment;
 
 select 
 state,
 count(treatmentID) as treatment_count,
 count(claimID) as claim_count,
 count(treatmentID)/
 count(claimID) as treatment_to_claim_ratio
 from treatment t 
 inner join person p on p.personID=t.patientID
 inner join address a on a.addressID=p.addressID
 where date between '2021-04-01' and '2022-03-31'
 group by state;