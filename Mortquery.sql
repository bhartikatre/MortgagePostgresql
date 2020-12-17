-- This function named Calc_Mort takes arguments (loanamount[numeric],periodinmonths[integer],yearinterestrate[numeric])
-- and create a basic mortguage calculator table with annuity schedule to run it - [select * from Calc_Mort(5000,36,5)]
-- drop function if exists Calc_newb(numeric,INTEGER,numeric);  (drop only if recreation of function is needed)

create or replace function Calc_Mort(loanamt numeric,periodmo int,rate numeric)
returns table (Nr int,Payment_month text,Loan_amount€ numeric(10,2),Interest€ numeric(10,2),
Principal_payment€ numeric(10,2),Monthly_payment€ numeric(10,2),Principal_remaining€ numeric(10,2)) 
as $$
declare months integer := date_part('month', CURRENT_DATE);                      -- declare variables
declare years integer := date_part('year', CURRENT_DATE);
declare displaymonth varchar;
declare loant numeric := loanamt;
declare r numeric := rate;
declare per int := periodmo;
declare n numeric; 
declare num numeric;
declare pow numeric; 
declare d numeric;
declare ratep numeric;
declare monthlypay numeric;
declare prinoutstnd numeric;
declare prinpay numeric;
declare interestpay numeric;
declare x integer;
begin 
    create temp table if not exists temp_table as select * from annuity;  -- creating a temptable from a table structure with row0
    if months = 12 then                                                   -- start process next month if starting month is december
	    years := years + 1;  
		months := 1; 
		else months = months + 1; 
	end if;
                                              --logic for calculating monthly payment with the formula p = r(pv)/1-(1+r)power(-n)
    ratep := cast (r * 0.01 as float)/12;     --(r/100)/12(months) calculating interest rate annual rate given in the argumnt
    n := (ratep*loant);                       -- numerator for calculating monthly payment
	num := n;
	pow := power((1+ratep),(-per));   
    d:= cast((1-pow) as float);               -- denominator for calculating monthly payment
    monthlypay := n/d;                        
 
    for x in 1..per                           -- this loop will give amount details schedule,1row for each month of period 
        loop
            case months                       -- logic for payment month
			    when 1 then  displaymonth = ('January' ||' '||years);
                when 2 then  displaymonth = ('February' ||' '|| years);
				when 3 then  displaymonth = ('March' ||' '|| years);
				when 4 then  displaymonth = ('April' ||' '|| years);
				when 5 then  displaymonth = ('May' ||' '|| years);
				when 6 then  displaymonth = ('June' ||' '|| years);
				when 7 then  displaymonth = ('July' ||' '|| years);
				when 8 then  displaymonth = ('August' ||' '|| years);
				when 9 then  displaymonth = ('September' ||' '|| years);
				when 10 then displaymonth = ('October' ||' '|| years);
				when 11 then displaymonth = ('November' ||' '|| years);
				when 12 then displaymonth = ('December' ||' '|| years);
                else         displaymonth = ('invalid'); 
            end case; 
            months := months + 1;
            if  months = 13 then 
			    months := 1; 
				years:= years+1; 
		    end if;
			
            interestpay := num;                 -- logic for amounts(interest amt,principal amt,outstanding amt,)
            prinoutstnd := loant - monthlypay + interestpay;
            prinpay := loant - prinoutstnd;
            insert into temp_table values (x,displaymonth,loant,interestpay,prinpay,monthlypay,prinoutstnd);
			loant :=  prinoutstnd;
			num := (ratep*loant);
            end loop;
            return query  select * from temp_table where temp_table.nr > 0;    -- return temp table rows
            drop table temp_table;				
end;
$$ language plpgsql;