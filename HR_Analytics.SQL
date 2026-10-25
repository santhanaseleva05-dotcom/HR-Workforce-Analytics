---------- HR Workforce,Performance & Compensation Analytics--------------

--Q1.What is the current workforce size, 
and how is it distributed between active and terminated employees?--------

select count(EmpId) as Total_Employees, 
       sum(Case when Termd = 0 then 1 else 0 end) as Active_Employees,
	   sum(Case when Termd = 1 then 1 else 0 end) as Terminated_employees,
	   Round(sum(Case when Termd = 0 then 1 else 0 end)/count(EmpID) *100,2) as ActivePercentage , 
       Round(sum(Case when Termd = 1 then 1 else 0 end)/count(EmpID)*100,2) as TerminatedPercentage 
from fact_employee;

--Q2.Which departments have the highest number of employees?-----

Select 
      d.Department,
      Count(f.EmpID) as Employeecount 
from fact_employee f 
join dim_department d
     on f.DeptID = d.DeptID 
group by d.Department 
order by Count(f.EmpID) Desc 
limit 1;

--Q3.Which job positions have the highest employee concentration?---

select 
      p.Position,
      count(EmpId) as Employeecount 
from fact_employee f 
join dim_position p
	 on f.PositionID = p.PositionKey 
group by p.Position 
order by count(EmpId) desc 
limit 1;

--Q4.How has employee hiring volume changed over time?---

select 
      d.Year,
      count(f.EmpID) as HiringVolume 
from fact_employee f 
join dim_date d 
	 on f.HireDateKey = d.Datekey 
group by d.Year 
order by d.Year;

--Q5.Which departments have the highest termination rates?---

select 
      count(f.EmpID) as Total_Employee, 
      d.Department,
	  sum(case when f.Termd = 1 then 1 else 0 end) as TerminationEmployee,
	  Round(sum(case when f.Termd = 1 then 1 else 0 end)/count(f.EmpID) *100,2) as Termination_Rate 
from fact_employee f join dim_department d 
	 on f.DeptID = d.DeptID 
group by d.department 
order by Termination_Rate desc;

--Q6.Which job positions have both high headcount and high termination rates?---
 
select 
      p.Position,
      count(f.EmpID) as HeadCount,
      sum(case when f.Termd = 1 then 1 else 0 end) as TerminationEmployee,
	  Round(sum(case when f.Termd = 1 then 1 else 0 end)/count(f.EmpID) *100,2) as Termination_Rate 
from fact_employee f join dim_position p 
	 on f.PositionID = p.PositionKey 
group by p.Position 
order by HeadCount desc,Termination_Rate desc;

--Q7.What are the most common reasons for employee termination?----

select TermReason,
       count(EmpID) as Termination_count 
from fact_employee
where Termd = 1 
group by TermReason 
order by Termination_count desc;

--Q8.How do termination reasons vary across departments?---

SELECT
    d.Department,
    f.TermReason,
    COUNT(f.EmpID) AS TerminationCount
FROM fact_employee f
JOIN dim_department d
    ON f.DeptID = d.DeptID
WHERE f.Termd = 1
GROUP BY
    d.Department,
    f.TermReason
ORDER BY
    d.Department,
    TerminationCount DESC;
    
--Q9.How does employee tenure differ between active and terminated employees?----

select 
     case when f.Termd = 1 then 'Terminated' else 'Active' end as Employment_Status, 
     count(f.EmpID) as Employeecount,
	 round(avg(case when f.Termd =1 then tIMESTAMPDIFF(Day,dh.FullDate,dt.FullDate)/365.5
     else 
     tIMESTAMPDIFF(Day,dh.FullDate,curdate())/365.5 end),2) as AverageTenureYears 
from fact_employee f join dim_date dh 
	 on f.HireDateKey = dh.Datekey 
left join dim_date dt 
	 on f.TerminationDateKey = dt.Datekey
group by 
     case when f.Termd = 1 then 'Terminated' else 'Active' end;

--Q10.Which recruitment sources are associated with different retention or termination patterns?---

select 
      RecruitmentSource, 
      count(EmpID) as Employeecount,
      sum(case when Termd = 0 then 1 else 0 end) as Active_Employee,
	  sum(case when Termd = 1 then 1 else 0 end ) as Terminated_Employees, 
      concat(Round(sum(case when Termd = 1 then 1 else 0 end )/count(EmpID)*100,2),'%') as Terminated_Rate
from fact_employee 
group by RecruitmentSource 
order by Terminated_Rate desc

--Q11.How does average salary vary across departments?---

select 
      d.department,
      count(f.EmpID) as Employee_count,
      Round(avg(f.Salary),2) as AverageSalary 
from fact_employee f join dim_department d 
	 on f.DeptID = d.DeptID 
group by d.Department 
order by AverageSalary desc;

--Q12.Which job positions have the highest and lowest average salaries?---

