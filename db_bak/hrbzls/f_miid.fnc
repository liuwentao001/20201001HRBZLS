create or replace function hrbzls.f_miid(v_fun in VARCHAR2,v_reportid in varchar2,v_mis in varchar2) return VARCHAR2
as
  v_bmdwpkey  VARCHAR2(40);
  v_miid VARCHAR2(20);
  v_bmtype varchar2(10);

begin
  if v_mis='null' or trim(v_mis)='' then
    v_miid:='';
  else
    select distinct lower(bmdwpkey),bmtype into v_bmdwpkey,v_bmtype from BILLMAIN,ERPFUNCTION where bmid=efrunpara and  efid=v_fun;
    if lower(v_bmdwpkey)='cchno' then
                                 
        select MAX( t.ciid) into v_miid from CUSTCHANGEDT t where t.ccdno=v_reportid and CISMFID=v_mis ;

    end if;
    if lower(v_bmdwpkey)='pahno' then
      select MAX( t.pahmcode) into v_miid from PAIDADJUSThd t where t.pahno=v_reportid and PAHSMFID=v_mis;
    end if;
     if lower(v_bmdwpkey)='rchno' then
      select MAX( RCDCCODE) into v_miid from  recczdt t,recczhd where t.rcdno=v_reportid and RCHSMFID=v_mis and t.rcdno=RCHNO ;
    end if;
    if lower(v_bmdwpkey)='rthno' then
      select MAX( RTHCID) into v_miid from  RECTRANSHD t where t.rthno=v_reportid and RTHSMFID=v_mis;
    end if;
  end if;
  return(v_miid);
end f_miid;
/

