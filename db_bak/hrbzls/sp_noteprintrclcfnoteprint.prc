CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLCFNOTEPRINT" (
o_base out tools.out_base) is
  begin
    open o_base for
select miid,
MAX(ciname) ÓÃ»§Ãû,
MAX(ciadr) ÓÃ»§µØÖ·,
MAX(micode) ×ÊÁÏºÅ,
MAX(mdno) ±íÉíÂë,
max( case when  rdpiid='01' then rlmonth else '0000.00' end )  Ë®·Ñ´óÄêÔÂ,
min( case when  rdpiid='01' then rlmonth else '9999.01' end )  Ë®·ÑĞ¡ÄêÔÂ,
max( case when  rdpiid='02' then rlmonth else '0000.00' end )  ÎÛË®´óÄêÔÂ,
min( case when  rdpiid='02' then rlmonth else '9999.01' end )  ÎÛË®Ğ¡ÄêÔÂ,
SUM(case when  rdpiid='01' then RDJE else 0 end ) Ë®·Ñ,
SUM(case when  rdpiid='02' then RDJE else 0 end ) ÎÛË®Ë®·Ñ,
count(distinct rlid) Ç··Ñ±ÊÊı,
sum( rdje ) ºÏ¼Æ ,
'15'  ÈÕÆÚ,
max(mibfid) ±í²á,
max(mirorder ) ³­±í´ÎĞò,
max(cicode) ¿Í»§ºÅ,
max(miadr) Ë®±íµØÖ·,
'Ô¤Áô×Ö¶Î1'   Ô¤Áô×Ö¶Î1  , --Ô¤Áô×Ö¶Î1  C19
'Ô¤Áô×Ö¶Î2'   Ô¤Áô×Ö¶Î2  , --Ô¤Áô×Ö¶Î2  C20
'Ô¤Áô×Ö¶Î3'   Ô¤Áô×Ö¶Î3  , --Ô¤Áô×Ö¶Î3  C21
'Ô¤Áô×Ö¶Î4'   Ô¤Áô×Ö¶Î4  , --Ô¤Áô×Ö¶Î4  C22
'Ô¤Áô×Ö¶Î5'   Ô¤Áô×Ö¶Î5  , --Ô¤Áô×Ö¶Î5  C23
'Ô¤Áô×Ö¶Î6'   Ô¤Áô×Ö¶Î6  , --Ô¤Áô×Ö¶Î6            C24
'Ô¤Áô×Ö¶Î7'   Ô¤Áô×Ö¶Î7  , --Ô¤Áô×Ö¶Î7            C25
'Ô¤Áô×Ö¶Î8'   Ô¤Áô×Ö¶Î8  , --Ô¤Áô×Ö¶Î8      C26
'Ô¤Áô×Ö¶Î9'   Ô¤Áô×Ö¶Î9  , --Ô¤Áô×Ö¶Î9       C27
'Ô¤Áô×Ö¶Î10'   Ô¤Áô×Ö¶Î10   --Ô¤Áô×Ö¶Î10       C28
from reclist ,recdetail,meterinfo, custinfo , meterdoc  ,pbparmtemp
where rlid=rdid and rlmid=miid and miid=mdmid and  micid=ciid and miid=c1
and rlcd='DE' and rdpaidflag='N' and rdje>0
group by miid ;

end ;
/