select 
      p.Position,
      count(f.EmpID) as Employee_count,
      Round(avg(f.Salary),2) as AverageSalary 
from fact_employee f 
join dim_position p 
	 on f.PositionID = p.PositionKey 
group by p.Position 
order by AverageSalary desc;

--Q13.How does salary vary across employee performance levels?---- 

select 
      p.PerformanceScore,
	  count(f.EmpID) as Employee_count,
      round(Avg(f.salary),2) as AverageSalary 
from fact_employee f 
join dim_performance p
	 on f.PerfScoreID =p.PerfScoreID 
group by p.PerformanceScore 
order by AverageSalary desc;

--Q14.Which departments or positions 
show salary levels notably different from the overall company average?-----
 
select 
      d.department,
      count(f.EmpID) as Employee_count,
      round(Avg(f.salary),2) as AverageSalary,
      (select avg(salary) from fact_employee) as overall_salary,
      round(Avg(f.salary) - (select avg(salary) from fact_employee),2) as differencefromcompanyavg 
from fact_employee f 
join dim_department d 
	  on f.DeptID = d.DeptID 
group by d.Department 
order by differencefromcompanyavg desc;

--Q15.How are employees distributed across different performance categories?--- 

SELECT
    p.PerformanceScore,
    COUNT(f.EmpID) AS EmployeeCount
FROM fact_employee f
JOIN dim_performance p
    ON f.PerfScoreID = p.PerfScoreID
GROUP BY p.PerformanceScore
ORDER BY EmployeeCount DESC;

--Q16.Which departments show lower employee engagement and satisfaction levels? 

SELECT d.Department,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.EngagementSurvey), 2) AS AverageEngagement,
    ROUND(AVG(f.EmpSatisfaction), 2) AS AverageSatisfaction
FROM fact_employee f
JOIN dim_department d
    ON f.DeptID = d.DeptID
GROUP BY d.Department
ORDER BY AverageEngagement ASC, AverageSatisfaction ASC;

--Q17.How do engagement and satisfaction patterns relate to employee performance?-----

select p.PerformanceScore,COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.EngagementSurvey), 2) AS AverageEngagement,
    ROUND(AVG(f.EmpSatisfaction), 2) AS AverageSatisfaction
FROM fact_employee f
JOIN dim_performance p
    ON f.PerfScoreID = p.PerfScoreID
GROUP BY p.PerformanceScore
ORDER BY AverageEngagement ASC, AverageSatisfaction ASC;

--Q18.Is there a relationship between employee satisfaction, 
engagement, and absenteeism? 

SELECT
    EmpSatisfaction,
    COUNT(EmpID) AS EmployeeCount,
    ROUND(AVG(EngagementSurvey), 2) AS AverageEngagement,
    ROUND(AVG(Absences), 2) AS AverageAbsences
FROM fact_employee
GROUP BY EmpSatisfaction
ORDER BY EmpSatisfaction;

--Q19.Which departments, positions, or managers 
show higher levels of absenteeism and late days?----

SELECT
    d.Department,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.Absences), 2) AS AverageAbsences,
    ROUND(AVG(f.DaysLateLast30), 2) AS AverageLateDays
FROM fact_employee f
JOIN dim_department d
    ON f.DeptID = d.DeptID
GROUP BY d.Department
ORDER BY AverageAbsences DESC;

SELECT
    p.Position,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.Absences), 2) AS AverageAbsences,
    ROUND(AVG(f.DaysLateLast30), 2) AS AverageLateDays
FROM fact_employee f
JOIN dim_position p
    ON f.PositionID = p.PositionKey
GROUP BY p.Position
ORDER BY AverageAbsences DESC;

SELECT
    m.ManagerName,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.Absences), 2) AS AverageAbsences,
    ROUND(AVG(f.DaysLateLast30), 2) AS AverageLateDays
FROM fact_employee f
JOIN dim_manager m
    ON f.ManagerID = m.ManagerID
GROUP BY m.ManagerName
ORDER BY AverageAbsences DESC;

--Q20.Does employee involvement in special projects vary 
by department or performance level?----

SELECT
    d.Department,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.SpecialProjectsCount), 2) AS AverageSpecialProjects,
    SUM(f.SpecialProjectsCount) AS TotalSpecialProjects
FROM fact_employee f
JOIN dim_department d
    ON f.DeptID = d.DeptID
GROUP BY d.Department
ORDER BY AverageSpecialProjects DESC;

SELECT
    p.PerformanceScore,
    COUNT(f.EmpID) AS EmployeeCount,
    ROUND(AVG(f.SpecialProjectsCount), 2) AS AverageSpecialProjects,
    SUM(f.SpecialProjectsCount) AS TotalSpecialProjects
FROM fact_employee f
JOIN dim_performance p
    ON f.PerfScoreID = p.PerfScoreID
GROUP BY p.PerformanceScore
ORDER BY AverageSpecialProjects DESC;
