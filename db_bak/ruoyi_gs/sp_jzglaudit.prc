CREATE OR REPLACE PROCEDURE SP_JZGLAUDIT(P_WORKID IN VARCHAR2) AS
  --V_CIID  VARCHAR2(50);
  --V_MIID  VARCHAR2(50);
  V_MIRORDER  VARCHAR2(060);
  V_FLAGC     NUMBER;
  V_FLAGM     NUMBER;
	V_CIDBBS    NUMBER;
BEGIN

  FOR JZGL IN (SELECT *
                 FROM REQUEST_JZGL
                WHERE ENABLED = 5
                  AND WORKID = P_WORKID) LOOP
    DBMS_OUTPUT.PUT_LINE(JZGL.RENO);
    SELECT COUNT(1) INTO V_FLAGC FROM BS_CUSTINFO WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGC);
    SELECT COUNT(1) INTO V_FLAGM FROM BS_METERINFO WHERE MIID = JZGL.MIID;
    DBMS_OUTPUT.PUT_LINE(V_FLAGM);
		SELECT COUNT(1) INTO V_CIDBBS FROM REQUEST_JZGL WHERE CIID = JZGL.CIID;
    DBMS_OUTPUT.PUT_LINE(V_CIDBBS);
  
    -----BS_CUSTINFO
    IF V_FLAGC = 0 THEN
      INSERT INTO BS_CUSTINFO
        (CIMTEL,  --移动电话
         CITEL1,  --电话1
         CICONNECTPER,  --联系人
         CIIFINV,  --是否普票
         CIIFSMS,  --是否提供短信服务
         MICHARGETYPE,  --类型（1=坐收，2=走收,收费方式）
         MISAVING,  --预存款余额
         CIID,  --用户号
         CINAME,  --用户名
         CIADR,  --用户地址
         CISTATUS,  --用户状态【syscuststatus】
         CIIDENTITYLB,  --证件类型
         CIIDENTITYNO,  --证件号码
         CISMFID,  --营销公司
         CINEWDATE,  --立户日期
         CISTATUSDATE,  --状态日期
         CIDBBS,  --是否一户多表
         CIUSENUM,  --户籍人数
         CIAMOUNT,  --户数
         CIPASSWORD)  --用户密码
        SELECT CIMTEL,  --移动电话
               CITEL1,  --电话1
               CICONNECTPER,  --联系人
               CIIFINV,  --是否普票
               CIIFSMS,  --是否提供短信服务
               MICHARGETYPE,  --类型（1=坐收，2=走收,收费方式）
               0,  --预存款余额
               CIID,  --用户号
               CINAME,  --用户名
               CIADR,  --用户地址
               CISTATUS,  --用户状态【syscuststatus】
               CIIDENTITYLB,  --证件类型(1-身份证 2-营业执照  0-无)
               CIIDENTITYNO,  --证件号码
               RESMFID,  --营销公司
               SYSDATE,  --立户日期
               MODIFYDATE,  --修改时间
               CASE WHEN V_CIDBBS='1' THEN 'N' ELSE 'Y' END,  --是否一户多表
               CIUSENUM,  --户籍人数
               CIAMOUNT,  --户数
               '123456'  --用户密码
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERINFO
    IF V_FLAGM = 0 THEN
      INSERT INTO BS_METERINFO
        (MIID,  --水表档案编号
         MIADR,  --表地址
         MICODE,  --用户号
         MISMFID,  --营销公司(SYSMANAFRAME)
         MIBFID,  --表册(bookframe)
         MIRORDER,  --抄表次序
         MIPID,  --上级水表编号
         MICLASS,  --水表级次
         MIRTID,  --抄表方式【sysreadtype】
         MISTID,  --行业分类【metersortframe】
         MIPFID,  --用水性质(priceframe)
         MISTATUS,  --有效状态【sysmeterstatus】
         MISIDE,  --表位【syscharlist】
         MIINSCODE,  --新装起度
         MIINSDATE,  --装表日期
         MILH,  --楼号
         MIDYH,  --单元号
         MIMPH,  --门牌号
         MIXQM,  --小区名
         MIJD,  --街道
         MIYL13,  --街道号
         DQSFH,  --塑封号
         DQGFH,  --钢封号
         MICARDNO,  --卡片图号
         MIRCODE,  --本期读数
         MISEQNO,  --帐卡号（初始化时册号+序号，帐卡号）
         ISALLOWREADING)  --是否允许手工录入开关(0允许，1禁止)
        SELECT MIID,  --水表档案编号
               MIADR,  --表地址
               CIID,  --用户号
               RESMFID,  --营销公司
               MIBFID,  --表册(bookframe)
               MIRORDER,  --抄表次序
               MIPID,  --上级水表编号
               MICLASS,  --水表级次
               MIRTID,  --采集类型（原抄表方式【sysreadtype】）
               MISTID,  --行业分类【metersortframe】
               MIPFID,  --用水性质(priceframe)
               MISTATUS,  --水表状态【sysmeterstatus】
               MISIDE,  --表位【syscharlist】
               MIINSCODE,  --初始指针
               MIINSDATE,  --装表日期
               MILH,  --楼号
               MIDYH,  --单元号
               MIMPH,  --门牌号
               MIXQM,  --小区名
               MIJD,  --街道
               MIYL13,  --街道号
               DQSFH,  --塑封号
               DQGFH,  --钢封号
               MICARDNO,  --卡片图号
               MIINSCODE,  --初始指针
               MIBFID||SORTCODE MISEQNO,  --表册(bookframe)||序号
               '1'  --是否允许手工录入开关(0允许，1禁止)
          FROM REQUEST_JZGL
         WHERE RENO = JZGL.RENO;
    END IF;
    -----BS_METERDOC 更新表使用状态及变更日期
    UPDATE BS_METERDOC B
       SET MDID        =
           (SELECT A.MIID
              FROM REQUEST_JZGL A
             WHERE A.MDNO = B.MDNO
               AND A.RENO = JZGL.RENO),
           MDSTATUS     = 1,
           MDSTATUSDATE = SYSDATE
     WHERE EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.MDNO = B.MDNO
               AND C.RENO = JZGL.RENO);
  
    -----BS_METERFH_STORE 更新表身码及状态
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '1'
               AND A.DQSFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '1'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
    UPDATE BS_METERFH_STORE B
       SET BSM     =
           (SELECT A.MDNO
              FROM REQUEST_JZGL A
             WHERE B.FHTYPE = '2'
               AND A.DQGFH = B.METERFH
               AND A.RENO = JZGL.RENO),
           FHSTATUS = 1
     WHERE B.FHTYPE = '2'
       AND EXISTS (SELECT 1
              FROM REQUEST_JZGL C
             WHERE C.DQGFH = B.METERFH
               AND C.RENO = JZGL.RENO);
  
  END LOOP;
  V_MIRORDER := '0';
  COMMIT;
  IF V_MIRORDER ='0' THEN
    FOR I IN (SELECT MIBFID FROM REQUEST_JZGL WHERE ENABLED = 5 AND WORKID = P_WORKID) LOOP
    SP_METERINFO_MIRORDER(I.MIBFID,V_MIRORDER);
    END LOOP;
    END IF ;

END;
/

