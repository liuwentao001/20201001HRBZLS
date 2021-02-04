CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_PAD_DL IS

  /*
  * ���ܣ������û�������Ϣ
  * ������:������
  * ����ʱ�䣺2014-07-23
  * @�����Ϣ
  * @����Ա���
  * @�����α�
  */
  procedure DOWN_DATA(I_BFIDS   IN VARCHAR2,
                    I_BFRPER  IN VARCHAR2,
                    i_version  IN VARCHAR2, --�汾��
                    O_CURRSOR OUT SYS_REFCURSOR) IS
    li_old_pos1     NUMBER;
    li_pos1         NUMBER;
    i               NUMBER;
    li_exit         boolean;
    v_temp_str      varchar2(200);
    v_bfids varchar2(4000);
    --����Ա���
    v_count number;
    v_�ֵ�CODE  datadesign.�ֵ�CODE%type;
  BEGIN
     BEGIN 
       select �ֵ�CODE into v_�ֵ�CODE from datadesign where �ֵ�����='�ֻ��ͻ��˰汾' ;
       EXCEPTION 
          WHEN OTHERS THEN
            v_�ֵ�CODE:='';
       END ;
       if trim(NVL(v_�ֵ�CODE,'NULL'))<> trim(nvl(i_version,'NULL')) then  --�ֻ��汾�Ƿ�ͻ��˰汾һ�£���һ�����ر������Ϊ��
          return ;
         end if ;
/*    --I_BFIDS������ʱ��
      li_old_pos1 := 0;
      li_pos1     := 0;
      I           := 1;
      li_exit     := true;
      if instr(I_BFIDS, ',') = 0 then
         li_exit := false;
      end if;

      WHILE li_exit LOOP
        li_pos1 := instr(I_BFIDS, ',', 1, i);
        if li_pos1 = 0 then
          exit;
        end if;
        v_temp_str := substr(I_BFIDS,
                             li_old_pos1 + 1,
                             li_pos1 - li_old_pos1 - 1);

        if v_temp_str is not null then
           insert into pad_bfids(c1,c2)values(I_BFRPER,v_temp_str);
           if v_bfids is not null then
              v_bfids := v_bfids||',';
           end if;
           v_bfids := v_bfids||''''||v_temp_str||'''';
        end if;
        li_old_pos1 := li_pos1;
        i           := i + 1;
      END LOOP;*/
      
    OPEN O_CURRSOR FOR
    --ɾ���û���Ϣ
   -- SELECT 'DELETE FROM custinfo WHERE BFID in('||v_bfids||') ' FROM DUAL
   SELECT 'DELETE FROM custinfo  ' FROM DUAL
    UNION ALL
    --�û�������Ϣ
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,isprint,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,BARCODE,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,apply_date,sfjg,psfjg,MDMODEL) values(' || 
    '''' || ���� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ����||''','||
    '''' || �û���ַ||''','||
    ''''||��ϵ��||''','||
    ''''||��ϵ�绰||''','||
    ''''||�ƶ��绰||''','||
    ''''||�û�����||''','||
    ''''||��ˮ����||''','||
    ''''||��ˮ��������||''','||
    ''''||�����||''','||
    ''''||�������||''','||
    ''''||�������||''','||
    ''''||�˿���||''','||
    ''''||����Ԥ����||''','||
    ''''||����Ԥ����||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||��ӡ��־||''','||
    ''''||�ϴγ�������||''','||
    ''''||�Ƿ����||''','||
    ''''||���״��||''','||
    ''''||��ҳ��||''','||
    ''''||�û����||''','||
    ''''||�û���ע||''','||
    ''''||Ӧ�ս��||''','||
    ''''||Ӧ��ˮ��||''','||
    ''''||��ʵ����||''','||
    ''''||����״̬||''','||
    ''''||С����||''','||
    ''''||С������||''','||
    ''''||�ʿ���||''','||
    ''''||¥��||''','||
    ''''||��Ԫ��||''','||
    ''''||���ע��||''','||
    ''''||ʾ����Դ||''','||
    ''''||���γ�������||''','||
    ''''||������||''','||
    ''''||�»���||''','||
    ''''||����ˮ����||''','||
    ''''||����ˮ��������||''','||
    ''''||���������־||''','||
    ''''||�Ƿ񱾴γ���||''','||  --meterreadingline_way(�Ƿ񱾴γ���·��)    cahr   1�����Ǳ���   0�����Ǳ���
     -- '''1'','||   --�Ƿ񱾴γ���
    '''1'','||
    '''1'','|| 
    '''1'','||
    ''''||�޸�ʱ��||''','||
    ''''||ˮ�ѵ���||''','||
    ''''||��ˮ�ѵ���||''','||
    ''''||���ͺ�||''')'
  FROM (SELECT MAX(T2.MIID) ����,
        MAX(replace(replace(T2.MINAME,chr(10),''),chr(13),''))����,
        MAX(replace(replace(T2.MINAME2,chr(10),''),chr(13),''))��ʵ����,
        MAX(replace(replace(T2.MIADR,chr(10),''),chr(13),''))�û���ַ,
        MAX(replace(replace(T1.CICONNECTPER,chr(10),''),chr(13),''))��ϵ��,
        --MAX(T1.CICONNECTPER)��ϵ��,  
              -- MAX(T2.MIADR) �û���ַ,
              -- MAX(T1.CICONNECTPER) ��ϵ��,
/*          ( case when instr( MAX(T1.citel1),CHR(10)) > 0  then 
  substr( MAX(T1.citel1),1,instr( MAX(T1.citel1),CHR(10)) - 2)   else  MAX(T1.citel1) end ) ��ϵ�绰,
                       ( case when instr( MAX(T1.CIMTEL),CHR(10)) > 0  then 
  substr( MAX(T1.CIMTEL),1,instr( MAX(T1.CIMTEL),CHR(10)) - 2)   else  MAX(T1.CIMTEL) end ) �ƶ��绰,*/
   -- MAX(T1.citel1) ��ϵ�绰,
    max(replace(replace(T1.citel1,chr(10),''),chr(13),'')) ��ϵ�绰,
  -- MAX(T1.CIMTEL) �ƶ��绰,
   max(replace(replace(T1.CIMTEL,chr(10),''),chr(13),''))�ƶ��绰,
            --   MAX(T1.citel1) ��ϵ�绰,
            --   MAX(T1.CIMTEL) �ƶ��绰,
              -- MAX(T1.CICONNECTMTEL) �ƶ��绰,
             --  MAX(T1.CICHARGETYPE) �û�����,
              MAX(T2.mICHARGETYPE) �û�����, --20150308
               MAX(T2.MIPFID) ��ˮ����,
          FGETPRICENAME(MAX(T2.MIPFID)) ��ˮ��������,
               MAX(nvl(T3.MRBFID,t6.bfid)) �����,
               MAX(nvl(T3.MRBFID,t6.bfid)) �������, 
               max(nvl(t3.MRRORDER,t2.mirorder)) �������, --20150308
               SUM(T2.MIUSENUM) �˿���,  
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30')   AND  t3.MRREADOK <> 'N' and nvl(t3.mrdatasource,'X') <> '9'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)     -- ���ֻ����������
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30')   AND  t3.MRREADOK <> 'N'  and nvl(t3.mrdatasource,'X') = '9' THEN  T3.MRPLANJE02    -- �ֻ��������
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                    --    when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                     when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  nvl(T3.MRPLANJE03,0)--20150414��̶��������ձ��ӡ��������� 
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') <> '9'   THEN  nvl(t3.mrsl,0)  --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд���   
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'   THEN  T3.MRPLANSL  --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) Ӧ��ˮ��, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) ����Ԥ����, 
      
          --   sum(VIEW1.rlsl) Ӧ��ˮ��,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                    --     when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0 /*t3.mrsl*/   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                          when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01 --20150414��̶��������ձ��ӡ���������
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end ) Ӧ�ս��, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0 /*T3.MRYEARJE01*/ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE01 --20150414��̶��������ձ��ӡ���������
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ˮ��, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE02 */ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02   --20150414��̶��������ձ��ӡ���������
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ��ˮ��, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                        -- when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE03 */ --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE03 --20150414��̶��������ձ��ӡ���������
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ���ӷ�,                   
               max(case when t3.MRREQUISITION > 0 then 'Y' ELSE 'N' END ) ��ӡ��־,
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) �ϴγ�������,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) �Ƿ����,
               'N'  �Ƿ����,
               'δ��' ���״��, 
              MAX(T3.mrbatch) ��ҳ��,--��ҳ�Ÿĳ��ʿ���
              -- MAX(T2.miseqno) �ʿ���, 
               MAX(T2.MILB) �û����,
   ( case when instr( MAX(T2.mimemo),CHR(10)) > 0  then 
  substr( MAX(T2.mimemo),1,instr( MAX(T2.mimemo),CHR(10)) - 2)   else  MAX(T2.mimemo) end ) �û���ע,  
            --   MAX(T2.mimemo)�û���ע,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
             MAX(CASE when  T3.MRREADOK ='Y'  THEN '�����'
                      when  T3.MRREADOK ='N'  THEN 'δ����'
                      when  T3.MRREADOK ='X'  THEN '�����'
                      when  T3.MRREADOK ='U'  THEN 'δͨ��'
                      else 'δ����' END) ����״̬,
              --  MAX(DECODE(T3.MRREADOK,'Y','�ѳ���','N','δ����','X','�����')) ����״̬,

                 max(t2.MICOMMUNITY) С����,
               max(t2.MISEQNO) �ʿ���,
                  max(t2.MILH)  ¥��,
                 max(t2.MIDYH) ��Ԫ��,
                  max(t4.diname) С������,
              MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --����ˡ��ѳ���
                      when  T3.MRREADOK ='N' or  T3.MRREADOK ='U'  THEN 'N'  --δ����
                      else 'N' END) ���ע�� ,
             decode(max(T3.MRIFGU),'1','����','2','����','3','�绰��','4','δ����') ʾ����Դ,
            --   max(t3.MRRDATE) ���γ�������,
                to_char( max(t3.MRRDATE),'yyyy-mm-dd hh24:mi:ss')   ���γ�������,
               max(t5.BARCODE) ������, 
               
              --decode(nvl(max(MIYL5),'N'),'N',    max(T2.miname))   , MAX(MIJD)   �»���,
              decode(nvl(max(MIYL5),'N'),'N',     MAX(replace(replace(T2.miname,chr(10),''),chr(13),'')))   , MAX(replace(replace(MIJD,chr(10),''),chr(13),''))   �»���,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(miyl6)  ) ����ˮ����,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(miyl6)) )����ˮ��������,
              decode(nvl(max(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ���������־,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) �Ƿ񱾴γ��� ,
            to_char(max(MIYL10),'yyyy-mm-dd hh24:mi:ss') �޸�ʱ��,
             -----zhw20160415�޸����³����µ���
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  ˮ�ѵ���,
                 fun_getjtdqdj( max(MIPFID), max(MIPRIID) , max(miid) ,'1') ˮ�ѵ���,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     ��ˮ�ѵ���,
               fgetwsf(max(mipfid)) ��ˮ�ѵ���, 
                -----------------------------------------------------------end
            t2.MIRTID ���ͺ�
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 ȡ��
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 ȡ��
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid    AND RLREVERSEFLAG <> 'Y'
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2,bookframe t6  --ץȡ�Ѿ���ѵ�
         WHERE T1.CIID = T2.MICID
           AND T2.MIID = T3.MRMID(+)
           and t2.mibfid =t6.bfid
           and t2.miid = t5.MDMID
          -- AND T4.SMMIID = T2.MIID
           AND T2.MIID = VIEW1.RLMID(+)
           and t2.MICOMMUNITY=t4.diid(+)
          and t3.mrid =view2.rlmrid(+)
          and t6.BFRPER =I_BFRPER
          and t2.mibfid is not null
          --and t3.mrdatasource <> 'I'       --ȥ�� ͨ�����ܱ�ƽ̨�ӿڵ�
  /*         and exists(
             select 1 from pad_bfids tt where tt.c1 = I_BFRPER and tt.c2 = t2.mibfid
           )*/
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID)
          
  UNION ALL
  
  --ɾ��ˮ����Ϣ
 -- SELECT 'DELETE FROM meterinfo WHERE BFID in('||v_bfids||') ' FROM DUAL
  SELECT 'DELETE FROM meterinfo ' FROM DUAL
  UNION ALL
  
  --ˮ�������Ϣ
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid,mrdzflag,mrdzcurcode,miyl9) values(' || 
    '''' || ��λ�� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ��λ||''','||
    '''' || ����||''','||
    ''''||�ھ�||''','||
    ''''||�����||''','||
    ''''||ˮ������||''','||
    ''''||��װ����||''','||
    ''''||��������||''','||
    ''''||�ϴγ�������||''','||
    ''''||����||''','||
    ''''||ֹ��||''','||
    ''''||ˮ��||''','||
    ''''||���||''','||
    ''''||�ϴγ�������||''','||
    ''''||���¾���||''','||
    ''''||Ǧ���||''','||
    ''''||������||''','||
    ''''||�±�����||''','|| 
    ''''||�Ƿ���||''','||
    ''''||���ۼ�ˮ��||''','||
    ''''||����������||''','||
    ''''||�˿���||''','||
    ''''||��ˮ����||''','||
    ''''||�ϴγ���ˮ��||''','||
    ''''||��ˮ��������||''','||
    ''''||��������||''','||
    ''''||����ע||''','||
    ''''||Ӫҵ������||''','||
    ''''||Ӫҵ��˵��||''','||
    ''''||�շѷ�ʽ����||''','||
    ''''||�շѷ�ʽ˵��||''','||
    ''''||���˵��||''','||
    ''''||���ձ������||''','||
    ''''||���ձ��־||''','||
    ''''||�����ܷ��||''','||
    ''''||�����ַ��||''','||
    ''''||����շ��||''','||
    ''''||������||''','||
    ''''||ˮ��״̬||''','||
    ''''||�����־||''','||
    ''''||�ֱܷ��־||''','||
    ''''||�ܱ���||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||Ӧ�ս��||''','||
    ''''||����||''','||
    ''''||�����־||''','||
    ''''||�����û�ʵ�ʶ���||''','||
    ''''||ˮ������||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END ��λ��,
       T2.MIID ����, 
        T2.Miname ����,
        T2.Miadr �û���ַ,
     decode(t2.MISIDE,'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
      t5.MDBRAND ����,
       T5.MDCALIBER �ھ�,
       --T2.MINO �����,
      --substrb(t5.MDNO,1,13) �����,
      replace(replace(t5.MDNO,chr(10),''),chr(13),'') �����,
      --decode( T3.MRBFID,'06507235','', t5.MDNO )�����,
       T2.MILB  ˮ������,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') ��װ����,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') ��������,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END �ϴγ�������,
       NVL(T3.MRSCODE,0) ����,
       T3.MRECODE ֹ��,
    --   T3.MRSL ˮ��,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                            when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') <> '9'    THEN  t3.mrsl --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд���                
                            when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'   THEN  T3.MRPLANSL --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) , T3.MRSL )ˮ��, --�ֱܷ�ˮ������Ϊʵ�ʵ�ˮ��
       NVL(T3.MRFACE2,'01')  ���,--ʵ���Ǽ���̬20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') ���,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end ������,
       0 ������,
       t3.MRTHREESL ���¾���,
       t5.QFH Ǧ���,
       0 �±�����,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end �Ƿ���,
       'N' �Ƿ���,
       T3.MRBFID ����,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') ����������,
       ''  ����������,
       T2.MIUSENUM �˿���,
       t2.mipfid ��ˮ����,
      -- CASE WHEN T2.MIPFID='9999' THEN '�����ˮ' else FGETPRICENAME(t2.mipfid) end ��ˮ��������,
       FGETPRICENAME(t2.mipfid) ��ˮ��������,
       --T2.miyeartotalsl ���ۼ�ˮ��,20150308
       fun_getjtdqdj( MIPFID, MIPRIID , miid ,'3') ���ۼ�ˮ��,
       T2.MIRECSL �ϴγ���ˮ��,
      DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO)  ����ע,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) �������� 20150308
       T4.BFRCYC ��������,
       t2.MISMFID Ӫҵ������,
       fgetsmfname(t2.MISMFID ) Ӫҵ��˵��,
        t2.MICHARGETYPE �շѷ�ʽ����,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  ���˵��,-- 20150310����̬˵��
         decode( t2.MICHARGETYPE,'X','����','M','����') �շѷ�ʽ˵��,
         t2.MIPRIID ���ձ������,
         t2.MIPRIFLAG ���ձ��־,
         --t5.DQSFH �����ܷ��,
         replace(replace(t5.DQSFH,chr(10),''),chr(13),'') �����ܷ��,
         replace(replace(t5.DQGFH,chr(10),''),chr(13),'') �����ַ��,
         replace(replace(t5.JCGFH,chr(10),''),chr(13),'') ����շ��,
         -- t5.DQGFH �����ַ��,
         -- t5.JCGFH  ����շ��,
         t5.BARCODE ������,
         t2.MISTATUS ˮ��״̬,
         nvl(t5.IFDZSB,'N') �����־,  --Ԥ��ΪN
       --  t5.IFDZSB �����־,
         t2.MICLASS �ֱܷ��־,
         nvl(t2.MIPID,t2.miid) �ܱ���,  
  /*             (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --���쳣����0ˮ��
              else   T3.MRYEARJE01 end  )  ˮ��, 
           (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --���쳣����0ˮ��
              else   T3.MRYEARJE02 end  )  ��ˮ��, 
         (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --���쳣����0ˮ��
              else   T3.MRYEARJE03 end  )  ���ӷ�, 
      (  case when  T3.MRREADOK ='N'  THEN  nvl(VIEW1.RLJE,0)  
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --���쳣����0ˮ��
              else   T3.MRPLANJE01 end  )   Ӧ�ս��  --��������������ץȡ֮ǰ��Ӧ�պϼ�*/
                                                  
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE01*/ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE01 --20150415
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ˮ��, 
                           
                  case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02 /*T3.MRYEARJE02*/  --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ��ˮ��, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03 /*T3.MRYEARJE03*/  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ���ӷ�,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01 /*t3.mrsl*/   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end  Ӧ�ս�� ,
                         nvl(t3.mrdzflag,'N') �����־,
                         t3.mrdzcurcode �����û�ʵ�ʶ���,
                         t2.miyl9 ˮ������
                           
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --ץȡ�Ѿ���ѵ�
 WHERE T1.CIID = T2.MICID
   and t2.miid   = t3.mrmid(+)
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and t2.miid = VIEW1.RLMID(+)
   and t3.mrid =view2.rlmrid(+)
   and T4.BFRPER =I_BFRPER
   and t2.mibfid is not null
   --and t3.mrdatasource <> 'I'    --ȥ��ͨ�����ܱ�ƽ̨�ӿڵ�����
/*   and exists(
      select 1 from pad_bfids tt where tt.c1 = I_BFRPER and tt.c2 = t2.mibfid
   )*/
   )
   
   UNION ALL
   --ɾ��ˮ����Ϣ
   select 'DELETE FROM price_detail' from dual
   
   UNION ALL
   
   --ˮ����Ϣ
   SELECT 'insert into price_detail(pfid,pfname,start_date,end_date,sfdj,psfdj,jyfdj,szydj,curr_dj,step,start_usenum,end_usenum,isstep) values(' || 
    '''' || ��ˮ���� || ''',' || 
    '''' || ��ˮ�������� || ''',' ||
    '''' || ��ʼʱ��||''','||
    '''' || ����ʱ��||''','||
    ''''||ˮ�ѵ���||''','||
    ''''||NVL(��ˮ�ѵ���,0)||''','||
    ''''||NVL(���μ�ѹ����,0)||''','||
    ''''||NVL(�����ѵ���,0)||''','||
    ''''||�Ƿ�ǰ��||''','||
    ''''||���ݺ�||''','||
    ''''||��ʼˮ��||''','||
    ''''||����ˮ��||''','||
    ''''||�Ƿ����||''')'
  FROM (select T.PDPFID ��ˮ����,
               MAX(T2.PFNAME) ��ˮ��������,
               MAX(CASE
                     WHEN T.PDPIID = '01' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) ˮ�ѵ���,
               MAX(CASE
                     WHEN T.PDPIID = '02' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) ��ˮ�ѵ���,
               MAX(CASE
                     WHEN T.PDPIID = '04' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) ���μ�ѹ����,
               0 �����ѵ���,
               '1900-01-01' ��ʼʱ��,
               '2080-12-30' ����ʱ��,
               'Y' �Ƿ�ǰ��,
               1 ���ݺ�,
               'N' �Ƿ����,
               0 ��ʼˮ��,
               0 ����ˮ��
          FROM  PRICEDETAIL T, PRICEFRAME T2
         WHERE T.PDPFID = T2.PFID
/*           AND NOT EXISTS
         (SELECT * FROM  pricestep T3 WHERE T3.PSPFID = T.PDPFID)*/
         GROUP BY T.PDPFID

        UNION ALL

        select T3.pspfid ��ˮ����,
               T2.PFNAME ��ˮ��������,
               CASE
                 WHEN T.PDPIID = '01' THEN
                  T3.Psprice
                 ELSE
                  0
               END ˮ�ѵ���,
               view4. ��ˮ�ѵ���,
               view4.���μ�ѹ����,
               0 �����ѵ���,
               '1900-01-01' ��ʼʱ��,
               '2080-12-30' ����ʱ��,
               'Y' �Ƿ�ǰ��,
               t3.psclass ���ݺ�,
               'Y' �Ƿ����,
               T3.PSSCODE-1 ��ʼˮ��,
               T3.PSECODE ����ˮ��
          FROM  PRICEDETAIL T,
                PRICEFRAME T2,
                pricestep T3,
               (select t4.pdpfid,
                       max(case
                             when t4.pdpiid = '02' then
                              t4.PDDJ
                             else
                              0
                           end) ��ˮ�ѵ���,
                       max(case
                             when t4.pdpiid = '04' then
                              t4.PDDJ
                             else
                              0
                           end) ���μ�ѹ����
                  from  PRICEDETAIL t4
                 where t4.pdpiid <> '01'
                 group by t4.pdpfid) view4
         WHERE T.PDPFID = T2.PFID
           AND T.Pdpfid = t3.pspfid
           and t.pdpiid = t3.pspiid
           and t.pdpfid = view4.pdpfid(+)
)

