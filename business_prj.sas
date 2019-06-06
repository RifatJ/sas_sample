title1 color=red bcolor=bisque'Report Generated By Rifat';
footnote color=red bcolor=bisque'On 28OCT2018';
ods rtf file="C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro\rep1.rtf";
options nodate nonumber;

libname reddh "C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro";

proc import 
datafile="C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro\customers.txt" 
out=customers_1 dbms=csv replace;
getnames=no;
run;
****converting Customers.txt to Customers.csv*;
proc import 
datafile="C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro\customers.csv" 
out=customers_1 dbms=csv replace;
getnames=no;
run;

/*
proc contents data=customers_1;
run;

proc print data=customers_1 n='No of Customers : ';
run;*/

data reddh.customers_2(rename=(var1=customerNumber var2=customerName var3=contactLastName
					var4=contactFirstName var5=phone var6=addressLine1 var7=addressLine2
					var8=city var9=state var10=postalCode var11=country var=salesRepEmployeeNumber
					var13=creditLimit) drop=var12);
set customers_1;
if var12= 'NULL' then var12 = .;
var = input(var12, 4.); *salesrepEmployeeNumber was in var12 and it was character-type;
run;

/***********import orders as .text, also read date as text because shippedDate having 
text "Null" as data value in few cells, this works**********/
data reddh.orders_1;
infile "C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro\orders.txt" dsd dlm=',';
input orderNumber  orderDate : $ 12. requiredDate : $ 12. shippedDate : $ 12. status ~ $ 15.  comments ~ $ 100. customerNumber;
run;

/*
proc print data=reddh.orders_1; run;
*/
********This works--convert to .csv and import orders.csv, reading date as text cause date field has NULL-value**********;
data reddh.orders_1;
infile "C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro\orders.csv" dsd dlm=',' ;
input orderNumber  orderDate : $ 12.  requiredDate : $ 12.   shippedDate : $ 12.  status ~ $ 10. comments ~ $ 100. customerNumber;
run;


*******Replacing "NULL" data value by . *****;
data reddh.orders_2;
set reddh.orders_1;
if shippedDate = "NULL" then shippedDate = .;
run;

****Converting text-type date to numeric date***********;
data reddh.orders_3;
set reddh.orders_2;
orderDate_n = input(orderDate, mmddyy10.);
requiredDate_n=input(requiredDate, mmddyy10.);
shippedDate_n=input(shippedDate, mmddyy10.);
format orderDate_n date9. requiredDate_n date9. shippedDate_n date9.;
run;

*********************************************************************;
/*1.Find out the Year over year (2003 versus 2004) sales growth?*/

title2 color=bip bcolor=antiquewhite 'Year Over Year Sales Growth';
data reddh.payments_1;
set reddh.payments;
format paymentDate date9.;
paymentYear = Year(paymentDate);
if paymentYear in (2003, 2004);
run;

*********sum(amount)using Group By paymentDate**********;
proc sql;
create table sale_gr_Year as
select paymentYear, sum(amount) as Total
from reddh.payments_1
group by paymentYear
order by Total desc;
quit;

*Finding Year over year sale growth (2003 vs 2004)*;
proc sql;
select (max(Total)-min(Total))/min(Total)*100 as SalesGrowth_2003_2004 format=percent8.1
from sale_gr_Year;

*gchart amount vs year;
proc gchart data=reddh.payments_1;
	vbar3d paymentYear/sumvar=amount midpoints = 2003 2004 space=8 shape = block ctext=red cframe=azure;
run;
quit;

**********2.Which quarter has highest Sales peak and in which month?*********;
title2 color=bippk bcolor=beige bold "Highest Sales Peak by Quarter and Month";
data reddh.payments_4;
set reddh.payments_1;
paymentQuarter=paymentDate;
format paymentQuarter yyq6.;
run;

**** Highest Sales by Quarter*********;
proc sql outobs=1;
select paymentDate as PaymentDate, paymentQuarter as PaymentQuarter, sum(amount) as Total_Sale_Quarter format=dollar16.
from reddh.payments_4
group by paymentQuarter, paymentDate
order by Total_Sale_Quarter desc;
quit;

***********3.Which territory generates the largest sales volume?********************;

