create or replace procedure hrbzls.sp_plzkh(
v_recourcecpy  in meterinfo.mismfid%type,  --营业所
v_recourcedh  in meterinfo.MISAFID%type,   --代号
v_recourcebc1  in number,    --表册1
v_recourcebc2  in number,    --表册2
v_BFRCYC in bookframe.BFRCYC%type, --抄表周期
v_BFNRMONTH in bookframe.BFNRMONTH%type,
v_cby  in bookframe.BFRPER%type -- 抄表员
) is

 i number ;
 v_count number :=0;
 j number :=1;



 v_sql varchar2(500):=''; --动态语句
 v_bc VARCHAR2(10);
 v_max_bc VARCHAR2(10);

  v_date  date;
  v_month  varchar2(7);
  V_NAME VARCHAR(30);
  v_nextmonth  bookframe.bfnrmonth%type;
begin
    select to_char(sysdate,'yyyy.mm') into v_nextmonth from dual;
    
    if to_number(substr(v_BFNRMONTH,6,2))+ v_BFRCYC>12 then
       v_nextmonth:=concat(to_char(to_number(substr(v_BFNRMONTH,1,4))+1),'.')||lpad(to_char(to_number(substr(v_BFNRMONTH,6,2)) + v_BFRCYC - 12),2,'0');
    else
      v_nextmonth:=concat(substr(v_BFNRMONTH,1,4),'.')||lpad(to_char(to_number(substr(v_BFNRMONTH,6,2))+ v_BFRCYC),2,'0');
    end if;
    v_date:=to_date(substr(v_nextmonth,1,4)||'/'||substr(v_nextmonth,6,2)||'/'||'01','yyyy/mm/dd');
    select count(*) into v_count from bookframe where BFID=v_cby and  bfclass='2' ;
    --select count(*) into v_count from bookframe where SUBSTR(BFID,1,5)=v_recourcedh and (bfclass='3' or bfclass='2') ;
    if v_count>0 then  --如果存在这个代号

        select max(bfid) into v_max_bc from bookframe where  substr(bfid,1,5)=v_recourcedh and to_number(substr(bfid,6,3))  between  v_recourcebc1  and v_recourcebc2  and bfclass='3';
        i:=1;
        if trim(v_max_bc)=''  or  nvl(  v_max_bc,0)=0 then --如果这个代号下没有表册
          j:= v_recourcebc2 - v_recourcebc1 + 1 ;
          while i<= j loop
           v_bc:=v_recourcedh||lpad(to_char(v_recourcebc1+i - 1),3 ,'0');
           i:=i+1;
            insert into bookframe(bfid,bfsmfid,bfbatch,bfname,bfpid,bfclass,bfflag,bfstatus,bfmemo,bforder,bfcreper,
           bfcredate,bfrcyc,bflb,bfrper,bfsafid,bfnrmonth,bfday,bfsdate,bfedate,bfmonth,bfpper)
           values( v_bc,v_recourcecpy,1,concat(concat(substr(v_recourcecpy,3),substr(v_recourcedh,4)),substr(v_bc,7))||'H' ,/*v_cby*/v_recourcedh,
           '3','Y','Y',v_cby,0,v_cby,SYSDATE,v_BFRCYC,'H',v_cby,v_recourcedh,v_nextmonth,0,to_date(to_char(trunc(v_date,'MONTH'),'yyyy-mm-dd'),'yyyy-mm-dd' )
         ,to_date(to_char(last_day(trunc(v_date,'MONTH')),'yyyy-mm-dd')，'yyyy-mm-dd' ),v_BFNRMONTH,v_cby );
          end loop;
        else --如果这个代号下有表册
           RAISE_APPLICATION_ERROR('20001', '表册区间不能超过999');
         end if;

    else  -- 不存在这个代号
       SELECT OANAME INTO V_NAME FROM OPERACCNT  WHERE OAID=v_cby;
       insert into  bookframe(bfid,bfsmfid,bfbatch,bfname,bfpid,bfclass,bfflag,bfstatus,bfmemo,bforder,bfcreper,
           bfcredate,bfrcyc,bflb,bfrper,bfsafid,bfnrmonth,bfday,bfsdate,bfedate,bfmonth,bfpper)
          values( v_cby,v_recourcecpy,0,concat(v_recourcedh,V_NAME),substr(v_recourcecpy,3,2),
           '2','N','Y','按抄表员分组',0,v_cby,SYSDATE,v_BFRCYC,'',v_cby,'',v_nextmonth,0,to_date(to_char(trunc(v_date,'MONTH'),'yyyy-mm-dd'),'yyyy-mm-dd' )
         ,to_date(to_char(last_day(trunc(v_date,'MONTH')),'yyyy-mm-dd')，'yyyy-mm-dd' ),v_BFNRMONTH,v_cby );
       i:=1;
       if v_recourcebc2>999 then
         RAISE_APPLICATION_ERROR('20001', '表册区间不能超过999');
       end if;
       while i<= v_recourcebc2 - v_recourcebc1+1  loop
         v_bc:=rtrim(v_recourcedh||lpad(to_char(v_recourcebc1+i - 1),3 ,'0'));
         i:=i+1;
          insert into bookframe(bfid,bfsmfid,bfbatch,bfname,bfpid,bfclass,bfflag,bfstatus,bfmemo,bforder,bfcreper,
         bfcredate,bfrcyc,bflb,bfrper,bfsafid,bfnrmonth,bfday,bfsdate,bfedate,bfmonth,bfpper)
         values( v_bc,v_recourcecpy,1,concat(concat(substr(v_recourcecpy,3),substr(v_recourcedh,4)),substr(v_bc,7))||'H' ,/*v_cby*/v_recourcedh,
         '3','Y','Y',v_cby,0,v_cby,SYSDATE,v_BFRCYC,'H',v_cby,v_recourcedh,v_nextmonth,0,to_date(to_char(trunc(v_date,'MONTH'),'yyyy-mm-dd'),'yyyy-mm-dd' )
       ,to_date(to_char(last_day(trunc(v_date,'MONTH')),'yyyy-mm-dd')，'yyyy-mm-dd' ),v_BFNRMONTH,v_cby );

       end loop;
    end if;
commit;
end sp_plzkh;
/

