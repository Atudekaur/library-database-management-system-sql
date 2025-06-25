
create database library_mng_db;
use library_mng_db;
create table branch (
    branch_id int auto_increment primary key,
    branch_name varchar(100),
    location varchar(100)
);

create table employees (
    emp_id int auto_increment  primary key,
    emp_name varchar(100),
    designation varchar(50),
    branch_id int,
    foreign key (branch_id) references branch(branch_id)
);

create table members (
    member_id int primary key,
    member_name varchar(100),
    membership_date date,
    contact varchar(15)
);

create table books (
    book_id int auto_increment primary key,
    title varchar(100),
    author varchar(100),
    publisher varchar(100),
    branch_id int,
    foreign key (branch_id) references branch(branch_id)
);

create table issued_status (
    issue_id int  primary key,
    book_id int,
    member_id int,
    issue_date date,
    emp_id int,
    foreign key (book_id) references books(book_id),
    foreign key (member_id) references members(member_id),
    foreign key (emp_id) references employees(emp_id)
);

create table return_status (
    return_id int primary key,
    issue_id int,
    return_date date,
    fine_amount decimal(8,2),
    foreign key (issue_id) references issued_status(issue_id)
);
insert into branch values 
(1, 'central library', 'main campus'),
(2, 'science wing', 'block b');

insert into employees values
(101, 'anita sharma', 'librarian', 1),
(102, 'raj kumar', 'assistant', 2);

insert into members values
(201, 'neha verma', '2022-01-10', '9876543210'),
(202, 'arjun singh', '2023-03-22', '8765432109');

insert into books values
(301, 'introduction to algorithms', 'cormen', 'mit press', 1),
(302, 'database system concepts', 'silberschatz', 'mcgraw hill', 2);

insert into issued_status values
(401, 301, 201, '2024-05-01', 101),
(402, 302, 202, '2024-06-01', 102);

insert into return_status values
(501, 401, '2024-05-15', 0.00),
(502, 402, '2024-06-15', 20.00);

-- list all books
select * from books;

-- show all members
select * from members;

-- get all employees working in branch 1
select * from employees where branch_id = 1;

-- list books available in 'science wing'
select title from books 
join branch on books.branch_id = branch.branch_id 
where branch.branch_name = 'science wing';



--  Show all currently issued books with member ID

SELECT book_id, member_id, issue_date
FROM issued_status;


-- intermediate queries -----


 
-- list books issued with member names
select b.title, m.member_name, i.issue_date
from issued_status i
join books b on i.book_id = b.book_id
join members m on i.member_id = m.member_id;

-- show total books issued by each employee
select e.emp_name, count(i.issue_id) as total_issued
from employees e
join issued_status i on e.emp_id = i.emp_id
group by e.emp_name;


-- list books not yet returned (if return_status is missing)
select b.title
from issued_status i
left join return_status r on i.issue_id = r.issue_id
join books b on i.book_id = b.book_id
where r.return_id is null;



-- List all books and the employee who issued them
select b.title, e.emp_name, i.issue_date
from issued_status i
join books b on i.book_id = b.book_id
join employees e on i.emp_id = e.emp_id; 

-- Find members who borrowed books written by a specific author

select distinct m.member_name, b.author
from issued_status i
join books b on i.book_id = b.book_id
join members m on i.member_id = m.member_id
where b.author = 'cormen';


-- Get list of books along with issue and return dates**

select b.title, i.issue_date, r.return_date
from books b
join issued_status i on b.book_id = i.book_id
left join return_status r on i.issue_id = r.issue_id;


-- List of books that have been issued more than once

select member_id,count(*) as book_issued from issued_status group by member_id having count(*)>1;
   

--  members who have never returned any book


select m.member_name
from members m
where m.member_id not in (
    select distinct i.member_id
    from issued_status i
    join return_status r on i.issue_id = r.issue_id
);


-- Get the number of books available in each branch**


select br.branch_name, count(b.book_id) as total_books
from branch br
left join books b on br.branch_id = b.branch_id
group by br.branch_name;

-- List employees who haven't issued any book yet

select e.emp_name
from employees e
where e.emp_id not in (
    select emp_id from issued_status
);


#### Find the latest book issued by each employee**


select e.emp_name, b.title, i.issue_date
from employees e
join issued_status i on e.emp_id = i.emp_id
join books b on i.book_id = b.book_id
where i.issue_date = (
    select max(i2.issue_date)
    from issued_status i2
    where i2.emp_id = e.emp_id
);
-- Get average fine paid by each member

select m.member_name, avg(r.fine_amount) as avg_fine
from members m
join issued_status i on m.member_id = i.member_id
join return_status r on i.issue_id = r.issue_id
group by m.member_name;

-- List of members who returned books within 15 days

select m.member_name, b.title, i.issue_date, r.return_date
from members m
join issued_status i on m.member_id = i.member_id
join return_status r on i.issue_id = r.issue_id
join books b on i.book_id = b.book_id
where datediff(r.return_date, i.issue_date) <= 15;

#advance queries
-- total fine collected by each employee
select e.emp_name, sum(r.fine_amount) as total_fine
from employees e
join issued_status i on e.emp_id = i.emp_id
join return_status r on i.issue_id = r.issue_id
group by e.emp_name;

-- Get the member who paid the highest total fine 
select m.member_name, sum(r.fine_amount) as total_fine
from members m
join issued_status i on m.member_id = i.member_id
join return_status r on i.issue_id = r.issue_id
group by m.member_name
order by total_fine desc
limit 1;


-- top 1 member who borrowed most books
select m.member_name, count(*) as total_borrowed
from members m
join issued_status i on m.member_id = i.member_id
group by m.member_name
order by total_borrowed desc
limit 1;

-- list books returned after 10 days of issue
select b.title, i.issue_date, r.return_date
from books b
join issued_status i on b.book_id = i.book_id
join return_status r on i.issue_id = r.issue_id
where datediff(r.return_date, i.issue_date) > 10;

-- Find books that were returned late and fine was 0

select b.title, m.member_name, i.issue_date, r.return_date, r.fine_amount
from books b
join issued_status i on b.book_id = i.book_id
join return_status r on i.issue_id = r.issue_id
join members m on i.member_id = m.member_id
where datediff(r.return_date, i.issue_date) > 10 and r.fine_amount = 0;

-- Procedure to Issue a Book

delimiter //

create procedure book_issue(  in p_book_id int,
    in p_member_id int,
    in p_emp_id int,
    in p_issue_date date
)
begin
    insert into issued_status (book_id, member_id, issue_date, emp_id)
    values (p_book_id, p_member_id, p_issue_date, p_emp_id);
      select * from issued_status;
end //

delimiter ;
call book_issue(201, 202, 2203, '2025-07-03');

 alter table issued_status alter issue_id set default "001";
 alter table return_status alter issue_id set default "001";
  alter table return_status alter return_id set default "001";
delimiter //

-- Procedure to Return a Book

create procedure return_book(
    in p_issue_id int,
    in p_return_date date,
    in p_fine decimal(8,2)
)
begin
    insert into return_status (issue_id, return_date, fine_amount)
    values (p_issue_id, p_return_date, p_fine);
    select * from return_status;
end //

delimiter ;
call return_book(401, '2025-06-15', 10.00);