/*territory-var is present in the 'Offices'table, so first merge Offices+Employees=Offi_Emp 
and then again merge with Customers and then merge Payments-table */
title2 color=biv bcolor=antiquewhite'Sales Volume in Amount By Territory ';
proc sort data=reddh.offices;
by officeCode;
run;

proc sort data=reddh.employees;
by officeCode;
run;

**merge offices with employees;
data Office_Employee;
	merge reddh.offices reddh.employees;
	by officeCode;
run;

*merge Office_Employee with Customers;
proc sort data=Office_Employee;
by employeeNumber;
run;

proc sort data=reddh.customers_2;
by salesRepEmployeeNumber;
run;

data reddh.Off_Emp_Cust;
	merge Office_Employee reddh.customers_2(rename=(salesRepEmployeeNumber=employeeNumber));
	by employeeNumber;
run;

***merge Off_Emp_Cust with Payments-table****;
proc sort data=reddh.Off_Emp_Cust;
by customerNumber;
run;

 proc sort data=reddh.payments_1;
 by customerNumber;
 run;

 data reddh.Off_Emp_Cust_Payments(where=(amount is not missing));
 	merge reddh.Off_Emp_Cust reddh.payments_1;
	by customerNumber;
	keep territory amount;
 run;

 proc sql;
 select territory as Territory, sum(amount) as Total_Amt_Territory format=dollar16.
 from reddh.off_emp_cust_payments
 group by territory
 order by Total_Amt_Territory desc;
 quit;

*********10/25/2018************************************;
 libname reddh "C:\Users\rifa\Documents\SAS_Clinical\base pro\base_pro";
 ***GChart for territory*************;
 
 proc gchart data=reddh.Off_Emp_Cust_Payments;
 	vbar3d territory/sumvar=amount subgroup=territory space=8 ctext=bib cframe=aliceblue;
 run;
 quit;


**********4.Which quarter has a slight drop in sales for the year 2004?***********;
****Sales by Quarter*********;

title2 color=bip bcolor=antiquewhite bold "Quarter That Has a Slight Drop in Sales for the Year 2004 ";
proc sql outobs=1;
select paymentDate as PaymentDate, paymentQuarter as PaymentQuarter, sum(amount) as Total_Sale_Quarter 
from reddh.payments_4
where '01JAN2004'd<= paymentDate<='31DEC2004'd
group by paymentQuarter, paymentDate
order by Total_Sale_Quarter;
quit;

title2 color=bip bcolor=antiquewhite bold "Sales for the Year 2004 by Quarter";
proc gchart data=reddh.payments_4;
vbar paymentQuarter/sumvar=amount space = 8 type=mean;
where '01JAN2004'd<= paymentDate<='31DEC2004'd;
run;
quit; 

****5.Which productline accounts for highest % of sales volume?******;
*merge ORDERDETAILS and PRODUCTS************;
title2 color=bip bcolor=antiquewhite 'Quantity Ordered by ProductLine';
proc sort data=reddh.orderdetails;
by productCode;
run;

proc sort data=reddh.products;
by productCode;
run;

data reddh.OrderDetails_Products;
merge reddh.orderdetails reddh.products;
by productCode;
run;

*Total quantityOrdered by productLine;
proc sql;
select productLine as ProductLine, sum(quantityOrdered) as Total_Quant_Ord
from reddh.OrderDetails_Products
group by productLine;
quit;



***highest percentage of sale volume*********;
title2 color=bip bcolor=antiquewhite 'Percentage of Sale Volume by ProductLine';

proc sql;
create table OrderDetails_Products_Pct as
select productLine, quantityOrdered/sum(quantityOrdered) as PercentProdLine format=percent6.2
from reddh.OrderDetails_Products;
quit;

proc sql;
create table OrderDetails_Products_TotalPct as
select productLine as ProductLine, sum(PercentProdLine) as Total_Pct format=percent8.2
from OrderDetails_Products_Pct
group by productLine;
quit;

proc print data=OrderDetails_Products_TotalPct obs='OBS'
style(header obsheader)={foreground=blue background=yellow}
style(obsdata)={foreground=blue background=yellow}
style(header)={foreground=blue background=yellow};
run;

***plot Total_Pct*productLine******;
proc plot data=OrderDetails_Products_TotalPct;
plot Total_Pct*productLine;
run;

****use this sgplot of productLine vs Total_Pct*********;
proc sgplot data=OrderDetails_Products_TotalPct;
	series x=productLine y=Total_Pct/markers;
run;

