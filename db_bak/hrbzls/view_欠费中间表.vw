create or replace force view hrbzls.view_欠费中间表 as
select  rlsmfid  营销公司      ,
  rlmonth   财务月份   ,
  rlsl     水量     ,
  rlje     总金额     ,
  michargetype 水表类别  ,
  case when nvl(rlreverseflag,'N')='Y' THEN '是' ELSE '否' END  冲正标志,
  case when nvl(rlbadflag,'N')='Y' THEN '是' ELSE '否' END     呆账标志,
  rltrans     应收事物  ,
  rlpfid   用水性质,
  charg1     水费  ,
  charg2    污水费    ,
  charg3      附加费  ,
  misaving    预存金额 ,
  case when rlbadflag='Y' THEN  rlje ELSE 0 END 呆账金额,
   case when rlbadflag='Y' THEN  charg1 ELSE 0 END 呆账水费,
      case when rlbadflag='Y' THEN  charg2 ELSE 0 END 呆账污水费,
         case when rlbadflag='Y' THEN  charg3 ELSE 0 END 呆账附加费
    from 欠费中间表;

