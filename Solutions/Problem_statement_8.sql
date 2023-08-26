use healthcare;

-- Question 1 

-- For each age(in years), how many patients have gone for treatment?


SELECT timestampdiff(year, dob , curDATE()) AS age, count(*) AS numTreatments
FROM Person
JOIN Patient ON Patient.patientID = Person.personID
JOIN Treatment ON Treatment.patientID = Patient.patientID
group by timestampdiff(year, dob , curDATE())
order by numTreatments desc;


-- Question 2 

-- For each city, Find the number of registered people, number of pharmacies, and number of insurance companies.

drop table if exists T1;
drop table if exists T2;
drop table if exists T3;

select city, count(pharmacyID) as numPharmacy
into T1
from Pharmacy right join Address using(addressid)
group by city
order by numPharmacy desc;

select city, count(companyID) as numInsuranceCompany
into T2
from InsuranceCompany ic right join Address a using(addressid)
group by city
order by numInsuranceCompany desc;

select city, count(personID) as numRegisteredPeople
into T3
from Person p right join Address a using(addressid)
group by city
order by numRegisteredPeople desc;

select T1.city, T3.numRegisteredPeople, T2.numInsuranceCompany, T1.numPharmacy
from T1 
inner join T2 using(city)
inner join T3 using(city)
order by numRegisteredPeople desc;



-- Question 3

-- Total quantity of medicine for each prescription prescribed by Ally Scripts
-- If the total quantity of medicine is less than 20 tag it as "Low Quantity".
-- If the total quantity of medicine is from 20 to 49 (both numbers including) tag it as "Medium Quantity".
-- If the quantity is more than equal to 50 then tag it as "High quantity".

select 
prescriptionID, sum(quantity) as totalQuantity,
CASE WHEN sum(quantity) < 20 THEN 'Low Quantity'
WHEN sum(quantity) < 50 THEN 'Medium Quantity'
ELSE 'High Quantity' END AS Tag
FROM Contain C
JOIN Prescription P 
on P.prescriptionID = C.prescriptionID
JOIN Pharmacy using(pharmacyid)
where pharmacyName = 'Ally Scripts'
group by prescriptionID;
 
 
 -- Question 4 
 
 -- The total quantity of medicine in a prescription is the sum of the quantity of all the medicines in the prescription.
-- Select the prescriptions for which the total quantity of medicine exceeds
-- the avg of the total quantity of medicines for all the prescriptions.

drop table if exists T1;

with cte as (
select pharmacyID, prescriptionID, sum(quantity) as totalQuantity
from Pharmacy
join Prescription using(pharmacyID)
join Contain using(prescriptionID)
join Medicine using(medicineID)
join Treatment using(treatmentID)
group by pharmacyID, prescriptionID
order by pharmacyID, prescriptionID)
select * from cte
where totalQuantity > (select avg(totalQuantity) from cte);


-- Question 5

-- Select every disease that has 'p' in its name, and 
-- the number of times an insurance claim was made for each of them. 

SELECT diseaseName, COUNT(*) as numClaims
FROM Disease
JOIN Treatment using(diseaseID)
JOIN Claim using(claimID)
WHERE diseaseName like '%p%'
GROUP BY diseaseName;

