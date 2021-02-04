CREATE OR REPLACE PROCEDURE HRBZLS."PRC_SBXX"
(
    VS_OBJECT      IN     VARCHAR2,           -- 资源ID           列表
    VS_COMPANYID   IN     VARCHAR2,           -- 营业公司ID         ...
    VS_DIZHI       IN     VARCHAR2,           -- 地址               ..
    VS_HUMING      IN     VARCHAR2,           -- 户名
    VN_YHH         IN     VARCHAR2,           -- 用户号
    VS_ZKH         IN     VARCHAR2,           -- 账卡号
    VS_SBBH        IN     VARCHAR2,           -- 水表编号           ..
    VS_SBCS        IN     VARCHAR2,           -- 水表厂商
    VN_SBKJ        IN     VARCHAR2,           -- 水表口径
    VS_JZQH        IN     VARCHAR2,           -- 集中器号
    VS_YSXZ        IN     VARCHAR2,           -- 用水性质    code 转换
    VS_CJLX        IN     VARCHAR2,           -- 采集类型    0 远传 1 集抄
    VS_BEGIN       IN     VARCHAR2,           -- 统计月份 add 170615
    VS_END         IN     VARCHAR2,           -- 统计月份 add 170615
    VS_UPLOADTYPE  IN     VARCHAR2,           -- 数据推送类型
    VN_PAGE        IN     NUMBER,             -- 分页
    VN_ROWS        IN     NUMBER,             -- 每页行数
    VN_SORTNAME    IN     VARCHAR2,           -- 排序字段
    VN_SORTORDER   IN     VARCHAR2,           -- 排序方式
    VCUR           OUT    SYS_REFCURSOR,       -- 输出结果集  
    VS_SBTS        IN     VARCHAR2            -- 水表是否推送
)

IS
   -- VS_YSXZ2              VARCHAR2(32767);
    VS_SQL                VARCHAR2(32767);
    VS_SQL1               VARCHAR2(32767);
    VS_SQL2               VARCHAR2(32767);
    VS_SQL3               VARCHAR2(32767);
    VS_SQL4               VARCHAR2(32767);
    VS_SQL5               VARCHAR2(32767);
    VS_SQL6               VARCHAR2(32767);
    VS_SQL7               VARCHAR2(32767);
    V_RETINFO             VARCHAR2(4000);
