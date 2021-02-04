create or replace procedure hrbzls.pro_flow_define_set( i_fid in flow_define.fid%type ,
                                                    i_fno in flow_define.fno%type,
                                                    i_del_user in operaccnt.OAID%type, 
                                                    i_oper_mk in char, --I 新增 --D 删除
                                                         o_mess out varchar2 
                                                 ) is
  --add 单据流程删除时，相关未审核单据回退上一级
  --add 20141110
  --add hb
  v_flow_main  flow_main%rowtype;--记录包含哪些单据
  -- select * from FLOW_MAIN where fmid ='0000000415' and  fmbillno='3000087500' 
  v_flow_define flow_define%rowtype;
  -- select  *   from FLOW_DEFINE t where FID='0000000415'
  v_KPI_TASK   KPI_TASK%rowtype;  
  -- select * from KPI_TASK WHERE  REPORT_ID  ='3000087500'
  v_billmain BILLMAIN%rowtype ;
  v_erpfunction  erpfunction%rowtype;
  v_operaccnt  operaccnt%rowtype ;
 
  cursor C_FLOW_MAIN IS 
  select * from FLOW_MAIN where fmid =i_fid and  fmno = i_fno  and fmstaus <>'1' ; --未完成的单据
  cursor C_I_FLOW_MAIN IS  --当单据新增时，判断上一级的单据是否有完成，没有完成的需增加一个单据流
  select * from FLOW_MAIN where fmid =i_fid and  fmno = i_fno - 1  and fmstaus <>'1' ; --未完成的单据
  cursor C_BILLMAIN IS 
  SELECT *  FROM BILLMAIN   WHERE    BMFLAG2=i_fid and rownum =1  ;
  cursor C_erpfunction(i_efrunpara erpfunction.efrunpara%type ) IS    
  select   *  from erpfunction   where  efrunpara =i_efrunpara and rownum =1 ; 
  cursor C_v_operaccnt is  
  select   *  from operaccnt  where oaid =i_del_user; 
begin
  open C_v_operaccnt;
  fetch C_v_operaccnt into v_operaccnt;
  close C_v_operaccnt;
  
  if  i_oper_mk ='D' THEN  --流程删除
  --null;
    OPEN C_FLOW_MAIN ;
    LOOP
      FETCH C_FLOW_MAIN
        INTO v_flow_main;
      EXIT WHEN C_FLOW_MAIN%NOTFOUND OR C_FLOW_MAIN%NOTFOUND IS NULL;
         if v_flow_main.fmstaus ='0' then  --未执行
             DELETE FROM FLOW_MAIN
              where fmid =i_fid and 
                  fmno = i_fno  AND  
                  FMBILLNO =v_flow_main.fmbillno ;
         elsif v_flow_main.fmstaus ='2' or  v_flow_main.fmstaus ='3'  then --2 当前执行 3回退
             open C_BILLMAIN ;
             fetch C_BILLMAIN into v_billmain;
             close C_BILLMAIN;
             FLOW_NEXT(i_fid,
             i_fno,
             v_flow_main.fmbillno,
             i_del_user,--需确认
             '1',
             '【'||trim(v_operaccnt.oaname)||'】删除单据流程,单据流程回退',
             v_billmain.BMtype,--is_billtype需确认
              i_del_user,--需确认
                 'N'
                );
                
             open C_erpfunction(v_billmain.bmid) ;
             fetch C_erpfunction into v_erpfunction;
             close C_erpfunction;
                   
             kt_do_report('2',
              '', --需确认 :is_funcid  ,
             i_del_user,--需确认
             v_erpfunction.efid,
             v_flow_main.fmbillno,
             '【'||trim(v_operaccnt.oaname)||'】删除单据流程,单据流程回退');
           end if ;
      END LOOP;
      IF C_FLOW_MAIN%ISOPEN THEN
        CLOSE C_FLOW_MAIN;
      END IF;
 
    ELSif  i_oper_mk ='I' THEN  --流程添加
      OPEN C_I_FLOW_MAIN ;
      LOOP
      FETCH C_I_FLOW_MAIN
        INTO v_flow_main;
      EXIT WHEN C_I_FLOW_MAIN%NOTFOUND OR C_I_FLOW_MAIN%NOTFOUND IS NULL; 
          INSERT INTO FLOW_MAIN(FMID,FMNO,FMBILLNO,FMSTAUS,FMETYPE,FMEMO)
          VALUES(i_fid,i_fno,v_flow_main.fmbillno,'0','0','【'||trim(v_operaccnt.oaname)||'】新增单据流程,单据流程增加') ;
      END LOOP;
      IF C_I_FLOW_MAIN%ISOPEN THEN
        CLOSE C_I_FLOW_MAIN;
      END IF; 
    END IF ;
    
   --  COMMIT ;
      o_mess :='成功';
exception 
  when others then
       --   rollback;
         o_mess :='失败';
end pro_flow_define_set;
/

