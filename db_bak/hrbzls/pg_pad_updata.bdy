CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_PAD_UPDATA IS

  /*
  * 功能：上传主函数
  * 创建人:曾海洲
  * 创建时间：2014-06-22
  * 修改人：  08001|00028|0560044063|2014-06-11|1890|30|正常|Y|8337|
  *            协议编号|协议长度|户号|抄表日期|抄见止码|抄见水量|抄表表况|波动审核|抄表员编号|抄表备注
              5|5|10|10|10|10|20|5|20|200
  * 修改时间：
  */
  procedure main(i_trans_code IN varchar2,
                 i_in_trans   IN VARCHAR2,
                 o_out_trans  OUT VARCHAR2) IS
  
    V_COUNT      NUMBER;
    V_LOG_TRANS  LOG_TRANS%ROWTYPE;
    V_TRANS_CODE NUMBER;
    V_SEQ        VARCHAR2(20);
  
  BEGIN
    --协议编号
    V_TRANS_CODE           := TO_NUMBER(SUBSTR(i_in_trans, 1, 5));
    V_LOG_TRANS.TRANS_CODE := V_TRANS_CODE;
    --插入日志信息
    SELECT SEQ_TRANS.NEXTVAL INTO V_SEQ FROM DUAL;
    V_LOG_TRANS.TRANS_TASK_NO     := V_SEQ;
    V_LOG_TRANS.TRANS_NOTE        := i_in_trans;
    V_LOG_TRANS.TRANS_HAPPEN_DATE := SYSDATE;
    V_LOG_TRANS.TRANS_INPUT_INFO  := '';
    INSERT INTO LOG_TRANS VALUES V_LOG_TRANS;
    COMMIT;
  
    if V_TRANS_CODE = 8001 then
      --哈尔滨暂时未使用
      f8001(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8002 then
      --用户资料上传
      f8002(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8003 then
      --抄表资料上传
      f8003(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8004 then
      --密码验证
      f8004(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8005 then
      --参数版本验证
      f8005(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8006 then
      --抄表取消协议
      f8006(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8007 then
      --用户巡检
      f8007(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8008 then
      --用户图片资料上传
      f8008(i_in_trans, V_SEQ, o_out_trans);
    end if;
  
  EXCEPTION
    WHEN OTHERS THEN
      rollback;
    
      if V_TRANS_CODE = 8001 then
        o_out_trans := '|999|08001';
      elsif V_TRANS_CODE = 8002 then
        o_out_trans := '|999|08002';
      elsif V_TRANS_CODE = 8003 then
        o_out_trans := '|999|08003';
      elsif V_TRANS_CODE = 8004 then
        o_out_trans := '|999|08004';
      elsif V_TRANS_CODE = 8005 then
        o_out_trans := '|999|08005';
      elsif V_TRANS_CODE = 8006 then
        o_out_trans := '|999|08006';
      elsif V_TRANS_CODE = 8007 then
        o_out_trans := '|999|08007';
      elsif V_TRANS_CODE = 8008 then
        o_out_trans := '|999|08008';
      end if;
      /*    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT = '0', T.TRANS_RETURN_NOTE = '上传失败'
       WHERE T.TRANS_TASK_NO = V_SEQ;*/
      o_out_trans := o_out_trans || sqlerrm;
      UPDATE LOG_TRANS T --返回888有可能资料延时，需重复上传资料.
         SET T.TRANS_RESULT = '999', T.TRANS_RETURN_NOTE = o_out_trans
       WHERE T.TRANS_TASK_NO = V_SEQ;
      /* raise_application_error( -20002, sqlerrm);
      dbms_output.put_line(sqlerrm);*/
      COMMIT;
    
  end;

  /*
  * 功能：8001协议
  * 创建人:曾海洲
  * 创建时间：2014-08-28
  * 修改人：  
  * 修改时间：
  */
  procedure f8001(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
    V_USER_NO    VARCHAR2(20);
    V_COPY_DATE  VARCHAR2(10);
    V_COPY_ECODE NUMBER;
    V_SUBMIT     VARCHAR2(2);
  
    V_COPY_SL         NUMBER;
    V_COPY_BK         VARCHAR2(20);
    V_COPER_MEMBER    VARCHAR2(20);
    v_cb_memo         varchar2(200);
    v_MRIFGU          meterread.mrifgu%type; --估抄标记 
    v_MRPRIVILEGEMEMO meterread.mrprivilegememo%type; --存放图片的名称
    -- v_count number;
    v_rlje    number(13, 0);
    v_message VARCHAR2(200);
    v_mrid    meterread.mrid%type;
    v_MRIFREC meterread.MRIFREC%type;
  
  begin
    return;
    --户号
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
    --抄表日期
    V_COPY_DATE := TRIM(SUBSTR(i_in_trans, 24, 10));
    --抄见止码
    V_COPY_ECODE := TRIM(SUBSTR(i_in_trans, 35, 10));
    --抄见水量
    V_COPY_SL := TRIM(SUBSTR(i_in_trans, 46, 10));
    --抄表表况
    V_COPY_BK := TRIM(SUBSTR(i_in_trans, 57, 20));
    --波动审核
    V_SUBMIT := TRIM(SUBSTR(i_in_trans, 78, 5));
    --抄表员编号
    V_COPER_MEMBER := TRIM(SUBSTR(i_in_trans, 84, 20));
    --抄表备注
    v_cb_memo := TRIM(SUBSTR(i_in_trans, 105, 200));
  
    /*     select count(*)
     into v_count
     from am_tie_off t
    where t.offmonth = TO_CHAR(SYSDATE, 'yyyy-MM')
      and t.smfid IN (select t1.copyer_dept_no
                       from fm_copyer t1
                      where t1.copyer_no = V_COPER_MEMBER
                        and t1.copyer_type = '1')
      and t.offstate = 'Y';
      */
    select MRID, MRIFREC
      into v_mrid, v_MRIFREC
      from METERREAD
     where mrmid = V_USER_NO; --是否已算费
  
    --v_count 表示当月已经扎账
    if v_MRIFREC = 'Y' then
      o_out_trans := '|999|08001';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,已算费',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
    else
      if to_char(sysdate, 'yyyy-MM') =
         to_char(to_date(V_COPY_DATE, 'yyyy-MM-dd'), 'yyyy-MM') then
        UPDATE METERREAD t
           SET mrdatasource = '9', --表示手机抄表上传
               MROUTFLAG    = 'N',
               mrinorder    = nvl(mrinorder, 0) + 1,
               mrindate     = sysdate,
               mrinputper   = V_COPER_MEMBER,
               --     mrifsubmit   = V_SUBMIT,  是否抄表审核放到营收来审核 20150313
               mrreadok = 'Y',
               --mrecodechar  = 处理止码位数问题(V_COPY_ECODE, MRMCODE),
               mrecodechar     = V_COPY_ECODE,
               MRSL            = V_COPY_SL,
               MRECODE         = V_COPY_ECODE,
               mrrdate         = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
               mrpdardate      = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
               mrinputdate     = sysdate,
               MRFACE         =
               (select SFLFLAG1 from sysfacelist2 t where sflid = V_COPY_BK), --查表表态
               mrface2         = V_COPY_BK, --检表表态
               mrmemo          = v_cb_memo,
               MRPRIVILEGEMEMO = v_MRPRIVILEGEMEMO, --用于手机图片名称
               MRIFGU          = v_mrifgu --估抄表标
         WHERE mrmid = V_USER_NO
           AND MRIFREC = 'N';
      
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '000',
               T.TRANS_RETURN_NOTE = '上传成功',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        o_out_trans := '|000|08001';
      else
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '111',
               T.TRANS_RETURN_NOTE = '跨月上传失败',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        o_out_trans := '|999|08001';
      end if;
    
    end if;
  
    COMMIT;
  
  end;

  /*
   * 功能：8002协议
   * 创建人:曾海洲 
   * 创建时间：2014-08-28
   *  协议编号|协议长度|单位号|联系人|联系电话|移动电话|抄表员编号|友情提醒|抄表备注
  　*　　5|5|10|50|20|20|20|50|200
   * 修改人：  
   * 修改时间：
   */
  procedure f8002(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    V_USER_NO         VARCHAR2(20);
    V_LINK_MAN        VARCHAR2(50);
    V_CONNECT_PHONE   VARCHAR2(20);
    V_TEL_PHONE       VARCHAR2(20);
    V_COPER_NO        VARCHAR2(20);
    V_apply_flag      VARCHAR2(20);
    V_YQTX            VARCHAR2(50);
    V_CBBZ            VARCHAR2(200);
    V_USERNm          VARCHAR2(60); --用户名称
    v_MIPFID          varchar2(10); --用水性质
    v_MDCALIBER       meterdoc.mdcaliber%type; --口径 
    v_MDNO            meterdoc.mdno%type; --表身码
    v_DQGFH           meterdoc.DQGFH%type; --刚封号
    v_DQSFH           meterdoc.DQSFH%type; --塑封号
    v_qfh             meterdoc.qfh%type; --铅封号
    v_JCGFH           meterdoc.JCGFH%type; --稽查封号
    v_MRREQUISITION   meterread.MRREQUISITION%type;
    v_MRPRIVILEGEFLAG meterread.MRPRIVILEGEFLAG%type; --工单申请状态
    v_MISIDE          meterinfo.miside%type; --表位置
    v_dy              char(1);
    v_cb_month        VARCHAR2(7); --抄表月份
    v_count           number;
    v_message         VARCHAR2(400);
    v_adr             meterinfo.miadr%type;
    v_mi              meterinfo%rowtype;
    v_ci              custinfo%rowtype;
    v_md              meterdoc%rowtype;
    v_ma              meteraccount%rowtype;
    v_type            CUSTCHANGEHD.CCHLB%type;
    v_apply_date      CUSTCHANGEHD.CCHCREDATE%type;
    v_apply_date1     VARCHAR2(20);
  
    --8002
    --新增|用户名称|用水性质|口径|表身码|刚封号|塑封号|铅封号|稽查封号|是否打印|抄表月份|用户地址|工单申请标志|表位置 
    --新增|60|30|5|20|40|40|20|40|1|7|100|20|20
  
  begin
    if length(i_in_trans) <> 825 then
      --户号
      V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
      --联系人
      V_LINK_MAN := TRIM(SUBSTRb(i_in_trans, 24, 50));
      --联系电话
      V_CONNECT_PHONE := TRIM(SUBSTR(i_in_trans, 75, 20));
      --移动电话
      V_TEL_PHONE := TRIM(SUBSTR(i_in_trans, 96, 20));
      --抄表员编号
      V_COPER_NO := TRIM(SUBSTR(i_in_trans, 117, 20));
      --友情提醒
      V_YQTX := TRIM(SUBSTR(i_in_trans, 138, 50));
      --用户备注
      V_CBBZ := TRIM(SUBSTR(i_in_trans, 189, 200));
      --用户名称
      V_USERNm := TRIM(SUBSTR(i_in_trans, 390, 60));
      --用水性质
      v_MIPFID := TRIM(SUBSTR(i_in_trans, 451, 30));
      --口径
      v_MDCALIBER := to_number(TRIM(SUBSTR(i_in_trans, 482, 2)));
      --表身码
      v_MDNO := TRIM(SUBSTR(i_in_trans, 485, 20));
      --刚封号
      v_DQGFH := TRIM(SUBSTR(i_in_trans, 506, 40));
      --塑封号
      v_DQSFH := TRIM(SUBSTR(i_in_trans, 547, 40));
      --铅封号
      v_qfh := TRIM(SUBSTR(i_in_trans, 588, 20));
      --稽查封号
      v_JCGFH := TRIM(SUBSTR(i_in_trans, 609, 40));
      --打印注记
      v_dy := TRIM(SUBSTR(i_in_trans, 650, 1));
      --本月是否下载
      v_cb_month := TRIM(SUBSTR(i_in_trans, 652, 7));
      -- 用户地址
      v_adr := TRIM(SUBSTR(i_in_trans, 660, 100));
      --申请工单用户申请状态 未申请   申请中   未通过   通过
      V_apply_flag := TRIM(SUBSTR(i_in_trans, 761, 20));
      --水表位置
      v_MISIDE := TRIM(SUBSTR(i_in_trans, 782, 20));
      --修改时间 
    
      begin
        v_apply_date := to_date(TRIM(SUBSTR(i_in_trans, 803, 20)),
                                'yyyymmddhh24miss');
      exception
        when others then
          v_apply_date := sysdate;
      end;
    
    else
      --户号
      V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
      --联系人
      V_LINK_MAN := TRIM(SUBSTRb(i_in_trans, 24, 50));
      --联系电话
      V_CONNECT_PHONE := TRIM(SUBSTR(i_in_trans, 75, 20));
      --移动电话
      V_TEL_PHONE := TRIM(SUBSTR(i_in_trans, 96, 20));
      --抄表员编号
      V_COPER_NO := TRIM(SUBSTR(i_in_trans, 117, 20));
      --友情提醒
      V_YQTX := TRIM(SUBSTR(i_in_trans, 138, 50));
      --用户备注
      V_CBBZ := TRIM(SUBSTR(i_in_trans, 189, 200));
      --用户名称
      V_USERNm := TRIM(SUBSTR(i_in_trans, 390, 60));
      --用水性质
      v_MIPFID := TRIM(SUBSTR(i_in_trans, 451, 30));
      --口径
      v_MDCALIBER := to_number(TRIM(SUBSTR(i_in_trans, 482, 5)));
      --表身码
      v_MDNO := TRIM(SUBSTR(i_in_trans, 488, 20));
      --刚封号
      v_DQGFH := TRIM(SUBSTR(i_in_trans, 509, 40));
      --塑封号
      v_DQSFH := TRIM(SUBSTR(i_in_trans, 550, 40));
      --铅封号
      v_qfh := TRIM(SUBSTR(i_in_trans, 591, 20));
      --稽查封号
      v_JCGFH := TRIM(SUBSTR(i_in_trans, 612, 40));
      --打印注记
      v_dy := TRIM(SUBSTR(i_in_trans, 653, 1));
      --本月是否下载
      v_cb_month := TRIM(SUBSTR(i_in_trans, 655, 7));
      -- 用户地址
      v_adr := TRIM(SUBSTR(i_in_trans, 663, 100));
      --申请工单用户申请状态 未申请   申请中   未通过   通过
      V_apply_flag := TRIM(SUBSTR(i_in_trans, 764, 20));
      --水表位置
      v_MISIDE := TRIM(SUBSTR(i_in_trans, 785, 20));
      --修改时间 
    
      begin
        v_apply_date := to_date(TRIM(SUBSTR(i_in_trans, 806, 20)),
                                'yyyymmddhh24miss');
      exception
        when others then
          v_apply_date := sysdate;
      end;
    
    end if;
  
    /*     BEGIN  
       select count(*) into v_count from  datadesign
         where 字典类型='本月是否下载' and 字典code =v_cb_month;
         if v_count= 0 then --判断本月是否有重新下载新数据
             v_message:='手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机'||v_cb_month;
           -- v_message:= v_apply_date;
                o_out_trans := '|999|08002' ;
            o_out_trans :=o_out_trans||'|'|| v_message ;
             UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
             commit; 
             return ;
         end if ;
    EXCEPTION
       WHEN OTHERS THEN
              v_message:='手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机';
              o_out_trans := '|999|08002' ;
            o_out_trans :=o_out_trans||'|'|| v_message ;
             UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
             commit; 
             return ;
    END ; */
    --apply_flag    未申请   申请中   未通过   通过  
    if V_apply_flag = '未申请' then
      V_MRPRIVILEGEFLAG := 'N';
    ELSIF V_apply_flag = '申请中' then
      V_MRPRIVILEGEFLAG := 'X';
    ELSIF V_apply_flag = '未通过' then
      V_MRPRIVILEGEFLAG := 'U';
    ELSIF V_apply_flag = '已通过' then
      V_MRPRIVILEGEFLAG := 'Y';
    END IF;
  
    if v_dy = 'Y' THEN
      v_MRREQUISITION := 1; --打印次数
    END IF;
  
    select * into v_mi from meterinfo where miid = V_USER_NO;
    select * into v_ci from custinfo where CIID = V_USER_NO;
    select * into v_md from meterdoc where MDMID = V_USER_NO;
    select * into v_ma from meteraccount where mamid = V_USER_NO;
    --'CF','厨房','GJ','管井','QT','其他','TJ','天井','CS','卫生间'
    /*    if v_MISIDE ='厨房' then  
      v_mi.miside :='CF';
    ELSIF v_MISIDE ='管井' then  
      v_mi.miside :='GJ';
    ELSIF v_MISIDE ='其它' then  
      v_mi.miside :='QT';
    ELSIF v_MISIDE ='天井' then  
      v_mi.miside :='TJ';
    ELSIF v_MISIDE ='卫生间' then  
      v_mi.miside :='CS'; 
    end if ;*/
    --直接从手机端过来
    v_mi.miside := v_MISIDE;
    --B 更名
    --C 收费方式
    ---D 过户
    --E 水价变更  
    ---X 用户水表信息维护          
    --Y 合收表维护
    --20 用户状态变更
    --W 水表档案变更
  
    if trim(V_USERNm) is null or trim(V_USERNm) = '' then
      --20150806 手机修改备注信息时，新的用户名未传过来,为空.所以自动赋值为原户名一致
      V_USERNm := v_mi.MINAME;
    end if;
    
    -- by 20190628 屏蔽手机发起水表档案
/*    if v_MDCALIBER = 0 or v_MDCALIBER = '' then
      v_MDCALIBER := v_md.MDCALIBER;
    end if;
  
    if trim(v_MDNO) is null or trim(v_MDNO) = '' then
      v_MDNO := v_md.MDNO;
    end if;
    if trim(v_DQGFH) is null or trim(v_DQGFH) = '' then
      v_DQGFH := v_md.DQGFH;
    end if;
  
    if trim(v_DQSFH) is null or trim(v_DQSFH) = '' then
      v_DQSFH := v_md.DQSFH;
    end if;
  
    if trim(v_qfh) is null or trim(v_qfh) = '' then
      v_qfh := v_md.qfh;
    end if;
    if trim(v_JCGFH) is null or trim(v_JCGFH) = '' then
      v_JCGFH := v_md.JCGFH;
    end if;*/
  
    if trim(v_MIPFID) is null or trim(v_MIPFID) = '' then
      v_MIPFID := v_mi.MIPFID;
    end if;
    if NVL(v_mi.MINAME, 'NULL') <> NVL(V_USERNm, 'NULL') then
      --产权名需走工单
      v_type := 'B'; ---B 更名
    end if;
    --暂时取消水表档案、用户水表信息维护
    /*if NVL(v_md.MDCALIBER, 0) <> NVL(v_MDCALIBER, 0) OR
       NVL(v_md.MDNO, 'NULL') <> NVL(v_MDNO, 'NULL') OR
       NVL(v_md.DQGFH, 'NULL') <> NVL(v_DQGFH, 'NULL') OR
       NVL(v_md.DQSFH, 'NULL') <> NVL(v_DQSFH, 'NULL') OR
       NVL(v_md.qfh, 'NULL') <> NVL(v_qfh, 'NULL') OR
       NVL(v_md.JCGFH, 'NULL') <> NVL(v_JCGFH, 'NULL') then
      --水表档案变更
      v_type := 'W'; ---W水表档案变更
    end if;*/
    --水价变更放在后面,如果同时变更更名及水价则统一走水价变更工单.只产生一笔工单
    if NVL(v_mi.MIPFID, 'NULL') <> NVL(v_MIPFID, 'NULL') then
      --用水性质需走工单
      v_type := 'E'; --E 水价变更 
    end if;
  
    /*    if NVL(v_ci.CICONNECTTEL,'NULL')<> NVL(V_CONNECT_PHONE,'NULL') OR  NVL(v_ci.CIMTEL,'NULL')<> NVL(V_TEL_PHONE,'NULL')  OR   NVL(v_ci.CICONNECTPER,'NULL')<>NVL(V_LINK_MAN,'NULL')   then --水表档案变更
        v_type:='X'; --- X用户水表信息维护
    end if ;*/
  
    /*  UPDATE METERREAD t
      SET  MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION ,
        MRPRIVILEGEFLAG =V_MRPRIVILEGEFLAG, --更改工单状态标志
        MRPRIVILEGEPER=v_MIPFID, --新用水性质
        MRPRIVILEGEMEMO =V_USERNm, --新户名
        MRPRIVILEGEDATE=v_apply_date  --作为修改时间使用 by ralph 20150429
    WHERE mrmid = V_USER_NO
      AND MRIFREC = 'N';*/
    update meterinfo
       set MIYL5  = V_MRPRIVILEGEFLAG,
           MIYL6  = v_MIPFID,
           MIJD   = V_USERNm,
           MIYL10 = v_apply_date
     where miid = V_USER_NO;
    --更新抄表备注
    /* UPDATE CM_METERREAD T
      SET T.MRMEMO = V_CBBZ
    WHERE T.MRMID = V_USER_NO;*/
    v_md.MDCALIBER := v_MDCALIBER;
    v_md.MDNO      := v_MDNO;
    v_md.DQGFH     := v_DQGFH;
    v_md.DQSFH     := v_DQSFH;
    v_md.qfh       := v_qfh;
    v_md.JCGFH     := v_JCGFH;
  
    /*    update meterdoc
    set MDCALIBER =v_MDCALIBER,MDNO=v_MDNO, DQGFH=v_DQGFH, DQSFH=v_DQSFH, qfh=v_qfh,JCGFH=v_JCGFH
    where MDMID = V_USER_NO; */
    --上述需要产生工单因表身码、封号需要检查是否存在系统中
    --更新用户备注
    v_mi.MIMEMO     := V_CBBZ; --备注
    v_mi.MIPFID     := v_MIPFID; --用水性质
    v_mi.MINAME     := V_USERNm; --产权名
    --ADD ZB 2018-11-2
    --手机抄表屏蔽地址修改
    --v_mi.miadr      := v_adr; --地址
    --v_mi.miposition := v_adr; --地址
  
  --ADD ZB 2018-11-2
    --手机抄表屏蔽地址修改
    UPDATE METERINFO T
       SET T.MIMEMO = V_CBBZ,
           T.MISIDE = V_MI.MISIDE --表位置
           -- MIPFID=v_MIPFID,  --用水性质需走工单
           --  MINAME =V_USERNm,  --产权名更改需走工单
           --miadr      = v_adr,
           --miposition = v_adr
     WHERE T.MIID = V_USER_NO;
  
    --更新联系电话
    v_ci.CICONNECTTEL := V_CONNECT_PHONE;
    v_ci.CITEL1       := V_CONNECT_PHONE;
    v_ci.CIMTEL       := V_TEL_PHONE;
    v_ci.CICONNECTPER := V_LINK_MAN;
    --ADD ZB 2018-11-2
    --手机抄表屏蔽地址修改
    --v_ci.ciadr        := v_adr;
    v_ci.ciname       := V_USERNm;
    v_ci.ciname2      := V_USERNm;
    --ADD ZB 2018-11-2
    --手机抄表屏蔽地址修改
    UPDATE CUSTINFO T
       SET T.CICONNECTTEL = V_CONNECT_PHONE,
           --T.CITEL1       = V_CONNECT_PHONE,
           T.CIMTEL       = V_TEL_PHONE,
           T.CICONNECTPER = V_LINK_MAN
           --t.ciadr        = v_adr
     WHERE T.CIID IN
           (SELECT T1.MICID FROM METERINFO T1 WHERE T1.MIID = V_USER_NO);
    --
    /*MI IN METERINFO%ROWTYPE, --水表信息
    CI IN CUSTINFO%ROWTYPE,  --用户信息
    MD IN METERDOC%ROWTYPE,  --水表档案
    MA IN METERACCOUNT%ROWTYPE,--用户银行信息
    P_TYPE IN VARCHAR2,        --变更类型
    P_CCHCREPER in CUSTCHANGEhd.Cchcreper%type, --申请人
    P_MESSAGE OUT VARCHAR2   --出参*/
    IF TRIM(V_TYPE) IN ('E', 'B'/*, 'W'*/, 'X') THEN
      --手机抄表更改产权名、用水性质、口径基本信息系统自动产生工单
      select count(*)
        into v_count
        from operaccnt_level
       where oaid = V_COPER_NO; ---ralph by 20150615
      if v_count = 0 then
        v_message   := '此用户没有进行抄表员对应关系调整!';
        o_out_trans := '|999|08002';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '此用户没有进行抄表员对应关系调整!',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
      end if;
      PRO_TELSJCB(V_MI, V_CI, V_MD, V_MA, V_TYPE, V_COPER_NO, v_message);
    END IF;
    IF v_message IS NULL OR v_message = '' THEN
      v_message := '上传成功' || '--' || V_TYPE;
    ELSE
      --  v_message:=v_message;
      o_out_trans := '|999|08002';
      o_out_trans := o_out_trans || '|' || v_message;
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = v_message,
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      commit;
      return;
    END IF;
    UPDATE LOG_TRANS T
       SET T.TRANS_RESULT      = '000',
           T.TRANS_RETURN_NOTE = v_message,
           T.TRANS_MIID        = V_USER_NO
     WHERE T.TRANS_TASK_NO = i_SEQ;
    o_out_trans := '|000|08002';
    COMMIT;
  end;

  /*
  * 功能：8003协议  
   手机抄表确定（抄表数据给营收） -> 营收 (根据抄表数据进行算费，结果传回手机) -> 手机（接收算费结果） 打印催费通知单
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */
  procedure f8003(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    V_USER_NO         VARCHAR2(20);
    V_COPY_DATE       VARCHAR2(20);
    V_COPY_ECODE      NUMBER;
    V_SUBMIT          VARCHAR2(2);
    V_MRIFSUBMIT      meterread.mrifsubmit%type;
    V_COPY_SL         NUMBER;
    V_COPY_BK         VARCHAR2(20);
    V_COPER_MEMBER    VARCHAR2(20);
    v_cb_memo         varchar2(200);
    v_MRIFGU          meterread.mrifgu%type; --估抄标记 
    v_MRPRIVILEGEMEMO meterread.mrprivilegememo%type; --存放图片的名称
    v_count           number;
    v_rlje            number(13, 0);
    v_message         VARCHAR2(400);
    v_mrid            meterread.mrid%type;
    v_MRIFREC         meterread.MRIFREC%type;
    v_MRREQUISITION   meterread.MRREQUISITION%type;
    V_mrreadok        meterread.mrreadok%type;
    v_MRSMFID         meterread.MRSMFID%type;
    v_ssly            VARCHAR2(20); --示数来源
    v_dy              char(1);
    v_字典code        datadesign.字典code%type;
    v_mistatus        meterinfo.mistatus%type; --用户状态
    v_MRTHREESL       meterread.MRTHREESL%type; --波动审核量
    v_mrchkresult     meterread.mrchkresult%type; --查表结果
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --倒表设置 'Y'--为Y倒表
    v_MRSCODE         meterread.mrscode%type; --起始指针
    v_MRSL            meterread.mrsl%type; --抄表水量
    v_mrface          meterread.mrface%type; --表态
    v_MROUTFLAG       meterread.MROUTFLAG%type; --发出到抄表机标志
    v_MICLASS         meterinfo.MICLASS%type; --总分表 2-总表3-分表
    v_MIPID           meterinfo.MIPID%type; --总表号码 3时为总表
    v_MIPRIID         meterinfo.MIPRIID%type; --合收主表号
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --合收表标志
    v_mipfid          meterinfo.mipfid%type; --水价类别
    v_pfprice         priceframe.pfprice%type; --金额
    v_cb_month        VARCHAR2(7); --抄表月份
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --等针标志
    v_mrdzcurcode meterread.mrdzcurcode%type; --等针用户实际读数
    v_mrdzsl      meterread.mrdzsl%type; --等针用量
    v_miyl9       meterinfo.miyl9%type; --水表量程
    v_mrreadok_pz     VARCHAR2(1);  --照片审核
    V_SHBZ            VARCHAR2(1);  --照片审核
  begin
    --户号
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
    --抄表日期
    V_COPY_DATE := TRIM(SUBSTR(i_in_trans, 24, 20));
    --抄见止码
    V_COPY_ECODE := TRIM(SUBSTR(i_in_trans, 45, 10));
    --抄见水量
    V_COPY_SL := TRIM(SUBSTR(i_in_trans, 56, 10)); --20150320取消,水量由营收来计算
    --抄表表况
    V_COPY_BK := TRIM(SUBSTR(i_in_trans, 67, 20));
    --波动审核
    V_SUBMIT := TRIM(SUBSTR(i_in_trans, 88, 5));
    --抄表员编号
    V_COPER_MEMBER := TRIM(SUBSTR(i_in_trans, 94, 20));
    --抄表备注
    -- v_cb_memo := TRIM(SUBSTR(i_in_trans, 105, 200));
    v_cb_memo := TRIM(SUBSTR(i_in_trans, 115, 200)); --20150325
    --是否有照片更新审核
    v_mrreadok_pz := TRIM(SUBSTR(i_in_trans, 345, 1));
    IF v_mrreadok_pz ='N' THEN
      V_SHBZ :='Y';
    ELSIF v_mrreadok_pz ='Y' THEN
      V_SHBZ :='X';
    END IF;
    if v_cb_memo = 'NNUULL' THEN
      --手机抄表传入NNUULL
      v_cb_memo := '';
    END IF;
    --抄表示数来源 见表 1 估抄2  电话件 3  未见表4
    v_ssly := TRIM(SUBSTR(i_in_trans, 316, 20));
    if v_ssly = '见表' then
      v_MRIFGU := '1';
    elsif v_ssly = '估抄' then
      v_MRIFGU := '2';
    elsif v_ssly = '电话件' then
      v_MRIFGU := '3';
    elsif v_ssly = '未见表' then
      v_MRIFGU := '4';
    end if;
    v_cb_month := TRIM(SUBSTR(i_in_trans, 337, 7)); --本月是否下载
  
    BEGIN
      select count(*)
        into v_count
        from datadesign
       where 字典类型 = '本月是否下载'
         and 字典code = v_cb_month;
      if v_count = 0 then
        --判断本月是否有重新下载新数据
        v_message   := '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        v_message   := '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '手机抄表数据为上次抄表月数据,请重新下载数据到手机抄表机',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
    END;
  
    /*    if to_char(sysdate,'yyyy-MM') = to_char(to_date(V_COPY_DATE,'yyyy-MM-dd'),'yyyy-MM') then
        v_message:='';
          o_out_trans := '|999|08003'||v_message;
         UPDATE LOG_TRANS T
          SET T.TRANS_RESULT      = '999',
              T.TRANS_RETURN_NOTE = '未找到抄表资料',
              T.TRANS_MIID        = V_USER_NO
        WHERE T.TRANS_TASK_NO = i_SEQ;
         commit; 
         return ;
    end if ;*/
  
    BEGIN
      select mr.MRID,
             mr.MRIFREC,
             mr.MRSMFID,
             mr.mrreadok,
             mi.mistatus,
             mr.MRTHREESL,
             mr.MRIFSUBMIT,
             mr.mrchkresult,
             md.ifdzsb,
             mr.MRSCODE,
             mi.MICLASS,
             mi.MIPID,
             mi.MIPRIID,
             mi.MIPRIFLAG,
             mr.mrdatasource,
             mr.mrface,
             mi.mipfid,
             mi.mircode, --是否已算费
             NVL(mr.mrdzflag, 'N'), --等针标志
             NVL(mr.mrdzcurcode, 0), --等针用户实际读数
             mi.miyl9 --水表量程
        into v_mrid,
             v_MRIFREC,
             v_MRSMFID,
             V_mrreadok,
             v_mistatus,
             v_MRTHREESL,
             V_MRIFSUBMIT,
             v_mrchkresult,
             v_ifdzsb,
             v_MRSCODE,
             v_MICLASS,
             v_MIPID,
             v_MIPRIID,
             v_MIPRIFLAG,
             v_mrdatasource,
             v_mrface,
             v_mipfid,
             v_mircode,
             v_mrdzflag,
             v_mrdzcurcode,
             v_miyl9
        from METERREAD mr, meterinfo mi, meterdoc md
       where mr.MRMID = mi.miid
         and mr.mrmid = md.MDMID
         and mr.mrmid = V_USER_NO;
    EXCEPTION
      WHEN OTHERS THEN
        v_message   := '未找到抄表资料';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '未找到抄表资料',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
    END;
  
    --追量管控
    /*select TO_CHAR(SYSDATE, 'YYYY.MM') into v_mrmonth from DUAL; 
    select count(rlcid)
      into v_count
      from reclist rl, meterreadhis mrs 
     where RLMRID = MRID
       and rltrans <> '13' --事物类别显示补缴，但是来源是追量的，补缴应该不进入控制 by 王伟20141112
       and mrs.mrmonth =v_mrmonth
       and rl.RLREVERSEFLAG <> 'Y'
       AND MRS.MRDATASOURCE = 'Z'
       and rlcid = V_USER_NO;
    
     if v_count > 0 then
            o_out_trans := '|999|08003';
          v_message:='上传失败,当月已产生追量，则不允许继续抄表';
      
           UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '上传失败,当月已产生追量，则不允许继续抄表',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
           o_out_trans :=o_out_trans||'|'|| v_message ;
           commit; 
           return ;
    end if ;
    */
    if v_mistatus = '24' then
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表编号正在故障换表中,不能进行算费';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,正在故障换表中',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mistatus = '35' then
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表编号正在周期换表中,不能进行算费';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,正在周期换表中',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mistatus = '36' then
      --预存冲正中
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表编号正在预存冲正中,不能进行算费';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,正在预存冲正中',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
    if v_mistatus = '19' then
      --正在销户
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表编号正在销户中,不能进行算费';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,此水表编号正在销户中',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    --byj add 
    if v_mistatus = '39' then
      --预存撤表退费中
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表编号正在预存撤表退费中,不能进行算费';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,正在预存撤表退费中',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mircode <> v_mrscode then
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此水表读数已经被改变,不能进行算费!';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,此水表读数已经被改变!',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    --byj end!
  
    if trunc(TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss')) > trunc(sysdate) then
      o_out_trans := '|999|08003';
      v_message   := '上传失败,抄表日期不能大于当前系统日期,上传算费失改';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,抄表日期不能大于当前系统日期,上传算费失改',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    
    end if;
  
    if fun_getsjcbmpmk(V_USER_NO, v_cb_month) = 'Y' THEN
      o_out_trans := '|999|08003';
      v_message   := '上传失败,此抄表周期内已经有上传图片且内勤已经审核通过,不允许再次抄表';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,此抄表周期内已经有上传图片且内勤已经审核通过,不允许再次抄表',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    END IF;
    -- if (v_MRIFREC ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'  ) or ( V_mrreadok ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'  )   then  --当月抄表有算费、抄表审核则不进行资料更新
  
    if (v_MRIFREC = 'Y' and v_mistatus <> '29' and v_mistatus <> '30') or
       (V_mrreadok = 'Y' and v_mistatus <> '29' and v_mistatus <> '30' and
       v_mrdatasource = '9') then
      --当月抄表有算费、抄表审核则不进行资料更新
      --v_MRIFREC 算费
      --V_mrreadok 抄见标志
    
      --V_mrreadok ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'固定量部份需重新算费打印催费通知单
      o_out_trans := '|999|08003';
      v_message   := '上传失败,已算费或已经抄表审核';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '上传失败,已算费或已经抄表审核',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    elsif V_mrreadok <> 'Y' AND v_MRIFREC <> 'Y' then
      --可以更新抄表资料 
      --更新当月抄表资料
      --  if to_char(sysdate,'yyyy-MM') = to_char(to_date(substrb(V_COPY_DATE,1,8),'yyyy-MM-dd'),'yyyy-MM')  or V_USER_NO ='3061018832' then
      --判断营业所是否需要抄表审核功能  1-需要审核 0-不需审核
      BEGIN
        select 字典code
          into v_字典code
          from datadesign
         where 字典类型 = '抄表审核'
           and 备注 = v_MRSMFID;
      EXCEPTION
        WHEN OTHERS THEN
          v_message   := '上传失败,抄表资料是否需要审核参数未找到';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '抄表资料是否需要审核参数未找到',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          return;
      END;
    
      if v_字典code = '0' OR v_mistatus = '29' OR v_mistatus = '30' then
        --判断营业所是否需要抄表审核功能  1-需要审核 0-不需审核
        V_mrreadok := 'Y'; --营业所设定不需审核,则系统自动审核    
        if v_mistatus <> '29' and v_mistatus <> '30' then
          v_MRCHKFLAG := 'Y';
          v_MRCHKDATE := sysdate;
          v_MRCHKPER  := V_COPER_MEMBER;
        end if;
      
      else
        v_MRCHKFLAG := 'N';
        v_MRCHKDATE := null;
        v_MRCHKPER  := null;
        --V_mrreadok  := 'X'; --营业所设定需审核,则系统自动不审核
        V_mrreadok  := V_SHBZ;  --如果没有照片则自动审核
      end if; --Y代表已经审核 X待审核 N-未处理
      -- 表况
      begin
        select SFLFLAG1
          into v_mrface --根据表况抓取表态
          from sysfacelist2 t
         where sflid = V_COPY_BK; --表况
      exception
        when others then
          v_message   := '上传失败,抄表资料根据表况抓取表态未找到';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '抄表资料根据表况抓取表态未找到',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          commit;
          return;
      end;
    
      if v_mrface = '01' then
        --表况正常 
        --倒表管控
        --20150320取消,水量由营收来计算
        /**正常表况下，止码比起码小可能有三种情况：
        *1、水表倒装2、等针3、走穿
        *前台增加校验，暂不支持交织情况
        **/
        if v_ifdzsb = 'Y' THEN
          --倒表
          v_MRSL := v_MRSCODE - V_COPY_ECODE; --始指针 -末指针  
        ELSIF v_mrdzflag = 'Y' THEN
          --等针
          IF V_COPY_ECODE < v_mrdzcurcode THEN
            v_message   := '等针用户本次指针小于等针读数,不正常';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = '等针用户本次指针小于等针读数,不正常',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            return;
          END IF;
          IF V_COPY_ECODE >= v_MRSCODE THEN
            --等针结束，水量=止码-起码，等针水量=起码-等针读数
            v_MRSL   := V_COPY_ECODE - v_MRSCODE;
            v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
          ELSE
            --等针，水量=0，等针水量=止码-等针读数
            v_MRSL   := 0;
            v_mrdzsl := V_COPY_ECODE - v_mrdzcurcode;
          END IF;
        ELSE
        --量程
          IF v_miyl9 is not null and  V_COPY_ECODE > v_miyl9 THEN
            v_message   := '用户本次指针比水表最大量程数大,不正常';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = '用户本次指针比水表最大量程数大,不正常',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            return;
          END IF;
          --正常表
          v_MRSL := V_COPY_ECODE - v_MRSCODE; --末指针 -始指针
          IF v_MRSL < 0 AND v_miyl9 IS not null THEN
            --水表走穿
            v_MRSL := to_number(v_miyl9) - v_MRSCODE + V_COPY_ECODE;
          END IF;
        END IF;
        if v_MRSL < 0 then
          v_message   := '水量为负数,不正常';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '水量为负数,不正常',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          return;
        end if;
        --波动审核
        if v_MRTHREESL > 0 then
          if v_mrchkresult <> '确认通过' or v_mrchkresult is null then
            PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                  v_MRSL,
                                                  V_MRIFSUBMIT);
          end if;
        end if;
      elsif v_mrface = '02' then
        --//02指定量，止码为起码，水量为上传水量（仅作参考）
        V_MRIFSUBMIT := 'N';
        IF V_COPY_ECODE > 0 THEN
          --当止码大于0进行处理
          v_MRSL := V_COPY_ECODE - v_MRSCODE; --末指针 -始指针
          if v_MRSL < 0 then
            v_message   := '水量为负数,不正常';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = '水量为负数,不正常',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            commit;
            return;
          end if;
        else
          v_MRSL := 0;
        END IF;
        V_COPY_ECODE := v_MRSCODE; -- by ralph 20150724 表异常止码应和起码相同
      elsif v_mrface = '03' then
        --//03零水量，止码为起码，水量为0
        V_MRIFSUBMIT := 'N';
        v_MRSL       := 0;
        V_COPY_ECODE := v_MRSCODE; --止码为起码，水量为0
      end if;
    
      v_MROUTFLAG := 'N';
    
      UPDATE METERREAD t
         SET mrdatasource = '9', --表示手机抄表上传
             MROUTFLAG    = v_MROUTFLAG,
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,
             mrinputper   = substrb(V_COPER_MEMBER, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,
             mrreadok     = V_mrreadok, --是否抄表审核放到营收来审核 20150313
             --mrecodechar  = 处理止码位数问题(V_COPY_ECODE, MRMCODE),
             mrecodechar = V_COPY_ECODE,
             MRSL        = v_MRSL,
             MRECODE     = V_COPY_ECODE,
             mrdzsl = v_mrdzsl,--等针用量 20160805
             --mrrdate     = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
             mrrdate         = TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss'),
             mrpdardate      = TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss'),
             mrinputdate     = sysdate,
             MRFACE          = v_mrface, --查表表态
             mrface2         = V_COPY_BK, --表况
             mrmemo          = v_cb_memo,
             MRCHKFLAG       = v_MRCHKFLAG,
             MRCHKDATE       = v_MRCHKDATE,
             MRCHKPER        = v_MRCHKPER,
             MRPRIVILEGEMEMO = v_MRPRIVILEGEMEMO, --用于手机图片名称
             MRIFGU          = v_mrifgu /*, --估抄表标
             
                                                 MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION*/
       WHERE mrmid = V_USER_NO
         AND NVL(MRIFMCH, 'N') <> 'Y' --免抄件不上传
         AND MRIFREC <> 'Y' --只更新未算费、未审核资料
         and mrreadok <> 'Y';
    
      --当抄表资料未通过，抄表员重新抄表,资料重新上传，需删除之前上传的图片 
      delete from meterpicture
       where mpmiid = V_USER_NO
         and PMBZ = '1' --抄表的图片
         and pmtime >= to_date(to_char(sysdate, 'yyyymm') || '01000001',
                               'yyyymmddhh24miss')
         and pmtime <= to_date(to_char(trunc(Last_day(sysdate)), 'yyyymmdd') ||
                               '235959',
                               'yyyymmddhh24miss');
    
      commit;
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '上传成功',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|000|08003';
      /*             else
         UPDATE LOG_TRANS T
          SET T.TRANS_RESULT      = '111',
              T.TRANS_RETURN_NOTE = '跨月上传失败',
              T.TRANS_MIID        = V_USER_NO
        WHERE T.TRANS_TASK_NO = i_SEQ;
           v_message :='跨月上传失败';
          o_out_trans := '|999|08003' ;
          o_out_trans :=o_out_trans||'|'|| v_message ;
           commit; 
           return ;
           
      end if; */
    elsif V_mrreadok = 'Y' and (v_mistatus = '29' OR v_mistatus = '30') then
      --固定量部份直接调用算费
      o_out_trans := '|000|08003';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '上传成功,固定量',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      v_mrface := '01';
    elsif v_mrdatasource <> '9' and V_mrreadok = 'Y' AND v_MRIFREC <> 'Y' and
          v_mrface = '01' then
      --其它抄表器有抄表未算费
      o_out_trans := '|000|08003';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '上传成功,其它抄表器的数据,只算费',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      -- v_mrface:='01';
    end if;
  
    if v_MICLASS = '2' then
      --总表
      select count(*), SUM(mrsl)
        into v_count, v_mrsl
        from meterread mr, meterinfo mi
       where mr.MRMID = mi.miid
         and mr.MRFACE = '02'
         and --总分表下面分表如果有表异常，则不进行算费,只保存抄表数据
             mi.MIPID = V_USER_NO;
      If v_count > 0 then
        o_out_trans := '|111|08003'; --总分表下面分表如果有表异常，则不进行算费,只保存抄表数据
      end if;
    end if;
    select SUM(mrsl)
      INTO v_mrsl1
    
      from meterread
     where mrmid in (select micid
                       from METERINFO
                      where MIPRIID in (select distinct MIPRIID
                                          from METERINFO
                                         where miid = V_USER_NO));
    if v_mrface = '01' or v_mrface = '03' then
      --只有表态为正常才需算费
    
      if o_out_trans = '|000|08003' then
        --抄表记录成功后调用预算费过程
        begin
          select pfprice
            into v_pfprice
            from priceframe
           where pfid = v_mipfid;
        exception
          when others then
            v_pfprice := 0;
        end;
        if v_pfprice >= 0 then   ---20161130 由于消防水鹤没有水价 且要参与手机抄表 将大于0改为大于等于零
          --单价大于0才预算费
          PG_EWIDE_METERREAD_01.CALCULATE_YSFH(v_MRID, v_rlje, v_message);
        end if;
      
        /*if v_rlje = 0 and v_pfprice > 0 then
          --单价大于0才预算费
          o_out_trans := '|999|08003';
        else*/
        o_out_trans := '|000|08003';
        /*end if;*/
        o_out_trans := o_out_trans || '|' || v_message;
      end if;
    
      if o_out_trans = '|111|08003' then
        --总分表下面分表如果有表异常，则不进行算费,只保存抄表数据
        v_message   := '此总表下分表表态为表异常,不打票';
        o_out_trans := '|111|08003';
        o_out_trans := o_out_trans || '|' || v_message;
      end if;
    elsif v_mrface = '02' then
      --表异常
      --  if o_out_trans  = '|000|08003' then  -- 
      v_message   := '表态为表异常,不打票';
      o_out_trans := '|111|08003';
      o_out_trans := o_out_trans || '|' || v_message;
      --  end if ;
      /* elsif v_mrface = '03' then
      --0水量
      v_message   := '表态为零水量,不打票';
      o_out_trans := '|111|08003';
      o_out_trans := o_out_trans || '|' || v_message;*/
    end if;
    /*      if  Instrb (o_out_trans,'|999|' ,1) > 0 then
       rollback;
    else*/
    COMMIT;
    --   end if ;
    --|08003返回值
    --|成功标志(000-成功 999-失败)|协议|应收水量|应收水费|应收污水费|应收其它费用|应收合计|上期预存余额|本期预存余额
    -- 注 如果返回000成功 值按上述协议返回，如果返回999则返回错误信息 
    --|3|5|10|10|10|10|10|10|10|
    --|000|08003|0000000500|0000001200|0000000400|0000000000|0000001600|0000006960|0000000000
    /*     exception 
    when others then
      dbms_output.put_line(sqlerrm);*/
  end;

  procedure f8004(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    V_USER_NO  VARCHAR2(20);
    v_password operaccnt.oapwd%type;
    v_count    number;
  
  begin
    --f8004  密码验证
    -- 用户名  VARCHAR2(15)
    --密码 VARCHAR2(32)
    --返回 '|000|08004' -成功    '|999|08004' -失败
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 15));
    --密码
    v_password := TRIM(SUBSTR(i_in_trans, 29, 32));
  
    select md5(v_password) into v_password from dual;
  
    select count(*)
      into v_count
      from operaccnt
     where (oaid = V_USER_NO)
       and OAPWD = v_password;
    -- where (oagh =V_USER_NO or oaid =V_USER_NO )  and OAPWD =v_password ;  by 20150608 ralph 因为抄表员工号才可能关联表册表
  
    --v_count 表示当月已经扎账
    if v_count > 0 then
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '密码验证成功',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
    
      insert into sys_host_his
        (ip, login_user, host_name, log_date, ip1, os_user)
      values
        ('SJCB',
         V_USER_NO,
         v_password,
         sysdate,
         '手机抄表',
         'PG_pad_updata 手机抄表登入');
    
      o_out_trans := '|000|08004';
    else
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '密码验证失败',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|999|08004';
    end if;
  
    COMMIT;
  
  end;

  procedure f8005(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_字典CODE  datadesign.字典CODE%type;
    v_字典CODE1 datadesign.字典CODE%type;
    v_count     number;
  
  begin
    --f8005  参数版本验证
    -- 字典代号  VARCHAR2(20) 
    --返回 '|000|08005|版本号'  000-代表营收版本比手机高    '|999|08005|版本号'   999-手机与营收版本一致 
    v_字典CODE1 := TRIM(SUBSTR(i_in_trans, 13, 20));
  
    select 字典CODE
      into v_字典CODE
      from datadesign
     where 字典类型 = '手机参数版本';
  
    --v_count 表示当月已经扎账
    if v_字典CODE > v_字典CODE1 then
      --营收版高于手机版本，则返回营收参数
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '手机参数版本成功',
             T.TRANS_MIID        = v_字典CODE1
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|000|08005|' || v_字典CODE1; --需重新下载
    else
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '手机参数版本一致',
             T.TRANS_MIID        = v_字典CODE1
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|999|08005|' || v_字典CODE1; --不需重新下载
    end if;
  
    COMMIT;
  
  end;

  procedure f8006(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_字典CODE  datadesign.字典CODE%type;
    v_字典CODE1 datadesign.字典CODE%type;
    v_count     number;
    v_miid      VARCHAR2(20);
    v_mr        meterread%rowtype;
    v_mi        meterinfo%rowtype;
    v_md        meterdoc%rowtype;
    v_message   VARCHAR2(400);
    v_ysdj      number(10, 2);
    v_wsdj      number(10, 2);
  begin
    /*  * 功能：8006协议  
    用户点抄表取消协议，抄表注记需退审,相关资料取消 */
    --返回 |000|08006|'返回成功信息' --000成功  |999|08006|'返回失败信息' --999失败
    --户号
  
    v_miid := TRIM(SUBSTR(i_in_trans, 13, 10));
  
    BEGIN
      /*      select mr.MRID,mr.MRIFREC,mr.MRSMFID,mr.mrreadok,mi.mistatus,mr.MRTHREESL,mr.MRIFSUBMIT,mr.mrchkresult,md.ifdzsb,mr.MRSCODE, mi.MICLASS,mi.MIPID,mi.MIPRIID,mi.MIPRIFLAG,mr.mrdatasource,mr.mrface--是否已算费
      into  v_mr.mrid,v_mr.MRIFREC,v_mr.MRSMFID,v_mr.mrreadok,v_mi.mistatus ,v_mr.MRTHREESL,v_mr.MRIFSUBMIT,v_mr.mrchkresult,v_md.ifdzsb,v_mr.MRSCODE,v_mi.MICLASS,v_mi.MIPID,v_mi.MIPRIID,v_mi.MIPRIFLAG,v_mr.mrdatasource,v_mr.mrface --v_ifdzsb倒表装置
      from METERREAD mr ,meterinfo mi,meterdoc md 
      where mr.MRMID = mi.miid and 
            mr.mrmid = md.MDMID and 
            mr.mrmid = v_miid  ;  */
      select mr.mrreadok
        into v_mr.mrreadok
        from METERREAD mr
       where mr.mrmid = v_miid;
    EXCEPTION
      WHEN OTHERS THEN
        v_message   := '未找到抄表资料';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '未找到抄表资料',
               T.TRANS_MIID        = v_miid
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
    END;
  
    if v_mr.mrifrec = 'Y' THEN
      --20150917 
      o_out_trans := '|999|08006|此表已经审核算费,不能退审'; --资料回退失败
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '资料回退失败,此表已经审核,不能退审',
             T.TRANS_MIID        = v_miid
       WHERE T.TRANS_TASK_NO = i_SEQ;
      commit;
      return;
    end if;
  
    if v_mr.mrreadok <> 'Y' THEN
      --未审核通过的可以取消再次抄表 
      begin
        UPDATE METERREAD t
           SET mrdatasource = '9', --表示手机抄表上传
               MROUTFLAG    = 'N',
               mrinorder    = 0,
               mrindate     = NULL,
               mrinputper   = '',
               --       mrifsubmit   = V_MRIFSUBMIT,  
               mrreadok = 'N', --是否抄表审核放到营收来审核 20150313
               --mrecodechar  = 处理止码位数问题(V_COPY_ECODE, MRMCODE),
               mrecodechar     = '0',
               MRSL            = 0,
               MRECODE         = 0,
               mrrdate         = NULL,
               mrpdardate      = NULL,
               mrinputdate     = NULL,
               MRFACE          = '', --查表表态
               mrface2         = '', --表况
               mrmemo          = '',
               MRPRIVILEGEMEMO = '', --用于手机图片名称
               MRIFGU          = '' /*, --估抄表标
                                   MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION*/
         WHERE mrmid = v_miid
           AND NVL(MRIFMCH, 'N') <> 'Y' --免抄件不上传
           AND MRIFREC <> 'Y' --只更新未算费、未审核资料
           and mrreadok <> 'Y';
        select fun_getjtdqdj(MIPFID, MIPRIID, miid, '1') 水费单价,
               fgetwsf(mipfid) 污水费单价
          into v_ysdj, v_wsdj
          from meterinfo
         where miid = v_miid;
        o_out_trans := '|000|08006|' ||
                       trim(to_char(abs(v_ysdj) * 100, '0000000000')) || '|' ||
                       trim(to_char(abs(v_wsdj) * 100, '0000000000')); --资料回退成功
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '000',
               T.TRANS_RETURN_NOTE = '资料回退成功',
               T.TRANS_MIID        = v_miid
         WHERE T.TRANS_TASK_NO = i_SEQ;
        --当抄表资料未通过，抄表员重新抄表,资料重新上传，需删除之前上传的图片 
        delete from meterpicture
         where mpmiid = v_miid
           and PMBZ = '1' --抄表的图片
           and pmtime >= to_date(to_char(sysdate, 'yyyymm') || '01000001',
                                 'yyyymmddhh24miss')
           and pmtime <= to_date(to_char(trunc(Last_day(sysdate)),
                                         'yyyymmdd') || '235959',
                                 'yyyymmddhh24miss');
      
        commit;
      
      exception
        when others then
          o_out_trans := '|999|08006|' || sqlerrm; --资料回退失败
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '资料回退失败',
                 T.TRANS_MIID        = v_miid
           WHERE T.TRANS_TASK_NO = i_SEQ;
          rollback;
          return;
      end;
    else
      o_out_trans := '|999|08006|此表已经审核,不能退审'; --资料回退失败
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '资料回退失败,此表已经审核,不能退审',
             T.TRANS_MIID        = v_miid
       WHERE T.TRANS_TASK_NO = i_SEQ;
    END IF;
  
    COMMIT;
  
  end;
  /*  * 功能：8006协议  
  用户巡检 */
  -- 
  --户号    
  procedure f8007(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_字典CODE  datadesign.字典CODE%type;
    v_字典CODE1 datadesign.字典CODE%type;
    v_count     number;
    tc          telcheck%rowtype;
    -- f8007
    --用户巡检
    --|用户号|巡检类别|巡检结果|巡检备注|巡检人|巡检时间|是否拍照|照片路径
    --|10|20|20|200|15|10|1|200
  begin
    tc.tcmid        := TRIM(SUBSTR(i_in_trans, 13, 10)); --用户号
    tc.TCMONTH      := to_char(sysdate, 'yyyy.mm');
    tc.tctype       := TRIM(SUBSTR(i_in_trans, 24, 20)); --巡检类别
    tc.TCRESULT     := TRIM(SUBSTR(i_in_trans, 45, 20)); --巡检结果
    tc.TCNOTE       := TRIM(SUBSTR(i_in_trans, 66, 200)); --巡检备注
    tc.TCUSER       := TRIM(SUBSTR(i_in_trans, 267, 15)); --巡检人
    tc.TCDATE       := to_date(TRIM(SUBSTR(i_in_trans, 283, 19)),
                               'YYYY-MM-DD hh24:mI:ss'); --巡检时间
    tc.TCPHOTO_MK   := TRIM(SUBSTR(i_in_trans, 303, 1)); --是否拍照(Y/N)
    tc.TCPHOTO_PATH := TRIM(SUBSTR(i_in_trans, 305, 200)); --照片路径
    tc.TCINSDATE    := sysdate; --是否拍照(Y/N)
    TC.TCCHK_MK     := 'N';
    begin
      SELECT FGETSEQUENCE('SEQ_TELCHECK') INTO tc.tcid FROM DUAL; --获取流水号
      insert into telcheck values tc;
      o_out_trans := '|000|08007|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                     '资料新增成功'; --资料上传成功
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '资料新增成功',
             T.TRANS_MIID        = tc.tcmid
       WHERE T.TRANS_TASK_NO = i_SEQ;
    exception
      when others then
        o_out_trans := '|999|08007|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                       sqlerrm; --资料回退失败
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '资料新增失败',
               T.TRANS_MIID        = tc.tcmid
         WHERE T.TRANS_TASK_NO = i_SEQ;
        rollback;
        return;
    end;
  
    COMMIT;
  
  end;

  procedure f8008(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_字典CODE  datadesign.字典CODE%type;
    v_字典CODE1 datadesign.字典CODE%type;
    v_count     number;
    mp          meterpicture%rowtype;
  
    /*
    * 功能：8008协议  
      用户图片资料上传
    * 创建人:贺帮
    * 创建时间：2015-07-15
    * 修改人：  
    * 修改时间：
    */
    --|用户号|图片大小|路径|时间|注记|抄表员姓名|用户号|图片路径
    --|10|10|400|20|100|10|30|10|400
  
  begin
    mp.MPMIID      := TRIM(SUBSTR(i_in_trans, 13, 10)); --用户号
    mp.PMSIZE      := to_number(SUBSTR(i_in_trans, 24, 10)); --图片大小
    mp.PMPATH      := TRIM(SUBSTR(i_in_trans, 35, 400)); --路径
    mp.PMTIME      := to_date(TRIM(SUBSTR(i_in_trans, 436, 20)),
                              'YYYY-MM-DD hh24:mI:ss'); --时间
    mp.PMBZ        := TRIM(SUBSTR(i_in_trans, 457, 100)); --注记
    mp.PMPER       := TRIM(SUBSTR(i_in_trans, 558, 10)); --抄表员工号
    mp.PMPNAME     := TRIM(SUBSTR(i_in_trans, 569, 30)); --抄表员姓名
    mp.CIID        := TRIM(SUBSTR(i_in_trans, 600, 10)); --用户号(Y/N)
    mp.PMFACT_PATH := TRIM(SUBSTR(i_in_trans, 611, 400)); --图片路径
  
    begin
    
      insert into meterpicture values mp;
      o_out_trans := '|000|08008|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                     '资料新增成功'; --资料上传成功
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '资料新增成功',
             T.TRANS_MIID        = mp.MPMIID
       WHERE T.TRANS_TASK_NO = i_SEQ;
    exception
      when others then
        o_out_trans := '|999|08008|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                       sqlerrm; --资料回退失败
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '资料新增失败',
               T.TRANS_MIID        = mp.MPMIID
         WHERE T.TRANS_TASK_NO = i_SEQ;
        rollback;
        return;
    end;
  
    COMMIT;
  
  end;

END;
/

