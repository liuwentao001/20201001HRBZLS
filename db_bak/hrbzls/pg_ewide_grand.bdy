CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_GRAND" AS

上期评定月份              VARCHAR2(10);
本期评定周期              VARCHAR2(10);
起始月份                  VARCHAR2(10);
截止月份                  VARCHAR2(10);
评定数据生成标志      VARCHAR2(10);  

--单据审批
  PROCEDURE APPROVE(P_BILLID IN VARCHAR2,
                    P_OPER IN VARCHAR2,
                    P_BMID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
  IF P_DJLB='r' THEN
     --单据审批主过程
    SP_GRANDTRANS(P_DJLB,
                  P_BILLID,
                  P_OPER,
                  'N');
  END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END APPROVE;

--单据审核主流程
PROCEDURE SP_GRANDTRANS(P_DJLB IN VARCHAR2,       --单据类别
                        P_BILLNO IN VARCHAR2,     --单据号
                        P_OPER IN VARCHAR2,     --审核人
                        P_COMMIT IN VARCHAR2      --审核标志
                        ) IS
GH  GRANDBILLHD%ROWTYPE;
GD  GRANDBILLDT%ROWTYPE;
G   GRAND%ROWTYPE;

CURSOR C_GRAND IS 
SELECT * 
FROM GRANDBILLDT
WHERE GBDID=P_BILLNO
ORDER BY GBDROW;


BEGIN
--1、效验单据数据
--效验单头
  BEGIN
    SELECT * INTO GH FROM GRANDBILLHD WHERE GBHID = P_BILLNO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '评定单头信息不存在!');
  END;
--效验单体
  /*BEGIN
    SELECT * INTO GD FROM GRANDBILLDT WHERE GBDID = P_BILLNO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '评定单体信息不存在!');
  END;*/
--检查单据信息
  IF GH.GBHSHFLAG = 'Y' THEN
    RAISE_APPLICATION_ERROR(ERRCODE, '单据已经审核,不需重复审核!');
  END IF;
  
--2、根据单据数据更新用户级别
  OPEN C_GRAND;
  LOOP
    FETCH C_GRAND INTO GD;
    EXIT WHEN C_GRAND%NOTFOUND OR C_GRAND%NOTFOUND IS NULL;
    BEGIN
      SELECT * INTO G FROM GRAND WHERE GMICODE=GD.GBDCODE AND GBQFLAG='Y';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '评定表中不存在用户['||GD.GBDCODE||']信息不存在!');
    END;
    --检查评定表数据
    IF G.GFLAG = 'Y' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '用户['||GD.GBDCODE||']本期已评定,请检查数据！');
    END IF;
    
    --3、更新评定表标志和信息
    UPDATE GRAND 
    SET GFLAG='Y',                      --评定标志
        GDATE=TRUNC(SYSDATE),           --评定日期
        GRANKID=GD.GBDRANKID,           --下次标志
        GBILLID=GD.GBDID                --单据流水号
    WHERE GMICODE=GD.GBDCODE
          AND GBQFLAG='Y';
    IF SQL%ROWCOUNT<=0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '用户['||GD.GBDCODE||']更新本期评定表失败！');
    END IF;  
    --4、更新用户信息
    UPDATE METERINFO MI
    SET MI.MICOLUMN7 = GD.GBDRANKID
    WHERE MI.MICODE=GD.GBDCODE;
    IF SQL%ROWCOUNT<=0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '用户['||GD.GBDCODE||']更新用户信息表失败！');
    END IF;
  END LOOP;
  CLOSE C_GRAND;

  --5、更新单据信息
  UPDATE GRANDBILLHD
  SET GBHSHDATE=TRUNC(SYSDATE),
      GBHSHPER=P_OPER,
      GBHSHFLAG='Y'
  WHERE GBHID=GH.GBHID;
  
  --提交审核标志
  IF P_COMMIT='Y' THEN
     COMMIT;
  END IF;
  

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END;


