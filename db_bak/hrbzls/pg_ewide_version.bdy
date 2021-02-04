CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_VERSION" IS
  --  ָ��ִ��  p_month ���鵵�·�  p_oper ���鵵��Ա
  PROCEDURE price_version(p_Smonth IN VARCHAR2,p_emonth in varchar2,p_memo in varchar2,p_oper in varchar2) is

    v_count number;
    v_pricever pricever%rowtype;
  begin
  /*�������**/
      if p_Smonth is null or p_emonth is null  then
         raise_application_error(errcode, '�鵵�·ݲ���ΪNULL!');
      end if;
       if p_oper is null then
         raise_application_error(errcode, '�鵵��Ա����ΪNULL!');
      end if;

      select count(*) into v_count from pricever t where (p_Smonth>=t.smonth and  p_smonth<= t.emonth );

      IF V_COUNT>0 THEN
         raise_application_error(errcode, '��ʼ�·��Ѵ��ڹ鵵��Ϣ������!');
      END IF;
      V_COUNT:=0;
       select count(*) into v_count from pricever t where (p_emonth>=t.smonth and  p_emonth<= t.emonth );
      IF V_COUNT>0 THEN
         raise_application_error(errcode, '��ֹ�·��Ѵ��ڹ鵵��Ϣ������!');
      END IF;
   /*ˮ�۹鵵**/
     begin
         select SEQ_PRICEVER.Nextval into  v_pricever.id from dual;
          v_pricever.smonth:=p_smonth;
          v_pricever.emonth:=p_emonth;
          v_pricever.oper:=p_oper;
          v_pricever.odate:=sysdate;
          v_pricever.MEMO:=p_memo;
          insert into pricever values v_pricever;
         /*ˮ��*/
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
        --������ϸ
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
            --����
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

