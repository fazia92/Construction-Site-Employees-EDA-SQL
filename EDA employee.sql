-----analysis of all employees on the construction sites since January 2022
------------------------------------------------------------------/*cleanning the data */---------------------------------------------------------------------------------

select * from functions
select * from employee

-- creating a data base to work with
select * into emp_data
from salaries 
left join companies
on salaries.comp_name = companies.company_name
left join employee 
on salaries.employee_id = employee.employee_code_emp
left join functions 
on salaries.func_code = functions.function_code

--- we will select only relevant columns for furthe analysis 
drop table df_employee
select 
CONCAT(employee_id,CAST(date as date)) as id,
employee_id,
employee_name,
age,
GENM_F as  gender,
func,
function_group,
comp_name,
company_type,	  
const_site_category,	  
company_city,
company_state,   
salary,
CAST(date as date) as date
into df_employee
from emp_data

--visualise the df
select* from df_employee


select distinct const_site_category  from df_employee
update df_employee 
 set const_site_category = case const_site_category
                           when 'commerciall' then 'commercial'
						   else const_site_category
						   end;
select distinct company_city  from df_employee
update df_employee 
  set company_city = case company_city 
                     when 'Goianiaa' then 'Goiania'
					 else company_city 
					 end;
ALTER TABLE df_employee
ALTER COLUMN gender VARCHAR(10);

update df_employee
set gender = case gender 
             when 'M' then 'Male'
             when 'F' then 'Female' 
             else gender 
              end;

------check for null values 

select * 
from df_employee
where const_site_category is null 

select COUNT(*) as counting_null_values
from df_employee 
where const_site_category is null

-- the null values in this case are the compagnies that are not type "construction site", the analysis only involves employee of the construction site so we are going to delete those rows

delete from df_employee 
where const_site_category is null 

select * 
from df_employee
where salary is null 

select COUNT(*) as number_null_values 
from df_employee
where salary is null 

--- anyone who does not have a salary value specified should not bu included in the payroll report and therefore should noy be analysed. in this case we will delete the 42 rows

delete from df_employee
where salary is null 

--remove unwanted spaces 
update df_employee
set id = TRIM(id),
employee_name = TRIM(employee_name),
	gender=TRIM(gender),
	func=TRIM(func),
	function_group=TRIM(function_group),
	comp_name=TRIM(comp_name),
	company_type=TRIM(company_type),
	const_site_category = TRIM(const_site_category),
	company_city=trim(company_city),
	company_state=TRIM(company_state)

--check for duplicates 
select distinct id
from df_employee
group by id 
having COUNT (id) > 1

-- check if 
select id, salary 
from df_employee
where id in (
select distinct id
from df_employee
group by id 
having COUNT (id) > 1 )
ORDER BY id, salary;

-- checking for inconsistent rows
SELECT id
FROM df_employee
GROUP BY id      --- groups all rows by the id value.
HAVING         --HAVING : keeps only the ids that have more than one distinct salary — which indicates a data inconsistency.
COUNT(DISTINCT salary) > 1;  --count : counts how many different salary values exist for each id   

--deleting dublicates 

with emp_CTE as (
select *, 
 ROW_NUMBER()
 over ( PARTITION by employee_id order by employee_id) as row_num
 from df_employee)
 delete
 from emp_CTE
 where row_num > 1

 -- change the type of data in salary 
update df_employee
set salary = REPLACE(salary,',','.')

alter table df_employee
alter column salary float;
 --------------------------------------------------------------------------------EDA----------------------------------------------------
 --questions to be answered:
--Has the average salary decreased or increased since January 2022?
select DATENAME (MONTH, date ) as Month, round (AVG(salary),2) as average_salary 
from df_employee 
group by DATENAME (MONTH, date ) 
order by average_salary DESC

--How effective is our HR program to reduce the gender gap?
 ------------- reduce the gender gap (salary/function group-----------
-----------------------------------------salary-------------
select gender as Gender, ROUND(avg(salary),2) as Average_salary
from df_employee
group by gender 
order by Average_salary DESC
-------------------------------------------function_group------------
select function_group as functions,gender as Gender, count(function_group) as number_of_person
from df_employee
group by function_group, gender

-----------------------------functiongroip/salary----------------
select gender as Gender, function_group as function_group,
ROUND(avg(salary),2) as average_salary
from df_employee
group by gender, function_group
order by function_group

--How are our salaries distributed across the states?
select company_state as state, round(avg(salary),2) as total_salary
from df_employee
group by company_state
order by total_salary DESC


--How standardized is our pay policy across the states?
select company_state as state, function_group as function_group, ROUND(avg(salary),2) as average_salary
from df_employee
group by company_state, function_group 
order by function_group 

--How experienced is our engineering team?
select   
--In what function groups do we spend the most?
--What construction sites spent the most in salaries for the period?