
--При решении желательно использовать хотя бы один раз иерархические запросы, аналитические запросы, регулярные выражения.
--Поиск родственников
--
--По заданной таблице родственных отношений определить для каждого человека количество родных и двоюродных братьев и сестёр.
--Например, для таблицы родственных отношений:
--
--ID	Name		Gender	Parent_id
--1	Иван		м		2
--2	Петр		м		3
--3	Екатерина	ж	 
--4	Мария		ж		2
--5	Анастасия	ж		3
--6	Павел		м		5
--
--
--Результат должен быть:
--ID	Name		Brothers count		Sisters count		First Cousins count (male)		First Cousins count (female)
--1	Иван		0					1					1								0
--2	Петр		0					1					0								0
--3	Екатерина	0					0					0								0
--4	Мария		1					0					1								0
--5	Анастасия	1					0					0								0
--6	Павел		0					0					1								1
--


declare
	@family table(
		id int, 
		name nvarchar(255), 
		gender nvarchar(1),
		parent_id int)
		
insert into
	@family
values 
	(1, N'Иван', 'м', 2),
	(2, N'Петр', 'м', 3),
	(3, N'Екатерина', 'ж', null),
	(4, N'Мария', 'ж', 2),
	(5, N'Анастасия', 'ж', 3),
	(6, N'Павел', 'м', 5)


;with t (
	id, 
	name, 
	gender, 
	parent_id, 
	grandparent_id
) as (
	select
		f.id, 
		f.name, 
		f.gender, 
		null, 
		null
	from
		@family f
	where
		f.parent_id is null
	union all
	select
		f.id,
		f.name,		
		f.gender,
		f.parent_id,
		pf.parent_id
	from
		t, @family f, @family pf
	where
		t.id = f.parent_id
		and f.parent_id = pf.id
)
select
	t.id id
	,t.name name
	,(
		select count(fin.id)
		from t fin
		where t.parent_id = fin.parent_id 
			  and fin.gender like 'м' 
			  and fin.id <> t.id
	) brothers_count
	,(
		select count(fin.id)
		from t fin
		where t.parent_id = fin.parent_id 
			  and fin.gender like 'ж' 
			  and fin.id <> t.id
	) sister_count
	,(
		select count(gpf.id)
		from t gpf
		where t.grandparent_id = gpf.grandparent_id
			  and gpf.gender like 'м' 
			  and gpf.id <> t.id
			  and t.parent_id <> gpf.parent_id
	) first_cousins_count_male
	,(
		select count(gpf.id)
		from t gpf
		where t.grandparent_id = gpf.grandparent_id
			  and gpf.gender like 'ж' 
			  and gpf.id <> t.id
			  and t.parent_id <> gpf.parent_id
	) first_cousins_count_female
from
	t
order by 1