--评定方法
--P_GRANDID 批次ID
/*********添加初步算费，欠费笔数及欠费金额********/
PROCEDURE SP_GRAND_FUNC(P_GRANDID IN VARCHAR2,  --单据批次号
                        P_SMFID   IN VARCHAR2,  --营业所
                        P_BFID    IN VARCHAR2,  --表册
                        P_CODE    IN VARCHAR2   --用户号
                        ) IS

type cursor_type is ref cursor;
c_rl1 cursor_type;
  
CURSOR C_RL IS
select gmicode,
       count(*),
       sum(rlsl),
       sum(rlje)
  from reclist,GRAND,meterinfo
   where rlmonth>=起始月份
   and rlmonth<=截止月份
   and rlpaidflag = 'N'
   and RLREVERSEFLAG='N'
   AND RLJE <> 0
   AND gmicode=rlmcode
   and gmicode=micode
   and GBQFLAG='Y'
   and GFLAG='N'
   --and ((mismfid = P_GRANDID and P_GRANDID is not null) or P_GRANDID is null)
   and ((mismfid = P_SMFID and P_SMFID is not null) or P_SMFID is null)
   and ((mibfid = P_BFID and P_BFID is not null) or P_BFID is null)
   and ((micode = P_CODE and P_CODE is not null) or P_CODE is null)
   
 group by gmicode;
 
V_G GRAND%ROWTYPE;
v_count   number(10);

--评级计算条件
v_qfbs    number(10);   --欠费笔数
v_qfbsqy  varchar2(10); --欠费笔数启用标志
v_qfje    number(12,3); --欠费金额
v_qfjeqy  varchar2(10); --欠费金额启用
v_jflag   number(10);   --降级标志
v_sflag   number(10);   --升级标志
v_jmemo    varchar2(200);  --降级备注
v_smemo    varchar2(200);  --升级备注

