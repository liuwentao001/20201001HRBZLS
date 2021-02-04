CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_PAD_DL IS

  /*
  * 功能：下载用户基本信息
  * 创建人:曾海洲
  * 创建时间：2014-07-23
  * @表册信息
  * @抄表员编号
  * @返回游标
  */
  procedure DOWN_DATA(I_BFIDS   IN VARCHAR2,
                    I_BFRPER  IN VARCHAR2,
                    i_version  IN VARCHAR2, --版本号
                    O_CURRSOR OUT SYS_REFCURSOR) IS
    li_old_pos1     NUMBER;
    li_pos1         NUMBER;
    i               NUMBER;
    li_exit         boolean;
    v_temp_str      varchar2(200);
    v_bfids varchar2(4000);
    --抄表员编号
    v_count number;
    v_字典CODE  datadesign.字典CODE%type;
  BEGIN
     BEGIN 
       select 字典CODE into v_字典CODE from datadesign where 字典类型='手机客户端版本' ;
       EXCEPTION 
          WHEN OTHERS THEN
            v_字典CODE:='';
       END ;
       if trim(NVL(v_字典CODE,'NULL'))<> trim(nvl(i_version,'NULL')) then  --手机版本是否客户端版本一致，不一致下载表册数据为空
          return ;
         end if ;
