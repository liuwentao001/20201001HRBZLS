create or replace procedure hrbzls.sp_qygr(v_resourceyys in varchar2 ,v_purposeyys in varchar2, v_miid in varchar2,v_oper_id  in varchar2) is

   v_count  number;
   v_ye     meterinfo.misaving%type;
begin
   select count(*) into v_count from meterread mr where mrmid=v_miid
   and mr.MRREADOK='Y' ;
   if v_count>0 then 
     RAISE_APPLICATION_ERROR('20001', '该用户存在抄表或者抄表算费记录，不能进行迁移');
   END IF;
   select count(dt.MTDMCODE) into v_count from METERTRANSDT dt,METERTRANShd hd where dt.mtdno=hd.mthno and 
   MTHSHFLAG='N' and MTDMCODE=v_miid;
   if  v_count>0 then 
     RAISE_APPLICATION_ERROR('20002', '该用户存在未完成的换表类工单');
   end if;
   select  count(CIID)  into v_count  from  CUSTCHANGEDT dt , CUSTCHANGEhd hd where dt.ccdno=hd.cchno and cchshflag ='N'
   AND CIID=v_miid;
   if  v_count>0 then 
     RAISE_APPLICATION_ERROR('20003', '该用户存在未完成的用户信息类工单');
   end if;
   select count(PAHMID) into v_count from PAIDADJUSTDT dt ,PAIDADJUSThd hd where dt.padno=hd.pahno  and PAHSHFLAG='N'
   and PAHMID=v_miid;
   if  v_count>0 then 
     RAISE_APPLICATION_ERROR('20004', '该用户存在未完成的实收冲正工单');
   end if;
   select count(RCDCCODE) into v_count from recczdt dt ,recczhd hd where dt.rcdno=hd.rchno and RCHSHFLAG='N' and RCDCCODE=v_miid;
   if  v_count>0 then 
     RAISE_APPLICATION_ERROR('20005', '该用户存在未完成的应收冲正工单');
   end if;
   
    update payment set PPOSITION=v_purposeyys where pmid =v_miid and PPOSITION  like '02%' ;
    
    update recdetail set RDMSMFID=v_purposeyys where exists (select rlid from reclist where rlmid=v_miid and rdid=rlid );
    
    update reclist set RLMIUIID=v_resourceyys ,RLSMFID =v_purposeyys,RLMSMFID=v_purposeyys,RLCSMFID=v_purposeyys where rlmid =v_miid;
    
    update meterreadhis set MRCTRL5=v_resourceyys, MRSMFID=v_purposeyys where MRMID =v_miid;
    
    update meterread set MRCTRL5=v_resourceyys, MRSMFID=v_purposeyys where MRMID =v_miid;
    
    update custinfo  set CISMFID=v_purposeyys where ciid=v_miid; 
    
    update meterinfo set MISMFID=v_purposeyys where miid=v_miid; 
    
    begin
      select misaving into v_ye from meterinfo where miid = v_miid;
    exception
      when no_data_found then
        v_ye := 0;  
    end;  
    
    insert into 区域迁移日志表
      (area_id, re_mismfid, po_mismfid, re_area, po_area, re_mibfid, po_mibfid, re_zkh, po_zkh, miid, opdate, opuser,MISAVING)
    values( EPC_CLI_COL_SEQUENCE.NEXTVAL,v_resourceyys,v_purposeyys,'','','','','','',v_miid,sysdate,v_oper_id,v_ye);
    
    if sqlcode<>0 then 
      RAISE_APPLICATION_ERROR('20006', '迁移写记录失败!');
    end if; 
    commit;
end sp_qygr;
/

