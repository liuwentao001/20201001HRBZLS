CREATE OR REPLACE PACKAGE BODY HRBZLS."ZHONGBE" is

  /*----------------------------------------------------------------------
  Note:ҵ������ں���
  Input: p_in  -- �����
  Output:p_out -- ���ذ�
  Return: 000 --�ɹ�
          006 --��������
          022 --��������
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
    --��ִ̬��ҵ������̣����ز�����P_OUT
    --execute immediate sql_text;
    execute immediate sql_text
      using in p_in, in out p_out;
  
    --��¼��־
    --sp_tran_log(P_CODE, p_in, p_out);
    --��¼��־
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

  --�������з��ͱ����ֶ�
  function F_GET_HDTEXT(P_ROW IN VARCHAR2) return VARCHAR2 as
    v_TEXT VARCHAR2(400);
  begin
    SELECT C1 INTO v_TEXT FROM PACKETSHD WHERE TRIM(C2) = TRIM(P_ROW);
    return v_TEXT;
  end F_GET_HDTEXT;
  
    --�����м�����ͱ����ֶ�
  function F_GET_DTTEXT(P_ROW IN VARCHAR2) return VARCHAR2 as
    v_TEXT VARCHAR2(400);
  begin
    SELECT trim(substr(c1, (instr(c1, '|')+1),length(c1))) INTO v_TEXT FROM PACKETSDT WHERE TRIM(C2) = TRIM(P_ROW);
    return v_TEXT;
  end F_GET_DTTEXT;

  /*----------------------------------------------------------------------
  Note: 520����(Ƿ�����ϲ�ѯ)����
  Input: p_in  -- �����
  Output:
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure f520(p_in in arr, p_out in out arr) as
    pstep          number(10); --���������
    v_ccode        varchar2(30); --�ͻ���
    MI             METERINFO%rowtype; --�ͻ�����
    CI             custinfo%rowtype;
    v_cxyf         varchar2(6); --��ѯ�·�
    v_qfyf         varchar2(6); --Ƿ���·�
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --ʵ��Ӧ�ɽ��
    v_znj          number(10, 2); --ΥԼ��
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
  
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
    --Ƿ���α�
    cursor C_QFYF_LIST IS
      select RLID
        from (SELECT RLID AS RLID
                from RECLIST RL
                WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 ��¼�����ձ�ά��֮ǰ��δ����Ӧ�գ���ѯ������Ҫ���ǽ�ȥ
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
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------
  
    --��֯Ƿ������
    cursor c_ysmx IS
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�11
             to_char((chargetotal + chargeznj) * 100) xj, --С��12
             trim(f_getcardno(rlmid)) rlbfid, --�ʿ���13
              to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLSCODE))) RLSCODE, --����14
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --�ϴγ�������15
              to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLECODE))) RLECODE,  --ֹ��16
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --���ڳ�������17
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --ˮ�ѵ���һ��18
             to_char(USER_DJ2 * 100) USER_DJ2, --ˮ�ѵ��۶���19
             to_char(USER_DJ3 * 100) USER_DJ3, --ˮ�ѵ�������20
             to_char(dj2 * 100) dj2, --��ˮ����21
             to_char(decode(use_r1, 0, wateruse)) use_r1, --ˮ��һ��22
             to_char(use_r2) use_r2, --ˮ������23
             to_char(use_r3) use_r3, --ˮ������24
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --ˮ��һ��25
             to_char(charge_r2 * 100) charge_r2, --ˮ�Ѷ���26
             to_char(charge_r3 * 100) charge_r3, --ˮ������27
             to_char(charge2 * 100) charge2, --��ˮ���28
             to_char(chargeznj * 100) chargeznj, --ΥԼ��29
             '0' zjje, --׷�����30
             rlmid, --�ͻ�����31
             '' yl1, --Ԥ��1 32
             '' yl2, --Ԥ��1 33
             '' yl3, --Ԥ��1 34
             '' yl4 --Ԥ��1 35
        from reclist rl, view_reclist_charge_02 rd
       where rlid = rdid
         and rl.rlje > 0
         and rlbadflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'N'
         --and rl.rlprimcode = v_ccode
         and rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 ��¼�����ձ�ά��֮ǰ��δ����Ӧ�գ���ѯ������Ҫ���ǽ�ȥ
         and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or (v_cxyf = '000000'))
       order by rldate desc;
  
    v_ysmx c_ysmx%rowtype;
  
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    no_rec exception; --��Ƿ��
    rec_lock exception; --Ƿ�Ѽ�¼����
    rec_overflow exception; --Ƿ���·ݳ�����Ӧ��Ӫҵ���ɷ�
    znj exception; --��ΥԼ�𣬲��ܴ���
    no_user exception; --�޴��û�
  
    v_n     number(10);
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
  
  begin
    -------------------------20130912�޸ģ����м�¼�����޸�Ϊ6---------------------------
    v_jfsx := 6; --Ƿ���·�����
    -------------------------20130912�޸�end---------------------------
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 8 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 23 then
      raise err_format;
    end if;
  
    v_ccode := trim(F_GET_HDTEXT(7)); --�ͻ�����
  
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    v_cxyf := trim(F_GET_HDTEXT(8)); --�����·�
  
    -- STEP 1:ȡ�ͻ���������
    pstep := 1;
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --�ж��Ƿ������û�ZHW������ֵ˰�û����������нɷ�
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') or mi.MIIFTAX = 'Y' then
      raise no_user;
    end if;
  
    --�ж���һ��һ����һ�����
    if mi.mipriflag = 'N' then
      v_sbs := 1;
    else
      --��ֵ���������
      v_ccode := mi.mipriid;
      --��ѯ���ձ�����
      select nvl(count(t.micode), 1)
        into v_sbs
        from meterinfo t
       where t.mipriid = v_ccode;
      --����ȡ������������
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
    rcount := F_SET_TEXT(3, MI.micode); --����
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --����
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --����ַ
  
    --STEP 2: ���Ƿ�Ѽ�¼��
    pstep := 2;
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
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
      WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 ��¼�����ձ�ά��֮ǰ��δ����Ӧ�գ���ѯ������Ҫ���ǽ�ȥ
     --WHERE rl.RLMCODE = v_ccode
    -- WHERE rl.rlprimcode = v_ccode
       AND RL.RLJE > 0
       AND RL.RLPAIDFLAG = 'N'
          --AND RL.RLOUTFLAG = 'N'
       AND RL.RLREVERSEFLAG = 'N'
       AND RL.RLBADFLAG = 'N'
       and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or (v_cxyf = '000000'));
  
    --Ƿ���·���
    select count(rlid)
      into qfyf2_all
      from (select rlid
              from reclist rl
              WHERE rl.rlcid in (select miid from meterinfo where MIPRIID =v_ccode  ) --2010.10.27 ��¼�����ձ�ά��֮ǰ��δ����Ӧ�գ���ѯ������Ҫ���ǽ�ȥ
            --where RLMCODE = v_ccode
             --where rlprimcode = v_ccode
               AND RL.RLJE > 0
               AND RL.RLPAIDFLAG = 'N'
                  --AND RL.RLOUTFLAG = 'N'
               AND RL.RLREVERSEFLAG = 'N'
               AND RL.RLBADFLAG = 'N'
               and ((to_char(RLRDATE, 'YYYYMM') = v_cxyf) or
                   (v_cxyf = '000000')));
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------            
  
    --��¼��
    --���1����Ƿ�Ѽ�¼
    IF qfyf2_all = 0 THEN
      ---------------------------------����2����20130108 16��06�޸�-------------------------------------------------
      rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��
      rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --�ڳ�Ԥ��
      --STEP 4:
      pstep  := 4;
      v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
      --ʵ��Ӧ�ɽ��
      if v_yjje - MI.MISAVING > 0 then
        v_yjje := v_yjje - MI.MISAVING;
      else
        v_yjje := 0;
      end if;
      --Ӧ�ɽ��
      rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --Ӧ�ɽ��
    
      --�����һ��һ�����һ�����ˮ����ͬ
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --ȡˮ�ѵ��ۺ���ˮ�ѵ���
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
      
        rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --ˮ�ѵ���
        rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
        --���һ�����ˮ�۲�ͬ
      else
        rcount := F_SET_TEXT(9, '-'); --ˮ�ѵ���
        rcount := F_SET_TEXT(10, '-'); --��ˮ�ѵ���
      end if;
    
      -----------------------------------------20130110pxp�޸�---------------------------------------------------
      raise no_rec; --��Ƿ�Ѽ�¼��
    
      --���2����Ƿ�Ѽ�¼�����Ƿ�����־Ϊ'Y'
    elsif qfyf1 > 0 then
      raise rec_lock; --��Ƿ�Ѽ�¼���������۷���
    
      --���3����Ƿ�Ѽ�¼������δ����
    else
      --�ж����ʵ�ʱ��������������������¼��ȡ��������
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, v_jfsx); --��¼��  
      else
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��  
      end if;
    
      /*--20131212�ſ����ƣ�����6��Ҳ�������أ�����ֻȡ���6��
      -------------------------20130912�޸ģ���¼�������������ӵ���10---------------------------------
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��
        rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --�ڳ�Ԥ��
        v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
        --ʵ��Ӧ�ɽ��
        if v_yjje - MI.MISAVING > 0 then
          v_yjje := v_yjje - MI.MISAVING;
        else
          v_yjje := 0;
        end if;
        --Ӧ�ɽ��
        rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --Ӧ�ɽ��
      
        --�����һ��һ�����һ�����ˮ����ͬ
        if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
          --ȡˮ�ѵ��ۺ���ˮ�ѵ���
          select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
                 nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
            into v_sfdj, v_wsfdj
            from pricedetail pd
           where pd.pdpfid = mi.mipfid
           group by pd.pdpfid;
        
          rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --ˮ�ѵ���
          rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
          --���һ�����ˮ�۲�ͬ
        else
          rcount := F_SET_TEXT(9, '-'); --ˮ�ѵ���
          rcount := F_SET_TEXT(10, '-'); --��ˮ�ѵ���
        end if;
        raise rec_overflow;
        -------------------------20130912�޸�end---------------------------------
      else
        ---------�ĵ�����
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��
      end if;*/
    end if;
  
    --STEP 3: ȡԤ����
    pstep := 3;
    --Ԥ����ת��Ϊ�ַ���
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --�ڳ�Ԥ��
  
    --STEP 4:
    pstep  := 4;
    v_yjje := nvl(v_yjje, 0) + nvl(v_znj, 0);
    --ʵ��Ӧ�ɽ��
    if v_yjje - MI.MISAVING > 0 then
      v_yjje := v_yjje - MI.MISAVING;
    else
      v_yjje := 0;
    end if;
    --Ӧ�ɽ��
    rcount := F_SET_TEXT(8, to_char(v_yjje * 100)); --Ӧ�ɽ��
  
    --�����һ��һ�����һ�����ˮ����ͬ
    if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
      --ȡˮ�ѵ��ۺ���ˮ�ѵ���
      select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
             nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
        into v_sfdj, v_wsfdj
        from pricedetail pd
       where pd.pdpfid = mi.mipfid
       group by pd.pdpfid;
    
      rcount := F_SET_TEXT(9, to_char(v_sfdj * 100)); --ˮ�ѵ���
      rcount := F_SET_TEXT(10, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
      --���һ�����ˮ�۲�ͬ
    else
      rcount := F_SET_TEXT(9, '-'); --ˮ�ѵ���
      rcount := F_SET_TEXT(10, '-'); --��ˮ�ѵ���
    end if;
  
    --STEP 5:��֯Ƿ������
    pstep := 5;
    --���ݼ�¼������packetsDT����
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --���Ƿ�Ѽ�¼����6�ʣ���ֻ���������6����ϸ
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --����������  11-35ѭ��ȡֵ
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(11 + (v_n * 25), to_char(v_ysmx.month)); --���·�
      rcount := F_SET_TEXT(12 + (v_n * 25), to_char(v_ysmx.xj)); --С��
      rcount := F_SET_TEXT(13 + (v_n * 25), to_char(v_ysmx.rlbfid)); --�ʿ���
      rcount := F_SET_TEXT(14 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --����
      rcount := F_SET_TEXT(15 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --�ϴγ�������
      rcount := F_SET_TEXT(16 + (v_n * 25), to_char(v_ysmx.RLECODE)); --ֹ��
      rcount := F_SET_TEXT(17 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --���γ�������
      rcount := F_SET_TEXT(18 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --ˮ�ѵ��ۣ�һ�ף�
      rcount := F_SET_TEXT(19 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --ˮ�ѵ��ۣ����ף�
      rcount := F_SET_TEXT(20 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --ˮ�ѵ��ۣ����ף�
      rcount := F_SET_TEXT(21 + (v_n * 25), to_char(v_ysmx.dj2)); --��ˮ����ѵ���
      rcount := F_SET_TEXT(22 + (v_n * 25), to_char(v_ysmx.use_r1)); --ˮ����һ�ף�
      rcount := F_SET_TEXT(23 + (v_n * 25), to_char(v_ysmx.use_r2)); --ˮ�������ף�
      rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.use_r3)); --ˮ�������ף�
      rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.charge_r1)); --ˮ�ѣ�һ�ף�
      rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.charge_r2)); --ˮ�ѣ����ף�
      rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.charge_r3)); --ˮ�ѣ����ף�
      rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.charge2)); --��ˮ�����
      rcount := F_SET_TEXT(29 + (v_n * 25), to_char(v_ysmx.chargeznj)); --ΥԼ��
      rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.zjje)); --׷����
      rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.rlmid)); --�ͻ�����
      rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.yl1)); --Ԥ��
      rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.yl2)); --Ԥ��
      rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.yl3)); --Ԥ��
      rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.yl4)); --Ԥ��
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --�޴˿ͻ�
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
  Note: 521  ��ѯ�����¼
  Input: p_in  -- �����
  Output:
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure f521(p_in in arr, p_out in out arr) as
    pstep          number(10); --���������
    v_ccode       varchar2(30); --�ͻ���
    MI             METERINFO%rowtype; --�ͻ�����
    CI             custinfo%rowtype;
    v_cxyf         varchar2(6); --��ѯ�·�
    v_qfyf         varchar2(6); --Ƿ���·�
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --ʵ��Ӧ�ɽ��
    v_znj          number(10, 2); --ΥԼ��
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
    V_RLID         VARCHAR(10); --Ӧ����ˮ
    ---��ѯ�·�
    v_cxyf1 varchar2(6); --��ѯ��ʼ�·�
    v_cxyf2 varchar2(6); --��ѯ��ֹ�·�
  
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
    --Ƿ���α�
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
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------
  
    --��֯��������
    cursor c_ysmx IS
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�8
             to_char(chargetotal * 100) xj, --С��9
             trim(f_getcardno(rlmid)) rlbfid, --�ʿ���10
             to_char(decode(RLMSTATUS,'29','-','30','-',RLSCODE)) RLSCODE, --����11
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --�ϴγ�������12
             to_char(decode(RLMSTATUS,'29','-','30','-',RLECODE)) RLECODE, --ֹ��13
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --���ڳ�������14
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --ˮ�ѵ���һ��15
             to_char(USER_DJ2 * 100) USER_DJ2, --ˮ�ѵ��۶���16
             to_char(USER_DJ3 * 100) USER_DJ3, --ˮ�ѵ�������17
             to_char(dj2 * 100) dj2, --��ˮ����18
             to_char(decode(use_r1, 0, wateruse)) use_r1, --ˮ��һ��19
             to_char(use_r2) use_r2, --ˮ������20
             to_char(use_r3) use_r3, --ˮ������21
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --ˮ��һ��22
             to_char(charge_r2 * 100) charge_r2, --ˮ�Ѷ���23
             to_char(charge_r3 * 100) charge_r3, --ˮ������24
             to_char(charge2 * 100) charge2, --��ˮ���25
             '' yl1, --Ԥ��1 26
             '' yl2, --Ԥ��2 27
             '' yl3, --Ԥ��3 28
             '' yl4, --Ԥ��4 29
             '' yl5 --Ԥ��5 30
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
  
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    no_rec exception; --��Ƿ��
    rec_lock exception; --Ƿ�Ѽ�¼����
    rec_overflow exception; --Ƿ���·ݳ�����Ӧ��Ӫҵ���ɷ�
    znj exception; --��ΥԼ�𣬲��ܴ���
    no_user exception; --�޴��û�
  
    v_n     number(10);
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
  
  begin
    --------�����¼��ѯ��Ҫ�������𣿣�������------------------------
    v_jfsx := 6; --����
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 9 then
      raise err_format;
    end if;
  
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 29 then
      raise err_format;
    end if;
  
    --ȡ�ò�ѯ���·�
    v_cxyf1 := trim(F_GET_HDTEXT(8)); --��ʼ�����·�
    v_cxyf2 := trim(F_GET_HDTEXT(9)); --��ֹ�����·�
  
    -- STEP 1:ȡ�ͻ���������
    pstep   := 1;
    v_ccode := trim(F_GET_HDTEXT(7)); --�ͻ�����
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --�ж��Ƿ������û�
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
  
    --�ж���һ��һ����һ�����
    if mi.mipriflag = 'Y' then
      v_ccode := mi.mipriid;
      --����ȡ������������
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(3, v_ccode); --����
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --����
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --����ַ
  
    --STEP 2: ��鳭���¼��
    pstep := 2;
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
    --��¼��
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
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------
  
    --��¼��
    IF qfyf2_all = 0 THEN
      raise no_rec; --�޳����¼
      /*elsif qfyf2_all > v_jfsx then
      ---*** end ***---
      raise rec_overflow; --�����¼����*/
    end if;
  
    --�ж����ʵ�ʱ��������������������¼��ȡ��������
    if qfyf2_all > v_jfsx then
      rcount := F_SET_TEXT(6, v_jfsx); --��¼��  
    else
      rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��  
    end if;
  
    --STEP 3: ȡԤ����
    pstep := 3;
    --Ԥ����ת��Ϊ�ַ���
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --Ԥ��Ƿ�Ѽ�¼��
  
    --STEP 4:��֯��������
    pstep := 5;
    --���ݼ�¼������packetsDT����
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --����ɷѼ�¼��������ֻ���������6����ϸ
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --����������  8-30ѭ��ȡֵ
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(8 + (v_n * 23), to_char(v_ysmx.month)); --���·�
      rcount := F_SET_TEXT(9 + (v_n * 23), to_char(v_ysmx.xj)); --С��
      rcount := F_SET_TEXT(10 + (v_n * 23), to_char(v_ysmx.rlbfid)); --�ʿ���
      rcount := F_SET_TEXT(11 + (v_n * 23), to_char(v_ysmx.RLSCODE)); --����
      rcount := F_SET_TEXT(12 + (v_n * 23), to_char(v_ysmx.RLPRDATE)); --�ϴγ�������
      rcount := F_SET_TEXT(13 + (v_n * 23), to_char(v_ysmx.RLECODE)); --ֹ��
      rcount := F_SET_TEXT(14 + (v_n * 23), to_char(v_ysmx.RLRDATE)); --���γ�������
      rcount := F_SET_TEXT(15 + (v_n * 23), to_char(v_ysmx.USER_DJ1)); --ˮ�ѵ��ۣ�һ�ף�
      rcount := F_SET_TEXT(16 + (v_n * 23), to_char(v_ysmx.USER_DJ2)); --ˮ�ѵ��ۣ����ף�
      rcount := F_SET_TEXT(17 + (v_n * 23), to_char(v_ysmx.USER_DJ3)); --ˮ�ѵ��ۣ����ף�
      rcount := F_SET_TEXT(18 + (v_n * 23), to_char(v_ysmx.dj2)); --��ˮ����ѵ���
      rcount := F_SET_TEXT(19 + (v_n * 23), to_char(v_ysmx.use_r1)); --ˮ����һ�ף�
      rcount := F_SET_TEXT(20 + (v_n * 23), to_char(v_ysmx.use_r2)); --ˮ�������ף�
      rcount := F_SET_TEXT(21 + (v_n * 23), to_char(v_ysmx.use_r3)); --ˮ�������ף�
      rcount := F_SET_TEXT(22 + (v_n * 23), to_char(v_ysmx.charge_r1)); --ˮ�ѣ�һ�ף�
      rcount := F_SET_TEXT(23 + (v_n * 23), to_char(v_ysmx.charge_r2)); --ˮ�ѣ����ף�
      rcount := F_SET_TEXT(24 + (v_n * 23), to_char(v_ysmx.charge_r3)); --ˮ�ѣ����ף�
      rcount := F_SET_TEXT(25 + (v_n * 23), to_char(v_ysmx.charge2)); --��ˮ�����
      rcount := F_SET_TEXT(26 + (v_n * 23), to_char(v_ysmx.yl1)); --Ԥ��
      rcount := F_SET_TEXT(27 + (v_n * 23), to_char(v_ysmx.yl2)); --Ԥ��
      rcount := F_SET_TEXT(28 + (v_n * 23), to_char(v_ysmx.yl3)); --Ԥ��
      rcount := F_SET_TEXT(29 + (v_n * 23), to_char(v_ysmx.yl4)); --Ԥ��
      rcount := F_SET_TEXT(30 + (v_n * 23), to_char(v_ysmx.yl5)); --Ԥ��
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --�޴˿ͻ�
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
  Note: 522   ��ѯʵ����Ϣ
  Input: p_in  -- �����
  Output:
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure f522(p_in in arr, p_out in out arr) as
    pstep          number(10); --���������
    v_ccode        varchar2(30); --�ͻ���
    MI             METERINFO%rowtype; --�ͻ�����
    CI             custinfo%rowtype;
    PM             PAYMENT%ROWTYPE;
    v_cxyf         varchar2(8); --��ѯ�·�
    v_qfyf         varchar2(8); --Ƿ���·�
    rcount         number(10);
    qfyf1          number(10);
    qfyf2          number(10);
    cqts           number(10);
    v_yjje         number(10, 2); --ʵ��Ӧ�ɽ��
    v_znj          number(10, 2); --ΥԼ��
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
    V_pid          VARCHAR(10); --ʵ����ˮ
    ---��ѯ�·�
    v_cxyf1 varchar2(8); --��ѯ��ʼ�·�
    v_cxyf2 varchar2(8); --��ѯ��ֹ�·�
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    --Ƿ���α�
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
  
    --ʵ�ռ�¼��ϸ
    cursor c_ysmx is
      select rank() over(partition by ppriid order by pdate desc) vnum,
             to_char(pm.pdate, 'YYYYMMDD') pdate, --�������� 8
             pm.ppayment, --���ѽ�� 9
             f_getpayway(pm.ppayway) ppayway, --�۷����� 10
             pm.psavingqc, --�ڳ�Ԥ�� 11
             pm.psavingbq, --���ڷ���
             pm.psavingqm, --��ĩԤ�� 12
             pm.pposition --���ѵص� 13
        from payment pm
       WHERE pm.pflag = 'Y'
         and pm.preverseflag = 'N' --�ƻ��ڳ���
         and PM.PPRIID = v_ccode
         and to_char(PM.Pdate, 'YYYYMMDD') > = v_cxyf1
         and to_char(PM.Pdate, 'YYYYMMDD') <= v_cxyf2
       order by pm.pdate desc;
  
    v_ysmx c_ysmx%rowtype;
  
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    no_rec exception; --��Ƿ��
    rec_lock exception; --Ƿ�Ѽ�¼����
    rec_overflow exception; --Ƿ���·ݳ�����Ӧ��Ӫҵ���ɷ�
    znj exception; --��ΥԼ�𣬲��ܴ���
    no_user exception; --�޴��û�
  
    v_n     number(10);
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
  
  begin
    ----------����������������------------
    v_jfsx := 6; --����
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 9 then
      raise err_format;
    end if;
  
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 33 then
      raise err_format;
    end if;
  
    --ȡ�ò�ѯ��ʱ����
    v_cxyf1 := trim(F_GET_HDTEXT(8)); --��ʼ��������
    v_cxyf2 := trim(F_GET_HDTEXT(9)); --��ֹ��������
  
    -- STEP 1:ȡ�ͻ���������
    pstep   := 1;
    v_ccode := trim(F_GET_HDTEXT(7));
    if length(v_ccode) = 14 then
      v_ccode := substr(v_ccode, 4, 1) || substr(v_ccode, 5, 2) ||
                 substr(v_ccode, 8, 1) || substr(v_ccode, 9, 6);
    end if;
  
    select t.* into MI from METERINFO t where t.micode = v_ccode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    --�ж��Ƿ������û�
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
  
    --�ж���һ��һ����һ�����
    if mi.mipriflag = 'Y' then
      v_ccode := mi.mipriid;
      --����ȡ������������
      select t.* into MI from METERINFO t where t.micode = v_ccode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    rcount := F_SET_TEXT(3, v_ccode); --����
    v_mame := substr(CI.ciname, 1, 60);
    rcount := F_SET_TEXT(4, v_mame); --����
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(5, v_addr); --����ַ
  
    --STEP 2: ���Ƿ�Ѽ�¼��
    pstep := 2;
  
    --��¼��
    select count(pid)
      into qfyf2_all
      from (select pm.pid pid
              from payment pm
             WHERE PM.PPRIID = v_ccode
               AND PM.PFLAG = 'Y'
               AND PM.PREVERSEFLAG = 'N'
               and to_char(PM.Pdate, 'YYYYMMDD') > = v_cxyf1
               and to_char(PM.Pdate, 'YYYYMMDD') <= v_cxyf2);
  
    --��¼��
    IF qfyf2_all = 0 THEN
      raise no_rec; --�޼�¼��
    
      /*elsif qfyf2_all > v_jfsx then
      ---*** end ***---
      raise rec_overflow; --��¼������*/
    else
      --�ж����ʵ�ʱ��������������������¼��ȡ��������
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(6, v_jfsx); --��¼��  
      else
        rcount := F_SET_TEXT(6, to_char(qfyf2_all)); --��¼��  
      end if;
    end if;
  
    --STEP 3: ȡԤ����
    pstep := 3;
    --Ԥ����ת��Ϊ�ַ���
    rcount := F_SET_TEXT(7, to_char(MI.MISAVING * 100)); --Ԥ��Ƿ�Ѽ�¼��
  
    --STEP 4:��֯ʵ������
    pstep := 5;
  
    --���ݼ�¼������packetsDT����
    if qfyf2_all <= v_jfsx then
      sp_extensiondata(qfyf2_all);
    else
      --����ɷѼ�¼��������ֻ���������3����ϸ
      sp_extensiondata(v_jfsx);
    end if;
    v_n := 0;
    --����������  8-13ѭ��ȡֵ
    open c_ysmx;
    loop
      fetch c_ysmx
        into v_ysmx;
      exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
      rcount := F_SET_TEXT(8 + (v_n * 6), to_char(v_ysmx.pdate)); --��������
      rcount := F_SET_TEXT(9 + (v_n * 6), to_char(v_ysmx.ppayment * 100)); --���ѽ��
      rcount := F_SET_TEXT(10 + (v_n * 6), v_ysmx.ppayway); --�۷�����
      rcount := F_SET_TEXT(11 + (v_n * 6), to_char(v_ysmx.psavingqc * 100)); --�ڳ�Ԥ��
      rcount := F_SET_TEXT(12 + (v_n * 6), to_char(v_ysmx.psavingqm * 100)); --��ĩԤ��
      rcount := F_SET_TEXT(13 + (v_n * 6), v_ysmx.pposition); --���ѵص�
      v_n    := v_n + 1;
    end loop;
    close c_ysmx;
  
  exception
    when err_format then
      rcount := F_SET_TEXT(2, '020');
    when no_data_found then
      if pstep = 1 then
        --�޴˿ͻ�
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
  Note: ��֯һ���µ�Ƿ������
  Input: p_qf
  Output:p_qf
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure sp_qf_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm     VARCHAR2(10);
    v_zm     VARCHAR2(10);
    v_sl     number(10);
    v_jtsl01 number(12, 2); ---����ˮ��1
    v_jtsl02 number(12, 2); ---����ˮ��2
    v_jtsl03 number(12, 2); ---����ˮ��3
  
    v_dj01   number(12, 2); --ˮ��01
    v_jtdj01 number(12, 2); ---����ˮ��1
    v_jtdj02 number(12, 2); ---����ˮ��2
    v_jtdj03 number(12, 2); ---����ˮ��3
  
    v_dj02 number(12, 2); --ˮ��02
    v_dj03 number(12, 2); --ˮ��03
    v_dj04 number(12, 2); --ˮ��04
    v_dj05 number(12, 2); --ˮ��05
  
    v_sf01   number(10, 2); --ˮ��01
    v_jtsf01 number(12, 2); ---����ˮ��1
    v_jtsf02 number(12, 2); ---����ˮ��2
    v_jtsf03 number(12, 2); ---����ˮ��3
    v_sf02   number(10, 2); --ˮ��02
    v_sf03   number(10, 2); --ˮ��03
    v_sf04   number(10, 2); --ˮ��04
    v_sf05   number(10, 2); --ˮ��05
  
    v_ljf   number(10, 2); --������
    v_zys   number(10, 2); --��Ӧ��
    v_znj   number(10, 2); --ΥԼ��
    rcount  number(10);
    v_ysxz  varchar2(20); --��ˮ����
    v_sqcbr varchar2(8);
    v_bqcbr varchar2(8);
    v_bkh   varchar2(14);
  begin
    ----�����ܽ��  ���롢ֹ�룬ֻȡ�ƻ��ڳ����¼�����롢ֹ��
    --ˮ�ۡ���ϵ����ˮ�� ��ˮ��Դ�ۡ�ˮ��  ����ˮ�ѡ�ˮ��Դ��
    --ˮ��
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
            -- AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --ָ���·�
         AND RL.RLJE > 0
         AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --�ƻ��ڳ���
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
    --������
  
    v_sl := nvl(v_sl, 0);
    --���ɽ�׷���ѡ��ɷѽ�Ԥ�����
    --�������ݰ�
    v_zys := v_sf02 + v_znj + v_jtsf01 + v_jtsf02 + v_jtsf03; --������Ӧ��
  
    --������
    v_ljf := v_ljf;
  
    --������Ҫ���룬����δ���ǵ��ۻ�������λС��ʱ*100���λ���һλС����ʱ��
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_zys * 100), 10, ' '); --����Ƿ���ܽ��                
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --���ڳ�����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --ֹ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --���ڳ�����
  
    ---ˮ�۵����
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --ˮ��02
    --ˮ�������
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jtˮ��03
  
    --ˮ�ѵ����
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --ˮ��02 
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_znj * 100), 10, ' '); --ΥԼ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --׷����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��1  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��2 
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��3                                    
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��4
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��5
  end;

  /*----------------------------------------------------------------------
  Note: ��֯һ��Ӧ�ռ�¼����
  Input: p_qf
  Output:p_qf
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure sp_ysjl_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---����ˮ��1
    v_jtsl02 number(12, 2); ---����ˮ��2
    v_jtsl03 number(12, 2); ---����ˮ��3
  
    v_dj01   number(12, 2); --ˮ��01
    v_jtdj01 number(12, 2); ---����ˮ��1
    v_jtdj02 number(12, 2); ---����ˮ��2
    v_jtdj03 number(12, 2); ---����ˮ��3
  
    v_dj02 number(12, 2); --ˮ��02
    v_dj03 number(12, 2); --ˮ��03
    v_dj04 number(12, 2); --ˮ��04
    v_dj05 number(12, 2); --ˮ��05
    v_dj06 number(12, 2); --ˮ��06
    v_dj07 number(12, 2); --ˮ��07
    v_dj08 number(12, 2); --ˮ��08
  
    v_sf01   number(10, 2); --ˮ��01
    v_jtsf01 number(12, 2); ---����ˮ��1
    v_jtsf02 number(12, 2); ---����ˮ��2
    v_jtsf03 number(12, 2); ---����ˮ��3
    v_sf02   number(10, 2); --ˮ��02
    v_sf03   number(10, 2); --ˮ��03
    v_sf04   number(10, 2); --ˮ��04
    v_sf05   number(10, 2); --ˮ��05
    v_sf06   number(10, 2); --ˮ��06
    v_sf07   number(10, 2); --ˮ��07
    v_sf08   number(10, 2); --ˮ��08
  
    v_ljf   number(10, 2); --������
    v_zys   number(10, 2); --��Ӧ��
    v_znj   number(10, 2); --ΥԼ��
    rcount  number(10);
    v_bkh   varchar2(20);
    v_sqcbr varchar2(8);
    v_bqcbr varchar2(8);
  begin
    ----�����ܽ��  ���롢ֹ�룬ֻȡ�ƻ��ڳ����¼�����롢ֹ��
    --ˮ�ۡ���ϵ����ˮ�� ��ˮ��Դ�ۡ�ˮ��  ����ˮ�ѡ�ˮ��Դ��
    --ˮ��
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
            --  AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --ָ���·�
         AND RL.RLJE > 0
            -- AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --�ƻ��ڳ���
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
    --������
  
    v_sl := nvl(v_sl, 0);
    --���ɽ�׷���ѡ��ɷѽ�Ԥ�����
    --�������ݰ�
    v_zys := v_sf02 + v_jtsf01 + v_jtsf02 + v_jtsf03; --������Ӧ��
  
    --������
    v_ljf := v_ljf;
  
    --������Ҫ���룬����δ���ǵ��ۻ�������λС��ʱ*100���λ���һλС����ʱ��
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(v_zys, 0) * 100), 10, ' '); --����Ƿ���ܽ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --���ڳ�����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --ֹ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --���ڳ�����
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --ˮ��02
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jtˮ��03
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jtˮ��03             
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --ˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��4  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��5
  
  end;

  /*----------------------------------------------------------------------
  Note: ��֯һ��ʵ�ռ�¼����
  Input: p_qf
  Output:p_qf
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure sp_ssjl_month(p_qf in out arr, p_pid in varchar2) as
  
    v_pparment  number(12, 2);
    v_ppayway   varchar2(10);
    v_psavingqc number(12, 2);
    v_psavingbq number(12, 2);
    v_psavingqm number(12, 2);
    v_pposition varchar2(10);
  
  begin
    ----�����ܽ��  ���롢ֹ�룬ֻȡ�ƻ��ڳ����¼�����롢ֹ��
    --ˮ�ۡ���ϵ����ˮ�� ��ˮ��Դ�ۡ�ˮ��  ����ˮ�ѡ�ˮ��Դ��
    --ˮ��
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
         and pm.preverseflag = 'N'; --�ƻ��ڳ���
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
  
    --������Ҫ���룬����δ���ǵ��ۻ�������λС��ʱ*100���λ���һλС����ʱ��
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_pparment * 100), 10, ' '); --���ѽ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_ppayway, 20, ' '); ---�۷����� 
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_psavingqc * 100), 10, ' '); --���ѽ��
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_psavingqm * 100), 10, ' '); --12  ��δԤ��  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_pposition, 20, ' '); ---�۷�����                    
  end;

  /*----------------------------------------------------------------------
  Note: ��֯һ��Ӧ�ռ�¼����(����)
  Input: p_qf
  Output:p_qf
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure sp_ssjy_month(p_qf in out arr, p_rlid in varchar2) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---����ˮ��1
    v_jtsl02 number(12, 2); ---����ˮ��2
    v_jtsl03 number(12, 2); ---����ˮ��3
  
    v_dj01   number(12, 2); --ˮ��01
    v_jtdj01 number(12, 2); ---����ˮ��1
    v_jtdj02 number(12, 2); ---����ˮ��2
    v_jtdj03 number(12, 2); ---����ˮ��3
  
    v_dj02 number(12, 2); --ˮ��02
    v_dj03 number(12, 2); --ˮ��03
    v_dj04 number(12, 2); --ˮ��04
    v_dj05 number(12, 2); --ˮ��05
    v_dj06 number(12, 2); --ˮ��06
    v_dj07 number(12, 2); --ˮ��07
    v_dj08 number(12, 2); --ˮ��08
  
    v_sf01   number(10, 2); --ˮ��01
    v_jtsf01 number(12, 2); ---����ˮ��1
    v_jtsf02 number(12, 2); ---����ˮ��2
    v_jtsf03 number(12, 2); ---����ˮ��3
    v_sf02   number(10, 2); --ˮ��02
    v_sf03   number(10, 2); --ˮ��03
    v_sf04   number(10, 2); --ˮ��04
    v_sf05   number(10, 2); --ˮ��05
    v_sf06   number(10, 2); --ˮ��06
    v_sf07   number(10, 2); --ˮ��07
    v_sf08   number(10, 2); --ˮ��08
  
    v_ljf     number(10, 2); --������
    v_zys     number(10, 2); --��Ӧ��
    v_znj     number(10, 2); --ΥԼ��
    rcount    number(10);
    v_bkh     varchar2(20);
    v_sqcbr   varchar2(8);
    v_bqcbr   varchar2(8);
    v_rlmcode varchar2(10);
  begin
    ----�����ܽ��  ���롢ֹ�룬ֻȡ�ƻ��ڳ����¼�����롢ֹ��
    --ˮ�ۡ���ϵ����ˮ�� ��ˮ��Դ�ۡ�ˮ��  ����ˮ�ѡ�ˮ��Դ��
    --ˮ��
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
            --  AND to_char(RL.RLRDATE, 'YYYYMM') = p_qf(p_qf.last) --ָ���·�
         AND RL.RLJE > 0
            -- AND RL.RLPAIDFLAG = 'N'
            --AND RL.RLOUTFLAG = 'N'
         AND RLREVERSEFLAG = 'N'
         AND RLBADFLAG = 'N'
       group by to_char(RL.RLRDATE, 'YYYYMM'), rlid, rlgroup, RLSMFID; --�ƻ��ڳ���
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
    --������
  
    v_sl  := nvl(v_sl, 0);
    v_znj := nvl(v_znj, 0);
    --���ɽ�׷���ѡ��ɷѽ�Ԥ�����
    --�������ݰ�
    v_zys := v_sf02 + v_jtsf01 + v_jtsf02 + v_jtsf03 + v_znj; --������Ӧ��
  
    --������
    v_ljf := v_ljf;
  
    --������Ҫ���룬����δ���ǵ��ۻ�������λС��ʱ*100���λ���һλС����ʱ��
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(v_zys, 0) * 100), 10, ' '); --����Ƿ���ܽ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bkh, 14, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_qm), 10, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_sqcbr, 8, ' '); --���ڳ�����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_zm), 10, ' '); --ֹ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_bqcbr, 8, ' '); --���ڳ�����
  
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtdj03 * 100), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_dj02 * 100), 10, ' '); --ˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl01), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl02), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(v_jtsl03), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf01 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf02 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_jtsf03 * 100), 10, ' '); --jtˮ��03             
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_sf02 * 100), 10, ' '); --ˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(v_znj * 100), 10, ' '); --ΥԼ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --׷����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(v_rlmcode, 14, ' '); --����                                             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��4  
  
  end;
  /*----------------------------------------------------------------------
  Note: ��֯һ��Ӧ�ռ�¼����(����)
  Input: p_qf
  Output:p_qf
  Return:���ذ�
  ----------------------------------------------------------------------*/
  procedure sp_ssyc_month(p_qf in out arr) as
    v_meteno varchar2(10);
    v_smonth varchar2(7);
    v_emonth varchar2(7);
  
    v_qm VARCHAR2(10);
    v_zm VARCHAR2(10);
    v_sl number(10);
  
    v_jtsl01 number(12, 2); ---����ˮ��1
    v_jtsl02 number(12, 2); ---����ˮ��2
    v_jtsl03 number(12, 2); ---����ˮ��3
  
    v_dj01   number(12, 2); --ˮ��01
    v_jtdj01 number(12, 2); ---����ˮ��1
    v_jtdj02 number(12, 2); ---����ˮ��2
    v_jtdj03 number(12, 2); ---����ˮ��3
  
    v_dj02 number(12, 2); --ˮ��02
    v_dj03 number(12, 2); --ˮ��03
    v_dj04 number(12, 2); --ˮ��04
    v_dj05 number(12, 2); --ˮ��05
    v_dj06 number(12, 2); --ˮ��06
    v_dj07 number(12, 2); --ˮ��07
    v_dj08 number(12, 2); --ˮ��08
  
    v_sf01   number(10, 2); --ˮ��01
    v_jtsf01 number(12, 2); ---����ˮ��1
    v_jtsf02 number(12, 2); ---����ˮ��2
    v_jtsf03 number(12, 2); ---����ˮ��3
    v_sf02   number(10, 2); --ˮ��02
    v_sf03   number(10, 2); --ˮ��03
    v_sf04   number(10, 2); --ˮ��04
    v_sf05   number(10, 2); --ˮ��05
    v_sf06   number(10, 2); --ˮ��06
    v_sf07   number(10, 2); --ˮ��07
    v_sf08   number(10, 2); --ˮ��08
  
    v_ljf     number(10, 2); --������
    v_zys     number(10, 2); --��Ӧ��
    v_znj     number(10, 2); --ΥԼ��
    rcount    number(10);
    v_bkh     varchar2(20);
    v_sqcbr   varchar2(8);
    v_bqcbr   varchar2(8);
    v_rlmcode varchar2(10);
  begin
    ----�����ܽ��  ���롢ֹ�룬ֻȡ�ƻ��ڳ����¼�����롢ֹ��
    --ˮ�ۡ���ϵ����ˮ�� ��ˮ��Դ�ۡ�ˮ��  ����ˮ�ѡ�ˮ��Դ��
    --ˮ��
  
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
  
    --������
  
    --������Ҫ���룬����δ���ǵ��ۻ�������λС��ʱ*100���λ���һλС����ʱ��
    p_qf(p_qf.last) := p_qf(p_qf.last) ||
                       rpad(to_char(nvl(0, 0) * 100), 10, ' '); --����Ƿ���ܽ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 14, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 8, ' '); --���ڳ�����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --ֹ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 8, ' '); --���ڳ�����
  
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --ˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --jtˮ��03
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��01
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --jtˮ��03             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --ˮ��02
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0 * 100), 10, ' '); --ΥԼ��
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --׷����
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(0, 14, ' '); --����                                             
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��1
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��2
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��3
    p_qf(p_qf.last) := p_qf(p_qf.last) || rpad(to_char(0), 10, ' '); --Ԥ��4  
  
  end;
  /*----------------------------------------------------------------------
  Note: 600 ����Ԥ�潻�״���
  Input: p_bankid -- ���б���
         p_chgno  -- ������ˮ
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f600(p_in in arr, p_out in out arr) as
    pstep number(10); --���������
  
    p_bankid varchar2(20);
    p_chgno  varchar2(30);
  
    v_ccode varchar2(30); --ˮ�����Ϻ�
  
    v_chg_total number(10, 2); --�ɷѽ��
    v_chg_op    varchar2(20); --�ɷ�Ա
  
    v_chgno     varchar(20); --ƾ֤��ˮ
    v_discharge number(10, 2); --���νɷѵֿ۽��
    v_curr_sav  number(10, 2); --���νɷѺ�Ԥ����
    /*   v_bankid    varchar2(10);*/
    v_bankcode varchar2(10);
    rcount     number(10);
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_charge exception; --�ɷѴ���
  begin
  
    /*   if p_in.count<>8 then
       raise err_format;
    end if;*/
    --Ԥ�����������1��2��Ԫ
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
  Note: 540�ɷѽ��״���
  Input: p_bankid -- ���б���
         p_chgno  -- ������ˮ
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
 /* procedure f540(p_in in arr, p_out in out arr) as
  
    pstep      number(10); --���������
    v_retstr   varchar2(10); --���ؽ��
    V_OUTCOUNT NUMBER(10);
    V_RLIDS    VARCHAR2(20000); --Ӧ����ˮ
    V_RLJE     NUMBER(12, 2); --Ӧ�ս��
    V_ZNJ      NUMBER(12, 2); --���ɽ�
  
    v_LJFJE     NUMBER(12, 2); --�����ѽ��
    v_RLIDS_LJF VARCHAR2(20000); --������Ӧ����ˮ
    v_out_LJFJE NUMBER(12, 2); --���������ʽ��
  
    v_SXF NUMBER(12, 2); --//������
  
    v_POSITION  varchar2(10); -- //�ɷѻ���-
    v_OPER      payment.pper%type; --//�տ�Ա
    v_ptrans    payment.ptrans%type; --//�տ�Ա
    v_mcode     varchar2(30); --  --�ͻ�����
    mi          meterinfo%rowtype;
    CI          CUSTINFO%ROWTYPE;
    v_chgno     payment.PBSEQNO%type; -- --������ˮ
    v_pbatch    payment.pbatch%type; -- --��������
    v_chg_op    payment.pper%type;
    v_PAYJE     number(10, 2); --�ɷѽ��
    v_discharge number(10, 2); --���νɷѵֿ۽��
    v_curr_sav  number(10, 2); --���νɷѺ�Ԥ����
    v_fppc      varchar2(14); ---��Ʊ����
    v_fpno      varchar2(10); ---��Ʊ����
    v_paypoint  varchar2(20); ---�ɷѷ�֧����
    v_pdate     varchar2(14); ---����ʱ��
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
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    ---- �����α�
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
  
    --ʵ�ս�����Ӧ��ѭ��������ϸ
    cursor c_ysmx is
      select rank() over(partition by rlprimcode order by rldate desc) vnum,
             substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�20
             to_char((chargetotal + chargeznj) * 100) xj, --С��21
             trim(f_getcardno(rlmid)) rlbfid, --�ʿ���22
             to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLSCODE))) RLSCODE, --����23
             TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --�ϴγ�������24
             to_char(decode(FGETIFDZSB(rlmid),'Y','-',decode(RLMSTATUS,'29','-','30','-',RLECODE))) RLECODE, --ֹ��25
             TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --���ڳ�������26
             to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --ˮ�ѵ���һ��27
             to_char(USER_DJ2 * 100) USER_DJ2, --ˮ�ѵ��۶���28
             to_char(USER_DJ3 * 100) USER_DJ3, --ˮ�ѵ�������29
             to_char(dj2 * 100) dj2, --��ˮ����30
             to_char(decode(use_r1, 0, wateruse)) use_r1, --ˮ��һ��31
             to_char(use_r2) use_r2, --ˮ������32
             to_char(use_r3) use_r3, --ˮ������33
             to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --ˮ��һ��34
             to_char(charge_r2 * 100) charge_r2, --ˮ�Ѷ���35
             to_char(charge_r3 * 100) charge_r3, --ˮ������36
             to_char(charge2 * 100) charge2, --��ˮ���37
             to_char(chargeznj * 100) chargeznj, --ΥԼ��38
             '0' zjje, --׷�����39
             rlmid, --�ͻ�����40
             '' yl1, --Ԥ��1 41
             '' yl2, --Ԥ��1 42
             '' yl3, --Ԥ��1 43
             '' yl4 --Ԥ��1 44
        from reclist rl, view_reclist_charge_02 rd, payment pm
       where rl.rlpid = pm.pid
         and rlid = rdid
         and pm.preverseflag = 'N'
         and rl.rlreverseflag = 'N'
         and rl.rlpaidflag = 'Y'
         and pm.pbseqno = v_chgno
         and pm.ppriid = v_mcode
       order by rldate desc;
  
    -----------------------20130923 ����Ԥ��----------------------------
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
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_charge exception; --�ɷѴ���
    err_je exception; --����
    err_nouser exception; --�û�������
    err_clockje exception; --003����¼����������ת��ʵʱ��ʽ����
    err_other exception; --
    err_exist exception;
    rec_overflow exception; --Ƿ���·ݳ�����Ӧ��Ӫҵ���ɷ�
    no_user exception; --�޴��û�
    
    err_ymsz exception; --��ĩ����
    v_bankid  varchar2(10);  --���з�֧����
    
    v_b       number(10);
    v_e       number(10);
    v_n       number(10);
    v_count   number(10); --���װ��ֶ���
    v_inlen   number(10); --���װ�������
    v_seqno   payment.PBSEQNO%type; -- --������ˮ
    v_pbseqno number(10); --У��������ˮ
  
  begin
    \*--����Ƿ����ѭ��
    SELECT to_number(nvl(c2,'0')) into v_b FROM packetsDT WHERE C3='b';
    SELECT to_number(nvl(c2,'0')) into v_e FROM packetsDT WHERE C3='b';*\
    --��ȡѭ������
    v_jfsx := 6; --����
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 13 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 93 then
      raise err_format;
    end if;
    
    --�ж��Ƿ�����ĩ����
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
      v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
      if F_GETBANKSYSPARA(v_bankid)='N' then
         raise err_ymsz;
      end if;
    --end if;
    
    --У������540������ˮ�Ƿ��Ѵ���
    v_pbseqno := 0;
    v_seqno   := trim(F_GET_HDTEXT(4)); --������ˮ
    select count(*) into v_pbseqno from payment where pbseqno = v_seqno;
    if v_pbseqno > 0 then
      raise err_exist;
    end if;
  
    v_mcode := trim(F_GET_HDTEXT(7)); --�ͻ�����
    if length(v_mcode) = 14 then
      v_mcode := substr(v_mcode, 4, 1) || substr(v_mcode, 5, 2) ||
                 substr(v_mcode, 8, 1) || substr(v_mcode, 9, 6);
    end if;
  
    v_paypoint := trim(F_GET_HDTEXT(10)); --���з�֧����
    v_pdate    := trim(F_GET_HDTEXT(11)); --�ɷ�ʱ��
    v_fppc     := trim(F_GET_HDTEXT(12)); --��Ʊ����
    v_fpno     := trim(F_GET_HDTEXT(13)); --��Ʊ��
  
    ---ȡ�������Ϣ��
    select t.* into MI from METERINFO t where t.micode = v_mcode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
    
    --�ж��Ƿ������û�
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
      --����ȡ������������
      select t.* into MI from METERINFO t where t.micode = v_mcode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
    --ͳ��Ƿ�Ѽ�¼��
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
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------
  
    --�����޶����� ���ýɷѷ���023����
    if qfyf2_all > v_jfsx then
      null;
      --raise rec_overflow;  --20131212�ſ����ƣ�����6��Ҳ���Խɷ�
    end if;
  
    v_POSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_OPER     := trim(F_GET_HDTEXT(9));
  
    v_PAYJE  := to_number(F_GET_HDTEXT(8)) / 100; --�ɷѽ��
    v_chgno  := trim(F_GET_HDTEXT(4)); --������ˮ
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
      --�û�������
      raise err_nouser;
    elsif v_retstr = '003' then
      --����
      raise err_clockje;
    elsif v_retstr = '005' then
      --����
      raise err_je;
    elsif v_retstr = '021' then
      raise err_other;
    end if;
  
    rcount := F_SET_TEXT(3, to_char(v_PAYJE * 100)); --���νɷѽ��
    rcount := F_SET_TEXT(4, to_char(v_sbs)); --�û�����
    rcount := F_SET_TEXT(5, MI.micode); --�ͻ�����
    v_mame := substr(MI.MINAME, 1, 60);
    rcount := F_SET_TEXT(6, v_mame); --����
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(7, v_addr); --����ַ
    rcount := F_SET_TEXT(8, v_chgno); --ƾ֤��ˮ
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    --��Ƿ�ѣ�ʵ�ս���
    if qfyf2_all > 0 then
      ----ȡ������Ϣ��
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
      ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
    
      --------20130912 �����ʵ�ս��ף����ֶ�ΪӦ��ˮ���������Ԥ�潻�ף����ֶ�Ϊ��ǰ��ʾ��----------
      rcount := F_SET_TEXT(9, to_char(v_sl)); --Ӧ��ˮ��
      --------------------------end ----------------------------------------------------
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --�����һ��һ�����һ�����ˮ����ͬ
        --ȡˮ�ѵ��ۺ���ˮ�ѵ���
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --ˮ�ѵ���
        rcount := F_SET_TEXT(11, to_char(v_sf * 100)); --ˮ�Ѻϼ�
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
        rcount := F_SET_TEXT(13, to_char(v_wsf * 100)); --��ˮ�Ѻϼ�
      else
        --���һ�����ˮ�۲�ͬ
        rcount := F_SET_TEXT(10, '-'); --ˮ�ѵ���
        rcount := F_SET_TEXT(11, '-'); --ˮ�Ѻϼ�
        rcount := F_SET_TEXT(12, '-'); --��ˮ�ѵ���
        rcount := F_SET_TEXT(13, '-'); --��ˮ�Ѻϼ�
      end if;
    
      rcount := F_SET_TEXT(14, to_char(v_ssznj * 100)); --ΥԼ��
      rcount := F_SET_TEXT(15, to_char(v_zys * 100)); --Ӧ�պϼ�
    
    else
      --Ԥ��ɷ�
      rcount := F_SET_TEXT(9, to_char(MI.MIRCODE)); --���ڱ�ʾ��
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --�����һ��һ�����һ�����ˮ����ͬ
        --ȡˮ�ѵ��ۺ���ˮ�ѵ���
        select nvl(sum(decode(pd.pdpiid, '01', pd.pddj, 0)), 0) sfdj,
               nvl(sum(decode(pd.pdpiid, '02', pd.pddj, 0)), 0) wsfdj
          into v_sfdj, v_wsfdj
          from pricedetail pd
         where pd.pdpfid = mi.mipfid
         group by pd.pdpfid;
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --ˮ�ѵ���
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
      else
        --���һ�����ˮ�۲�ͬ
        rcount := F_SET_TEXT(10, '-'); --ˮ�ѵ���
        rcount := F_SET_TEXT(12, '-'); --��ˮ�ѵ���
      end if;
      rcount := F_SET_TEXT(11, '0'); --ˮ�Ѻϼ�
      rcount := F_SET_TEXT(13, '0'); --��ˮ�Ѻϼ�
      rcount := F_SET_TEXT(14, '0'); --ΥԼ��
      rcount := F_SET_TEXT(15, '0'); --Ӧ�պϼ�
    
    end if;
  
    rcount := F_SET_TEXT(16, to_char(mi.misaving * 100)); --�ڳ�Ԥ��
    rcount := F_SET_TEXT(17, to_char(v_curr_sav * 100)); --��ĩԤ��
  
    -------------------------20130912�޸�һ��һ��Ϊ����Ԥ�Ʊ�ʾ������һ�����Ϊ����Ԥ�ƿ���ˮ����---------------------
    if v_sbs = 1 then
      --�����һ��һ��
      rcount := F_SET_TEXT(18,
                           to_char(MI.MIRCODE +
                                   floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---Ԥ�Ʊ�ʾ��
    elsif v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y' then
      --���һ�����ˮ����ͬ
      rcount := F_SET_TEXT(18,
                           to_char(floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---Ԥ�ƿ���ˮ��
    else
      --���һ�����ˮ�۲�ͬ
      rcount := F_SET_TEXT(18, '-');
    end if;
    -----------------------------------------------------end-----------------------------------------------------------------
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    --ͳ�Ʊ������˼�¼��
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
  
    --ʵ�ս���
    if qfyf2_all > 0 then
      --ʵ�ս��ױ������ݷ��ص���ϸ��������
      --�ж����ʵ�ʱ��������������������¼��ȡ��������
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --��¼��  
      else
        rcount := F_SET_TEXT(19, to_char(qfyf2_all)); --��¼��  
      end if;
    
      --���ݼ�¼������packetsDT����
      if qfyf2_all <= v_jfsx then
        sp_extensiondata(qfyf2_all);
      else
        --����ɷѼ�¼��������ֻ���������6����ϸ
        sp_extensiondata(v_jfsx);
      end if;
      v_n := 0;
      --����������  20-44ѭ��ȡֵ
      open c_ysmx;
      loop
        fetch c_ysmx
          into v_ysmx;
        exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
        rcount := F_SET_TEXT(20 + (v_n * 25), to_char(v_ysmx.month)); --���·�
        rcount := F_SET_TEXT(21 + (v_n * 25), to_char(v_ysmx.xj)); --С��
        rcount := F_SET_TEXT(22 + (v_n * 25), to_char(v_ysmx.rlbfid)); --�ʿ���
        rcount := F_SET_TEXT(23 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --����
        rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --�ϴγ�������
        rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.RLECODE)); --ֹ��
        rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --���γ�������
        rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --ˮ�ѵ��ۣ�һ�ף�
        rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(29 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.dj2)); --��ˮ����ѵ���
        rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.use_r1)); --ˮ����һ�ף�
        rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.use_r2)); --ˮ�������ף�
        rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.use_r3)); --ˮ�������ף�
        rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.charge_r1)); --ˮ�ѣ�һ�ף�
        rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.charge_r2)); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(36 + (v_n * 25), to_char(v_ysmx.charge_r3)); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(37 + (v_n * 25), to_char(v_ysmx.charge2)); --��ˮ�����
        rcount := F_SET_TEXT(38 + (v_n * 25), to_char(v_ysmx.chargeznj)); --ΥԼ��
        rcount := F_SET_TEXT(39 + (v_n * 25), to_char(v_ysmx.zjje)); --׷����
        rcount := F_SET_TEXT(40 + (v_n * 25), to_char(v_ysmx.rlmid)); --�ͻ�����
        rcount := F_SET_TEXT(41 + (v_n * 25), to_char(v_ysmx.yl1)); --Ԥ��
        rcount := F_SET_TEXT(42 + (v_n * 25), to_char(v_ysmx.yl2)); --Ԥ��
        rcount := F_SET_TEXT(43 + (v_n * 25), to_char(v_ysmx.yl3)); --Ԥ��
        rcount := F_SET_TEXT(44 + (v_n * 25), to_char(v_ysmx.yl4)); --Ԥ��
        v_n    := v_n + 1;
      end loop;
      close c_ysmx;
    
    else
      --����Ԥ�潻�ױ������ݷ��ص���ϸ��������
      --�ж�����û��������������������¼��ȡ��������
      if v_sbs > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --��¼��  
      elsif v_sbs>1  then --һ������ָ����ϸ
        rcount := F_SET_TEXT(19, to_char(v_sbs)); --��¼��  
      else--һ��һ����ָ����ϸ
        rcount := F_SET_TEXT(19, '0'); --��¼��  
      end if;
    
      --���ݼ�¼������packetsDT����
      if v_sbs <= v_jfsx then
        sp_extensiondata(v_sbs);
      else
        --����ɷѼ�¼��������ֻ���������6����ϸ
        sp_extensiondata(v_jfsx);
      end if;
    
      v_n := 0;
      --����������  20-44ѭ��ȡֵ
      open c_hs_meter;
      loop
        fetch c_hs_meter
          into v_hs_meter;
        exit when v_hs_meter.vnum > v_jfsx or c_hs_meter%notfound or c_hs_meter%notfound is null;
        rcount := F_SET_TEXT(20 + (v_n * 25), '-'); --ˮ�ѷ������·�
        rcount := F_SET_TEXT(21 + (v_n * 25), '-'); --С��
        rcount := F_SET_TEXT(22 + (v_n * 25),
                             trim(v_hs_meter.mibfid || v_hs_meter.mirorder)); --�ʿ���
        rcount := F_SET_TEXT(23 + (v_n * 25), '-'); --�ϴα�ʾ�������룩
        rcount := F_SET_TEXT(24 + (v_n * 25), '-'); --�ϴγ�������
        rcount := F_SET_TEXT(25 + (v_n * 25), v_hs_meter.mircode); --���α�ʾ����ֹ�룩
        rcount := F_SET_TEXT(26 + (v_n * 25), v_hs_meter.mirecdate); --���γ�������
        rcount := F_SET_TEXT(27 + (v_n * 25), '-'); --ˮ�ѵ��ۣ�һ�ף�
        rcount := F_SET_TEXT(28 + (v_n * 25), '-'); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(29 + (v_n * 25), '-'); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(30 + (v_n * 25), '-'); --��ˮ����ѵ���
        rcount := F_SET_TEXT(31 + (v_n * 25), '-'); --ˮ����һ�ף�
        rcount := F_SET_TEXT(32 + (v_n * 25), '-'); --ˮ�������ף�
        rcount := F_SET_TEXT(33 + (v_n * 25), '-'); --ˮ�������ף�
        rcount := F_SET_TEXT(34 + (v_n * 25), '-'); --ˮ�ѣ�һ�ף�
        rcount := F_SET_TEXT(35 + (v_n * 25), '-'); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(36 + (v_n * 25), '-'); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(37 + (v_n * 25), '-'); --��ˮ�����
        rcount := F_SET_TEXT(38 + (v_n * 25), '-'); --ΥԼ��
        rcount := F_SET_TEXT(39 + (v_n * 25), '-'); --׷����
        rcount := F_SET_TEXT(40 + (v_n * 25), v_hs_meter.miid); --�ͻ�����
        rcount := F_SET_TEXT(41 + (v_n * 25), ''); --Ԥ��
        rcount := F_SET_TEXT(42 + (v_n * 25), ''); --Ԥ��
        rcount := F_SET_TEXT(43 + (v_n * 25), ''); --Ԥ��
        rcount := F_SET_TEXT(44 + (v_n * 25), ''); --Ԥ��
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
      rcount := F_SET_TEXT(2, '003'); --��¼����������ת��ʵʱ��ʽ����
    when err_je then
      rcount := F_SET_TEXT(2, '005');
    when err_other then
      rcount := F_SET_TEXT(2, '021');
    when rec_overflow then
      rcount := F_SET_TEXT(2, '023');
    when err_ymsz then
      rcount := F_SET_TEXT(2, '022');--��ĩ���� 
   when err_exist then  --������ˮ
       rcount := F_SET_TEXT(2, '025'); 
    when others then 
      rcount := F_SET_TEXT(2, '024');  --����
  end;*/
   /*----------------------------------------------------------------------
  Note: 540�ɷѽ��״���
  Input: p_bankid -- ���б���
         p_chgno  -- ������ˮ
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f540(p_in in arr, p_out in out arr) as
  
    pstep      number(10); --���������
    v_retstr   varchar2(10); --���ؽ��
    V_OUTCOUNT NUMBER(10);
    V_RLIDS    VARCHAR2(20000); --Ӧ����ˮ
    V_RLJE     NUMBER(12, 2); --Ӧ�ս��
    V_ZNJ      NUMBER(12, 2); --���ɽ�
  
    v_LJFJE     NUMBER(12, 2); --�����ѽ��
    v_RLIDS_LJF VARCHAR2(20000); --������Ӧ����ˮ
    v_out_LJFJE NUMBER(12, 2); --���������ʽ��
  
    v_SXF NUMBER(12, 2); --//������
  
    v_POSITION  varchar2(10); -- //�ɷѻ���-
    v_OPER      payment.pper%type; --//�տ�Ա
    v_ptrans    payment.ptrans%type; --//�տ�Ա
    v_mcode     varchar2(30); --  --�ͻ�����
    mi          meterinfo%rowtype;
    CI          CUSTINFO%ROWTYPE;
    v_chgno     payment.PBSEQNO%type; -- --������ˮ
    v_pbatch    payment.pbatch%type; -- --��������
    v_chg_op    payment.pper%type;
    v_PAYJE     number(10, 2); --�ɷѽ��
    v_discharge number(10, 2); --���νɷѵֿ۽��
    v_curr_sav  number(10, 2); --���νɷѺ�Ԥ����
    v_fppc      varchar2(14); ---��Ʊ����
    v_fpno      varchar2(10); ---��Ʊ����
    v_paypoint  varchar2(20); ---�ɷѷ�֧����
    v_pdate     varchar2(14); ---����ʱ��
    v_pid       payment.pid%type; --//ʵ����ˮ
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    ---- �����α�
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
  
    --ʵ�ս�����Ӧ��ѭ��������ϸ
    cursor c_ysmx is
      select *
        from (select 1 vnum,
                     rdpiid,
                     RDPFID,
                     ppriid,
                     rlmonth,
                     rdclass,
                     count(*),
                     substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�20
                   /*  to_char((sum(decode(rdpiid, 01, 0, sum(rddj)))
                              over(partition by RDPFID) *
                              max(decode(rdpiid, '01', rdsl, 0)) +
                              max(decode(rdpiid, '01', rddj, 0)) *
                              max(decode(rdpiid, '01', rdsl, 0))) * 100) xj, --С��21*/
                     to_char(max(decode(rdpiid, '01', rddj, 0)) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100)  + to_char(sum(decode(rdpiid, '01', 0, max(rddj)))
                             over(partition by RDPFID,rlmonth) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) xj,
                     trim(f_getcardno(max(rlmid))) rlbfid, --�ʿ���22
                     max(to_char(decode(FGETIFDZSB(rlmid),
                                        'Y',
                                        '-',
                                        decode(RLMSTATUS,
                                               '29',
                                               '-',
                                               '30',
                                               '-',
                                               RLSCODE)))) RLSCODE, --����23
                     max(TO_CHAR(RLPRDATE, 'YYYYMMDD')) RLPRDATE, --�ϴγ�������24
                     max(to_char(decode(FGETIFDZSB(rlmid),
                                        'Y',
                                        '-',
                                        decode(RLMSTATUS,
                                               '29',
                                               '-',
                                               '30',
                                               '-',
                                               RLECODE)))) RLECODE, --ֹ��25
                     max(TO_CHAR(RLRDATE, 'YYYYMMDD')) RLRDATE, --���ڳ�������26
                     to_char(max(decode(rdpiid, '01', rddj, 0)) * 100) USER_DJ1, --ˮ�ѵ���һ��27
                     to_char(0 * 100) USER_DJ2, --ˮ�ѵ��۶���28
                     to_char(0 * 100) USER_DJ3, --ˮ�ѵ�������29
                     sum(decode(rdpiid, 01, 0, max(rddj))) over(partition by rlmonth, RDPFID) * 100 dj2,
                     --to_char(max(decode(rdpiid, '02', rddj, 0)) * 100) dj2, --��ˮ����30
                     to_char(sum(decode(rdpiid, '01', rdsl, 0))) use_r1, --ˮ��һ��31
                     to_char(0) use_r2, --ˮ������32
                     to_char(0) use_r3, --ˮ������33
                     to_char(max(decode(rdpiid, '01', rddj, 0)) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) charge_r1,
                     
                     to_char(0 * 100) charge_r2, --ˮ�Ѷ���35
                     to_char(0 * 100) charge_r3, --ˮ������36
                     to_char(sum(decode(rdpiid, 01, 0, max(rddj)))
                             over(partition by rlmonth, RDPFID) *
                             sum(decode(rdpiid, '01', rdsl, 0)) * 100) charge2, --��ˮ���37 
                     to_char(0 * 100) chargeznj, --ΥԼ��38
                     '0' zjje, --׷�����39
                     max(rlmid) rlmid, --�ͻ�����40
                     decode(rdclass, 0, '-', rdclass || '��') yl1, --Ԥ��1 41
                     '' yl2, --Ԥ��1 42
                     '' yl3, --Ԥ��1 43
                     '' yl4 --Ԥ��1 44
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
          substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�20
          to_char((1) * 100) xj, --С��21
          trim(f_getcardno(max(rlmid))) rlbfid, --�ʿ���22
          max(to_char(decode(FGETIFDZSB(rlmid),
                             'Y',
                             '-',
                             decode(RLMSTATUS,
                                    '29',
                                    '-',
                                    '30',
                                    '-',
                                    RLSCODE)))) RLSCODE, --����23
          max(TO_CHAR(RLPRDATE, 'YYYYMMDD')) RLPRDATE, --�ϴγ�������24
          max(to_char(decode(FGETIFDZSB(rlmid),
                             'Y',
                             '-',
                             decode(RLMSTATUS,
                                    '29',
                                    '-',
                                    '30',
                                    '-',
                                    RLECODE)))) RLECODE, --ֹ��25
          max(TO_CHAR(RLRDATE, 'YYYYMMDD')) RLRDATE, --���ڳ�������26
          to_char(max(decode(rdpiid, '01', rddj, 0)) * 100) USER_DJ1, --ˮ�ѵ���һ��27
          to_char(0 * 100) USER_DJ2, --ˮ�ѵ��۶���28
          to_char(0 * 100) USER_DJ3, --ˮ�ѵ�������29
          to_char(max(decode(rdpiid, '02', rddj, 0)) * 100) dj2, --��ˮ����30
          to_char(max(decode(rdpiid, '01', rdsl, 0))) use_r1, --ˮ��һ��31
          to_char(0) use_r2, --ˮ������32
          to_char(0) use_r3, --ˮ������33
          to_char(max(decode(rdpiid, '01', rddj, 0)) *
                  max(decode(rdpiid, '01', rdsl, 0)) * 100) charge_r1,
          
          to_char(0 * 100) charge_r2, --ˮ�Ѷ���35
          to_char(0 * 100) charge_r3, --ˮ������36
          to_char(max(decode(rdpiid, '02', rddj, 0)) *
                  max(decode(rdpiid, '01', rdsl, 0)) * 100) charge2, --��ˮ���37 
          to_char(0 * 100) chargeznj, --ΥԼ��38
          '0' zjje, --׷�����39
          max(rlmid) rlmid, --�ͻ�����40
          decode(rdclass, 0, '-', rdclass || '��') yl1, --Ԥ��1 41
          '' yl2, --Ԥ��1 42
          '' yl3, --Ԥ��1 43
          '' yl4 --Ԥ��1 44
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
           substr(rlmonth, 1, 4) || substr(rlmonth, 6, 2) month, --���·�20
           to_char((chargetotal + chargeznj) * 100) xj, --С��21
           trim(f_getcardno(rlmid)) rlbfid, --�ʿ���22
           to_char(decode(FGETIFDZSB(rlmid),
                          'Y',
                          '-',
                          decode(RLMSTATUS, '29', '-', '30', '-', RLSCODE))) RLSCODE, --����23
           TO_CHAR(RLPRDATE, 'YYYYMMDD') RLPRDATE, --�ϴγ�������24
           to_char(decode(FGETIFDZSB(rlmid),
                          'Y',
                          '-',
                          decode(RLMSTATUS, '29', '-', '30', '-', RLECODE))) RLECODE, --ֹ��25
           TO_CHAR(RLRDATE, 'YYYYMMDD') RLRDATE, --���ڳ�������26
           to_char(decode(USER_DJ1, 0, dj1) * 100) USER_DJ1, --ˮ�ѵ���һ��27
           to_char(USER_DJ2 * 100) USER_DJ2, --ˮ�ѵ��۶���28
           to_char(USER_DJ3 * 100) USER_DJ3, --ˮ�ѵ�������29
           to_char(dj2 * 100) dj2, --��ˮ����30
           to_char(decode(use_r1, 0, wateruse)) use_r1, --ˮ��һ��31
           to_char(use_r2) use_r2, --ˮ������32
           to_char(use_r3) use_r3, --ˮ������33
           to_char(decode(charge_r1, 0, charge1) * 100) charge_r1, --ˮ��һ��34
           to_char(charge_r2 * 100) charge_r2, --ˮ�Ѷ���35
           to_char(charge_r3 * 100) charge_r3, --ˮ������36
           to_char(charge2 * 100) charge2, --��ˮ���37
           to_char(chargeznj * 100) chargeznj, --ΥԼ��38
           '0' zjje, --׷�����39
           rlmid, --�ͻ�����40
           '' yl1, --Ԥ��1 41
           '' yl2, --Ԥ��1 42
           '' yl3, --Ԥ��1 43
           '' yl4 --Ԥ��1 44
      from reclist rl, view_reclist_charge_02 rd, payment pm
     where rl.rlpid = pm.pid
       and rlid = rdid
       and pm.preverseflag = 'N'
       and rl.rlreverseflag = 'N'
       and rl.rlpaidflag = 'Y'
       and pm.pbseqno = v_chgno
       and pm.ppriid = v_mcode
     order by rldate desc;*/
  
    -----------------------20130923 ����Ԥ��----------------------------
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
    --�쳣���ض���
    err_format   exception; --���ݸ�ʽ��
    err_charge   exception; --�ɷѴ���
    err_je       exception; --����
    err_nouser   exception; --�û�������
    err_clockje  exception; --003����¼����������ת��ʵʱ��ʽ����
    err_other    exception; --
    err_exist    exception;
    rec_overflow exception; --Ƿ���·ݳ�����Ӧ��Ӫҵ���ɷ�
    no_user      exception; --�޴��û�
  
    err_ymsz exception; --��ĩ����
    v_bankid varchar2(10); --���з�֧����
  
    v_b       number(10);
    v_e       number(10);
    v_n       number(10);
    v_count   number(10); --���װ��ֶ���
    v_inlen   number(10); --���װ�������
    v_seqno   payment.PBSEQNO%type; -- --������ˮ
    v_pbseqno number(10); --У��������ˮ
    v_hsb1    varchar2(400);
    v_hsb2    varchar2(400);
    v_rdclass recdetail.rdclass%type := 9;
    v_jtjg    varchar2(100);
    v_pspfid  varchar2(100);
    v_rlpfid  varchar2(100);
  begin
    /*--����Ƿ����ѭ��
    SELECT to_number(nvl(c2,'0')) into v_b FROM packetsDT WHERE C3='b';
    SELECT to_number(nvl(c2,'0')) into v_e FROM packetsDT WHERE C3='b';*/
    --��ȡѭ������
    v_jfsx    := 6; --����
    v_RLECODE := ' ';
    rcount    := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount    := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 13 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 93 then
      raise err_format;
    end if;
  
    --�ж��Ƿ�����ĩ����
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
    v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    if F_GETBANKSYSPARA(v_bankid) = 'N' then
      raise err_ymsz;
    end if;
    --end if;
  
    --У������540������ˮ�Ƿ��Ѵ���
    v_pbseqno := 0;
    v_seqno   := trim(F_GET_HDTEXT(4)); --������ˮ
    select count(*) into v_pbseqno from payment where pbseqno = v_seqno;
    if v_pbseqno > 0 then
      raise err_exist;
    end if;
  
    v_mcode := trim(F_GET_HDTEXT(7)); --�ͻ�����
    if length(v_mcode) = 14 then
      v_mcode := substr(v_mcode, 4, 1) || substr(v_mcode, 5, 2) ||
                 substr(v_mcode, 8, 1) || substr(v_mcode, 9, 6);
    end if;
  
    v_paypoint := trim(F_GET_HDTEXT(10)); --���з�֧����
    v_pdate    := trim(F_GET_HDTEXT(11)); --�ɷ�ʱ��
    v_fppc     := trim(F_GET_HDTEXT(12)); --��Ʊ����
    v_fpno     := trim(F_GET_HDTEXT(13)); --��Ʊ��
  
    ---ȡ�������Ϣ��
    select t.* into MI from METERINFO t where t.micode = v_mcode;
    select t.* into CI from custinfo t where t.ciid = MI.micid;
  
    --�ж��Ƿ������û� zhw������ֵ˰�û����������нɷ�
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
      --����ȡ������������
      select t.* into MI from METERINFO t where t.micode = v_mcode;
      select t.* into CI from custinfo t where t.ciid = MI.micid;
    end if;
  
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���---------------------
    --ͳ��Ƿ�Ѽ�¼��
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
    ----------------------20130922  ���ǵ�һ�������rlprimcodeƥ���û���end---------------------
  
    --�����޶����� ���ýɷѷ���023����
    if qfyf2_all > v_jfsx then
      null;
      --raise rec_overflow;  --20131212�ſ����ƣ�����6��Ҳ���Խɷ�
    end if;
  
    v_POSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_OPER     := trim(F_GET_HDTEXT(9));
    v_chgno    := F_GET_HDTEXT(8);
    v_PAYJE    := to_number(F_GET_HDTEXT(8)) / 100; --�ɷѽ��
    v_chgno    := trim(F_GET_HDTEXT(4)); --������ˮ
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
      --�û�������
      raise err_nouser;
    elsif v_retstr = '003' then
      --����
      raise err_clockje;
    elsif v_retstr = '005' then
      --����
      raise err_je;
    elsif v_retstr = '021' then
      raise err_other;
    end if;
  
    rcount := F_SET_TEXT(3, to_char(v_PAYJE * 100)); --���νɷѽ��
    rcount := F_SET_TEXT(4, to_char(v_sbs)); --�û�����
    rcount := F_SET_TEXT(5, MI.micode); --�ͻ�����
    v_mame := substr(MI.MINAME, 1, 60);
    rcount := F_SET_TEXT(6, v_mame); --����
    v_addr := substr(CI.CIADR, 1, 60);
    rcount := F_SET_TEXT(7, v_addr); --����ַ
    rcount := F_SET_TEXT(8, v_chgno); --ƾ֤��ˮ
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    --��Ƿ�ѣ�ʵ�ս���
    if qfyf2_all > 0 then
      ----ȡ������Ϣ��
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
      ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
    
      --------20130912 �����ʵ�ս��ף����ֶ�ΪӦ��ˮ���������Ԥ�潻�ף����ֶ�Ϊ��ǰ��ʾ��----------
      rcount := F_SET_TEXT(9, to_char(v_sl)); --Ӧ��ˮ��
      --------------------------end ----------------------------------------------------
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --�����һ��һ�����һ�����ˮ����ͬ
        --ȡˮ�ѵ��ۺ���ˮ�ѵ���
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
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --ˮ�ѵ���
        rcount := F_SET_TEXT(11, to_char(v_sf * 100)); --ˮ�Ѻϼ�
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
        rcount := F_SET_TEXT(13, to_char(v_wsf * 100)); --��ˮ�Ѻϼ�
      
      else
        --���һ�����ˮ�۲�ͬ
        rcount := F_SET_TEXT(10, '-'); --ˮ�ѵ���
        rcount := F_SET_TEXT(11, '-'); --ˮ�Ѻϼ�
        rcount := F_SET_TEXT(12, '-'); --��ˮ�ѵ���
        rcount := F_SET_TEXT(13, '-'); --��ˮ�Ѻϼ�
      end if;
    
      rcount := F_SET_TEXT(14, to_char(v_ssznj * 100)); --ΥԼ��
      rcount := F_SET_TEXT(15, to_char(v_zys * 100)); --Ӧ�պϼ�
    
    else
      --Ԥ��ɷ�
      rcount := F_SET_TEXT(9, to_char(MI.MIRCODE)); --���ڱ�ʾ��
    
      if v_sbs = 1 or (v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y') then
        --�����һ��һ�����һ�����ˮ����ͬ
        --ȡˮ�ѵ��ۺ���ˮ�ѵ���
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
        rcount := F_SET_TEXT(10, to_char(v_sfdj * 100)); --ˮ�ѵ���
        rcount := F_SET_TEXT(12, to_char(v_wsfdj * 100)); --��ˮ�ѵ���
      else
        --���һ�����ˮ�۲�ͬ
        rcount := F_SET_TEXT(10, '-'); --ˮ�ѵ���
        rcount := F_SET_TEXT(12, '-'); --��ˮ�ѵ���
      end if;
      rcount := F_SET_TEXT(11, '0'); --ˮ�Ѻϼ�
      rcount := F_SET_TEXT(13, '0'); --��ˮ�Ѻϼ�
      rcount := F_SET_TEXT(14, '0'); --ΥԼ��
      rcount := F_SET_TEXT(15, '0'); --Ӧ�պϼ�
    
    end if;
  
    rcount := F_SET_TEXT(16, to_char(mi.misaving * 100)); --�ڳ�Ԥ��
    rcount := F_SET_TEXT(17, to_char(v_curr_sav * 100)); --��ĩԤ��
  
    -------------------------20130912�޸�һ��һ��Ϊ����Ԥ�Ʊ�ʾ������һ�����Ϊ����Ԥ�ƿ���ˮ����---------------------
    if v_sbs = 1 then
      --�����һ��һ��
      rcount := F_SET_TEXT(18,
                           to_char(MI.MIRCODE +
                                   floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---Ԥ�Ʊ�ʾ��
    elsif v_sbs > 1 and f_priceissame(MI.mipriid) = 'Y' then
      --���һ�����ˮ����ͬ
      rcount := F_SET_TEXT(18,
                           to_char(floor(v_curr_sav / (v_sfdj + v_wsfdj)))); ---Ԥ�ƿ���ˮ��
    else
      --���һ�����ˮ�۲�ͬ
      rcount := F_SET_TEXT(18, '-');
    end if;
    -----------------------------------------------------end-----------------------------------------------------------------
  
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���---------------------
    --ͳ�Ʊ������˼�¼��
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
    ----------------------20130922  ���ǵ�һ�������PPRIIDƥ���û���end---------------------
    /*  rcount := F_SET_TEXT(19, '-'); --��¼��
    rcount := F_SET_TEXT(20, '-'); --��¼��*/
  
    --ʵ�ս���
  
    v_hsb1 := '';
    v_hsb2 := '';
    v_n    := 0;
    --����������  20-44ѭ��ȡֵ
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
      rcount := F_SET_TEXT(19, ' '); --��¼��
      rcount := F_SET_TEXT(20, ' '); --��¼��
    end if;
    if v_rdclass = 0 then
      v_jtjg := v_sfdj || 'Ԫ';
    elsif v_rdclass = 1 then
      v_jtjg := '(1��)' || v_sfdj || 'Ԫ';
    elsif v_rdclass = 2 then
      v_jtjg := '(2��)' || v_sfdj || 'Ԫ';
    elsif v_rdclass = 3 then
      v_jtjg := '(3��)' || v_sfdj || 'Ԫ';
    else
      v_jtjg := '-';
    end if;
    rcount := F_SET_TEXT(21, v_jtjg); --��¼��
    rcount := F_SET_TEXT(22, v_pid); --20180802 �޸�Ϊʵ����ˮ���������д�ӡ��Ʊ��ȡ��
    rcount := F_SET_TEXT(23, '0'); --��¼��
    if qfyf2_all > 0 then
      --ʵ�ս��ױ������ݷ��ص���ϸ��������
      --�ж����ʵ�ʱ��������������������¼��ȡ��������
      if qfyf2_all > v_jfsx then
        rcount := F_SET_TEXT(23, v_jfsx); --��¼��
      else
        rcount := F_SET_TEXT(23, to_char(qfyf2_all)); --��¼��
      end if;
    
      --���ݼ�¼������packetsDT����
      if qfyf2_all <= v_jfsx then
        sp_extensiondata(qfyf2_all);
      else
        --����ɷѼ�¼��������ֻ���������6����ϸ
        sp_extensiondata(v_jfsx);
      end if;
      v_n := 0;
      --����������  20-44ѭ��ȡֵ
      open c_ysmx;
      loop
        fetch c_ysmx
          into v_ysmx;
        exit when v_ysmx.vnum > v_jfsx or c_ysmx%notfound or c_ysmx%notfound is null;
        rcount := F_SET_TEXT(24 + (v_n * 25), to_char(v_ysmx.month)); --���·�
        rcount := F_SET_TEXT(25 + (v_n * 25), to_char(v_ysmx.xj)); --С��
        rcount := F_SET_TEXT(26 + (v_n * 25), to_char(v_ysmx.rlbfid)); --�ʿ���
        rcount := F_SET_TEXT(27 + (v_n * 25), to_char(v_ysmx.RLSCODE)); --����
        rcount := F_SET_TEXT(28 + (v_n * 25), to_char(v_ysmx.RLPRDATE)); --�ϴγ�������
        if v_RLECODE = v_ysmx.RLECODE then
          rcount := F_SET_TEXT(29 + (v_n * 25), ' '); --ֹ��
        else
          v_RLECODE := v_ysmx.RLECODE;
          rcount    := F_SET_TEXT(29 + (v_n * 25), v_ysmx.RLECODE); --ֹ��
        end if;
      
        rcount := F_SET_TEXT(30 + (v_n * 25), to_char(v_ysmx.RLRDATE)); --���γ�������
        rcount := F_SET_TEXT(31 + (v_n * 25), to_char(v_ysmx.USER_DJ1)); --ˮ�ѵ��ۣ�һ�ף�
        rcount := F_SET_TEXT(32 + (v_n * 25), to_char(v_ysmx.USER_DJ2)); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(33 + (v_n * 25), to_char(v_ysmx.USER_DJ3)); --ˮ�ѵ��ۣ����ף�
        rcount := F_SET_TEXT(34 + (v_n * 25), to_char(v_ysmx.dj2)); --��ˮ����ѵ���
        rcount := F_SET_TEXT(35 + (v_n * 25), to_char(v_ysmx.use_r1)); --ˮ����һ�ף�
        rcount := F_SET_TEXT(36 + (v_n * 25), to_char(v_ysmx.use_r2)); --ˮ�������ף�
        rcount := F_SET_TEXT(37 + (v_n * 25), to_char(v_ysmx.use_r3)); --ˮ�������ף�
        rcount := F_SET_TEXT(38 + (v_n * 25), to_char(v_ysmx.charge_r1)); --ˮ�ѣ�һ�ף�
        rcount := F_SET_TEXT(39 + (v_n * 25), to_char(v_ysmx.charge_r2)); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(40 + (v_n * 25), to_char(v_ysmx.charge_r3)); --ˮ�ѣ����ף�
        rcount := F_SET_TEXT(41 + (v_n * 25), to_char(v_ysmx.charge2)); --��ˮ�����
        rcount := F_SET_TEXT(42 + (v_n * 25), to_char(v_ysmx.chargeznj)); --ΥԼ��
        rcount := F_SET_TEXT(43 + (v_n * 25), to_char(v_ysmx.zjje)); --׷����
        rcount := F_SET_TEXT(44 + (v_n * 25), to_char(v_ysmx.rlmid)); --�ͻ�����
        rcount := F_SET_TEXT(45 + (v_n * 25), to_char(v_ysmx.yl1)); --Ԥ��
        rcount := F_SET_TEXT(46 + (v_n * 25), to_char(v_ysmx.yl2)); --Ԥ��
        rcount := F_SET_TEXT(47 + (v_n * 25), to_char(v_ysmx.yl3)); --Ԥ��
        rcount := F_SET_TEXT(48 + (v_n * 25), to_char(v_ysmx.yl4)); --Ԥ��
        v_n    := v_n + 1;
      end loop;
      close c_ysmx;
    
      /*  else
      --����Ԥ�潻�ױ������ݷ��ص���ϸ��������
      --�ж�����û��������������������¼��ȡ��������
      \*if v_sbs > v_jfsx then
        rcount := F_SET_TEXT(19, v_jfsx); --��¼��
      elsif v_sbs>1  then --һ������ָ����ϸ
        rcount := F_SET_TEXT(19, to_char(v_sbs)); --��¼��
      else--һ��һ����ָ����ϸ
        rcount := F_SET_TEXT(19, '0'); --��¼��
      end if;*\
      
      --���ݼ�¼������packetsDT����
      if v_sbs <= v_jfsx then
        sp_extensiondata(v_sbs);
      else
        --����ɷѼ�¼��������ֻ���������6����ϸ
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
    
      rcount := F_SET_TEXT(2, '003'); --��¼����������ת��ʵʱ��ʽ����
    when err_je then
    
      rcount := F_SET_TEXT(2, '005');
    when err_other then
    
      rcount := F_SET_TEXT(2, '021');
    when rec_overflow then
    
      rcount := F_SET_TEXT(2, '023');
    when err_ymsz then
    
      rcount := F_SET_TEXT(2, '022'); --��ĩ����
    when err_exist then
      --������ˮ
    
      rcount := F_SET_TEXT(2, '025');
    when others then
    
      rcount := F_SET_TEXT(2, '024'); --����
  end;
  /*----------------------------------------------------------------------
  Note: 580�ɷѽ����ѯ����
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f580(p_in in arr, p_out in out arr) as
  
    v_transno   varchar(20); --���нɷ���ˮ
    v_PPOSITION PAYMENT.PPOSITION %TYPE; --����
  
    rcount number(10);
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_charge exception; --�ɷѴ���
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
  
  begin
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_count from packetshd;
    if v_count <> 7 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 23 then
      raise err_format;
    end if;
  
    v_PPOSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    v_transno   := trim(F_GET_HDTEXT(7)); --������ˮ��
    --��ѯ�������������(����������ʱ��Ȼ����paymentΪ0��һ��ʵ�ɼ�¼)
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
  Note: 550�ɷ�ȡ������
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/

  procedure f550(p_in in arr, p_out in out arr) as
  
    v_transno   varchar(20); --���нɷ���ˮ
    v_meterno   varchar2(30); --ˮ�����Ϻ�
    v_PPOSITION PAYMENT.PPOSITION %TYPE; --����
    rcount      number(10);
    v_paycount    number(10);
    v_retstr    varchar2(20);
    v_pdate     varchar2(8);
    v_date      date;
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_charge exception; --�ɷѴ���
    err_nodate exception; --�ɷѴ���
    err_other exception; --�ɷѴ���
    no_user exception; --�޴��û�
    
    err_ymsz exception; --��ĩ����
    v_bankid  varchar2(10);  --���з�֧����
    
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
    v_seqno     payment.PBSEQNO%type; -- --������ˮ
    v_pbseqno      number(10);--У��������ˮ
        mi          meterinfo%rowtype;

  begin
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    if p_in.count <> 9 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 45 then
      raise err_format;
    end if;
    
     --�ж��Ƿ�����ĩ����
    --if trunc(sysdate)=trunc(last_day(sysdate)) then
      v_bankid := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
      if F_GETBANKSYSPARA(v_bankid)='N' then
         raise err_ymsz;
      end if;
    --end if;

    v_PPOSITION := FBCODE2SMFID(trim(F_GET_HDTEXT(1))); --
    v_transno   := trim(F_GET_HDTEXT(7)); --������ˮ��
    v_meterno   := trim(F_GET_HDTEXT(8)); --�û�ID��
    
   if length(v_meterno) = 14 then
      v_meterno := substr(v_meterno, 4, 1) || substr(v_meterno, 5, 2) ||
                 substr(v_meterno, 8, 1) || substr(v_meterno, 9, 6);
    end if;
    
    ---ȡ�������Ϣ��
    select t.* into MI from METERINFO t where t.micode = v_meterno;
    --�ж��Ƿ������û�
    if mi.michargetype = 'M' or mi.mistatus in ('7','19','28','31','32') then
      raise no_user;
    end if;
    
    if mi.mipriflag = 'Y' then
      v_meterno := mi.mipriid;
    end if;
    
   --����ֻ��������Լҵ��콻�ļ�¼
   select count(*)
     into v_paycount
     from payment
    where pbseqno = v_transno
      and pposition = v_PPOSITION
      and pdate = trunc(sysdate);
   if v_paycount <= 0 then
     raise err_other;
   end if;
    
    v_pdate     := trim(F_GET_HDTEXT(9)); --��������
  
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
      --���ݿ������
      raise err_charge;
    elsif v_retstr = '022' then
      --��������
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
      rcount := F_SET_TEXT(2, '022');--��ĩ����
    when others then
      rcount := F_SET_TEXT(2, '022');
  end f550;

  /*----------------------------------------------------------------------
  Note: 510 ���˽��״���
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f510(p_in in arr, p_out in out arr) as
  
    v_zbs     number(10); --�ܱ���
    v_zje     number(10, 2); --�ܽ��
    v_chkdate date; --��������
    v_sysdate date;--ϵͳ����
    rcount    number(10);
    v_count   number(10);
  
    p_bankid varchar2(20);
    p_bankno varchar2(20);
    v_jp     varchar2(1000);
    v_jtm    varchar2(50);
    v_time   varchar2(20);
    v_path   varchar2(200);
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_charge exception; --�ɷѴ���
    err_date exception; --ʱ�����
    err_zz exception; --δ���ʴ���
    err_dzword exception; --δ���Ͷ����ļ�(��δͬ��)����
    err_dzok exception; --�Ѷ��˴���
    v_incount number(10); --���װ��ֶ���
    v_inlen   number(10); --���װ�������
  begin
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
  
    select count(*) into v_incount from packetshd;
    if v_incount <> 9 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 31 then
      raise err_format;
    end if;
    
    --�������д����ȡ���з�֧����
    p_bankid  := FBCODE2SMFID(trim(F_GET_HDTEXT(1)));
    --��ȡ���д���
    p_bankno  := trim(F_GET_HDTEXT(1));
    --ȡϵͳʱ��
    --v_time    := to_char(sysdate, 'hh24:mi:ss');
    v_time    := to_char(trunc(sysdate,'mi')+5/(24*60), 'hh24:mi:ss') ;--5���Ӻ���ִ��job����
    --ȡ���з��͵Ķ���ʱ��
    v_chkdate := to_date(F_GET_HDTEXT(9), 'yyyymmdd');
     --ȡϵͳ��ǰʱ��
     v_sysdate  := trunc(sysdate);
    
    --20140401 �޸�Ϊ������ղ�����������
     --�ж�����ʱ���Ƿ����ϵͳʱ��
/*    if v_chkdate<>v_sysdate then
      raise err_date;
    end if;*/
    
    --�жϵ����Ƿ�����
    select count(*)
      into v_count
      from mi_bankzz
     where bankid = p_bankid
       and zzdate = v_chkdate;
    if v_count <= 0 then
      --����δ������
      raise err_zz;
    end if;
    
    --δ���Ͷ����ļ�(��δͬ��)����
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
      --raise err_dzword;  --��ʱ��У���ļ�
    END IF;
    
    
    --�Ѷ���
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
  
   --��̬jobִ��ͬ������
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
  Note: 511���ʽ��״���
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f511(p_in in arr, p_out in out arr) as
  
    v_chkdate date; --��������
    v_sysdate date;--ϵͳ����
    rcount    number(10);
    vsum      number(10);
  
    p_bankid varchar2(20);
    MB       mi_bankzz%ROWTYPE; --�������α���
    --�쳣���ض���
    err_format exception; --���ݸ�ʽ��
    err_date exception; --ʱ�����
    err_repeat exception; --�����ظ�
  
    v_count number(10); --���װ��ֶ���
    v_inlen number(10); --���װ�������
  
  begin
   --�������д����ȡ���з�֧����
    p_bankid  := FBCODE2SMFID(F_GET_HDTEXT(1));
    --��ȡ���з��͵���������
    v_chkdate := to_date(F_GET_HDTEXT(7), 'yyyymmdd');
    --ȡϵͳ��ǰʱ��
    v_sysdate  := trunc(sysdate);
    
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
    rcount := F_SET_TEXT(2, '000'); --���ؽ��

    select count(*) into v_count from packetshd;
    if v_count <> 7 then
      raise err_format;
    end if;
    v_inlen := F_GET_HDTEXT(5); --���װ�����
    if v_inlen <> 11 then
      raise err_format;
    end if;
    
    --�ж�����ʱ���Ƿ����ϵͳʱ��
    if v_chkdate<>v_sysdate then
      raise err_date;
    end if;
  
   ---�жϵ����Ƿ�����
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
      --�������δ������������ʼ�¼
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --���˱�� 
        FROM DUAL;
      MB.BANKID := p_bankid;--���б��� 
      MB.ZZDATE := v_chkdate;--�������� 
      MB.CZDATE := sysdate;--����ʱ�� 
      MB.ZZFROM := 'B';--��������
      insert into mi_bankzz values MB;
      
      --ֻ�е�һ�����ʸ���ʵ�ռ�¼
       update payment
       set PCHKDATE = MB.ZZDATE, --��������
           PCHKNO   = MB.DZNO --���˵���
     WHERE PPOSITION = MB.BANKID
       AND PDATETIME <= MB.CZDATE
       AND PDATE >= TO_DATE('2014-04-17','YYYY-MM-DD')
       AND PCHKNO IS NULL;

    else
      --��������ѳɹ����ʣ�����²���ʱ��
      MB.CZDATE := sysdate;
      update mi_bankzz
         set CZDATE = MB.CZDATE
       where bankid = p_bankid
         and zzdate = v_chkdate
         AND DZNO = trim(MB.DZNO);
      --raise err_repeat;--�����ظ�����
    end if;
    
    --��ĩ��������
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
  Note: 110 ǩ�����۹�ϵ��������ˮ����������
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
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
             '����ǩԼ',
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
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --ˮ�����Ϻ�
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8); --
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10); --
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := F_SET_TEXT(1, F_GET_HDTEXT(6)); --������
  
    --ƥ��ˮ�����Ϻ�
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
    v_meterinfo.miname := nvl(v_meterinfo.miname, 'δ��');
    v_ma_Info.Mamid    := v_meterinfo.miid; --����id
  
    --��������ջ����򷵻ش���
    v_meterinfo.MICHARGETYPE := NVL(v_meterinfo.MICHARGETYPE, 'N');
    if v_meterinfo.MICHARGETYPE = 'T' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    --���´�������
    delete meteraccount t where t.mamid = v_ma_Info.Mamid;
    insert into meteraccount t values v_ma_Info;
  
    update meterinfo t
       set t.MICHARGETYPE = 'D'
     WHERE t.MICODE = v_meterinfo.micode;
    --��¼��־
    --sp_dk_log(p_in);
    entrust_sign_log(v_ma_Info.Mamicode,
                     v_meterinfo.miname,
                     v_ma_Info.MABANKID,
                     v_ma_Info.MAACCOUNTNO,
                     v_ma_Info.Maaccountname,
                     v_meterinfo.MICHARGETYPE,
                     'U',
                     'Y');
    rcount := F_SET_TEXT(2, '000'); --���ؽ��
    rcount := F_SET_TEXT(3, 'ǩԼ�ɹ�'); --����˵��
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '�鲻���û������ݣ����ܲ����ڸ��û�');
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '�����û�����ǩԼ');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '���������쳣�����ϵͳ�޷�����');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
  Note: 111 ǩ�����۹�ϵ��������ˮ����������
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
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
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --ˮ�����Ϻ�
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8);
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10);
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := F_SET_TEXT(1, trim(F_GET_HDTEXT(6))); --������
  
    --ƥ��ˮ�����Ϻ�
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
    v_meterinfo.miname := nvl(v_meterinfo.miname, 'δ��');
    v_ma_Info.Mamid    := v_meterinfo.miid; --����id
  
    --��������ջ����򷵻ش���
    v_meterinfo.MICHARGETYPE := NVL(v_meterinfo.MICHARGETYPE, 'N');
    if v_meterinfo.MICHARGETYPE = 'T' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    --���´�������
    delete meteraccount t where t.mamid = v_ma_Info.Mamid;
    insert into meteraccount t values v_ma_Info;
  
    update meterinfo t
       set t.MICHARGETYPE = 'D'
     WHERE t.MICODE = v_meterinfo.micode;
    --��¼��־
    --sp_dk_log(p_in);
    entrust_sign_log(v_ma_Info.Mamicode,
                     v_meterinfo.miname,
                     v_ma_Info.MABANKID,
                     v_ma_Info.MAACCOUNTNO,
                     v_ma_Info.Maaccountname,
                     v_meterinfo.MICHARGETYPE,
                     'U',
                     'Y');
  
    rcount := F_SET_TEXT(2, '000'); --������
    rcount := F_SET_TEXT(3, 'ǩԼ�ɹ�'); --����˵��
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
  
    /*if v_meterinfo.miname <> trim(p_in(7)) THEN
      p_out(5) := 'ˮ��������ǩԼ�ɹ�';
    END IF;*/
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '�鲻���û������ݣ����ܲ����ڸ��û�');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '�����û�����ǩԼ');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '�û��ṩˮ���û���������ˮ�û�����һ��');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '���������쳣�����ϵͳ�޷�����');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
  Note: 120 ������۹�ϵ
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
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
             '���۽�Լ',
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
    v_ma_Info.Mamicode      := F_GET_HDTEXT(7); --ˮ�����Ϻ�
    v_ma_Info.MAACCOUNTNO   := F_GET_HDTEXT(8);
    v_ma_Info.Maaccountname := F_GET_HDTEXT(10);
    v_ma_Info.Maregdate     := sysdate;
  
    rcount := f_set_item(p_out, trim(F_GET_HDTEXT(6))); --������
  
    --ƥ��ˮ�����Ϻ�
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
  
    --������Ǵ��ۻ����򷵻ش���
    if v_meterinfo.MICHARGETYPE <> 'D' THEN
      RAISE ERR_TS_DK;
    END IF;
  
    select T.*
      INTO v_ma_Info
      FROM meteraccount T
     WHERE T.MAMICODE = v_meterinfo.micode;
    --���в���
    IF v_ma_Info.Mabankid <> p_bankid THEN
      RAISE ERR_BANK;
    END IF;
  
    IF v_ma_Info.Maaccountno <> F_GET_HDTEXT(8) OR
       v_ma_Info.Maaccountname <> F_GET_HDTEXT(10) THEN
      RAISE ERR_ACCOUNT;
    END IF;
  
    --������۹�ϵ
    update meterinfo t
       set t.MICHARGETYPE = 'X'
     WHERE t.MICODE = v_meterinfo.micode;
  
    --delete meteraccount t where t.mamid = v_ma_Info.Mamid;
  
    --��¼��־
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
  
    rcount := F_SET_TEXT(2, '000'); --������
    rcount := F_SET_TEXT(3, '��Լ�ɹ�'); --����˵��
    rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
    rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '�鲻���û������ݣ����ܲ����ڸ��û�');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
    when ERR_TS_DK then
      rcount := F_SET_TEXT(2, '077');
      rcount := F_SET_TEXT(3, '�Ǵ��ۻ��޷���Լ');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '��Ȩ����');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '�˺Ż��˻�����һ��');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
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
      rcount := F_SET_TEXT(3, '���������쳣�����ϵͳ�޷�����');
      rcount := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
      rcount := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
    
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
  Note: 130 ��ѯ�û�ǩԼ״̬
  Input: p_in  -- �����
  Output:p_out --���ذ�
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
    rcount             := F_SET_TEXT(1, trim(F_GET_HDTEXT(6))); --������
    rcount             := F_SET_TEXT(2, '000'); --������
    rcount             := F_SET_TEXT(3, '��Լ�ɹ�'); --����˵��
    rcount             := F_SET_TEXT(4, F_GET_HDTEXT(7)); --ˮ�����Ϻ�
    rcount             := F_SET_TEXT(5, F_GET_HDTEXT(1)); --���б���
    rcount             := F_SET_TEXT(6, '');
    rcount             := F_SET_TEXT(7, '');
    rcount             := F_SET_TEXT(8, '');
    rcount             := F_SET_TEXT(9, '');
    rcount             := F_SET_TEXT(10, '');
  
    --ƥ��ˮ�����Ϻ�
    select t.*
      into v_meterinfo
      from meterinfo t
     where t.MICODE = v_ma_Info.Mamicode;
  
    --������Ǵ��ۻ����򷵻ش���
    if v_meterinfo.MICHARGETYPE <> 'D' THEN
      rcount := F_SET_TEXT(6, to_char(v_ma_Info.Maaccountno));
      rcount := F_SET_TEXT(7, to_char(v_meterinfo.Miname));
      rcount := F_SET_TEXT(8, to_char(v_ma_Info.maaccountname));
      rcount := F_SET_TEXT(9, 'N');
      rcount := F_SET_TEXT(2, '000');
      rcount := F_SET_TEXT(3, '��������');
    
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
      rcount := F_SET_TEXT(3, '��������');
    
    END IF;
  
  exception
    when no_data_found then
      rcount := F_SET_TEXT(2, '001');
      rcount := F_SET_TEXT(3, '�鲻���û������ݣ����ܲ����ڸ��û�');
    
    WHEN OTHERS THEN
      rcount := F_SET_TEXT(2, '003');
      rcount := F_SET_TEXT(3, '���������쳣�����ϵͳ�޷�����');
    
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

  --packetsDT������
  procedure sp_extensiondata(P_ROW IN NUMBER) as
    v_b     number(10);
    v_e     number(10);
    v_row   number(10);
    v_count number(10);
    v_num   number(10);
    DT      packetsDT%ROWTYPE;
  begin
    --��ȡѭ����ֹ��
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
  
    --���ݴ���ѭ������
    v_count := v_e - v_b + 1;
    for v_row in 1 .. v_count loop
      SELECT *
        INTO DT
        FROM packetsDT
       WHERE TO_NUMBER(TRIM(C2)) = v_b + v_row - 1;
    
      --ѭ��������Ĭ�������д���һ��,P_ROW-1
      for v_num in 1 .. P_ROW - 1 loop
        --C2=˳���
        DT.C2 := v_b + v_row - 1 + (v_count * v_num);
        INSERT INTO packetsDT VALUES DT;
      end loop;
    
    end loop;
  end sp_extensiondata;

  /*---------------------------------------------------------------------
  ��¼������־
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
   �� arr ����ת��Ϊ|�ָ����ַ���
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

  /*��¼ǩԼ��־*/
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
  Note:����ʵʱ�ɷ����˹���
  Input:  p_bankid    ���б���,
          p_chg_op    �շ�Ա,
          p_mcode     ˮ�����Ϻ�,
          p_chg_total �ɷѽ��
  output: p_chgno     ����Ϊ������ˮ�����Ϊϵͳʵ����ˮ��,
          p_discharge ���νɷ�Ԥ��ķ���ֵ�����Ϊ����Ԥ�����ӣ����Ϊ������ʹ��Ԥ������˵ֿ�
          p_curr_sav  ���νɷѺ�Ԥ������
  return��1  �޴�ˮ���
          5  ����
          21 ���ݿ����
          22 ��������
  ҵ�����˵����
  1��ˮ�����Ϻ���ȫ��Ƿ�ѱ���һͬ���壻
  2������������;ʱ��������ʵʱ���գ����������ջ����ҳɹ�ʱ��Ԥ�棻
  3������ʱ��ÿ��5:00-23:00
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
  
    v_retstr varchar2(10); --���ؽ��
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --Ӧ����ˮ
    PLIDS    VARCHAR2(1280); --���ձ�������Ӧ����ˮ�б�
    V_RLJE   NUMBER(12, 2); --Ӧ�ս��
    V_ZNJ    NUMBER(12, 2); --���ɽ�
  
    v_LJFJE     NUMBER(12, 2); --�����ѽ��
    v_RLIDS_LJF VARCHAR2(20000); --������Ӧ����ˮ
    v_out_LJFJE NUMBER(12, 2); --���������ʽ��
  
    v_SXF  NUMBER(12, 2); --//������
    v_type varchar2(10); --���ʷ�ʽ
  
    v_FKFS payment.ppayway%type; --  //���ʽ
  
    v_PAYBATCH payment.PBATCH%type; -- //��������  --ok
    v_IFP      varchar2(10); --        , //�Ƿ��Ʊ
    v_INVNO    varchar2(10); -- //��Ʊ��
    v_COMMIT   varchar2(10); -- , //�����Ƿ��ύ
  
    v_discharge number(10, 2); --���νɷѵֿ۽��
    v_curr_sav  number(10, 2); --���νɷѺ�Ԥ����
  
    P_MIID PAYMENT.PMID%TYPE; --ˮ�����Ϻ�
    v_pid       payment.pid%type;
    rcount number(10);
    v_zbqf number(10);
  
    cursor c_hs_meter(c_miid varchar2) is
      select miid from meterinfo where mipriid = c_miid;
  
    v_hs_meter meterinfo%rowtype;
    v_hs_rlids varchar2(1280); --Ӧ����ˮ
    v_hs_rlje  number(12, 2); --Ӧ�ս��
    v_hs_znj   number(12, 2); --���ɽ�
    v_hs_sxf   number(12, 2); --������
    v_hs_outje number(12, 2);
    v_qfnum    number(10); --Ӧ���˱���
  
  begin
    BEGIN
      SELECT * into mi FROM METERINFO T WHERE MICODE = p_mcode;
    EXCEPTION
      WHEN OTHERS THEN
        --�û�������
        return '001';
    END;
    begin
      --ͳ��Ƿ�Ѽ�¼��
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
      return '003'; --����
    end if;*/
  
    v_FKFS     := 'XJ';
    V_PAYBATCH := fgetsequence('ENTRUSTLOG');
    V_IFP      := 'N';
    V_INVNO    := NULL;
    V_COMMIT   := 'N';
  
    ------�����ѵĸ�ֵ 20120926
    v_LJFJE     := 0;
    v_RLIDS_LJF := 0;
    v_out_LJFJE := 0;
  
    v_LJFJE := v_LJFJE - v_out_LJFJE;
  
    IF v_out_LJFJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS THEN
      return '005'; --����
    END IF;
  
    IF v_RLJE + v_ZNJ + v_SXF + v_LJFJE - nvl(mi.misaving, 0) > p_chg_total THEN
      IF substr(p_chg_op,1,3) = 'ATM' THEN
        v_type := '01';
         P_MIID := mi.miid;
      ELSE
         return '005'; --��ATM���ɷѱ������Ƿ��
      END IF;
    END IF;
  
    /*  --�������Ѳ���
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
  
    -------------20130922 ���Ӻ��ձ������ж�-----------------------
    ---�����Ƿ�ѣ�Ϊʵ�ս���   
    if v_qfnum > 0 then
      -----��ֵ
      if mi.mipriflag = 'N' then
        v_type := '01';
        P_MIID := mi.miid;
      else
        v_type := '02';
        P_MIID := mi.mipriid;
      
        --�������ӱ���û��Ƿ�ѣ���Ƿ����תΪ������ɷ�
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
      
        --����pay_para_tmp �������ձ�����׼��
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
      -------------20130922 ���Ӻ��ձ������ж�end-----------------------
    
      ----�����Ƿ���ǵ���Ԥ��
    else
      v_type := '01';
      P_MIID := mi.miid;
    end if;
  
    --����
    v_retstr := PG_EWIDE_PAY_01.POS(v_type, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                    p_bankid, --�ɷѻ���
                                    p_chg_op, --�տ�Ա
                                    v_RLIDS, --Ӧ����ˮ��
                                    v_RLJE, --Ӧ���ܽ��
                                    v_ZNJ, --����ΥԼ��
                                    v_SXF, --������
                                    p_chg_total, --ʵ���տ�
                                    p_trans, --�ɷ�����
                                    P_MIID, --ˮ�����Ϻ�
                                    v_FKFS, --���ʽ
                                    p_bankid, --�ɷѵص�
                                    v_PAYBATCH, --��������
                                    v_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                    v_INVNO, --��Ʊ��
                                    v_COMMIT --�����Ƿ��ύ��Y/N��
                                    );
  
    if v_retstr <> '000' then
      return '021'; --�ɷѴ���
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
  
    v_retstr varchar2(10); --���ؽ��
    V_OUTJE  NUMBER(12, 2);
    V_RLIDS  VARCHAR2(20000); --Ӧ����ˮ
    PLIDS    VARCHAR2(1280); --���ձ�������Ӧ����ˮ�б�
    V_RLJE   NUMBER(12, 2); --Ӧ�ս��
    V_ZNJ    NUMBER(12, 2); --���ɽ�
  
    v_LJFJE     NUMBER(12, 2); --�����ѽ��
    v_RLIDS_LJF VARCHAR2(20000); --������Ӧ����ˮ
    v_out_LJFJE NUMBER(12, 2); --���������ʽ��
  
    v_SXF  NUMBER(12, 2); --//������
    v_type varchar2(10); --���ʷ�ʽ
  
    v_FKFS payment.ppayway%type; --  //���ʽ
  
    v_PAYBATCH payment.PBATCH%type; -- //��������  --ok
    v_IFP      varchar2(10); --        , //�Ƿ��Ʊ
    v_INVNO    varchar2(10); -- //��Ʊ��
    v_COMMIT   varchar2(10); -- , //�����Ƿ��ύ
  
    v_discharge number(10, 2); --���νɷѵֿ۽��
    v_curr_sav  number(10, 2); --���νɷѺ�Ԥ����
  
    P_MIID PAYMENT.PMID%TYPE; --ˮ�����Ϻ�
    v_pid       payment.pid%type;
    rcount number(10);
    v_zbqf number(10);
  
    cursor c_hs_meter(c_miid varchar2) is
      select miid from meterinfo where mipriid = c_miid;
  
    v_hs_meter meterinfo%rowtype;
    v_hs_rlids varchar2(1280); --Ӧ����ˮ
    v_hs_rlje  number(12, 2); --Ӧ�ս��
    v_hs_znj   number(12, 2); --���ɽ�
    v_hs_sxf   number(12, 2); --������
    v_hs_outje number(12, 2);
    v_qfnum    number(10); --Ӧ���˱���
  
  begin
    BEGIN
      SELECT * into mi FROM METERINFO T WHERE MICODE = p_mcode;
    EXCEPTION
      WHEN OTHERS THEN
        --�û�������
        return '001';
    END;
 /*   begin
      --ͳ��Ƿ�Ѽ�¼��
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
      return '003'; --����
    end if;*/
  
    v_FKFS     := 'XJ';
    V_PAYBATCH := fgetsequence('ENTRUSTLOG');
    V_IFP      := 'N';
    V_INVNO    := NULL;
    V_COMMIT   := 'N';
  
    ------�����ѵĸ�ֵ 20120926
