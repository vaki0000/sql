
--SQL SESSION-4, 16.01.2023, (Joins & Views)

--////////////////////////////////////////////--
------ INNER JOIN ------

--Make a list of products showing the product ID, product name, category ID, and category name.
--(�r�nleri kategori isimleri ile birlikte listeleyin)
--(�r�n IDsi, �r�n ad�, kategori IDsi ve kategori adlar�n� se�in)

select * from product.product
select * from product.category

select count(distinct category_id) from product.product

select a.product_id, a.product_name, a.category_id, b.category_name
from product.product a
inner join product.category b
	on a.category_id=b.category_id

--or

select a.product_id, a.product_name, a.category_id, b.category_name
from product.product a, product.category b
where a.category_id=b.category_id;


--List employees of stores with their store information.
--Select first name, last name, store name

select a.first_name, a.last_name, b.store_name
from sale.staff a
inner join sale.store b on a.store_id=b.store_id


--How many employees are in each store?

select b.store_name, count(a.staff_id) num_of_staff
from sale.staff a, sale.store b
where a.store_id=b.store_id
group by b.store_name;


--////////////////////////////////////////////--
------ LEFT JOIN ------

--Write a query that returns products that have never been ordered
--Select product ID, product name, orderID
--(Hi� sipari� verilmemi� �r�nleri listeleyin)

select * from product.product
select * from sale.order_item

select count(distinct product_id) from sale.order_item

select p.product_id,p.product_name,o.order_id
from product.product p
left join sale.order_item o
	on p.product_id=o.product_id
where o.order_id is null;


--Report the total number of products sold by each employee

select a.staff_id, isnull(sum(c.quantity), 0)  --coalesce
from sale.staff a
left join sale.orders b on a.staff_id=b.staff_id
left join sale.order_item c on b.order_id=c.order_id
group by a.staff_id
order by a.staff_id;

/*select a.staff_id,isnull(sum(c.quantity), 0)
from sale.staff a
inner join sale.orders b on a.staff_id=b.staff_id
inner join sale.order_item c on b.order_id=c.order_id
group by a.staff_id
order by a.staff_id;*/


--////////////////////////////////////////////--
------ RIGHT JOIN ------

--Write a query that returns products that have never been ordered
--Select product ID, product name, orderID
--(Hi� sipari� verilmemi� �r�nleri listeleyin)

select p.product_id,p.product_name,o.order_id
from sale.order_item o
right join product.product p
	on p.product_id=o.product_id
where o.order_id is null;

-----

select p.product_id,p.product_name,o.order_id
from product.product p
right join sale.order_item o
	on p.product_id=o.product_id
where o.order_id is null;


--////////////////////////////////////////////--
------ FULL OUTER JOIN ------

--Report the stock quantities of all products
--(�r�nlerin stok miktar�n� raporlay�n)
--(Her �r�n�n stok ve sipari� bilgisi olmak zorunda de�il)

select * from product.stock order by store_id, product_id

select p.product_id, sum(s.quantity) as prod_quantity
from product.product p 
full outer join product.stock s on p.product_id=s.product_id
group by p.product_id;


--////////////////////////////////////////////--
------ CROSS JOIN ------

/*The stock table does not have all the products in the product table, and you want to add these products to the stock table.
  You have to insert all these products for every three stores with �0 (zero)� quantity.
  Write a query to prepare this data.*/

--stock tablosunda olmay�p product tablosunda mevcut olan �r�nlerin stock tablosuna t�m store'lar i�in kay�t edilmesi gerekiyor. 
--sto�u olmad��� i�in quantity'leri 0 olmak zorunda
--Ve bir product_id t�m store'lar�n stock'una eklenmesi gerekti�i i�in cross join yapmam�z gerekiyor.

select * from product.stock
select * from sale.store

select s.store_id, p.product_id, 0 as quantity
from product.product p
cross join sale.store s
where p.product_id NOT IN(select product_id from product.stock)

------


--////////////////////////////////////////////--
------ SELF JOIN ------

--Write a query that returns the staff names with their manager names.
--Expected columns: staff first name, staff last name, manager name
--(Personelleri ve �eflerini listeleyin)
--(�al��an ad� ve y�netici ad� bilgilerini getirin)

select * from sale.staff

select a.staff_id, a.first_name, b.first_name + ' ' + b.last_name as manager_name
from sale.staff a
left join sale.staff b on a.manager_id=b.staff_id

select a.staff_id, a.first_name, b.first_name + ' ' + b.last_name as manager_name
from sale.staff a
inner join sale.staff b on a.manager_id=b.staff_id







--Write a query that returns both the names of staff and the names of their 1st and 2nd managers
--(Bir �nceki sorgu sonucunda gelen �eflerin yan�na onlar�n da �eflerini getiriniz)
--(�al��an ad�, �ef ad�, �efin �efinin ad� bilgilerini getirin)











--////////////////////////////////////////////--
------ VIEWS ------

---m��terilerin sipari� etti�i �r�nleri g�steren bir view olu�turun

create or alter view vw_customer_product
as
select a.customer_id, a.first_name, a.last_name, b.order_id, c.product_id, c.quantity
from sale.customer a
left join sale.orders b on a.customer_id=b.customer_id
left join sale.order_item c on b.order_id=c.order_id;

select * from vw_customer_product;

EXEC sp_helptext vw_customer_product

alter view vw_customer_product  
as  
select a.customer_id, a.first_name, b.order_id, c.product_id, c.quantity  
from sale.customer a  
left join sale.orders b on a.customer_id=b.customer_id  
left join sale.order_item c on b.order_id=c.order_id;

drop view vw_customer_product






