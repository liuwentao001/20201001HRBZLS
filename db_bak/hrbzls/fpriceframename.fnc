CREATE OR REPLACE FUNCTION HRBZLS."FPRICEFRAMENAME"
   (tcode IN CHAR,lclass IN number)
   Return varchar2
  AS
   pfinfo priceframe%rowtype;
  BEGIN
     select pf.*
     into pfinfo
     from priceframe pf
     where pf.pfid=tcode;

     if lclass>=pfinfo.pfclass then
        return pfinfo.pfname;
     end if;

     while pfinfo.pfclass>lclass
     loop
       select pf.*
       into pfinfo
       from priceframe pf
       where pf.pfid=pfinfo.pfpid;
     end loop;
     Return pfinfo.pfname;
  END fpriceframename;
/

