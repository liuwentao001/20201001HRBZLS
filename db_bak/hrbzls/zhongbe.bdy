CREATE OR REPLACE PACKAGE BODY HRBZLS."ZHONGBE" is

  /*----------------------------------------------------------------------
  Note:业务处理入口函数
  Input: p_in  -- 请求包
  Output:p_out -- 返回包
  Return: 000 --成功
          006 --错误交易码
          022 --其他错误
  ----------------------------------------------------------------------*/
  function main(P_CODE in VARCHAR2, p_in in arr, p_out in out arr)
    return varchar2 as
    v_fun_name varchar2(100);
    sql_text   varchar2(400);
    v_result   varchar2(400);
  
    cursor c_log_hd is
      select * from packetshd order by to_number(c2);
    cursor c_log_dt is
      select * from packetsdt order by to_number(c2);
    log_hd   packetshd%rowtype;
    log_dt   packetsdt%rowtype;
    log_iarr arr;
    log_oarr arr;
    reslog   number(10);
  
    /*  i number(10);*/
  begin
  
    select t.pk_method
      into v_fun_name
      from MI_PACKAGE_ZB t
     where t.pk_code = p_code;
  
    sql_text := 'call ' || v_fun_name || '(:p1,:p2)';
    --sql_text := 'call ' || v_fun_name;
    --动态执行业务处理过程，返回参数到P_OUT
    --execute immediate sql_text;
    execute immediate sql_text
      using in p_in, in out p_out;
  
    --记录日志
    --sp_tran_log(P_CODE, p_in, p_out);
    --记录日志
    reslog := 0;
    open c_log_hd;
    loop
      fetch c_log_hd
        into log_hd;
      exit when c_log_hd%notfound;
      reslog := zhongbe.f_set_item(log_iarr, trim(log_hd.c1));
    end loop;
    close c_log_hd;
  
    reslog := 0;
    open c_log_dt;
    loop
      fetch c_log_dt
        into log_dt;
      exit when c_log_dt%notfound;
      reslog := zhongbe.f_set_item(log_oarr,
                                   trim(substr(log_dt.c1,
                                               (instr(log_dt.c1, '|') + 1),
                                               length(log_dt.c1))));
      --reslog := zhongbe.f_set_item(log_oarr,tools.fgetpara(dt.c1 || '|', 2, 2));
    end loop;
    close c_log_dt;
  
    sql_text := 'call zhongbe.sp_tran_log' || '(:p1,:p2,:p3)';
    execute immediate sql_text
      using in p_code, in log_iarr, in log_oarr;
  
    v_result := '000';
    v_result := F_GET_DTTEXT(2);
    return v_result;
  exception
    when no_data_found then
      return '006';
    when others then
      --INFOMSG('ERR.CODE:' || TO_CHAR(SQLCODE));
      --INFOMSG('ERR.MSG:' || SQLERRM);
      sp_tran_errlog(p_code, 
                     log_iarr, 
                     log_oarr,
                     TO_CHAR(SQLCODE),
                     TO_CHAR(SQLERRM));
      return '022';
  end main;

  function f_set_item(p_arr in out arr, p_data in varchar2) return number as
    v_count number(10);
  
  begin
  
    if p_arr is null then
      p_arr := arr('');
    else
      p_arr.extend;
    end if;
    v_count := p_arr.count;
    p_arr(v_count) := p_data;
    return v_count;
  end f_set_item;

  function F_SET_TEXT(P_ROW IN VARCHAR2, P_DATE IN VARCHAR2) return number as
    v_count NUMBER(10);
  begin
    --SELECT * FROM PACKETSDT WHERE TRIM(C2)=TRIM(P_ROW);
    UPDATE PACKETSDT
       SET C1 = SUBSTR(C1, 1, instr(C1, '|')) || P_DATE
     WHERE TRIM(C2) = TRIM(P_ROW);
    v_count := 0;
    return v_count;
  end F_SET_TEXT;

  --返回银行发送报文字段
  function F_GET_HDTEXT(P_ROW IN VARCHAR2) return VARCHAR2 as
    v_TEXT VARCHAR2(400);
  begin
    SELECT C1 INTO v_TEXT FROM PACKETSHD WHERE TRIM(C2) = TRIM(P_ROW);
    return v_TEXT;
  end F_GET_HDTEXT;
  
    --返回中间件发送报文字段
  function F_GET_DTTEXT(P_ROW IN VARCHAR2) return VARCHAR2 as
    v_TEXT VARCHAR2(400);
  begin
    SELECT trim(substr(c1, (instr(c1, '|')+1),length(c1))) INTO v_TEXT FROM PACKETSDT WHERE TRIM(C2) = TRIM(P_ROW);
    return v_TEXT;
  end F_GET_DTTEXT;

  /*----------------------------------------------------------------------
  Note: 520交易(欠费资料查询)处理
  Input: p_in  -- 请求包
  Output:
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure f520(p_in in arr, p_out in out arr) as
    pstep          number(10); --事务处理进度
    v_ccode        varchar2(30); --客户号
    MI             METERINFO%rowtype; --客户资料
    CI             custinfo%rowtype;
    v_cxyf         varchar2(6); --查询月份
    v_qfyf         varchar2(6); --欠费月份
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --实际应缴金额
    v_znj          number(10, 2); --违约金
    v_addr         varchar2(60);
    v_mame         varchar2(60);
    qfyf1_ljf      number(10);
    qfyf2_ljf      number(10);
    v_yjje_ljf     number(10, 2);
    v_znj_ljf      number(10, 2);
    v_out_yjje_ljf number(10, 2);
    cqts_ljf       number(10);
    qfyf1_all      number(10);
    qfyf2_all      number(10);
    v_sxcount      number(10);
    v_jfsx         number(10);
    v_rlid         varchar2(10);
    v_sfdj         number(12, 3);
    v_wsfdj        number(12, 3);
    v_sbs          number(10);
  
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    --欠费游标
    cursor C_QFYF_LIST IS
      select RLID
        from (SELECT RLID AS RLID
                from RECLIST RL
                WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 考录到合收表维护之前有未销帐应收，查询过程中要考虑进去
              --WHERE RL.RLMCODE = v_ccode
               --WHERE RL.rlprimcode = v_ccode
                 AND RL.RLJE > 0
                 AND RL.RLPAIDFLAG = 'N'
                 AND RL.RLOUTFLAG = 'N'
                 AND RLREVERSEFLAG = 'N'
                 AND RLBADFLAG = 'N'
                 and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or
                     (v_cxyf = '000000'))
               GROUP BY rlid);
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------
  
    --组织欠费数据
    cursor c_ysmx IS
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份11
             to_char((chargetotal + chargeznj) * 100) xj, --小计12
             trim(f_getcardno(rlmid)) rlbfid, --帐卡号13
              to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLSCODE))) RLSCODE, --起码14
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --上次抄表日期15
              to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLECODE))) RLECODE,  --止码16
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --本期抄表日期17
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --水费单价一阶18
             to_char(USER_DJ2 * 100) USER_DJ2, --水费单价二阶19
             to_char(USER_DJ3 * 100) USER_DJ3, --水费单价三阶20
             to_char(dj2 * 100) dj2, --污水单价21
             to_char(decode(use_r1, 0, wateruse)) use_r1, --水量一阶22
             to_char(use_r2) use_r2, --水量二阶23
             to_char(use_r3) use_r3, --水量三阶24
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --水费一阶25
             to_char(charge_r2 * 100) charge_r2, --水费二阶26
             to_char(charge_r3 * 100) charge_r3, --水费三阶27
             to_char(charge2 * 100) charge2, --污水金额28
             to_char(chargeznj * 100) chargeznj, --违约金29
             '0' zjje, --追减金额30
             rlmid, --客户代码31
             '' yl1, --预留1 32
             '' yl2, --预留1 33
             '' yl3, --预留1 34
             '' yl4 --预留1 35
        from reclist rl, view_reclist_charge_02 rd
       where rlid = rdid
         and rl.rlje > 0
         and rlbadflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'N'
         --and rl.rlprimcode = v_ccode
         and rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 考录到合收表维护之前有未销帐应收，查询过程中要考虑进去
         and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or (v_cxyf = '000000'))
       order by rldate desc;
  
    v_ysmx c_ysmx%rowtype;
  
    --异常返回定义
    err_format exception; --数据格式错
    no_rec exception; --无欠费
    rec_lock exception; --欠费记录锁定
    rec_overflow exception; --欠费月份超出，应到营业所缴费
    znj exception; --有违约金，不能代收
    no_user exception; --无此用户
  
    v_n     number(10);
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
  
  begin
    -------------------------20130912修改，所有记录数上限改为6---------------------------
    v_jfsx := 6; --欠费月份上限
    -------------------------20130912修改end---------------------------
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 8 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 23 then
      raise err_format;
    end if;
  
    v_ccode := trim(F_GET_HDTEXT(7)); --客户代码
  
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    v_cxyf := trim(F_GET_HDTEXT(8)); --费用月份
  
    -- STEP 1:取客户名称资料
    pstep := 1;
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --判断是否坐收用户ZHW加上增值税用户不能在银行缴费
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') or mi.MIIFTAX = 'Y' then
      raise no_user;
    end if;
  
    --判断是一户一表还是一户多表
    if mi.mipriflag = 'N' then
      v_sbs := 1;
    else
      --赋值合收主表号
      v_ccode := mi.mipriid;
      --查询合收表数量
      select nvl(count(t.micode), 1)
        into v_sbs
        from meterinfo t
       where t.mipriid = v_ccode;
      --重新取合收主表数据
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
    rcount := F_SET_TEXT(3, MI.micode); --户号
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --户名
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --户地址
  
    --STEP 2: 检查欠费记录数
    pstep := 2;
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    select sum(DECODE(rloutflag, 'Y', 1, 0)),
           sum(rlje),
           sum(PG_EWIDE_PAY_01.getznjadj(rlid,
                                         nvl(rlje, 0),
                                         RLGROUP,
                                         rlzndate,
                                         rlsmfid,
                                         sysdate))
      INTO qfyf1, v_yjje, v_znj
      from RECLIST RL
      WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 考录到合收表维护之前有未销帐应收，查询过程中要考虑进去
     --WHERE rl.RLMCODE = v_ccode
    -- WHERE rl.rlprimcode = v_ccode
       AND RL.RLJE > 0
       AND RL.RLPAIDFLAG = 'N'
          --AND RL.RLOUTFLAG = 'N'
       AND RL.RLREVERSEFLAG = 'N'
       AND RL.RLBADFLAG = 'N'
       and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or (v_cxyf = '000000'));
  
    --欠费月份数
    select count(rlid)
      into qfyf2_all
      from (select rlid
              from reclist rl
              WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 考录到合收表维护之前有未销帐应收，查询过程中要考虑进去
            --where RLMCODE = v_ccode
             --where rlprimcode = v_ccode
               AND RL.RLJE > 0
               AND RL.RLPAIDFLAG = 'N'
                  --AND RL.RLOUTFLAG = 'N'
               AND RL.RLREVERSEFLAG = 'N'
               AND RL.RLBADFLAG = 'N'
               and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or
                   (v_cxyf = '000000')));
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------            
  
    --记录数
    --情况1：无欠费记录
    IF qfyf2_all = 0 THEN
      ---------------------------------下面2行于20130108 16：06修改-------------------------------------------------
      rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数
      rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --期初预存
      --STEP 4:
      pstep  := 4;
      v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
      --实际应缴金额
      if v_yjje - MI.MISAVING > 0 then
        v_yjje := v_yjje - MI.MISAVING;
      else
        v_yjje := 0;
      end if;
      --应缴金额
      rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --应缴金额
    
      --如果是一户一表或者一户多表水价相同
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --取水费单价和污水费单价
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
      
        rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --水费单价
        rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --污水费单价
        --如果一户多表水价不同
      else
        rcount := F_SET_TEXT(9, '-'); --水费单价
        rcount := F_SET_TEXT(10, '-'); --污水费单价
      end if;
    
      -----------------------------------------20130110pxp修改---------------------------------------------------
      raise no_rec; --无欠费记录数
    
      --情况2：有欠费记录，但是发出标志为'Y'
    elsif qfyf1 > 0 then
      raise rec_lock; --有欠费记录数，但代扣发出
    
      --情况3：有欠费记录，并且未发出
    else
      --判断如果实际笔数大于限制条数，则记录数取限制条数
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, v_jfsx); --记录数  
      else
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数  
      end if;
    
      /*--20131212放宽限制，超出6笔也正常返回，但是只取最近6笔
      -------------------------20130912修改，记录数超出返回增加到序10---------------------------------
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数
        rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --期初预存
        v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
        --实际应缴金额
        if v_yjje - MI.MISAVING > 0 then
          v_yjje := v_yjje - MI.MISAVING;
        else
          v_yjje := 0;
        end if;
        --应缴金额
        rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --应缴金额
      
        --如果是一户一表或者一户多表水价相同
        if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
          --取水费单价和污水费单价
          select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
                 nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
            into v_sfdj, v_wsfdj
            from pricedetail pd
           where pd.pdpfid = mi.mipfid
           group by pd.pdpfid;
        
          rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --水费单价
          rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --污水费单价
          --如果一户多表水价不同
        else
          rcount := F_SET_TEXT(9, '-'); --水费单价
          rcount := F_SET_TEXT(10, '-'); --污水费单价
        end if;
        raise rec_overflow;
        -------------------------20130912修改end---------------------------------
      else
        ---------改到这里
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数
      end if;*/
    end if;
  
    --STEP 3: 取预存金额
    pstep := 3;
    --预存金额转换为字符串
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --期初预存
  
    --STEP 4:
    pstep  := 4;
    v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
    --实际应缴金额
    if v_yjje - MI.MISAVING > 0 then
      v_yjje := v_yjje - MI.MISAVING;
    else
      v_yjje := 0;
    end if;
    --应缴金额
    rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --应缴金额
  
    --如果是一户一表或者一户多表水价相同
    if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
      --取水费单价和污水费单价
      select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
             nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
        into v_sfdj, v_wsfdj
        from pricedetail pd
       where pd.pdpfid = mi.mipfid
       group by pd.pdpfid;
    
      rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --水费单价
      rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --污水费单价
      --如果一户多表水价不同
    else
      rcount := F_SET_TEXT(9, '-'); --水费单价
      rcount := F_SET_TEXT(10, '-'); --污水费单价
    end if;
  
    --STEP 5:组织欠费数据
    pstep := 5;
    --根据记录数扩充packetsDT数据
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --如果欠费记录超出6笔，则只返回最近的6笔明细
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --哈尔滨需求  11-35循环取值
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(11 + (v_n * 25), to_char(v_ysmx.month)); --年月份
      rcount := F_SET_TEXT(12 + (v_n * 25), to_char(v_ysmx.xj)); --小计
      rcount := F_SET_TEXT(13 + (v_n * 25), to_char(v_ysmx.rlbfid)); --帐卡号
      rcount := F_SET_TEXT(14 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --起码
      rcount := F_SET_TEXT(15 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --上次抄表日期
      rcount := F_SET_TEXT(16 + (v_n * 25), to_char(v_ysmx.RLECODE)); --止码
      rcount := F_SET_TEXT(17 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --本次抄表日期
      rcount := F_SET_TEXT(18 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --水费单价（一阶）
      rcount := F_SET_TEXT(19 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --水费单价（二阶）
      rcount := F_SET_TEXT(20 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --水费单价（三阶）
      rcount := F_SET_TEXT(21 + (v_n * 25), to_char(v_ysmx.dj2)); --污水处理费单价
      rcount := F_SET_TEXT(22 + (v_n * 25), to_char(v_ysmx.use_r1)); --水量（一阶）
      rcount := F_SET_TEXT(23 + (v_n * 25), to_char(v_ysmx.use_r2)); --水量（二阶）
      rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.use_r3)); --水量（三阶）
      rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.charge_r1)); --水费（一阶）
      rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.charge_r2)); --水费（二阶）
      rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.charge_r3)); --水费（三阶）
      rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.charge2)); --污水处理费
      rcount := F_SET_TEXT(29 + (v_n * 25), to_char(v_ysmx.chargeznj)); --违约金
      rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.zjje)); --追减费
      rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.rlmid)); --客户代码
      rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.yl1)); --预留
      rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.yl2)); --预留
      rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.yl3)); --预留
      rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.yl4)); --预留
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --无此客户
        rcount := F_SET_TEXT(2, '001');
      end if;
    when no_user then
      rcount := F_SET_TEXT(2, '001');
    when no_rec then
      rcount := F_SET_TEXT(2, '000');
    when rec_lock then
      rcount := F_SET_TEXT(2, '003');
    when rec_overflow then
      rcount := F_SET_TEXT(2, '023');
    when znj then
      rcount := F_SET_TEXT(2, '009');
    when others then
      raise;
  end f520;

  /*----------------------------------------------------------------------
  Note: 521  查询抄表记录
  Input: p_in  -- 请求包
  Output:
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure f521(p_in in arr, p_out in out arr) as
    pstep          number(10); --事务处理进度
    v_ccode       varchar2(30); --客户号
    MI             METERINFO%rowtype; --客户资料
    CI             custinfo%rowtype;
    v_cxyf         varchar2(6); --查询月份
    v_qfyf         varchar2(6); --欠费月份
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --实际应缴金额
    v_znj          number(10, 2); --违约金
    v_addr         varchar2(60);
    v_mame         varchar2(60);
    qfyf1_ljf      number(10);
    qfyf2_ljf      number(10);
    v_yjje_ljf     number(10, 2);
    v_znj_ljf      number(10, 2);
    v_out_yjje_ljf number(10, 2);
    cqts_ljf       number(10);
    qfyf1_all      number(10);
    qfyf2_all      number(10);
    v_sxcount      number(10);
    v_jfsx         number(10);
    V_RLID         VARCHAR(10); --应收流水
    ---查询月份
    v_cxyf1 varchar2(6); --查询起始月份
    v_cxyf2 varchar2(6); --查询终止月份
  
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    --欠费游标
    cursor C_QFYF_LIST IS
      select rlid
        from (SELECT rlid AS rlid
                from RECLIST RL
              --WHERE RL.RLMCODE = v_ccode
               WHERE RL.rlprimcode = v_ccode
                    --AND RL.RLJE > 0
                    --AND RL.RLPAIDFLAG = 'N'
                 AND RL.RLOUTFLAG = 'N'
                 AND RLREVERSEFLAG = 'N'
                 AND RLBADFLAG = 'N'
                 and to_char(RLRDATE, 'YYYYMM') > = v_cxyf1
                 and to_char(RLRDATE, 'YYYYMM') <= v_cxyf2
               GROUP BY rlid);
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------
  
    --组织抄表数据
    cursor c_ysmx IS
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份8
             to_char(chargetotal * 100) xj, --小计9
             trim(f_getcardno(rlmid)) rlbfid, --帐卡号10
             to_char(decode(RLMSTATUS,'29','-','30','-',RLSCODE)) RLSCODE, --起码11
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --上次抄表日期12
             to_char(decode(RLMSTATUS,'29','-','30','-',RLECODE)) RLECODE, --止码13
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --本期抄表日期14
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --水费单价一阶15
             to_char(USER_DJ2 * 100) USER_DJ2, --水费单价二阶16
             to_char(USER_DJ3 * 100) USER_DJ3, --水费单价三阶17
             to_char(dj2 * 100) dj2, --污水单价18
             to_char(decode(use_r1, 0, wateruse)) use_r1, --水量一阶19
             to_char(use_r2) use_r2, --水量二阶20
             to_char(use_r3) use_r3, --水量三阶21
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --水费一阶22
             to_char(charge_r2 * 100) charge_r2, --水费二阶23
             to_char(charge_r3 * 100) charge_r3, --水费三阶24
             to_char(charge2 * 100) charge2, --污水金额25
             '' yl1, --预留1 26
             '' yl2, --预留2 27
             '' yl3, --预留3 28
             '' yl4, --预留4 29
             '' yl5 --预留5 30
        from reclist rl, view_reclist_charge_02 rd
       where rlid = rdid
            --and rl.rlje > 0
         and rlbadflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlprimcode = v_ccode
         and to_char(RLRDATE, 'YYYYMM') >= v_cxyf1
         and to_char(RLRDATE, 'YYYYMM') <= v_cxyf2
       order by rldate desc;
  
    v_ysmx c_ysmx%rowtype;
  
    --异常返回定义
    err_format exception; --数据格式错
    no_rec exception; --无欠费
    rec_lock exception; --欠费记录锁定
    rec_overflow exception; --欠费月份超出，应到营业所缴费
    znj exception; --有违约金，不能代收
    no_user exception; --无此用户
  
    v_n     number(10);
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
  
  begin
    --------抄表记录查询需要设上限吗？？？？？------------------------
    v_jfsx := 6; --上限
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 9 then
      raise err_format;
    end if;
  
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 29 then
      raise err_format;
    end if;
  
    --取得查询的月份
    v_cxyf1 := trim(F_GET_HDTEXT(8)); --起始抄表月份
    v_cxyf2 := trim(F_GET_HDTEXT(9)); --终止抄表月份
  
    -- STEP 1:取客户名称资料
    pstep   := 1;
    v_ccode := trim(F_GET_HDTEXT(7)); --客户代码
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --判断是否坐收用户
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
  
    --判断是一户一表还是一户多表
    if mi.mipriflag = 'Y' then
      v_ccode := mi.mipriid;
      --重新取合收主表数据
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(3, v_ccode); --户号
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --户名
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --户地址
  
    --STEP 2: 检查抄表记录数
    pstep := 2;
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    --记录数
    select count(rlid)
      into qfyf2_all
      from (select rlid rlid
              from reclist rl
             where rlprimcode = v_ccode
                  --where RLMCODE = v_ccode
                  --AND RL.RLJE > 0
                  -- AND RL.RLPAIDFLAG = 'N'
                  --AND RL.RLOUTFLAG = 'N'
               AND RL.RLREVERSEFLAG = 'N'
               AND RL.RLBADFLAG = 'N'
               and to_char(RLRDATE, 'YYYYMM') > = v_cxyf1
               and to_char(RLRDATE, 'YYYYMM') <= v_cxyf2);
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------
  
    --记录数
    IF qfyf2_all = 0 THEN
      raise no_rec; --无抄表记录
      /*elsif qfyf2_all > v_jfsx then
      ---*** end ***---
      raise rec_overflow; --抄表记录超出*/
    end if;
  
    --判断如果实际笔数大于限制条数，则记录数取限制条数
    if qfyf2_all > v_jfsx then
      rcount := F_SET_TEXT(6, v_jfsx); --记录数  
    else
      rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数  
    end if;
  
    --STEP 3: 取预存金额
    pstep := 3;
    --预存金额转换为字符串
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --预定欠费记录数
  
    --STEP 4:组织抄表数据
    pstep := 5;
    --根据记录数扩充packetsDT数据
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --如果缴费记录超出，则只返回最近的6笔明细
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --哈尔滨需求  8-30循环取值
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(8 + (v_n * 23), to_char(v_ysmx.month)); --年月份
      rcount := F_SET_TEXT(9 + (v_n * 23), to_char(v_ysmx.xj)); --小计
      rcount := F_SET_TEXT(10 + (v_n * 23), to_char(v_ysmx.rlbfid)); --帐卡号
      rcount := F_SET_TEXT(11 + (v_n * 23), to_char(v_ysmx.RLSCODE)); --起码
      rcount := F_SET_TEXT(12 + (v_n * 23), to_char(v_ysmx.RLPRDATE)); --上次抄表日期
      rcount := F_SET_TEXT(13 + (v_n * 23), to_char(v_ysmx.RLECODE)); --止码
      rcount := F_SET_TEXT(14 + (v_n * 23), to_char(v_ysmx.RLRDATE)); --本次抄表日期
      rcount := F_SET_TEXT(15 + (v_n * 23), to_char(v_ysmx.USER_DJ1)); --水费单价（一阶）
      rcount := F_SET_TEXT(16 + (v_n * 23), to_char(v_ysmx.USER_DJ2)); --水费单价（二阶）
      rcount := F_SET_TEXT(17 + (v_n * 23), to_char(v_ysmx.USER_DJ3)); --水费单价（三阶）
      rcount := F_SET_TEXT(18 + (v_n * 23), to_char(v_ysmx.dj2)); --污水处理费单价
      rcount := F_SET_TEXT(19 + (v_n * 23), to_char(v_ysmx.use_r1)); --水量（一阶）
      rcount := F_SET_TEXT(20 + (v_n * 23), to_char(v_ysmx.use_r2)); --水量（二阶）
      rcount := F_SET_TEXT(21 + (v_n * 23), to_char(v_ysmx.use_r3)); --水量（三阶）
      rcount := F_SET_TEXT(22 + (v_n * 23), to_char(v_ysmx.charge_r1)); --水费（一阶）
      rcount := F_SET_TEXT(23 + (v_n * 23), to_char(v_ysmx.charge_r2)); --水费（二阶）
      rcount := F_SET_TEXT(24 + (v_n * 23), to_char(v_ysmx.charge_r3)); --水费（三阶）
      rcount := F_SET_TEXT(25 + (v_n * 23), to_char(v_ysmx.charge2)); --污水处理费
      rcount := F_SET_TEXT(26 + (v_n * 23), to_char(v_ysmx.yl1)); --预留
      rcount := F_SET_TEXT(27 + (v_n * 23), to_char(v_ysmx.yl2)); --预留
      rcount := F_SET_TEXT(28 + (v_n * 23), to_char(v_ysmx.yl3)); --预留
      rcount := F_SET_TEXT(29 + (v_n * 23), to_char(v_ysmx.yl4)); --预留
      rcount := F_SET_TEXT(30 + (v_n * 23), to_char(v_ysmx.yl5)); --预留
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --无此客户
        rcount := F_SET_TEXT(2, '001');
      end if;
    when no_user then
      rcount := F_SET_TEXT(2, '001');
    when no_rec then
      rcount := F_SET_TEXT(2, '004');
    when rec_lock then
      rcount := F_SET_TEXT(2, '003');
    when rec_overflow then
      rcount := F_SET_TEXT(2, '023');
    when znj then
      rcount := F_SET_TEXT(2, '009');
    when others then
      raise;
  end f521;

  /*----------------------------------------------------------------------
  Note: 522   查询实收信息
  Input: p_in  -- 请求包
  Output:
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure f522(p_in in arr, p_out in out arr) as
    pstep          number(10); --事务处理进度
    v_ccode        varchar2(30); --客户号
    MI             METERINFO%rowtype; --客户资料
    CI             custinfo%rowtype;
    PM             PAYMENT%ROWTYPE;
    v_cxyf         varchar2(8); --查询月份
    v_qfyf         varchar2(8); --欠费月份
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --实际应缴金额
    v_znj          number(10, 2); --违约金
    v_addr         varchar2(60);
    v_mame         varchar2(60);
    qfyf1_ljf      number(10);
    qfyf2_ljf      number(10);
    v_yjje_ljf     number(10, 2);
    v_znj_ljf      number(10, 2);
    v_out_yjje_ljf number(10, 2);
    cqts_ljf       number(10);
    qfyf1_all      number(10);
    qfyf2_all      number(10);
    v_sxcount      number(10);
    v_jfsx         number(10);
    V_pid          VARCHAR(10); --实收流水
    ---查询月份
    v_cxyf1 varchar2(8); --查询起始月份
    v_cxyf2 varchar2(8); --查询终止月份
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    --欠费游标
    cursor C_QFYF_LIST IS
      select pid
        from (SELECT pid AS pid
                from PAYMENT PM
               WHERE PM.PPRIID = v_ccode
                    --WHERE PM.PMCODE = v_ccode
                 AND PM.PFLAG = 'Y'
                 AND PM.PREVERSEFLAG = 'N'
                 and to_char(PM.Pdate, 'YYYYMMDD') > = v_cxyf1
                 and to_char(PM.Pdate, 'YYYYMMDD') <= v_cxyf2
               GROUP BY pid);
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
  
    --实收记录明细
    cursor c_ysmx is
      select rank() over(partition by ppriid order by pdate desc) vnum,
             to_char(pm.pdate, 'YYYYMMDD') pdate, --交费日期 8
             pm.ppayment, --交费金额 9
             f_getpayway(pm.ppayway) ppayway, --扣费类型 10
             pm.psavingqc, --期初预存 11
             pm.psavingbq, --本期发生
             pm.psavingqm, --期末预存 12
             pm.pposition --交费地点 13
        from payment pm
       WHERE pm.pflag = 'Y'
         and pm.preverseflag = 'N' --计划内抄表
         and PM.PPRIID = v_ccode
         and to_char(PM.Pdate, 'YYYYMMDD') > = v_cxyf1
         and to_char(PM.Pdate, 'YYYYMMDD') <= v_cxyf2
       order by pm.pdate desc;
  
    v_ysmx c_ysmx%rowtype;
  
    --异常返回定义
    err_format exception; --数据格式错
    no_rec exception; --无欠费
    rec_lock exception; --欠费记录锁定
    rec_overflow exception; --欠费月份超出，应到营业所缴费
    znj exception; --有违约金，不能代收
    no_user exception; --无此用户
  
    v_n     number(10);
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
  
  begin
    ----------？？？？？？？？------------
    v_jfsx := 6; --上限
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 9 then
      raise err_format;
    end if;
  
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 33 then
      raise err_format;
    end if;
  
    --取得查询的时间间隔
    v_cxyf1 := trim(F_GET_HDTEXT(8)); --起始交费日期
    v_cxyf2 := trim(F_GET_HDTEXT(9)); --终止交费日期
  
    -- STEP 1:取客户名称资料
    pstep   := 1;
    v_ccode := trim(F_GET_HDTEXT(7));
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    --判断是否坐收用户
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
  
    --判断是一户一表还是一户多表
    if mi.mipriflag = 'Y' then
      v_ccode := mi.mipriid;
      --重新取合收主表数据
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(3, v_ccode); --户号
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --户名
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --户地址
  
    --STEP 2: 检查欠费记录数
    pstep := 2;
  
    --记录数
    select count(pid)
      into qfyf2_all
      from (select pm.pid pid
              from payment pm
             WHERE PM.PPRIID = v_ccode
               AND PM.PFLAG = 'Y'
               AND PM.PREVERSEFLAG = 'N'
               and to_char(PM.Pdate, 'YYYYMMDD') > = v_cxyf1
               and to_char(PM.Pdate, 'YYYYMMDD') <= v_cxyf2);
  
    --记录数
    IF qfyf2_all = 0 THEN
      raise no_rec; --无记录数
    
      /*elsif qfyf2_all > v_jfsx then
      ---*** end ***---
      raise rec_overflow; --记录数超出*/
    else
      --判断如果实际笔数大于限制条数，则记录数取限制条数
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, v_jfsx); --记录数  
      else
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --记录数  
      end if;
    end if;
  
    --STEP 3: 取预存金额
    pstep := 3;
    --预存金额转换为字符串
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --预定欠费记录数
  
    --STEP 4:组织实收数据
    pstep := 5;
  
    --根据记录数扩充packetsDT数据
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --如果缴费记录超出，则只返回最近的3笔明细
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --哈尔滨需求  8-13循环取值
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(8 + (v_n * 6), to_char(v_ysmx.pdate)); --交费日期
      rcount := F_SET_TEXT(9 + (v_n * 6), to_char(v_ysmx.ppayment * 100)); --交费金额
      rcount := F_SET_TEXT(10 + (v_n * 6), v_ysmx.ppayway); --扣费类型
      rcount := F_SET_TEXT(11 + (v_n * 6), to_char(v_ysmx.psavingqc * 100)); --期初预存
      rcount := F_SET_TEXT(12 + (v_n * 6), to_char(v_ysmx.psavingqm * 100)); --期末预存
      rcount := F_SET_TEXT(13 + (v_n * 6), v_ysmx.pposition); --交费地点
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --无此客户
        rcount := F_SET_TEXT(2, '001');
      end if;
    when no_user then
      rcount := F_SET_TEXT(2, '001');
    when no_rec then
      rcount := F_SET_TEXT(2, '004');
    when rec_lock then
      rcount := F_SET_TEXT(2, '003');
    when rec_overflow then
      rcount := F_SET_TEXT(2, '023');
    when znj then
      rcount := F_SET_TEXT(2, '009');
    when others then
      raise;
  end f522;

  /*----------------------------------------------------------------------
  Note: 组织一个月的欠费数据
  Input: p_qf
  Output:p_qf
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure sp_qf_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm     VARCHAR2(10);
    v_zm     VARCHAR2(10);
    v_sl     number(10);
    v_jtsl01 number(12, 2); ---阶梯水量1
    v_jtsl02 number(12, 2); ---阶梯水量2
    v_jtsl03 number(12, 2); ---阶梯水量3
  
    v_dj01   number(12, 2); --水价01
    v_jtdj01 number(12, 2); ---阶梯水价1
    v_jtdj02 number(12, 2); ---阶梯水价2
    v_jtdj03 number(12, 2); ---阶梯水价3
  
    v_dj02 number(12, 2); --水价02
    v_dj03 number(12, 2); --水价03
    v_dj04 number(12, 2); --水价04
    v_dj05 number(12, 2); --水价05
  
    v_sf01   number(10, 2); --水费01
    v_jtsf01 number(12, 2); ---阶梯水费1
    v_jtsf02 number(12, 2); ---阶梯水费2
    v_jtsf03 number(12, 2); ---阶梯水费3
    v_sf02   number(10, 2); --水费02
    v_sf03   number(10, 2); --水费03
    v_sf04   number(10, 2); --水费04
    v_sf05   number(10, 2); --水费05
  
    v_ljf   number(10, 2); --垃圾费
    v_zys   number(10, 2); --总应收
    v_znj   number(10, 2); --违约金
    rcount  number(10);
    v_ysxz  varchar2(20); --用水性质
    v_sqcbr varchar2(8);
    v_bqcbr varchar2(8);
    v_bkh   varchar2(14);
  begin
    ----本月总金额  起码、止码，只取计划内抄表记录的起码、止码
    --水价、排系、排水价 、水资源价、水费  、排水费、水资源费
    --水量
    begin
      select max(f_getcardno(rlmcode)),
             min(to_char(nvl(rl.RLSCODE, 0))),
             min(to_char(rl.rlprdate, 'YYYYMMDD')),
             max(to_char(nvl(rl.RLECODE, 0))),
             min(to_char(rl.rlrdate, 'YYYYMMDD')),
             /*  nvl(sum(case
                   when rd.rdpiid = '01' and rd.rdclass = 0   then
                    rddj * rd.rdpmdscale
                   else
                    0
                 end),
             0) as dj01,*/
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rddj
                       else
                        0
                     end),
                 0) as jtdj01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rddj
                       else
                        0
                     end),
                 0) as jtdj02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rddj
                       else
                        0
                     end),
                 0) as jtdj03,
             sum(decode(rd.rdpiid, '02', rddj * rd.rdpmdscale, 0)) as dj02,
             
             /*   nvl(sum(case
                   when rd.rdpiid = '01' and rd.rdclass = 0 then
                    rdje
                   else
                    0
                 end),
             0) as je01,*/
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdje
                       else
                        0
                     end),
                 0) as jtje01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje03,
             
             sum(decode(rd.rdpiid, '02', rdje, 0)) as je02,
             
             -- sum(decode(rd.rdpiid, '01', rdsl, 0)) sl,
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl03,
             PG_EWIDE_PAY_01.getznjadj(rlid,
                                       sum(rdje),
                                       rlgroup,
                                       max(rlzndate),
                                       RLSMFID,
                                       trunc(sysdate))
        into v_bkh,
             v_qm,
             v_sqcbr,
             v_zm,
             v_Bqcbr,
             
             v_jtdj01,
             v_jtdj02,
             v_jtdj03,
             v_dj02,
             
             v_jtsf01,
             v_jtsf02,
             v_jtsf03,
             v_sf02,
             
             v_jtsl01,
             v_jtsl02,
             v_jtsl03,
             v_znj
        from reclist rl, recdetail rd
       WHERE RL.RLMCODE = trim(p_qf(3))
         AND RL.RLID = RD.RDID
         AND RL.RLID = P_RLID
            -- AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --指定月份
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --计划内抄表
    exception
      when no_data_found then
        ---------------------------
        --   v_ysxz   := 0;
        v_qm     := 0;
        v_zm     := 0;
        v_dj01   := 0;
        v_jtdj01 := 0;
        v_jtdj02 := 0;
        v_jtdj03 := 0;
        v_dj02   := 0;
        /*  v_dj03   := 0;
        v_dj04   := 0;
        v_dj05   := 0;
        v_dj06   := 0;
        v_dj07   := 0;
        v_dj08   := 0;*/
        ---------=----------------
        v_sf01   := 0;
        v_jtsf01 := 0;
        v_jtsf02 := 0;
        v_jtsf03 := 0;
        v_sf02   := 0;
        /* v_sf03   := 0;
        v_sf04   := 0;
        v_sf05   := 0;
        v_sf06   := 0;
        v_sf07   := 0;
        v_sf08   := 0;*/
        v_sl     := 0;
        v_jtsl01 := 0;
        v_jtsl02 := 0;
        v_jtsl03 := 0;
      
        v_znj := 0;
    end;
    --垃圾费
  
    v_sl := nvl(v_sl, 0);
    --滞纳金、追减费、缴费金额、预留金额
    --设置数据包
    v_zys := v_sf02 + v_znj + v_jtsf01 + v_jtsf02 + v_jtsf03; --计算总应收
  
    --垃圾费
    v_ljf := v_ljf;
  
    --数字需要左齐，而且未考虑单价或金额有三位小数时*100后，任还有一位小数的时候
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_zys * 100), 10, ' '); --本月欠费总金额                
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --表卡号
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --起码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --上期抄表日
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --止码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --本期抄表日
  
    ---水价的造成
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jt水价01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jt水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jt水价03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --水价02
    --水量的造成
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jt水量01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jt水量02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jt水量03
  
    --水费的造成
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jt水费01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jt水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jt水费03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --水费02 
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_znj * 100), 10, ' '); --违约金
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --追减费
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留1  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留2 
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留3                                    
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留4
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留5
  end;

  /*----------------------------------------------------------------------
  Note: 组织一笔应收记录数据
  Input: p_qf
  Output:p_qf
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure sp_ysjl_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---阶梯水量1
    v_jtsl02 number(12, 2); ---阶梯水量2
    v_jtsl03 number(12, 2); ---阶梯水量3
  
    v_dj01   number(12, 2); --水价01
    v_jtdj01 number(12, 2); ---阶梯水价1
    v_jtdj02 number(12, 2); ---阶梯水价2
    v_jtdj03 number(12, 2); ---阶梯水价3
  
    v_dj02 number(12, 2); --水价02
    v_dj03 number(12, 2); --水价03
    v_dj04 number(12, 2); --水价04
    v_dj05 number(12, 2); --水价05
    v_dj06 number(12, 2); --水价06
    v_dj07 number(12, 2); --水价07
    v_dj08 number(12, 2); --水价08
  
    v_sf01   number(10, 2); --水费01
    v_jtsf01 number(12, 2); ---阶梯水费1
    v_jtsf02 number(12, 2); ---阶梯水费2
    v_jtsf03 number(12, 2); ---阶梯水费3
    v_sf02   number(10, 2); --水费02
    v_sf03   number(10, 2); --水费03
    v_sf04   number(10, 2); --水费04
    v_sf05   number(10, 2); --水费05
    v_sf06   number(10, 2); --水费06
    v_sf07   number(10, 2); --水费07
    v_sf08   number(10, 2); --水费08
  
    v_ljf   number(10, 2); --垃圾费
    v_zys   number(10, 2); --总应收
    v_znj   number(10, 2); --违约金
    rcount  number(10);
    v_bkh   varchar2(20);
    v_sqcbr varchar2(8);
    v_bqcbr varchar2(8);
  begin
    ----本月总金额  起码、止码，只取计划内抄表记录的起码、止码
    --水价、排系、排水价 、水资源价、水费  、排水费、水资源费
    --水量
    begin
      select max(f_getcardno(rlmcode)) as bkh,
             min(to_char(nvl(rl.RLSCODE, 0))) as qm,
             max(to_char(nvl(rl.RLECODE, 0))) as zm,
             max(to_char(rl.RLPRDATE, 'YYYYMMDD')) as sqcbr,
             max(to_char(rl.RLRDATE, 'YYYYMMDD')) as bqcbr,
             /*  nvl(sum(case
                   when rd.rdpiid = '01' and rd.rdclass = 0 then
                    rddj * rd.rdpmdscale
                   else
                    0
                 end),
             0) as dj01,*/
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj03,
             sum(decode(rd.rdpiid, '02', rddj * rd.rdpmdscale, 0)) as dj02,
             
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdje
                       else
                        0
                     end),
                 0) as jtje01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje03,
             
             sum(decode(rd.rdpiid, '02', rdje, 0)) as je02,
             
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl03
      
        into v_bkh,
             v_qm,
             v_zm,
             v_sqcbr,
             v_bqcbr,
             
             v_jtdj01,
             v_jtdj02,
             v_jtdj03,
             v_dj02,
             
             v_jtsf01,
             v_jtsf02,
             v_jtsf03,
             v_sf02,
             
             v_jtsl01,
             v_jtsl02,
             v_jtsl03
        from reclist rl, recdetail rd
       WHERE RL.RLID = RD.RDID
         AND RL.RLID = P_RLID
            --  AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --指定月份
         AND RL.RLJE > 0
            -- AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --计划内抄表
    exception
      when no_data_found then
        ---------------------------
        v_bkh    := 0;
        v_qm     := 0;
        v_zm     := 0;
        v_sqcbr  := 0;
        v_bqcbr  := 0;
        v_dj01   := 0;
        v_dj02   := 0;
        v_dj03   := 0;
        v_dj04   := 0;
        v_dj05   := 0;
        v_dj06   := 0;
        v_dj07   := 0;
        v_dj08   := 0;
        v_jtsf01 := 0;
        v_jtsf02 := 0;
        v_jtsf03 := 0;
        v_jtsL01 := 0;
        v_jtsL02 := 0;
        v_jtsL03 := 0;
      
        v_jtDJ01 := 0;
        v_jtDJ02 := 0;
        v_jtDJ03 := 0;
        ---------=----------------
        v_sf01 := 0;
        v_sf02 := 0;
        v_sf03 := 0;
        v_sf04 := 0;
        v_sf05 := 0;
        v_sf06 := 0;
        v_sf07 := 0;
        v_sf08 := 0;
        v_sl   := 0;
      
    end;
    --垃圾费
  
    v_sl := nvl(v_sl, 0);
    --滞纳金、追减费、缴费金额、预留金额
    --设置数据包
    v_zys := v_sf02 + v_jtsf01 + v_jtsf02 + v_jtsf03; --计算总应收
  
    --垃圾费
    v_ljf := v_ljf;
  
    --数字需要左齐，而且未考虑单价或金额有三位小数时*100后，任还有一位小数的时候
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(v_zys, 0) * 100), 10, ' '); --本月欠费总金额
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --表卡号
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --起码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --上期抄表日
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --止码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --本期抄表日
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jt水价01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jt水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jt水价03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --水价02
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jt水量01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jt水量02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jt水量03
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jt水费01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jt水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jt水费03             
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留4  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留5
  
  end;

  /*----------------------------------------------------------------------
  Note: 组织一笔实收记录数据
  Input: p_qf
  Output:p_qf
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure sp_ssjl_month(p_qf in out arr, p_pid in varchar2) as
  
    v_pparment  number(12, 2);
    v_ppayway   varchar2(10);
    v_psavingqc number(12, 2);
    v_psavingbq number(12, 2);
    v_psavingqm number(12, 2);
    v_pposition varchar2(10);
  
  begin
    ----本月总金额  起码、止码，只取计划内抄表记录的起码、止码
    --水价、排系、排水价 、水资源价、水费  、排水费、水资源费
    --水量
    begin
      select pm.ppayment,
             pm.ppayway,
             pm.psavingqc,
             pm.psavingbq,
             pm.psavingqm,
             pm.pposition
        into v_pparment,
             v_ppayway,
             v_psavingqc,
             v_psavingbq,
             v_psavingqm,
             v_pposition
        from payment pm
       WHERE pm.pid = p_pid
         and pm.pflag = 'Y'
         and pm.preverseflag = 'N'; --计划内抄表
    exception
      when no_data_found then
        ---------------------------
        v_pparment  := 0;
        v_ppayway   := '';
        v_psavingqc := 0;
        v_psavingbq := 0;
        v_psavingqm := 0;
        v_pposition := '';
    end;
  
    --数字需要左齐，而且未考虑单价或金额有三位小数时*100后，任还有一位小数的时候
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_pparment * 100), 10, ' '); --交费金额
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_ppayway, 20, ' '); ---扣费类型 
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_psavingqc * 100), 10, ' '); --交费金额
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_psavingqm * 100), 10, ' '); --12  期未预存  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_pposition, 20, ' '); ---扣费类型                    
  end;

  /*----------------------------------------------------------------------
  Note: 组织一笔应收记录数据(销账)
  Input: p_qf
  Output:p_qf
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure sp_ssjy_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---阶梯水量1
    v_jtsl02 number(12, 2); ---阶梯水量2
    v_jtsl03 number(12, 2); ---阶梯水量3
  
    v_dj01   number(12, 2); --水价01
    v_jtdj01 number(12, 2); ---阶梯水价1
    v_jtdj02 number(12, 2); ---阶梯水价2
    v_jtdj03 number(12, 2); ---阶梯水价3
  
    v_dj02 number(12, 2); --水价02
    v_dj03 number(12, 2); --水价03
    v_dj04 number(12, 2); --水价04
    v_dj05 number(12, 2); --水价05
    v_dj06 number(12, 2); --水价06
    v_dj07 number(12, 2); --水价07
    v_dj08 number(12, 2); --水价08
  
    v_sf01   number(10, 2); --水费01
    v_jtsf01 number(12, 2); ---阶梯水费1
    v_jtsf02 number(12, 2); ---阶梯水费2
    v_jtsf03 number(12, 2); ---阶梯水费3
    v_sf02   number(10, 2); --水费02
    v_sf03   number(10, 2); --水费03
    v_sf04   number(10, 2); --水费04
    v_sf05   number(10, 2); --水费05
    v_sf06   number(10, 2); --水费06
    v_sf07   number(10, 2); --水费07
    v_sf08   number(10, 2); --水费08
  
    v_ljf     number(10, 2); --垃圾费
    v_zys     number(10, 2); --总应收
    v_znj     number(10, 2); --违约金
    rcount    number(10);
    v_bkh     varchar2(20);
    v_sqcbr   varchar2(8);
    v_bqcbr   varchar2(8);
    v_rlmcode varchar2(10);
  begin
    ----本月总金额  起码、止码，只取计划内抄表记录的起码、止码
    --水价、排系、排水价 、水资源价、水费  、排水费、水资源费
    --水量
    begin
      select max(f_getcardno(rlmcode)) as bkh,
             max(rl.rlmcode) as rlmcode,
             min(to_char(nvl(rl.RLSCODE, 0))) as qm,
             max(to_char(nvl(rl.RLECODE, 0))) as zm,
             max(to_char(rl.RLPRDATE, 'YYYYMMDD')) as sqcbr,
             max(to_char(rl.RLRDATE, 'YYYYMMDD')) as bqcbr,
             /*  nvl(sum(case
                   when rd.rdpiid = '01' and rd.rdclass = 0 then
                    rddj * rd.rdpmdscale
                   else
                    0
                 end),
             0) as dj01,*/
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rddj * rd.rdpmdscale
                       else
                        0
                     end),
                 0) as jtdj03,
             sum(decode(rd.rdpiid, '02', rddj * rd.rdpmdscale, 0)) as dj02,
             
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdje
                       else
                        0
                     end),
                 0) as jtje01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdje
                       else
                        0
                     end),
                 0) as jtje03,
             
             sum(decode(rd.rdpiid, '02', rdje, 0)) as je02,
             
             nvl(sum(case
                       when rd.rdpiid = '01' and (rd.rdclass = 1 or rd.rdclass = 0) then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl01,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 2 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl02,
             nvl(sum(case
                       when rd.rdpiid = '01' and rd.rdclass = 3 then
                        rdsl
                       else
                        0
                     end),
                 0) as jtsl03,
             sum(rdznj) znj
        into v_bkh,
             v_rlmcode,
             v_qm,
             v_zm,
             v_sqcbr,
             v_bqcbr,
             
             v_jtdj01,
             v_jtdj02,
             v_jtdj03,
             v_dj02,
             
             v_jtsf01,
             v_jtsf02,
             v_jtsf03,
             v_sf02,
             
             v_jtsl01,
             v_jtsl02,
             v_jtsl03,
             v_znj
        from reclist rl, recdetail rd
       WHERE RL.RLID = RD.RDID
         AND RL.RLID = P_RLID
            --  AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --指定月份
         AND RL.RLJE > 0
            -- AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --计划内抄表
    exception
      when no_data_found then
        ---------------------------
        v_bkh    := 0;
        v_qm     := 0;
        v_zm     := 0;
        v_sqcbr  := 0;
        v_bqcbr  := 0;
        v_dj01   := 0;
        v_dj02   := 0;
        v_dj03   := 0;
        v_dj04   := 0;
        v_dj05   := 0;
        v_dj06   := 0;
        v_dj07   := 0;
        v_dj08   := 0;
        v_jtsf01 := 0;
        v_jtsf02 := 0;
        v_jtsf03 := 0;
        v_jtsL01 := 0;
        v_jtsL02 := 0;
        v_jtsL03 := 0;
      
        v_jtDJ01 := 0;
        v_jtDJ02 := 0;
        v_jtDJ03 := 0;
        ---------=----------------
        v_sf01 := 0;
        v_sf02 := 0;
        v_sf03 := 0;
        v_sf04 := 0;
        v_sf05 := 0;
        v_sf06 := 0;
        v_sf07 := 0;
        v_sf08 := 0;
        v_sl   := 0;
      
    end;
    --垃圾费
  
    v_sl  := nvl(v_sl, 0);
    v_znj := nvl(v_znj, 0);
    --滞纳金、追减费、缴费金额、预留金额
    --设置数据包
    v_zys := v_sf02 + v_jtsf01 + v_jtsf02 + v_jtsf03 + v_znj; --计算总应收
  
    --垃圾费
    v_ljf := v_ljf;
  
    --数字需要左齐，而且未考虑单价或金额有三位小数时*100后，任还有一位小数的时候
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(v_zys, 0) * 100), 10, ' '); --本月欠费总金额
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --表卡号
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --起码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --上期抄表日
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --止码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --本期抄表日
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jt水价01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jt水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jt水价03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jt水量01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jt水量02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jt水量03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jt水费01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jt水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jt水费03             
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_znj * 100), 10, ' '); --违约金
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --追减量
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_rlmcode, 14, ' '); --户号                                             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留4  
  
  end;
  /*----------------------------------------------------------------------
  Note: 组织一笔应收记录数据(销账)
  Input: p_qf
  Output:p_qf
  Return:返回包
  ----------------------------------------------------------------------*/
  procedure sp_ssyc_month(p_qf in out arr) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---阶梯水量1
    v_jtsl02 number(12, 2); ---阶梯水量2
    v_jtsl03 number(12, 2); ---阶梯水量3
  
    v_dj01   number(12, 2); --水价01
    v_jtdj01 number(12, 2); ---阶梯水价1
    v_jtdj02 number(12, 2); ---阶梯水价2
    v_jtdj03 number(12, 2); ---阶梯水价3
  
    v_dj02 number(12, 2); --水价02
    v_dj03 number(12, 2); --水价03
    v_dj04 number(12, 2); --水价04
    v_dj05 number(12, 2); --水价05
    v_dj06 number(12, 2); --水价06
    v_dj07 number(12, 2); --水价07
    v_dj08 number(12, 2); --水价08
  
    v_sf01   number(10, 2); --水费01
    v_jtsf01 number(12, 2); ---阶梯水费1
    v_jtsf02 number(12, 2); ---阶梯水费2
    v_jtsf03 number(12, 2); ---阶梯水费3
    v_sf02   number(10, 2); --水费02
    v_sf03   number(10, 2); --水费03
    v_sf04   number(10, 2); --水费04
    v_sf05   number(10, 2); --水费05
    v_sf06   number(10, 2); --水费06
    v_sf07   number(10, 2); --水费07
    v_sf08   number(10, 2); --水费08
  
    v_ljf     number(10, 2); --垃圾费
    v_zys     number(10, 2); --总应收
    v_znj     number(10, 2); --违约金
    rcount    number(10);
    v_bkh     varchar2(20);
    v_sqcbr   varchar2(8);
    v_bqcbr   varchar2(8);
    v_rlmcode varchar2(10);
  begin
    ----本月总金额  起码、止码，只取计划内抄表记录的起码、止码
    --水价、排系、排水价 、水资源价、水费  、排水费、水资源费
    --水量
  
    ---------------------------
    v_bkh    := 0;
    v_qm     := 0;
    v_zm     := 0;
    v_sqcbr  := 0;
    v_bqcbr  := 0;
    v_dj01   := 0;
    v_dj02   := 0;
    v_dj03   := 0;
    v_dj04   := 0;
    v_dj05   := 0;
    v_dj06   := 0;
    v_dj07   := 0;
    v_dj08   := 0;
    v_jtsf01 := 0;
    v_jtsf02 := 0;
    v_jtsf03 := 0;
    v_jtsL01 := 0;
    v_jtsL02 := 0;
    v_jtsL03 := 0;
  
    v_jtDJ01 := 0;
    v_jtDJ02 := 0;
    v_jtDJ03 := 0;
    ---------=----------------
    v_sf01 := 0;
    v_sf02 := 0;
    v_sf03 := 0;
    v_sf04 := 0;
    v_sf05 := 0;
    v_sf06 := 0;
    v_sf07 := 0;
    v_sf08 := 0;
    v_sl   := 0;
  
    --垃圾费
  
    --数字需要左齐，而且未考虑单价或金额有三位小数时*100后，任还有一位小数的时候
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(0, 0) * 100), 10, ' '); --本月欠费总金额
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 14, ' '); --表卡号
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --起码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 8, ' '); --上期抄表日
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --止码
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 8, ' '); --本期抄表日
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水价01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水价03
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --水价02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jt水量01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jt水量02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jt水量03
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水费01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jt水费03             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --水费02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --违约金
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --追减量
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 14, ' '); --户号                                             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --预留4  
  
  end;
  /*----------------------------------------------------------------------
  Note: 600 单缴预存交易处理
  Input: p_bankid -- 银行编码
         p_chgno  -- 银行流水
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f600(p_in in arr, p_out in out arr) as
    pstep number(10); --事务处理进度
  
    p_bankid varchar2(20);
    p_chgno  varchar2(30);
  
    v_ccode varchar2(30); --水表资料号
  
    v_chg_total number(10, 2); --缴费金额
    v_chg_op    varchar2(20); --缴费员
  
    v_chgno     varchar(20); --凭证流水
    v_discharge number(10, 2); --本次缴费抵扣金额
    v_curr_sav  number(10, 2); --本次缴费后预存金额
    /*   v_bankid    varchar2(10);*/
    v_bankcode varchar2(10);
    rcount     number(10);
    --异常返回定义
    err_format exception; --数据格式错
    err_charge exception; --缴费错误
  begin
  
    /*   if p_in.count<>8 then
       raise err_format;
    end if;*/
    --预设输出参数的1，2单元
    rcount      := F_SET_TEXT(1, F_GET_HDTEXT(6));
    rcount      := F_SET_TEXT(2, '000');
    p_bankid    := F_GET_HDTEXT(1);
    p_chgno     := F_GET_HDTEXT(4);
    v_ccode     := F_GET_HDTEXT(7);
    v_chg_total := to_number(F_GET_HDTEXT(8)) / 100;
    v_chg_op    := F_GET_HDTEXT(9);
    v_chgno     := p_chgno;
    rcount      := 0;
  
    if rcount <> 0 then
      raise err_charge;
    end if;
    rcount := F_SET_TEXT(3, v_chgno);
    rcount := F_SET_TEXT(4, to_char(v_chg_total * 100));
    rcount := F_SET_TEXT(5, to_char(v_discharge * 100));
    rcount := F_SET_TEXT(6, to_char(v_curr_sav * 100));
    ---*** end ***---
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when err_charge then
      rcount := F_SET_TEXT(2, trim(to_char(rcount, '000')));
    when others then
      rcount := F_SET_TEXT(2, '021');
  end f600;

  /*----------------------------------------------------------------------
  Note: 540缴费交易处理
  Input: p_bankid -- 银行编码
         p_chgno  -- 银行流水
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
 /* procedure f540(p_in in arr, p_out in out arr) as
  
    pstep      number(10); --事务处理进度
    v_retstr   varchar2(10); --返回结果
    V_OUTCOUNT NUMBER(10);
    V_RLIDS    VARCHAR2(20000); --应收流水
    V_RLJE     NUMBER(12, 2); --应收金额
    V_ZNJ      NUMBER(12, 2); --滞纳金
  
    v_LJFJE     NUMBER(12, 2); --垃圾费金额
    v_RLIDS_LJF VARCHAR2(20000); --垃圾费应收流水
    v_out_LJFJE NUMBER(12, 2); --垃圾费销帐金额
  
    v_SXF NUMBER(12, 2); --//手续费
  
    v_POSITION  varchar2(10); -- //缴费机构-
    v_OPER      payment.pper%type; --//收款员
    v_ptrans    payment.ptrans%type; --//收款员
    v_mcode     varchar2(30); --  --客户代码
    mi          meterinfo%rowtype;
    CI          CUSTINFO%ROWTYPE;
    v_chgno     payment.PBSEQNO%type; -- --交易流水
    v_pbatch    payment.pbatch%type; -- --交易批次
    v_chg_op    payment.pper%type;
    v_PAYJE     number(10, 2); --缴费金额
    v_discharge number(10, 2); --本次缴费抵扣金额
    v_curr_sav  number(10, 2); --本次缴费后预存金额
    v_fppc      varchar2(14); ---发票批次
    v_fpno      varchar2(10); ---发票号码
    v_paypoint  varchar2(20); ---缴费分支机构
    v_pdate     varchar2(14); ---交易时间
    v_sbs       number(10);
    rcount      number(10);
    v_addr      varchar2(60);
    v_mame      varchar2(60);
  
    v_sfdj    number(12, 3);
    v_wsfdj   number(12, 3);
    v_sf      number(12, 2);
    v_wsf     number(12, 2);
    v_ssznj   number(12, 2);
    v_sl      number(10);
    V_DJ      NUMBER(12, 3);
    v_zys     number(12, 2);
    v_sxcount number(10);
    V_RLID    varchar2(10);
    v_jfsx    number(10);
    qfyf2_all number(10);
    v_qfyf    varchar2(8);
  
    v_month  varchar2(400);
    v_xj     varchar2(400);
    v_zkh    varchar2(400);
    v_scode  varchar2(400);
    v_srdate varchar2(400);
    v_ecode  varchar2(400);
    v_erdate varchar2(400);
    v_sfdj1  varchar2(400);
    v_sfdj2  varchar2(400);
    v_sfdj3  varchar2(400);
    v_wsdj   varchar2(400);
    v_sl1    varchar2(400);
    v_sl2    varchar2(400);
    v_sl3    varchar2(400);
    v_sf1    varchar2(400);
    v_sf2    varchar2(400);
    v_sf3    varchar2(400);
    v_wsje   varchar2(400);
    v_wyj1   varchar2(400);
    v_zjje   varchar2(400);
    v_code   varchar2(400);
    v_yl1    varchar2(400);
    v_yl2    varchar2(400);
    v_yl3    varchar2(400);
    v_yl4    varchar2(400);
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    ---- 销账游标
    cursor C_QFYF_LIST IS
      select rlid
        from (SELECT rlid AS rlid
                from PAYMENT PM, reclist rl
               WHERE PM.PPRIID = v_mcode
                    --WHERE PM.PMCODE = v_mcode
                 and rl.rlpid = pm.pid
                 and rl.rlreverseflag = 'N'
                 and rl.rlpaidflag = 'Y'
                 AND PM.PFLAG = 'Y'
                 AND PM.PREVERSEFLAG = 'N'
                 and pm.pbseqno = v_chgno
               GROUP BY rlid);
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
  
    --实收交易响应包循环账务明细
    cursor c_ysmx is
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份20
             to_char((chargetotal + chargeznj) * 100) xj, --小计21
             trim(f_getcardno(rlmid)) rlbfid, --帐卡号22
             to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLSCODE))) RLSCODE, --起码23
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --上次抄表日期24
             to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLECODE))) RLECODE, --止码25
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --本期抄表日期26
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --水费单价一阶27
             to_char(USER_DJ2 * 100) USER_DJ2, --水费单价二阶28
             to_char(USER_DJ3 * 100) USER_DJ3, --水费单价三阶29
             to_char(dj2 * 100) dj2, --污水单价30
             to_char(decode(use_r1, 0, wateruse)) use_r1, --水量一阶31
             to_char(use_r2) use_r2, --水量二阶32
             to_char(use_r3) use_r3, --水量三阶33
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --水费一阶34
             to_char(charge_r2 * 100) charge_r2, --水费二阶35
             to_char(charge_r3 * 100) charge_r3, --水费三阶36
             to_char(charge2 * 100) charge2, --污水金额37
             to_char(chargeznj * 100) chargeznj, --违约金38
             '0' zjje, --追减金额39
             rlmid, --客户代码40
             '' yl1, --预留1 41
             '' yl2, --预留1 42
             '' yl3, --预留1 43
             '' yl4 --预留1 44
        from reclist rl, view_reclist_charge_02 rd, payment pm
       where rl.rlpid = pm.pid
         and rlid = rdid
         and pm.preverseflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'Y'
         and pm.pbseqno = v_chgno
         and pm.ppriid = v_mcode
       order by rldate desc;
  
    -----------------------20130923 单缴预存----------------------------
    cursor c_hs_meter IS
      select rank() over(partition by mipriid order by mircode desc) vnum,
             mibfid,
             mirorder,
             miid,
             mircode,
             mirecdate
        from meterinfo mi
       where mipriid = v_mcode
       order by mircode desc;
  
    v_hs_meter c_hs_meter%rowtype;
    ---------------------------------------------------
  
    v_ysmx c_ysmx%rowtype;
    --异常返回定义
    err_format exception; --数据格式错
    err_charge exception; --缴费错误
    err_je exception; --金额不符
    err_nouser exception; --用户不存在
    err_clockje exception; --003：记录已锁（如已转非实时方式处理）
    err_other exception; --
    err_exist exception;
    rec_overflow exception; --欠费月份超出，应到营业所缴费
    no_user exception; --无此用户
    
    err_ymsz exception; --月末锁帐
    v_bankid  varchar2(10);  --银行分支机构
    
    v_b       number(10);
    v_e       number(10);
    v_n       number(10);
    v_count   number(10); --交易包字段数
    v_inlen   number(10); --交易包包长度
    v_seqno   payment.PBSEQNO%type; -- --交易流水
    v_pbseqno number(10); --校验银行流水
  
  begin
    \*--检查是否存在循环
    SELECT to_number(nvl(c2,'0')) into v_b FROM packetsDT WHERE C3='b';
    SELECT to_number(nvl(c2,'0')) into v_e FROM packetsDT WHERE C3='b';*\
    --获取循环次数
    v_jfsx := 6; --上限
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 13 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 93 then
      raise err_format;
    end if;
    
    --判断是否已月末扎帐
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
      v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
      if F_GETBANKSYSPARA(v_bankid)='N' then
         raise err_ymsz;
      end if;
    --end if;
    
    --校验银行540交易流水是否已存在
    v_pbseqno := 0;
    v_seqno   := trim(F_GET_HDTEXT(4)); --交易流水
    select count(*) into v_pbseqno from payment where pbseqno = v_seqno;
    if v_pbseqno > 0 then
      raise err_exist;
    end if;
  
    v_mcode := trim(F_GET_HDTEXT(7)); --客户代码
    if length(v_mcode) = 14 then
      v_mcode := substr(v_mcode, 4, 1) || substr(v_mcode, 5, 2) ||
                 substr(v_mcode, 8, 1) || substr(v_mcode, 9, 6);
    end if;
  
    v_paypoint := trim(F_GET_HDTEXT(10)); --银行分支机构
    v_pdate    := trim(F_GET_HDTEXT(11)); --缴费时间
    v_fppc     := trim(F_GET_HDTEXT(12)); --发票代码
    v_fpno     := trim(F_GET_HDTEXT(13)); --发票号
  
    ---取户表的信息：
    select t.* into MI from METERINFO t where t.micode = v_mcode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --判断是否坐收用户
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
  
    if mi.mipriflag = 'N' then
      v_sbs := 1;
    else
      v_mcode := mi.mipriid;
      select nvl(count(t.micode), 1)
        into v_sbs
        from meterinfo t
       where t.mipriid = v_mcode;
      --重新取合收主表数据
      select t.* into MI from METERINFO t where t.micode = v_mcode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    --统计欠费记录数
    select count(rlid)
      into qfyf2_all
      from (SELECT rlid AS rlid
              from reclist rl
             WHERE rlprimcode = v_mcode
                  --WHERE rlmcode = v_mcode
               and rl.rlreverseflag = 'N'
               and rl.rlpaidflag = 'N'
               and rl.rlje > 0
               and rl.rlbadflag = 'N'
             GROUP BY rlid);
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------
  
    --超出限定条数 不让缴费返回023错误
    if qfyf2_all > v_jfsx then
      null;
      --raise rec_overflow;  --20131212放宽限制，超过6笔也可以缴费
    end if;
  
    v_POSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_OPER     := trim(F_GET_HDTEXT(9));
  
    v_PAYJE  := to_number(F_GET_HDTEXT(8)) / 100; --缴费金额
    v_chgno  := trim(F_GET_HDTEXT(4)); --交易流水
    v_ptrans := 'B';
  
    v_retstr := f_bank_chg_total(v_POSITION,
                                 v_OPER,
                                 v_mcode,
                                 v_PAYJE,
                                 v_ptrans,
                                 v_chgno,
                                 v_fppc,
                                 v_fpno,
                                 v_discharge,
                                 v_curr_sav);
  
    if v_retstr = '001' then
      --用户不存在
      raise err_nouser;
    elsif v_retstr = '003' then
      --锁帐
      raise err_clockje;
    elsif v_retstr = '005' then
      --金额不符
      raise err_je;
    elsif v_retstr = '021' then
      raise err_other;
    end if;
  
    rcount := F_SET_TEXT(3, to_char(v_PAYJE * 100)); --本次缴费金额
    rcount := F_SET_TEXT(4, to_char(v_sbs)); --用户表数
    rcount := F_SET_TEXT(5, MI.micode); --客户代码
    v_mame := substr(MI.MINAME, 1, 60);
    rcount := F_SET_TEXT(6, v_mame); --户名
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(7, v_addr); --户地址
    rcount := F_SET_TEXT(8, v_chgno); --凭证流水
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    --有欠费，实收交易
    if qfyf2_all > 0 then
      ----取费用信息：
      select sum(decode(rd.rdpiid, 01, rd.rdsl, 0)) sl,
             sum(decode(rd.rdpiid, 01, rd.rdje, 0)) sfje,
             sum(decode(rd.rdpiid, 02, rd.rdje, 0)) wsfje,
             max(pm.pznj) znj,
             sum(rdje) ysje
        into v_sl, v_sf, v_wsf, v_ssznj, v_zys
        from reclist rl, recdetail rd, payment pm
       where rl.rlpid = pm.pid
         and rlid = rdid
         and pm.preverseflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'Y'
         and pm.pbseqno = v_chgno
         and pm.ppriid = v_mcode;
      --and pm.pmcode = v_mcode;
      ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
    
      --------20130912 如果是实收交易，此字段为应收水量；如果是预存交易，此字段为当前表示数----------
      rcount := F_SET_TEXT(9, to_char(v_sl)); --应收水量
      --------------------------end ----------------------------------------------------
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --如果是一户一表或者一户多表水价相同
        --取水费单价和污水费单价
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --水费单价
        rcount := F_SET_TEXT(11, to_char(v_sf * 100)); --水费合计
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --污水费单价
        rcount := F_SET_TEXT(13, to_char(v_wsf * 100)); --污水费合计
      else
        --如果一户多表水价不同
        rcount := F_SET_TEXT(10, '-'); --水费单价
        rcount := F_SET_TEXT(11, '-'); --水费合计
        rcount := F_SET_TEXT(12, '-'); --污水费单价
        rcount := F_SET_TEXT(13, '-'); --污水费合计
      end if;
    
      rcount := F_SET_TEXT(14, to_char(v_ssznj * 100)); --违约金
      rcount := F_SET_TEXT(15, to_char(v_zys * 100)); --应收合计
    
    else
      --预存缴费
      rcount := F_SET_TEXT(9, to_char(MI.MIRCODE)); --本期表示数
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --如果是一户一表或者一户多表水价相同
        --取水费单价和污水费单价
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --水费单价
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --污水费单价
      else
        --如果一户多表水价不同
        rcount := F_SET_TEXT(10, '-'); --水费单价
        rcount := F_SET_TEXT(12, '-'); --污水费单价
      end if;
      rcount := F_SET_TEXT(11, '0'); --水费合计
      rcount := F_SET_TEXT(13, '0'); --污水费合计
      rcount := F_SET_TEXT(14, '0'); --违约金
      rcount := F_SET_TEXT(15, '0'); --应收合计
    
    end if;
  
    rcount := F_SET_TEXT(16, to_char(mi.misaving * 100)); --期初预存
    rcount := F_SET_TEXT(17, to_char(v_curr_sav * 100)); --期末预存
  
    -------------------------20130912修改一户一表为：“预计表示数”；一户多表为：“预计可用水量”---------------------
    if v_sbs = 1 then
      --如果是一户一表
      rcount := F_SET_TEXT(18,
                           to_char(MI.MIRCODE +
                                   floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---预计表示数
    elsif v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y' then
      --如果一户多表水价相同
      rcount := F_SET_TEXT(18,
                           to_char(floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---预计可用水量
    else
      --如果一户多表水价不同
      rcount := F_SET_TEXT(18, '-');
    end if;
    -----------------------------------------------------end-----------------------------------------------------------------
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    --统计本次销账记录数
    \* select count(rlid)
    into qfyf2_all
    from (SELECT rlid AS rlid
            from PAYMENT PM, reclist rl
           WHERE PM.PPRIID = v_mcode
                --WHERE PM.PMCODE = v_mcode
             and rl.rlpid = pm.pid
             and rl.rlreverseflag = 'N'
             and rl.rlpaidflag = 'Y'
             AND PM.PFLAG = 'Y'
             AND PM.PREVERSEFLAG = 'N'
             and pm.pbseqno = v_chgno
           GROUP BY rlid);*\
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
  
    --实收交易
    if qfyf2_all > 0 then
      --实收交易笔数依据返回的明细条数计算
      --判断如果实际笔数大于限制条数，则记录数取限制条数
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --记录数  
      else
        rcount := F_SET_TEXT(19, to_char(qfyf2_all)); --记录数  
      end if;
    
      --根据记录数扩充packetsDT数据
      if qfyf2_all <= v_jfsx then
        sp_extensiondata(qfyf2_all);
      else
        --如果缴费记录超出，则只返回最近的6笔明细
        sp_extensiondata(v_jfsx);
      end if;
      v_n := 0;
      --哈尔滨需求  20-44循环取值
      open c_ysmx;
      loop
        fetch c_ysmx
          into v_ysmx;
        exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
        rcount := F_SET_TEXT(20 + (v_n * 25), to_char(v_ysmx.month)); --年月份
        rcount := F_SET_TEXT(21 + (v_n * 25), to_char(v_ysmx.xj)); --小计
        rcount := F_SET_TEXT(22 + (v_n * 25), to_char(v_ysmx.rlbfid)); --帐卡号
        rcount := F_SET_TEXT(23 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --起码
        rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --上次抄表日期
        rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.RLECODE)); --止码
        rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --本次抄表日期
        rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --水费单价（一阶）
        rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --水费单价（二阶）
        rcount := F_SET_TEXT(29 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --水费单价（三阶）
        rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.dj2)); --污水处理费单价
        rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.use_r1)); --水量（一阶）
        rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.use_r2)); --水量（二阶）
        rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.use_r3)); --水量（三阶）
        rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.charge_r1)); --水费（一阶）
        rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.charge_r2)); --水费（二阶）
        rcount := F_SET_TEXT(36 + (v_n * 25), to_char(v_ysmx.charge_r3)); --水费（三阶）
        rcount := F_SET_TEXT(37 + (v_n * 25), to_char(v_ysmx.charge2)); --污水处理费
        rcount := F_SET_TEXT(38 + (v_n * 25), to_char(v_ysmx.chargeznj)); --违约金
        rcount := F_SET_TEXT(39 + (v_n * 25), to_char(v_ysmx.zjje)); --追减费
        rcount := F_SET_TEXT(40 + (v_n * 25), to_char(v_ysmx.rlmid)); --客户代码
        rcount := F_SET_TEXT(41 + (v_n * 25), to_char(v_ysmx.yl1)); --预留
        rcount := F_SET_TEXT(42 + (v_n * 25), to_char(v_ysmx.yl2)); --预留
        rcount := F_SET_TEXT(43 + (v_n * 25), to_char(v_ysmx.yl3)); --预留
        rcount := F_SET_TEXT(44 + (v_n * 25), to_char(v_ysmx.yl4)); --预留
        v_n    := v_n + 1;
      end loop;
      close c_ysmx;
    
    else
      --单缴预存交易笔数依据返回的明细条数计算
      --判断如果用户数大于限制条数，则记录数取限制条数
      if v_sbs > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --记录数  
      elsif v_sbs>1  then --一户多表打指针明细
        rcount := F_SET_TEXT(19, to_char(v_sbs)); --记录数  
      else--一户一表不打指针明细
        rcount := F_SET_TEXT(19, '0'); --记录数  
      end if;
    
      --根据记录数扩充packetsDT数据
      if v_sbs <= v_jfsx then
        sp_extensiondata(v_sbs);
      else
        --如果缴费记录超出，则只返回最近的6笔明细
        sp_extensiondata(v_jfsx);
      end if;
    
      v_n := 0;
      --哈尔滨需求  20-44循环取值
      open c_hs_meter;
      loop
        fetch c_hs_meter
          into v_hs_meter;
        exit when v_hs_meter.vnum > v_jfsx or c_hs_meter%notfound or c_hs_meter%notfound is null;
        rcount := F_SET_TEXT(20 + (v_n * 25), '-'); --水费发生年月份
        rcount := F_SET_TEXT(21 + (v_n * 25), '-'); --小计
        rcount := F_SET_TEXT(22 + (v_n * 25),
                             trim(v_hs_meter.mibfid || v_hs_meter.mirorder)); --帐卡号
        rcount := F_SET_TEXT(23 + (v_n * 25), '-'); --上次表示数（起码）
        rcount := F_SET_TEXT(24 + (v_n * 25), '-'); --上次抄表日期
        rcount := F_SET_TEXT(25 + (v_n * 25), v_hs_meter.mircode); --本次表示数（止码）
        rcount := F_SET_TEXT(26 + (v_n * 25), v_hs_meter.mirecdate); --本次抄表日期
        rcount := F_SET_TEXT(27 + (v_n * 25), '-'); --水费单价（一阶）
        rcount := F_SET_TEXT(28 + (v_n * 25), '-'); --水费单价（二阶）
        rcount := F_SET_TEXT(29 + (v_n * 25), '-'); --水费单价（三阶）
        rcount := F_SET_TEXT(30 + (v_n * 25), '-'); --污水处理费单价
        rcount := F_SET_TEXT(31 + (v_n * 25), '-'); --水量（一阶）
        rcount := F_SET_TEXT(32 + (v_n * 25), '-'); --水量（二阶）
        rcount := F_SET_TEXT(33 + (v_n * 25), '-'); --水量（三阶）
        rcount := F_SET_TEXT(34 + (v_n * 25), '-'); --水费（一阶）
        rcount := F_SET_TEXT(35 + (v_n * 25), '-'); --水费（二阶）
        rcount := F_SET_TEXT(36 + (v_n * 25), '-'); --水费（三阶）
        rcount := F_SET_TEXT(37 + (v_n * 25), '-'); --污水处理费
        rcount := F_SET_TEXT(38 + (v_n * 25), '-'); --违约金
        rcount := F_SET_TEXT(39 + (v_n * 25), '-'); --追减费
        rcount := F_SET_TEXT(40 + (v_n * 25), v_hs_meter.miid); --客户代码
        rcount := F_SET_TEXT(41 + (v_n * 25), ''); --预留
        rcount := F_SET_TEXT(42 + (v_n * 25), ''); --预留
        rcount := F_SET_TEXT(43 + (v_n * 25), ''); --预留
        rcount := F_SET_TEXT(44 + (v_n * 25), ''); --预留
        v_n    := v_n + 1;
      end loop;
    end if;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_user then
      rcount := F_SET_TEXT(2, '001');
    when err_nouser then
      rcount := F_SET_TEXT(2, '001');
    when err_clockje then
      rcount := F_SET_TEXT(2, '003'); --记录已锁（如已转非实时方式处理）
    when err_je then
      rcount := F_SET_TEXT(2, '005');
    when err_other then
      rcount := F_SET_TEXT(2, '021');
    when rec_overflow then
      rcount := F_SET_TEXT(2, '023');
    when err_ymsz then
      rcount := F_SET_TEXT(2, '022');--月末锁帐 
   when err_exist then  --交易流水
       rcount := F_SET_TEXT(2, '025'); 
    when others then 
      rcount := F_SET_TEXT(2, '024');  --其它
  end;*/
   /*----------------------------------------------------------------------
  Note: 540缴费交易处理
  Input: p_bankid -- 银行编码
         p_chgno  -- 银行流水
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f540(p_in in arr, p_out in out arr) as
  
    pstep      number(10); --事务处理进度
    v_retstr   varchar2(10); --返回结果
    V_OUTCOUNT NUMBER(10);
    V_RLIDS    VARCHAR2(20000); --应收流水
    V_RLJE     NUMBER(12, 2); --应收金额
    V_ZNJ      NUMBER(12, 2); --滞纳金
  
    v_LJFJE     NUMBER(12, 2); --垃圾费金额
    v_RLIDS_LJF VARCHAR2(20000); --垃圾费应收流水
    v_out_LJFJE NUMBER(12, 2); --垃圾费销帐金额
  
    v_SXF NUMBER(12, 2); --//手续费
  
    v_POSITION  varchar2(10); -- //缴费机构-
    v_OPER      payment.pper%type; --//收款员
    v_ptrans    payment.ptrans%type; --//收款员
    v_mcode     varchar2(30); --  --客户代码
    mi          meterinfo%rowtype;
    CI          CUSTINFO%ROWTYPE;
    v_chgno     payment.PBSEQNO%type; -- --交易流水
    v_pbatch    payment.pbatch%type; -- --交易批次
    v_chg_op    payment.pper%type;
    v_PAYJE     number(10, 2); --缴费金额
    v_discharge number(10, 2); --本次缴费抵扣金额
    v_curr_sav  number(10, 2); --本次缴费后预存金额
    v_fppc      varchar2(14); ---发票批次
    v_fpno      varchar2(10); ---发票号码
    v_paypoint  varchar2(20); ---缴费分支机构
    v_pdate     varchar2(14); ---交易时间
    v_pid       payment.pid%type; --//实收流水
    v_sbs       number(10);
    rcount      number(10);
    v_addr      varchar2(60);
    v_mame      varchar2(60);
  
    v_sfdj    number(12, 3);
    v_wsfdj   number(12, 3);
    v_sf      number(12, 2);
    v_wsf     number(12, 2);
    v_ssznj   number(12, 2);
    v_sl      number(10);
    V_DJ      NUMBER(12, 3);
    v_zys     number(12, 2);
    v_sxcount number(10);
    V_RLID    varchar2(10);
    v_jfsx    number(10);
    qfyf2_all number(10);
    v_qfyf    varchar2(8);
  
    v_month   varchar2(400);
    v_xj      varchar2(400);
    v_zkh     varchar2(400);
    v_scode   varchar2(400);
    v_srdate  varchar2(400);
    v_ecode   varchar2(400);
    v_erdate  varchar2(400);
    v_sfdj1   varchar2(400);
    v_sfdj2   varchar2(400);
    v_sfdj3   varchar2(400);
    v_wsdj    varchar2(400);
    v_sl1     varchar2(400);
    v_sl2     varchar2(400);
    v_sl3     varchar2(400);
    v_sf1     varchar2(400);
    v_sf2     varchar2(400);
    v_sf3     varchar2(400);
    v_wsje    varchar2(400);
    v_wyj1    varchar2(400);
    v_zjje    varchar2(400);
    v_code    varchar2(400);
    v_yl1     varchar2(400);
    v_yl2     varchar2(400);
    v_yl3     varchar2(400);
    v_yl4     varchar2(400);
    v_RLECODE varchar2(30);
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    ---- 销账游标
    cursor C_QFYF_LIST IS
      select rlid
        from (SELECT rlid AS rlid
                from PAYMENT PM, reclist rl
               WHERE PM.PPRIID = v_mcode
                    --WHERE PM.PMCODE = v_mcode
                 and rl.rlpid = pm.pid
                 and rl.rlreverseflag = 'N'
                 and rl.rlpaidflag = 'Y'
                 AND PM.PFLAG = 'Y'
                 AND PM.PREVERSEFLAG = 'N'
                 and pm.pbseqno = v_chgno
               GROUP BY rlid);
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
  
    --实收交易响应包循环账务明细
    cursor c_ysmx is
      select *
        from (select 1 vnum,
                     rdpiid,
                     RDPFID,
                     ppriid,
                     rlmonth,
                     rdclass,
                     count(*),
                     substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份20
                   /*  to_char((sum(decode(rdpiid, 01, 0, sum(rddj)))
                              over(partition by RDPFID) *
                              max(decode(rdpiid, '01', rdsl, 0)) +
                              max(decode(rdpiid, '01', rddj, 0)) *
                              max(decode(rdpiid, '01', rdsl, 0))) * 100) xj, --小计21*/
                     to_char(max(decode(rdpiid, '01', rddj, 0)) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100)  + to_char(sum(decode(rdpiid, '01', 0, max(rddj)))
                             over(partition by RDPFID,rlmonth) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) xj,
                     trim(f_getcardno(max(rlmid))) rlbfid, --帐卡号22
                     max(to_char(decode(FGETIFDZSB(rlmid),
                                        'Y',
                                        '-',
                                        decode(RLMSTATUS,
                                               '29',
                                               '-',
                                               '30',
                                               '-',
                                               RLSCODE)))) RLSCODE, --起码23
                     max(TO_CHAR(RLPRDATE, 'YYYYMMDD')) RLPRDATE, --上次抄表日期24
                     max(to_char(decode(FGETIFDZSB(rlmid),
                                        'Y',
                                        '-',
                                        decode(RLMSTATUS,
                                               '29',
                                               '-',
                                               '30',
                                               '-',
                                               RLECODE)))) RLECODE, --止码25
                     max(TO_CHAR(RLRDATE, 'YYYYMMDD')) RLRDATE, --本期抄表日期26
                     to_char(max(decode(rdpiid, '01', rddj, 0)) * 100) USER_DJ1, --水费单价一阶27
                     to_char(0 * 100) USER_DJ2, --水费单价二阶28
                     to_char(0 * 100) USER_DJ3, --水费单价三阶29
                     sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by rlmonth, RDPFID) * 100 dj2,
                     --to_char(max(decode(rdpiid, '02', rddj, 0)) * 100) dj2, --污水单价30
                     to_char(sum(decode(rdpiid, '01', rdsl, 0))) use_r1, --水量一阶31
                     to_char(0) use_r2, --水量二阶32
                     to_char(0) use_r3, --水量三阶33
                     to_char(max(decode(rdpiid, '01', rddj, 0)) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) charge_r1,
                     
                     to_char(0 * 100) charge_r2, --水费二阶35
                     to_char(0 * 100) charge_r3, --水费三阶36
                     to_char(sum(decode(rdpiid, 01, 0, max(rddj)))
                             over(partition by rlmonth, RDPFID) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) charge2, --污水金额37 
                     to_char(0 * 100) chargeznj, --违约金38
                     '0' zjje, --追减金额39
                     max(rlmid) rlmid, --客户代码40
                     decode(rdclass, 0, '-', rdclass || '阶') yl1, --预留1 41
                     '' yl2, --预留1 42
                     '' yl3, --预留1 43
                     '' yl4 --预留1 44
                from reclist rl, recdetail rd, payment pm
               where rl.rlpid = pm.pid
                 and rlid = rdid
                 and pm.preverseflag = 'N'
                 and rl.rlreverseflag = 'N'
                 and rl.rlpaidflag = 'Y'
                 and pm.pbseqno = v_chgno
                 and pm.ppriid = v_mcode
              --and rdpiid = '01'
               group by pm.ppriid, rlmonth, rdpiid, RDPFID, rdclass)
       where rdpiid = '01'
       order by ppriid, rlmonth, rdpiid, RDPFID, rdclass desc;
    /* select 1 vnum,
          rlmonth,
          rdclass,
          count(*),
          substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份20
          to_char((1) * 100) xj, --小计21
          trim(f_getcardno(max(rlmid))) rlbfid, --帐卡号22
          max(to_char(decode(FGETIFDZSB(rlmid),
                             'Y',
                             '-',
                             decode(RLMSTATUS,
                                    '29',
                                    '-',
                                    '30',
                                    '-',
                                    RLSCODE)))) RLSCODE, --起码23
          max(TO_CHAR(RLPRDATE, 'YYYYMMDD')) RLPRDATE, --上次抄表日期24
          max(to_char(decode(FGETIFDZSB(rlmid),
                             'Y',
                             '-',
                             decode(RLMSTATUS,
                                    '29',
                                    '-',
                                    '30',
                                    '-',
                                    RLECODE)))) RLECODE, --止码25
          max(TO_CHAR(RLRDATE, 'YYYYMMDD')) RLRDATE, --本期抄表日期26
          to_char(max(decode(rdpiid, '01', rddj, 0)) * 100) USER_DJ1, --水费单价一阶27
          to_char(0 * 100) USER_DJ2, --水费单价二阶28
          to_char(0 * 100) USER_DJ3, --水费单价三阶29
          to_char(max(decode(rdpiid, '02', rddj, 0)) * 100) dj2, --污水单价30
          to_char(max(decode(rdpiid, '01', rdsl, 0))) use_r1, --水量一阶31
          to_char(0) use_r2, --水量二阶32
          to_char(0) use_r3, --水量三阶33
          to_char(max(decode(rdpiid, '01', rddj, 0)) *
                  max(decode(rdpiid, '01', rdsl, 0)) * 100) charge_r1,
          
          to_char(0 * 100) charge_r2, --水费二阶35
          to_char(0 * 100) charge_r3, --水费三阶36
          to_char(max(decode(rdpiid, '02', rddj, 0)) *
                  max(decode(rdpiid, '01', rdsl, 0)) * 100) charge2, --污水金额37 
          to_char(0 * 100) chargeznj, --违约金38
          '0' zjje, --追减金额39
          max(rlmid) rlmid, --客户代码40
          decode(rdclass, 0, '-', rdclass || '阶') yl1, --预留1 41
          '' yl2, --预留1 42
          '' yl3, --预留1 43
          '' yl4 --预留1 44
     from reclist rl, recdetail rd, payment pm
    where rl.rlpid = pm.pid
      and rlid = rdid
      and pm.preverseflag = 'N'
      and rl.rlreverseflag = 'N'
      and rl.rlpaidflag = 'Y'
      and pm.pbseqno = v_chgno
      and pm.ppriid = v_mcode
    group by pm.ppriid, rlmonth, rdclass
    order by pm.ppriid, rlmonth, rdclass desc;*/
    /* cursor c_ysmx is
    select rank() over(partition by rlprimcode order by rldate desc) vnum,
           substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --年月份20
           to_char((chargetotal + chargeznj) * 100) xj, --小计21
           trim(f_getcardno(rlmid)) rlbfid, --帐卡号22
           to_char(decode(FGETIFDZSB(rlmid),
                          'Y',
                          '-',
                          decode(RLMSTATUS, '29', '-', '30', '-', RLSCODE))) RLSCODE, --起码23
           TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --上次抄表日期24
           to_char(decode(FGETIFDZSB(rlmid),
                          'Y',
                          '-',
                          decode(RLMSTATUS, '29', '-', '30', '-', RLECODE))) RLECODE, --止码25
           TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --本期抄表日期26
           to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --水费单价一阶27
           to_char(USER_DJ2 * 100) USER_DJ2, --水费单价二阶28
           to_char(USER_DJ3 * 100) USER_DJ3, --水费单价三阶29
           to_char(dj2 * 100) dj2, --污水单价30
           to_char(decode(use_r1, 0, wateruse)) use_r1, --水量一阶31
           to_char(use_r2) use_r2, --水量二阶32
           to_char(use_r3) use_r3, --水量三阶33
           to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --水费一阶34
           to_char(charge_r2 * 100) charge_r2, --水费二阶35
           to_char(charge_r3 * 100) charge_r3, --水费三阶36
           to_char(charge2 * 100) charge2, --污水金额37
           to_char(chargeznj * 100) chargeznj, --违约金38
           '0' zjje, --追减金额39
           rlmid, --客户代码40
           '' yl1, --预留1 41
           '' yl2, --预留1 42
           '' yl3, --预留1 43
           '' yl4 --预留1 44
      from reclist rl, view_reclist_charge_02 rd, payment pm
     where rl.rlpid = pm.pid
       and rlid = rdid
       and pm.preverseflag = 'N'
       and rl.rlreverseflag = 'N'
       and rl.rlpaidflag = 'Y'
       and pm.pbseqno = v_chgno
       and pm.ppriid = v_mcode
     order by rldate desc;*/
  
    -----------------------20130923 单缴预存----------------------------
    cursor c_hs_meter IS
      select rank() over(partition by mipriid order by mircode desc) vnum,
             mibfid,
             mirorder,
             miid,
             mircode,
             mirecdate
        from meterinfo mi
       where mipriid = v_mcode
       order by mircode desc;
  
    v_hs_meter c_hs_meter%rowtype;
    ---------------------------------------------------
  
    v_ysmx c_ysmx%rowtype;
    --异常返回定义
    err_format   exception; --数据格式错
    err_charge   exception; --缴费错误
    err_je       exception; --金额不符
    err_nouser   exception; --用户不存在
    err_clockje  exception; --003：记录已锁（如已转非实时方式处理）
    err_other    exception; --
    err_exist    exception;
    rec_overflow exception; --欠费月份超出，应到营业所缴费
    no_user      exception; --无此用户
  
    err_ymsz exception; --月末锁帐
    v_bankid varchar2(10); --银行分支机构
  
    v_b       number(10);
    v_e       number(10);
    v_n       number(10);
    v_count   number(10); --交易包字段数
    v_inlen   number(10); --交易包包长度
    v_seqno   payment.PBSEQNO%type; -- --交易流水
    v_pbseqno number(10); --校验银行流水
    v_hsb1    varchar2(400);
    v_hsb2    varchar2(400);
    v_rdclass recdetail.rdclass%type := 9;
    v_jtjg    varchar2(100);
    v_pspfid  varchar2(100);
    v_rlpfid  varchar2(100);
  begin
    /*--检查是否存在循环
    SELECT to_number(nvl(c2,'0')) into v_b FROM packetsDT WHERE C3='b';
    SELECT to_number(nvl(c2,'0')) into v_e FROM packetsDT WHERE C3='b';*/
    --获取循环次数
    v_jfsx    := 6; --上限
    v_RLECODE := ' ';
    rcount    := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount    := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 13 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 93 then
      raise err_format;
    end if;
  
    --判断是否已月末扎帐
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
    v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    if F_GETBANKSYSPARA(v_bankid) = 'N' then
      raise err_ymsz;
    end if;
    --end if;
  
    --校验银行540交易流水是否已存在
    v_pbseqno := 0;
    v_seqno   := trim(F_GET_HDTEXT(4)); --交易流水
    select count(*) into v_pbseqno from payment where pbseqno = v_seqno;
    if v_pbseqno > 0 then
      raise err_exist;
    end if;
  
    v_mcode := trim(F_GET_HDTEXT(7)); --客户代码
    if length(v_mcode) = 14 then
      v_mcode := substr(v_mcode, 4, 1) || substr(v_mcode, 5, 2) ||
                 substr(v_mcode, 8, 1) || substr(v_mcode, 9, 6);
    end if;
  
    v_paypoint := trim(F_GET_HDTEXT(10)); --银行分支机构
    v_pdate    := trim(F_GET_HDTEXT(11)); --缴费时间
    v_fppc     := trim(F_GET_HDTEXT(12)); --发票代码
    v_fpno     := trim(F_GET_HDTEXT(13)); --发票号
  
    ---取户表的信息：
    select t.* into MI from METERINFO t where t.micode = v_mcode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
  
    --判断是否坐收用户 zhw增加增值税用户不能在银行缴费
    if mi.michargetype = 'M' or
       mi.mistatus in ('7', '19', '28', '31', '32') or mi.MIIFTAX = 'Y' then
      raise no_user;
    end if;
  
    if mi.mipriflag = 'N' then
      v_sbs := 1;
    else
      v_mcode := mi.mipriid;
      select nvl(count(t.micode), 1)
        into v_sbs
        from meterinfo t
       where t.mipriid = v_mcode;
      --重新取合收主表数据
      select t.* into MI from METERINFO t where t.micode = v_mcode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号---------------------
    --统计欠费记录数
    /* select count(rlid)
    into qfyf2_all
    from (SELECT rlid AS rlid
            from reclist rl
           WHERE rlprimcode = v_mcode
                --WHERE rlmcode = v_mcode
             and rl.rlreverseflag = 'N'
             and rl.rlpaidflag = 'N'
             and rl.rlje > 0
             and rl.rlbadflag = 'N'
           GROUP BY rlid);*/
    select count(*)
      into qfyf2_all
      from (SELECT rlmonth, rd.rddj, rd.rdclass
              from reclist rl, recdetail rd
             WHERE rl.rlid = rd.rdid
               and rlprimcode = v_mcode
                  --WHERE rlmcode = v_mcode
               and rl.rlreverseflag = 'N'
               and rl.rlpaidflag = 'N'
               and rl.rlje > 0
               and rl.rlbadflag = 'N'
               and rd.rdpiid = '01'
             GROUP BY rlmonth, rd.rddj, rd.rdclass);
    ----------------------20130922  考虑到一户多表，拿rlprimcode匹配用户号end---------------------
  
    --超出限定条数 不让缴费返回023错误
    if qfyf2_all > v_jfsx then
      null;
      --raise rec_overflow;  --20131212放宽限制，超过6笔也可以缴费
    end if;
  
    v_POSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_OPER     := trim(F_GET_HDTEXT(9));
    v_chgno    := F_GET_HDTEXT(8);
    v_PAYJE    := to_number(F_GET_HDTEXT(8)) / 100; --缴费金额
    v_chgno    := trim(F_GET_HDTEXT(4)); --交易流水
    v_ptrans   := 'B';
  
    v_retstr := f_bank_chg_total(v_POSITION,
                                 v_OPER,
                                 v_mcode,
                                 v_PAYJE,
                                 v_ptrans,
                                 v_chgno,
                                 v_fppc,
                                 v_fpno,
                                 v_pid,
                                 v_discharge,
                                 v_curr_sav);
  
    if v_retstr = '001' then
      --用户不存在
      raise err_nouser;
    elsif v_retstr = '003' then
      --锁帐
      raise err_clockje;
    elsif v_retstr = '005' then
      --金额不符
      raise err_je;
    elsif v_retstr = '021' then
      raise err_other;
    end if;
  
    rcount := F_SET_TEXT(3, to_char(v_PAYJE * 100)); --本次缴费金额
    rcount := F_SET_TEXT(4, to_char(v_sbs)); --用户表数
    rcount := F_SET_TEXT(5, MI.micode); --客户代码
    v_mame := substr(MI.MINAME, 1, 60);
    rcount := F_SET_TEXT(6, v_mame); --户名
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(7, v_addr); --户地址
    rcount := F_SET_TEXT(8, v_chgno); --凭证流水
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    --有欠费，实收交易
    if qfyf2_all > 0 then
      ----取费用信息：
      select sum(decode(rd.rdpiid, 01, rd.rdsl, 0)) sl,
             sum(decode(rd.rdpiid, 01, rd.rdje, 0)) sfje,
             sum(decode(rd.rdpiid, 02, rd.rdje, 0)) wsfje,
             max(pm.pznj) znj,
             sum(rdje) ysje
        into v_sl, v_sf, v_wsf, v_ssznj, v_zys
        from reclist rl, recdetail rd, payment pm
       where rl.rlpid = pm.pid
         and rlid = rdid
         and pm.preverseflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'Y'
         and pm.pbseqno = v_chgno
         and pm.ppriid = v_mcode;
      --and pm.pmcode = v_mcode;
      ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
    
      --------20130912 如果是实收交易，此字段为应收水量；如果是预存交易，此字段为当前表示数----------
      rcount := F_SET_TEXT(9, to_char(v_sl)); --应收水量
      --------------------------end ----------------------------------------------------
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --如果是一户一表或者一户多表水价相同
        --取水费单价和污水费单价
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
/*        select max(rddj), max(rd.rdclass)
          into v_sfdj, v_rdclass
          from reclist rl, recdetail rd
         where rl.rlid = rd.rdid
           and rlmonth =
               (select max(RLSCRRLMONTH)
                  from reclist
                 where rlreverseflag = 'N'
                   and rlmid in
                       (select miid from meterinfo where mipriid = v_mcode)AND RLSL>0)
           and rlmid in
               (select miid from meterinfo where mipriid = v_mcode)
           and rdpiid = '01'
           and RDPSCID = 0
           and rl.rlreverseflag = 'N'
           and rl.rlsl>0;*/
         select count(*)
           into v_count
           from reclist
          where rlreverseflag = 'N'
            and rlmid in
                (select miid from meterinfo where mipriid = v_mcode)
            and RLSL > 0;
         
         if v_count > 0 then   
           select rlpfid 
             into v_rlpfid
             from reclist
            where rlid =
                  (select max(rlid)
                     from reclist
                    where rlreverseflag = 'N'
                      and rlmid in
                          (select miid from meterinfo where mipriid = v_mcode) and rlsl>0 ) ;
         end if;   
         if v_count > 0 and mi.mipfid = v_rlpfid then
         /*   select max(rddj), max(rd.rdclass)
              into v_sfdj, v_rdclass
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rlid =
                   (select max(rlid)
                      from reclist
                     where rlreverseflag = 'N'
                       and rlmid in
                           (select miid from meterinfo where mipriid = v_mcode)and rlsl>0)                
               and rdpiid = '01'
               and RDPSCID = 0;*/
               select 
               fun_getjtdqdj(v_rlpfid,v_mcode,v_mcode,'1') ,
               fun_getjtdqdj(v_rlpfid,v_mcode,v_mcode,'4') 
               into v_sfdj, v_rdclass
               from dual;
         else
              begin 
                  select max(pspfid) into v_pspfid from pricestep where  pspfid = mi.mipfid;
                  v_rdclass :=1;
              exception 
                  when no_data_found then 
                   v_rdclass := 0;   
              end;      
         end if;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --水费单价
        rcount := F_SET_TEXT(11, to_char(v_sf * 100)); --水费合计
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --污水费单价
        rcount := F_SET_TEXT(13, to_char(v_wsf * 100)); --污水费合计
      
      else
        --如果一户多表水价不同
        rcount := F_SET_TEXT(10, '-'); --水费单价
        rcount := F_SET_TEXT(11, '-'); --水费合计
        rcount := F_SET_TEXT(12, '-'); --污水费单价
        rcount := F_SET_TEXT(13, '-'); --污水费合计
      end if;
    
      rcount := F_SET_TEXT(14, to_char(v_ssznj * 100)); --违约金
      rcount := F_SET_TEXT(15, to_char(v_zys * 100)); --应收合计
    
    else
      --预存缴费
      rcount := F_SET_TEXT(9, to_char(MI.MIRCODE)); --本期表示数
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --如果是一户一表或者一户多表水价相同
        --取水费单价和污水费单价
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
/*        select max(rddj), max(rd.rdclass)
          into v_sfdj, v_rdclass
          from reclist rl, recdetail rd
         where rl.rlid = rd.rdid
           and rlmonth =
               (select max(RLSCRRLMONTH)
                  from reclist
                 where rlreverseflag = 'N'
                   and rlmid in
                       (select miid from meterinfo where mipriid = v_mcode)AND RLSL>0)
           and rlmid in
               (select miid from meterinfo where mipriid = v_mcode)
           and rdpiid = '01'
           and RDPSCID = 0
           and rl.rlreverseflag = 'N'
           and rl.rlsl>0;*/
         select count(*)
           into v_count
           from reclist
          where rlreverseflag = 'N'
            and rlmid in
                (select miid from meterinfo where mipriid = v_mcode)
            and RLSL > 0;
         
         if v_count > 0 then   
           select rlpfid 
             into v_rlpfid
             from reclist
            where rlid =
                  (select max(rlid)
                     from reclist
                    where rlreverseflag = 'N'
                      and rlmid in
                          (select miid from meterinfo where mipriid = v_mcode) and rlsl>0 ) ;
         end if;   
         if v_count > 0 and mi.mipfid = v_rlpfid then
           /* select max(rddj), max(rd.rdclass)
              into v_sfdj, v_rdclass
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rlid =
                   (select max(rlid)
                      from reclist
                     where rlreverseflag = 'N'
                       and rlmid in
                           (select miid from meterinfo where mipriid = v_mcode)and rlsl>0)                
               and rdpiid = '01'
               and RDPSCID = 0;*/
               select 
               fun_getjtdqdj(v_rlpfid,v_mcode,v_mcode,'1') ,
               fun_getjtdqdj(v_rlpfid,v_mcode,v_mcode,'4') 
               into v_sfdj, v_rdclass
               from dual;
         else
              begin 
                  select max(pspfid) into v_pspfid from pricestep where  pspfid = mi.mipfid;
                  v_rdclass :=1;
              exception 
                  when no_data_found then 
                   v_rdclass := 0;   
              end;      
         end if;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --水费单价
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --污水费单价
      else
        --如果一户多表水价不同
        rcount := F_SET_TEXT(10, '-'); --水费单价
        rcount := F_SET_TEXT(12, '-'); --污水费单价
      end if;
      rcount := F_SET_TEXT(11, '0'); --水费合计
      rcount := F_SET_TEXT(13, '0'); --污水费合计
      rcount := F_SET_TEXT(14, '0'); --违约金
      rcount := F_SET_TEXT(15, '0'); --应收合计
    
    end if;
  
    rcount := F_SET_TEXT(16, to_char(mi.misaving * 100)); --期初预存
    rcount := F_SET_TEXT(17, to_char(v_curr_sav * 100)); --期末预存
  
    -------------------------20130912修改一户一表为：“预计表示数”；一户多表为：“预计可用水量”---------------------
    if v_sbs = 1 then
      --如果是一户一表
      rcount := F_SET_TEXT(18,
                           to_char(MI.MIRCODE +
                                   floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---预计表示数
    elsif v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y' then
      --如果一户多表水价相同
      rcount := F_SET_TEXT(18,
                           to_char(floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---预计可用水量
    else
      --如果一户多表水价不同
      rcount := F_SET_TEXT(18, '-');
    end if;
    -----------------------------------------------------end-----------------------------------------------------------------
  
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号---------------------
    --统计本次销账记录数
    /* select count(rlid)
    into qfyf2_all
    from (SELECT rlid AS rlid
            from PAYMENT PM, reclist rl
           WHERE PM.PPRIID = v_mcode
                --WHERE PM.PMCODE = v_mcode
             and rl.rlpid = pm.pid
             and rl.rlreverseflag = 'N'
             and rl.rlpaidflag = 'Y'
             AND PM.PFLAG = 'Y'
             AND PM.PREVERSEFLAG = 'N'
             and pm.pbseqno = v_chgno
           GROUP BY rlid);*/
    ----------------------20130922  考虑到一户多表，拿PPRIID匹配用户号end---------------------
    /*  rcount := F_SET_TEXT(19, '-'); --记录数
    rcount := F_SET_TEXT(20, '-'); --记录数*/
  
    --实收交易
  
    v_hsb1 := '';
    v_hsb2 := '';
    v_n    := 0;
    --哈尔滨需求  20-44循环取值
    if v_sbs > 1 then
      open c_hs_meter;
      loop
        fetch c_hs_meter
          into v_hs_meter;
        exit when v_hs_meter.vnum > v_jfsx or c_hs_meter%notfound or c_hs_meter%notfound is null;
        if v_n < 3 then
          v_hsb1 := v_hsb1 || v_hs_meter.miid || ':' || v_hs_meter.mircode || ' ';
        end if;
        if v_n >= 3 and v_n < 6 then
          v_hsb2 := v_hsb2 || v_hs_meter.miid || ':' || v_hs_meter.mircode || ' ';
        end if;
        v_n := v_n + 1;
      end loop;
      if v_n > 3 then
        rcount := F_SET_TEXT(19, v_hsb1);
        rcount := F_SET_TEXT(20, v_hsb2);
      else
        rcount := F_SET_TEXT(19, v_hsb1);
        rcount := F_SET_TEXT(20, ' ');
      end if;
    else
      rcount := F_SET_TEXT(19, ' '); --记录数
      rcount := F_SET_TEXT(20, ' '); --记录数
    end if;
    if v_rdclass = 0 then
      v_jtjg := v_sfdj || '元';
    elsif v_rdclass = 1 then
      v_jtjg := '(1阶)' || v_sfdj || '元';
    elsif v_rdclass = 2 then
      v_jtjg := '(2阶)' || v_sfdj || '元';
    elsif v_rdclass = 3 then
      v_jtjg := '(3阶)' || v_sfdj || '元';
    else
      v_jtjg := '-';
    end if;
    rcount := F_SET_TEXT(21, v_jtjg); --记录数
    rcount := F_SET_TEXT(22, v_pid); --20180802 修改为实收流水，用作银行打印发票提取码
    rcount := F_SET_TEXT(23, '0'); --记录数
    if qfyf2_all > 0 then
      --实收交易笔数依据返回的明细条数计算
      --判断如果实际笔数大于限制条数，则记录数取限制条数
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(23, v_jfsx); --记录数
      else
        rcount := F_SET_TEXT(23, to_char(qfyf2_all)); --记录数
      end if;
    
      --根据记录数扩充packetsDT数据
      if qfyf2_all <= v_jfsx then
        sp_extensiondata(qfyf2_all);
      else
        --如果缴费记录超出，则只返回最近的6笔明细
        sp_extensiondata(v_jfsx);
      end if;
      v_n := 0;
      --哈尔滨需求  20-44循环取值
      open c_ysmx;
      loop
        fetch c_ysmx
          into v_ysmx;
        exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
        rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.month)); --年月份
        rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.xj)); --小计
        rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.rlbfid)); --帐卡号
        rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --起码
        rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --上次抄表日期
        if v_RLECODE = v_ysmx.RLECODE then
          rcount := F_SET_TEXT(29 + (v_n * 25), ' '); --止码
        else
          v_RLECODE := v_ysmx.RLECODE;
          rcount    := F_SET_TEXT(29 + (v_n * 25), v_ysmx.RLECODE); --止码
        end if;
      
        rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --本次抄表日期
        rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --水费单价（一阶）
        rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --水费单价（二阶）
        rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --水费单价（三阶）
        rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.dj2)); --污水处理费单价
        rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.use_r1)); --水量（一阶）
        rcount := F_SET_TEXT(36 + (v_n * 25), to_char(v_ysmx.use_r2)); --水量（二阶）
        rcount := F_SET_TEXT(37 + (v_n * 25), to_char(v_ysmx.use_r3)); --水量（三阶）
        rcount := F_SET_TEXT(38 + (v_n * 25), to_char(v_ysmx.charge_r1)); --水费（一阶）
        rcount := F_SET_TEXT(39 + (v_n * 25), to_char(v_ysmx.charge_r2)); --水费（二阶）
        rcount := F_SET_TEXT(40 + (v_n * 25), to_char(v_ysmx.charge_r3)); --水费（三阶）
        rcount := F_SET_TEXT(41 + (v_n * 25), to_char(v_ysmx.charge2)); --污水处理费
        rcount := F_SET_TEXT(42 + (v_n * 25), to_char(v_ysmx.chargeznj)); --违约金
        rcount := F_SET_TEXT(43 + (v_n * 25), to_char(v_ysmx.zjje)); --追减费
        rcount := F_SET_TEXT(44 + (v_n * 25), to_char(v_ysmx.rlmid)); --客户代码
        rcount := F_SET_TEXT(45 + (v_n * 25), to_char(v_ysmx.yl1)); --预留
        rcount := F_SET_TEXT(46 + (v_n * 25), to_char(v_ysmx.yl2)); --预留
        rcount := F_SET_TEXT(47 + (v_n * 25), to_char(v_ysmx.yl3)); --预留
        rcount := F_SET_TEXT(48 + (v_n * 25), to_char(v_ysmx.yl4)); --预留
        v_n    := v_n + 1;
      end loop;
      close c_ysmx;
    
      /*  else
      --单缴预存交易笔数依据返回的明细条数计算
      --判断如果用户数大于限制条数，则记录数取限制条数
      \*if v_sbs > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --记录数
      elsif v_sbs>1  then --一户多表打指针明细
        rcount := F_SET_TEXT(19, to_char(v_sbs)); --记录数
      else--一户一表不打指针明细
        rcount := F_SET_TEXT(19, '0'); --记录数
      end if;*\
      
      --根据记录数扩充packetsDT数据
      if v_sbs <= v_jfsx then
        sp_extensiondata(v_sbs);
      else
        --如果缴费记录超出，则只返回最近的6笔明细
        sp_extensiondata(v_jfsx);
      end if;
      
      v_n := 0;*/
    
    end if;
  
  exception
  
    when err_format then
    
      rcount := F_SET_TEXT(2, '020');
    when no_user then
    
      rcount := F_SET_TEXT(2, '001');
    when err_nouser then
    
      rcount := F_SET_TEXT(2, '001');
    when err_clockje then
    
      rcount := F_SET_TEXT(2, '003'); --记录已锁（如已转非实时方式处理）
    when err_je then
    
      rcount := F_SET_TEXT(2, '005');
    when err_other then
    
      rcount := F_SET_TEXT(2, '021');
    when rec_overflow then
    
      rcount := F_SET_TEXT(2, '023');
    when err_ymsz then
    
      rcount := F_SET_TEXT(2, '022'); --月末锁帐
    when err_exist then
      --交易流水
    
      rcount := F_SET_TEXT(2, '025');
    when others then
    
      rcount := F_SET_TEXT(2, '024'); --其它
  end;
  /*----------------------------------------------------------------------
  Note: 580缴费结果查询交易
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f580(p_in in arr, p_out in out arr) as
  
    v_transno   varchar(20); --银行缴费流水
    v_PPOSITION PAYMENT.PPOSITION %TYPE; --银行
  
    rcount number(10);
    --异常返回定义
    err_format exception; --数据格式错
    err_charge exception; --缴费错误
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
  
  begin
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_count from packetshd;
    if v_count <> 7 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 23 then
      raise err_format;
    end if;
  
    v_PPOSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_transno   := trim(F_GET_HDTEXT(7)); --银行流水号
    --查询单缴垃圾费情况(单缴垃圾费时仍然生成payment为0的一笔实缴记录)
    select count(*)
      INTO RCOUNT
      from payment t
     where t.pbseqno = v_transno
       and t.PFLAG = 'Y'
       AND T.PREVERSEFLAG = 'N'
       and t.pposition = v_PPOSITION
       and t.pdatetime >= trunc(sysdate)
       and t.pdatetime < trunc(sysdate) + 1;
    IF RCOUNT = 0 THEN
      RAISE err_charge;
    END IF;
  
  EXCEPTION
    WHEN err_format THEN
      rcount := F_SET_TEXT(2, '020');
    WHEN ERR_CHARGE THEN
      rcount := F_SET_TEXT(2, '006');
    WHEN OTHERS THEN
      rcount := F_SET_TEXT(2, '022');
  end f580;

  /*----------------------------------------------------------------------
  Note: 550缴费取消交易
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/

  procedure f550(p_in in arr, p_out in out arr) as
  
    v_transno   varchar(20); --银行缴费流水
    v_meterno   varchar2(30); --水表资料号
    v_PPOSITION PAYMENT.PPOSITION %TYPE; --银行
    rcount      number(10);
    v_paycount    number(10);
    v_retstr    varchar2(20);
    v_pdate     varchar2(8);
    v_date      date;
    --异常返回定义
    err_format exception; --数据格式错
    err_charge exception; --缴费错误
    err_nodate exception; --缴费错误
    err_other exception; --缴费错误
    no_user exception; --无此用户
    
    err_ymsz exception; --月末锁帐
    v_bankid  varchar2(10);  --银行分支机构
    
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
    v_seqno     payment.PBSEQNO%type; -- --交易流水
    v_pbseqno      number(10);--校验银行流水
        mi          meterinfo%rowtype;

  begin
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    if p_in.count <> 9 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 45 then
      raise err_format;
    end if;
    
     --判断是否已月末扎帐
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
      v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
      if F_GETBANKSYSPARA(v_bankid)='N' then
         raise err_ymsz;
      end if;
    --end if;

    v_PPOSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1))); --
    v_transno   := trim(F_GET_HDTEXT(7)); --银行流水号
    v_meterno   := trim(F_GET_HDTEXT(8)); --用户ID号
    
   if length(v_meterno) = 14 then
      v_meterno := substr(v_meterno, 4, 1) || substr(v_meterno, 5, 2) ||
                 substr(v_meterno, 8, 1) || substr(v_meterno, 9, 6);
    end if;
    
    ---取户表的信息：
    select t.* into MI from METERINFO t where t.micode = v_meterno;
    --判断是否坐收用户
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
    
    if mi.mipriflag = 'Y' then
      v_meterno := mi.mipriid;
    end if;
    
   --银行只允许冲正自家当天交的记录
   select count(*)
     into v_paycount
     from payment
    where pbseqno = v_transno
      and pposition = v_PPOSITION
      and pdate = trunc(sysdate);
   if v_paycount <= 0 then
     raise err_other;
   end if;
    
    v_pdate     := trim(F_GET_HDTEXT(9)); --账务日期
  
    if v_pdate is null or v_pdate = '00000000' then
      v_pdate := to_char(trunc(sysdate), 'YYYYMMDD');
    end if;
  
    v_date   := to_date(v_pdate, 'yyyymmdd');
    v_retstr := f_bank_dischargeone(v_PPOSITION,
                                    v_transno,
                                    v_meterno,
                                    v_date);
  
    if v_retstr = '000' then
      null;
    elsif v_retstr = '006' then
      raise err_nodate;
    elsif v_retstr = '021' then
      --数据库操作错
      raise err_charge;
    elsif v_retstr = '022' then
      --其他错误
      raise err_other;
    else
      raise err_other;
    end if;
    --COMMIT;
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_user then
      rcount := F_SET_TEXT(2, '001');
    when err_charge then
      rcount := F_SET_TEXT(2, '021');
    when err_nodate then
      rcount := F_SET_TEXT(2, '006');
    when err_other then
      rcount := F_SET_TEXT(2, '022');
    when err_ymsz then
      rcount := F_SET_TEXT(2, '022');--月末锁帐
    when others then
      rcount := F_SET_TEXT(2, '022');
  end f550;

  /*----------------------------------------------------------------------
  Note: 510 对账交易处理
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f510(p_in in arr, p_out in out arr) as
  
    v_zbs     number(10); --总笔数
    v_zje     number(10, 2); --总金额
    v_chkdate date; --对帐日期
    v_sysdate date;--系统日期
    rcount    number(10);
    v_count   number(10);
  
    p_bankid varchar2(20);
    p_bankno varchar2(20);
    v_jp     varchar2(1000);
    v_jtm    varchar2(50);
    v_time   varchar2(20);
    v_path   varchar2(200);
    --异常返回定义
    err_format exception; --数据格式错
    err_charge exception; --缴费错误
    err_date exception; --时间错误
    err_zz exception; --未扎帐错误
    err_dzword exception; --未发送对账文件(或未同步)错误
    err_dzok exception; --已对账错误
    v_incount number(10); --交易包字段数
    v_inlen   number(10); --交易包包长度
  begin
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果
  
    select count(*) into v_incount from packetshd;
    if v_incount <> 9 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 31 then
      raise err_format;
    end if;
    
    --根据银行代码获取银行分支机构
    p_bankid  := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    --获取银行代码
    p_bankno  := trim(F_GET_HDTEXT(1));
    --取系统时间
    --v_time    := to_char(sysdate, 'hh24:mi:ss');
    v_time    := to_char(trunc(sysdate,'mi')+5/(24*60), 'hh24:mi:ss') ;--5分钟后再执行job对账
    --取银行发送的对账时间
    v_chkdate := to_date(F_GET_HDTEXT(9), 'yyyymmdd');
     --取系统当前时间
     v_sysdate  := trunc(sysdate);
    
    --20140401 修改为允许隔日补发对账请求
     --判断扎帐时间是否等于系统时间
/*    if v_chkdate<>v_sysdate then
      raise err_date;
    end if;*/
    
    --判断当日是否扎帐
    select count(*)
      into v_count
      from mi_bankzz
     where bankid = p_bankid
       and zzdate = v_chkdate;
    if v_count <= 0 then
      --当天未扎账务
      raise err_zz;
    end if;
    
    --未发送对账文件(或未同步)错误
    SELECT max(SMPPVALUE)
      into v_path
      FROM SYSMANAPARA
     WHERE SMPID = p_bankid
       AND SMPPID = 'FTPDZDIR';
    SELECT COUNT(*)
      INTO V_COUNT
      FROM ENTRUSTFILE
     WHERE to_date(substr(effilename, (f_getptype(effilename, '.') - 7), 8),
                   'YYYYMMDD') = trunc(v_chkdate)
       AND EFPATH = v_path;
    IF V_COUNT <= 0 THEN
      null;
      --raise err_dzword;  --暂时不校验文件
    END IF;
    
    
    --已对账
    select COUNT(*)
      INTO V_COUNT
      from bankchklog_new
     where bankcode = p_bankid
       and to_date(substr(chkfile, (f_getptype(chkfile, '.') - 7), 8),
                   'YYYYMMDD') = trunc(v_chkdate)
       and okflag = 'Y';
    IF V_COUNT > 0 THEN
      raise err_dzok;
    END IF;
  
   --动态job执行同步操作
    v_jp  := 'sp_auto_bankdz(''' || F_GET_HDTEXT(9) || ''',''' || p_bankid ||
             ''');';
    v_jtm := F_GET_HDTEXT(9) || v_time;
    job_submit(v_jp, v_jtm);
    
    
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when err_date then
      rcount := F_SET_TEXT(2, '008');
    when err_zz then
      rcount := F_SET_TEXT(2, '024');
    when err_dzword then
      rcount := F_SET_TEXT(2, '025');
    when err_dzok then
      rcount := F_SET_TEXT(2, '026');
    when others then
      rcount := F_SET_TEXT(2, '021');
  end f510;

  /*----------------------------------------------------------------------
  Note: 511扎帐交易处理
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f511(p_in in arr, p_out in out arr) as
  
    v_chkdate date; --对帐日期
    v_sysdate date;--系统日期
    rcount    number(10);
    vsum      number(10);
  
    p_bankid varchar2(20);
    MB       mi_bankzz%ROWTYPE; --对账批次变量
    --异常返回定义
    err_format exception; --数据格式错
    err_date exception; --时间错误
    err_repeat exception; --交易重复
  
    v_count number(10); --交易包字段数
    v_inlen number(10); --交易包包长度
  
  begin
   --根据银行代码获取银行分支机构
    p_bankid  := FBCODE2SMFID(F_GET_HDTEXT(1));
    --获取银行发送的扎帐日期
    v_chkdate := to_date(F_GET_HDTEXT(7), 'yyyymmdd');
    --取系统当前时间
    v_sysdate  := trunc(sysdate);
    
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
    rcount := F_SET_TEXT(2, '000'); --返回结果

    select count(*) into v_count from packetshd;
    if v_count <> 7 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --交易包长度
    if v_inlen <> 11 then
      raise err_format;
    end if;
    
    --判断扎帐时间是否等于系统时间
    if v_chkdate<>v_sysdate then
      raise err_date;
    end if;
  
   ---判断当天是否扎帐
    MB        := NULL;
    BEGIN
      select *
        into MB
        from mi_bankzz zz
       where zz.bankid = p_bankid
         and zz.zzdate = v_chkdate;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    if MB.DZNO IS NULL then
      --如果当日未扎帐则插入扎帐记录
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --对账编号 
        FROM DUAL;
      MB.BANKID := p_bankid;--银行编码 
      MB.ZZDATE := v_chkdate;--扎帐日期 
      MB.CZDATE := sysdate;--操作时间 
      MB.ZZFROM := 'B';--银行自扎
      insert into mi_bankzz values MB;
      
      --只有第一次扎帐更新实收记录
       update payment
       set PCHKDATE = MB.ZZDATE, --对账日期
           PCHKNO   = MB.DZNO --进账单号
     WHERE PPOSITION = MB.BANKID
       AND PDATETIME <= MB.CZDATE
       AND PDATE >= TO_DATE('2014-04-17','YYYY-MM-DD')
       AND PCHKNO IS NULL;

    else
      --如果当日已成功扎帐，则更新操作时间
      MB.CZDATE := sysdate;
      update mi_bankzz
         set CZDATE = MB.CZDATE
       where bankid = p_bankid
         and zzdate = v_chkdate
         AND DZNO = trim(MB.DZNO);
      --raise err_repeat;--允许重复扎帐
    end if;
    
    --月末扎帐锁帐
   if trunc(sysdate)=trunc(last_day(sysdate)) then
      P_SETBANKSYSPARA(p_bankid,'N','N');
   end if;

  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when err_repeat then
      rcount := F_SET_TEXT(2, '007');
    when err_date then
      rcount := F_SET_TEXT(2, '008');
    when others then
      rcount := F_SET_TEXT(2, '021');
  end f511;

  /*----------------------------------------------------------------------
  Note: 110 签订代扣关系（不检验水表户名）交易
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f110(p_in in arr, p_out in out arr) as
    v_ma_Info meteraccount%rowtype;
  
    v_meterinfo meterinfo%rowtype;
  
    rcount number(10);
  
    ERR_TS_DK EXCEPTION;
  
    msl meter_static_log%rowtype;
    CURSOR C_METERLOG(vmid in varchar2) is
      select micode,
             ciname,
             miadr,
             '代扣签约',
             Bfsafid,
             mismfid,
             mirtid,
             mdcaliber,
             mistid,
             mitype,
             miifchk,
             michargetype,
             milb,
             fpriceframejcbm(mipfid, 1),
             fpriceframejcbm(mipfid, 2),
             mipfid,
             miside,
             mibfid,
             trunc(minewdate)
        from custinfo, meterinfo
        left join bookframe
          on (bfsmfid = mismfid and bfid = mibfid), meterdoc
       where ciid = micid
         and miid = mdmid
         and miid = vmid;
  
  begin
  
    v_ma_Info.MABANKID      := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --水表资料号
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8); --
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10); --
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --交易码
  
    --匹配水表资料好
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
    v_meterinfo.miname := nvl(v_meterinfo.miname, '未名');
    v_ma_Info.Mamid    := v_meterinfo.miid; --主键id
  
    --如果是托收户，则返回错误
    v_meterinfo.MICHARGETYPE := NVL(v_meterinfo.MICHARGETYPE, 'N');
    if v_meterinfo.MICHARGETYPE = 'T' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    --更新代扣资料
    delete meteraccount t where t.mamid = v_ma_Info.Mamid;
    insert into meteraccount t values v_ma_Info;
  
    update meterinfo t
       set t.MICHARGETYPE = 'D'
     WHERE t.MICODE = v_meterinfo.micode;
    --记录日志
    --sp_dk_log(p_in);
    entrust_sign_log(v_ma_Info.Mamicode,
                     v_meterinfo.miname,
                     v_ma_Info.MABANKID,
                     v_ma_Info.MAACCOUNTNO,
                     v_ma_Info.Maaccountname,
                     v_meterinfo.MICHARGETYPE,
                     'U',
                     'Y');
    rcount := F_SET_TEXT(2, '000'); --返回结果
    rcount := F_SET_TEXT(3, '签约成功'); --返回说明
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '查不到用户的数据，可能不存在该用户');
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '托收用户不能签约');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-077',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'U',
                       'N');
    when others then
      INFOMSG('ERR.CODE:' || TO_CHAR(SQLCODE));
      INFOMSG('ERR.MSG:' || SQLERRM);
      rcount := F_SET_TEXT(2, '003');
      rcount := F_SET_TEXT(3, '可能数据异常，造成系统无法处理');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      rollback;
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-03',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'U',
                       'N');
    
  end f110;

  /*----------------------------------------------------------------------
  Note: 111 签订代扣关系（不检验水表户名）交易
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f111(p_in in arr, p_out in out arr) as
    v_ma_Info meteraccount%rowtype;
  
    v_meterinfo meterinfo%rowtype;
    ci          custinfo%rowtype;
  
    rcount number(10);
  
    ERR_TS_DK EXCEPTION;
    dif_name EXCEPTION;
    msl meter_static_log%rowtype;
  
  begin
  
    v_ma_Info.MABANKID      := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --水表资料号
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8);
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10);
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := F_SET_TEXT(1, trim(F_GET_HDTEXT(6))); --交易码
  
    --匹配水表资料好
    begin
      select t.*
        into v_meterinfo
        from meterinfo t
       where t.MICODE = v_ma_Info.Mamicode;
    exception
      when others then
        raise no_data_found;
    end;
    begin
      select * into ci from custinfo where ciid = v_meterinfo.micid;
    exception
      when others then
        raise no_data_found;
    end;
    if trim(ci.ciname) <> trim(F_GET_HDTEXT(9)) then
      raise dif_name;
    end if;
    v_meterinfo.miname := nvl(v_meterinfo.miname, '未名');
    v_ma_Info.Mamid    := v_meterinfo.miid; --主键id
  
    --如果是托收户，则返回错误
    v_meterinfo.MICHARGETYPE := NVL(v_meterinfo.MICHARGETYPE, 'N');
    if v_meterinfo.MICHARGETYPE = 'T' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    --更新代扣资料
    delete meteraccount t where t.mamid = v_ma_Info.Mamid;
    insert into meteraccount t values v_ma_Info;
  
    update meterinfo t
       set t.MICHARGETYPE = 'D'
     WHERE t.MICODE = v_meterinfo.micode;
    --记录日志
    --sp_dk_log(p_in);
    entrust_sign_log(v_ma_Info.Mamicode,
                     v_meterinfo.miname,
                     v_ma_Info.MABANKID,
                     v_ma_Info.MAACCOUNTNO,
                     v_ma_Info.Maaccountname,
                     v_meterinfo.MICHARGETYPE,
                     'U',
                     'Y');
  
    rcount := F_SET_TEXT(2, '000'); --返回码
    rcount := F_SET_TEXT(3, '签约成功'); --返回说明
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
  
    /*if v_meterinfo.miname <> trim(p_in(7)) THEN
      p_out(5) := '水表户名不符签约成功';
    END IF;*/
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '查不到用户的数据，可能不存在该用户');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '托收用户不能签约');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-077',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'U',
                       'N');
    when dif_name then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '用户提供水表用户名与自来水用户名不一致');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-077',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'U',
                       'N');
    
    when others then
      INFOMSG('ERR.CODE:' || TO_CHAR(SQLCODE));
      INFOMSG('ERR.MSG:' || SQLERRM);
      rcount := F_SET_TEXT(2, '003');
      rcount := F_SET_TEXT(3, '可能数据异常，造成系统无法处理');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      rollback;
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-03',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'U',
                       'N');
    
  end f111;
  /*----------------------------------------------------------------------
  Note: 120 解除代扣关系
  Input: p_bankid -- 银行编码
         p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/
  procedure f120(p_in in arr, p_out in out arr) as
    v_ma_Info meteraccount%rowtype;
  
    v_meterinfo meterinfo%rowtype;
  
    p_bankid varchar2(20);
    rcount   number(10);
  
    ERR_TS_DK EXCEPTION;
  
    ERR_BANK EXCEPTION;
    ERR_ACCOUNT EXCEPTION;
  
    msl meter_static_log%rowtype;
    CURSOR C_METERLOG(vmid in varchar2) is
      select micode,
             ciname,
             miadr,
             '代扣解约',
             Bfsafid,
             mismfid,
             mirtid,
             mdcaliber,
             mistid,
             mitype,
             miifchk,
             michargetype,
             milb,
             fpriceframejcbm(mipfid, 1),
             fpriceframejcbm(mipfid, 2),
             mipfid,
             miside,
             mibfid,
             trunc(minewdate)
        from custinfo, meterinfo
        left join bookframe
          on (bfsmfid = mismfid and bfid = mibfid), meterdoc
       where ciid = micid
         and miid = mdmid
         and miid = vmid;
  begin
    v_ma_Info.MABANKID      := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --水表资料号
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8);
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10);
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := f_set_item(p_out, trim(F_GET_HDTEXT(6))); --交易码
  
    --匹配水表资料好
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
  
    --如果不是代扣户，则返回错误
    if v_meterinfo.MICHARGETYPE <> 'D' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    select T.*
      INTO v_ma_Info
      FROM meteraccount T
     WHERE T.MAMICODE = v_meterinfo.micode;
    --银行不符
    IF v_ma_Info.Mabankid <> p_bankid THEN
      RAISE ERR_BANK;
    END IF;
  
    IF v_ma_Info.Maaccountno <> F_GET_HDTEXT(8) OR
       v_ma_Info.Maaccountname <> F_GET_HDTEXT(10) THEN
      RAISE ERR_ACCOUNT;
    END IF;
  
    --解除代扣关系
    update meterinfo t
       set t.MICHARGETYPE = 'X'
     WHERE t.MICODE = v_meterinfo.micode;
  
    --delete meteraccount t where t.mamid = v_ma_Info.Mamid;
  
    --记录日志
    --sp_dk_log(p_in);
    entrust_sign_log(v_ma_Info.Mamicode,
                     v_meterinfo.miname,
                     v_ma_Info.MABANKID,
                     v_ma_Info.MAACCOUNTNO,
                     v_ma_Info.Maaccountname,
                     v_meterinfo.MICHARGETYPE,
                     'O',
                     'Y');
    --------------------------------------------------------
  
    rcount := F_SET_TEXT(2, '000'); --返回码
    rcount := F_SET_TEXT(3, '解约成功'); --返回说明
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '查不到用户的数据，可能不存在该用户');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '非代扣户无法解约');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-077',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'O',
                       'N');
    when ERR_BANK then
      rcount := F_SET_TEXT(2, '005');
      rcount := F_SET_TEXT(3, '鉴权错误');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-005',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'O',
                       'N');
    when ERR_ACCOUNT then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '账号或账户名不一致');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-077',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'O',
                       'N');
    when others then
      rcount := F_SET_TEXT(2, '003');
      rcount := F_SET_TEXT(3, '可能数据异常，造成系统无法处理');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
    
      rollback;
      entrust_sign_log(v_ma_Info.Mamicode,
                       v_meterinfo.miname,
                       v_ma_Info.MABANKID,
                       v_ma_Info.MAACCOUNTNO || '-003',
                       v_ma_Info.Maaccountname,
                       v_meterinfo.MICHARGETYPE,
                       'O',
                       'N');
  end f120;

  /*----------------------------------------------------------------------
  Note: 130 查询用户签约状态
  Input: p_in  -- 请求包
  Output:p_out --返回包
  ----------------------------------------------------------------------*/

  procedure f130(p_in in arr, p_out in out arr) as
    v_ma_Info   meteraccount%rowtype;
    v_meterinfo meterinfo%rowtype;
    RCOUNT      NUMBER(10);
  
    ERR_TS_DK EXCEPTION;
  
    ERR_BANK EXCEPTION;
    ERR_ACCOUNT EXCEPTION;
  
  begin
    v_ma_Info.MABANKID := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_ma_Info.Mamicode := trim(F_GET_HDTEXT(7));
    rcount             := F_SET_TEXT(1, trim(F_GET_HDTEXT(6))); --交易码
    rcount             := F_SET_TEXT(2, '000'); --返回码
    rcount             := F_SET_TEXT(3, '解约成功'); --返回说明
    rcount             := F_SET_TEXT(4, F_GET_HDTEXT(7)); --水表资料号
    rcount             := F_SET_TEXT(5, F_GET_HDTEXT(1)); --银行编码
    rcount             := F_SET_TEXT(6, '');
    rcount             := F_SET_TEXT(7, '');
    rcount             := F_SET_TEXT(8, '');
    rcount             := F_SET_TEXT(9, '');
    rcount             := F_SET_TEXT(10, '');
  
    --匹配水表资料好
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
  
    --如果不是代扣户，则返回错误
    if v_meterinfo.MICHARGETYPE <> 'D' THEN
      rcount := F_SET_TEXT(6, to_char(v_ma_Info.Maaccountno));
      rcount := F_SET_TEXT(7, to_char(v_meterinfo.Miname));
      rcount := F_SET_TEXT(8, to_char(v_ma_Info.maaccountname));
      rcount := F_SET_TEXT(9, 'N');
      rcount := F_SET_TEXT(2, '000');
      rcount := F_SET_TEXT(3, '正常返回');
    
    else
      select T.*
        INTO v_ma_Info
        FROM meteraccount T
       WHERE T.MAMICODE = v_meterinfo.micode;
      rcount := F_SET_TEXT(6, to_char(v_ma_Info.Maaccountno));
      rcount := F_SET_TEXT(7, to_char(v_meterinfo.Miname));
      rcount := F_SET_TEXT(8, to_char(v_ma_Info.maaccountname));
      rcount := F_SET_TEXT(9, 'Y');
      rcount := F_SET_TEXT(2, '000');
      rcount := F_SET_TEXT(3, '正常返回');
    
    END IF;
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '查不到用户的数据，可能不存在该用户');
    
    WHEN OTHERS THEN
      rcount := F_SET_TEXT(2, '003');
      rcount := F_SET_TEXT(3, '可能数据异常，造成系统无法处理');
    
  end f130;

  procedure sp_test as
    v_p1     arr;
    v_p2     arr;
    i        number(10);
    v_result varchar2(3);
  begin
    i    := 0;
    v_p1 := arr('');
    v_p2 := arr('');
    loop
      i := i + 1;
      v_p1.extend;
      v_p1(i) := to_char(i);
      infomsg(v_p1(i));
      exit when i > 10;
    end loop;
    v_result := main('1110', v_p1, v_p2);
  end sp_test;

  --packetsDT扩充行
  procedure sp_extensiondata(P_ROW IN NUMBER) as
    v_b     number(10);
    v_e     number(10);
    v_row   number(10);
    v_count number(10);
    v_num   number(10);
    DT      packetsDT%ROWTYPE;
  begin
    --获取循环起止行
    SELECT to_number(trim(c2))
      into v_b
      FROM packetsDT
     WHERE TRIM(C3) = 'b';
    SELECT to_number(trim(c2))
      into v_e
      FROM packetsDT
     WHERE TRIM(C3) = 'e';
    IF v_e - v_b <= 0 THEN
      RETURN;
    END IF;
  
    --根据次数循环数据
    v_count := v_e - v_b + 1;
    for v_row in 1 .. v_count loop
      SELECT *
        INTO DT
        FROM packetsDT
       WHERE TO_NUMBER(TRIM(C2)) = v_b + v_row - 1;
    
      --循环次数，默认数据中存在一次,P_ROW-1
      for v_num in 1 .. P_ROW - 1 loop
        --C2=顺序号
        DT.C2 := v_b + v_row - 1 + (v_count * v_num);
        INSERT INTO packetsDT VALUES DT;
      end loop;
    
    end loop;
  end sp_extensiondata;

  /*---------------------------------------------------------------------
  记录交易日志
  ---------------------------------------------------------------------*/
  procedure sp_tran_log(p_code in varchar2, p_req in arr, p_ans in arr) as
    v_bankid varchar2(10);
  
    rcount number(10);
  
    msg_req varchar2(4000);
  
    msg_ans varchar2(4000);
  
  begin
    msg_req := f_arr2var(p_req);
    msg_ans := f_arr2var(p_ans);
  
    IF LENGTH(P_CODE) > 3 THEN
      V_BANKID := trim(P_REQ(2));
    ELSE
      V_BANKID := trim(P_REQ(1));
    END IF;
  
    insert into BANK_TRAN_LOG t
      select SEQ_BANK_TRAN_LOG.NEXTVAL,
             P_CODE,
             V_BANKID,
             SYSDATE,
             MSG_REQ,
             MSG_ANS
        FROM DUAL;
   -- COMMIT;
  
  end sp_tran_log;
  
  procedure sp_tran_errlog(p_code in varchar2, 
                           p_req in arr, 
                           p_ans in arr,
                           p_errid in varchar2,
                           p_errtext in varchar2) as
    v_bankid varchar2(10);

    rcount number(10);

    msg_req varchar2(4000);

    msg_ans varchar2(4000);

  begin
    msg_req := f_arr2var(p_req);
    msg_ans := f_arr2var(p_ans);

    IF LENGTH(P_CODE) > 3 THEN
      V_BANKID := trim(P_REQ(2));
    ELSE
      V_BANKID := trim(P_REQ(1));
    END IF;

    insert into BANK_TRAN_ERRLOG t
      select P_CODE,
             V_BANKID,
             SYSDATE,
             MSG_REQ,
             MSG_ANS,
             p_errid,
             p_errtext
        FROM DUAL;
    -- COMMIT;

  end sp_tran_errlog;
  
  /*---------------------------------------------------------------------
   将 arr 内容转化为|分隔的字符串
  ---------------------------------------------------------------------*/
  function f_arr2var(p_msg in arr) return varchar2 as
    rcount   number(10);
    v_result varchar2(4000);
  begin
    rcount   := 1;
    v_result := '';
    while rcount <= p_msg.count loop
      v_result := v_result || '|' || trim(p_msg(rcount));
      rcount   := rcount + 1;
    end loop;
    return v_result;
  
  end f_arr2var;

  /*记录签约日志*/
  procedure entrust_sign_log(p_ccode       in varchar2,
                             p_cname       in varchar2,
                             p_bankid      in varchar2,
                             p_ACCOUNTNO   in varchar2,
                             p_ACCOUNTNAME in varchar2,
                             p_CHARGETYPE  in varchar2,
                             p_SIGN_TYPE   in char,
                             p_SIGN_OK     in char) as
    v_id number(10);
  
  begin
    select SEQ_ENTRUSTLOG.NEXTVAL into v_id from dual;
    insert into bs_entrust_sign_log t
    values
      (v_id,
       p_ccode,
       p_cname,
       p_bankid,
       p_ACCOUNTNO,
       p_ACCOUNTNAME,
       p_CHARGETYPE,
       p_SIGN_TYPE,
       sysdate,
       p_SIGN_OK,
       sysdate);
    --commit;
  
  end entrust_sign_log;

  /*----------------------------------------------------------------------
  Note:银行实时缴费销账过程
  Input:  p_bankid    银行编码,
          p_chg_op    收费员,
          p_mcode     水表资料号,
          p_chg_total 缴费金额
  output: p_chgno     传入为银行流水，输出为系统实收流水号,
          p_discharge 本次缴费预存的发生值，如果为正则预存增加，如果为负则是使用预存进行了抵扣
          p_curr_sav  本次缴费后，预存的余额
  return：1  无此水表号
          5  金额不符
          21 数据库错误
          22 其他错误
  业务规则说明：
  1、水表资料号下全额欠费必须一同缴清；
  2、代扣托收在途时允许银行实时代收，待代扣托收回帐且成功时计预存；
  3、交易时段每日5:00-23:00
  ----------------------------------------------------------------------*/
  function f_bank_chg_total(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2 as
  
    mi meterinfo%rowtype;
  
    v_retstr varchar2(10); --返回结果
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --应收流水
    PLIDS    VARCHAR2(1280); --合收表销账用应收流水列表
    V_RLJE   NUMBER(12, 2); --应收金额
    V_ZNJ    NUMBER(12, 2); --滞纳金
  
    v_LJFJE     NUMBER(12, 2); --垃圾费金额
    v_RLIDS_LJF VARCHAR2(20000); --垃圾费应收流水
    v_out_LJFJE NUMBER(12, 2); --垃圾费销帐金额
  
    v_SXF  NUMBER(12, 2); --//手续费
    v_type varchar2(10); --销帐方式
  
    v_FKFS payment.ppayway%type; --  //付款方式
  
    v_PAYBATCH payment.PBATCH%type; -- //销帐批次  --ok
    v_IFP      varchar2(10); --        , //是否打票
    v_INVNO    varchar2(10); -- //发票号
    v_COMMIT   varchar2(10); -- , //控制是否提交
  
    v_discharge number(10, 2); --本次缴费抵扣金额
    v_curr_sav  number(10, 2); --本次缴费后预存金额
  
    P_MIID PAYMENT.PMID%TYPE; --水表资料号
    v_pid       payment.pid%type;
    rcount number(10);
    v_zbqf number(10);
  
    cursor c_hs_meter(c_miid varchar2) is
      select miid from meterinfo where mipriid = c_miid;
  
    v_hs_meter meterinfo%rowtype;
    v_hs_rlids varchar2(1280); --应收流水
    v_hs_rlje  number(12, 2); --应收金额
    v_hs_znj   number(12, 2); --滞纳金
    v_hs_sxf   number(12, 2); --手续费
    v_hs_outje number(12, 2);
    v_qfnum    number(10); --应收账笔数
  
  begin
    BEGIN
      SELECT * into mi FROM METERINFO T WHERE MICODE = p_mcode;
    EXCEPTION
      WHEN OTHERS THEN
        --用户不存在
        return '001';
    END;
    begin
      --统计欠费记录数
      select count(rlid)
        into v_qfnum
        from (SELECT rlid AS rlid
                from reclist rl
               WHERE rlprimcode = p_mcode
                 and rl.rlreverseflag = 'N'
                 and rl.rlpaidflag = 'N'
                 and rl.rlje > 0
                 and rl.rlbadflag = 'N'
               GROUP BY rlid);
    
      select sum(DECODE(rloutflag, 'Y', 1, 0)),
             REPLACE(connstr(RLID), '/', ',') || '|',
             sum(rlje),
             sum(PG_EWIDE_PAY_01.getznjadj(rlid,
                                           nvl(rlje, 0),
                                           RLGROUP,
                                           rlzndate,
                                           rlsmfid,
                                           sysdate))
        INTO V_OUTJE, V_RLIDS, V_RLJE, V_ZNJ
        from RECLIST RL
       WHERE rl.rlprimcode = p_mcode
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLBADFLAG = 'N';
    
      v_SXF := 0;
    exception
      when others then
        null;
        V_OUTJE := 0;
        V_RLIDS := null;
        V_RLJE  := 0;
        V_ZNJ   := 0;
    end;
    if V_RLJE is null then
      V_OUTJE := 0;
      --V_RLIDS :=null;
      V_RLJE := 0;
      V_ZNJ  := 0;
    end if;
/*    if V_OUTJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS then
      return '003'; --锁帐
    end if;*/
  
    v_FKFS     := 'XJ';
    V_PAYBATCH := fgetsequence('ENTRUSTLOG');
    V_IFP      := 'N';
    V_INVNO    := NULL;
    V_COMMIT   := 'N';
  
    ------垃圾费的赋值 20120926
    v_LJFJE     := 0;
    v_RLIDS_LJF := 0;
    v_out_LJFJE := 0;
  
    v_LJFJE := v_LJFJE - v_out_LJFJE;
  
    IF v_out_LJFJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS THEN
      return '005'; --金额不符
    END IF;
  
    IF v_RLJE + v_ZNJ + v_SXF + v_LJFJE - nvl(mi.misaving, 0) > p_chg_total THEN
      IF substr(p_chg_op,1,3) = 'ATM' THEN
        v_type := '01';
         P_MIID := mi.miid;
      ELSE
         return '005'; --非ATM机缴费必须大于欠费
      END IF;
    END IF;
  
    /*  --补垃圾费参数
    delete pbparmtemp;
    insert into pbparmtemp
      (c1, c2)
      select rl.rl_id, rl.RL_MCODE
        from whzlsds.record_list RL
       WHERE RL_MCODE = p_mcode
         and rl.rl_reverse_flag = 'N'
         and rl.rl_paid_flag = 'N'
            --    and rl.rl_outflag='N'
         and rl.rd_money > 0;*/
  
    -------------20130922 增加合收表销账判断-----------------------
    ---如果有欠费，为实收交易   
    if v_qfnum > 0 then
      -----赋值
      if mi.mipriflag = 'N' then
        v_type := '01';
        P_MIID := mi.miid;
      else
        v_type := '02';
        P_MIID := mi.mipriid;
      
        --检查合收子表有没有欠费，无欠费则转为主表单表缴费
        select count(rlid)
          into v_zbqf
          from (SELECT rlid AS rlid
                  from reclist rl
                 WHERE rlprimcode = P_MIID
                   and rlmcode <> P_MIID
                   and rl.rlreverseflag = 'N'
                   and rl.rlpaidflag = 'N'
                   and rl.rlje > 0
                   and rl.rlbadflag = 'N'
                 GROUP BY rlid);
        if v_zbqf = 0 then
          v_type := '01';
          P_MIID := mi.mipriid;
        end if;
      
        --插入pay_para_tmp 表做合收表销账准备
        delete pay_para_tmp;
      
        OPEN C_HS_METER(P_MIID);
        LOOP
          FETCH C_HS_METER
            INTO V_HS_METER.MIID;
          EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
          v_hs_outje := 0;
          v_hs_rlids := '';
          v_hs_rlje := 0;
          v_hs_znj := 0;
          select sum(DECODE(rloutflag, 'Y', 1, 0)),
                 REPLACE(connstr(RLID), '/', ',') || '|',
                 sum(rlje),
                 sum(PG_EWIDE_PAY_01.getznjadj(rlid,
                                               nvl(rlje, 0),
                                               RLGROUP,
                                               rlzndate,
                                               rlsmfid,
                                               sysdate))
            INTO v_hs_outje, v_hs_rlids, v_hs_rlje, v_hs_znj
            from RECLIST RL
           WHERE rl.rlmid = V_HS_METER.MIID
             AND RL.RLJE > 0
             AND RL.RLPAIDFLAG = 'N'
                --AND RL.RLOUTFLAG = 'N'
             AND RL.RLREVERSEFLAG = 'N'
             AND RL.RLBADFLAG = 'N';
          if v_hs_rlje>0 then
            insert into pay_para_tmp
            values
              (V_HS_METER.MIID, v_hs_rlids, v_hs_rlje, v_SXF, v_hs_znj);
           end if;
        end loop;
        close C_HS_METER;
      end if;
      -------------20130922 增加合收表销账判断end-----------------------
    
      ----如果不欠费是单缴预存
    else
      v_type := '01';
      P_MIID := mi.miid;
    end if;
  
    --销帐
    v_retstr := PG_EWIDE_PAY_01.POS(v_type, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                    p_bankid, --缴费机构
                                    p_chg_op, --收款员
                                    v_RLIDS, --应收流水串
                                    v_RLJE, --应收总金额
                                    v_ZNJ, --销帐违约金
                                    v_SXF, --手续费
                                    p_chg_total, --实际收款
                                    p_trans, --缴费事务
                                    P_MIID, --水表资料号
                                    v_FKFS, --付款方式
                                    p_bankid, --缴费地点
                                    v_PAYBATCH, --销帐批次
                                    v_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                    v_INVNO, --发票号
                                    v_COMMIT --控制是否提交（Y/N）
                                    );
  
    if v_retstr <> '000' then
      return '021'; --缴费错误
    end if;
  
    BEGIN
      update payment t set t.PBSEQNO = p_chgno where PBATCH = v_PAYBATCH;
      select max(pid) into v_pid from payment where pbatch = v_PAYBATCH and pmid=ppriid and ptrans<>'K';
    exception
      when others then
        return '021';
    end;
    select nvl(misaving, 0)
      into v_curr_sav
      from meterinfo
     where micode = p_mcode;
    v_discharge := nvl(v_curr_sav, 0) - nvl(mi.misaving, 0);
    o_discharge := v_discharge; --
    o_curr_sav  := v_curr_sav; --
    o_pid       := v_pid;
    return '000';
  exception
    when others then
      rollback;
      return '021';
  end;

function f_bank_chg_total_pz(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2 as
  
    mi meterinfo%rowtype;
  
    v_retstr varchar2(10); --返回结果
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --应收流水
    PLIDS    VARCHAR2(1280); --合收表销账用应收流水列表
    V_RLJE   NUMBER(12, 2); --应收金额
    V_ZNJ    NUMBER(12, 2); --滞纳金
  
    v_LJFJE     NUMBER(12, 2); --垃圾费金额
    v_RLIDS_LJF VARCHAR2(20000); --垃圾费应收流水
    v_out_LJFJE NUMBER(12, 2); --垃圾费销帐金额
  
    v_SXF  NUMBER(12, 2); --//手续费
    v_type varchar2(10); --销帐方式
  
    v_FKFS payment.ppayway%type; --  //付款方式
  
    v_PAYBATCH payment.PBATCH%type; -- //销帐批次  --ok
    v_IFP      varchar2(10); --        , //是否打票
    v_INVNO    varchar2(10); -- //发票号
    v_COMMIT   varchar2(10); -- , //控制是否提交
  
    v_discharge number(10, 2); --本次缴费抵扣金额
    v_curr_sav  number(10, 2); --本次缴费后预存金额
  
    P_MIID PAYMENT.PMID%TYPE; --水表资料号
    v_pid       payment.pid%type;
    rcount number(10);
    v_zbqf number(10);
  
    cursor c_hs_meter(c_miid varchar2) is
      select miid from meterinfo where mipriid = c_miid;
  
    v_hs_meter meterinfo%rowtype;
    v_hs_rlids varchar2(1280); --应收流水
    v_hs_rlje  number(12, 2); --应收金额
    v_hs_znj   number(12, 2); --滞纳金
    v_hs_sxf   number(12, 2); --手续费
    v_hs_outje number(12, 2);
    v_qfnum    number(10); --应收账笔数
  
  begin
    BEGIN
      SELECT * into mi FROM METERINFO T WHERE MICODE = p_mcode;
    EXCEPTION
      WHEN OTHERS THEN
        --用户不存在
        return '001';
    END;
 /*   begin
      --统计欠费记录数
      select count(rlid)
        into v_qfnum
        from (SELECT rlid AS rlid
                from reclist rl
               WHERE rlprimcode = p_mcode
                 and rl.rlreverseflag = 'N'
                 and rl.rlpaidflag = 'N'
                 and rl.rlje > 0
                 and rl.rlbadflag = 'N'
               GROUP BY rlid);
    
      select sum(DECODE(rloutflag, 'Y', 1, 0)),
             REPLACE(connstr(RLID), '/', ',') || '|',
             sum(rlje),
             sum(PG_EWIDE_PAY_01.getznjadj(rlid,
                                           nvl(rlje, 0),
                                           RLGROUP,
                                           rlzndate,
                                           rlsmfid,
                                           sysdate))
        INTO V_OUTJE, V_RLIDS, V_RLJE, V_ZNJ
        from RECLIST RL
       WHERE rl.rlprimcode = p_mcode
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLBADFLAG = 'N';
    
      v_SXF := 0;
    exception
      when others then
        null;
        V_OUTJE := 0;
        V_RLIDS := null;
        V_RLJE  := 0;
        V_ZNJ   := 0;
    end;
    if V_RLJE is null then
      V_OUTJE := 0;
      --V_RLIDS :=null;
      V_RLJE := 0;
      V_ZNJ  := 0;
    end if;*/
    
        V_OUTJE := 0;
        V_RLIDS := null;
        V_RLJE  := 0;
        V_ZNJ   := 0;
/*    if V_OUTJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS then
      return '003'; --锁帐
    end if;*/
  
    v_FKFS     := 'XJ';
    V_PAYBATCH := fgetsequence('ENTRUSTLOG');
    V_IFP      := 'N';
    V_INVNO    := NULL;
    V_COMMIT   := 'N';
  
    ------垃圾费的赋值 20120926
/*    v_LJFJE     := 0;
    v_RLIDS_LJF := 0;
    v_out_LJFJE := 0;
  
    v_LJFJE := v_LJFJE - v_out_LJFJE;
  
    IF v_out_LJFJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS THEN
      return '005'; --金额不符
    END IF;
  
    IF v_RLJE + v_ZNJ + v_SXF + v_LJFJE - nvl(mi.misaving, 0) > p_chg_total THEN
      IF substr(p_chg_op,1,3) = 'ATM' THEN
        v_type := '01';
         P_MIID := mi.miid;
      ELSE
         return '005'; --非ATM机缴费必须大于欠费
      END IF;
    END IF;*/
  
    /*  --补垃圾费参数
    delete pbparmtemp;
    insert into pbparmtemp
      (c1, c2)
      select rl.rl_id, rl.RL_MCODE
        from whzlsds.record_list RL
       WHERE RL_MCODE = p_mcode
         and rl.rl_reverse_flag = 'N'
         and rl.rl_paid_flag = 'N'
            --    and rl.rl_outflag='N'
         and rl.rd_money > 0;*/
  
    -------------20130922 增加合收表销账判断-----------------------
    ---如果有欠费，为实收交易   
  /*  if v_qfnum > 0 then
      -----赋值
      if mi.mipriflag = 'N' then
        v_type := '01';
        P_MIID := mi.miid;
      else
        v_type := '02';
        P_MIID := mi.mipriid;
      
        --检查合收子表有没有欠费，无欠费则转为主表单表缴费
        select count(rlid)
          into v_zbqf
          from (SELECT rlid AS rlid
                  from reclist rl
                 WHERE rlprimcode = P_MIID
                   and rlmcode <> P_MIID
                   and rl.rlreverseflag = 'N'
                   and rl.rlpaidflag = 'N'
                   and rl.rlje > 0
                   and rl.rlbadflag = 'N'
                 GROUP BY rlid);
        if v_zbqf = 0 then
          v_type := '01';
          P_MIID := mi.mipriid;
        end if;
      
        --插入pay_para_tmp 表做合收表销账准备
        delete pay_para_tmp;
      
        OPEN C_HS_METER(P_MIID);
        LOOP
          FETCH C_HS_METER
            INTO V_HS_METER.MIID;
          EXIT WHEN C_HS_METER%NOTFOUND OR C_HS_METER%NOTFOUND IS NULL;
          v_hs_outje := 0;
          v_hs_rlids := '';
          v_hs_rlje := 0;
          v_hs_znj := 0;
          select sum(DECODE(rloutflag, 'Y', 1, 0)),
                 REPLACE(connstr(RLID), '/', ',') || '|',
                 sum(rlje),
                 sum(PG_EWIDE_PAY_01.getznjadj(rlid,
                                               nvl(rlje, 0),
                                               RLGROUP,
                                               rlzndate,
                                               rlsmfid,
                                               sysdate))
            INTO v_hs_outje, v_hs_rlids, v_hs_rlje, v_hs_znj
            from RECLIST RL
           WHERE rl.rlmid = V_HS_METER.MIID
             AND RL.RLJE > 0
             AND RL.RLPAIDFLAG = 'N'
                --AND RL.RLOUTFLAG = 'N'
             AND RL.RLREVERSEFLAG = 'N'
             AND RL.RLBADFLAG = 'N';
          if v_hs_rlje>0 then
            insert into pay_para_tmp
            values
              (V_HS_METER.MIID, v_hs_rlids, v_hs_rlje, v_SXF, v_hs_znj);
           end if;
        end loop;
        close C_HS_METER;
      end if;
      -------------20130922 增加合收表销账判断end-----------------------
    
      ----如果不欠费是单缴预存
    else
      v_type := '01';
      P_MIID := mi.miid;
    end if;*/
    
    v_type := '02';
    P_MIID := mi.mipriid;
  
    --销帐
    v_retstr := PG_EWIDE_PAY_01.POS(v_type, --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                                    p_bankid, --缴费机构
                                    p_chg_op, --收款员
                                    v_RLIDS, --应收流水串
                                    v_RLJE, --应收总金额
                                    v_ZNJ, --销帐违约金
                                    v_SXF, --手续费
                                    p_chg_total, --实际收款
                                    p_trans, --缴费事务
                                    P_MIID, --水表资料号
                                    v_FKFS, --付款方式
                                    p_bankid, --缴费地点
                                    v_PAYBATCH, --销帐批次
                                    v_IFP, --是否打票  Y 打票，N不打票， R 应收票
                                    v_INVNO, --发票号
                                    v_COMMIT --控制是否提交（Y/N）
                                    );
  
    if v_retstr <> '000' then
      return '021'; --缴费错误
    end if;
  
    BEGIN
      update payment t set t.PBSEQNO = p_chgno where PBATCH = v_PAYBATCH;
      select max(pid) into v_pid from payment where pbatch = v_PAYBATCH and pmid=ppriid and ptrans<>'K';
    exception
      when others then
        return '021';
    end;
    select nvl(misaving, 0)
      into v_curr_sav
      from meterinfo
     where micode = p_mcode;
    v_discharge := nvl(v_curr_sav, 0) - nvl(mi.misaving, 0);
    o_discharge := v_discharge; --
    o_curr_sav  := v_curr_sav; --
    o_pid       := v_pid;
    return '000';
  exception
    when others then
      rollback;
      return '021';
  end;
  /*银行实时缴费冲正----------------------------------------------------------------------
   p_bankid:银行代码
   p_transno:待撤销交易流水
   p_date :银行交易日期
   return：
         6：交易不存在
         21：数据库操作错
         22：其他错误；
  ------------------------------------------------------------------------------------------*/
  function f_bank_discharged(p_bankid  in varchar2,
                             p_transno in varchar2,
                             p_meterno in varchar2,
                             p_date    in date) return number as
    v_retstr varchar2(10);
  begin
    --检查实收
    v_retstr := f_bank_dischargeone(p_bankid, p_transno, p_meterno, p_date);
    if v_retstr = '000' then
      return 0;
    elsif v_retstr = '006' then
      --交易不存在
      return 6;
    elsif v_retstr = '021' then
      return 21;
    else
      return 22;
    end if;
  exception
    when others then
      rollback;
      return 22;
  end;

  function f_bank_dischargeone(p_bankid  in varchar2,
                               p_transno in varchar2,
                               p_meterno in varchar2,
                               p_date    in date) return varchar2 as
    v_BATCH  PAYMENT.PBATCH%TYPE; --自来水缴费流水
    v_PPER   PAYMENT.PPER%TYPE; --销帐员
    v_TRANS  PAYMENT.PPER%TYPE; --事务
    rcount   number(10);
    v_retstr varchar2(20);
  begin
    --检查实收
    begin
      select max(PBATCH), max(pper)
        INTO v_BATCH, v_PPER
        from payment t
       where t.pbseqno = p_transno
         and t.PFLAG = 'Y'
         AND T.PREVERSEFLAG = 'N'
         and t.pposition = p_bankid
         and t.pmcode = p_meterno
/*         and pdate >= trunc(p_date)
         and t.pdate < trunc(p_date) + 1*/;
     --这里想把谁操作的加进来，实验一下BY 20141229；
    -- SELECT FGETPBOPER INTO v_PPER FROM DUAL;
    exception
      when others then
        return '006'; --交易不存在
    end;
    --检查客户代码
    v_TRANS := 'X';
    if v_BATCH is not null then
      v_retstr := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(v_BATCH, --自来水缴费流水
                                                     p_bankid, --银行
                                                     v_PPER, --销帐员
                                                     p_bankid, --银行
                                                     v_TRANS --事务
                                                     
                                                     );
    else
    
      return '006'; --交易不存在                                               
    end if;
  
    if v_retstr <> '000' then
      return '021';
    end if;
  
    return '000';
  exception
    when others then
      rollback;
      return '022';
  end;

  --银行补销
  function f_bank_charged_total(p_bankid    in varchar2, --银行
                                p_chg_op    in varchar2, --操作员
                                p_mcode     in varchar2, --户号
                                p_chg_total in number, --缴费金额
                                p_chg_no    in varchar2, --交易流水
                                p_paydate   in varchar2 --交易日期
                                ) return number as
    cursor c_rl is
      SELECT rlid, rloutflag
        from RECLIST RL
       WHERE RL.RLMCODE = p_mcode
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         and (trunc(RL.RLDATE) > to_date(p_paydate, 'yyyymmdd') or
             trunc(RLSCRRLDATE) > to_date(p_paydate, 'yyyymmdd'));
  
    rl    reclist%rowtype;
    spara varchar2(500);
    lret  number;
  
    p_discharge number;
    p_curr_sav  number;
    v_pid payment.pid%type;
    mi          meterinfo%rowtype;
    vpid        varchar2(10);
    v_str       varchar2(100);
    v_discharge number(12, 2);
    v_curr_sav  number(12, 2);
    subtype rd_type is ARRSTR2;
    type rl_table is table of rd_type;
  
    rlt    ARRSTR2 := ARRSTR2('', '');
    rl_arr rl_table;
    --   rl_njf_arr rl_table;
  
  begin
    select * into mi from meterinfo where micode = p_mcode;
    --锁水费帐
    open c_rl;
    fetch c_rl
      into rlt.STR1, rlt.STR2;
    while c_rl%found loop
    
      if rl_arr is null then
        rl_arr := rl_table(rlt);
      else
        rl_arr.extend;
        rl_arr(rl_arr.last) := rlt;
      END IF;
      --锁帐
      update reclist set rloutflag = 'Y' where rlid = rlt.STR1;
      fetch c_rl
        into rlt.STR1, rlt.STR2;
    end loop;
    close c_rl;
  
    v_str := f_bank_chg_total(p_bankid,
                              p_chg_op,
                              p_mcode,
                              p_chg_total,
                              pg_ewide_pay_01.PAYTRANS_DSDE,
                              p_chg_no,
                              '',
                              '',
                              v_pid,
                              v_discharge,
                              v_curr_sav);
  
    --还原锁帐标志
    --水费
    if rl_arr is not null then
      for i in rl_arr.first .. rl_arr.last loop
        null;
        update reclist
           set rloutflag = rl_arr(i).str2
         where rlid = rl_arr(i).str1;
      end loop;
    end if;
  
   -- commit;
    if v_str = '000' then
      return 0;
    elsif v_str = '001' then
      --'无此水表号'
      return 1;
    elsif v_str = '004' then
      --'金额不符'
      return 5;
    elsif v_str = '002' then
      --'数据库错误'
      return 21;
    elsif v_str = '005' or v_str = '007' then
      --'数据库错误'
      return 22;
    else
      return 22;
    end if;
    return 0;
  exception
    when others then
      rollback;
      return 22;
  end;
  
  function f_bank_charged_total_pz(p_bankid    in varchar2, --银行
                                p_chg_op    in varchar2, --操作员
                                p_mcode     in varchar2, --户号
                                p_chg_total in number, --缴费金额
                                p_chg_no    in varchar2, --交易流水
                                p_paydate   in varchar2 --交易日期
                                ) return number as
/*    cursor c_rl is
      SELECT rlid, rloutflag
        from RECLIST RL
       WHERE RL.RLMCODE = p_mcode
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
         and (trunc(RL.RLDATE) > to_date(p_paydate, 'yyyymmdd') or
             trunc(RLSCRRLDATE) > to_date(p_paydate, 'yyyymmdd'));*/
  
    rl    reclist%rowtype;
    spara varchar2(500);
    lret  number;
  
    p_discharge number;
    p_curr_sav  number;
    v_pid payment.pid%type;
    mi          meterinfo%rowtype;
    vpid        varchar2(10);
    v_str       varchar2(100);
    v_discharge number(12, 2);
    v_curr_sav  number(12, 2);
    subtype rd_type is ARRSTR2;
    type rl_table is table of rd_type;
  
    rlt    ARRSTR2 := ARRSTR2('', '');
    rl_arr rl_table;
    --   rl_njf_arr rl_table;
  
  begin
    select * into mi from meterinfo where micode = p_mcode;
    --锁水费帐
/*    open c_rl;
    fetch c_rl
      into rlt.STR1, rlt.STR2;
    while c_rl%found loop
    
      if rl_arr is null then
        rl_arr := rl_table(rlt);
      else
        rl_arr.extend;
        rl_arr(rl_arr.last) := rlt;
      END IF;
      --锁帐
      update reclist set rloutflag = 'Y' where rlid = rlt.STR1;
      fetch c_rl
        into rlt.STR1, rlt.STR2;
    end loop;
    close c_rl;*/
  
    v_str := f_bank_chg_total_pz(p_bankid,
                              p_chg_op,
                              p_mcode,
                              p_chg_total,
                              pg_ewide_pay_01.PAYTRANS_DSDE,
                              p_chg_no,
                              '',
                              '',
                              v_pid,
                              v_discharge,
                              v_curr_sav);
  
    --还原锁帐标志
    --水费
/*    if rl_arr is not null then
      for i in rl_arr.first .. rl_arr.last loop
        null;
        update reclist
           set rloutflag = rl_arr(i).str2
         where rlid = rl_arr(i).str1;
      end loop;
    end if;*/
  
   -- commit;
    if v_str = '000' then
      return 0;
    elsif v_str = '001' then
      --'无此水表号'
      return 1;
    elsif v_str = '004' then
      --'金额不符'
      return 5;
    elsif v_str = '002' then
      --'数据库错误'
      return 21;
    elsif v_str = '005' or v_str = '007' then
      --'数据库错误'
      return 22;
    else
      return 22;
    end if;
    return 0;
  exception
    when others then
      rollback;
      return 22;
  end;

  --银行对账（生成自来水对账信息）
  procedure sp_bankdz(p_date in date, p_smfid in varchar2) AS
  
    CM_BANK BANKCHKLOG_NEW%ROWTYPE;
    type c_mi is ref cursor;
    cm_bank_mx c_mi;
    /*cursor cm_bank_mx is
      select *
        from bankchklog_new t
       where t.chkdate = p_date
         and trim(bankcode) = p_smfid
         AND T.OKFLAG = 'N';*/
  begin
    null;

     --支持多次手工对账，对账前先删除之前的记录
    --删除对账明细
    delete bank_dz_mx
     where id = (select b.id
                   from bankchklog_new b
                  where bankcode = p_smfid
                    and chkdate = p_date);

    --删除对账流水               
    delete bankchklog_new
     where bankcode = p_smfid
       and chkdate = p_date;
  
    --重置对账文件标志位
    update entrustfile
       set efflag = 2
     where substr(effilename, (f_getptype(effilename, '.') - 7), 8)= to_char(p_date,'yyyymmdd')
   --  to_date(substr(effilename, (f_getptype(effilename, '.') - 7), 8),'yyyymmdd') = trunc(p_date)
       and efpath = (select max(smppvalue)
                       from sysmanapara
                      where smpid = p_smfid
                        and smppid = 'FTPDZDIR');
    commit;--20140521
/*    IF  cm_bank_mx%FOUND THEN
      CM_BANK.ID:=trim(to_char(bankchklog.nextval, '0000000000'));
    END IF;*/
    insert into bankchklog_new
      (SELECT trim(to_char(bankchklog.nextval, '0000000000')) id,
              T.CHKDATE,
              T.smfid,
              0,
              0,
              NULL,
              'N',
              NULL,
              NULL,
              NULL,
              NULL,
              NULL,
              NULL
         FROM (select NVL(A.CHKDATE,p_date) CHKDATE,
                      B.smfid,
                      0,
                      0,
                      NULL,
                      'N',
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL,
                      NULL
                 FROM (SELECT DISTINCT (trunc(T1.PCHKDATE)) CHKDATE, 'M' DZ
                         FROM PAYMENT T1
                        WHERE T1.PCHKDATE = p_date
                          AND T1.PTRANS = 'B') A,
                      (select C.smfid AS smfid, C.smfname AS smfname, 'M' DZ
                         from sysmanaframe C,
                              sysmanapara  a,
                              sysmanapara  b,
                              sysmanapara  x
                        where C.smfid = a.smpid
                          and C.smfid = b.smpid
                          and C.smfid = x.smpid
                          and a.smppid = 'FTPDZDIR'
                          and b.smppid = 'FTPDZSRV'
                          and x.smppid = 'BCODE'
                          and (x.smppvalue is not null or x.smppvalue != '')
                          and c.smfid = p_smfid) B WHERE A.DZ(+)=B.DZ ) T
        WHERE (T.smfid, T.CHKDATE) NOT IN
              (SELECT T1.BANKCODE, CHKDATE
                 FROM bankchklog_new T1
                WHERE T1.CHKDATE = p_date));
      COMMIT; --20140102
    OPEN  cm_bank_mx FOR 
      select *
        from bankchklog_new t
       where T.chkdate = p_date
         and trim(bankcode) = p_smfid
         AND TRIM(T.OKFLAG) = 'N';
   FETCH cm_bank_mx INTO CM_BANK;  
    LOOP
      EXIT WHEN cm_bank_mx%NOTFOUND OR cm_bank_mx%NOTFOUND IS NULL;
      insert into bank_dz_mx
        (SELECT CM_BANK.ID,
                TRIM(T.PBSEQNO),
                sum(T.PPAYMENT),
                NULL,
                NULL,
                T.ppriid,
                T.PCHKDATE,
                NULL,
                'N',
                NULL
           from payment t
          where t.PCHKDATE = trunc(CM_BANK.CHKDATE)
            and PFLAG = 'Y'
            AND PREVERSEFLAG = 'N'
            AND T.PPOSITION = CM_BANK.BANKCODE
            --AND T.PTRANS = 'B'
            AND T.PTRANS NOT IN ( 'E','K','U')   --往期的银行单边帐补销不在本期中生成自来水单边帐    by cdh    2015/08/31 银行模拟交易Q也包含在对账明细里 2016.12.13 byj
          group by PBSEQNO, ppriid, T.PCHKDATE);
      update BANKCHKLOG_NEW t
         set t.reccount =
             (select count(a.chargeno)
                from bank_dz_mx a
               where a.id = CM_BANK.ID),
             t.amount  =
             (select sum(a.money_local)
                from bank_dz_mx a
               where a.id = CM_BANK.ID)
       where t.id = CM_BANK.id
         and t.chkdate = CM_BANK.CHKDATE
         and t.bankcode = cm_bank.bankcode;
         FETCH cm_bank_mx INTO CM_BANK;
    END LOOP;
     COMMIT; --20140102
     CLOSE cm_bank_mx;
  exception
    when others then
      rollback;
  end sp_bankdz;

  function f_priceissame(p_pmiid in varchar2) return varchar2 as
    --合收表水表号游标
    cursor c_meterid is
      select micode from meterinfo where mipriid = p_pmiid;
  
    v_meterid  meterinfo.micode%type; --客户代码
    v_sfdj     number(12, 3); --水费单价
    v_wsfdj    number(12, 3); --污水费单价
    v_sumsfdj  number(12, 3);
    v_sumwsfdj number(12, 3);
    v_count    number(3);
    v_ret      varchar2(1);
  
  begin
    v_sfdj     := 0;
    v_wsfdj    := 0;
    v_sumsfdj  := 0;
    v_sumwsfdj := 0;
    v_count    := 0;
  
    open c_meterid;
    loop
      fetch c_meterid
        into v_meterid;
      exit when c_meterid%notfound or c_meterid%notfound is null;
      --求水费单价和污水费单价
      select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
             nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
        into v_sfdj, v_wsfdj
        from pricedetail pd
       where pd.pdpfid =
             (select mi.mipfid from meterinfo mi where mi.miid = v_meterid)
       group by pd.pdpfid;
      v_sumsfdj  := v_sumsfdj + v_sfdj;
      v_sumwsfdj := v_sumwsfdj + v_wsfdj;
      v_count    := v_count + 1;
    end loop;
    close c_meterid;
    --比较单价是否相同
    if v_sumsfdj = v_sfdj * v_count and v_sumwsfdj = v_wsfdj * v_count then
      v_ret := 'Y';
    else
      v_ret := 'N';
    end if;
    return v_ret;
  
  end f_priceissame;

  --获取用户账卡号
  function f_getcardno(p_rlcid in varchar2) return varchar2 as
    v_ret varchar2(14);
  begin
    select mibfid || mirorder
      into v_ret
      from meterinfo mi
     where mi.micid = p_rlcid;
    return v_ret;
  end;

  --翻译付款方式
  function f_getpayway(p_ppayway in varchar2) return varchar2 as
    v_ret varchar2(20);
  begin
    select sclvalue
      into v_ret
      from syscharlist
     where sclid = p_ppayway
       and scltype = '交易方式';
    return v_ret;
  end;
  
   --判断银行交易开关
FUNCTION F_GETBANKSYSPARA(P_BANKID IN VARCHAR2) RETURN VARCHAR2 AS
  LRET   VARCHAR2(20);
  P_SPID VARCHAR2(20);
BEGIN
  --获取参数编号
  IF P_BANKID = '030101' THEN
    --交通银行(030101)
    P_SPID := 'B001';
  ELSIF P_BANKID = '030201' THEN
    --邮政储蓄(030201)
    P_SPID := 'B002';
  ELSIF P_BANKID = '030301' THEN
    --工商银行(030301)
    P_SPID := 'B003';
  ELSIF P_BANKID = '030401' THEN
    --哈尔滨银行(030401)
    P_SPID := 'B004';
  ELSIF P_BANKID = '030501' THEN
    --中国银行(030501)
    P_SPID := 'B005';
  ELSIF P_BANKID = '030601' THEN
    --光大银行(030601)
    P_SPID := 'B006';
  ELSIF P_BANKID = '030701' THEN
    --建设银行(030701)
    P_SPID := 'B007';
  ELSIF P_BANKID = '030801' THEN
    --招商银行(030801)
    P_SPID := 'B008';
    ELSIF P_BANKID = '030901' THEN
    --兴业银行(030901)
    P_SPID := 'B009';
      ELSIF P_BANKID = '031001' THEN
    --龙江银行(031001)
    P_SPID := 'B010';
      ELSIF P_BANKID = '031101' THEN
    --储蓄银行(031101)
    P_SPID := 'B011';
  END IF;
  --查询开关状态
  SELECT SPVALUE INTO LRET FROM SYSPARA WHERE SPID = P_SPID;
  RETURN LRET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

  --设置银行交易开关
PROCEDURE P_SETBANKSYSPARA(P_BANKID IN VARCHAR2,P_TYPE IN VARCHAR2,P_COMMIT IN VARCHAR2) AS
  P_SPID VARCHAR2(20);
BEGIN
  --获取参数编号
  IF P_BANKID = '030101' THEN
    --交通银行(030101)
    P_SPID := 'B001';
  ELSIF P_BANKID = '030201' THEN
    --邮政储蓄(030201)
    P_SPID := 'B002';
  ELSIF P_BANKID = '030301' THEN
    --工商银行(030301)
    P_SPID := 'B003';
  ELSIF P_BANKID = '030401' THEN
    --哈尔滨银行(030401)
    P_SPID := 'B004';
  ELSIF P_BANKID = '030501' THEN
    --中国银行(030501)
    P_SPID := 'B005';
  ELSIF P_BANKID = '030601' THEN
    --光大银行(030601)
    P_SPID := 'B006';
  ELSIF P_BANKID = '030701' THEN
    --建设银行(030701)
    P_SPID := 'B007';
  ELSIF P_BANKID = '030801' THEN
    --招商银行(030801)
    P_SPID := 'B008';
        ELSIF P_BANKID = '030901' THEN
    --兴业银行(030901)
    P_SPID := 'B009';
      ELSIF P_BANKID = '031001' THEN
    --龙江银行(031001)
    P_SPID := 'B010';
      ELSIF P_BANKID = '031101' THEN
    --储蓄银行(031101)
    P_SPID := 'B011';
  END IF;
  --设置开关状态
  UPDATE SYSPARA SET SPVALUE = P_TYPE WHERE SPID = P_SPID;
  
  IF P_COMMIT='Y' THEN
     COMMIT;
  END IF;
  
END;

--自动银行扎帐
PROCEDURE SP_AUTOBANKZZ AS
  CURSOR C_BANKID IS
    SELECT SMFID
      FROM SYSMANAFRAME
     WHERE SMFPID LIKE '03%'
       AND SMFCLASS = '3'
     ORDER BY SMFID;

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  MB        MI_BANKZZ%ROWTYPE; --对账批次变量
  V_CHKDATE DATE; --系统扎帐日期

BEGIN
  --【哈尔滨】每天凌晨1点检查昨日银行是否扎帐，如果未扎帐则自动扎帐
  V_CHKDATE := TRUNC(SYSDATE) - 1;

  OPEN C_BANKID;
  LOOP
    FETCH C_BANKID
      INTO V_SMFID.SMFID;
    EXIT WHEN C_BANKID%NOTFOUND OR C_BANKID%NOTFOUND IS NULL;
    ---判断当天是否扎帐
    MB := NULL;
    BEGIN
      SELECT *
        INTO MB
        FROM MI_BANKZZ ZZ
       WHERE ZZ.BANKID = V_SMFID.SMFID
         AND ZZ.ZZDATE = V_CHKDATE;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    IF MB.DZNO IS NULL THEN
      --如果当日未扎帐则插入扎帐记录
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --对账编号 
        FROM DUAL;
      MB.BANKID := V_SMFID.SMFID; --银行编码 
      MB.ZZDATE := V_CHKDATE; --扎帐日期 
      MB.CZDATE := SYSDATE; --操作时间 
      MB.ZZFROM := 'S';--系统补扎
      INSERT INTO MI_BANKZZ VALUES MB;
    
      --更新实收记录,缴费日期截至至昨天，及扎帐日期
      UPDATE PAYMENT
         SET PCHKDATE = MB.ZZDATE, --对账日期
             PCHKNO   = MB.DZNO --进账单号
       WHERE PPOSITION = MB.BANKID
         AND PDATE <= V_CHKDATE --扎帐日期 
         AND PDATE >= TO_DATE('2014-04-17','YYYY-MM-DD')
         AND PCHKNO IS NULL;
    END IF;
  
  END LOOP;
  CLOSE C_BANKID;
  
  COMMIT;

END SP_AUTOBANKZZ;

--自动银行扎帐手动测试  hb test 因0716日工商银行未进行银行自动扎帐，后台job失效.需手动进行扎帐
PROCEDURE SP_AUTOBANKZZ_手动 AS
  CURSOR C_BANKID IS
    SELECT SMFID
      FROM SYSMANAFRAME
     WHERE SMFPID LIKE '03%'
       AND SMFCLASS = '3'
       and SMFid in('030401','030301')
     ORDER BY SMFID;

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  MB        MI_BANKZZ%ROWTYPE; --对账批次变量
  V_CHKDATE DATE; --系统扎帐日期

BEGIN
  --【哈尔滨】每天凌晨1点检查昨日银行是否扎帐，如果未扎帐则自动扎帐
 -- V_CHKDATE := TRUNC(SYSDATE) - 1;
  select trunc(to_date('20160331','yyyymmdd'))  into V_CHKDATE from dual;

  OPEN C_BANKID;
  LOOP
    FETCH C_BANKID
      INTO V_SMFID.SMFID;
    EXIT WHEN C_BANKID%NOTFOUND OR C_BANKID%NOTFOUND IS NULL;
    ---判断当天是否扎帐
    MB := NULL;
    BEGIN
      SELECT *
        INTO MB
        FROM MI_BANKZZ ZZ
       WHERE ZZ.BANKID = V_SMFID.SMFID
         AND ZZ.ZZDATE = V_CHKDATE;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  
    IF MB.DZNO IS NULL THEN
      --如果当日未扎帐则插入扎帐记录
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --对账编号 
        FROM DUAL;
      MB.BANKID := V_SMFID.SMFID; --银行编码 
      MB.ZZDATE := V_CHKDATE; --扎帐日期 
      MB.CZDATE := SYSDATE; --操作时间 
      MB.ZZFROM := 'S';--系统补扎
      INSERT INTO MI_BANKZZ VALUES MB;
    
      --更新实收记录,缴费日期截至至昨天，及扎帐日期
      UPDATE PAYMENT
         SET PCHKDATE = MB.ZZDATE, --对账日期
             PCHKNO   = MB.DZNO --进账单号
       WHERE PPOSITION = MB.BANKID
         AND PDATE <= V_CHKDATE --扎帐日期 
         AND PDATE >= TO_DATE('2016-03-31','YYYY-MM-DD')
         AND PCHKNO IS NULL;
    END IF;
  
  END LOOP;
  CLOSE C_BANKID;
  
  COMMIT;

END SP_AUTOBANKZZ_手动;

 --自动银行平账
PROCEDURE SP_AUTOBANKPZ(P_DATE IN DATE, P_SMFID IN VARCHAR2) AS

  CURSOR C_BANK_DZ(P_ID IN VARCHAR2) IS
    SELECT * FROM BANK_DZ_MX T WHERE T.ID = P_ID;

  V_CHKID   VARCHAR2(10);
  L_RESULT  NUMBER;
  V_COUNT   NUMBER;
  V_BANK_DZ BANK_DZ_MX%ROWTYPE;
  V_PATH    VARCHAR2(200);

BEGIN

  --检验是否有对账文件
  SELECT MAX(SMPPVALUE)
    INTO V_PATH
    FROM SYSMANAPARA
   WHERE SMPID = P_SMFID
     AND SMPPID = 'FTPDZDIR';

  SELECT COUNT(*)
    INTO V_COUNT
    FROM ENTRUSTFILE
   WHERE TO_DATE(SUBSTR(EFFILENAME, (F_GETPTYPE(EFFILENAME, '.') - 7), 8),
                 'YYYYMMDD') = P_DATE
     AND EFPATH = V_PATH;

  --如果无对账文件则当日不自动平账
  IF V_COUNT <= 0 THEN
    RETURN;
  END IF;

  --获取对账流水号
  SELECT T.ID
    INTO V_CHKID
    FROM BANKCHKLOG_NEW T
   WHERE TO_DATE(T.CHKDATE,'YYYYMMDD') = P_DATE
     AND BANKCODE = P_SMFID
     AND T.OKFLAG = 'N';

  OPEN C_BANK_DZ(V_CHKID);
  LOOP
    FETCH C_BANK_DZ
      INTO V_BANK_DZ;
    EXIT WHEN C_BANK_DZ%NOTFOUND OR C_BANK_DZ%NOTFOUND IS NULL;
    NULL;
    --自来水单边账
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '2' THEN
      L_RESULT := F_BANK_DISCHARGED(P_SMFID,
                                    V_BANK_DZ.CHARGENO,
                                    V_BANK_DZ.METERNO,
                                    V_BANK_DZ.TRANDATE);
      IF L_RESULT = 0 THEN
        --更新
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    
    END IF;
    --银行单边账
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '1' THEN
      L_RESULT := F_BANK_CHARGED_TOTAL(P_SMFID,
                                       'SYSTEM',
                                       V_BANK_DZ.METERNO,
                                       V_BANK_DZ.MONEY_BANK,
                                       '',
                                       P_DATE);
      IF L_RESULT = 0 THEN
        --更新
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    END IF;
    --正常账
    IF V_BANK_DZ.CZ_FLAG = 'Y' THEN
      UPDATE BANK_DZ_MX
         SET CHKDATE = SYSDATE
       WHERE ID = V_CHKID
         AND CHARGENO = V_BANK_DZ.CHARGENO;
    END IF;
  
  END LOOP;
  CLOSE C_BANK_DZ;

END SP_AUTOBANKPZ;

PROCEDURE SP_AUTOBANKPZ_test(P_DATE IN DATE, P_SMFID IN VARCHAR2) AS

  CURSOR C_BANK_DZ(P_ID IN VARCHAR2) IS
    SELECT * FROM BANK_DZ_MX T WHERE T.ID = P_ID;

  V_CHKID   VARCHAR2(10);
  L_RESULT  NUMBER;
  V_COUNT   NUMBER;
  V_BANK_DZ BANK_DZ_MX%ROWTYPE;
  V_PATH    VARCHAR2(200);
 -- P_DATE    DATE;
 -- P_SMFID   VARCHAR2(10);

BEGIN
 
 
  --检验是否有对账文件
  SELECT MAX(SMPPVALUE)
    INTO V_PATH
    FROM SYSMANAPARA
   WHERE SMPID = P_SMFID
     AND SMPPID = 'FTPDZDIR';

  SELECT COUNT(*)
    INTO V_COUNT
    FROM ENTRUSTFILE
   WHERE TO_DATE(SUBSTR(EFFILENAME, (F_GETPTYPE(EFFILENAME, '.') - 7), 8),
                 'YYYYMMDD') = P_DATE
     AND EFPATH = V_PATH;

  --如果无对账文件则当日不自动平账
  IF V_COUNT <= 0 THEN
    RETURN;
  END IF;

  --获取对账流水号
  SELECT T.ID
    INTO V_CHKID
    FROM BANKCHKLOG_NEW T
   WHERE /*TO_DATE(T.CHKDATE,'YYYYMMDD')*/ T.CHKDATE = P_DATE
     AND BANKCODE = P_SMFID
     --AND T.OKFLAG = 'N';
     AND T.OKFLAG = 'Y';

  OPEN C_BANK_DZ(V_CHKID);
  LOOP
    FETCH C_BANK_DZ
      INTO V_BANK_DZ;
    EXIT WHEN C_BANK_DZ%NOTFOUND OR C_BANK_DZ%NOTFOUND IS NULL;
    NULL;
    --自来水单边账
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '2' THEN
      L_RESULT := F_BANK_DISCHARGED(P_SMFID,
                                    V_BANK_DZ.CHARGENO,
                                    V_BANK_DZ.METERNO,
                                    V_BANK_DZ.TRANDATE);
      IF L_RESULT = 0 THEN
        --更新
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    
    END IF;
    --银行单边账
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '1' THEN
      L_RESULT := F_BANK_CHARGED_TOTAL(P_SMFID,
                                       'SYSTEM',
                                       V_BANK_DZ.METERNO,
                                       V_BANK_DZ.MONEY_BANK,
                                       '',
                                       P_DATE);
      IF L_RESULT = 0 THEN
        --更新
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    END IF;
    --正常账
    IF V_BANK_DZ.CZ_FLAG = 'Y' THEN
      UPDATE BANK_DZ_MX
         SET CHKDATE = SYSDATE
       WHERE ID = V_CHKID
         AND CHARGENO = V_BANK_DZ.CHARGENO;
    END IF;
  
  END LOOP;
  CLOSE C_BANK_DZ;

END SP_AUTOBANKPZ_test;

end ZHONGBE;
/