*6.Find out the average of orders by the customer per year? Who (customer) gave highest no of orders per year?;
title2 color=bip bcolor=antiquewhite'Average of Orders By Customers';
proc sql;
create table reddh.Orders_4 as
select  customerNumber, count(orderNumber) as CountOrderNumber, Year(orderDate_n ) as Year 
from reddh.orders_3
group by customerNumber, year;
quit;

proc sql;
select customerNumber, mean(CountOrderNumber) as AvgOrderPerYear
from reddh.Orders_4 
group by customerNumber
order by AvgOrderPerYear desc;
quit;

**7.Find out The shipping times (the difference between OrderDate and ShippedDate) for different locations.*;
*merge Customers and Orders*;
title2 color=bip bcolor=antiquewhite'Shipping Times for Different Locations';
proc sort data=reddh.customers_2
out=customers_3(keep = customerNumber country city postalCode);
by customerNumber;
run;

proc sort data=reddh.orders_3
out= orders_5(keep =  customerNumber orderDate_n shippedDate_n);
by customerNumber;
run;

data reddh.customers_3_orders_5;
merge customers_3  orders_5;
by customerNumber;
run;

data ShippedTime;
set reddh.customers_3_orders_5;
by customerNumber;
	ShippingTimeInDays = intck('day',orderDate_n, shippedDate_n);
	Location=catx(', ',country, city, postalcode);
run; 

proc sql;
select customerNumber as CustomerNumber, Location, orderDate_n as Order_Date, shippedDate_n as Shipped_Date, ShippingTimeInDays
from  ShippedTime;
run;

*********8.On average which customers send their payments faster? ***********;
title2 color=bip bcolor=antiquewhite 'Average Days of Sending Payments By Customers';
proc sort data=reddh.orders_3
out=orders_6(keep=customerNumber orderDate_n status);
by customerNumber;
where status not in ('Cancelled', 'Disputed', 'On Hold');
run;

proc sort data=reddh.payments_1
out=payments_5(keep=customerNumber paymentDate);
by customerNumber;
run;

data reddh.orders_6_payments_5;
merge orders_6 payments_5;
by customerNumber;
Customer_Payment_Days = intck('day', orderDate_n, paymentDate);
run;

proc sql;
select customerNumber as CustomerNumber, mean(Customer_Payment_Days) as AvgDaysCustPayment 
from reddh.orders_6_payments_5
group by customerNumber
order by AvgDaysCustPayment;
run;

**9.Find out the brand new customers in EMEA that will start placing orders soon.**;
title2 color=bip bcolor=antiquewhite 'Brand New Customers in EMEA';
proc sort data=reddh.off_emp_cust
out=off_emp_cust_9;
by customerNumber;
run;

proc sort data=reddh.orders_3
out= orders_9;
by customerNumber;
run;

data reddh.off_emp_cust_9_orders_9;
merge off_emp_cust_9  orders_9;
by customerNumber;
if territory = 'EMEA';
if orderNumber = .;
run;

proc print data=reddh.off_emp_cust_9_orders_9;
run;

***10.Find out the average of MSRP? And range?***;
title2 color=bip bcolor=antiquewhite 'Average and Range of MSRP';
proc sql;
select avg(MSRP) as AvgMSRP, range(MSRP) as RangeMSRP
from reddh.products;
quit;

****11.Each order contains how many 9 unique products?***;
title2 color=bip bcolor=antiquewhite 'Number of 9 Unique Products by Each Order';
proc sql;
select  orderNumber as OrderNumber, count(distinct orderLineNumber) as CountUniqueProd
from reddh.orderdetails
group by orderNumber;
quit;

**12.Which year contains incomplete data?**;
title2 color=bip bcolor=antiquewhite'Year Contains Incomplete Data';
proc sql;
select orderDate_n as Order_Date, year(orderDate_n) as Year, shippedDate_n as Shipped_Date
from reddh.orders_3
where shippedDate_n is missing;
quit;

**13.Find out the % of status as shipped?**;
title2 color=bip bcolor=antiquewhite bold 'Percentage of Status';

proc sql;
create table CouneStatus as
select status, count(status) as CountStatus 
from reddh.orders_1
group by status;
quit;

proc sql;
select status as Status, CountStatus, CountStatus/sum(CountStatus) as PctStatus format=percent8.2
from CouneStatus;
quit;

ods rtf close;