/*    v_LJFJE     := 0;
    v_RLIDS_LJF := 0;
    v_out_LJFJE := 0;
  
    v_LJFJE := v_LJFJE - v_out_LJFJE;
  
    IF v_out_LJFJE > 0 and p_trans = PG_EWIDE_PAY_01.PAYTRANS_DS THEN
      return '005'; --����
    END IF;
  
    IF v_RLJE + v_ZNJ + v_SXF + v_LJFJE - nvl(mi.misaving, 0) > p_chg_total THEN
      IF substr(p_chg_op,1,3) = 'ATM' THEN
        v_type := '01';
         P_MIID := mi.miid;
      ELSE
         return '005'; --��ATM���ɷѱ������Ƿ��
      END IF;
    END IF;*/
  
    /*  --�������Ѳ���
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
  
    -------------20130922 ���Ӻ��ձ������ж�-----------------------
    ---�����Ƿ�ѣ�Ϊʵ�ս���   
  /*  if v_qfnum > 0 then
      -----��ֵ
      if mi.mipriflag = 'N' then
        v_type := '01';
        P_MIID := mi.miid;
      else
        v_type := '02';
        P_MIID := mi.mipriid;
      
        --�������ӱ���û��Ƿ�ѣ���Ƿ����תΪ������ɷ�
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
      
        --����pay_para_tmp �������ձ�����׼��
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
      -------------20130922 ���Ӻ��ձ������ж�end-----------------------
    
      ----�����Ƿ���ǵ���Ԥ��
    else
      v_type := '01';
      P_MIID := mi.miid;
    end if;*/
    
    v_type := '02';
    P_MIID := mi.mipriid;
  
    --����
    v_retstr := PG_EWIDE_PAY_01.POS(v_type, --���ʷ�ʽ 01 ����ɷ� 02 ���ձ�ɷ� 03 ���ɷ�
                                    p_bankid, --�ɷѻ���
                                    p_chg_op, --�տ�Ա
                                    v_RLIDS, --Ӧ����ˮ��
                                    v_RLJE, --Ӧ���ܽ��
                                    v_ZNJ, --����ΥԼ��
                                    v_SXF, --������
                                    p_chg_total, --ʵ���տ�
                                    p_trans, --�ɷ�����
                                    P_MIID, --ˮ�����Ϻ�
                                    v_FKFS, --���ʽ
                                    p_bankid, --�ɷѵص�
                                    v_PAYBATCH, --��������
                                    v_IFP, --�Ƿ��Ʊ  Y ��Ʊ��N����Ʊ�� R Ӧ��Ʊ
                                    v_INVNO, --��Ʊ��
                                    v_COMMIT --�����Ƿ��ύ��Y/N��
                                    );
  
    if v_retstr <> '000' then
      return '021'; --�ɷѴ���
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
  /*����ʵʱ�ɷѳ���----------------------------------------------------------------------
   p_bankid:���д���
   p_transno:������������ˮ
   p_date :���н�������
   return��
         6�����ײ�����
         21�����ݿ������
         22����������
  ------------------------------------------------------------------------------------------*/
  function f_bank_discharged(p_bankid  in varchar2,
                             p_transno in varchar2,
                             p_meterno in varchar2,
                             p_date    in date) return number as
    v_retstr varchar2(10);
  begin
    --���ʵ��
    v_retstr := f_bank_dischargeone(p_bankid, p_transno, p_meterno, p_date);
    if v_retstr = '000' then
      return 0;
    elsif v_retstr = '006' then
      --���ײ�����
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
    v_BATCH  PAYMENT.PBATCH%TYPE; --����ˮ�ɷ���ˮ
    v_PPER   PAYMENT.PPER%TYPE; --����Ա
    v_TRANS  PAYMENT.PPER%TYPE; --����
    rcount   number(10);
    v_retstr varchar2(20);
  begin
    --���ʵ��
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
     --�������˭�����ļӽ�����ʵ��һ��BY 20141229��
    -- SELECT FGETPBOPER INTO v_PPER FROM DUAL;
    exception
      when others then
        return '006'; --���ײ�����
    end;
    --���ͻ�����
    v_TRANS := 'X';
    if v_BATCH is not null then
      v_retstr := PG_EWIDE_PAY_01.F_PAYBACK_BY_BATCH(v_BATCH, --����ˮ�ɷ���ˮ
                                                     p_bankid, --����
                                                     v_PPER, --����Ա
                                                     p_bankid, --����
                                                     v_TRANS --����
                                                     
                                                     );
    else
    
      return '006'; --���ײ�����                                               
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

  --���в���
  function f_bank_charged_total(p_bankid    in varchar2, --����
                                p_chg_op    in varchar2, --����Ա
                                p_mcode     in varchar2, --����
                                p_chg_total in number, --�ɷѽ��
                                p_chg_no    in varchar2, --������ˮ
                                p_paydate   in varchar2 --��������
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
    --��ˮ����
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
      --����
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
  
    --��ԭ���ʱ�־
    --ˮ��
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
      --'�޴�ˮ���'
      return 1;
    elsif v_str = '004' then
      --'����'
      return 5;
    elsif v_str = '002' then
      --'���ݿ����'
      return 21;
    elsif v_str = '005' or v_str = '007' then
      --'���ݿ����'
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
  
  function f_bank_charged_total_pz(p_bankid    in varchar2, --����
                                p_chg_op    in varchar2, --����Ա
                                p_mcode     in varchar2, --����
                                p_chg_total in number, --�ɷѽ��
                                p_chg_no    in varchar2, --������ˮ
                                p_paydate   in varchar2 --��������
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
    --��ˮ����
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
      --����
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
  
    --��ԭ���ʱ�־
    --ˮ��
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
      --'�޴�ˮ���'
      return 1;
    elsif v_str = '004' then
      --'����'
      return 5;
    elsif v_str = '002' then
      --'���ݿ����'
      return 21;
    elsif v_str = '005' or v_str = '007' then
      --'���ݿ����'
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

  --���ж��ˣ���������ˮ������Ϣ��
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

     --֧�ֶ���ֹ����ˣ�����ǰ��ɾ��֮ǰ�ļ�¼
    --ɾ��������ϸ
    delete bank_dz_mx
     where id = (select b.id
                   from bankchklog_new b
                  where bankcode = p_smfid
                    and chkdate = p_date);

    --ɾ��������ˮ               
    delete bankchklog_new
     where bankcode = p_smfid
       and chkdate = p_date;
  
    --���ö����ļ���־λ
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
            AND T.PTRANS NOT IN ( 'E','K','U')   --���ڵ����е����ʲ������ڱ�������������ˮ������    by cdh    2015/08/31 ����ģ�⽻��QҲ�����ڶ�����ϸ�� 2016.12.13 byj
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
    --���ձ�ˮ����α�
    cursor c_meterid is
      select micode from meterinfo where mipriid = p_pmiid;
  
    v_meterid  meterinfo.micode%type; --�ͻ�����
    v_sfdj     number(12, 3); --ˮ�ѵ���
    v_wsfdj    number(12, 3); --��ˮ�ѵ���
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
      --��ˮ�ѵ��ۺ���ˮ�ѵ���
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
    --�Ƚϵ����Ƿ���ͬ
    if v_sumsfdj = v_sfdj * v_count and v_sumwsfdj = v_wsfdj * v_count then
      v_ret := 'Y';
    else
      v_ret := 'N';
    end if;
    return v_ret;
  
  end f_priceissame;

  --��ȡ�û��˿���
  function f_getcardno(p_rlcid in varchar2) return varchar2 as
    v_ret varchar2(14);
  begin
    select mibfid || mirorder
      into v_ret
      from meterinfo mi
     where mi.micid = p_rlcid;
    return v_ret;
  end;

  --���븶�ʽ
  function f_getpayway(p_ppayway in varchar2) return varchar2 as
    v_ret varchar2(20);
  begin
    select sclvalue
      into v_ret
      from syscharlist
     where sclid = p_ppayway
       and scltype = '���׷�ʽ';
    return v_ret;
  end;
  
   --�ж����н��׿���
FUNCTION F_GETBANKSYSPARA(P_BANKID IN VARCHAR2) RETURN VARCHAR2 AS
  LRET   VARCHAR2(20);
  P_SPID VARCHAR2(20);
BEGIN
  --��ȡ�������
  IF P_BANKID = '030101' THEN
    --��ͨ����(030101)
    P_SPID := 'B001';
  ELSIF P_BANKID = '030201' THEN
    --��������(030201)
    P_SPID := 'B002';
  ELSIF P_BANKID = '030301' THEN
    --��������(030301)
    P_SPID := 'B003';
  ELSIF P_BANKID = '030401' THEN
    --����������(030401)
    P_SPID := 'B004';
  ELSIF P_BANKID = '030501' THEN
    --�й�����(030501)
    P_SPID := 'B005';
  ELSIF P_BANKID = '030601' THEN
    --�������(030601)
    P_SPID := 'B006';
  ELSIF P_BANKID = '030701' THEN
    --��������(030701)
    P_SPID := 'B007';
  ELSIF P_BANKID = '030801' THEN
    --��������(030801)
    P_SPID := 'B008';
    ELSIF P_BANKID = '030901' THEN
    --��ҵ����(030901)
    P_SPID := 'B009';
      ELSIF P_BANKID = '031001' THEN
    --��������(031001)
    P_SPID := 'B010';
      ELSIF P_BANKID = '031101' THEN
    --��������(031101)
    P_SPID := 'B011';
  END IF;
  --��ѯ����״̬
  SELECT SPVALUE INTO LRET FROM SYSPARA WHERE SPID = P_SPID;
  RETURN LRET;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END;

  --�������н��׿���
PROCEDURE P_SETBANKSYSPARA(P_BANKID IN VARCHAR2,P_TYPE IN VARCHAR2,P_COMMIT IN VARCHAR2) AS
  P_SPID VARCHAR2(20);
BEGIN
  --��ȡ�������
  IF P_BANKID = '030101' THEN
    --��ͨ����(030101)
    P_SPID := 'B001';
  ELSIF P_BANKID = '030201' THEN
    --��������(030201)
    P_SPID := 'B002';
  ELSIF P_BANKID = '030301' THEN
    --��������(030301)
    P_SPID := 'B003';
  ELSIF P_BANKID = '030401' THEN
    --����������(030401)
    P_SPID := 'B004';
  ELSIF P_BANKID = '030501' THEN
    --�й�����(030501)
    P_SPID := 'B005';
  ELSIF P_BANKID = '030601' THEN
    --�������(030601)
    P_SPID := 'B006';
  ELSIF P_BANKID = '030701' THEN
    --��������(030701)
    P_SPID := 'B007';
  ELSIF P_BANKID = '030801' THEN
    --��������(030801)
    P_SPID := 'B008';
        ELSIF P_BANKID = '030901' THEN
    --��ҵ����(030901)
    P_SPID := 'B009';
      ELSIF P_BANKID = '031001' THEN
    --��������(031001)
    P_SPID := 'B010';
      ELSIF P_BANKID = '031101' THEN
    --��������(031101)
    P_SPID := 'B011';
  END IF;
  --���ÿ���״̬
  UPDATE SYSPARA SET SPVALUE = P_TYPE WHERE SPID = P_SPID;
  
  IF P_COMMIT='Y' THEN
     COMMIT;
  END IF;
  
END;

--�Զ���������
PROCEDURE SP_AUTOBANKZZ AS
  CURSOR C_BANKID IS
    SELECT SMFID
      FROM SYSMANAFRAME
     WHERE SMFPID LIKE '03%'
       AND SMFCLASS = '3'
     ORDER BY SMFID;

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  MB        MI_BANKZZ%ROWTYPE; --�������α���
  V_CHKDATE DATE; --ϵͳ��������

BEGIN
  --����������ÿ���賿1�������������Ƿ����ʣ����δ�������Զ�����
  V_CHKDATE := TRUNC(SYSDATE) - 1;

  OPEN C_BANKID;
  LOOP
    FETCH C_BANKID
      INTO V_SMFID.SMFID;
    EXIT WHEN C_BANKID%NOTFOUND OR C_BANKID%NOTFOUND IS NULL;
    ---�жϵ����Ƿ�����
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
      --�������δ������������ʼ�¼
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --���˱�� 
        FROM DUAL;
      MB.BANKID := V_SMFID.SMFID; --���б��� 
      MB.ZZDATE := V_CHKDATE; --�������� 
      MB.CZDATE := SYSDATE; --����ʱ�� 
      MB.ZZFROM := 'S';--ϵͳ����
      INSERT INTO MI_BANKZZ VALUES MB;
    
      --����ʵ�ռ�¼,�ɷ����ڽ��������죬����������
      UPDATE PAYMENT
         SET PCHKDATE = MB.ZZDATE, --��������
             PCHKNO   = MB.DZNO --���˵���
       WHERE PPOSITION = MB.BANKID
         AND PDATE <= V_CHKDATE --�������� 
         AND PDATE >= TO_DATE('2014-04-17','YYYY-MM-DD')
         AND PCHKNO IS NULL;
    END IF;
  
  END LOOP;
  CLOSE C_BANKID;
  
  COMMIT;

END SP_AUTOBANKZZ;

--�Զ����������ֶ�����  hb test ��0716�չ�������δ���������Զ����ʣ���̨jobʧЧ.���ֶ���������
PROCEDURE SP_AUTOBANKZZ_�ֶ� AS
  CURSOR C_BANKID IS
    SELECT SMFID
      FROM SYSMANAFRAME
     WHERE SMFPID LIKE '03%'
       AND SMFCLASS = '3'
       and SMFid in('030401','030301')
     ORDER BY SMFID;

  V_SMFID   SYSMANAFRAME%ROWTYPE;
  MB        MI_BANKZZ%ROWTYPE; --�������α���
  V_CHKDATE DATE; --ϵͳ��������

BEGIN
  --����������ÿ���賿1�������������Ƿ����ʣ����δ�������Զ�����
 -- V_CHKDATE := TRUNC(SYSDATE) - 1;
  select trunc(to_date('20160331','yyyymmdd'))  into V_CHKDATE from dual;

  OPEN C_BANKID;
  LOOP
    FETCH C_BANKID
      INTO V_SMFID.SMFID;
    EXIT WHEN C_BANKID%NOTFOUND OR C_BANKID%NOTFOUND IS NULL;
    ---�жϵ����Ƿ�����
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
      --�������δ������������ʼ�¼
      SELECT TRIM(TO_CHAR(SEQ_BILLSEQNO.NEXTVAL, '0000000000'))
        INTO MB.DZNO --���˱�� 
        FROM DUAL;
      MB.BANKID := V_SMFID.SMFID; --���б��� 
      MB.ZZDATE := V_CHKDATE; --�������� 
      MB.CZDATE := SYSDATE; --����ʱ�� 
      MB.ZZFROM := 'S';--ϵͳ����
      INSERT INTO MI_BANKZZ VALUES MB;
    
      --����ʵ�ռ�¼,�ɷ����ڽ��������죬����������
      UPDATE PAYMENT
         SET PCHKDATE = MB.ZZDATE, --��������
             PCHKNO   = MB.DZNO --���˵���
       WHERE PPOSITION = MB.BANKID
         AND PDATE <= V_CHKDATE --�������� 
         AND PDATE >= TO_DATE('2016-03-31','YYYY-MM-DD')
         AND PCHKNO IS NULL;
    END IF;
  
  END LOOP;
  CLOSE C_BANKID;
  
  COMMIT;

END SP_AUTOBANKZZ_�ֶ�;

 --�Զ�����ƽ��
PROCEDURE SP_AUTOBANKPZ(P_DATE IN DATE, P_SMFID IN VARCHAR2) AS

  CURSOR C_BANK_DZ(P_ID IN VARCHAR2) IS
    SELECT * FROM BANK_DZ_MX T WHERE T.ID = P_ID;

  V_CHKID   VARCHAR2(10);
  L_RESULT  NUMBER;
  V_COUNT   NUMBER;
  V_BANK_DZ BANK_DZ_MX%ROWTYPE;
  V_PATH    VARCHAR2(200);

BEGIN

  --�����Ƿ��ж����ļ�
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

  --����޶����ļ����ղ��Զ�ƽ��
  IF V_COUNT <= 0 THEN
    RETURN;
  END IF;

  --��ȡ������ˮ��
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
    --����ˮ������
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '2' THEN
      L_RESULT := F_BANK_DISCHARGED(P_SMFID,
                                    V_BANK_DZ.CHARGENO,
                                    V_BANK_DZ.METERNO,
                                    V_BANK_DZ.TRANDATE);
      IF L_RESULT = 0 THEN
        --����
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    
    END IF;
    --���е�����
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '1' THEN
      L_RESULT := F_BANK_CHARGED_TOTAL(P_SMFID,
                                       'SYSTEM',
                                       V_BANK_DZ.METERNO,
                                       V_BANK_DZ.MONEY_BANK,
                                       '',
                                       P_DATE);
      IF L_RESULT = 0 THEN
        --����
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    END IF;
    --������
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
 
 
  --�����Ƿ��ж����ļ�
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

  --����޶����ļ����ղ��Զ�ƽ��
  IF V_COUNT <= 0 THEN
    RETURN;
  END IF;

  --��ȡ������ˮ��
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
    --����ˮ������
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '2' THEN
      L_RESULT := F_BANK_DISCHARGED(P_SMFID,
                                    V_BANK_DZ.CHARGENO,
                                    V_BANK_DZ.METERNO,
                                    V_BANK_DZ.TRANDATE);
      IF L_RESULT = 0 THEN
        --����
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    
    END IF;
    --���е�����
    IF V_BANK_DZ.CZ_FLAG = 'N' AND V_BANK_DZ.DZ_FLAG = '1' THEN
      L_RESULT := F_BANK_CHARGED_TOTAL(P_SMFID,
                                       'SYSTEM',
                                       V_BANK_DZ.METERNO,
                                       V_BANK_DZ.MONEY_BANK,
                                       '',
                                       P_DATE);
      IF L_RESULT = 0 THEN
        --����
        UPDATE BANK_DZ_MX
           SET CZ_FLAG = 'Y', CHKDATE = SYSDATE
         WHERE ID = V_CHKID
           AND CHARGENO = V_BANK_DZ.CHARGENO;
      END IF;
    END IF;
    --������
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

