use healthcare;

-- Question 1 

-- Insurance companies want to know if a disease is claimed higher or lower than average. Write a stored procedure 
-- that returns “claimed higher than average” or “claimed lower than average” when the diseaseID is passed to it. 
-- Hint: Find average number of insurance claims for all the diseases.  If the number of claims for the passed
 -- disease is higher than the average return “claimed higher than average” otherwise “claimed lower than average”.

delimiter $$
create procedure disease_classification(
in id int,
out disease_id int,
out disease_name varchar(50),
out higher_lower varchar(30)
)
begin
with cte as (
select 
diseaseid,
diseasename,
count(claimid) as claim_count 
from treatment 
inner join disease using(diseaseid) 
group by diseaseid,diseaseName
),
cte2 as (
select 
avg(claim_count) as avg_claim
from cte
)
select 
diseaseid,
diseasename,
case when claim_count>avg_claim 
then 'claimed higher than average'
else 'claimed lower than average'
end into 
disease_id,
disease_name,
higher_lower 
from cte2,cte 
where diseaseid=id;
end
$$
delimiter ;

drop procedure disease_classification;
call disease_classification(31,@diseaseid,@diseasename,@classify);
select @diseaseid as diseaseid,@diseasename as diseasename,@classify as classification; 


-- Question 2

-- Joseph from Healthcare department has requested for an application which helps him get genderwise report for any disease. 
-- Write a stored procedure when passed a disease_id returns 4 columns,
-- disease_name, number_of_male_treated, number_of_female_treated, more_treated_gender
-- Where, more_treated_gender is either ‘male’ or ‘female’ based on which gender underwent more often for the disease, 
-- if the number is same for both the genders, the value should be ‘same’.
  
  
  delimiter $$
  create procedure genderwise_report(
  in id int,
  out disease_id int,
  out disease_name varchar(50),
  out total_male_count int,
  out total_female_count int,
  out main_gender varchar(30)
  )
  begin
  with cte as (
  select diseaseid,diseasename,gender,count(treatmentid) as treatment_count
  from treatment t
  inner join person p on p.personID=t.patientID
  inner join disease d using(diseaseid)
  group by diseaseid,diseasename,gender
  order by diseasename),
  cte2 as (
  select 
  diseaseid,
  diseasename,
  max(case when gender='male' then treatment_count end) as male_count,
  max(case when gender='female' then treatment_count end) as female_count
  from cte
  group by diseasename,diseaseid
  )
  select diseaseid,
  diseasename,
  male_count,
  female_count,
  if(male_count>female_count,'male','female') as dominant_gender 
  into 
  disease_id,
  disease_name,
  total_male_count,
  total_female_count,
  main_gender
  from cte2 where diseaseid=id;
  end
  $$
  delimiter ;
  
  drop procedure genderwise_report;
  call genderwise_report(27,@diseaseid,@diseasename,@male_count,@female_count,@dominant_gender);
  select @diseaseid,@diseasename,@male_count,@female_count,@dominant_gender;
  
  
   with cte as (
  select diseaseid,diseasename,gender,count(treatmentid) as treatment_count
  from treatment t
  inner join person p on p.personID=t.patientID
  inner join disease d using(diseaseid)
  group by diseaseid,diseasename,gender
  order by diseasename),
  cte2 as (
  select 
  diseaseid,
  diseasename,
  max(case when gender='male' then treatment_count end) as male_count,
  max(case when gender='female' then treatment_count end) as female_count
  from cte
  group by diseasename,diseaseid
  )
  select diseaseid,
  diseasename,
  male_count,
  female_count,
  if(male_count>female_count,'male','female') as dominant_gender 
  from cte2;
  
  
  -- Question 3 
  
--   The insurance companies want a report on the claims of different insurance plans. 
-- Write a query that finds the top 3 most and top 3 least claimed insurance plans.
-- The query is expected to return the insurance plan name, the insurance company name which has that plan,
--  and whether the plan is the most claimed or least claimed. 


select * from claim;

with cte as (
select 
companyname,
planname,
count(claimID) as claim_count,
row_number() over(order by count(claimid) desc) as rn
from insuranceplan i 
inner join claim c using(uin)
inner join treatment using(claimid)
inner join insurancecompany using(companyid)
group by companyname,planname)
select planname,claim_count from cte where rn <4 or rn>(select max(rn)-3 from cte);


-- Question 4

with cte_disease_age as(
select d.diseaseName,
        pt.patientID,
        case 
          when pt.dob<'1970-01-01' and p.gender='male' then 'ElderMale'
          when pt.dob<'1970-01-01' and p.gender='female' then 'ElderFemale'
          when pt.dob<'1985-01-01' and p.gender='male' then 'MidAgeMale'
          when pt.dob<'1985-01-01' and p.gender='female' then 'MidAgeFemale'
		  when pt.dob<'2005-01-01' and p.gender='male' then 'AdultMale'
          when pt.dob<'2005-01-01' and p.gender='female' then 'AdultFemale'
          when pt.dob>='2005-01-01' and p.gender='male' then 'YoungMale'
          when pt.dob>='2005-01-01' and p.gender='female' then 'YoungFemale'
          end as category
from person p
	inner join  patient pt on p.personID=pt.patientID
    inner join treatment t on t.patientID=pt.patientID
    inner join disease d on d.diseaseID=t.diseaseID),
    
cte_disease_age_ranks as(
select diseaseName,
		category,
        count(patientID) as patients_cnt,
        rank() over(partition by diseaseName order by count(patientID) desc) as r
from cte_disease_age
group by diseaseName,
		 category)
select diseaseName,
       category as most_affected_category
from cte_disease_age_ranks where r=1;


-- Question 5

-- Anna wants a report on the pricing of the medicine. She wants a list of the most expensive and most affordable medicines only. 
-- Assist anna by creating a report of all the medicines which are pricey and affordable, listing the companyName, productName,
--  description, maxPrice, and the price category of each. Sort the list in descending order of the maxPrice.
-- Note: A medicine is considered to be “pricey” if the max price exceeds 1000 and “affordable” if the price is under 5.

select 
companyName,
productName,
description,
maxPrice,
case when maxPrice>1000 
then 'pricey'
else 'affordable'
end as category
 from medicine 
 where maxPrice>1000 or maxPrice<5
 order by maxPrice desc;
 