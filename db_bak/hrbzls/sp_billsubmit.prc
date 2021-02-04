CREATE OR REPLACE PROCEDURE HRBZLS."SP_BILLSUBMIT" (p_billno varchar2,
                                              omrid out varchar2) as   --������ˮ

  v_morid varchar2(50);
  v_code varchar2(50);
  v_mrid varchar2(50);
  v_ylid varchar2(50);
  v_str varchar2(50);
  md    METERTRANSDT%rowtype;
begin
      for md in (select * from METERTRANSDT where mtdno=p_billno) loop
         sp_insertmr_xg2(md,v_morid);      --��ӳ����
         if v_morid is not null then
           /* begin
             select mrmcode,mrid into v_code,v_mrid from meterread where mrid = v_morid;
            exception when others then
             raise_application_error(-20010, '�˳����¼������!');
            end;*/
            --��ȡ������ˮ

            begin
               select masid into v_ylid from meteraddsl where masbillno=p_billno and MASMID = md.mtdmid ;
            exception when others then
              raise_application_error(-20010, '��������¼��¼������!');
            end;
            
            pg_ewide_raedplan_01.sp_useaddingsl(v_mrid,v_ylid,v_str);
            if v_str is not null then
              pg_ewide_meterread_01.Calculate(v_morid);    --���
              insert into meterreadhis (select * from meterread where mrid=v_morid);
              delete meterread where mrid=v_morid;
            end if;
            omrid := v_code;
          end if;
      end loop;
      
      
      
end sp_billSUBMIT;
/

