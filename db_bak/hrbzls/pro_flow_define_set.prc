create or replace procedure hrbzls.pro_flow_define_set( i_fid in flow_define.fid%type ,
                                                    i_fno in flow_define.fno%type,
                                                    i_del_user in operaccnt.OAID%type, 
                                                    i_oper_mk in char, --I ���� --D ɾ��
                                                         o_mess out varchar2 
                                                 ) is
  --add ��������ɾ��ʱ�����δ��˵��ݻ�����һ��
  --add 20141110
  --add hb
  v_flow_main  flow_main%rowtype;--��¼������Щ����
  -- select * from FLOW_MAIN where fmid ='0000000415' and  fmbillno='3000087500' 
  v_flow_define flow_define%rowtype;
  -- select  *   from FLOW_DEFINE t where FID='0000000415'
  v_KPI_TASK   KPI_TASK%rowtype;  
  -- select * from KPI_TASK WHERE  REPORT_ID  ='3000087500'
  v_billmain BILLMAIN%rowtype ;
  v_erpfunction  erpfunction%rowtype;
  v_operaccnt  operaccnt%rowtype ;
 
  cursor C_FLOW_MAIN IS 
  select * from FLOW_MAIN where fmid =i_fid and  fmno = i_fno  and fmstaus <>'1' ; --δ��ɵĵ���
  cursor C_I_FLOW_MAIN IS  --����������ʱ���ж���һ���ĵ����Ƿ�����ɣ�û����ɵ�������һ��������
  select * from FLOW_MAIN where fmid =i_fid and  fmno = i_fno - 1  and fmstaus <>'1' ; --δ��ɵĵ���
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
  
  if  i_oper_mk ='D' THEN  --����ɾ��
  --null;
    OPEN C_FLOW_MAIN ;
    LOOP
      FETCH C_FLOW_MAIN
        INTO v_flow_main;
      EXIT WHEN C_FLOW_MAIN%NOTFOUND OR C_FLOW_MAIN%NOTFOUND IS NULL;
         if v_flow_main.fmstaus ='0' then  --δִ��
             DELETE FROM FLOW_MAIN
              where fmid =i_fid and 
                  fmno = i_fno  AND  
                  FMBILLNO =v_flow_main.fmbillno ;
         elsif v_flow_main.fmstaus ='2' or  v_flow_main.fmstaus ='3'  then --2 ��ǰִ�� 3����
             open C_BILLMAIN ;
             fetch C_BILLMAIN into v_billmain;
             close C_BILLMAIN;
             FLOW_NEXT(i_fid,
             i_fno,
             v_flow_main.fmbillno,
             i_del_user,--��ȷ��
             '1',
             '��'||trim(v_operaccnt.oaname)||'��ɾ����������,�������̻���',
             v_billmain.BMtype,--is_billtype��ȷ��
              i_del_user,--��ȷ��
                 'N'
                );
                
             open C_erpfunction(v_billmain.bmid) ;
             fetch C_erpfunction into v_erpfunction;
             close C_erpfunction;
                   
             kt_do_report('2',
              '', --��ȷ�� :is_funcid  ,
             i_del_user,--��ȷ��
             v_erpfunction.efid,
             v_flow_main.fmbillno,
             '��'||trim(v_operaccnt.oaname)||'��ɾ����������,�������̻���');
           end if ;
      END LOOP;
      IF C_FLOW_MAIN%ISOPEN THEN
        CLOSE C_FLOW_MAIN;
      END IF;
 
    ELSif  i_oper_mk ='I' THEN  --�������
      OPEN C_I_FLOW_MAIN ;
      LOOP
      FETCH C_I_FLOW_MAIN
        INTO v_flow_main;
      EXIT WHEN C_I_FLOW_MAIN%NOTFOUND OR C_I_FLOW_MAIN%NOTFOUND IS NULL; 
          INSERT INTO FLOW_MAIN(FMID,FMNO,FMBILLNO,FMSTAUS,FMETYPE,FMEMO)
          VALUES(i_fid,i_fno,v_flow_main.fmbillno,'0','0','��'||trim(v_operaccnt.oaname)||'��������������,������������') ;
      END LOOP;
      IF C_I_FLOW_MAIN%ISOPEN THEN
        CLOSE C_I_FLOW_MAIN;
      END IF; 
    END IF ;
    
   --  COMMIT ;
      o_mess :='�ɹ�';
exception 
  when others then
       --   rollback;
         o_mess :='ʧ��';
end pro_flow_define_set;
/