UNION ALL
--20150308 �����ˮ��ʱ������
/*--�����ˮ��Ϣ
SELECT ' DELETE FROM mixtureinfo where bfid in ('||v_bfids||') ' FROM DUAL

UNION ALL

SELECT 'insert into mixtureinfo(ciid,miid,pfid,rate_scale,ratify_sl,data_type,isstep,pfname,bfid) values(' || 
    '''' || �û���� || ''',' || 
    '''' || ˮ���� || ''',' ||
    '''' || ��ˮ����||''','||
    '''' || ��ϱ���||''','||
    ''''||�˶�ˮ��||''','||
    ''''||��������||''','||
    ''''||�Ƿ����||''','||
    ''''||��ˮ��������||''','||
    ''''||�����||''')'
  FROM (SELECT T2.MICID �û����,
       T2.MIID ˮ����,
       T3.PMDPFID ��ˮ����,
       T3.PMDSCALE ��ϱ���,
       '1' ��������,
       CASE WHEN T3.PMDPFID LIKE '0104%' THEN 'Y'ELSE 'N' END �Ƿ����,
       T2.MIBFID �����,
       '0' �˶�ˮ��,
       FGETPRICENAME(T3.PMDPFID) ��ˮ��������
  FROM  METERINFO T2,  PRICEMULTIDETAIL T3
 WHERE T2.MIID = T3.PMDMID
   AND exists (select 1
          from pad_bfids tt
         where tt.c1 = I_BFRPER
           and tt.c2 = t2.Mibfid)) 
UNION ALL

SELECT 'insert into mixtureinfo(ciid,miid,pfid,rate_scale,ratify_sl,data_type,isstep,pfname,bfid) values(' || 
    '''' || �û���� || ''',' || 
    '''' || ˮ���� || ''',' ||
    '''' || ��ˮ����||''','||
    '''' || ��ϱ���||''','||
    ''''||�˶�ˮ��||''','||
    ''''||��������||''','||
    ''''||�Ƿ����||''','||
    ''''||��ˮ��������||''','||
    ''''||�����||''')'
  FROM (SELECT T2.MICID �û����,
       T2.MIID ˮ����,
     --  T3.RAPFID ��ˮ����,
       '' ��ϱ���,
       '2' ��������,
     --  CASE WHEN T3.RAPFID LIKE '0104%' THEN 'Y'ELSE 'N' END �Ƿ����,
       'N' �Ƿ����,
       T2.MIBFID �����,
      -- T3.rasl  �˶�ˮ��,
      0  �˶�ˮ��,
    --   fn_get_pfname(T3.RAPFID) ��ˮ��������
  FROM  METERINFO T2\*,  RATIFY T3*\
 WHERE \*T2.MIID = T3.RAMIID
   AND*\ exists (select 1
          from pad_bfids tt
         where tt.c1 = I_BFRPER
           and tt.c2 = t2.Mibfid))

UNION ALL */

-- SELECT 'DELETE FROM history WHERE BFID in('||v_bfids||') '  FROM DUAL
 SELECT 'DELETE FROM history '  FROM DUAL