--拼接sql
v_sql varchar2(4000);
v_where varchar2(500);
BEGIN
  
   
   --1、检查数据初始化
   select count(*) into v_count 
   from GRAND
   where GBQFLAG='Y';
   if v_count<=0 then
      rollback;
      raise_application_error(-20012, '本期无评定数据产生，请先生成数据');
   end if;
   select nvl(spisedit,'#'),spvalue into v_qfbsqy,v_qfbs from syspara T where SPID='1107';
   select nvl(spisedit,'#'),spvalue into v_qfjeqy,v_qfje from syspara T where SPID='1108';
   v_sql := 'select gmicode,
       count(*),
       sum(rlsl),
       sum(rlje)
  from reclist,GRAND,meterinfo
   where rlmonth>='''||起始月份||'''
   and rlmonth<='''||截止月份||'''
   and rlpaidflag = ''N''
   and RLREVERSEFLAG=''N''
   AND RLJE <> 0
   AND gmicode=rlmcode
   and gmicode=micode
   and GBQFLAG=''Y''
   and GFLAG=''N''
   group by gmicode';
   --2、查询用户欠费情况更新到GRAND表中
    
   --
   IF P_GRANDID IS NOT NULL THEN
      v_where := v_where || ' AND GBILLID='''||P_GRANDID||'';
   END IF;
   
   --
   IF P_SMFID IS NOT NULL THEN
      v_where := v_where || ' AND MISMFID='''||P_SMFID||'';
   END IF;
   
   --
   IF P_BFID IS NOT NULL THEN
      v_where := v_where || ' AND MIBFID='''||P_BFID||'';
   END IF;
   
   --
   IF P_CODE IS NOT NULL THEN
      v_where := v_where || ' AND GMICODE='''||P_CODE||'';
   END IF;
   
   v_sql := v_sql || v_where;
   
   /*open c_rl;
   LOOP
       FETCH c_rl 
       INTO V_G.GMICODE,
            V_G.GQFBS,
            V_G.GQFSL,
            V_G.GQFJE;
       EXIT WHEN c_rl%NOTFOUND OR c_rl%NOTFOUND IS NULL;
       v_jflag := 0;
       v_sflag := 0;
       v_jmemo := '';
       v_smemo := '';
       --2.1、更新本期需评定数据
       update GRAND
       set GQFBS = NVL(V_G.GQFBS,0),
           GQFSL = NVL(V_G.GQFSL,0),
           GQFJE = NVL(V_G.GQFJE,0)
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       --2.2、根据评定参数做评定计算
       --欠费笔数评定是否启用
       if v_qfbsqy='Y' and v_qfbs is not null then
          if V_G.GQFBS>=to_number(v_qfbs) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || '欠费超过'||v_qfbs||'笔';
          else
             v_smemo  := v_smemo || '本期少于'||v_qfbs||'笔';
          end if;
       end if;
       if v_jmemo is not null then
          v_jmemo := v_jmemo||'/';
       end if;
       if v_smemo is not null then
          v_smemo := v_smemo||'/';
       end if;
       --欠费金额评定是否启用
       if v_qfjeqy='Y' and v_qfje is not null then
          if V_G.GQFJE>=to_number(v_qfje) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || '欠费超过'||v_qfje||'元';
          else
             v_smemo  := v_smemo || '本期欠费低于'||v_qfje||'元';
          end if;
       end if;
       
       if v_jflag>0 then
          --需降级
          --当前默认只降一级
          --上次级别号如果为空默认为3
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GMEMO=v_jmemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       else
          --需升级
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GMEMO=v_smemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       end if;
       COMMIT;
   end loop;
   close c_rl;*/
   
   open c_rl1 for v_sql;
   LOOP
       FETCH c_rl1 
       INTO V_G.GMICODE,
            V_G.GQFBS,
            V_G.GQFSL,
            V_G.GQFJE;
       EXIT WHEN c_rl1%NOTFOUND OR c_rl1%NOTFOUND IS NULL;
       v_jflag := 0;
       v_sflag := 0;
       v_jmemo := '';
       v_smemo := '';
       --2.1、更新本期需评定数据
       update GRAND
       set GQFBS = NVL(V_G.GQFBS,0),
           GQFSL = NVL(V_G.GQFSL,0),
           GQFJE = NVL(V_G.GQFJE,0)
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       --2.2、根据评定参数做评定计算
       --欠费笔数评定是否启用
       if v_qfbsqy='Y' and v_qfbs is not null then
          if V_G.GQFBS>=to_number(v_qfbs) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || '欠费超过'||v_qfbs||'笔';
          else
             v_smemo  := v_smemo || '本期少于'||v_qfbs||'笔';
          end if;
       end if;
       if v_jmemo is not null then
          v_jmemo := v_jmemo||'/';
       end if;
       if v_smemo is not null then
          v_smemo := v_smemo||'/';
       end if;
       --欠费金额评定是否启用
       if v_qfjeqy='Y' and v_qfje is not null then
          if V_G.GQFJE>=to_number(v_qfje) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || '欠费超过'||v_qfje||'元';
          else
             v_smemo  := v_smemo || '本期欠费低于'||v_qfje||'元';
          end if;
       end if;
       
       if v_jflag>0 then
          --需降级
          --当前默认只降一级
          --上次级别号如果为空默认为3
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GMEMO=v_jmemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       else
          --需升级
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GMEMO=v_smemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       end if;
       COMMIT;
   end loop;
   close c_rl1;
   
   --更新未评定数据
   update grand
   set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3')),
       GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))
   where GBQFLAG='Y' and
         GFLAG='N' and
         GRANKID is null;
   commit;
   
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

--创建基础数据
PROCEDURE SP_GRAND_CREATE IS
V_G GRAND%ROWTYPE;

