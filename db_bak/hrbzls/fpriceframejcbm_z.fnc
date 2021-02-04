CREATE OR REPLACE FUNCTION HRBZLS."FPRICEFRAMEJCBM_Z"
   (tcode IN CHAR,lclass IN number)
   Return char
  AS
   pfinfo priceframe%rowtype;
  BEGIN
     select pf.*
     into pfinfo
     from priceframe pf
     where pf.pfid=tcode;

     if lclass>=pfinfo.pfclass then
        return pfinfo.pfid;
     end if;

     while pfinfo.pfclass>lclass
     loop
       select pf.*
       into pfinfo
       from priceframe pf
       where pf.pfid=pfinfo.pfpid;
     end loop;
     Return pfinfo.pfid;
  END fpriceframejcbm_z;
/

