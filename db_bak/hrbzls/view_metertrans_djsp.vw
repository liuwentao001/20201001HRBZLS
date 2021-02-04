create or replace force view hrbzls.view_metertrans_djsp as
select mthno 单据流水号,
       mtdrowno 行号,
       mthshflag 审核标志 ,
       mthshdate 审核日期 ,
       mthshper 审核人员 ,
       mthlb 单据类别,
       mthcredate 受理日期,
       mthcreper 受理人,
       mtdmcode 客户代码 ,
       mtdsentper 派工人员 ,
       mtdsentdate 派工时间 ,
       mtduninsper 拆表员 ,
       mtduninsdate 拆表日期 ,
       mtdshper 完工人员 ,
       mtdshdate 完工日期 ,
       mtdscode 上期读数 ,
       mtdecode 拆表底数 ,
       mtdaddsl 余量 ,
       mtdreinscode 新表起数 ,
       mtdappnote 申请说明
from metertranshd,metertransdt
where mthno =mtdno and mthshflag='N';

