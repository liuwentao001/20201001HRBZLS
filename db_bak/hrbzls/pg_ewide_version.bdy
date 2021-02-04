CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_VERSION" IS
  --  指标执行  p_month ：归档月份  p_oper ：归档人员
  PROCEDURE price_version(p_Smonth IN VARCHAR2,p_emonth in varchar2,p_memo in varchar2,p_oper in varchar2) is

    v_count number;
    v_pricever pricever%rowtype;
  begin
  /*参数检查**/
      if p_Smonth is null or p_emonth is null  then
         raise_application_error(errcode, '归档月份不能为NULL!');
      end if;
       if p_oper is null then
         raise_application_error(errcode, '归档人员不能为NULL!');
      end if;

      select count(*) into v_count from pricever t where (p_Smonth>=t.smonth and  p_smonth<= t.emonth );

      IF V_COUNT>0 THEN
         raise_application_error(errcode, '起始月份已存在归档信息，请检查!');
      END IF;
      V_COUNT:=0;
       select count(*) into v_count from pricever t where (p_emonth>=t.smonth and  p_emonth<= t.emonth );
      IF V_COUNT>0 THEN
         raise_application_error(errcode, '终止月份已存在归档信息，请检查!');
      END IF;
   /*水价归档**/
     begin
         select SEQ_PRICEVER.Nextval into  v_pricever.id from dual;
          v_pricever.smonth:=p_smonth;
          v_pricever.emonth:=p_emonth;
          v_pricever.oper:=p_oper;
          v_pricever.odate:=sysdate;
          v_pricever.MEMO:=p_memo;
          insert into pricever values v_pricever;
         /*水价*/
      insert into priceframe_ver
        select pfid,
               pfname,
               pfpid,
               pfclass,
               pfflag,
               pfstatus,
               pfhandles,
               pfprice,
               pfmemo,
               pfsmfid,
               v_pricever.id
          from priceframe;
        --费用明细
        insert into pricedetail_ver
          select pdpscid,
                 pdpfid,
                 pdpiid,
                 pddj,
                 pdsl,
                 pdje,
                 pdmethod,
                 pdsdate,
                 pdedate,
                 pdsmonth,
                 pdemonth,
                 v_pricever.id
            from pricedetail;
            --阶梯
          insert into pricestep_ver
            select pspscid,
                   pspfid,
                   pspiid,
                   psclass,
                   psscode,
                   psecode,
                   psprice,
                   psmemo,
                   v_pricever.id
              from pricestep;

     exception
         when others then raise_application_error(errcode, sqlerrm);
     end;
     commit;
    exception
    when others then
    rollback;
    raise_application_error(errcode, sqlerrm);
  end;
BEGIN
  NULL;
END PG_ewide_Version;
/