CURSOR C_IGRAND IS
SELECT     NULL, --流水号 
           MI.MICODE,                             --客户代码 
           MI.MICOLUMN7,                          --级别id 
           G.GDATE,                               --上次评定时间 
           NULL,                                  --本次评定时间 
           'N',                                   --评定标志 
           起始月份,                              --起始月份 *
           截止月份,                              --截止月份  *
           MI.MICOLUMN7,                          --下次级别id  
           'Y',                                   --本期标志(如果到下个周期结转时该标志为n)
           'N',                                   --上期标志(如果到下个周期结转时该标志为y) 
           NULL,                                  --欠费笔数 
           NULL,                                  --欠费金额 
           NULL,                                  --本期表况次数 
           NULL,                                  --违约金笔数 
           NULL,                                  --违约金 
           NULL,                                  --缴费笔数 
           NULL,                                  --缴费金额（包含违约金、单缴月初） 
           NULL,                                  --单缴预存 
           NULL,                                  --代扣扣款未成功次数 
           NULL,                                  --托收扣款未成功次数 
           NULL,                                  --备注 
           NULL,                                  --单据号 
           TRUNC(SYSDATE),                         --创建日期 
           NULL,                                   --欠费水量
           GCOLUMNS1,
            GCOLUMNS2,
            GCOLUMNS3,
            GCOLUMNS4,
            GCOLUMNS5,
            GCOLUMNS6,
            GCOLUMNN1,
            GCOLUMNN2,
            GCOLUMNN3,
            GCOLUMNN4,
            GCOLUMNN5,
            MI.MICOLUMN7,
            GCOLUMNL2,
            GCOLUMNL3,
            GCOLUMNL4,
            GCOLUMNL5,
            GCOLUMND1,
            GCOLUMND2

   FROM METERINFO MI LEFT JOIN GRAND G ON (GSQFLAG='Y' AND MI.MICODE=G.GMICODE)
   WHERE MISTATUS='1';
BEGIN

  if 评定数据生成标志='Y' then
     rollback;
     raise_application_error(-20012, '本月数据已经生成，请先删除本期数据');
  end if;  
--1、上次评定数据标志改为N
  UPDATE GRAND
  SET GSQFLAG='N'
  WHERE GSQFLAG='Y';
--2、本次评定标志改为N，上次评定标志改为Y
  UPDATE GRAND
  SET GSQFLAG='Y',
      GBQFLAG='N'
  WHERE GBQFLAG='Y';
--生成本次评定数据
  OPEN C_IGRAND;
  LOOP
       FETCH C_IGRAND INTO V_G;
       EXIT WHEN C_IGRAND%NOTFOUND OR C_IGRAND%NOTFOUND IS NULL;
       SELECT SEQ_GRANDID.NEXTVAL INTO V_G.GID FROM DUAL;
       INSERT INTO GRAND VALUES V_G;
  END LOOP;
  CLOSE C_IGRAND;
  --更新本期数据生成标志为Y，该标志为Y不能重复生成数据
  update syspara
  set spvalue='Y'
  where spid='1109';  
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    --raise_application_error(-20012, '初始化数据错误!,事件发生：PG_EWIDE_GRAND.SP_GRAND_CREATE');
END;

--删除本期数据
PROCEDURE SP_GRAND_DELETE IS

v_count number(10);
BEGIN
      --1、检查本期是否存在已审核数据
      select count(*) into v_count 
      from GRAND
      WHERE GFLAG='Y' AND
            GBQFLAG='Y';
      IF v_count>0 THEN
         rollback;
         raise_application_error(-20012, '本期数据不允许删除，已存在审核单据');
      END IF;     
      --2、删除本期数据
      delete GRAND
      where GBQFLAG='Y';
      --3、更新本期数据标志 
      update syspara
      set spvalue='N'
      where spid='1109'; 
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

PROCEDURE SP_GRAND_CARRY IS

BEGIN
--1.将本次数据提交为上次
update grand
set GSQFLAG='N'
where GSQFLAG='Y';
update grand
set GBQFLAG='N',
    gsqflag='Y'
where GBQFLAG='Y';
--2.调整计算月份
update syspara
set SPVALUE=截止月份
where spid='1105';
null;
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

BEGIN
上期评定月份              := FSYSPARA('1105');
本期评定周期              := FSYSPARA('1106');
起始月份                  := to_char(add_months(to_date(FSYSPARA('1105'),'yyyy.mm'),1),'yyyy.mm');
截止月份                  := to_char(add_months(to_date(FSYSPARA('1105'),'yyyy.mm'),本期评定周期),'yyyy.mm');
评定数据生成标志          := FSYSPARA('1109');

END PG_EWIDE_GRAND;
/

