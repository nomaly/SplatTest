
--��� ������� ���������� ������������ ���� �� ���� ��� ������������� �������, ������������� �������, ���������� ���������.
--����� �������������
--
--�� �������� ������� ����������� ��������� ���������� ��� ������� �������� ���������� ������ � ���������� ������� � �����.
--��������, ��� ������� ����������� ���������:
--
--ID	Name		Gender	Parent_id
--1		����		�		2
--2		����		�		3
--3		���������	�	�
--4		�����		�		2
--5		���������	�		3
--6		�����		�		5
--
--
--��������� ������ ����:
--ID	Name		Brothers count		Sisters count		First Cousins count (male)		First Cousins count (female)
--1		����		0					1					1								0
--2		����		0					1					0								0
--3		���������	0					0					0								0
--4		�����		1					0					1								0
--5		���������	1					0					0								0
--6		�����		0					0					1								1
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
	(1, N'����', '�', 2),
	(2, N'����', '�', 3),
	(3, N'���������', '�', null),
	(4, N'�����', '�', 2),
	(5, N'���������', '�', 3),
	(6, N'�����', '�', 5)


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
			  and fin.gender like '�' 
			  and fin.id <> t.id
	) brothers_count
	,(
		select count(fin.id)
		from t fin
		where t.parent_id = fin.parent_id 
			  and fin.gender like '�' 
			  and fin.id <> t.id
	) sister_count
	,(
		select count(gpf.id)
		from t gpf
		where t.grandparent_id = gpf.grandparent_id
			  and gpf.gender like '�' 
			  and gpf.id <> t.id
			  and t.parent_id <> gpf.parent_id
	) first_cousins_count_male
	,(
		select count(gpf.id)
		from t gpf
		where t.grandparent_id = gpf.grandparent_id
			  and gpf.gender like '�' 
			  and gpf.id <> t.id
			  and t.parent_id <> gpf.parent_id
	) first_cousins_count_female
from
	t
order by 1