BEGIN
    --解析输入参数
    IF VS_OBJECT IS NOT NULL THEN
       VS_SQL1 := VS_SQL1 || CHR(13)||' AND COMPANYID IN (SELECT RESOURCEID FROM BASE_DATASCOPEPERMISSION WHERE OBJECTID IN ('||VS_OBJECT||'))';
    END IF;
    IF VS_COMPANYID IS NOT NULL THEN -- 营业公司ID
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND COMPANYID IN ('||VS_COMPANYID||')';
    END IF;
    IF VS_DIZHI IS NOT NULL THEN     -- 地址
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND INSTR(WMETERADDRESS,'''||VS_DIZHI||''') <> 0';
    END IF;
    IF VS_HUMING IS NOT NULL THEN    -- 户名
      VS_SQL2 := VS_SQL2 || CHR(13)||' AND INSTR(户名,'''||VS_HUMING||''') <> 0';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND INSTR(C.HM,'''||VS_HUMING||''') <> 0';
      --VS_SQL2 := VS_SQL2 || CHR(13)||' AND 户名 = '''||VS_HUMING||'''';
      --VS_SQL4 := VS_SQL4 || CHR(13)||' AND C.HM = '''||VS_HUMING||'''';
    END IF;
    IF VN_YHH IS NOT NULL THEN       -- 用户号
      VS_SQL2 := VS_SQL2 || CHR(13)||' AND 用户编号 = '''||VN_YHH||'''';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND NVL(T.USERCODE,C.YHBH) = '''||VN_YHH||'''';
    END IF;
    IF VS_ZKH IS NOT NULL THEN       -- 帐卡号
      VS_SQL2 := VS_SQL2 || CHR(13)||' AND INSTR(帐卡号, '''||VS_ZKH||''') <> 0';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND INSTR(C.ZKH, '''||VS_ZKH||''') <> 0';
    END IF;
    IF VS_SBBH IS NOT NULL THEN       -- 水表编号
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND WATERMETERCODE = '''||VS_SBBH||'''';
      VS_SQL2 := VS_SQL2 || CHR(13)||' AND 水表编号 = '''||VS_SBBH||'''';
    END IF;
    IF VS_SBCS IS NOT NULL THEN      -- 水表厂商
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND WMETERFACTORY IN ('||VS_SBCS||')';
    END IF;
    IF VN_SBKJ IS NOT NULL THEN      -- 水表口径
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND WMETERCALIBER IN ('||VN_SBKJ||')';
    END IF;
    IF VS_JZQH IS NOT NULL THEN      -- 集中器号
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND CONCENTRATORID like '''||VS_JZQH||'%''';
    END IF;
    IF VS_UPLOADTYPE = '0' or VS_UPLOADTYPE = '1' THEN      -- 数据上传类型
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND automaticupload = '''||VS_UPLOADTYPE||'''';
    ELSIF VS_UPLOADTYPE = '-1' THEN
      VS_SQL1 := VS_SQL1 || CHR(13)||' AND automaticupload IS NULL';
    END IF;
    IF VS_YSXZ IS NOT NULL THEN       -- 用水性质
      --获取用水性质中文
     -- EXECUTE IMMEDIATE 'SELECT FULLNAME FROM BASE_DATADICTIONARYDETAIL WHERE DATADICTIONARYID = LOWER(''7d085228-5a11-4b44-8eb7-eeaa864ba461'') AND CODE = :1' INTO VS_YSXZ2 USING VS_YSXZ;
      VS_SQL2 := VS_SQL2 || CHR(13)||' AND 用水性质 IN('||VS_YSXZ||')';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND C.YSXZ IN('||VS_YSXZ||')';
     
    END IF;
    -- 2017-9-19 modify by sxn 直接与 BASE_WATERMETER.COLLENTTYPE 比对
    IF VS_CJLX = '0' THEN      -- 采集类型 0 远传 1 集抄 BASE_WATERMETERINFO.WMETERPERSON = '000000' 为远传，其他为集抄
      --VS_SQL3 := VS_SQL3 || CHR(13)||' AND WMETERPERSON = ''000000''';
      --VS_SQL4 := VS_SQL4 || CHR(13)||' AND T1.WMETERPERSON = ''000000''';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND T.COLLENTTYPE = ''0''';
    ELSIF VS_CJLX = '1' THEN
      --VS_SQL3 := VS_SQL3 || CHR(13)||' AND NVL(WMETERPERSON,'' '') <> ''000000''';
      --VS_SQL4 := VS_SQL4 || CHR(13)||' AND NVL(T1.WMETERPERSON,'' '') <> ''000000''';
      VS_SQL4 := VS_SQL4 || CHR(13)||' AND T.COLLENTTYPE = ''1''';
    END IF;
    IF VS_SQL1 IS NOT NULL THEN
       VS_SQL3 := CHR(13)||' AND EXISTS (SELECT 0 FROM S WHERE WMETERCODE = S.WATERMETERCODE)';
    END IF;
    IF VS_BEGIN IS NOT NULL THEN 
       VS_SQL5 := '  and READWMETERDATE >=TO_DATE('''||VS_BEGIN||''',''yyyy-mm-dd hh24:mi:ss'') and READWMETERDATE <=TO_DATE('''||VS_END||''',''yyyy-mm-dd hh24:mi:ss'')';
       VS_SQL6 := '  and 1=1';
    END IF;
/*      -- 水表是否推送
    IF VS_SBTS IS NOT NULL THEN 
        VS_SQL7 := VS_SQL7 || CHR(13)||' AND WATERPROPELLINGFLAG = ''1''';
    END IF;*/

    --
   -- IF VS_MONTH IS  NULL THEN
   --    VS_SQL5 := 'and 1=1';
   --    VS_SQL6 := 'and 1=1';
   -- ELSIF VS_MONTH IS NOT NULL AND SYSDATE - TO_DATE(VS_MONTH || '16','yyyy-mm-dd') < 0   THEN 
   --    VS_SQL5 := 'and 1=2';
   --    VS_SQL6 := 'and 1=2';
   -- ELSE
    --   VS_SQL5 := 'and READWMETERDATE >= DATE '''|| VS_MONTH || '-01' ||''' and READWMETERDATE <  DATE '''|| VS_MONTH || '-16' ||''''  ;
    --   VS_SQL6 := 'and 1=1';
   -- END IF;
    VS_SQL :=
    'WITH S AS
    (SELECT /*+NO_PARALLEL*/* 
       FROM BASE_WATERMETER
      WHERE 1 = 1 '||VS_SQL1 || VS_SQL6||'
        AND DELETEMARK = 0
    )
    SELECT
        T.MID,
        T.COMPANYID,                            --营业公司ID 
        D.FULLNAME COMPANYNAME,                 --营业公司名
        NVL(T.USERCODE,C.YHBH) YHBH,            --用户编号 BASE_WATERMETER.USERCODE为空，取HRBZLS.V_YK_USERINFO.用户编号
        C.HM,                                   --用户名
        C.ZKH,                                  --账卡号
        T.WATERMETERCODE,                       --水表编号 
        T.WMETERADDRESS,                        --水表地址 
        T.WMETERCALIBER,                        --水表口径 
        --T1.READWMETERDATE,
        DECODE(NVL(T1.WMETERNUMBER,0), 0, FUN2(T1.WMETERCODE, T1.READWMETERDATE), T1.READWMETERDATE) READWMETERDATE,                      --最后抄表时间
        DECODE(NVL(T1.WMETERNUMBER,0), 0, FUN1(T1.WMETERCODE, T1.READWMETERDATE), T1.WMETERNUMBER) WMETERNUMBER,                        --最后抄表表示数
        T1.CREATEDATE,                          --数据上传时间
        T1.CREATEUSERNAME,                      --创建用户
        C.YSXZ,                                 --用水性质
        T.WMETERFACTORY,                        --水表厂商 
        A.FULLNAME WMETERFACTORYNAME,           --水表厂商描述 
        --
       /* DECODE(T1.WMETERPERSON,''000000'',''远传'',''集抄'') */E.FULLNAME COLLENTTYPE,                --采集类型
        T.CONCENTRATORID,                       --集中器ID
        (case T.automaticupload when ''1'' then ''自动'' when ''0'' then ''手动'' else ''不推送'' end) as uploadtype,    --上传类型
        (case T1.DATAPROPELLINGFLAG when ''1'' then ''是'' else ''否'' end) as DATAPROPELLINGFLAG,                  --数据是否上传过
        (case T2.WATERPROPELLINGFLAG when ''1'' then ''是'' else ''否'' end) as WATERPROPELLINGFLAG,                --水表是否推送过数据
        F.FULLNAME  WMETERSTATE,                --水表状态
        --2017/10/25 ADD BY SXN 首次上传时间
        (SELECT MIN(S.READWMETERDATE) FROM BASE_WATERMETERINFO_FINAL S WHERE S.WMETERCODE = T.WATERMETERCODE) FIRSTUPLOADDATE   --首次抄表时间
      FROM S  T, 
           (SELECT TT.WMETERCODE, READWMETERDATE, CREATEDATE,CREATEUSERNAME, WMETERNUMBER, WMETERPERSON,DATAPROPELLINGFLAG,WATERPROPELLINGFLAG,wmeterstate
              FROM BASE_WATERMETERINFO_FINAL TT
              --FROM BASE_WATERMETER TT
             WHERE 1 = 1
               --AND WMETERNUMBER = 0     --2017/10/25 ADD BY SXN  过滤水表读数为0的记录
               AND READWMETERDATE = (SELECT MAX(READWMETERDATE) 
                                       FROM BASE_WATERMETERINFO_FINAL 
                                       --FROM BASE_WATERMETER TT
                                      WHERE WMETERCODE = TT.WMETERCODE '||VS_SQL5||'
                                    ) '||VS_SQL3||'
           )  T1,
           (SELECT WMETERCODE, NVL(MAX(WATERPROPELLINGFLAG),0) WATERPROPELLINGFLAG
              FROM BASE_WATERMETERINFO_FINAL
             WHERE READWMETERDATE >= TRUNC(SYSDATE,''MM'')
               AND READWMETERDATE < ADD_MONTHS(TRUNC(SYSDATE,''MM''),+1)
             GROUP BY WMETERCODE
           ) T2,
           (
              -- 水表状态
              SELECT CODE, FULLNAME
                FROM BASE_DATADICTIONARYDETAIL
               WHERE DATADICTIONARYID = LOWER(''fe2f7772-caec-497e-89c2-8ad2a0908262'')
           ) F,
           (
              -- 厂家
              SELECT CODE, FULLNAME
                FROM BASE_DATADICTIONARYDETAIL
               WHERE DATADICTIONARYID = LOWER(''36a01f67-3815-4f35-87ec-1ca6a08149f9'')
           )  A,
           (
              -- 水表类型
              SELECT CODE, FULLNAME
                FROM BASE_DATADICTIONARYDETAIL
               WHERE DATADICTIONARYID = LOWER(''683edc6d-75f7-4ba1-bd46-3f7ab46318de'')
           )  B,
           (
              -- 采集类型
              SELECT CODE, FULLNAME
                FROM BASE_DATADICTIONARYDETAIL
               WHERE DATADICTIONARYID = LOWER(''e1f72084-337e-4877-ac10-dfcd1571d6b4'')
           ) E,
           (SELECT 用户编号           YHBH, 
                   户名               HM, 
                   帐卡号             ZKH, 
                   水表编号           SBBH,
                   用水性质           YSXZ
              FROM YK_YS_DATA  B
             WHERE 水表编号 IS NOT NULL '||VS_SQL2||'
           )  C,
           BASE_COMPANY  D
      WHERE T.WATERMETERCODE = T1.WMETERCODE(+) --AND T1.WMETERNUMBER = 0
        AND T.WATERMETERCODE = T2.WMETERCODE(+)
        AND UPPER(case when isNumber(T1.WMETERSTATE) =1then
          to_char(trunc(T1.WMETERSTATE, 0))
         else
          T1.WMETERSTATE
       end)= F.CODE(+)
        /*AND UPPER(T1.WMETERSTATE) = F.CODE(+)*/
        AND T.WMETERFACTORY = A.CODE(+)
        AND T.WMETERTYPE = B.CODE(+)
        AND T.WATERMETERCODE = C.SBBH(+)
        AND T.COMPANYID = D.COMPANYID(+)
        AND T.COLLENTTYPE = E.CODE(+) '||VS_SQL4;
    -- 前台展现
    VS_SQL :=
    'SELECT *
       FROM (SELECT A.*, ROWNUM ORDERNO
               FROM (SELECT T.*, COUNT(1) OVER() CNT
                       FROM ('||VS_SQL||') T
                     -- ORDER BY COMPANYNAME, MID
                       -- ORDER  BY nvl(WMETERNUMBER,0) desc
                       ORDER  BY nvl(READWMETERDATE,to_date(''19000101'',''yyyymmdd'')) desc
                    ) A
              WHERE ROWNUM <= :1 * :2

            )
      WHERE ORDERNO > :3 * :4             
      ORDER BY '||VN_SORTNAME||' '||VN_SORTORDER||'';
    DBMS_OUTPUT.PUT_LINE(VS_SQL);
    OPEN VCUR FOR VS_SQL USING  NVL(VN_PAGE,1), NVL(VN_ROWS,100), NVL(VN_PAGE,1)-1, NVL(VN_ROWS,100);
    
EXCEPTION
    WHEN OTHERS THEN
        V_RETINFO := SQLERRM || '  ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE; --存储过程报错提示错误所在行。
        ROLLBACK;
        OPEN VCUR FOR SELECT V_RETINFO COMPANYNAME FROM DUAL;
        RETURN;
END;
/

