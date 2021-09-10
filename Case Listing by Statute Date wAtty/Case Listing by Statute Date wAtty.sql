declare @dueStartDate  as date;
declare @dueEndDate as date;
declare @dateOpenStart  as date;
declare @dateOpenEnd as date;
declare @dateCloseStart  as date;
declare @dateCloseEnd as date;
declare @checklistCode as varchar(50);
declare @checklistStatus as varchar(50) = 'Open';
declare @primaryStaff as varchar(50) ;
declare @anyStaff as varchar(50);
declare @staffRole as varchar(50) = 'Paralegal';
declare @dormant as varchar(50);
declare @class as varchar(50);
select
	cases.casenum,
	(select top 1  names.fullname_lastfirst from names,party where namesid=names.id and party.namesid=names.id and party.casesid=cases.id Order by record_num ASC ) as party_name,
	checklist_dir.code,
	checklist_dir.description,
	case_checklist.due_date,
	(select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000001') as primary_staff,

(select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid and staff.id = case_staff.staffid 
and case_staff.matterstaffid=matter_staff.id and display_order=1) as staff_1,


	(select staff.staff_code from staff where case_checklist.staffassignedid=staff.id) as staff_assigned,
	(select top 1 data from user_case_data, user_case_fields where user_case_data.usercasefieldid=user_case_fields.id and user_case_data.casesid=cases.id and user_case_fields.field_title='TEAM') as team,
	matter.matcode,
	(select casedate from case_dates, matter_dates where cases.id = case_dates.casesid and cases.matterid = matter_dates.matterid and case_dates.datelabelid=matter_dates.datelabelid and display_order=3) as case_date_3,
	staff_role.role as staff_role
from cases
join case_checklist on case_checklist.casesid=cases.id 

join checklist_dir on case_checklist.checklistdirid=checklist_dir.id AND checklist_dir.lim = 1
join staff_role on checklist_dir.staffroleid=staff_role.id
join matter on matter.id=checklist_dir.matterid
left join class on class.id=cases.classid

where 
	(@dueStartDate is null or case_checklist.due_date >= @dueStartDate) and (@dueEndDate is null or case_checklist.due_date <= @dueEndDate)
	AND (@checklistCode is null or checklist_dir.code in (@checklistCode))
	AND (@checklistStatus is null or case_checklist.status in (@checklistStatus))
	AND (@primaryStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id and staffroleid='00000000-0000-0000-0000-000000000001') in (@primaryStaff))
	AND (
		(@anyStaff is null or 
(select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000002') in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000003') in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000004')  in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000005')  in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000006')  in (@anyStaff)) or 
		(@anyStaff is null or 
(select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000007') in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000008') in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid 
and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
and staffroleid='00000000-0000-0000-0000-000000000009') in (@anyStaff)) or 
		(@anyStaff is null or (select staff_code from case_staff, staff, matter_staff where cases.id = case_staff.casesid and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id 
		and staffroleid='00000000-0000-0000-0000-000000000010') in (@anyStaff)) 
	)
	AND
		(@staffRole is null or staff_role.role in (@staffRole))

----		(@staffRole is null or (select top 1 staff_role.role from case_staff, staff, matter_staff,staff_role where cases.id = case_staff.casesid 
--and staff.id = case_staff.staffid and case_staff.matterstaffid=matter_staff.id  and staff_role.id=matter_staff.staffroleid) in (@staffRole))
	AND (@dormant is null or cases.dormant = @dormant)
	AND (@class is null or class.classcode in (@class))
	AND ((@dateOpenStart is null or cases.date_opened >= @dateOpenStart) AND (@dateOpenEnd is null or cases.date_opened <= @dateOpenEnd))
	AND ((@dateCloseStart is null or cases.close_date >= @dateCloseStart) AND (@dateCloseEnd is null or cases.close_date <= @dateCloseEnd))

order by case_checklist.due_date asc,cases.casenum asc