/*    --I_BFIDS存入临时表
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
    --删除用户信息
   -- SELECT 'DELETE FROM custinfo WHERE BFID in('||v_bfids||') ' FROM DUAL
   SELECT 'DELETE FROM custinfo  ' FROM DUAL
    UNION ALL
    --用户基本信息
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,isprint,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,BARCODE,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,apply_date,sfjg,psfjg,MDMODEL) values(' || 
    '''' || 户号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 户名||''','||
    '''' || 用户地址||''','||
    ''''||联系人||''','||
    ''''||联系电话||''','||
    ''''||移动电话||''','||
    ''''||用户类型||''','||
    ''''||用水性质||''','||
    ''''||用水性质名称||''','||
    ''''||表册编号||''','||
    ''''||表册名称||''','||
    ''''||抄表次序||''','||
    ''''||人口数||''','||
    ''''||上期预存金额||''','||
    ''''||本期预存金额||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||打印标志||''','||
    ''''||上次抄表日期||''','||
    ''''||是否阶梯||''','||
    ''''||查表状况||''','||
    ''''||册页号||''','||
    ''''||用户类别||''','||
    ''''||用户备注||''','||
    ''''||应收金额||''','||
    ''''||应收水量||''','||
    ''''||真实名称||''','||
    ''''||处理状态||''','||
    ''''||小区号||''','||
    ''''||小区名称||''','||
    ''''||帐卡号||''','||
    ''''||楼号||''','||
    ''''||单元号||''','||
    ''''||算费注记||''','||
    ''''||示数来源||''','||
    ''''||本次抄表日期||''','||
    ''''||条形码||''','||
    ''''||新户名||''','||
    ''''||新用水性质||''','||
    ''''||新用水性质名称||''','||
    ''''||工单申请标志||''','||
    ''''||是否本次抄表||''','||  --meterreadingline_way(是否本次抄表路线)    cahr   1代表是本月   0代表不是本月
     -- '''1'','||   --是否本次抄表
    '''1'','||
    '''1'','|| 
    '''1'','||
    ''''||修改时间||''','||
    ''''||水费单价||''','||
    ''''||污水费单价||''','||
    ''''||表型号||''')'
  FROM (SELECT MAX(T2.MIID) 户号,
        MAX(replace(replace(T2.MINAME,chr(10),''),chr(13),''))户名,
        MAX(replace(replace(T2.MINAME2,chr(10),''),chr(13),''))真实名称,
        MAX(replace(replace(T2.MIADR,chr(10),''),chr(13),''))用户地址,
        MAX(replace(replace(T1.CICONNECTPER,chr(10),''),chr(13),''))联系人,
        --MAX(T1.CICONNECTPER)联系人,  
              -- MAX(T2.MIADR) 用户地址,
              -- MAX(T1.CICONNECTPER) 联系人,
/*          ( case when instr( MAX(T1.citel1),CHR(10)) > 0  then 
  substr( MAX(T1.citel1),1,instr( MAX(T1.citel1),CHR(10)) - 2)   else  MAX(T1.citel1) end ) 联系电话,
                       ( case when instr( MAX(T1.CIMTEL),CHR(10)) > 0  then 
  substr( MAX(T1.CIMTEL),1,instr( MAX(T1.CIMTEL),CHR(10)) - 2)   else  MAX(T1.CIMTEL) end ) 移动电话,*/
   -- MAX(T1.citel1) 联系电话,
    max(replace(replace(T1.citel1,chr(10),''),chr(13),'')) 联系电话,
  -- MAX(T1.CIMTEL) 移动电话,
   max(replace(replace(T1.CIMTEL,chr(10),''),chr(13),''))移动电话,
            --   MAX(T1.citel1) 联系电话,
            --   MAX(T1.CIMTEL) 移动电话,
              -- MAX(T1.CICONNECTMTEL) 移动电话,
             --  MAX(T1.CICHARGETYPE) 用户类型,
              MAX(T2.mICHARGETYPE) 用户类型, --20150308
               MAX(T2.MIPFID) 用水性质,
          FGETPRICENAME(MAX(T2.MIPFID)) 用水性质名称,
               MAX(nvl(T3.MRBFID,t6.bfid)) 表册编号,
               MAX(nvl(T3.MRBFID,t6.bfid)) 表册名称, 
               max(nvl(t3.MRRORDER,t2.mirorder)) 抄表次序, --20150308
               SUM(T2.MIUSENUM) 人口数,  
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30')   AND  t3.MRREADOK <> 'N' and nvl(t3.mrdatasource,'X') <> '9'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)     -- 非手机抄表但有算费
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30')   AND  t3.MRREADOK <> 'N'  and nvl(t3.mrdatasource,'X') = '9' THEN  T3.MRPLANJE02    -- 手机抄表算费
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                    --    when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0   --  固定量每次打印调用此处为0
                     when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  nvl(T3.MRPLANJE03,0)--20150414因固定量、合收表打印算费有问题 
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') <> '9'   THEN  nvl(t3.mrsl,0)  --当未算费，已抄表、表况为正常时抓取之前写入的   
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'   THEN  T3.MRPLANSL  --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) 应收水量, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) 本期预存金额, 
      
          --   sum(VIEW1.rlsl) 应收水量,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                    --     when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0 /*t3.mrsl*/   --  固定量每次打印调用此处为0
                          when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01 --20150414因固定量、合收表打印算费有问题
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end ) 应收金额, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0 /*T3.MRYEARJE01*/ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE01 --20150414因固定量、合收表打印算费有问题
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 水费, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE02 */ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02   --20150414因固定量、合收表打印算费有问题
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 污水费, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                        -- when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE03 */ --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE03 --20150414因固定量、合收表打印算费有问题
                       when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 附加费,                   
               max(case when t3.MRREQUISITION > 0 then 'Y' ELSE 'N' END ) 打印标志,
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) 上次抄表日期,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) 是否阶梯,
               'N'  是否阶梯,
               '未查' 查表状况, 
              MAX(T3.mrbatch) 册页号,--册页号改成帐卡号
              -- MAX(T2.miseqno) 帐卡号, 
               MAX(T2.MILB) 用户类别,
   ( case when instr( MAX(T2.mimemo),CHR(10)) > 0  then 
  substr( MAX(T2.mimemo),1,instr( MAX(T2.mimemo),CHR(10)) - 2)   else  MAX(T2.mimemo) end ) 用户备注,  
            --   MAX(T2.mimemo)用户备注,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
             MAX(CASE when  T3.MRREADOK ='Y'  THEN '已审核'
                      when  T3.MRREADOK ='N'  THEN '未处理'
                      when  T3.MRREADOK ='X'  THEN '待审核'
                      when  T3.MRREADOK ='U'  THEN '未通过'
                      else '未处理' END) 处理状态,
              --  MAX(DECODE(T3.MRREADOK,'Y','已出账','N','未处理','X','待审核')) 处理状态,

                 max(t2.MICOMMUNITY) 小区号,
               max(t2.MISEQNO) 帐卡号,
                  max(t2.MILH)  楼号,
                 max(t2.MIDYH) 单元号,
                  max(t4.diname) 小区名称,
              MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --待审核、已出帐
                      when  T3.MRREADOK ='N' or  T3.MRREADOK ='U'  THEN 'N'  --未处理
                      else 'N' END) 算费注记 ,
             decode(max(T3.MRIFGU),'1','见表','2','估抄','3','电话件','4','未见表') 示数来源,
            --   max(t3.MRRDATE) 本次抄表日期,
                to_char( max(t3.MRRDATE),'yyyy-mm-dd hh24:mi:ss')   本次抄表日期,
               max(t5.BARCODE) 条形码, 
               
              --decode(nvl(max(MIYL5),'N'),'N',    max(T2.miname))   , MAX(MIJD)   新户名,
              decode(nvl(max(MIYL5),'N'),'N',     MAX(replace(replace(T2.miname,chr(10),''),chr(13),'')))   , MAX(replace(replace(MIJD,chr(10),''),chr(13),''))   新户名,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(miyl6)  ) 新用水性质,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(miyl6)) )新用水性质名称,
              decode(nvl(max(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') 工单申请标志,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) 是否本次抄表 ,
            to_char(max(MIYL10),'yyyy-mm-dd hh24:mi:ss') 修改时间,
             -----zhw20160415修改最新成最新单价
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  水费单价,
                 fun_getjtdqdj( max(MIPFID), max(MIPRIID) , max(miid) ,'1') 水费单价,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     污水费单价,
               fgetwsf(max(mipfid)) 污水费单价, 
                -----------------------------------------------------------end
            t2.MIRTID 表型号
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 取消
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 取消
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid    AND RLREVERSEFLAG <> 'Y'
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2,bookframe t6  --抓取已经算费的
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
          --and t3.mrdatasource <> 'I'       --去掉 通过智能表平台接口的
  /*         and exists(
             select 1 from pad_bfids tt where tt.c1 = I_BFRPER and tt.c2 = t2.mibfid
           )*/
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID)
          
  UNION ALL
  
  --删除水表信息
 -- SELECT 'DELETE FROM meterinfo WHERE BFID in('||v_bfids||') ' FROM DUAL
  SELECT 'DELETE FROM meterinfo ' FROM DUAL
  UNION ALL
  
  --水表基本信息
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid,mrdzflag,mrdzcurcode,miyl9) values(' || 
    '''' || 单位号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 表位||''','||
    '''' || 厂牌||''','||
    ''''||口径||''','||
    ''''||表身号||''','||
    ''''||水表类型||''','||
    ''''||安装日期||''','||
    ''''||换表日期||''','||
    ''''||上次抄表日期||''','||
    ''''||起码||''','||
    ''''||止码||''','||
    ''''||水量||''','||
    ''''||表况||''','||
    ''''||上次抄表日期||''','||
    ''''||三月均量||''','||
    ''''||铅封号||''','||
    ''''||拆表底数||''','||
    ''''||新表起数||''','|| 
    ''''||是否拆表||''','||
    ''''||年累计水量||''','||
    ''''||阶梯起算日||''','||
    ''''||人口数||''','||
    ''''||用水性质||''','||
    ''''||上次抄表水量||''','||
    ''''||用水性质名称||''','||
    ''''||抄表周期||''','||
    ''''||抄表备注||''','||
    ''''||营业所代号||''','||
    ''''||营业所说明||''','||
    ''''||收费方式代号||''','||
    ''''||收费方式说明||''','||
    ''''||表况说明||''','||
    ''''||合收表主表号||''','||
    ''''||合收表标志||''','||
    ''''||地区塑封号||''','||
    ''''||地区钢封号||''','||
    ''''||稽查刚封号||''','||
    ''''||条形码||''','||
    ''''||水表状态||''','||
    ''''||倒表标志||''','||
    ''''||总分表标志||''','||
    ''''||总表编号||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||应收金额||''','||
    ''''||表册号||''','||
    ''''||等针标志||''','||
    ''''||等针用户实际读数||''','||
    ''''||水表量程||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END 单位号,
       T2.MIID 户号, 
        T2.Miname 户名,
        T2.Miadr 用户地址,
     decode(t2.MISIDE,'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
      t5.MDBRAND 厂牌,
       T5.MDCALIBER 口径,
       --T2.MINO 表身号,
      --substrb(t5.MDNO,1,13) 表身号,
      replace(replace(t5.MDNO,chr(10),''),chr(13),'') 表身号,
      --decode( T3.MRBFID,'06507235','', t5.MDNO )表身号,
       T2.MILB  水表类型,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') 安装日期,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') 换表日期,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END 上次抄表日期,
       NVL(T3.MRSCODE,0) 起码,
       T3.MRECODE 止码,
    --   T3.MRSL 水量,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  固定量每次打印调用此处为0
                            when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') <> '9'    THEN  t3.mrsl --当未算费，已抄表、表况为正常时抓取之前写入的                
                            when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'   THEN  T3.MRPLANSL --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) , T3.MRSL )水量, --总分表水量处理为实际的水量
       NVL(T3.MRFACE2,'01')  表况,--实际是检表表态20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') 表况,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end 拆表底数,
       0 拆表底数,
       t3.MRTHREESL 三月均量,
       t5.QFH 铅封号,
       0 新表起数,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end 是否拆表,
       'N' 是否拆表,
       T3.MRBFID 表册号,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') 阶梯起算日,
       ''  阶梯起算日,
       T2.MIUSENUM 人口数,
       t2.mipfid 用水性质,
      -- CASE WHEN T2.MIPFID='9999' THEN '混合用水' else FGETPRICENAME(t2.mipfid) end 用水性质名称,
       FGETPRICENAME(t2.mipfid) 用水性质名称,
       --T2.miyeartotalsl 年累计水量,20150308
       fun_getjtdqdj( MIPFID, MIPRIID , miid ,'3') 年累计水量,
       T2.MIRECSL 上次抄表水量,
      DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO)  抄表备注,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) 抄表周期 20150308
       T4.BFRCYC 抄表周期,
       t2.MISMFID 营业所代号,
       fgetsmfname(t2.MISMFID ) 营业所说明,
        t2.MICHARGETYPE 收费方式代号,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  表况说明,-- 20150310检表表态说明
         decode( t2.MICHARGETYPE,'X','坐收','M','走收') 收费方式说明,
         t2.MIPRIID 合收表主表号,
         t2.MIPRIFLAG 合收表标志,
         --t5.DQSFH 地区塑封号,
         replace(replace(t5.DQSFH,chr(10),''),chr(13),'') 地区塑封号,
         replace(replace(t5.DQGFH,chr(10),''),chr(13),'') 地区钢封号,
         replace(replace(t5.JCGFH,chr(10),''),chr(13),'') 稽查刚封号,
         -- t5.DQGFH 地区钢封号,
         -- t5.JCGFH  稽查刚封号,
         t5.BARCODE 条形码,
         t2.MISTATUS 水表状态,
         nvl(t5.IFDZSB,'N') 倒表标志,  --预设为N
       --  t5.IFDZSB 倒表标志,
         t2.MICLASS 总分表标志,
         nvl(t2.MIPID,t2.miid) 总表编号,  
  /*             (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --表异常及零0水量
              else   T3.MRYEARJE01 end  )  水费, 
           (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --表异常及零0水量
              else   T3.MRYEARJE02 end  )  污水费, 
         (  case when  T3.MRREADOK ='N'  THEN  0
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --表异常及零0水量
              else   T3.MRYEARJE03 end  )  附加费, 
      (  case when  T3.MRREADOK ='N'  THEN  nvl(VIEW1.RLJE,0)  
             when  T3.MRREADOK <> 'N' and  t3.mrface <> '01' then 0   --表异常及零0水量
              else   T3.MRPLANJE01 end  )   应收金额  --如果待审核则重新抓取之前的应收合计*/
                                                  
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                       --  when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN 0/*T3.MRYEARJE01*/ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRYEARJE01 --20150415
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   水费, 
                           
                  case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02 /*T3.MRYEARJE02*/  --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   污水费, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03 /*T3.MRYEARJE03*/  --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end 附加费,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01 /*t3.mrsl*/   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end  应收金额 ,
                         nvl(t3.mrdzflag,'N') 等针标志,
                         t3.mrdzcurcode 等针用户实际读数,
                         t2.miyl9 水表量程
                           
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --抓取已经算费的
 WHERE T1.CIID = T2.MICID
   and t2.miid   = t3.mrmid(+)
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and t2.miid = VIEW1.RLMID(+)
   and t3.mrid =view2.rlmrid(+)
   and T4.BFRPER =I_BFRPER
   and t2.mibfid is not null
   --and t3.mrdatasource <> 'I'    --去掉通过智能表平台接口的数据
/*   and exists(
      select 1 from pad_bfids tt where tt.c1 = I_BFRPER and tt.c2 = t2.mibfid
   )*/
   )
   
   UNION ALL
   --删除水价信息
   select 'DELETE FROM price_detail' from dual
   
   UNION ALL
   
   --水价信息
   SELECT 'insert into price_detail(pfid,pfname,start_date,end_date,sfdj,psfdj,jyfdj,szydj,curr_dj,step,start_usenum,end_usenum,isstep) values(' || 
    '''' || 用水性质 || ''',' || 
    '''' || 用水性质名称 || ''',' ||
    '''' || 开始时间||''','||
    '''' || 结束时间||''','||
    ''''||水费单价||''','||
    ''''||NVL(排水费单价,0)||''','||
    ''''||NVL(二次加压单价,0)||''','||
    ''''||NVL(垃圾费单价,0)||''','||
    ''''||是否当前价||''','||
    ''''||阶梯号||''','||
    ''''||起始水量||''','||
    ''''||结束水量||''','||
    ''''||是否阶梯||''')'
  FROM (select T.PDPFID 用水性质,
               MAX(T2.PFNAME) 用水性质名称,
               MAX(CASE
                     WHEN T.PDPIID = '01' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) 水费单价,
               MAX(CASE
                     WHEN T.PDPIID = '02' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) 排水费单价,
               MAX(CASE
                     WHEN T.PDPIID = '04' THEN
                      T.PDDJ
                     ELSE
                      0
                   END) 二次加压单价,
               0 垃圾费单价,
               '1900-01-01' 开始时间,
               '2080-12-30' 结束时间,
               'Y' 是否当前价,
               1 阶梯号,
               'N' 是否阶梯,
               0 起始水量,
               0 结束水量
          FROM  PRICEDETAIL T, PRICEFRAME T2
         WHERE T.PDPFID = T2.PFID
/*           AND NOT EXISTS
         (SELECT * FROM  pricestep T3 WHERE T3.PSPFID = T.PDPFID)*/
         GROUP BY T.PDPFID

        UNION ALL

        select T3.pspfid 用水性质,
               T2.PFNAME 用水性质名称,
               CASE
                 WHEN T.PDPIID = '01' THEN
                  T3.Psprice
                 ELSE
                  0
               END 水费单价,
               view4. 排水费单价,
               view4.二次加压单价,
               0 垃圾费单价,
               '1900-01-01' 开始时间,
               '2080-12-30' 结束时间,
               'Y' 是否当前价,
               t3.psclass 阶梯号,
               'Y' 是否阶梯,
               T3.PSSCODE-1 起始水量,
               T3.PSECODE 结束水量
          FROM  PRICEDETAIL T,
                PRICEFRAME T2,
                pricestep T3,
               (select t4.pdpfid,
                       max(case
                             when t4.pdpiid = '02' then
                              t4.PDDJ
                             else
                              0
                           end) 排水费单价,
                       max(case
                             when t4.pdpiid = '04' then
                              t4.PDDJ
                             else
                              0
                           end) 二次加压单价
                  from  PRICEDETAIL t4
                 where t4.pdpiid <> '01'
                 group by t4.pdpfid) view4
         WHERE T.PDPFID = T2.PFID
           AND T.Pdpfid = t3.pspfid
           and t.pdpiid = t3.pspiid
           and t.pdpfid = view4.pdpfid(+)
)

UNION ALL
--20150308 混合用水暂时不考虑
/*--混合用水信息
SELECT ' DELETE FROM mixtureinfo where bfid in ('||v_bfids||') ' FROM DUAL

UNION ALL

SELECT 'insert into mixtureinfo(ciid,miid,pfid,rate_scale,ratify_sl,data_type,isstep,pfname,bfid) values(' || 
    '''' || 用户编号 || ''',' || 
    '''' || 水表编号 || ''',' ||
    '''' || 用水性质||''','||
    '''' || 混合比例||''','||
    ''''||核定水量||''','||
    ''''||数据类型||''','||
    ''''||是否阶梯||''','||
    ''''||用水性质名称||''','||
    ''''||表册编号||''')'
  FROM (SELECT T2.MICID 用户编号,
       T2.MIID 水表编号,
       T3.PMDPFID 用水性质,
       T3.PMDSCALE 混合比例,
       '1' 数据类型,
       CASE WHEN T3.PMDPFID LIKE '0104%' THEN 'Y'ELSE 'N' END 是否阶梯,
       T2.MIBFID 表册编号,
       '0' 核定水量,
       FGETPRICENAME(T3.PMDPFID) 用水性质名称
  FROM  METERINFO T2,  PRICEMULTIDETAIL T3
 WHERE T2.MIID = T3.PMDMID
   AND exists (select 1
          from pad_bfids tt
         where tt.c1 = I_BFRPER
           and tt.c2 = t2.Mibfid)) 
UNION ALL

SELECT 'insert into mixtureinfo(ciid,miid,pfid,rate_scale,ratify_sl,data_type,isstep,pfname,bfid) values(' || 
    '''' || 用户编号 || ''',' || 
    '''' || 水表编号 || ''',' ||
    '''' || 用水性质||''','||
    '''' || 混合比例||''','||
    ''''||核定水量||''','||
    ''''||数据类型||''','||
    ''''||是否阶梯||''','||
    ''''||用水性质名称||''','||
    ''''||表册编号||''')'
  FROM (SELECT T2.MICID 用户编号,
       T2.MIID 水表编号,
     --  T3.RAPFID 用水性质,
       '' 混合比例,
       '2' 数据类型,
     --  CASE WHEN T3.RAPFID LIKE '0104%' THEN 'Y'ELSE 'N' END 是否阶梯,
       'N' 是否阶梯,
       T2.MIBFID 表册编号,
      -- T3.rasl  核定水量,
      0  核定水量,
    --   fn_get_pfname(T3.RAPFID) 用水性质名称
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

  --历史抄表库信息 1年历史抄表记录
  SELECT 'insert into history(ciid,miid,position,month,readdate,scode,ecode,usenum,pfname,sfje,qfje) values(' || 
    '''' || 单位号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 表位||''','||
    '''' || 抄表月份||''','||
    '''' || 抄表日期||''','||
    ''''||起码||''','||
    ''''||止码||''','||
    ''''||水量||''','||
    ''''||用水性质名称||''','||
    ''''||水费||''','||
    ''''||欠费金额||''')'
  FROM (SELECT MAX(CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END) 单位号,
       T3.RLMID 户号,
       T3.RLMONTH 抄表月份,
       TO_CHAR(MAX(T3.RLRDATE),'yyyy-MM-dd') 抄表日期,
       MAX(T2.Miname)   户名,
       MAX(T2.Miadr)  用户地址,
     decode( MAX(T2. MISIDE),'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
       --MAX(T2.MIPOSITION)表位,
       MAX(T3.RLSCODE) 起码,
       MAX(T3.RLECODE) 止码,
       SUM(T3.RLSL) 水量,
       sum(t3.rlje) 水费,
       SUM(CASE WHEN T3.RLPAIDFLAG ='N' THEN T3.RLJE ELSE 0 END) 欠费金额,
       MAX(T2.MIPFID) 用水性质名称
  FROM METERINFO T2, RECLIST T3,BOOKFRAME t4
 WHERE T2.MIID = T3.RLMID
   AND T3.RLREVERSEFLAG='N'  --未冲正
   and t3.rlbadflag <> 'Y' --不是呆坏账
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
   
   SELECT 'DELETE FROM payment_his '  FROM DUAL  --缴费历史信息
   UNION ALL
  SELECT 'insert into payment_his(MIID,CIID,PDATETIME,PPOSITION,MICHARGETYPE,PPAYMENT,PPAYEE,PPAYWAY) values(' || 
    '''' || 水表编号 || ''',' || 
    '''' || 用户编号 || ''',' ||
    '''' || 缴费日期||''','||
    '''' || 缴费机构||''','||
    '''' || 缴费方式||''','||
    ''''||付款金额||''','||
    ''''||收费员||''','||
    ''''||付款方式||''')'
    from 
      ( SELECT MAX(MI.MICID) 水表编号, --水表编号 VARCHAR2(10)
       MAX(MI.MICID) 用户编号, --用户编号 VARCHAR2(10) 
       to_char(MAX(PM.PDATETIME),'yyyy-mm-dd hh24:mm:ss') 缴费日期, --发生日期 VARCHAR2(20)
       MAX(FGETSYSMANAFRAME(PM.PPOSITION) ) 缴费机构, --缴费机构 VARCHAR2(60)
        DECODE(MAX(MI.MICHARGETYPE), 'X', '坐收', 'M', '走收') 缴费方式, --缴费方式 VARCHAR2(20)
        SUM(PM.PPAYMENT) 付款金额, --付款金额 NUMBER(12,2)
       MAX( FGETOPERNAME(PM.PPAYEE) )收费员, --收费员  VARCHAR2(20) 
       MAX(decode(TRIM(PM.PPAYWAY), 'XJ','现金','DC','倒存','ZP','支票','MZ','抹帐') ) 付款方式     --付款方式VARCHAR2(20)
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
   
   
   --字典信息
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || 字典类型 || ''',' || 
    '''' || 字典CODE || ''',' ||
    '''' || 字典||''','||
    '''' || 备注||''')'
  FROM (
       select '水表口径' 字典类型,mcid||'' 字典CODE,mcname||'' 字典, '' 备注 from METERCALIBER
       UNION ALL
       select '水表状况' 字典类型,sflid 字典CODE,sflname 字典,sflflag1 备注 from sysfacelist2 t     /* where t.sflid  not in ('13','14','15')*/
      UNION ALL
      -- select '水表位置' 字典类型,sclid 字典CODE,sclvalue 字典,decode(sclgroup,'01','室内','02','室外') 备注 from syscharlist  where scltype ='表位'   
      select '水表位置' 字典类型,sclid 字典CODE,sclvalue 字典,case  when sclgroup in  ('01','02','08','09','10','11','13') then '室内' else  '室外' end 备注 from syscharlist  where scltype ='表位'   
         UNION ALL
       select '营销员' 字典类型,'编号' 字典CODE,t.oaid 字典,''备注 from operaccnt t where  (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select '营销员' 字典类型,'名称' 字典CODE,t.oaname 字典,''备注 from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select '营销员' 字典类型,'密码' 字典CODE,UPPER(t.oapwd) 字典,''备注 from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select '营销员手机号码' 字典类型,oatel 字典CODE,t.oatel 字典,''备注 from operaccnt t where (t.OAID =I_BFRPER or  t.OAGH=I_BFRPER)
       UNION ALL
       select '营销员' 字典类型, '营业所' 字典CODE,   b.smfpid   字典,''备注   --记录抄表员营业所
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
       UNION ALL
       select 字典类型, 字典CODE,字典,备注 from datadesign where  字典类型 not in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件','打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔','手机版本更新内容','手机抄表审核全选功能','手机抄表程序安装路径','待选服务器','数据下载URL' )
              AND NVL(备注,'NULL') <> 'XXXXXXXXXX' and 字典 not in ('营业所上传图片文件服务器IP地址')
       UNION ALL
              SELECT 字典类型, 字典CODE,字典,备注
          FROM DATADESIGN
         WHERE 字典类型 = '手机版本更新内容'
           and 字典code = (select max(字典code)
                           from DATADESIGN
                          WHERE 字典类型 = '手机版本更新内容') 
      UNION ALL
       select '用户(水表)状态' 字典类型,SMSID 字典CODE,SMSNAME 字典,''备注 FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 添加水表状态
       UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件','打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔'  )
       UNION ALL 
       select c.字典类型,substrb(c.字典CODE,1,instr(c.字典CODE,':') - 1),c.字典,  substrb(c.字典CODE,instr(c.字典CODE,':') + 1 ,length(c.字典CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ( '数据下载URL')
      UNION ALL 
       select c.字典类型, c.字典CODE, substrb(c.字典,1,instr(c.字典,':') - 1) ,  substrb(c.字典,instr(c.字典,':') + 1 ,length(c.字典))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ( '待选服务器' ) 
       UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.字典类型
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and  c.字典  in ('营业所上传图片文件服务器IP地址' ))
   /*    SELECT '待选服务器' 字典类型,'TELECOM' 字典CODE,'10.10.10.158' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '待选服务器' 字典类型,'UNICOM' 字典CODE,'10.10.10.158' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '待选服务器' 字典类型,'WIFI' 字典CODE,'10.10.10.158' 字典,'8080'备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158' 字典CODE,'TELECOM' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158' 字典CODE,'UNICOM' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158'  字典CODE,'WIFI' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '是否实时上传' 字典类型,'0' 字典CODE,'是否实时上传' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '提交数据时间间隔' 字典类型,'120' 字典CODE,'时间间隔' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '水费短信' 字典类型,'01' 字典CODE,'尊敬的用户你好，用户编号：yhh，您本次用水量sl立方米，综合水费je元。' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '本月是否下载'字典类型,TO_CHAR(SYSDATE,'yyyy-MM') 字典CODE,'本月是否下载' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '打印纸张数' 字典类型,'1' 字典CODE,'' 字典,''备注 FROM DUAL
       UNION ALL
       SELECT '打印标题' 字典类型,'自来水缴费通知单' 字典CODE,'' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '突高突低' 字典类型,'0.3' 字典CODE,'波动比例' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '突高突低' 字典类型,'50' 字典CODE,'基量' 字典,'' 备注 FROM DUAL*/
  union all
   select 'DELETE FROM telcheck' from dual
   union all
    SELECT 'insert into telcheck(tcmid,tcmonth, tctype,tcresult,tcnote,tcuser, tcdate,tcphoto_mk,tcphoto_path,tcchk_mk,tcchk_user,tcchk_date,tcinsdate) values('|| 
    ''''||用户编号||''','|| 
    ''''||巡检月份||''','||
    ''''||巡检类别||''','||
    ''''||巡检结果||''','||
    ''''||巡检备注||''','|| 
    ''''||巡检人||''','||
    ''''||巡检时间||''','||
    ''''||是否拍照||''','|| 
    ''''||照片路径 ||''','|| 
    ''''||巡检审核注记||''','||
    ''''||巡检审核人||''','||
    ''''||巡检审核日期||''','||  
    ''''||资料新增时间||''')'
    from (select tcmid 用户编号,
    tcmonth 巡检月份, 
    tctype 巡检类别,
    tcresult 巡检结果,
    tcnote 巡检备注,
    tcuser 巡检人,  
    to_char(tcdate,'yyyy-mm-dd hh24:mI:ss') 巡检时间,
    tcphoto_mk 是否拍照,
    tcphoto_path 照片路径,
    tcchk_mk 巡检审核注记,
    tcchk_user 巡检审核人,
    to_char(tcchk_date,'yyyy-mm-dd hh24:mI:ss') 巡检审核日期,
    to_char(tcinsdate,'yyyy-mm-dd hh24:mI:ss')  资料新增时间
    from meterinfo mit,telcheck,bookframe 
    where miid=tcmid and mit.mismfid =BFSMFID and bfid=mibfid and BFRPER =I_BFRPER  )
    
    UNION ALL
    SELECT 'DELETE FROM pic_his '  FROM DUAL  --拍照历史记录
       UNION ALL
      SELECT 'insert into pic_his(ciid,pmtime,pmper) values(' || 
        '''' || 用户编号 || ''',' || 
        '''' || 上传时间 || ''',' ||
        ''''||上传人员||''')'
        from 
          (SELECT m.ciid 用户编号, --水表编号 VARCHAR2(10) 
           to_char(m.pmtime,'yyyy-mm-dd hh24:mi:ss') 上传时间, --发生日期 VARCHAR2(20)
           m.pmpname 上传人员
      FROM meterpicture m,meterinfo,bookframe,meterreadhis
     WHERE m.mpmiid=miid and mpmiid=mrmid and mibfid=bfid and mismfid =BFSMFID and mrifrec<>'N'and to_char(m.pmtime,'yyyy.mm')= mrmonth and  
      m.pmtime >= add_months(SYSDATE,-12) and bfrper = I_BFRPER /*and mrdatasource <> 'I'*/);

  
  --add 20150320 
  --hb
  --更新当前抄表库发出注记及时间，
  update meterread
     set mroutflag=DECODE(MRREADOK ,'Y','N','N', 'Y') ,  --已经抄表的发出注记为N,不需更新抄表资料，只单独调用算费，因，因f8003如果MRREADOK为Y不会把mroutflag更新为N
         MROUTDATE =sysdate,MROUTID='9'
   where MRRPER =I_BFRPER  /*and
         mrdatasource <> 'I'*/;  --已经抄表的话MRREADOK为Y发出注记mroutflag不需要设为Y，因f8003如果MRREADOK为Y不会把mroutflag更新为N
  
 -- delete from METERINFO_SJCBUP    where miid  in (select mi.miid from meterinfo mi , bookframe bk where mi.mibfid =bk.bfid and bk.BFRPER=I_BFRPER) ;  --每次更新需删除抄表员下水表的更新信息
  
  commit;
  
  
  END;
  
 /*
  * 功能：数据初始化
  * 创建人:曾海洲
  * 创建时间：2014-07-23
  * @表册信息
  * @抄表员编号
  * @返回游标
  */
  procedure DATA_INIT(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) IS
  BEGIN
    
   OPEN O_CURRSOR FOR select 'DELETE FROM datadesign' from dual
   
   UNION ALL
   
   --字典信息
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || 字典类型 || ''',' || 
    '''' || 字典CODE || ''',' ||
    '''' || 字典||''','||
    '''' || 备注||''')'
  FROM (
      select '水表口径' 字典类型,mcid||'' 字典CODE,mcname||'' 字典, '' 备注 from METERCALIBER
       UNION ALL
       select '水表状况' 字典类型,sflid 字典CODE,sflname 字典,sflflag1 备注 from sysfacelist2 t  /*  where t.sflid  not in ('13','14','15')*/
        UNION ALL
       select '水表位置' 字典类型,sclid 字典CODE,sclvalue 字典,decode(sclgroup,'01','室内','02','室外') 备注 from syscharlist  where scltype ='表位'   
       UNION ALL
       select '营销员' 字典类型,'编号' 字典CODE,t.oaid 字典,''备注 from operaccnt t where t.OAID=I_BFRPER  or  t.OAGH=I_BFRPER
       UNION ALL
       select '营销员' 字典类型,'名称' 字典CODE,t.oaname 字典,''备注 from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select '营销员' 字典类型,'密码' 字典CODE,UPPER(t.oapwd) 字典,''备注 from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select '营销员手机号码' 字典类型,oatel 字典CODE,t.oatel 字典,''备注 from operaccnt t where t.OAID=I_BFRPER or  t.OAGH=I_BFRPER
       UNION ALL
       select '营销员' 字典类型, '营业所' 字典CODE,   b.smfpid   字典,''备注   --记录抄表员营业所
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
         and (a.OAID =I_BFRPER  or  a.OAGH=I_BFRPER)
       UNION ALL
       select 字典类型, 字典CODE,字典,备注 from datadesign where  字典类型 not in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件','打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔','手机版本更新内容','手机抄表审核全选功能','手机抄表程序安装路径','待选服务器','数据下载URL')
        AND NVL(备注,'NULL') <> 'XXXXXXXXXX' and 字典 not in ('营业所上传图片文件服务器IP地址')
       UNION ALL
              SELECT 字典类型, 字典CODE,字典,备注
          FROM DATADESIGN
         WHERE 字典类型 = '手机版本更新内容'
           and 字典code = (select max(字典code)
                           from DATADESIGN
                          WHERE 字典类型 = '手机版本更新内容') 
                          
       UNION ALL
       select '用户(水表)状态' 字典类型,SMSID 字典CODE,SMSNAME 字典,''备注 FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 添加水表状态
       UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件' ,'打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔')
    UNION ALL 
       select c.字典类型,substrb(c.字典CODE,1,instr(c.字典CODE,':') - 1),c.字典,  substrb(c.字典CODE,instr(c.字典CODE,':') + 1 ,length(c.字典CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ( '数据下载URL')
      UNION ALL 
       select c.字典类型, c.字典CODE, substrb(c.字典,1,instr(c.字典,':') - 1) ,  substrb(c.字典,instr(c.字典,':') + 1 ,length(c.字典))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and c.字典类型 in ( '待选服务器' ) 
      UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.字典类型
        and (a.OAID =I_BFRPER or  a.OAGH=I_BFRPER)
         and  c.字典  in ('营业所上传图片文件服务器IP地址' )
      /* SELECT '待选服务器' 字典类型,'TELECOM' 字典CODE,'10.10.10.158' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '待选服务器' 字典类型,'UNICOM' 字典CODE,'10.10.10.158' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '待选服务器' 字典类型,'WIFI' 字典CODE,'10.10.10.158' 字典,'8080'备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158' 字典CODE,'TELECOM' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158' 字典CODE,'UNICOM' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '数据下载URL' 字典类型,'10.10.10.158'  字典CODE,'WIFI' 字典,'8080' 备注 FROM DUAL
       UNION ALL
       SELECT '是否实时上传' 字典类型,'0' 字典CODE,'是否实时上传' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '提交数据时间间隔' 字典类型,'120' 字典CODE,'时间间隔' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '水费短信' 字典类型,'01' 字典CODE,'尊敬的用户你好，用户编号：yhh，您本次用水量sl立方米，综合水费je元。' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '本月是否下载'字典类型,TO_CHAR(SYSDATE,'yyyy-MM') 字典CODE,'本月是否下载' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '打印纸张数' 字典类型,'1' 字典CODE,'' 字典,''备注 FROM DUAL
       UNION ALL
       SELECT '打印标题' 字典类型,'自来水缴费通知单' 字典CODE,'' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '突高突低' 字典类型,'0.3' 字典CODE,'波动比例' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '突高突低' 字典类型,'50' 字典CODE,'基量' 字典,'' 备注 FROM DUAL
        UNION ALL
       SELECT '手机参数版本' 字典类型,'0000000001' 字典CODE,'核对手机参数是否与营收系统参数版本是否一致' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '图片参数' 字典类型,'xxx' 字典CODE,'' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '居民报警值' 字典类型,'10-30' 字典CODE,'居民最小、最大水量报警值' 字典,'' 备注 FROM DUAL
        UNION ALL
       SELECT '是否电话件' 字典类型,'0' 字典CODE,'是否选择电话件(1-选择电话件 0-不选择)' 字典,'' 备注 FROM DUAL
        UNION ALL
       SELECT '是否拍照' 字典类型,'1' 字典CODE,'是否允许抄表后不拍照也可以保存成功(1-抄表拍照 0-抄表不拍照)' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '打印预告知通知单' 字典类型,'1' 字典CODE,'是否允许打印预告知通知单(1-打印 0-不打印)' 字典,'' 备注 FROM DUAL
       UNION ALL
       SELECT '抄表审核' 字典类型,'1' 字典CODE,'是否必须进行抄表审核(1-必须抄表审核 0-不必须抄表审核)' 字典,'' 备注 FROM DUAL*/
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
    --抄表员编号
    v_count number;
  BEGIN
     
/*    --I_BFIDS存入临时表
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
 
          
  insert into pad_bfids(c1,c2)values(I_BFRPER,v_temp_str);  --抄表员先写入临时表
       
  
    OPEN O_CURRSOR FOR 
   select  ' update custinfo   set lastjfdate='||  
                 '''' || 上次抄表日期 || ''',' ||
                'apply_flag='|| 
                  '''' || 工单申请标志 || ''',' ||
               'issf='||      
               '''' || 算费注记 || ''',' ||   
             'cusenum='||  
               '''' || 水量 || ''',' ||
              'sfjg='||  
               '''' || 水费单价 || ''',' ||
              'psfjg='||  
               '''' || 污水费单价 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
              'psfje='||  
               '''' || 污水费 || ''',' ||
               'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'total_money='||  
               '''' || 总费用 || ''',' ||   
               'saving='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上期预存金额 || ''',' ||   
               'chargetotal='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 本期预存金额 || ''',' ||  
               
                'processflag='||    
               '''' || 审核标志 || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || 户号 || ''''  
   from ( select  to_char(mr.MRRDATE,'yyyy-mm-dd') 上次抄表日期, 
                 '已审核'  审核标志,
                     max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N' and nvl(mr.mrdatasource,'X') <> '9'  THEN  mi.MISAVING -  nvl(VIEW1.RLJE,0)     -- 非手机抄表但有算费
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') = '9' THEN  mr.MRPLANJE02    -- 手机抄表算费
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                    --    when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN 0   --  固定量每次打印调用此处为0
                     when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN  nvl(mr.MRPLANJE03,0)--20150414因固定量、合收表打印算费有问题 
                       when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                        when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
               
                    decode(nvl(trim(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请')工单申请标志,
                    NVL(mr.MRPLANSL,0) 水量,
                   -----zhw20160415修改最新成最新单价
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  水费单价,
                 fun_getjtdqdj( max(MIPFID), max(MIPRIID) , max(miid) ,'1') 水费单价,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     污水费单价,
               fgetwsf(max(mipfid)) 污水费单价, 
                -----------------------------------------------------------end
                  mr.MRYEARJE01 水费 ,
                   mr.MRYEARJE02 污水费,
                   mr.MRYEARJE03 其他费用,
                   mr.MRPLANJE01 总费用,
                  'Y'  算费注记,
                  mr.MRMID 户号 
                  FROM METERREAD mr,meterinfo mi,   ( SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1, (                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
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
                         mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --抓取临时档
                         group by  to_char(mr.MRRDATE,'yyyy-mm-dd')  , 
                 '已审核'   , 
                    decode(nvl(trim(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') ,
                    NVL(mr.MRPLANSL,0)  ,
                  DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)   ,
                DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)      ,
                  mr.MRYEARJE01   ,
                   mr.MRYEARJE02  ,
                   mr.MRYEARJE03  ,
                   mr.MRPLANJE01  ,
                  mr.MRMID   
                  
                        )  --审核  
       union all
     select  ' update  meterinfo   set  ecode='||   
               '''' || 本次指针 || ''',' ||
              'musenum='||  
               '''' || 水量 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
               'psfje='||  
               '''' || 污水费 || ''',' ||
              'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'sfjg='||  
               '''' || 水费单价 || ''',' ||              
               'psfjg='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 污水费单价 || ''',' ||    
               'total_money='||  
               '''' || 总金额 || '''' ||  
                 ' where miid=  '||
                  '''' || 户号 || ''''  
  
                  
      from ( select  mr.MRECODE 本次指针,  
                  mr.MRPLANSL  水量, 
                  mr.MRYEARJE01 水费 ,
                   mr.MRYEARJE02 污水费,
                   mr.MRYEARJE03 其他费用,
                /*  DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  水费单价,
                DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     污水费单价,*/
                
                -----zhw20160415修改最新成最新单价
                 --DECODE( NVL(mr.MRPLANSL,0), 0,0, mr.MRYEARJE01/ mr.MRPLANSL)  水费单价,
                 fun_getjtdqdj(  MIPFID ,  MIPRIID  ,  miid ,'1') 水费单价,
                --DECODE(  NVL(mr.MRPLANSL,0),0,0, mr.MRYEARJE02/ mr.MRPLANSL)     污水费单价,
               fgetwsf( mipfid ) 污水费单价, 
                -----------------------------------------------------------end
                   mr.MRPLANJE01 总金额,
                  mr.MRMID 户号 
                  FROM METERREAD mr,meterinfo mi
                  WHERE mr.MRMID =mi.miid and  mr.MRRPER=  I_BFRPER and ( mr.MRDATASOURCE ='9' or mr.mrdatasource = '1' /* byj 2016.06 加入mrdatasource = '1' */)  --and mr.mrreadok = 'Y' 
                       and mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --抓取临时档
                        )  --审核 因出现内勤退审未通过接着抄表员更新，数据更新起码水量这些都没有，然后内勤选通过，这些资料就没法更新了    
 
         UNION ALL
         
         
     select  ' update custinfo   set apply_flag='||   
                  '''' || 工单申请标志 || ''',' ||
                 'issf='||      
               '''' || 算费注记 || ''',' ||   
                'processflag='||    
               '''' || 审核标志 || '''' || 
               ' where mrid=  '||
                  '''' || 户号 || ''''  
             from ( select   '待审核'  审核标志,
                             'Y'  算费注记,
                              decode(nvl(trim(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请')工单申请标志,
                            mr.MRMID 户号 
                            FROM METERREAD mr,meterinfo mi
                            WHERE mr.MRMID =mi.miid and  mr.MRRPER=  I_BFRPER and mr.MRDATASOURCE ='9' and mr.mrreadok = 'X' 
                                 and mr.mrmid in (select miid from METERINFO_SJCBUP where UPDATE_MK ='2' )   --抓取临时档
                                  )  --待审核也需要更新,因为内勤有可能切换审核注记。从通过到未通过或到未审核，切来切去 
          UNION ALL                            
    --下述为审核不通过的抄表资料
  select  ' update custinfo   set  cbzk='||   
              '''' || 查表状况 || ''',' ||
              'codesource='||  
               '''' || 示数来源 || ''',' ||
             -- 'cusenum='||  
          --     '''' || 水量 || ''',' ||
              'sfjg='||  
               '''' || 水费单价 || ''',' ||
              'psfjg='||  
               '''' || 污水费单价 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
              'psfje='||  
               '''' || 污水费 || ''',' ||
               'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'total_money='||  
               '''' || 总费用 || ''',' ||              
               'saving='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上期预存金额 || ''',' ||   
               'chargetotal='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 本期预存金额 || ''',' ||  
               'sendflag='||  
               '''' || 发送标志 || ''',' ||
               'memo='||  
               '''' || 用户备注 || ''',' ||
                'isprint='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 打印 || ''',' || 
               'lastjfdate='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上次抄表日期 || ''',' ||  
               'ciname='||    
               '''' || 户名 || ''',' ||  
               'ciaddr='||   
               '''' || 用户地址 || ''',' ||  
               'linkman='||    
               '''' || 联系人 || ''',' ||  
               'hometel='||      
               '''' || 联系电话 || ''',' ||  
               'mobiletel='||      
               '''' || 移动电话 || ''',' ||  
               'chargetype='||      
               '''' || 用户类型 || ''',' ||  
               'pfid='||      
               '''' || 用水性质 || ''',' ||  
               'pfname='||      
               '''' || 用水性质名称 || ''',' ||  
               'rorder='||      
               '''' || 抄表次序 || ''',' ||  
               'mans='||      
               '''' || 人口数 || ''',' ||   
               'MICOMMUNITY='||      
               '''' || 小区号 || ''',' ||   
                'MICOMMUNITY_NAME='||      
               '''' || 小区名称 || ''',' ||   
                'MISEQNO='||      
               '''' || 帐卡号 || ''',' ||   
                  'MILH='||      
               '''' || 楼号 || ''',' ||   
                'MIDYH='||      
               '''' || 单元号 || ''',' ||    
                'issf='||      
               '''' || 算费注记 || ''',' ||   
                'readdate='||      
               '''' || 本次抄表日期 || ''',' ||    
                'BARCODE='||      
               '''' || 条形码 || ''',' ||     
                'apply_ciname='||      
               '''' || 新户名 || ''',' ||   
                               'apply_pfid='||      
               '''' || 新用水性质 || ''',' ||   
                               'apply_pfname='||      
               '''' || 新用水性质名称 || ''',' ||   
                               'apply_flag='||      
               '''' || 工单申请标志 || ''',' ||    
              'processflag='||  
               '''' || 审核标志 || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || 户号 || ''''  
        from (  select '未查' 查表状况,
                        '见表' 示数来源,
                      --   null 水量,
                     --  mr.MRSL 水量,
                        null 水费单价,
                        null 污水费单价,
                        null 水费,
                      null 污水费,
                     null 其他费用,
                     null 总费用,  --应收合计
             max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') <> '9'  THEN   mi.MISAVING -  nvl(VIEW1.RLJE,0)  -- 不是手机抄表
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X')= '9'  THEN   mr.MRPLANJE02  --手机抄表
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN mr.MRPLANJE03  --  固定量每次打印调用此处为0
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
                          
                    null 发送标志,
                       mi.MIMEMO  用户备注,

                        null 打印,
                        TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    上次抄表日期,
                      to_char( mr.MRRDATE ,'yyyy-mm-dd hh24:mi:ss')   本次抄表日期, 
                      --  '未处理' 审核标志,
                  MAX(CASE when  mr.MRREADOK ='Y'  THEN '已审核'
                      when  mr.MRREADOK ='N'  THEN '未处理'
                      when  mr.MRREADOK ='X'  THEN '待审核'
                      when  mr.MRREADOK ='U'  THEN '未通过'
                      else '未处理' END) 审核标志,
                      mi.MINAME  户名, 
                       mi.MIADR  用户地址,

                    ci.CICONNECTPER  联系人,
                        ci.citel1  联系电话,
                        ci.CIMTEL 移动电话, 
                        mi.mICHARGETYPE  用户类型, --20150308
                        mi.MIPFID  用水性质,
                        FGETPRICENAME( mi.MIPFID ) 用水性质名称, 
                        mr.MRRORDER  抄表次序, --20150308
                        mi.MIUSENUM  人口数, 
                        mi.MICOMMUNITY  小区号,
                        mi.MISEQNO 帐卡号,
                        mi.MILH 楼号,
                        mi.MIDYH 单元号,
                        t4.diname 小区名称 ,
                        mr.MRMID  户号,
                        md.barcode 条形码,
               decode(nvl(max(MIYL5),'N'),'N',   MAX(mi.MINAME)

 , MAX(MIJD)  ) 新户名,
              decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MIPFID), MAX(miyl6)  ) 新用水性质,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(mi.MIPFID)),FGETPRICENAME(MAX(miyl6)) )新用水性质名称,
              decode(nvl(max(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') 工单申请标志,
                      MAX(CASE when  mr.MRREADOK ='Y' or mr.MRREADOK ='X'  THEN 'Y'  --待审核、已出帐
                              when  mr.MRREADOK ='N'  or mr.MRREADOK ='U'   THEN 'N'  --未处理 、未通过
                              else 'N' END) 算费注记 
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
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --抓取已经算费的
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
                 and (mr.mrreadok = 'N'  or mr.mrreadok = 'U'   ) --未处理、未通过
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
               t4.diname  ,mr.MRMID , md.barcode   )      -- N审核不能过的抄表资料
 
           union all 
       --下述为不存在抄表库的有更新用户信息资料
  select  ' update custinfo   set  cbzk='||   
              '''' || 查表状况 || ''',' ||
              'codesource='||  
               '''' || 示数来源 || ''',' ||
              'cusenum='||  
               '''' || 水量 || ''',' ||
              'sfjg='||  
               '''' || 水费单价 || ''',' ||
              'psfjg='||  
               '''' || 污水费单价 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
              'psfje='||  
               '''' || 污水费 || ''',' ||
               'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'total_money='||  
               '''' || 总费用 || ''',' ||              
               'saving='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上期预存金额 || ''',' ||   
               'chargetotal='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 本期预存金额 || ''',' ||  
               'sendflag='||  
               '''' || 发送标志 || ''',' ||
               'memo='||  
               '''' || 用户备注 || ''',' ||
                'isprint='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 打印 || ''',' || 
               'lastjfdate='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上次抄表日期 || ''',' ||  
               'ciname='||    
               '''' || 户名 || ''',' ||  
               'ciaddr='||   
               '''' || 用户地址 || ''',' ||  
               'linkman='||    
               '''' || 联系人 || ''',' ||  
               'hometel='||      
               '''' || 联系电话 || ''',' ||  
               'mobiletel='||      
               '''' || 移动电话 || ''',' ||  
               'chargetype='||      
               '''' || 用户类型 || ''',' ||  
               'pfid='||      
               '''' || 用水性质 || ''',' ||  
               'pfname='||      
               '''' || 用水性质名称 || ''',' ||  
               'rorder='||      
               '''' || 抄表次序 || ''',' ||  
               'mans='||      
               '''' || 人口数 || ''',' ||   
               'MICOMMUNITY='||      
               '''' || 小区号 || ''',' ||   
                'MICOMMUNITY_NAME='||      
               '''' || 小区名称 || ''',' ||   
                'MISEQNO='||      
               '''' || 帐卡号 || ''',' ||   
                  'MILH='||      
               '''' || 楼号 || ''',' ||   
                'MIDYH='||      
               '''' || 单元号 || ''',' ||    
                'issf='||      
               '''' || 算费注记 || ''',' ||   
                'readdate='||      
               '''' || 本次抄表日期 || ''',' ||    
                'BARCODE='||      
               '''' || 条形码 || ''',' ||     
                'apply_ciname='||      
               '''' || 新户名 || ''',' ||   
                               'apply_pfid='||      
               '''' || 新用水性质 || ''',' ||   
                               'apply_pfname='||      
               '''' || 新用水性质名称 || ''',' ||   
                               'apply_flag='||      
               '''' || 工单申请标志 || ''',' ||    
              'processflag='||  
               '''' || 审核标志 || '''' ||
               -- where
               ' where mrid=  '||
                  '''' || 户号 || ''''  
        from (   select '未查' 查表状况,
                        '见表' 示数来源,
                        null 水量,
                        null 水费单价,
                        null 污水费单价,
                        null 水费,
                      null 污水费,
                     null 其他费用,
                     null 总费用,  --应收合计
                   /*   MAX(mr.MRYEARJE01) 水费,
                      MAX(mr.MRYEARJE02)  污水费,
                      MAX(mr.MRYEARJE03) 其他费用,
                      MAX(mr.MRPLANJE01) 总费用,  --应收合计*/
                       --   sum(mi.MISAVING) - sum(nvl(VIEW1.RLJE,0)) 上期预存金额,
               --    decode( MAX(mr.MRIFREC),'Y',MAX(mr.MRPLANJE02),  sum(mi.MISAVING) - sum(nvl(VIEW1.RLJE,0))  ) 上期预存金额,--当已计费则抓取之前算过费用上期预存金额否则上期预存金额是新的
/*            max (case when mi.mistatus in ('29','30') and mr.MRREADOK ='Y' THEN  mi.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN mi.mistatus NOT in ('29','30') and mr.MRREADOK ='Y'  and mr.mrface='01' THEN  mr.MRPLANJE02 
                  else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) 上期预存金额, 
            decode( MAX(mr.MRREADOK),'N', 0,decode( max(mr.mrface),'01', MAX(mr.MRPLANJE03),0) ) 本期预存金额, */
            
             max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X') <> '9'  THEN   mi.MISAVING -  nvl(VIEW1.RLJE,0)  -- 不是手机抄表
                        when  mr.mrifrec ='N' and  mi.mistatus  not in ('29','30')   AND  mr.MRREADOK <> 'N'  and nvl(mr.mrdatasource,'X')= '9'  THEN   mr.MRPLANJE02  --手机抄表
                        when  mr.mrifrec ='N' and  mi.mistatus   in ('29','30') then  mi.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  mr.mrifrec ='N' and mr.MRREADOK = 'N' then mi.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   mi.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when mr.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  mi.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when mr.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  mi.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND   mi.mistatus  in ('29','30')   THEN mr.MRPLANJE03  --  固定量每次打印调用此处为0
                        when  mr.mrifrec ='N' and  mr.MRREADOK <> 'N'  AND mr.mrface='01'  and   mi.mistatus not in ('29','30')   THEN mr.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  mr.mrifrec ='N' and  mr.mrface <> '01' then mi.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  mr.mrifrec ='N' and  mr.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
                          
                    null 发送标志,
                     mi.MIMEMO  用户备注,
                        null 打印,
                        TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    上次抄表日期,
                      to_char( mr.MRRDATE ,'yyyy-mm-dd hh24:mi:ss')   本次抄表日期,
                        
                      --  '未处理' 审核标志,
                  MAX(CASE when  mr.MRREADOK ='Y'  THEN '已审核'
                      when  mr.MRREADOK ='N'  THEN '未处理'
                      when  mr.MRREADOK ='X'  THEN '待审核'
                      when  mr.MRREADOK ='U'  THEN '未通过'
                      else '未处理' END) 审核标志,
  
                       mi.MINAME  户名, 
                      mi.MIADR  用户地址,
                       ci.CICONNECTPER  联系人,
                      ci.citel1  联系电话,
                       ci.CIMTEL  移动电话, 
                        mi.mICHARGETYPE  用户类型, --20150308
                        mi.MIPFID  用水性质,
                        FGETPRICENAME( mi.MIPFID ) 用水性质名称, 
                        mi.mirorder 抄表次序, --没有做抄表的话，抄表次序选择METERINFO BY RALPH 20150430
                       -- mr.MRRORDER  抄表次序, --20150308
                        mi.MIUSENUM  人口数, 
                        mi.MICOMMUNITY 小区号,
                        mi.MISEQNO 帐卡号,
                    mi.MILH 楼号,
                      mi.MIDYH 单元号,
                       t4.diname 小区名称 ,
                        MI.MIID  户号,
                        md.barcode 条形码,
               decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MINAME), MAX(MIJD)  ) 新户名,
              decode(nvl(max(MIYL5),'N'),'N',MAX(mi.MIPFID), MAX(miyl6)  ) 新用水性质,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(mi.MIPFID)),FGETPRICENAME(MAX(miyl6)) )新用水性质名称,
              decode(nvl(max(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') 工单申请标志,
                      MAX(CASE when  mr.MRREADOK ='Y' or mr.MRREADOK ='X'  THEN 'Y'  --待审核、已出帐
                              when  mr.MRREADOK ='N'  or mr.MRREADOK ='U'   THEN 'N'  --未处理 、未通过
                              else 'N' END) 算费注记 
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
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --抓取已经算费的
               WHERE  mi.miid= mr.MRMID(+) 
                 and  mi.miid = ci.ciid
                 and  mi.miid = md.mdmid
                 and mi.mibfid =bf.bfid
                 and MI.miid = VIEW1.RLMID(+)
                 and mr.mrid =view2.rlmrid(+)
                 AND bf.BFRPER =I_BFRPER
                 and mi.MICOMMUNITY=t4.diid(+)
                  and   mi.mibfid is not null 
                  and mr.mrid is null   --未抄表的数据更新 
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
     --下述更新抄表库 --未处理、未通过 的资料                
     select  ' update  meterinfo   set  sbzk='||   
              '''' || 水表状况 || ''',' ||
               'MRFACE_NAME='||  
               '''' || 表况的中文名 || ''',' || 
              'prdate='||  
               '''' || 上次抄表日期 || ''',' ||
              'lastreaddate='||  
               '''' || 上次抄表日期1 || ''',' ||
              'scode='||  
               '''' || 上次指针 || ''',' ||
              'ecode='||  
               '''' || 本次指针 || ''',' ||
              'musenum='||  
               '''' || 水量 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
               'psfje='||  
               '''' || 污水费 || ''',' ||
              'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'sfjg='||  
               '''' || 水费单价 || ''',' ||              
               'psfjg='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 污水费单价 || ''',' ||    
               'mrthreesl='||  
               '''' || 三月均量 || ''',' ||
               'total_money='||  
               '''' || 总金额 || ''',' ||
                'lastcode='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上次抄表水量 || ''',' || 
                               'miPersons='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 人口数 || ''',' ||  
                               'pfid='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 用水性质 || ''',' || 
                               'pfname='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 用水性质名称 || ''',' || 
                               'MISMFID='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 营业所代号 || ''',' || 
                               'MISMFID_NAME='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 营业所说明 || ''',' || 
                               'MICHARGETYPE='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 收费方式代号 || ''',' || 
                               'MICHARGETYPE_NAME='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 收费方式说明 || ''',' || 
                               'MIPRIID='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 合收表主表号 || ''',' || 
                               'MIPRIFLAG='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 合收表标志 || ''',' || 
                               'DQSFH='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 地区塑封号 || ''',' || 
                               'DQGFH='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 地区钢封号 || ''',' || 
                               'JCGFH='||     --(大于等于0为预存  小于0就是欠费)
                '''' || 稽查刚封号 || ''',' || 
                               'BARCODE='||     --(大于等于0为预存  小于0就是欠费)
                '''' || 条形码 || ''',' || 
                                'qfh='||     --(大于等于0为预存  小于0就是欠费)
                '''' || 铅封号 || ''',' ||  
                             'MISTATUS='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 水表状态 || ''',' || 
                               'IFDZSB='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 倒表标志 || ''',' || 
                               'MICLASS='||     --(大于等于0为预存  小于0就是欠费)
                  '''' || 总分表标志 || ''',' || 
                               'MIPID='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 总表编号 || ''',' ||  
                              'position='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 表位 || ''',' ||  
                             'brand='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 厂牌 || ''',' ||  
                            'caliber='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 口径 || ''',' ||  
                           'nameplate='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 表身号 || ''',' ||  
                           'metertype='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 水表类型 || ''',' ||  
                        'cbmemo='||  
                  '''' || 抄表备注 || '''' ||
               -- where
               ' where miid=  '||
                  '''' || 户号 || ''''  
        from (  select '01' 水表状况,
                     '正常' 表况的中文名,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    上次抄表日期,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')     上次抄表日期1,
                    --byj edited 2016.6.16     
                    --mr.MRSCODE   上次指针,
                    mi.mircode 上次指针,
                    --  null 本次指针,
                      mr.MRECODE 本次指针,
                      
                   --  null 水量,
                      mr.MRSL 水量,
                     null 水费,
                     null 污水费,
                 --    mr.MRYEARJE01 水费,
               --      mr.MRYEARJE02 污水费,
                     null 水费单价,
                     null 污水费单价,
                     mr.MRTHREESL 三月均量,
                     null 其他费用,
                     null 总金额,
                --     mr.MRYEARJE03 其他费用,
                --     mr.MRPLANJE01 总金额,
 
                      mr.MRLASTSL  上次抄表水量,
                    DECODE(mr.MRREADOK,'U',mr.MRCHKRESULT, mr.MRMEMO) 抄表备注,   
                        mi.MIUSENUM 人口数,
                         mi.mipfid 用水性质, 
                         FGETPRICENAME(mi.mipfid) 用水性质名称, 
                       --  T4.BFRCYC 抄表周期,
                         mi.MISMFID 营业所代号,
                         fgetsmfname(mi.MISMFID ) 营业所说明,
                          mi.MICHARGETYPE 收费方式代号,
                          decode( mi.MICHARGETYPE,'X','坐收','M','走收') 收费方式说明, 
                           mi.MIPRIID 合收表主表号,
                           mi.MIPRIFLAG 合收表标志,
                           md.QFH 铅封号,
                            md.DQSFH 地区塑封号,
                          md.DQGFH 地区钢封号,
                          md.JCGFH 稽查刚封号,
                          md.BARCODE 条形码,
                           mi.MISTATUS 水表状态,
                           md.IFDZSB 倒表标志,
                           mi.MICLASS 总分表标志,
                          nvl(mi.MIPID,mi.miid)  总表编号,
                        --   mi.MIPOSITION 表位,
                          decode( mi.MISIDE ,'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
                           md.MDBRAND 厂牌,
                          md.MDCALIBER 口径, 
                        --   md.MDNO 表身号,
                         substrb(md.MDNO,1,13) 表身号,
                           mi.MILB  水表类型, 
                           mr.MRMID 户号
                FROM METERREAD mr,meterinfo mi ,meterdoc md 
               WHERE   mr.MRMID=mi.miid 
                 and mr.mrmid =md.mdmid
                 and mr.MRRPER =I_BFRPER
                  and   mi.mibfid is not null 
                 and NVL(mr.MROUTID,'X') ='9'
                 and mi.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  ) 
                 and  (mr.mrreadok = 'N'  or mr.mrreadok = 'U'   )    )      --未处理、未通过 
                 
           union all 
           
     --下述更新没有存在抄表库中的水表信息               
     select  ' update  meterinfo   set  sbzk='||   
              '''' || 水表状况 || ''',' ||
               'MRFACE_NAME='||  
               '''' || 表况的中文名 || ''',' || 
              'prdate='||  
               '''' || 上次抄表日期 || ''',' ||
              'lastreaddate='||  
               '''' || 上次抄表日期1 || ''',' ||
              'scode='||  
               '''' || 上次指针 || ''',' ||
              'ecode='||  
               '''' || 本次指针 || ''',' ||
              'musenum='||  
               '''' || 水量 || ''',' ||
              'sfje='||  
               '''' || 水费 || ''',' ||
               'psfje='||  
               '''' || 污水费 || ''',' ||
              'szyfje='||  
               '''' || 其他费用 || ''',' ||
               'sfjg='||  
               '''' || 水费单价 || ''',' ||              
               'psfjg='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 污水费单价 || ''',' ||    
               'mrthreesl='||  
               '''' || 三月均量 || ''',' ||
               'total_money='||  
               '''' || 总金额 || ''',' ||
                'lastcode='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 上次抄表水量 || ''',' || 
                               'miPersons='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 人口数 || ''',' ||  
                               'pfid='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 用水性质 || ''',' || 
                               'pfname='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 用水性质名称 || ''',' || 
                               'MISMFID='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 营业所代号 || ''',' || 
                               'MISMFID_NAME='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 营业所说明 || ''',' || 
                               'MICHARGETYPE='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 收费方式代号 || ''',' || 
                               'MICHARGETYPE_NAME='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 收费方式说明 || ''',' || 
                               'MIPRIID='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 合收表主表号 || ''',' || 
                               'MIPRIFLAG='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 合收表标志 || ''',' || 
                               'DQSFH='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 地区塑封号 || ''',' || 
                               'DQGFH='||     --(大于等于0为预存  小于0就是欠费)
               '''' || 地区钢封号 || ''',' || 
                               'JCGFH='||     --(大于等于0为预存  小于0就是欠费)
                '''' || 稽查刚封号 || ''',' || 
                               'BARCODE='||     --(大于等于0为预存  小于0就是欠费)
                '''' || 条形码 || ''',' || 
                        'qfh='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 铅封号 || ''',' ||  
                               'MISTATUS='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 水表状态 || ''',' || 
                               'IFDZSB='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 倒表标志 || ''',' || 
                               'MICLASS='||     --(大于等于0为预存  小于0就是欠费)
                  '''' || 总分表标志 || ''',' || 
                               'MIPID='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 总表编号 || ''',' ||  
                              'position='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 表位 || ''',' ||  
                             'brand='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 厂牌 || ''',' ||  
                            'caliber='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 口径 || ''',' ||  
                           'nameplate='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 表身号 || ''',' ||  
                           'metertype='||     --(大于等于0为预存  小于0就是欠费)
                 '''' || 水表类型 || ''',' ||  
                        'cbmemo='||  
                  '''' || 抄表备注 || '''' ||
               -- where
               ' where miid=  '||
                  '''' || 户号 || ''''  
        from ( select '01' 水表状况,
                     '正常' 表况的中文名,
                    TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')    上次抄表日期,
                 TO_CHAR(mr.MRRDATE ,'yyyy-MM-dd')     上次抄表日期1,
                     --mr.MRSCODE   上次指针,
                     mi.MIRCODE 上次指针,     --byj edit 2016.06 上次指针应该从meterinfo表中取 
                     null 本次指针,
                     null 水量,
                     null 水费,
                     null 污水费,
                 --    mr.MRYEARJE01 水费,
               --      mr.MRYEARJE02 污水费,
                     null 水费单价,
                     null 污水费单价,
                     mr.MRTHREESL 三月均量,
                     null 其他费用,
                     null 总金额,
                --     mr.MRYEARJE03 其他费用,
                --     mr.MRPLANJE01 总金额,
 
                      mr.MRLASTSL  上次抄表水量,
                 DECODE(mr.MRREADOK,'U',mr.MRCHKRESULT, mr.MRMEMO) 抄表备注,     
                        mi.MIUSENUM 人口数,
                         mi.mipfid 用水性质, 
                         FGETPRICENAME(mi.mipfid) 用水性质名称, 
                       --  T4.BFRCYC 抄表周期,
                         mi.MISMFID 营业所代号,
                         fgetsmfname(mi.MISMFID ) 营业所说明,
                          mi.MICHARGETYPE 收费方式代号,
                          decode( mi.MICHARGETYPE,'X','坐收','M','走收') 收费方式说明, 
                           mi.MIPRIID 合收表主表号,
                           mi.MIPRIFLAG 合收表标志,
                          md.DQSFH 地区塑封号,
                          md.DQGFH 地区钢封号,
                           md.JCGFH 稽查刚封号,
                           md.QFH 铅封号,
                           md.BARCODE 条形码,
                           mi.MISTATUS 水表状态,
                           md.IFDZSB 倒表标志,
                           mi.MICLASS 总分表标志,
                              nvl(mi.MIPID,mi.miid)  总表编号,
                        --   mi.MIPOSITION 表位,
                          decode( mi.MISIDE ,'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
                          md.MDBRAND 厂牌,
                           md.MDCALIBER 口径, 
                          substrb(md.MDNO,1,13) 表身号,
                        --   md.MDNO 表身号,
                           mi.MILB  水表类型, 
                           MI.MIID 户号
                FROM METERREAD mr,meterinfo mi ,meterdoc md ,bookframe bf
               WHERE  mi.miid = mr.MRMID(+)
                 and mi.miid = md.mdmid
                 and mi.mibfid =bf.bfid
                 and bf.BFRPER = I_BFRPER 
                 and mi.mibfid is not null
                 and mr.mrid is  null   --更新未抄表的资料
                 and mi.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='2'  )   --抓取临时档
              )           
            UNION ALL
  ---下述处理重新添加表册下用户的资料20150320
    --用户基本信息
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,barcode,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,MDMODEL) values(' || 
    '''' || 户号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 户名||''','||
    '''' || 用户地址||''','||
    ''''||联系人||''','||
    ''''||联系电话||''','||
    ''''||移动电话||''','||
    ''''||用户类型||''','||
    ''''||用水性质||''','||
    ''''||用水性质名称||''','||
    ''''||表册编号||''','||
    ''''||表册名称||''','||
    ''''||抄表次序||''','||
    ''''||人口数||''','||
    ''''||上期预存金额||''','||
    ''''||本期预存金额||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||上次抄表日期||''','||
    ''''||是否阶梯||''','||
    ''''||查表状况||''','||
    ''''||册页号||''','||
    ''''||用户类别||''','||
    ''''||用户备注||''','||
    ''''||应收金额||''','||
    ''''||应收水量||''','||
    ''''||真实名称||''','||
    ''''||处理状态||''','||
    ''''||小区号||''','||
    ''''||小区名称||''','||
    ''''||帐卡号||''','||
    ''''||楼号||''','||
    ''''||单元号||''','||
    ''''||算费注记||''','|| 
    ''''||示数来源||''','|| 
    ''''||本次抄表日期||''','|| 
    ''''||条形码||''','|| 
    ''''||新户名||''','||
    ''''||新用水性质||''','||
    ''''||新用水性质名称||''','||
    ''''||工单申请标志||''','||
    ''''||是否本次抄表||''','||  --meterreadingline_way(是否本次抄表路线)    cahr   1代表是本月   0代表不是本月
    '''1'','||
    '''1'','||
    '''1'','||
    ''''||表型号||''')' 
  FROM (SELECT MAX(T2.MIID) 户号,
               MAX(T2.MINAME) 户名,
               MAX(T2.MINAME2) 真实名称,
               MAX(T2.MIADR) 用户地址,
               MAX(T1.CICONNECTPER) 联系人, 

               MAX(T1.citel1) 联系电话,
               MAX(T1.CIMTEL)  移动电话,
              -- MAX(T1.CICONNECTMTEL) 移动电话,
             --  MAX(T1.CICHARGETYPE) 用户类型,
              MAX(T2.mICHARGETYPE) 用户类型, --20150308
               MAX(T2.MIPFID) 用水性质,
          FGETPRICENAME(MAX(T2.MIPFID)) 用水性质名称,
               MAX(T3.MRBFID) 表册编号,
               MAX(T3.MRBFID) 表册名称, 
               max(t3.MRRORDER) 抄表次序, --20150308
               SUM(T2.MIUSENUM) 人口数,
/*                    max (case when t2.mistatus in ('29','30') and t3.MRREADOK ='Y' THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN t2.mistatus NOT in ('29','30') and t3.MRREADOK ='Y' and t3.mrface='01' THEN  T3.MRPLANJE02 
                  else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) 上期预存金额,
            decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) 本期预存金额, 
            max(case when  T3.MRREADOK ='N'  THEN   VIEW1.RLJE   else   T3.MRPLANJE01  end   )   应收金额, --如果待审核则重新抓取之前的应收合计
               sum(VIEW1.rlsl) 应收水量,
                max(t3.MRYEARJE01)  水费,
                max(t3.MRYEARJE02)  污水费,
                max(t3.MRYEARJE03)  附加费,*/
                
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                            when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X')<> '9'    AND  t3.MRREADOK <> 'N'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0) -- 未算费的非固定量抓取之前上传的
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'    AND  t3.MRREADOK <> 'N'  THEN T3.MRPLANJE02   -- 未算费的非固定量抓取之前上传的
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE03   --  固定量每次打印调用此处为0
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  t3.mrsl   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X')<> '9'  and   t2.mistatus not in ('29','30')   THEN T3.mrsl 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X') = '9'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) 应收水量, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) 本期预存金额, 
      
          --   sum(VIEW1.rlsl) 应收水量,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01/*t3.mrsl*/   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end ) 应收金额, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01/*T3.MRYEARJE01*/ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 水费, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02  */--   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 污水费, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03 */ --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 附加费,    
                           
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) 上次抄表日期,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) 是否阶梯,
               'N'  是否阶梯,
               '未查' 查表状况, 
              MAX(T3.mrbatch) 册页号,--册页号改成帐卡号
              -- MAX(T2.miseqno) 帐卡号, 
               MAX(T2.MILB) 用户类别,
     MAX(T2.mimemo)用户备注,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
              --  MAX(DECODE(T3.MRREADOK,'Y','已出账','N','未处理','X','待审核')) 处理状态,
                MAX(CASE when  T3.MRREADOK ='Y'  THEN '已审核'
                      when  T3.MRREADOK ='N'  THEN '未处理'
                      when  T3.MRREADOK ='X'  THEN '待审核'
                      when  T3.MRREADOK ='U'  THEN '未通过'
                      else '未处理' END) 处理状态, 
             --  sum(VIEW1.RLJE) 应收金额,

               max(t2.MICOMMUNITY) 小区号,
               max(t2.MISEQNO) 帐卡号,
              max(t2.MILH)  楼号,
             max(t2.MIDYH)  单元号,
 
            max(t4.diname) 小区名称, 
                      MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --待审核、已出帐
                              when  T3.MRREADOK ='N'  or T3.MRREADOK ='U'  THEN 'N'  --未处理
                              else 'N' END) 算费注记 ,
                   decode(max(T3.MRIFGU),'1','见表','2','估抄','3','电话件','4','未见表') 示数来源,
                 -- max(T3.Mrrdate)       本次抄表日期,
                    to_char( max(T3.Mrrdate)  ,'yyyy-mm-dd hh24:mi:ss') 本次抄表日期,
                   MAX(T5.BARCODE) 条形码, 
              decode(nvl(max(MIYL5),'N'),'N',   MAX(T2.MINAME) , MAX(T3.MRPRIVILEGEMEMO)  ) 新户名,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(T3.MRPRIVILEGEPER)  ) 新用水性质,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(T3.MRPRIVILEGEPER)) )新用水性质名称,
              decode(nvl(max(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') 工单申请标志,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) 是否本次抄表 ,
            t2.MIRTID 表型号
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 取消
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 取消
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5 ,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2   --抓取已经算费的
         WHERE T1.CIID = T2.MICID
           AND T2.MIID = T3.MRMID 
           AND T2.MIID = T5.MDMID 
          -- AND T4.SMMIID = T2.MIID
           AND T2.MIID = VIEW1.RLMID(+)
           and t3.mrid =view2.rlmrid(+)
           and t2.MICOMMUNITY=t4.diid(+)
            and   t2.mibfid is not null 
           and T3.mrrper =I_BFRPER  --抓取当月添加的抄表信息
         --  and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --抓取临时档
           and NVL(T3.MROUTID,'X') <> '9'                                                 --未做过下载的数据!!! byj comment
         --  AND T3.MRREADOK <> 'Y'
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID) 
         
         
     UNION ALL
     
   --下述处理添加不是本月抄表用户的资料20150420
    --用户基本信息
    SELECT 'insert into custinfo(mrid,ciid,ciname,ciaddr,linkman,hometel,mobiletel,chargetype,pfid,pfname,bfid,bfname,rorder,mans,saving,chargetotal,sfje,psfje,szyfje,lastjfdate,isstep,cbzk,bookpage,accountname,memo,total_money,cusenum,miname2,processflag,MICOMMUNITY,MICOMMUNITY_NAME,MISEQNO,MILH,MIDYH,issf,codesource,readdate,barcode,apply_ciname,apply_pfid,apply_pfname,apply_flag,meterreadingline_way,sfdj_discount,psfdj_discount,szydj_discount,MDMODEL) values(' || 
    '''' || 户号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 户名||''','||
    '''' || 用户地址||''','||
    ''''||联系人||''','||
    ''''||联系电话||''','||
    ''''||移动电话||''','||
    ''''||用户类型||''','||
    ''''||用水性质||''','||
    ''''||用水性质名称||''','||
    ''''||表册编号||''','||
    ''''||表册名称||''','||
    ''''||抄表次序||''','||
    ''''||人口数||''','||
    ''''||上期预存金额||''','||
    ''''||本期预存金额||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||上次抄表日期||''','||
    ''''||是否阶梯||''','||
    ''''||查表状况||''','||
    ''''||册页号||''','||
    ''''||用户类别||''','||
    ''''||用户备注||''','||
    ''''||应收金额||''','||
    ''''||应收水量||''','||
    ''''||真实名称||''','||
    ''''||处理状态||''','||
    ''''||小区号||''','||
    ''''||小区名称||''','||
    ''''||帐卡号||''','||
    ''''||楼号||''','||
    ''''||单元号||''','||
    ''''||算费注记||''','|| 
    ''''||示数来源||''','|| 
    ''''||本次抄表日期||''','|| 
    ''''||条形码||''','|| 
    ''''||新户名||''','||
    ''''||新用水性质||''','||
    ''''||新用水性质名称||''','||
    ''''||工单申请标志||''','||
    ''''||是否本次抄表||''','||  --meterreadingline_way(是否本次抄表路线)    cahr   1代表是本月   0代表不是本月
    '''1'','||
    '''1'','||
    '''1'','||
    ''''||表型号||''')' 
  FROM (SELECT MAX(T2.MIID) 户号,
               MAX(T2.MINAME) 户名,
               MAX(T2.MINAME2) 真实名称,
               MAX(T2.MIADR) 用户地址,
               MAX(T1.CICONNECTPER) 联系人,
              MAX(T1.citel1) 联系电话,
               MAX(T1.CIMTEL) 移动电话,
              -- MAX(T1.CICONNECTMTEL) 移动电话,
             --  MAX(T1.CICHARGETYPE) 用户类型,
              MAX(T2.mICHARGETYPE) 用户类型, --20150308
               MAX(T2.MIPFID) 用水性质,
          FGETPRICENAME(MAX(T2.MIPFID)) 用水性质名称,
               MAX(T3.MRBFID) 表册编号,
               MAX(T3.MRBFID) 表册名称, 
               max(t3.MRRORDER) 抄表次序, --20150308
               SUM(T2.MIUSENUM) 人口数,
/*                    max (case when t2.mistatus in ('29','30') and t3.MRREADOK ='Y' THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0)  
                 WHEN t2.mistatus NOT in ('29','30') and t3.MRREADOK ='Y' and t3.mrface='01' THEN  T3.MRPLANJE02 
                  else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end  ) 上期预存金额,
            decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) 本期预存金额, 
            max(case when  T3.MRREADOK ='N'  THEN   VIEW1.RLJE   else   T3.MRPLANJE01  end   )   应收金额, --如果待审核则重新抓取之前的应收合计
               sum(VIEW1.rlsl) 应收水量,
                max(t3.MRYEARJE01)  水费,
                max(t3.MRYEARJE02)  污水费,
                max(t3.MRYEARJE03)  附加费,*/
                
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING - nvl(VIEW2.RLJE1,0)   --已经算费销帐的，上期预存等于预存-本期欠费 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING - nvl(VIEW1.RLJE,0) + nvl(VIEW2.RLJE1,0)  --已经算费的，上期预存等于预存-所有欠费+本期欠费
                            when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X')<> '9'    AND  t3.MRREADOK <> 'N'  THEN  T2.MISAVING -  nvl(VIEW1.RLJE,0) -- 未算费的非固定量抓取之前上传的
                        when  t3.mrifrec ='N' and  t2.mistatus  not in ('29','30') and nvl(t3.mrdatasource,'X') = '9'    AND  t3.MRREADOK <> 'N'  THEN T3.MRPLANJE02   -- 未算费的非固定量抓取之前上传的
                        when  t3.mrifrec ='N' and  t2.mistatus   in ('29','30') then  T2.MISAVING -  nvl(VIEW1.RLJE,0)   --固定量，所有的都抓取预存-以前欠费 
                        when  t3.mrifrec ='N' and t3.MRREADOK = 'N' then T2.MISAVING  - nvl(VIEW1.RLJE,0)  --未处理的部份抓取预存-以前欠费 
                        else   T2.MISAVING  - nvl(VIEW1.RLJE,0)    end ) 上期预存金额, 
                          
               max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  T2.MISAVING   --已经算费销帐的，本期预存金额等于预存 
                        when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN  T2.MISAVING  - nvl(VIEW1.RLJE,0)   --已经算费未销帐的，本期预存金额等于预存 -所有欠费
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE03   --  固定量每次打印调用此处为0
                        when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                        when  t3.mrifrec ='N' and  t3.mrface <> '01' then T2.MISAVING  - nvl(VIEW1.RLJE,0)     --当未算费，- 零水量、表异常为预存-欠费
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0   ---   未处理的部份都为N   
                        else   0   end ) 本期预存金额, 
            
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  t3.mrsl   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X')<> '9'  and   t2.mistatus not in ('29','30')   THEN T3.mrsl 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01' and nvl(t3.mrdatasource,'X') = '9'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) 应收水量, 
                                  
         --   decode( MAX(T3.MRREADOK),'N', 0,decode( max(t3.mrface),'01', MAX(T3.MRPLANJE03),0) ) 本期预存金额, 
      
          --   sum(VIEW1.rlsl) 应收水量,
                 max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN  T3.MRPLANJE01/*t3.mrsl*/   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end ) 应收金额, 
                                  
                  max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01/*T3.MRYEARJE01*/ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 水费, 
                           
                   max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02  */--   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 污水费, 
                            
                        max(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03 */ --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end ) 附加费,    
                           
               MAX(CASE WHEN T2.MIRECDATE IS NOT NULL THEN TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd')  END) 上次抄表日期,
                -- MAX(CASE WHEN(T2.MIPFID  like '0104%') THEN 'Y' ELSE 'N' END ) 是否阶梯,
               'N'  是否阶梯,
               '未查' 查表状况, 
              MAX(T3.mrbatch) 册页号,--册页号改成帐卡号
              -- MAX(T2.miseqno) 帐卡号, 
               MAX(T2.MILB) 用户类别,

            MAX(T2.mimemo)用户备注,
               --MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
             --  MAX(CASE WHEN T3.MRREADOK ='Y' THEN '已出账' else '未处理' END) 处理状态,
              --  MAX(DECODE(T3.MRREADOK,'Y','已出账','N','未处理','X','待审核')) 处理状态,
                MAX(CASE when  T3.MRREADOK ='Y'  THEN '已审核'
                      when  T3.MRREADOK ='N'  THEN '未处理'
                      when  T3.MRREADOK ='X'  THEN '待审核'
                      when  T3.MRREADOK ='U'  THEN '未通过'
                      else '未处理' END) 处理状态, 
             --  sum(VIEW1.RLJE) 应收金额,

               max(t2.MICOMMUNITY) 小区号,
               max(t2.MISEQNO) 帐卡号,
             max(t2.MILH) 楼号,
            max(t2.MIDYH)  单元号,
             max(t4.diname) 小区名称, 
                      MAX(CASE when  T3.MRREADOK ='Y' or T3.MRREADOK ='X'  THEN 'Y'  --待审核、已出帐
                              when  T3.MRREADOK ='N'  or T3.MRREADOK ='U'  THEN 'N'  --未处理
                              else 'N' END) 算费注记 ,
                   decode(max(T3.MRIFGU),'1','见表','2','估抄','3','电话件','4','未见表') 示数来源,
                 -- max(T3.Mrrdate)       本次抄表日期,
                    to_char( max(T3.Mrrdate)  ,'yyyy-mm-dd hh24:mi:ss') 本次抄表日期,
                   MAX(T5.BARCODE) 条形码, 
              decode(nvl(max(MIYL5),'N'),'N',  MAX(T2.MINAME) , MAX(MIJD)  ) 新户名,
              decode(nvl(max(MIYL5),'N'),'N',MAX(T2.MIPFID), MAX(MIYL6)  ) 新用水性质,   
              decode(nvl(max(MIYL5),'N'),'N',FGETPRICENAME(MAX(T2.MIPFID)),FGETPRICENAME(MAX(MIYL6)) )新用水性质名称,
              decode(nvl(max(MIYL5),'N'),'N','未申请','Y','已通过','X','申请中','U','未通过','未申请') 工单申请标志,
            MAX(CASE when  NVL(T3.MRREADOK,'NULL') ='NULL' THEN '0' ELSE '1'  END  ) 是否本次抄表 ,
            t2.MIRTID 表型号
    --    FROM FM_CUSTINFO T1, FM_METERINFO T2,CM_METERREAD T3,FM_SORTMETER T4,(  --20150308 取消
     FROM CUSTINFO T1, METERINFO T2, METERREAD T3 ,(
       --            SELECT SUM(T5.RLJE) RLJE,RLMIID FROM AM_RECLIST T5 WHERE T5.RLRMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMIID--20150308 取消
      --   SELECT SUM(T5.RLJE) RLJE,RLMID FROM  RECLIST T5 WHERE T5.RLMONTH=TO_CHAR(SYSDATE,'yyyy.MM') GROUP BY T5.RLMID
       SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,DISTRICTINFO t4,meterdoc t5 ,bookframe t6,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2   --抓取已经算费的
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
           and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --抓取临时档
           and t3.mrid is null  --添加不是本月抄表资料的custinfo信息
         GROUP BY T1.CIID,T2.MIID,t2.MIRTID) 
  UNION ALL
   ---下述处理重新添加表册下用户的资料20150320
  --水表基本信息
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid) values(' || 
    '''' || 单位号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 表位||''','||
    '''' || 厂牌||''','||
    ''''||口径||''','||
    ''''||表身号||''','||
    ''''||水表类型||''','||
    ''''||安装日期||''','||
    ''''||换表日期||''','||
    ''''||上次抄表日期||''','||
    ''''||起码||''','||
    ''''||止码||''','||
    ''''||水量||''','||
    ''''||表况||''','||
    ''''||上次抄表日期||''','||
    ''''||三月均量||''','||
    ''''||铅封号||''','||
    ''''||拆表底数||''','||
    ''''||新表起数||''','|| 
    ''''||是否拆表||''','||
    ''''||年累计水量||''','||
    ''''||阶梯起算日||''','||
    ''''||人口数||''','||
    ''''||用水性质||''','||
    ''''||上次抄表水量||''','||
    ''''||用水性质名称||''','||
    ''''||抄表周期||''','||
    ''''||抄表备注||''','||
    ''''||营业所代号||''','||
    ''''||营业所说明||''','||
    ''''||收费方式代号||''','||
    ''''||收费方式说明||''','||
    ''''||表况说明||''','||
    ''''||合收表主表号||''','||
    ''''||合收表标志||''','||
    ''''||地区塑封号||''','||
    ''''||地区钢封号||''','||
    ''''||稽查刚封号||''','||
    ''''||条形码||''','||
    ''''||水表状态||''','||
    ''''||倒表标志||''','||
    ''''||总分表标志||''','||
    ''''||总表编号||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||应收金额||''','||
    ''''||表册号||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END 单位号,
       T2.MIID 户号,
  T2.Miname 户名,
  T2.Miadr 用户地址,
     --  t2.MIPOSITION 表位,
     decode(  T2.MISIDE ,'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
      t5.MDBRAND 厂牌,
       T5.MDCALIBER 口径,
       --T2.MINO 表身号,
       --substrb(t5.MDNO,1,13)  表身号,
       replace(replace(t5.MDNO,chr(10),''),chr(13),'') 表身号,        
      -- t5.MDNO 表身号,
       T2.MILB  水表类型,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') 安装日期,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') 换表日期,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END 上次抄表日期,
       --NVL(T3.MRSCODE,0) 起码,
       t2.MIRCODE 起码,     -- byj edit 起码取 meterinfo 中的 
       T3.MRECODE 止码,
     --  T3.MRSL 水量,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') <> '9' and   t2.mistatus not in ('29','30')   THEN T3.mrsl --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') = '9' and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) , T3.MRSL )水量, --总分表水量处理为实际的水量
       NVL(T3.MRFACE2,'01')  表况,--实际是检表表态20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') 表况,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end 拆表底数,
       0 拆表底数,
       t3.MRTHREESL 三月均量,
       t5.QFH 铅封号,
       0 新表起数,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end 是否拆表,
       'N' 是否拆表,
       T3.MRBFID 表册号,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') 阶梯起算日,
       ''  阶梯起算日,
       T2.MIUSENUM 人口数,
       t2.mipfid 用水性质,
      -- CASE WHEN T2.MIPFID='9999' THEN '混合用水' else FGETPRICENAME(t2.mipfid) end 用水性质名称,
       FGETPRICENAME(t2.mipfid) 用水性质名称,
       --T2.miyeartotalsl 年累计水量,20150308
       0 年累计水量,
       T2.MIRECSL 上次抄表水量,
      DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO) 抄表备注,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) 抄表周期 20150308
       T4.BFRCYC 抄表周期,
       t2.MISMFID 营业所代号,
       fgetsmfname(t2.MISMFID ) 营业所说明,
        t2.MICHARGETYPE 收费方式代号,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  表况说明,-- 20150310检表表态说明
         decode( t2.MICHARGETYPE,'X','坐收','M','走收') 收费方式说明,
         t2.MIPRIID 合收表主表号,
         t2.MIPRIFLAG 合收表标志,
         t5.DQSFH 地区塑封号,
        t5.DQGFH 地区钢封号,
      t5.JCGFH 稽查刚封号,
       t5.BARCODE 条形码,
         t2.MISTATUS 水表状态,
         t5.IFDZSB 倒表标志,
         t2.MICLASS 总分表标志,
          nvl(t2.MIPID,t2.miid)  总表编号,
                                                             
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01 /*T3.MRYEARJE01 */--   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   水费, 
                           
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02 */ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   污水费, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03*/  --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   附加费,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE01 /*t3.mrsl */  --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end  应收金额 
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5 ,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --抓取已经算费的
 WHERE T1.CIID = T2.MICID
   and t2.miid   = t3.mrmid 
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and T3.MRRPER =I_BFRPER
   and NVL(T3.MROUTID,'X') <> '9'
   and t2.mibfid is not null 
  -- and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --抓取临时档
  -- AND T3.MRREADOK <> 'Y'
   and t3.mrid =view2.rlmrid(+)
   and t2.miid =view1.rlmid(+)
   ) 
   
    UNION ALL
   ---下述处理重新添加不是本月表册下用户的资料20150420
  --水表基本信息
  SELECT 'insert into meterinfo(ciid,miid,position,brand,caliber,nameplate,metertype,instdate,changedate,prdate,scode,ecode,musenum,sbzk,lastreaddate,mrthreesl,qfh,cbcode,newcode,cbstate,totalYealSL,stepBeginTime,miPersons,pfid,lastcode,pfname,cbstyle,cbmemo,MISMFID,MISMFID_NAME,MICHARGETYPE,MICHARGETYPE_NAME,MRFACE_NAME,MIPRIID,MIPRIFLAG,DQSFH,DQGFH,JCGFH,BARCODE,MISTATUS,IFDZSB,MICLASS,MIPID,sfje,psfje,szyfje,total_money,bfid) values(' || 
    '''' || 单位号 || ''',' || 
    '''' || 户号 || ''',' ||
    '''' || 表位||''','||
    '''' || 厂牌||''','||
    ''''||口径||''','||
    ''''||表身号||''','||
    ''''||水表类型||''','||
    ''''||安装日期||''','||
    ''''||换表日期||''','||
    ''''||上次抄表日期||''','||
    ''''||起码||''','||
    ''''||止码||''','||
    ''''||水量||''','||
    ''''||表况||''','||
    ''''||上次抄表日期||''','||
    ''''||三月均量||''','||
    ''''||铅封号||''','||
    ''''||拆表底数||''','||
    ''''||新表起数||''','|| 
    ''''||是否拆表||''','||
    ''''||年累计水量||''','||
    ''''||阶梯起算日||''','||
    ''''||人口数||''','||
    ''''||用水性质||''','||
    ''''||上次抄表水量||''','||
    ''''||用水性质名称||''','||
    ''''||抄表周期||''','||
    ''''||抄表备注||''','||
    ''''||营业所代号||''','||
    ''''||营业所说明||''','||
    ''''||收费方式代号||''','||
    ''''||收费方式说明||''','||
    ''''||表况说明||''','||
    ''''||合收表主表号||''','||
    ''''||合收表标志||''','||
    ''''||地区塑封号||''','||
    ''''||地区钢封号||''','||
    ''''||稽查刚封号||''','||
    ''''||条形码||''','||
    ''''||水表状态||''','||
    ''''||倒表标志||''','||
    ''''||总分表标志||''','||
    ''''||总表编号||''','||
    ''''||水费||''','||
    ''''||污水费||''','||
    ''''||附加费||''','||
    ''''||应收金额||''','||
    ''''||表册号||''')'
  FROM (SELECT CASE WHEN T2.MICHARGETYPE='TX'THEN T2.MICID ELSE T2.MIID END 单位号,
       T2.MIID 户号,
     T2.Miname 户名,
     T2.Miadr 用户地址,
     --  t2.MIPOSITION 表位,
     decode(  T2.MISIDE ,'CF','厨房','GJ','管井','QT','其它','TJ','天井','CS','卫生间') 表位,
      t5.MDBRAND 厂牌,
       T5.MDCALIBER 口径,
       --T2.MINO 表身号,
     --  t5.MDNO 表身号,
        --substrb(t5.MDNO,1,13) 表身号,
        replace(replace(t5.MDNO,chr(10),''),chr(13),'') 表身号,
       T2.MILB  水表类型,
       TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') 安装日期,
       TO_CHAR(T2.MIREINSDATE,'yyyy-MM-dd') 换表日期,
       CASE WHEN T2.MIRECDATE IS NOT NULL THEN  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') ELSE TO_CHAR(T2.MIINSDATE,'yyyy-MM-dd') END 上次抄表日期,
       --NVL(T3.MRSCODE,0) 起码,
       t2.MIRCODE 起码,   --byj edit 2016.06 起码取meterinfo 中的 
       T3.MRECODE 止码,
     --  T3.MRSL 水量,
       decode(  t2.miclass,'2',(case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlsl1   --已经算费销帐的，水量等于本期水量
                           when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view1.rlsl  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN t3.mrsl   --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') <> '9' and   t2.mistatus not in ('29','30')   THEN T3.mrsl --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and nvl(t3.mrdatasource,'X') = '9' and   t2.mistatus not in ('29','30')   THEN T3.MRPLANSL --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then  0   ---   未处理的部份都为0   
                        else   0   end ) , T3.MRSL )水量, --总分表水量处理为实际的水量
       NVL(T3.MRFACE2,'01')  表况,--实际是检表表态20150310
      -- fn_get_sm_Userdictionaryname(T3.MRFACE,'28') 表况,
    -- 20150308   case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then manewmiscode else 0 end 拆表底数,
       0 拆表底数,
       t3.MRTHREESL 三月均量,
       t5.QFH 铅封号,
       0 新表起数,
     -- 20150308 case when to_char(view2.mafinishdate,'yyyy-MM-dd')>  TO_CHAR(T2.MIRECDATE,'yyyy-MM-dd') then 'Y' else 'N' end 是否拆表,
       'N' 是否拆表,
       T3.MRBFID 表册号,
      -- TO_CHAR(T2.mistepsdate,'yyyy-MM-dd') 阶梯起算日,
       ''  阶梯起算日,
       T2.MIUSENUM 人口数,
       t2.mipfid 用水性质,
      -- CASE WHEN T2.MIPFID='9999' THEN '混合用水' else FGETPRICENAME(t2.mipfid) end 用水性质名称,
       FGETPRICENAME(t2.mipfid) 用水性质名称,
       --T2.miyeartotalsl 年累计水量,20150308
       0 年累计水量,
       T2.MIRECSL 上次抄表水量,
       DECODE(T3.MRREADOK,'U',T3.MRCHKRESULT, T3.MRMEMO)   抄表备注,
    --   fn_get_sm_Userdictionaryname(T4.bfrcyc,20) 抄表周期 20150308
       T4.BFRCYC 抄表周期,
       t2.MISMFID 营业所代号,
       fgetsmfname(t2.MISMFID ) 营业所说明,
        t2.MICHARGETYPE 收费方式代号,
        fgetmiface2( NVL(T3.MRFACE2,'01'))  表况说明,-- 20150310检表表态说明
         decode( t2.MICHARGETYPE,'X','坐收','M','走收') 收费方式说明,
         t2.MIPRIID 合收表主表号,
         t2.MIPRIFLAG 合收表标志,
         t5.DQSFH 地区塑封号,
         t5.DQGFH 地区钢封号,
        t5.JCGFH 稽查刚封号,
        t5.BARCODE 条形码,
         t2.MISTATUS 水表状态,
         t5.IFDZSB 倒表标志,
         t2.MICLASS 总分表标志,
          nvl(t2.MIPID,t2.miid)  总表编号,
                                                             
      case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE01 /*T3.MRYEARJE01 */--   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   水费, 
                           
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE2   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN    view2.CHARGE2 --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE02/*T3.MRYEARJE02 */ --   固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE02 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   污水费, 
                            
                   case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.CHARGE3   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.CHARGE3   --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRYEARJE03/*T3.MRYEARJE03*/  --  固定量每次打印调用此处为0暂时与MRYEARJE03一样
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRYEARJE03 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0 end   附加费,  
       case when t3.mrifrec ='Y' and  view2.rlpaidflag ='Y' THEN  view2.rlje1   --已经算费销帐的，水量等于本期水量
                          when t3.mrifrec ='Y' and  view2.rlpaidflag ='N' THEN   view2.rlje1  --已经算费未销帐的， 水量等于所有欠费水量
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND   t2.mistatus  in ('29','30')   THEN T3.MRPLANJE01 /*t3.mrsl */  --  固定量每次打印调用此处为0
                         when  t3.mrifrec ='N' and  t3.MRREADOK <> 'N'  AND t3.mrface='01'  and   t2.mistatus not in ('29','30')   THEN T3.MRPLANJE01 --当未算费，已抄表、表况为正常时抓取之前写入的 
                         when  t3.mrifrec ='N' and  t3.MRREADOK = 'N' then 0    ---   未处理的部份都为0   
                         else   0   end  应收金额 
  FROM CUSTINFO T1, METERINFO T2,METERREAD T3,BOOKFRAME T4,meterdoc t5 ,(
           SELECT SUM(T5.RLJE) RLJE, sum(t5.rlsl) rlsl, RLMID
                        FROM RECLIST T5
                       WHERE T5.RLPAIDFLAG <> 'Y'
                         AND T5.RLREVERSEFLAG <> 'Y'
                         AND T5.RLBADFLAG <> 'Y'
                       GROUP BY T5.RLMID
                            )VIEW1,(                    
                 select rl.rlmrid rlmrid, rl.rlsl rlsl1 , rl.rlje rlje1, rlpaidflag, SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
                                                 SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  污水费
                                                 SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3  --  附加费
                   from RECLIST rl, recdetail rd
                  where rl.rlid = rd.rdid  
                    group by  rl.rlmrid,rl.rlsl, rl.rlje,rlpaidflag) view2  --抓取已经算费的
 WHERE T1.CIID = T2.MICID
   and t2.miid = t3.mrmid (+)
   AND T2.MIBFID = T4.BFID 
   and t1.ciid =t5.MDMID
   and T4.BFRPER = I_BFRPER
    and t2.mibfid is not null
   and t3.mrid is  null  --不是本月抄表资料
  and t2.miid in (select miid from METERINFO_SJCBUP  where UPDATE_MK ='1'  )   --抓取临时档 
   and t3.mrid =view2.rlmrid(+)
   and t2.miid =view1.rlmid(+)) 
   --添加缴费信息更新 20150615
   UNION ALL
  SELECT 'insert into payment_his(MIID,CIID,PDATETIME,PPOSITION,MICHARGETYPE,PPAYMENT,PPAYEE,PPAYWAY) values(' || 
    '''' || 水表编号 || ''',' || 
    '''' || 用户编号 || ''',' ||
    '''' || 缴费日期||''','||
    '''' || 缴费机构||''','||
    '''' || 缴费方式||''','||
    ''''||付款金额||''','||
    ''''||收费员||''','||
    ''''||付款方式||''')'
    from 
      ( SELECT MAX(MI.MICID) 水表编号, --水表编号 VARCHAR2(10)
       MAX(MI.MICID) 用户编号, --用户编号 VARCHAR2(10) 
       to_char(MAX(PM.PDATETIME),'yyyy-mm-dd hh24:mm:ss') 缴费日期, --发生日期 VARCHAR2(20)
       MAX(FGETSYSMANAFRAME(PM.PPOSITION) ) 缴费机构, --缴费机构 VARCHAR2(60)
        DECODE(MAX(MI.MICHARGETYPE), 'X', '坐收', 'M', '走收') 缴费方式, --缴费方式 VARCHAR2(20)
        SUM(PM.PPAYMENT) 付款金额, --付款金额 NUMBER(12,2)
       MAX( FGETOPERNAME(PM.PPAYEE) )收费员, --收费员  VARCHAR2(20) 
       MAX(decode(TRIM(PM.PPAYWAY), 'XJ','现金','DC','倒存','ZP','支票','MZ','抹帐') ) 付款方式     --付款方式VARCHAR2(20)
  FROM PAYMENT PM, METERINFO MI,BOOKFRAME BF
 WHERE PM.PMID = MI.MIID
   AND mi.mibfid =bf.bfid
   AND PM.PREVERSEFLAG = 'N'
   and bf.BFRPER=I_BFRPER
   and PM.PBATCH in ( select miid from METERINFO_SJCBUP  where ciid =pm.pmid and  UPDATE_MK ='3'  ) --添加用户缴费记录
   aND ( PM.PDATETIME >=add_months(SYSDATE,-24) )
 GROUP BY PM.PBATCH
 having  SUM(PM.PPAYMENT) > 0
 ORDER BY MAX(MI.MISMFID),
          SUBSTR(MAX(MI.MIBFID), 1, 5),
          MAX(MI.MILB),
          MAX(MI.MIPRIID)  )
          
   -- 添加参数更新
   UNION ALL
    select 'DELETE FROM datadesign' from dual
   
   UNION ALL
   
   --字典信息
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || 字典类型 || ''',' || 
    '''' || 字典CODE || ''',' ||
    '''' || 字典||''','||
    '''' || 备注||''')'
  FROM (
      select '水表口径' 字典类型,mcid||'' 字典CODE,mcname||'' 字典, '' 备注 from METERCALIBER
       UNION ALL
       select '水表状况' 字典类型,sflid 字典CODE,sflname 字典,sflflag1 备注 from sysfacelist2 t   /* where t.sflid  not in ('13','14','15')*/
       UNION ALL
       select '水表位置' 字典类型,sclid 字典CODE,sclvalue 字典,decode(sclgroup,'01','室内','02','室外') 备注 from syscharlist  where scltype ='表位'   
       UNION ALL
       select '营销员' 字典类型,'编号' 字典CODE,t.oaid 字典,''备注 from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select '营销员' 字典类型,'名称' 字典CODE,t.oaname 字典,''备注 from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select '营销员' 字典类型,'密码' 字典CODE,UPPER(t.oapwd) 字典,''备注 from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select '营销员手机号码' 字典类型,oatel 字典CODE,t.oatel 字典,''备注 from operaccnt t where t.oaid=I_BFRPER
       UNION ALL
       select '营销员' 字典类型, '营业所' 字典CODE,   b.smfpid   字典,''备注   --记录抄表员营业所
           from OPERACCNT a, SYSMANAFRAME b   
             where a.oadept = b.smfid -- oadept 
         and a.oaid =I_BFRPER 
       UNION ALL
       select 字典类型, 字典CODE,字典,备注 from datadesign where  字典类型 not in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件','打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔','手机版本更新内容','手机抄表审核全选功能','手机抄表程序安装路径','待选服务器','数据下载URL')
        AND NVL(备注,'NULL') <> 'XXXXXXXXXX' and 字典 not in ('营业所上传图片文件服务器IP地址')
      UNION ALL
              SELECT 字典类型, 字典CODE,字典,备注
          FROM DATADESIGN
         WHERE 字典类型 = '手机版本更新内容'
           and 字典code = (select max(字典code)
                           from DATADESIGN
                          WHERE 字典类型 = '手机版本更新内容') 
                          
       UNION ALL
       select '用户(水表)状态' 字典类型,SMSID 字典CODE,SMSNAME 字典,''备注 FROM sysmeterstatus WHERE SMSMEMO='Y'  --ADD 20150324 添加水表状态
       UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and a.oaid =I_BFRPER
         and c.字典类型 in ('打印预告知通知单', '抄表审核', '是否拍照', '是否电话件' ,'打印预存预告通知单','拍照张数','打印纸张数','是否实时上传','提交数据时间间隔','水费短信','提交抄表数据时间间隔' )
             UNION ALL 
       select c.字典类型,substrb(c.字典CODE,1,instr(c.字典CODE,':') - 1),c.字典,  substrb(c.字典CODE,instr(c.字典CODE,':') + 1 ,length(c.字典CODE))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and a.oaid =I_BFRPER
         and c.字典类型 in ( '数据下载URL')
      UNION ALL 
       select c.字典类型, c.字典CODE, substrb(c.字典,1,instr(c.字典,':') - 1) ,  substrb(c.字典,instr(c.字典,':') + 1 ,length(c.字典))
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.备注
         and a.oaid =I_BFRPER
         and c.字典类型 in ( '待选服务器' ) 
       UNION ALL 
       select c.字典类型, c.字典CODE,c.字典,c.备注
        from OPERACCNT a, SYSMANAFRAME b, datadesign c
       where a.oadept = b.smfid -- oadept
         and b.smfpid = c.字典类型
         and a.oaid =I_BFRPER
         and  c.字典  in ('营业所上传图片文件服务器IP地址' ) 
       UNION ALL     
      select distinct '图片已经上传' 字典类型, PMBZ 字典CODE,substr(pmpath,instr(pmpath,mpmiid,1),200)字典,MPMIID 备注
      from meterpicture 
      where pmper= I_BFRPER
      and pmtime >= to_date(to_char( sysdate  ,'yyyymm')||'01000001', 'yyyymmddhh24miss') 
      and  pmtime <= to_date(to_char(trunc(Last_day(sysdate)),'yyyymmdd')||'235959', 'yyyymmddhh24miss')   
         )     ;   
         
  --add 20150320 
  --hb
  --更新当前抄表库发出注记及时间， 
  update meterread
    set mroutflag=DECODE(MRREADOK ,'Y','N','N', 'Y') ,  --已经抄表的发出注记为N,不需更新抄表资料，只单独调用算费，因，因f8003如果MRREADOK为Y不会把mroutflag更新为N
        MROUTDATE =sysdate,MROUTID='9'
  where MRRPER =I_BFRPER  ;  --已经抄表的话MRREADOK为Y发出注记mroutflag不需要设为Y，因f8003如果MRREADOK为Y不会把mroutflag更新为N
  
  
  --更新本地抄表计划指针 byj edit 2016.06
	update meterread mr 
	   set MRSCODE = (select MIRCODE from meterinfo mi where mr.mrmid = miid),
		     mr.mrscodechar = (select to_char(MIRCODE) from meterinfo mi where mr.mrmid = miid)
	 where (mr.mrreadok = 'N' or mrreadok = 'U') and
	       mr.mrrper = i_bfrper;
	
	-- byj edit 2016.06
  delete from METERINFO_SJCBUP a where 
	  exists(select 1 from meterinfo mi,bookframe bf where mi.mibfid = bf.bfid and bf.bfrper = I_BFRPER and a.ciid = mi.miid);
  
  
  
 -- delete from METERINFO_SJCBUP where ciid  in (select mi.miid from meterinfo mi , bookframe bk where mi.mibfid =bk.bfid and bk.BFRPER=I_BFRPER) ;  --每次更新需删除抄表员下水表的更新信息
  --这里改用CIID 因为miid中有3类别缴费记录的资料Miid里面存的是批次号，只有CIID存的是用户号
  commit;
  
  END;
                         
     --抄表审核注记回写手机端
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
    O_CURRSOR :='000' ;--返回成功
  exception
        when others then  
            O_CURRSOR :='999' ;--返回成功
            rollback;
            return;
 end ; 
  
  --手机上传图片时第三次进行图片更新
  procedure DOWN_DATA_PICTS(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) IS
    V_TYPE VARCHAR2(30);
    v_BFRPER meterpicture.pmper%type;
  BEGIN
   V_TYPE:='图片已经上传';
   v_BFRPER:=replace(I_BFRPER,',','');
   OPEN O_CURRSOR FOR select 'DELETE FROM datadesign WHERE  type  in ('''||V_TYPE||''') ' from dual 
   UNION ALL 
    SELECT 'insert into datadesign(type,id,name,savetype) values(' || 
    '''' || 字典类型 || ''',' || 
    '''' || 字典CODE || ''',' ||
    '''' || 字典||''','||
    '''' || 备注||''')'
  FROM (
        select distinct '图片已经上传' 字典类型, PMBZ 字典CODE,substr(pmpath,instr(pmpath,mpmiid,1),200)字典,MPMIID 备注
      from meterpicture 
      where pmper= v_BFRPER
      and pmtime >= to_date(to_char( sysdate  ,'yyyymm')||'01000001', 'yyyymmddhh24miss') 
      and  pmtime <= to_date(to_char(trunc(Last_day(sysdate)),'yyyymmdd')||'235959', 'yyyymmddhh24miss')  
  );
  END;
  
END;
/