UNION ALL

  --��ʷ�������Ϣ 1����ʷ�����¼
  SELECT 'insert into history(ciid,miid,position,month,readdate,scode,ecode,usenum,pfname,sfje,qfje) values(' || 
    '''' || ��λ�� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ��λ||''','||
    '''' || �����·�||''','||
    '''' || ��������||''','||
    ''''||����||''','||
    ''''||ֹ��||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��������||''','||
    ''''||ˮ��||''','||
    ''''||Ƿ�ѽ��||''')'
  FROM (SELECT MAX(CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END) ��λ��,
       T3.RLMID ����,
       T3.RLMONTH �����·�,
       TO_CHAR(MAX(T3.RLRDATE),'yyyy-MM-dd') ��������,
       MAX(T2.Miname)   ����,
       MAX(T2.Miadr)  �û���ַ,
     decode( MAX(T2. MISIDE),'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
       --MAX(T2.MIPOSITION)��λ,
       MAX(T3.RLSCODE) ����,
       MAX(T3.RLECODE) ֹ��,
       SUM(T3.RLSL) ˮ��,
       sum(t3.rlje) ˮ��,
       SUM(CASE WHEN T3.RLPAIDFLAG ='N' THEN T3.RLJE ELSE 0 END) Ƿ�ѽ��,
       MAX(T2.MIPFID) ��ˮ��������
  FROM METERINFO T2, RECLIST T3,BOOKFRAME t4
 WHERE T2.MIID = T3.RLMID
   AND T3.RLREVERSEFLAG='N'  --δ����
   and t3.rlbadflag <> 'Y' --���Ǵ�����
    AND T2.mibfid =t4.bfid
    and t4.BFRPER=I_BFRPER
   --AND T3.RLPAIDFLAG='N'
   --AND (TO_CHAR(T3.RLDATE)>=add_months(SYSDATE,-12) )
   AND ( T3.RLDATE >=add_months(SYSDATE,-24) )
/*   AND exists (select 1
          from pad_bfids tt
         where tt.c1 = I_BFRPER
           and tt.c2 = t2.MIBFID)*/
   GROUP BY T3.RLMID,T3.RLMONTH)
   
   UNION ALL
   
   SELECT 'DELETE FROM payment_his '  FROM DUAL  --�ɷ���ʷ��Ϣ
   UNION ALL
  SELECT 'insert into payment_his(MIID,CIID,PDATETIME,PPOSITION,MICHARGETYPE,PPAYMENT,PPAYEE,PPAYWAY) values(' || 
    '''' || ˮ���� || ''',' || 
    '''' || �û���� || ''',' ||
    '''' || �ɷ�����||''','||
    '''' || �ɷѻ���||''','||
    '''' || �ɷѷ�ʽ||''','||
    ''''||������||''','||
    ''''||�շ�Ա||''','||
    ''''||���ʽ||''')'
    from 
      ( SELECT MAX(MI.MICID) ˮ����, --ˮ���� VARCHAR2(10)
       MAX(MI.MICID) �û����, --�û���� VARCHAR2(10) 
       to_char(MAX(PM.PDATETIME),'yyyy-mm-dd hh24:mm:ss') �ɷ�����, --�������� VARCHAR2(20)
       MAX(FGETSYSMANAFRAME(PM.PPOSITION) ) �ɷѻ���, --�ɷѻ��� VARCHAR2(60)
        DECODE(MAX(MI.MICHARGETYPE), 'X', '����', 'M', '����') �ɷѷ�ʽ, --�ɷѷ�ʽ VARCHAR2(20)
        SUM(PM.PPAYMENT) ������, --������ NUMBER(12,2)
       MAX( FGETOPERNAME(PM.PPAYEE) )�շ�Ա, --�շ�Ա  VARCHAR2(20) 
       MAX(decode(TRIM(PM.PPAYWAY), 'XJ','�ֽ�','DC','����','ZP','֧Ʊ','MZ','Ĩ��') ) ���ʽ     --���ʽVARCHAR2(20)
  FROM PAYMENT PM, METERINFO MI,BOOKFRAME BF
 WHERE PM.PMID = MI.MIID
   AND mi.mibfid =bf.bfid
   AND PM.PREVERSEFLAG = 'N'
   and bf.BFRPER=I_BFRPER
   aND ( PM.PDATETIME >=add_months(SYSDATE,-24) )
 GROUP BY PM.PBATCH
 having  SUM(PM.PPAYMENT) > 0
 ORDER BY MAX(MI.MISMFID),
          SUBSTR(MAX(MI.MIBFID), 1, 5),
          MAX(MI.MILB),
          MAX(MI.MIPRIID)  )
 
   union all
   select 'DELETE FROM datadesign' from dual
   
   UNION ALL
   
   
   --�ֵ���Ϣ
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || �ֵ����� || ''',' || 
    '''' || �ֵ�CODE || ''',' ||
    '''' || �ֵ�||''','||
    '''' || ��ע||''')'
  FROM (
       select 'ˮ��ھ�' �ֵ�����,mcid||'' �ֵ�CODE,mcname||'' �ֵ�, '' ��ע from METERCALIBER
       UNION ALL
       select 'ˮ��״��' �ֵ�����,sflid �ֵ�CODE,sflname �ֵ�,sflflag1 ��ע from sysfacelist2 t     /* where t.sflid  not in ('13','14','15')*/
      UNION ALL
      -- select 'ˮ��λ��' �ֵ�����,sclid �ֵ�CODE,sclvalue �ֵ�,decode(sclgroup,'01','����','02','����') ��ע from syscharlist  where scltype ='��λ'   
      select 'ˮ��λ��' �ֵ�����,sclid �ֵ�CODE,sclvalue �ֵ�,case  when sclgroup in  ('01','02','08','09','10','11','13') then '����' else  '����' end ��ע from syscharlist  where scltype ='��λ'   
         UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'���' �ֵ�CODE,t.oaid �ֵ�,''��ע from operaccnt t where  (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,t.oaname �ֵ�,''��ע from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,UPPER(t.oapwd) �ֵ�,''��ע from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select 'Ӫ��Ա�ֻ�����' �ֵ�����,oatel �ֵ�CODE,t.oatel �ֵ�,''��ע from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����, 'Ӫҵ��' �ֵ�CODE,   b.smfpid   �ֵ�,''��ע   --��¼����ԱӪҵ��
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
       UNION ALL
       select �ֵ�����, �ֵ�CODE,�ֵ�,��ע from datadesign where  �ֵ����� not in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��','��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����','�ֻ��汾��������','�ֻ��������ȫѡ����','�ֻ��������װ·��','��ѡ������','��������URL' )
              AND NVL(��ע,'NULL') <> 'XXXXXXXXXX' and �ֵ� not in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ')
       UNION ALL
              SELECT �ֵ�����, �ֵ�CODE,�ֵ�,��ע
          FROM DATADESIGN
         WHERE �ֵ����� = '�ֻ��汾��������'
           and �ֵ�code = (select max(�ֵ�code)
                           from DATADESIGN
                          WHERE �ֵ����� = '�ֻ��汾��������') 
      UNION ALL
       select '�û�(ˮ��)״̬' �ֵ�����,SMSID �ֵ�CODE,SMSNAME �ֵ�,''��ע FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 ���ˮ��״̬
       UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��','��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����'  )
       UNION ALL 
       select c.�ֵ�����,substrb(c.�ֵ�CODE,1,instr(c.�ֵ�CODE,':') - 1),c.�ֵ�,  substrb(c.�ֵ�CODE,instr(c.�ֵ�CODE,':') + 1 ,length(c.�ֵ�CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ( '��������URL')
      UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE, substrb(c.�ֵ�,1,instr(c.�ֵ�,':') - 1) ,  substrb(c.�ֵ�,instr(c.�ֵ�,':') + 1 ,length(c.�ֵ�))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ( '��ѡ������' ) 
       UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.�ֵ�����
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and  c.�ֵ�  in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ' ))
   /*    SELECT '��ѡ������' �ֵ�����,'TELECOM' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��ѡ������' �ֵ�����,'UNICOM' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��ѡ������' �ֵ�����,'WIFI' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080'��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158' �ֵ�CODE,'TELECOM' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158' �ֵ�CODE,'UNICOM' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158'  �ֵ�CODE,'WIFI' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '�Ƿ�ʵʱ�ϴ�' �ֵ�����,'0' �ֵ�CODE,'�Ƿ�ʵʱ�ϴ�' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '�ύ����ʱ����' �ֵ�����,'120' �ֵ�CODE,'ʱ����' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ˮ�Ѷ���' �ֵ�����,'01' �ֵ�CODE,'�𾴵��û���ã��û���ţ�yhh����������ˮ��sl�����ף��ۺ�ˮ��jeԪ��' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '�����Ƿ�����'�ֵ�����,TO_CHAR(SYSDATE,'yyyy-MM') �ֵ�CODE,'�����Ƿ�����' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '��ӡֽ����' �ֵ�����,'1' �ֵ�CODE,'' �ֵ�,''��ע FROM DUAL
       UNION ALL
       SELECT '��ӡ����' �ֵ�����,'����ˮ�ɷ�֪ͨ��' �ֵ�CODE,'' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ͻ��ͻ��' �ֵ�����,'0.3' �ֵ�CODE,'��������' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ͻ��ͻ��' �ֵ�����,'50' �ֵ�CODE,'����' �ֵ�,'' ��ע FROM DUAL*/
  union all
   select 'DELETE FROM telcheck' from dual
   union all
    SELECT 'insert into telcheck(tcmid,tcmonth, tctype,tcresult,tcnote,tcuser, tcdate,tcphoto_mk,tcphoto_path,tcchk_mk,tcchk_user,tcchk_date,tcinsdate) values('|| 
    ''''||�û����||''','|| 
    ''''||Ѳ���·�||''','||
    ''''||Ѳ�����||''','||
    ''''||Ѳ����||''','||
    ''''||Ѳ�챸ע||''','|| 
    ''''||Ѳ����||''','||
    ''''||Ѳ��ʱ��||''','||
    ''''||�Ƿ�����||''','|| 
    ''''||��Ƭ·�� ||''','|| 
    ''''||Ѳ�����ע��||''','||
    ''''||Ѳ�������||''','||
    ''''||Ѳ���������||''','||  
    ''''||��������ʱ��||''')'
    from (select tcmid �û����,
    tcmonth Ѳ���·�, 
    tctype Ѳ�����,
    tcresult Ѳ����,
    tcnote Ѳ�챸ע,
    tcuser Ѳ����,  
    to_char(tcdate,'yyyy-mm-dd hh24:mI:ss') Ѳ��ʱ��,
    tcphoto_mk �Ƿ�����,
    tcphoto_path ��Ƭ·��,
    tcchk_mk Ѳ�����ע��,
    tcchk_user Ѳ�������,
    to_char(tcchk_date,'yyyy-mm-dd hh24:mI:ss') Ѳ���������,
    to_char(tcinsdate,'yyyy-mm-dd hh24:mI:ss')  ��������ʱ��
    from meterinfo mit,telcheck,bookframe 
    where miid=tcmid and mit.mismfid =BFSMFID and bfid=mibfid and BFRPER =I_BFRPER  )
    
    UNION ALL
    SELECT 'DELETE FROM pic_his '  FROM DUAL  --������ʷ��¼
       UNION ALL
      SELECT 'insert into pic_his(ciid,pmtime,pmper) values(' || 
        '''' || �û���� || ''',' || 
        '''' || �ϴ�ʱ�� || ''',' ||
        ''''||�ϴ���Ա||''')'
        from 
          (SELECT m.ciid �û����, --ˮ���� VARCHAR2(10) 
           to_char(m.pmtime,'yyyy-mm-dd hh24:mi:ss') �ϴ�ʱ��, --�������� VARCHAR2(20)
           m.pmpname �ϴ���Ա
      FROM meterpicture m,meterinfo,bookframe,meterreadhis
     WHERE m.mpmiid=miid and mpmiid=mrmid and mibfid=bfid and mismfid =BFSMFID and mrifrec<>'N'and to_char(m.pmtime,'yyyy.mm')= mrmonth and  
      m.pmtime >= add_months(SYSDATE,-12) and bfrper = I_BFRPER /*and mrdatasource <> 'I'*/);

  
  --add 20150320 
  --hb
  --���µ�ǰ����ⷢ��ע�Ǽ�ʱ�䣬
  update meterread
     set mroutflag=DECODE(MRREADOK ,'Y','N','N', 'Y') ,  --�Ѿ�����ķ���ע��ΪN,������³������ϣ�ֻ����������ѣ�����f8003���MRREADOKΪY�����mroutflag����ΪN
         MROUTDATE =sysdate,MROUTID='9'
   where MRRPER =I_BFRPER  /*and
         mrdatasource <> 'I'*/;  --�Ѿ�����Ļ�MRREADOKΪY����ע��mroutflag����Ҫ��ΪY����f8003���MRREADOKΪY�����mroutflag����ΪN
  
 -- delete from METERINFO_SJCBUP    where miid  in (select mi.miid from meterinfo mi , bookframe bk where mi.mibfid =bk.bfid and bk.BFRPER=I_BFRPER) ;  --ÿ�θ�����ɾ������Ա��ˮ��ĸ�����Ϣ
  
  commit;
  
  
  END;
  
 /*
  * ���ܣ����ݳ�ʼ��
  * ������:������
  * ����ʱ�䣺2014-07-23
  * @�����Ϣ
  * @����Ա���
  * @�����α�
  */
  procedure DATA_INIT(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) IS
  BEGIN
    
   OPEN O_CURRSOR FOR select 'DELETE FROM datadesign' from dual
   
   UNION ALL
   
   --�ֵ���Ϣ
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || �ֵ����� || ''',' || 
    '''' || �ֵ�CODE || ''',' ||
    '''' || �ֵ�||''','||
    '''' || ��ע||''')'
  FROM (
      select 'ˮ��ھ�' �ֵ�����,mcid||'' �ֵ�CODE,mcname||'' �ֵ�, '' ��ע from METERCALIBER
       UNION ALL
       select 'ˮ��״��' �ֵ�����,sflid �ֵ�CODE,sflname �ֵ�,sflflag1 ��ע from sysfacelist2 t  /*  where t.sflid  not in ('13','14','15')*/
        UNION ALL
       select 'ˮ��λ��' �ֵ�����,sclid �ֵ�CODE,sclvalue �ֵ�,decode(sclgroup,'01','����','02','����') ��ע from syscharlist  where scltype ='��λ'   
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'���' �ֵ�CODE,t.oaid �ֵ�,''��ע from operaccnt t where t.OAID=I_BFRPER  or  t.OAGH=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,t.oaname �ֵ�,''��ע from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,UPPER(t.oapwd) �ֵ�,''��ע from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա�ֻ�����' �ֵ�����,oatel �ֵ�CODE,t.oatel �ֵ�,''��ע from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����, 'Ӫҵ��' �ֵ�CODE,   b.smfpid   �ֵ�,''��ע   --��¼����ԱӪҵ��
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
         and (a.OAID =I_BFRPER  or  a.OAGH=I_BFRPER)
       UNION ALL
       select �ֵ�����, �ֵ�CODE,�ֵ�,��ע from datadesign where  �ֵ����� not in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��','��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����','�ֻ��汾��������','�ֻ��������ȫѡ����','�ֻ��������װ·��','��ѡ������','��������URL')
        AND NVL(��ע,'NULL') <> 'XXXXXXXXXX' and �ֵ� not in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ')
       UNION ALL
              SELECT �ֵ�����, �ֵ�CODE,�ֵ�,��ע
          FROM DATADESIGN
         WHERE �ֵ����� = '�ֻ��汾��������'
           and �ֵ�code = (select max(�ֵ�code)
                           from DATADESIGN
                          WHERE �ֵ����� = '�ֻ��汾��������') 
                          
       UNION ALL
       select '�û�(ˮ��)״̬' �ֵ�����,SMSID �ֵ�CODE,SMSNAME �ֵ�,''��ע FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 ���ˮ��״̬
       UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��' ,'��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����')
    UNION ALL 
       select c.�ֵ�����,substrb(c.�ֵ�CODE,1,instr(c.�ֵ�CODE,':') - 1),c.�ֵ�,  substrb(c.�ֵ�CODE,instr(c.�ֵ�CODE,':') + 1 ,length(c.�ֵ�CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ( '��������URL')
      UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE, substrb(c.�ֵ�,1,instr(c.�ֵ�,':') - 1) ,  substrb(c.�ֵ�,instr(c.�ֵ�,':') + 1 ,length(c.�ֵ�))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.�ֵ����� in ( '��ѡ������' ) 
      UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.�ֵ�����
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and  c.�ֵ�  in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ' )
      /* SELECT '��ѡ������' �ֵ�����,'TELECOM' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��ѡ������' �ֵ�����,'UNICOM' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��ѡ������' �ֵ�����,'WIFI' �ֵ�CODE,'10.10.10.158' �ֵ�,'8080'��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158' �ֵ�CODE,'TELECOM' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158' �ֵ�CODE,'UNICOM' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '��������URL' �ֵ�����,'10.10.10.158'  �ֵ�CODE,'WIFI' �ֵ�,'8080' ��ע FROM DUAL
       UNION ALL
       SELECT '�Ƿ�ʵʱ�ϴ�' �ֵ�����,'0' �ֵ�CODE,'�Ƿ�ʵʱ�ϴ�' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '�ύ����ʱ����' �ֵ�����,'120' �ֵ�CODE,'ʱ����' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ˮ�Ѷ���' �ֵ�����,'01' �ֵ�CODE,'�𾴵��û���ã��û���ţ�yhh����������ˮ��sl�����ף��ۺ�ˮ��jeԪ��' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '�����Ƿ�����'�ֵ�����,TO_CHAR(SYSDATE,'yyyy-MM') �ֵ�CODE,'�����Ƿ�����' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '��ӡֽ����' �ֵ�����,'1' �ֵ�CODE,'' �ֵ�,''��ע FROM DUAL
       UNION ALL
       SELECT '��ӡ����' �ֵ�����,'����ˮ�ɷ�֪ͨ��' �ֵ�CODE,'' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ͻ��ͻ��' �ֵ�����,'0.3' �ֵ�CODE,'��������' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ͻ��ͻ��' �ֵ�����,'50' �ֵ�CODE,'����' �ֵ�,'' ��ע FROM DUAL
        UNION ALL
       SELECT '�ֻ������汾' �ֵ�����,'0000000001' �ֵ�CODE,'�˶��ֻ������Ƿ���Ӫ��ϵͳ�����汾�Ƿ�һ��' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT 'ͼƬ����' �ֵ�����,'xxx' �ֵ�CODE,'' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '���񱨾�ֵ' �ֵ�����,'10-30' �ֵ�CODE,'������С�����ˮ������ֵ' �ֵ�,'' ��ע FROM DUAL
        UNION ALL
       SELECT '�Ƿ�绰��' �ֵ�����,'0' �ֵ�CODE,'�Ƿ�ѡ��绰��(1-ѡ��绰�� 0-��ѡ��)' �ֵ�,'' ��ע FROM DUAL
        UNION ALL
       SELECT '�Ƿ�����' �ֵ�����,'1' �ֵ�CODE,'�Ƿ������������Ҳ���Ա���ɹ�(1-�������� 0-��������)' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '��ӡԤ��֪֪ͨ��' �ֵ�����,'1' �ֵ�CODE,'�Ƿ������ӡԤ��֪֪ͨ��(1-��ӡ 0-����ӡ)' �ֵ�,'' ��ע FROM DUAL
       UNION ALL
       SELECT '�������' �ֵ�����,'1' �ֵ�CODE,'�Ƿ������г������(1-���볭����� 0-�����볭�����)' �ֵ�,'' ��ע FROM DUAL*/
  );
  END;
  
  
  procedure DOWN_DATA_READCHK(I_BFIDS   IN VARCHAR2,
                    I_BFRPER  IN VARCHAR2,
                    O_CURRSOR OUT SYS_REFCURSOR) IS
    li_old_pos1     NUMBER;
    li_pos1         NUMBER;
    i               NUMBER;
    li_exit         boolean;
    v_temp_str      varchar2(200);
    v_bfids varchar2(4000);
    --����Ա���
    v_count number;
  BEGIN
     
/*    --I_BFIDS������ʱ��
      li_old_pos1 := 0;
      li_pos1     := 0;
      I           := 1;
      li_exit     := true;
      if instr(I_BFIDS, ',') = 0 then
         li_exit := false;
      end if;

      WHILE li_exit LOOP
        li_pos1 := instr(I_BFIDS, ',', 1, i);
        if li_pos1 = 0 then
          exit;
        end if;
        v_temp_str := substr(I_BFIDS,
                             li_old_pos1 + 1,
                             li_pos1 - li_old_pos1 - 1);

        if v_temp_str is not null then
           insert into pad_bfids(c1,c2)values(I_BFRPER,v_temp_str);
           if v_bfids is not null then
              v_bfids := v_bfids||',';
           end if;
           v_bfids := v_bfids||''''||v_temp_str||'''';
        end if;
        li_old_pos1 := li_pos1;
        i           := i + 1;
      END LOOP;*/ 
 
          
  insert into pad_bfids(c1,c2)values(I_BFRPER,v_temp_str);  --����Ա��д����ʱ��
       
  
    OPEN O_CURRSOR FOR 
   select  ' update custinfo   set lastjfdate='||  
                 '''' || �ϴγ������� || ''',' ||
                'apply_flag='|| 
                  '''' || ���������־ || ''',' ||
               'issf='||      
               '''' || ���ע�� || ''',' ||   
             'cusenum='||  
               '''' || ˮ�� || ''',' ||
              'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||
              'psfjg='||  
               '''' || ��ˮ�ѵ��� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
              'psfje='||  
               '''' || ��ˮ�� || ''',' ||
               'szyfje='||  
               '''' || �������� || ''',' ||
               'total_money='||  
               '''' || �ܷ��� || ''',' ||   
               'saving='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||   
               'chargetotal='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||  
               
                'processflag='||    
               '''' || ��˱�־ || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || ���� || ''''  
   from ( select  to_char(mr.MRRDATE,'yyyy-mm-dd') �ϴγ�������, 
                 '�����'  ��˱�־,
                     max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N' and nvl(mr.mrdatasource,'X') <> '9'  THEN  mi.MISAVING -  nvl(VIEW1.RLJE,0)     -- ���ֻ����������
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') = '9' THEN  mr.MRPLANJE02    -- �ֻ��������
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                    --    when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN 0   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                     when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN  nvl(mr.MRPLANJE03,0)--20150414��̶��������ձ��ӡ��������� 
                       when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                        when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
               
                    decode(nvl(trim(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����')���������־,
                    NVL(mr.MRPLANSL,0) ˮ��,
                   -----zhw20160415�޸����³����µ���
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  ˮ�ѵ���,
                 fun_getjtdqdj( max(MIPFID), max(MIPRIID) , max(miid) ,'1') ˮ�ѵ���,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     ��ˮ�ѵ���,
               fgetwsf(max(mipfid)) ��ˮ�ѵ���, 
                -----------------------------------------------------------end
                  mr.MRYEARJE01 ˮ�� ,
                   mr.MRYEARJE02 ��ˮ��,
                   mr.MRYEARJE03 ��������,
                   mr.MRPLANJE01 �ܷ���,
                  'Y'  ���ע��,
                  mr.MRMID ���� 
                  FROM METERREAD mr,meterinfo mi,   ( SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1, (                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2
                    
                  WHERE  mr.MRMID =mi.miid and 
                          mi.MIID = VIEW1.RLMID(+) and 
                           mr.mrid =view2.rlmrid(+) and
                         mr.MRRPER=  I_BFRPER and 
                         mr.MRDATASOURCE ='9' and 
                        -- mr.mrreadok = 'Y' and
                          mi.mibfid is not null and
                         mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --ץȡ��ʱ��
                         group by  to_char(mr.MRRDATE,'yyyy-mm-dd')  , 
                 '�����'   , 
                    decode(nvl(trim(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ,
                    NVL(mr.MRPLANSL,0)  ,
                  DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)   ,
                DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)      ,
                  mr.MRYEARJE01   ,
                   mr.MRYEARJE02  ,
                   mr.MRYEARJE03  ,
                   mr.MRPLANJE01  ,
                  mr.MRMID   
                  
                        )  --���  
       union all
     select  ' update  meterinfo   set  ecode='||   
               '''' || ����ָ�� || ''',' ||
              'musenum='||  
               '''' || ˮ�� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
               'psfje='||  
               '''' || ��ˮ�� || ''',' ||
              'szyfje='||  
               '''' || �������� || ''',' ||
               'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||              
               'psfjg='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ�ѵ��� || ''',' ||    
               'total_money='||  
               '''' || �ܽ�� || '''' ||  
                 ' where miid=  '||
                  '''' || ���� || ''''  
  
                  
      from ( select  mr.MRECODE ����ָ��,  
                  mr.MRPLANSL  ˮ��, 
                  mr.MRYEARJE01 ˮ�� ,
                   mr.MRYEARJE02 ��ˮ��,
                   mr.MRYEARJE03 ��������,
                /*  DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  ˮ�ѵ���,
                DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     ��ˮ�ѵ���,*/
                
                -----zhw20160415�޸����³����µ���
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  ˮ�ѵ���,
                 fun_getjtdqdj(  MIPFID ,  MIPRIID  ,  miid ,'1') ˮ�ѵ���,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     ��ˮ�ѵ���,
               fgetwsf( mipfid ) ��ˮ�ѵ���, 
                -----------------------------------------------------------end
                   mr.MRPLANJE01 �ܽ��,
                  mr.MRMID ���� 
                  FROM METERREAD mr,meterinfo mi
                  WHERE mr.MRMID =mi.miid and  mr.MRRPER=  I_BFRPER and ( mr.MRDATASOURCE ='9' or mr.mrdatasource = '1' /* byj 2016.06 ����mrdatasource = '1' */)  --and mr.mrreadok = 'Y' 
                       and mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --ץȡ��ʱ��
                        )  --��� �������������δͨ�����ų���Ա���£����ݸ�������ˮ����Щ��û�У�Ȼ������ѡͨ������Щ���Ͼ�û��������    
 
         UNION ALL
         
         
     select  ' update custinfo   set apply_flag='||   
                  '''' || ���������־ || ''',' ||
                 'issf='||      
               '''' || ���ע�� || ''',' ||   
                'processflag='||    
               '''' || ��˱�־ || '''' || 
               ' where mrid=  '||
                  '''' || ���� || ''''  
             from ( select   '�����'  ��˱�־,
                             'Y'  ���ע��,
                              decode(nvl(trim(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����')���������־,
                            mr.MRMID ���� 
                            FROM METERREAD mr,meterinfo mi
                            WHERE mr.MRMID =mi.miid and  mr.MRRPER=  I_BFRPER and mr.MRDATASOURCE ='9' and mr.mrreadok = 'X' 
                                 and mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --ץȡ��ʱ��
                                  )  --�����Ҳ��Ҫ����,��Ϊ�����п����л����ע�ǡ���ͨ����δͨ����δ��ˣ�������ȥ 
          UNION ALL                            
    --����Ϊ��˲�ͨ���ĳ�������
  select  ' update custinfo   set  cbzk='||   
              '''' || ���״�� || ''',' ||
              'codesource='||  
               '''' || ʾ����Դ || ''',' ||
             -- 'cusenum='||  
          --     '''' || ˮ�� || ''',' ||
              'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||
              'psfjg='||  
               '''' || ��ˮ�ѵ��� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
              'psfje='||  
               '''' || ��ˮ�� || ''',' ||
               'szyfje='||  
               '''' || �������� || ''',' ||
               'total_money='||  
               '''' || �ܷ��� || ''',' ||              
               'saving='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||   
               'chargetotal='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||  
               'sendflag='||  
               '''' || ���ͱ�־ || ''',' ||
               'memo='||  
               '''' || �û���ע || ''',' ||
                'isprint='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ӡ || ''',' || 
               'lastjfdate='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �ϴγ������� || ''',' ||  
               'ciname='||    
               '''' || ���� || ''',' ||  
               'ciaddr='||   
               '''' || �û���ַ || ''',' ||  
               'linkman='||    
               '''' || ��ϵ�� || ''',' ||  
               'hometel='||      
               '''' || ��ϵ�绰 || ''',' ||  
               'mobiletel='||      
               '''' || �ƶ��绰 || ''',' ||  
               'chargetype='||      
               '''' || �û����� || ''',' ||  
               'pfid='||      
               '''' || ��ˮ���� || ''',' ||  
               'pfname='||      
               '''' || ��ˮ�������� || ''',' ||  
               'rorder='||      
               '''' || ������� || ''',' ||  
               'mans='||      
               '''' || �˿��� || ''',' ||   
               'MICOMMUNITY='||      
               '''' || С���� || ''',' ||   
                'MICOMMUNITY_NAME='||      
               '''' || С������ || ''',' ||   
                'MISEQNO='||      
               '''' || �ʿ��� || ''',' ||   
                  'MILH='||      
               '''' || ¥�� || ''',' ||   
                'MIDYH='||      
               '''' || ��Ԫ�� || ''',' ||    
                'issf='||      
               '''' || ���ע�� || ''',' ||   
                'readdate='||      
               '''' || ���γ������� || ''',' ||    
                'BARCODE='||      
               '''' || ������ || ''',' ||     
                'apply_ciname='||      
               '''' || �»��� || ''',' ||   
                               'apply_pfid='||      
               '''' || ����ˮ���� || ''',' ||   
                               'apply_pfname='||      
               '''' || ����ˮ�������� || ''',' ||   
                               'apply_flag='||      
               '''' || ���������־ || ''',' ||    
              'processflag='||  
               '''' || ��˱�־ || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || ���� || ''''  
        from (  select 'δ��' ���״��,
                        '����' ʾ����Դ,
                      --   null ˮ��,
                     --  mr.MRSL ˮ��,
                        null ˮ�ѵ���,
                        null ��ˮ�ѵ���,
                        null ˮ��,
                      null ��ˮ��,
                     null ��������,
                     null �ܷ���,  --Ӧ�պϼ�
             max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') <> '9'  THEN   mi.MISAVING -  nvl(VIEW1.RLJE,0)  -- �����ֻ�����
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X')= '9'  THEN   mr.MRPLANJE02  --�ֻ�����
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN mr.MRPLANJE03  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
                          
                    null ���ͱ�־,
                       mi.MIMEMO  �û���ע,

                        null ��ӡ,
                        TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    �ϴγ�������,
                      to_char( mr.MRRDATE ,'yyyy-mm-dd hh24:mi:ss')   ���γ�������, 
                      --  'δ����' ��˱�־,
                  MAX(CASE when  mr.MRREADOK ='Y'  THEN '�����'
                      when  mr.MRREADOK ='N'  THEN 'δ����'
                      when  mr.MRREADOK ='X'  THEN '�����'
                      when  mr.MRREADOK ='U'  THEN 'δͨ��'
                      else 'δ����' END) ��˱�־,
                      mi.MINAME  ����, 
                       mi.MIADR  �û���ַ,

                    ci.CICONNECTPER  ��ϵ��,
                        ci.citel1  ��ϵ�绰,
                        ci.CIMTEL �ƶ��绰, 
                        mi.mICHARGETYPE  �û�����, --20150308
                        mi.MIPFID  ��ˮ����,
                        FGETPRICENAME( mi.MIPFID ) ��ˮ��������, 
                        mr.MRRORDER  �������, --20150308
                        mi.MIUSENUM  �˿���, 
                        mi.MICOMMUNITY  С����,
                        mi.MISEQNO �ʿ���,
                        mi.MILH ¥��,
                        mi.MIDYH ��Ԫ��,
                        t4.diname С������ ,
                        mr.MRMID  ����,
                        md.barcode ������,
               decode(nvl(max(MIYL5),'N'),'N',   MAX(mi.MINAME)

 , MAX(MIJD)  ) �»���,
              decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MIPFID), MAX(miyl6)  ) ����ˮ����,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(mi.MIPFID)),FGETPRICENAME(MAX(miyl6)) )����ˮ��������,
              decode(nvl(max(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ���������־,
                      MAX(CASE when  mr.MRREADOK ='Y' or mr.MRREADOK ='X'  THEN 'Y'  --����ˡ��ѳ���
                              when  mr.MRREADOK ='N'  or mr.MRREADOK ='U'   THEN 'N'  --δ���� ��δͨ��
                              else 'N' END) ���ע�� 
                FROM METERREAD mr,
                     meterinfo mi,
                     CUSTINFO ci,
                     meterdoc md,
                     (SELECT SUM(T5.RLJE) RLJE, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID) VIEW1,DISTRICTINFO t4,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --ץȡ�Ѿ���ѵ�
               WHERE mr.MRMID = mi.miid
                 and mr.MRMID= ci.ciid
                 and mr.MRMID = md.mdmid
                 and MI.miid = VIEW1.RLMID(+)
                 and mr.mrid =view2.rlmrid(+)
                 AND mr.MRRPER =I_BFRPER
                 and mi.MICOMMUNITY=t4.diid(+)
                 and NVL(mr.MROUTID,'X') ='9'
                 and   mi.mibfid is not null 
                 and mi.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  ) 
                 and (mr.mrreadok = 'N'  or mr.mrreadok = 'U'   ) --δ����δͨ��
                  GROUP BY  mi.MIMEMO ,  mr.MRRDATE ,  mr.MRMID ,  mi.MINAME   , 
                mi.MIADR   ,
                ci.CICONNECTPER   ,
                ci.citel1   ,
                ci.CIMTEL   , 
               mi.mICHARGETYPE   , --20150308
               mi.MIPFID   ,
                FGETPRICENAME( mi.MIPFID )  , 
                mr.MRRORDER   , --20150308
                mi.MIUSENUM,         
                mi.MICOMMUNITY  ,
               mi.MISEQNO  ,
               mi.MILH  ,
               mi.MIDYH  ,
               t4.diname  ,mr.MRMID , md.barcode   )      -- N��˲��ܹ��ĳ�������
 
           union all 
       --����Ϊ�����ڳ������и����û���Ϣ����
  select  ' update custinfo   set  cbzk='||   
              '''' || ���״�� || ''',' ||
              'codesource='||  
               '''' || ʾ����Դ || ''',' ||
              'cusenum='||  
               '''' || ˮ�� || ''',' ||
              'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||
              'psfjg='||  
               '''' || ��ˮ�ѵ��� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
              'psfje='||  
               '''' || ��ˮ�� || ''',' ||
               'szyfje='||  
               '''' || �������� || ''',' ||
               'total_money='||  
               '''' || �ܷ��� || ''',' ||              
               'saving='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||   
               'chargetotal='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ����Ԥ���� || ''',' ||  
               'sendflag='||  
               '''' || ���ͱ�־ || ''',' ||
               'memo='||  
               '''' || �û���ע || ''',' ||
                'isprint='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ӡ || ''',' || 
               'lastjfdate='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �ϴγ������� || ''',' ||  
               'ciname='||    
               '''' || ���� || ''',' ||  
               'ciaddr='||   
               '''' || �û���ַ || ''',' ||  
               'linkman='||    
               '''' || ��ϵ�� || ''',' ||  
               'hometel='||      
               '''' || ��ϵ�绰 || ''',' ||  
               'mobiletel='||      
               '''' || �ƶ��绰 || ''',' ||  
               'chargetype='||      
               '''' || �û����� || ''',' ||  
               'pfid='||      
               '''' || ��ˮ���� || ''',' ||  
               'pfname='||      
               '''' || ��ˮ�������� || ''',' ||  
               'rorder='||      
               '''' || ������� || ''',' ||  
               'mans='||      
               '''' || �˿��� || ''',' ||   
               'MICOMMUNITY='||      
               '''' || С���� || ''',' ||   
                'MICOMMUNITY_NAME='||      
               '''' || С������ || ''',' ||   
                'MISEQNO='||      
               '''' || �ʿ��� || ''',' ||   
                  'MILH='||      
               '''' || ¥�� || ''',' ||   
                'MIDYH='||      
               '''' || ��Ԫ�� || ''',' ||    
                'issf='||      
               '''' || ���ע�� || ''',' ||   
                'readdate='||      
               '''' || ���γ������� || ''',' ||    
                'BARCODE='||      
               '''' || ������ || ''',' ||     
                'apply_ciname='||      
               '''' || �»��� || ''',' ||   
                               'apply_pfid='||      
               '''' || ����ˮ���� || ''',' ||   
                               'apply_pfname='||      
               '''' || ����ˮ�������� || ''',' ||   
                               'apply_flag='||      
               '''' || ���������־ || ''',' ||    
              'processflag='||  
               '''' || ��˱�־ || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || ���� || ''''  
        from (   select 'δ��' ���״��,
                        '����' ʾ����Դ,
                        null ˮ��,
                        null ˮ�ѵ���,
                        null ��ˮ�ѵ���,
                        null ˮ��,
                      null ��ˮ��,
                     null ��������,
                     null �ܷ���,  --Ӧ�պϼ�
                   /*   MAX(mr.MRYEARJE01) ˮ��,
                      MAX(mr.MRYEARJE02)  ��ˮ��,
                      MAX(mr.MRYEARJE03) ��������,
                      MAX(mr.MRPLANJE01) �ܷ���,  --Ӧ�պϼ�*/
                       --   sum(mi.MISAVING) - sum(nvl(VIEW1.RLJE,0)) ����Ԥ����,
               --    decode( MAX(mr.MRIFREC),'Y',MAX(mr.MRPLANJE02),  sum(mi.MISAVING) - sum(nvl(VIEW1.RLJE,0))  ) ����Ԥ����,--���ѼƷ���ץȡ֮ǰ�����������Ԥ�����������Ԥ�������µ�
/*            max (case when mi.mistatus in ('29','30') and mr.MRREADOK ='Y' THEN  mi.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN mi.mistatus NOT in ('29','30') and mr.MRREADOK ='Y'  and mr.mrface='01' THEN  mr.MRPLANJE02 
                  else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) ����Ԥ����, 
            decode( MAX(mr.MRREADOK),'N', 0,decode( max(mr.mrface),'01', MAX(mr.MRPLANJE03),0) ) ����Ԥ����, */
            
             max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') <> '9'  THEN   mi.MISAVING -  nvl(VIEW1.RLJE,0)  -- �����ֻ�����
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X')= '9'  THEN   mr.MRPLANJE02  --�ֻ�����
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN mr.MRPLANJE03  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
                          
                    null ���ͱ�־,
                     mi.MIMEMO  �û���ע,
                        null ��ӡ,
                        TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    �ϴγ�������,
                      to_char( mr.MRRDATE ,'yyyy-mm-dd hh24:mi:ss')   ���γ�������,
                        
                      --  'δ����' ��˱�־,
                  MAX(CASE when  mr.MRREADOK ='Y'  THEN '�����'
                      when  mr.MRREADOK ='N'  THEN 'δ����'
                      when  mr.MRREADOK ='X'  THEN '�����'
                      when  mr.MRREADOK ='U'  THEN 'δͨ��'
                      else 'δ����' END) ��˱�־,
  
                       mi.MINAME  ����, 
                      mi.MIADR  �û���ַ,
                       ci.CICONNECTPER  ��ϵ��,
                      ci.citel1  ��ϵ�绰,
                       ci.CIMTEL  �ƶ��绰, 
                        mi.mICHARGETYPE  �û�����, --20150308
                        mi.MIPFID  ��ˮ����,
                        FGETPRICENAME( mi.MIPFID ) ��ˮ��������, 
                        mi.mirorder �������, --û��������Ļ����������ѡ��METERINFO BY RALPH 20150430
                       -- mr.MRRORDER  �������, --20150308
                        mi.MIUSENUM  �˿���, 
                        mi.MICOMMUNITY С����,
                        mi.MISEQNO �ʿ���,
                    mi.MILH ¥��,
                      mi.MIDYH ��Ԫ��,
                       t4.diname С������ ,
                        MI.MIID  ����,
                        md.barcode ������,
               decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MINAME), MAX(MIJD)  ) �»���,
              decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MIPFID), MAX(miyl6)  ) ����ˮ����,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(mi.MIPFID)),FGETPRICENAME(MAX(miyl6)) )����ˮ��������,
              decode(nvl(max(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ���������־,
                      MAX(CASE when  mr.MRREADOK ='Y' or mr.MRREADOK ='X'  THEN 'Y'  --����ˡ��ѳ���
                              when  mr.MRREADOK ='N'  or mr.MRREADOK ='U'   THEN 'N'  --δ���� ��δͨ��
                              else 'N' END) ���ע�� 
                FROM METERREAD mr,
                     meterinfo mi,
                     CUSTINFO ci,
                     meterdoc md,
                     bookframe bf,
                     (SELECT SUM(T5.RLJE) RLJE, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID) VIEW1,DISTRICTINFO t4,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --ץȡ�Ѿ���ѵ�
               WHERE  mi.miid= mr.MRMID(+) 
                 and  mi.miid = ci.ciid
                 and  mi.miid = md.mdmid
                 and mi.mibfid =bf.bfid
                 and MI.miid = VIEW1.RLMID(+)
                 and mr.mrid =view2.rlmrid(+)
                 AND bf.BFRPER =I_BFRPER
                 and mi.MICOMMUNITY=t4.diid(+)
                  and   mi.mibfid is not null 
                  and mr.mrid is null   --δ��������ݸ��� 
                 and mi.miid   in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  ) 
                  GROUP BY  mi.MIMEMO ,  mr.MRRDATE ,  mr.MRMID ,  mi.MINAME   , 
                mi.MIADR   ,
                ci.CICONNECTPER   ,
                ci.citel1   ,
                ci.CIMTEL   , 
               mi.mICHARGETYPE   , --20150308
               mi.MIPFID   ,
                FGETPRICENAME( mi.MIPFID )  , 
                mi.mirorder   , --20150308
                mi.MIUSENUM,         
                mi.MICOMMUNITY  ,
               mi.MISEQNO  ,
               mi.MILH  ,
               mi.MIDYH  ,
               t4.diname  ,MI.MIID , md.barcode   )      
 
           union all 
     --�������³���� --δ����δͨ�� ������                
     select  ' update  meterinfo   set  sbzk='||   
              '''' || ˮ��״�� || ''',' ||
               'MRFACE_NAME='||  
               '''' || ����������� || ''',' || 
              'prdate='||  
               '''' || �ϴγ������� || ''',' ||
              'lastreaddate='||  
               '''' || �ϴγ�������1 || ''',' ||
              'scode='||  
               '''' || �ϴ�ָ�� || ''',' ||
              'ecode='||  
               '''' || ����ָ�� || ''',' ||
              'musenum='||  
               '''' || ˮ�� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
               'psfje='||  
               '''' || ��ˮ�� || ''',' ||
              'szyfje='||  
               '''' || �������� || ''',' ||
               'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||              
               'psfjg='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ�ѵ��� || ''',' ||    
               'mrthreesl='||  
               '''' || ���¾��� || ''',' ||
               'total_money='||  
               '''' || �ܽ�� || ''',' ||
                'lastcode='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �ϴγ���ˮ�� || ''',' || 
                               'miPersons='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �˿��� || ''',' ||  
                               'pfid='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ���� || ''',' || 
                               'pfname='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ�������� || ''',' || 
                               'MISMFID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || Ӫҵ������ || ''',' || 
                               'MISMFID_NAME='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || Ӫҵ��˵�� || ''',' || 
                               'MICHARGETYPE='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �շѷ�ʽ���� || ''',' || 
                               'MICHARGETYPE_NAME='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �շѷ�ʽ˵�� || ''',' || 
                               'MIPRIID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ���ձ������ || ''',' || 
                               'MIPRIFLAG='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ���ձ��־ || ''',' || 
                               'DQSFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �����ܷ�� || ''',' || 
                               'DQGFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �����ַ�� || ''',' || 
                               'JCGFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                '''' || ����շ�� || ''',' || 
                               'BARCODE='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                '''' || ������ || ''',' || 
                                'qfh='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                '''' || Ǧ��� || ''',' ||  
                             'MISTATUS='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ˮ��״̬ || ''',' || 
                               'IFDZSB='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �����־ || ''',' || 
                               'MICLASS='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                  '''' || �ֱܷ��־ || ''',' || 
                               'MIPID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �ܱ��� || ''',' ||  
                              'position='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ��λ || ''',' ||  
                             'brand='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ���� || ''',' ||  
                            'caliber='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �ھ� || ''',' ||  
                           'nameplate='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ����� || ''',' ||  
                           'metertype='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ˮ������ || ''',' ||  
                        'cbmemo='||  
                  '''' || ����ע || '''' ||
               -- where
               ' where miid=  '||
                  '''' || ���� || ''''  
        from (  select '01' ˮ��״��,
                     '����' �����������,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    �ϴγ�������,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')     �ϴγ�������1,
                    --byj edited 2016.6.16     
                    --mr.MRSCODE   �ϴ�ָ��,
                    mi.mircode �ϴ�ָ��,
                    --  null ����ָ��,
                      mr.MRECODE ����ָ��,
                      
                   --  null ˮ��,
                      mr.MRSL ˮ��,
                     null ˮ��,
                     null ��ˮ��,
                 --    mr.MRYEARJE01 ˮ��,
               --      mr.MRYEARJE02 ��ˮ��,
                     null ˮ�ѵ���,
                     null ��ˮ�ѵ���,
                     mr.MRTHREESL ���¾���,
                     null ��������,
                     null �ܽ��,
                --     mr.MRYEARJE03 ��������,
                --     mr.MRPLANJE01 �ܽ��,
 
                      mr.MRLASTSL  �ϴγ���ˮ��,
                    DECODE(mr.MRREADOK,'U',mr.MRCHKRESULT, mr.MRMEMO) ����ע,   
                        mi.MIUSENUM �˿���,
                         mi.mipfid ��ˮ����, 
                         FGETPRICENAME(mi.mipfid) ��ˮ��������, 
                       --  T4.BFRCYC ��������,
                         mi.MISMFID Ӫҵ������,
                         fgetsmfname(mi.MISMFID ) Ӫҵ��˵��,
                          mi.MICHARGETYPE �շѷ�ʽ����,
                          decode( mi.MICHARGETYPE,'X','����','M','����') �շѷ�ʽ˵��, 
                           mi.MIPRIID ���ձ������,
                           mi.MIPRIFLAG ���ձ��־,
                           md.QFH Ǧ���,
                            md.DQSFH �����ܷ��,
                          md.DQGFH �����ַ��,
                          md.JCGFH ����շ��,
                          md.BARCODE ������,
                           mi.MISTATUS ˮ��״̬,
                           md.IFDZSB �����־,
                           mi.MICLASS �ֱܷ��־,
                          nvl(mi.MIPID,mi.miid)  �ܱ���,
                        --   mi.MIPOSITION ��λ,
                          decode( mi.MISIDE ,'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
                           md.MDBRAND ����,
                          md.MDCALIBER �ھ�, 
                        --   md.MDNO �����,
                         substrb(md.MDNO,1,13) �����,
                           mi.MILB  ˮ������, 
                           mr.MRMID ����
                FROM METERREAD mr,meterinfo mi ,meterdoc md 
               WHERE   mr.MRMID=mi.miid 
                 and mr.mrmid =md.mdmid
                 and mr.MRRPER =I_BFRPER
                  and   mi.mibfid is not null 
                 and NVL(mr.MROUTID,'X') ='9'
                 and mi.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  ) 
                 and  (mr.mrreadok = 'N'  or mr.mrreadok = 'U'   )    )      --δ����δͨ�� 
                 
           union all 
           
     --��������û�д��ڳ�����е�ˮ����Ϣ               
     select  ' update  meterinfo   set  sbzk='||   
              '''' || ˮ��״�� || ''',' ||
               'MRFACE_NAME='||  
               '''' || ����������� || ''',' || 
              'prdate='||  
               '''' || �ϴγ������� || ''',' ||
              'lastreaddate='||  
               '''' || �ϴγ�������1 || ''',' ||
              'scode='||  
               '''' || �ϴ�ָ�� || ''',' ||
              'ecode='||  
               '''' || ����ָ�� || ''',' ||
              'musenum='||  
               '''' || ˮ�� || ''',' ||
              'sfje='||  
               '''' || ˮ�� || ''',' ||
               'psfje='||  
               '''' || ��ˮ�� || ''',' ||
              'szyfje='||  
               '''' || �������� || ''',' ||
               'sfjg='||  
               '''' || ˮ�ѵ��� || ''',' ||              
               'psfjg='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ�ѵ��� || ''',' ||    
               'mrthreesl='||  
               '''' || ���¾��� || ''',' ||
               'total_money='||  
               '''' || �ܽ�� || ''',' ||
                'lastcode='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �ϴγ���ˮ�� || ''',' || 
                               'miPersons='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �˿��� || ''',' ||  
                               'pfid='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ���� || ''',' || 
                               'pfname='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ��ˮ�������� || ''',' || 
                               'MISMFID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || Ӫҵ������ || ''',' || 
                               'MISMFID_NAME='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || Ӫҵ��˵�� || ''',' || 
                               'MICHARGETYPE='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �շѷ�ʽ���� || ''',' || 
                               'MICHARGETYPE_NAME='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �շѷ�ʽ˵�� || ''',' || 
                               'MIPRIID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ���ձ������ || ''',' || 
                               'MIPRIFLAG='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || ���ձ��־ || ''',' || 
                               'DQSFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �����ܷ�� || ''',' || 
                               'DQGFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
               '''' || �����ַ�� || ''',' || 
                               'JCGFH='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                '''' || ����շ�� || ''',' || 
                               'BARCODE='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                '''' || ������ || ''',' || 
                        'qfh='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || Ǧ��� || ''',' ||  
                               'MISTATUS='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ˮ��״̬ || ''',' || 
                               'IFDZSB='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �����־ || ''',' || 
                               'MICLASS='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                  '''' || �ֱܷ��־ || ''',' || 
                               'MIPID='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �ܱ��� || ''',' ||  
                              'position='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ��λ || ''',' ||  
                             'brand='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ���� || ''',' ||  
                            'caliber='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || �ھ� || ''',' ||  
                           'nameplate='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ����� || ''',' ||  
                           'metertype='||     --(���ڵ���0ΪԤ��  С��0����Ƿ��)
                 '''' || ˮ������ || ''',' ||  
                        'cbmemo='||  
                  '''' || ����ע || '''' ||
               -- where
               ' where miid=  '||
                  '''' || ���� || ''''  
        from ( select '01' ˮ��״��,
                     '����' �����������,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    �ϴγ�������,
                 TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')     �ϴγ�������1,
                     --mr.MRSCODE   �ϴ�ָ��,
                     mi.MIRCODE �ϴ�ָ��,     --byj edit 2016.06 �ϴ�ָ��Ӧ�ô�meterinfo����ȡ 
                     null ����ָ��,
                     null ˮ��,
                     null ˮ��,
                     null ��ˮ��,
                 --    mr.MRYEARJE01 ˮ��,
               --      mr.MRYEARJE02 ��ˮ��,
                     null ˮ�ѵ���,
                     null ��ˮ�ѵ���,
                     mr.MRTHREESL ���¾���,
                     null ��������,
                     null �ܽ��,
                --     mr.MRYEARJE03 ��������,
                --     mr.MRPLANJE01 �ܽ��,
 
                      mr.MRLASTSL  �ϴγ���ˮ��,
                 DECODE(mr.MRREADOK,'U',mr.MRCHKRESULT, mr.MRMEMO) ����ע,     
                        mi.MIUSENUM �˿���,
                         mi.mipfid ��ˮ����, 
                         FGETPRICENAME(mi.mipfid) ��ˮ��������, 
                       --  T4.BFRCYC ��������,
                         mi.MISMFID Ӫҵ������,
                         fgetsmfname(mi.MISMFID ) Ӫҵ��˵��,
                          mi.MICHARGETYPE �շѷ�ʽ����,
                          decode( mi.MICHARGETYPE,'X','����','M','����') �շѷ�ʽ˵��, 
                           mi.MIPRIID ���ձ������,
                           mi.MIPRIFLAG ���ձ��־,
                          md.DQSFH �����ܷ��,
                          md.DQGFH �����ַ��,
                           md.JCGFH ����շ��,
                           md.QFH Ǧ���,
                           md.BARCODE ������,
                           mi.MISTATUS ˮ��״̬,
                           md.IFDZSB �����־,
                           mi.MICLASS �ֱܷ��־,
                              nvl(mi.MIPID,mi.miid)  �ܱ���,
                        --   mi.MIPOSITION ��λ,
                          decode( mi.MISIDE ,'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
                          md.MDBRAND ����,
                           md.MDCALIBER �ھ�, 
                          substrb(md.MDNO,1,13) �����,
                        --   md.MDNO �����,
                           mi.MILB  ˮ������, 
                           MI.MIID ����
                FROM METERREAD mr,meterinfo mi ,meterdoc md ,bookframe bf
               WHERE  mi.miid = mr.MRMID(+)
                 and mi.miid = md.mdmid
                 and mi.mibfid =bf.bfid
                 and bf.BFRPER = I_BFRPER 
                 and mi.mibfid is not null
                 and mr.mrid is  null   --����δ���������
                 and mi.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  )   --ץȡ��ʱ��
              )           
            UNION ALL
  ---��������������ӱ�����û�������20150320
    --�û�������Ϣ
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,barcode,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,MDMODEL) values(' || 
    '''' || ���� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ����||''','||
    '''' || �û���ַ||''','||
    ''''||��ϵ��||''','||
    ''''||��ϵ�绰||''','||
    ''''||�ƶ��绰||''','||
    ''''||�û�����||''','||
    ''''||��ˮ����||''','||
    ''''||��ˮ��������||''','||
    ''''||�����||''','||
    ''''||�������||''','||
    ''''||�������||''','||
    ''''||�˿���||''','||
    ''''||����Ԥ����||''','||
    ''''||����Ԥ����||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||�ϴγ�������||''','||
    ''''||�Ƿ����||''','||
    ''''||���״��||''','||
    ''''||��ҳ��||''','||
    ''''||�û����||''','||
    ''''||�û���ע||''','||
    ''''||Ӧ�ս��||''','||
    ''''||Ӧ��ˮ��||''','||
    ''''||��ʵ����||''','||
    ''''||����״̬||''','||
    ''''||С����||''','||
    ''''||С������||''','||
    ''''||�ʿ���||''','||
    ''''||¥��||''','||
    ''''||��Ԫ��||''','||
    ''''||���ע��||''','|| 
    ''''||ʾ����Դ||''','|| 
    ''''||���γ�������||''','|| 
    ''''||������||''','|| 
    ''''||�»���||''','||
    ''''||����ˮ����||''','||
    ''''||����ˮ��������||''','||
    ''''||���������־||''','||
    ''''||�Ƿ񱾴γ���||''','||  --meterreadingline_way(�Ƿ񱾴γ���·��)    cahr   1�����Ǳ���   0�����Ǳ���
    '''1'','||
    '''1'','||
    '''1'','||
    ''''||���ͺ�||''')' 
  FROM (SELECT MAX(T2.MIID) ����,
               MAX(T2.MINAME) ����,
               MAX(T2.MINAME2) ��ʵ����,
               MAX(T2.MIADR) �û���ַ,
               MAX(T1.CICONNECTPER) ��ϵ��, 

               MAX(T1.citel1) ��ϵ�绰,
               MAX(T1.CIMTEL)  �ƶ��绰,
              -- MAX(T1.CICONNECTMTEL) �ƶ��绰,
             --  MAX(T1.CICHARGETYPE) �û�����,
              MAX(T2.mICHARGETYPE) �û�����, --20150308
               MAX(T2.MIPFID) ��ˮ����,
          FGETPRICENAME(MAX(T2.MIPFID)) ��ˮ��������,
               MAX(T3.MRBFID) �����,
               MAX(T3.MRBFID) �������, 
               max(t3.MRRORDER) �������, --20150308
               SUM(T2.MIUSENUM) �˿���,
/*                    max (case when t2.mistatus in ('29','30') and t3.MRREADOK ='Y' THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN t2.mistatus NOT in ('29','30') and t3.MRREADOK ='Y' and t3.mrface='01' THEN  T3.MRPLANJE02 
                  else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) ����Ԥ����,
            decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) ����Ԥ����, 
            max(case when  T3.MRREADOK ='N'  THEN   VIEW1.RLJE   else   T3.MRPLANJE01  end   )   Ӧ�ս��, --��������������ץȡ֮ǰ��Ӧ�պϼ�
               sum(VIEW1.rlsl) Ӧ��ˮ��,
                max(t3.MRYEARJE01)  ˮ��,
                max(t3.MRYEARJE02)  ��ˮ��,
                max(t3.MRYEARJE03)  ���ӷ�,*/
                
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                            when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X')<> '9'    AND  t3.MRREADOK <> 'N'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0) -- δ��ѵķǹ̶���ץȡ֮ǰ�ϴ���
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'    AND  t3.MRREADOK <> 'N'  THEN T3.MRPLANJE02   -- δ��ѵķǹ̶���ץȡ֮ǰ�ϴ���
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE03   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X')<> '9'  and   t2.mistatus not in ('29','30')   THEN T3.mrsl 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X') = '9'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) Ӧ��ˮ��, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) ����Ԥ����, 
      
          --   sum(VIEW1.rlsl) Ӧ��ˮ��,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01/*t3.mrsl*/   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end ) Ӧ�ս��, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01/*T3.MRYEARJE01*/ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ˮ��, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02  */--   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ��ˮ��, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03 */ --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ���ӷ�,    
                           
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) �ϴγ�������,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) �Ƿ����,
               'N'  �Ƿ����,
               'δ��' ���״��, 
              MAX(T3.mrbatch) ��ҳ��,--��ҳ�Ÿĳ��ʿ���
              -- MAX(T2.miseqno) �ʿ���, 
               MAX(T2.MILB) �û����,
     MAX(T2.mimemo)�û���ע,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
              --  MAX(DECODE(T3.MRREADOK,'Y','�ѳ���','N','δ����','X','�����')) ����״̬,
                MAX(CASE when  T3.MRREADOK ='Y'  THEN '�����'
                      when  T3.MRREADOK ='N'  THEN 'δ����'
                      when  T3.MRREADOK ='X'  THEN '�����'
                      when  T3.MRREADOK ='U'  THEN 'δͨ��'
                      else 'δ����' END) ����״̬, 
             --  sum(VIEW1.RLJE) Ӧ�ս��,

               max(t2.MICOMMUNITY) С����,
               max(t2.MISEQNO) �ʿ���,
              max(t2.MILH)  ¥��,
             max(t2.MIDYH)  ��Ԫ��,
 
            max(t4.diname) С������, 
                      MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --����ˡ��ѳ���
                              when  T3.MRREADOK ='N'  or T3.MRREADOK ='U'  THEN 'N'  --δ����
                              else 'N' END) ���ע�� ,
                   decode(max(T3.MRIFGU),'1','����','2','����','3','�绰��','4','δ����') ʾ����Դ,
                 -- max(T3.Mrrdate)       ���γ�������,
                    to_char( max(T3.Mrrdate)  ,'yyyy-mm-dd hh24:mi:ss') ���γ�������,
                   MAX(T5.BARCODE) ������, 
              decode(nvl(max(MIYL5),'N'),'N',   MAX(T2.MINAME) , MAX(T3.MRPRIVILEGEMEMO)  ) �»���,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(T3.MRPRIVILEGEPER)  ) ����ˮ����,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(T3.MRPRIVILEGEPER)) )����ˮ��������,
              decode(nvl(max(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ���������־,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) �Ƿ񱾴γ��� ,
            t2.MIRTID ���ͺ�
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 ȡ��
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 ȡ��
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5 ,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2   --ץȡ�Ѿ���ѵ�
         WHERE T1.CIID = T2.MICID
           AND T2.MIID = T3.MRMID 
           AND T2.MIID = T5.MDMID 
          -- AND T4.SMMIID = T2.MIID
           AND T2.MIID = VIEW1.RLMID(+)
           and t3.mrid =view2.rlmrid(+)
           and t2.MICOMMUNITY=t4.diid(+)
            and   t2.mibfid is not null 
           and T3.mrrper =I_BFRPER  --ץȡ������ӵĳ�����Ϣ
         --  and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --ץȡ��ʱ��
           and NVL(T3.MROUTID,'X') <> '9'                                                 --δ�������ص�����!!! byj comment
         --  AND T3.MRREADOK <> 'Y'
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID) 
         
         
     UNION ALL
     
   --����������Ӳ��Ǳ��³����û�������20150420
    --�û�������Ϣ
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,barcode,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,MDMODEL) values(' || 
    '''' || ���� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ����||''','||
    '''' || �û���ַ||''','||
    ''''||��ϵ��||''','||
    ''''||��ϵ�绰||''','||
    ''''||�ƶ��绰||''','||
    ''''||�û�����||''','||
    ''''||��ˮ����||''','||
    ''''||��ˮ��������||''','||
    ''''||�����||''','||
    ''''||�������||''','||
    ''''||�������||''','||
    ''''||�˿���||''','||
    ''''||����Ԥ����||''','||
    ''''||����Ԥ����||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||�ϴγ�������||''','||
    ''''||�Ƿ����||''','||
    ''''||���״��||''','||
    ''''||��ҳ��||''','||
    ''''||�û����||''','||
    ''''||�û���ע||''','||
    ''''||Ӧ�ս��||''','||
    ''''||Ӧ��ˮ��||''','||
    ''''||��ʵ����||''','||
    ''''||����״̬||''','||
    ''''||С����||''','||
    ''''||С������||''','||
    ''''||�ʿ���||''','||
    ''''||¥��||''','||
    ''''||��Ԫ��||''','||
    ''''||���ע��||''','|| 
    ''''||ʾ����Դ||''','|| 
    ''''||���γ�������||''','|| 
    ''''||������||''','|| 
    ''''||�»���||''','||
    ''''||����ˮ����||''','||
    ''''||����ˮ��������||''','||
    ''''||���������־||''','||
    ''''||�Ƿ񱾴γ���||''','||  --meterreadingline_way(�Ƿ񱾴γ���·��)    cahr   1�����Ǳ���   0�����Ǳ���
    '''1'','||
    '''1'','||
    '''1'','||
    ''''||���ͺ�||''')' 
  FROM (SELECT MAX(T2.MIID) ����,
               MAX(T2.MINAME) ����,
               MAX(T2.MINAME2) ��ʵ����,
               MAX(T2.MIADR) �û���ַ,
               MAX(T1.CICONNECTPER) ��ϵ��,
              MAX(T1.citel1) ��ϵ�绰,
               MAX(T1.CIMTEL) �ƶ��绰,
              -- MAX(T1.CICONNECTMTEL) �ƶ��绰,
             --  MAX(T1.CICHARGETYPE) �û�����,
              MAX(T2.mICHARGETYPE) �û�����, --20150308
               MAX(T2.MIPFID) ��ˮ����,
          FGETPRICENAME(MAX(T2.MIPFID)) ��ˮ��������,
               MAX(T3.MRBFID) �����,
               MAX(T3.MRBFID) �������, 
               max(t3.MRRORDER) �������, --20150308
               SUM(T2.MIUSENUM) �˿���,
/*                    max (case when t2.mistatus in ('29','30') and t3.MRREADOK ='Y' THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN t2.mistatus NOT in ('29','30') and t3.MRREADOK ='Y' and t3.mrface='01' THEN  T3.MRPLANJE02 
                  else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) ����Ԥ����,
            decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) ����Ԥ����, 
            max(case when  T3.MRREADOK ='N'  THEN   VIEW1.RLJE   else   T3.MRPLANJE01  end   )   Ӧ�ս��, --��������������ץȡ֮ǰ��Ӧ�պϼ�
               sum(VIEW1.rlsl) Ӧ��ˮ��,
                max(t3.MRYEARJE01)  ˮ��,
                max(t3.MRYEARJE02)  ��ˮ��,
                max(t3.MRYEARJE03)  ���ӷ�,*/
                
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --�Ѿ�������ʵģ�����Ԥ�����Ԥ��-����Ƿ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --�Ѿ���ѵģ�����Ԥ�����Ԥ��-����Ƿ��+����Ƿ��
                            when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X')<> '9'    AND  t3.MRREADOK <> 'N'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0) -- δ��ѵķǹ̶���ץȡ֮ǰ�ϴ���
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'    AND  t3.MRREADOK <> 'N'  THEN T3.MRPLANJE02   -- δ��ѵķǹ̶���ץȡ֮ǰ�ϴ���
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --�̶��������еĶ�ץȡԤ��-��ǰǷ�� 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --δ����Ĳ���ץȡԤ��-��ǰǷ�� 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) ����Ԥ����, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --�Ѿ�������ʵģ�����Ԥ�������Ԥ�� 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --�Ѿ����δ���ʵģ�����Ԥ�������Ԥ�� -����Ƿ��
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE03   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --��δ��ѣ�- ��ˮ�������쳣ΪԤ��-Ƿ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   δ����Ĳ��ݶ�ΪN   
                        else   0   end ) ����Ԥ����, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X')<> '9'  and   t2.mistatus not in ('29','30')   THEN T3.mrsl 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X') = '9'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) Ӧ��ˮ��, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) ����Ԥ����, 
      
          --   sum(VIEW1.rlsl) Ӧ��ˮ��,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01/*t3.mrsl*/   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end ) Ӧ�ս��, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01/*T3.MRYEARJE01*/ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ˮ��, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02  */--   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ��ˮ��, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03 */ --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end ) ���ӷ�,    
                           
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) �ϴγ�������,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) �Ƿ����,
               'N'  �Ƿ����,
               'δ��' ���״��, 
              MAX(T3.mrbatch) ��ҳ��,--��ҳ�Ÿĳ��ʿ���
              -- MAX(T2.miseqno) �ʿ���, 
               MAX(T2.MILB) �û����,

            MAX(T2.mimemo)�û���ע,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '�ѳ���' else 'δ����' END) ����״̬,
              --  MAX(DECODE(T3.MRREADOK,'Y','�ѳ���','N','δ����','X','�����')) ����״̬,
                MAX(CASE when  T3.MRREADOK ='Y'  THEN '�����'
                      when  T3.MRREADOK ='N'  THEN 'δ����'
                      when  T3.MRREADOK ='X'  THEN '�����'
                      when  T3.MRREADOK ='U'  THEN 'δͨ��'
                      else 'δ����' END) ����״̬, 
             --  sum(VIEW1.RLJE) Ӧ�ս��,

               max(t2.MICOMMUNITY) С����,
               max(t2.MISEQNO) �ʿ���,
             max(t2.MILH) ¥��,
            max(t2.MIDYH)  ��Ԫ��,
             max(t4.diname) С������, 
                      MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --����ˡ��ѳ���
                              when  T3.MRREADOK ='N'  or T3.MRREADOK ='U'  THEN 'N'  --δ����
                              else 'N' END) ���ע�� ,
                   decode(max(T3.MRIFGU),'1','����','2','����','3','�绰��','4','δ����') ʾ����Դ,
                 -- max(T3.Mrrdate)       ���γ�������,
                    to_char( max(T3.Mrrdate)  ,'yyyy-mm-dd hh24:mi:ss') ���γ�������,
                   MAX(T5.BARCODE) ������, 
              decode(nvl(max(MIYL5),'N'),'N',  MAX(T2.MINAME) , MAX(MIJD)  ) �»���,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(MIYL6)  ) ����ˮ����,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(MIYL6)) )����ˮ��������,
              decode(nvl(max(MIYL5),'N'),'N','δ����','Y','��ͨ��','X','������','U','δͨ��','δ����') ���������־,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) �Ƿ񱾴γ��� ,
            t2.MIRTID ���ͺ�
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 ȡ��
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 ȡ��
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5 ,bookframe t6,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2   --ץȡ�Ѿ���ѵ�
         WHERE T1.CIID = T2.MICID
           AND T2.MIID = T3.MRMID(+) 
           AND T2.MIID = T5.MDMID 
           and t2.mibfid =t6.bfid 
          -- AND T4.SMMIID = T2.MIID
           AND T2.MIID = VIEW1.RLMID(+)
           and t3.mrid =view2.rlmrid(+)
           and t2.MICOMMUNITY=t4.diid(+)
           and t6.BFRPER =I_BFRPER
           and t2.mibfid is not null
           and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --ץȡ��ʱ��
           and t3.mrid is null  --��Ӳ��Ǳ��³������ϵ�custinfo��Ϣ
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID) 
  UNION ALL
   ---��������������ӱ�����û�������20150320
  --ˮ�������Ϣ
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid) values(' || 
    '''' || ��λ�� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ��λ||''','||
    '''' || ����||''','||
    ''''||�ھ�||''','||
    ''''||�����||''','||
    ''''||ˮ������||''','||
    ''''||��װ����||''','||
    ''''||��������||''','||
    ''''||�ϴγ�������||''','||
    ''''||����||''','||
    ''''||ֹ��||''','||
    ''''||ˮ��||''','||
    ''''||���||''','||
    ''''||�ϴγ�������||''','||
    ''''||���¾���||''','||
    ''''||Ǧ���||''','||
    ''''||������||''','||
    ''''||�±�����||''','|| 
    ''''||�Ƿ���||''','||
    ''''||���ۼ�ˮ��||''','||
    ''''||����������||''','||
    ''''||�˿���||''','||
    ''''||��ˮ����||''','||
    ''''||�ϴγ���ˮ��||''','||
    ''''||��ˮ��������||''','||
    ''''||��������||''','||
    ''''||����ע||''','||
    ''''||Ӫҵ������||''','||
    ''''||Ӫҵ��˵��||''','||
    ''''||�շѷ�ʽ����||''','||
    ''''||�շѷ�ʽ˵��||''','||
    ''''||���˵��||''','||
    ''''||���ձ������||''','||
    ''''||���ձ��־||''','||
    ''''||�����ܷ��||''','||
    ''''||�����ַ��||''','||
    ''''||����շ��||''','||
    ''''||������||''','||
    ''''||ˮ��״̬||''','||
    ''''||�����־||''','||
    ''''||�ֱܷ��־||''','||
    ''''||�ܱ���||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||Ӧ�ս��||''','||
    ''''||����||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END ��λ��,
       T2.MIID ����,
  T2.Miname ����,
  T2.Miadr �û���ַ,
     --  t2.MIPOSITION ��λ,
     decode(  T2.MISIDE ,'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
      t5.MDBRAND ����,
       T5.MDCALIBER �ھ�,
       --T2.MINO �����,
       --substrb(t5.MDNO,1,13)  �����,
       replace(replace(t5.MDNO,chr(10),''),chr(13),'') �����,        
      -- t5.MDNO �����,
       T2.MILB  ˮ������,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') ��װ����,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') ��������,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END �ϴγ�������,
       --NVL(T3.MRSCODE,0) ����,
       t2.MIRCODE ����,     -- byj edit ����ȡ meterinfo �е� 
       T3.MRECODE ֹ��,
     --  T3.MRSL ˮ��,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') <> '9' and   t2.mistatus not in ('29','30')   THEN T3.mrsl --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') = '9' and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) , T3.MRSL )ˮ��, --�ֱܷ�ˮ������Ϊʵ�ʵ�ˮ��
       NVL(T3.MRFACE2,'01')  ���,--ʵ���Ǽ���̬20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') ���,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end ������,
       0 ������,
       t3.MRTHREESL ���¾���,
       t5.QFH Ǧ���,
       0 �±�����,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end �Ƿ���,
       'N' �Ƿ���,
       T3.MRBFID ����,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') ����������,
       ''  ����������,
       T2.MIUSENUM �˿���,
       t2.mipfid ��ˮ����,
      -- CASE WHEN T2.MIPFID='9999' THEN '�����ˮ' else FGETPRICENAME(t2.mipfid) end ��ˮ��������,
       FGETPRICENAME(t2.mipfid) ��ˮ��������,
       --T2.miyeartotalsl ���ۼ�ˮ��,20150308
       0 ���ۼ�ˮ��,
       T2.MIRECSL �ϴγ���ˮ��,
      DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO) ����ע,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) �������� 20150308
       T4.BFRCYC ��������,
       t2.MISMFID Ӫҵ������,
       fgetsmfname(t2.MISMFID ) Ӫҵ��˵��,
        t2.MICHARGETYPE �շѷ�ʽ����,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  ���˵��,-- 20150310����̬˵��
         decode( t2.MICHARGETYPE,'X','����','M','����') �շѷ�ʽ˵��,
         t2.MIPRIID ���ձ������,
         t2.MIPRIFLAG ���ձ��־,
         t5.DQSFH �����ܷ��,
        t5.DQGFH �����ַ��,
      t5.JCGFH ����շ��,
       t5.BARCODE ������,
         t2.MISTATUS ˮ��״̬,
         t5.IFDZSB �����־,
         t2.MICLASS �ֱܷ��־,
          nvl(t2.MIPID,t2.miid)  �ܱ���,
                                                             
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01 /*T3.MRYEARJE01 */--   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ˮ��, 
                           
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02 */ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ��ˮ��, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03*/  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ���ӷ�,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE01 /*t3.mrsl */  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end  Ӧ�ս�� 
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5 ,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --ץȡ�Ѿ���ѵ�
 WHERE T1.CIID = T2.MICID
   and t2.miid   = t3.mrmid 
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and T3.MRRPER =I_BFRPER
   and NVL(T3.MROUTID,'X') <> '9'
   and t2.mibfid is not null 
  -- and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --ץȡ��ʱ��
  -- AND T3.MRREADOK <> 'Y'
   and t3.mrid =view2.rlmrid(+)
   and t2.miid =view1.rlmid(+)
   ) 
   
    UNION ALL
   ---��������������Ӳ��Ǳ��±�����û�������20150420
  --ˮ�������Ϣ
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid) values(' || 
    '''' || ��λ�� || ''',' || 
    '''' || ���� || ''',' ||
    '''' || ��λ||''','||
    '''' || ����||''','||
    ''''||�ھ�||''','||
    ''''||�����||''','||
    ''''||ˮ������||''','||
    ''''||��װ����||''','||
    ''''||��������||''','||
    ''''||�ϴγ�������||''','||
    ''''||����||''','||
    ''''||ֹ��||''','||
    ''''||ˮ��||''','||
    ''''||���||''','||
    ''''||�ϴγ�������||''','||
    ''''||���¾���||''','||
    ''''||Ǧ���||''','||
    ''''||������||''','||
    ''''||�±�����||''','|| 
    ''''||�Ƿ���||''','||
    ''''||���ۼ�ˮ��||''','||
    ''''||����������||''','||
    ''''||�˿���||''','||
    ''''||��ˮ����||''','||
    ''''||�ϴγ���ˮ��||''','||
    ''''||��ˮ��������||''','||
    ''''||��������||''','||
    ''''||����ע||''','||
    ''''||Ӫҵ������||''','||
    ''''||Ӫҵ��˵��||''','||
    ''''||�շѷ�ʽ����||''','||
    ''''||�շѷ�ʽ˵��||''','||
    ''''||���˵��||''','||
    ''''||���ձ������||''','||
    ''''||���ձ��־||''','||
    ''''||�����ܷ��||''','||
    ''''||�����ַ��||''','||
    ''''||����շ��||''','||
    ''''||������||''','||
    ''''||ˮ��״̬||''','||
    ''''||�����־||''','||
    ''''||�ֱܷ��־||''','||
    ''''||�ܱ���||''','||
    ''''||ˮ��||''','||
    ''''||��ˮ��||''','||
    ''''||���ӷ�||''','||
    ''''||Ӧ�ս��||''','||
    ''''||����||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END ��λ��,
       T2.MIID ����,
     T2.Miname ����,
     T2.Miadr �û���ַ,
     --  t2.MIPOSITION ��λ,
     decode(  T2.MISIDE ,'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������') ��λ,
      t5.MDBRAND ����,
       T5.MDCALIBER �ھ�,
       --T2.MINO �����,
     --  t5.MDNO �����,
        --substrb(t5.MDNO,1,13) �����,
        replace(replace(t5.MDNO,chr(10),''),chr(13),'') �����,
       T2.MILB  ˮ������,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') ��װ����,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') ��������,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END �ϴγ�������,
       --NVL(T3.MRSCODE,0) ����,
       t2.MIRCODE ����,   --byj edit 2016.06 ����ȡmeterinfo �е� 
       T3.MRECODE ֹ��,
     --  T3.MRSL ˮ��,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') <> '9' and   t2.mistatus not in ('29','30')   THEN T3.mrsl --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') = '9' and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   δ����Ĳ��ݶ�Ϊ0   
                        else   0   end ) , T3.MRSL )ˮ��, --�ֱܷ�ˮ������Ϊʵ�ʵ�ˮ��
       NVL(T3.MRFACE2,'01')  ���,--ʵ���Ǽ���̬20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') ���,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end ������,
       0 ������,
       t3.MRTHREESL ���¾���,
       t5.QFH Ǧ���,
       0 �±�����,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end �Ƿ���,
       'N' �Ƿ���,
       T3.MRBFID ����,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') ����������,
       ''  ����������,
       T2.MIUSENUM �˿���,
       t2.mipfid ��ˮ����,
      -- CASE WHEN T2.MIPFID='9999' THEN '�����ˮ' else FGETPRICENAME(t2.mipfid) end ��ˮ��������,
       FGETPRICENAME(t2.mipfid) ��ˮ��������,
       --T2.miyeartotalsl ���ۼ�ˮ��,20150308
       0 ���ۼ�ˮ��,
       T2.MIRECSL �ϴγ���ˮ��,
       DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO)   ����ע,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) �������� 20150308
       T4.BFRCYC ��������,
       t2.MISMFID Ӫҵ������,
       fgetsmfname(t2.MISMFID ) Ӫҵ��˵��,
        t2.MICHARGETYPE �շѷ�ʽ����,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  ���˵��,-- 20150310����̬˵��
         decode( t2.MICHARGETYPE,'X','����','M','����') �շѷ�ʽ˵��,
         t2.MIPRIID ���ձ������,
         t2.MIPRIFLAG ���ձ��־,
         t5.DQSFH �����ܷ��,
         t5.DQGFH �����ַ��,
        t5.JCGFH ����շ��,
        t5.BARCODE ������,
         t2.MISTATUS ˮ��״̬,
         t5.IFDZSB �����־,
         t2.MICLASS �ֱܷ��־,
          nvl(t2.MIPID,t2.miid)  �ܱ���,
                                                             
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01 /*T3.MRYEARJE01 */--   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ˮ��, 
                           
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02 */ --   �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ��ˮ��, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03*/  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0��ʱ��MRYEARJE03һ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0 end   ���ӷ�,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --�Ѿ�������ʵģ�ˮ�����ڱ���ˮ��
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --�Ѿ����δ���ʵģ� ˮ����������Ƿ��ˮ��
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE01 /*t3.mrsl */  --  �̶���ÿ�δ�ӡ���ô˴�Ϊ0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --��δ��ѣ��ѳ������Ϊ����ʱץȡ֮ǰд��� 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   δ����Ĳ��ݶ�Ϊ0   
                         else   0   end  Ӧ�ս�� 
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5 ,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ��ˮ��
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  ���ӷ�
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --ץȡ�Ѿ���ѵ�
 WHERE T1.CIID = T2.MICID
   and t2.miid = t3.mrmid (+)
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and T4.BFRPER = I_BFRPER
    and t2.mibfid is not null
   and t3.mrid is  null  --���Ǳ��³�������
  and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --ץȡ��ʱ�� 
   and t3.mrid =view2.rlmrid(+)
   and t2.miid =view1.rlmid(+)) 
   --��ӽɷ���Ϣ���� 20150615
   UNION ALL
  SELECT 'insert into payment_his(MIID,CIID,PDATETIME,PPOSITION,MICHARGETYPE,PPAYMENT,PPAYEE,PPAYWAY) values(' || 
    '''' || ˮ���� || ''',' || 
    '''' || �û���� || ''',' ||
    '''' || �ɷ�����||''','||
    '''' || �ɷѻ���||''','||
    '''' || �ɷѷ�ʽ||''','||
    ''''||������||''','||
    ''''||�շ�Ա||''','||
    ''''||���ʽ||''')'
    from 
      ( SELECT MAX(MI.MICID) ˮ����, --ˮ���� VARCHAR2(10)
       MAX(MI.MICID) �û����, --�û���� VARCHAR2(10) 
       to_char(MAX(PM.PDATETIME),'yyyy-mm-dd hh24:mm:ss') �ɷ�����, --�������� VARCHAR2(20)
       MAX(FGETSYSMANAFRAME(PM.PPOSITION) ) �ɷѻ���, --�ɷѻ��� VARCHAR2(60)
        DECODE(MAX(MI.MICHARGETYPE), 'X', '����', 'M', '����') �ɷѷ�ʽ, --�ɷѷ�ʽ VARCHAR2(20)
        SUM(PM.PPAYMENT) ������, --������ NUMBER(12,2)
       MAX( FGETOPERNAME(PM.PPAYEE) )�շ�Ա, --�շ�Ա  VARCHAR2(20) 
       MAX(decode(TRIM(PM.PPAYWAY), 'XJ','�ֽ�','DC','����','ZP','֧Ʊ','MZ','Ĩ��') ) ���ʽ     --���ʽVARCHAR2(20)
  FROM PAYMENT PM, METERINFO MI,BOOKFRAME BF
 WHERE PM.PMID = MI.MIID
   AND mi.mibfid =bf.bfid
   AND PM.PREVERSEFLAG = 'N'
   and bf.BFRPER=I_BFRPER
   and PM.PBATCH in ( select miid from METERINFO_SJCBUP  where ciid =pm.pmid and  UPDATE_MK ='3'  ) --����û��ɷѼ�¼
   aND ( PM.PDATETIME >=add_months(SYSDATE,-24) )
 GROUP BY PM.PBATCH
 having  SUM(PM.PPAYMENT) > 0
 ORDER BY MAX(MI.MISMFID),
          SUBSTR(MAX(MI.MIBFID), 1, 5),
          MAX(MI.MILB),
          MAX(MI.MIPRIID)  )
          
   -- ��Ӳ�������
   UNION ALL
    select 'DELETE FROM datadesign' from dual
   
   UNION ALL
   
   --�ֵ���Ϣ
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || �ֵ����� || ''',' || 
    '''' || �ֵ�CODE || ''',' ||
    '''' || �ֵ�||''','||
    '''' || ��ע||''')'
  FROM (
      select 'ˮ��ھ�' �ֵ�����,mcid||'' �ֵ�CODE,mcname||'' �ֵ�, '' ��ע from METERCALIBER
       UNION ALL
       select 'ˮ��״��' �ֵ�����,sflid �ֵ�CODE,sflname �ֵ�,sflflag1 ��ע from sysfacelist2 t   /* where t.sflid  not in ('13','14','15')*/
       UNION ALL
       select 'ˮ��λ��' �ֵ�����,sclid �ֵ�CODE,sclvalue �ֵ�,decode(sclgroup,'01','����','02','����') ��ע from syscharlist  where scltype ='��λ'   
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'���' �ֵ�CODE,t.oaid �ֵ�,''��ע from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,t.oaname �ֵ�,''��ע from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����,'����' �ֵ�CODE,UPPER(t.oapwd) �ֵ�,''��ע from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա�ֻ�����' �ֵ�����,oatel �ֵ�CODE,t.oatel �ֵ�,''��ע from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select 'Ӫ��Ա' �ֵ�����, 'Ӫҵ��' �ֵ�CODE,   b.smfpid   �ֵ�,''��ע   --��¼����ԱӪҵ��
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
         and a.oaid =I_BFRPER 
       UNION ALL
       select �ֵ�����, �ֵ�CODE,�ֵ�,��ע from datadesign where  �ֵ����� not in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��','��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����','�ֻ��汾��������','�ֻ��������ȫѡ����','�ֻ��������װ·��','��ѡ������','��������URL')
        AND NVL(��ע,'NULL') <> 'XXXXXXXXXX' and �ֵ� not in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ')
      UNION ALL
              SELECT �ֵ�����, �ֵ�CODE,�ֵ�,��ע
          FROM DATADESIGN
         WHERE �ֵ����� = '�ֻ��汾��������'
           and �ֵ�code = (select max(�ֵ�code)
                           from DATADESIGN
                          WHERE �ֵ����� = '�ֻ��汾��������') 
                          
       UNION ALL
       select '�û�(ˮ��)״̬' �ֵ�����,SMSID �ֵ�CODE,SMSNAME �ֵ�,''��ע FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 ���ˮ��״̬
       UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and a.oaid =I_BFRPER
         and c.�ֵ����� in ('��ӡԤ��֪֪ͨ��', '�������', '�Ƿ�����', '�Ƿ�绰��' ,'��ӡԤ��Ԥ��֪ͨ��','��������','��ӡֽ����','�Ƿ�ʵʱ�ϴ�','�ύ����ʱ����','ˮ�Ѷ���','�ύ��������ʱ����' )
             UNION ALL 
       select c.�ֵ�����,substrb(c.�ֵ�CODE,1,instr(c.�ֵ�CODE,':') - 1),c.�ֵ�,  substrb(c.�ֵ�CODE,instr(c.�ֵ�CODE,':') + 1 ,length(c.�ֵ�CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and a.oaid =I_BFRPER
         and c.�ֵ����� in ( '��������URL')
      UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE, substrb(c.�ֵ�,1,instr(c.�ֵ�,':') - 1) ,  substrb(c.�ֵ�,instr(c.�ֵ�,':') + 1 ,length(c.�ֵ�))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.��ע
         and a.oaid =I_BFRPER
         and c.�ֵ����� in ( '��ѡ������' ) 
       UNION ALL 
       select c.�ֵ�����, c.�ֵ�CODE,c.�ֵ�,c.��ע
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.�ֵ�����
         and a.oaid =I_BFRPER
         and  c.�ֵ�  in ('Ӫҵ���ϴ�ͼƬ�ļ�������IP��ַ' ) 
       UNION ALL     
      select distinct 'ͼƬ�Ѿ��ϴ�' �ֵ�����, PMBZ �ֵ�CODE,substr(pmpath,instr(pmpath,mpmiid,1),200)�ֵ�,MPMIID ��ע
      from meterpicture 
      where pmper= I_BFRPER
      and pmtime >= to_date(to_char( sysdate  ,'yyyymm')||'01000001', 'yyyymmddhh24miss') 
      and  pmtime <= to_date(to_char(trunc(Last_day(sysdate)),'yyyymmdd')||'235959', 'yyyymmddhh24miss')   
         )     ;   
         
  --add 20150320 
  --hb
  --���µ�ǰ����ⷢ��ע�Ǽ�ʱ�䣬 
  update meterread
    set mroutflag=DECODE(MRREADOK ,'Y','N','N', 'Y') ,  --�Ѿ�����ķ���ע��ΪN,������³������ϣ�ֻ����������ѣ�����f8003���MRREADOKΪY�����mroutflag����ΪN
        MROUTDATE =sysdate,MROUTID='9'
  where MRRPER =I_BFRPER  ;  --�Ѿ�����Ļ�MRREADOKΪY����ע��mroutflag����Ҫ��ΪY����f8003���MRREADOKΪY�����mroutflag����ΪN
  
  
  --���±��س���ƻ�ָ�� byj edit 2016.06
	update meterread mr 
	   set MRSCODE = (select MIRCODE from meterinfo mi where mr.mrmid = miid),
		     mr.mrscodechar = (select to_char(MIRCODE) from meterinfo mi where mr.mrmid = miid)
	 where (mr.mrreadok = 'N' or mrreadok = 'U') and
	       mr.mrrper = i_bfrper;
	
	-- byj edit 2016.06
  delete from METERINFO_SJCBUP a where 
	  exists(select 1 from meterinfo mi,bookframe bf where mi.mibfid = bf.bfid and bf.bfrper = I_BFRPER and a.ciid = mi.miid);
  
  
  
 -- delete from METERINFO_SJCBUP where ciid  in (select mi.miid from meterinfo mi , bookframe bk where mi.mibfid =bk.bfid and bk.BFRPER=I_BFRPER) ;  --ÿ�θ�����ɾ������Ա��ˮ��ĸ�����Ϣ
  --�������CIID ��Ϊmiid����3���ɷѼ�¼������Miid�����������κţ�ֻ��CIID������û���
  commit;
  
  END;
                         
     --�������ע�ǻ�д�ֻ���
  procedure  DOWN_DATA_PICT(I_MPMIID IN VARCHAR2,
                            I_PMSIZE   IN VARCHAR2,
                            I_PMPATH   IN VARCHAR2,
                            I_PMTIME   IN VARCHAR2,
                            I_PMBZ   IN VARCHAR2,
                            I_PMPER   IN VARCHAR2,
                            I_PMPNAME   IN VARCHAR2,
                            I_ciid   IN VARCHAR2,
                            I_PMFACT_PATH   IN VARCHAR2,
                          O_CURRSOR   OUT  VARCHAR2) is 
  V_COUNT NUMBER :=0 ;
begin 
/*    SELECT COUNT(*)
    INTO V_COUNT
    FROM meterpicture
    WHERE mpmiid=I_MPMIID AND TO_CHAR(PMTIME,'YYYYMM')= TO_CHAR(SYSDATE,'YYYYMM') ;
    IF */
    insert into meterpicture
     (mpmiid, pmsize, pmpath, pmtime, pmbz, pmper, pmpname, ciid, pmfact_path)
   values
      (I_MPMIID, to_number(I_PMSIZE), I_PMPATH, to_date(I_PMTIME,'yyyy/mm/dd hh24miss'), I_PMBZ, I_PMPER, I_PMPNAME, I_ciid, I_PMFACT_PATH);
   
   commit;
    O_CURRSOR :='000' ;--���سɹ�
  exception
        when others then  
            O_CURRSOR :='999' ;--���سɹ�
            rollback;
            return;
 end ; 
  
  --�ֻ��ϴ�ͼƬʱ�����ν���ͼƬ����
  procedure DOWN_DATA_PICTS(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) IS
    V_TYPE VARCHAR2(30);
    v_BFRPER meterpicture.pmper%type;
  BEGIN
   V_TYPE:='ͼƬ�Ѿ��ϴ�';
   v_BFRPER:=replace(I_BFRPER,',','');
   OPEN O_CURRSOR FOR select 'DELETE FROM datadesign WHERE  type  in ('''||V_TYPE||''') ' from dual 
   UNION ALL 
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || �ֵ����� || ''',' || 
    '''' || �ֵ�CODE || ''',' ||
    '''' || �ֵ�||''','||
    '''' || ��ע||''')'
  FROM (
        select distinct 'ͼƬ�Ѿ��ϴ�' �ֵ�����, PMBZ �ֵ�CODE,substr(pmpath,instr(pmpath,mpmiid,1),200)�ֵ�,MPMIID ��ע
      from meterpicture 
      where pmper= v_BFRPER
      and pmtime >= to_date(to_char( sysdate  ,'yyyymm')||'01000001', 'yyyymmddhh24miss') 
      and  pmtime <= to_date(to_char(trunc(Last_day(sysdate)),'yyyymmdd')||'235959', 'yyyymmddhh24miss')  
  );
  END;
  
END;
/

