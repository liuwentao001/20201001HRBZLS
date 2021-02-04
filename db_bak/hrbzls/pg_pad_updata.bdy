CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_PAD_UPDATA IS

  /*
  * ���ܣ��ϴ�������
  * ������:������
  * ����ʱ�䣺2014-06-22
  * �޸��ˣ�  08001|00028|0560044063|2014-06-11|1890|30|����|Y|8337|
  *            Э����|Э�鳤��|����|��������|����ֹ��|����ˮ��|������|�������|����Ա���|����ע
              5|5|10|10|10|10|20|5|20|200
  * �޸�ʱ�䣺
  */
  procedure main(i_trans_code IN varchar2,
                 i_in_trans   IN VARCHAR2,
                 o_out_trans  OUT VARCHAR2) IS
  
    V_COUNT      NUMBER;
    V_LOG_TRANS  LOG_TRANS%ROWTYPE;
    V_TRANS_CODE NUMBER;
    V_SEQ        VARCHAR2(20);
  
  BEGIN
    --Э����
    V_TRANS_CODE           := TO_NUMBER(SUBSTR(i_in_trans, 1, 5));
    V_LOG_TRANS.TRANS_CODE := V_TRANS_CODE;
    --������־��Ϣ
    SELECT SEQ_TRANS.NEXTVAL INTO V_SEQ FROM DUAL;
    V_LOG_TRANS.TRANS_TASK_NO     := V_SEQ;
    V_LOG_TRANS.TRANS_NOTE        := i_in_trans;
    V_LOG_TRANS.TRANS_HAPPEN_DATE := SYSDATE;
    V_LOG_TRANS.TRANS_INPUT_INFO  := '';
    INSERT INTO LOG_TRANS VALUES V_LOG_TRANS;
    COMMIT;
  
    if V_TRANS_CODE = 8001 then
      --��������ʱδʹ��
      f8001(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8002 then
      --�û������ϴ�
      f8002(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8003 then
      --���������ϴ�
      f8003(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8004 then
      --������֤
      f8004(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8005 then
      --�����汾��֤
      f8005(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8006 then
      --����ȡ��Э��
      f8006(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8007 then
      --�û�Ѳ��
      f8007(i_in_trans, V_SEQ, o_out_trans);
    elsif V_TRANS_CODE = 8008 then
      --�û�ͼƬ�����ϴ�
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
         SET T.TRANS_RESULT = '0', T.TRANS_RETURN_NOTE = '�ϴ�ʧ��'
       WHERE T.TRANS_TASK_NO = V_SEQ;*/
      o_out_trans := o_out_trans || sqlerrm;
      UPDATE LOG_TRANS T --����888�п���������ʱ�����ظ��ϴ�����.
         SET T.TRANS_RESULT = '999', T.TRANS_RETURN_NOTE = o_out_trans
       WHERE T.TRANS_TASK_NO = V_SEQ;
      /* raise_application_error( -20002, sqlerrm);
      dbms_output.put_line(sqlerrm);*/
      COMMIT;
    
  end;

  /*
  * ���ܣ�8001Э��
  * ������:������
  * ����ʱ�䣺2014-08-28
  * �޸��ˣ�  
  * �޸�ʱ�䣺
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
    v_MRIFGU          meterread.mrifgu%type; --������� 
    v_MRPRIVILEGEMEMO meterread.mrprivilegememo%type; --���ͼƬ������
    -- v_count number;
    v_rlje    number(13, 0);
    v_message VARCHAR2(200);
    v_mrid    meterread.mrid%type;
    v_MRIFREC meterread.MRIFREC%type;
  
  begin
    return;
    --����
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
    --��������
    V_COPY_DATE := TRIM(SUBSTR(i_in_trans, 24, 10));
    --����ֹ��
    V_COPY_ECODE := TRIM(SUBSTR(i_in_trans, 35, 10));
    --����ˮ��
    V_COPY_SL := TRIM(SUBSTR(i_in_trans, 46, 10));
    --������
    V_COPY_BK := TRIM(SUBSTR(i_in_trans, 57, 20));
    --�������
    V_SUBMIT := TRIM(SUBSTR(i_in_trans, 78, 5));
    --����Ա���
    V_COPER_MEMBER := TRIM(SUBSTR(i_in_trans, 84, 20));
    --����ע
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
     where mrmid = V_USER_NO; --�Ƿ������
  
    --v_count ��ʾ�����Ѿ�����
    if v_MRIFREC = 'Y' then
      o_out_trans := '|999|08001';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,�����',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
    else
      if to_char(sysdate, 'yyyy-MM') =
         to_char(to_date(V_COPY_DATE, 'yyyy-MM-dd'), 'yyyy-MM') then
        UPDATE METERREAD t
           SET mrdatasource = '9', --��ʾ�ֻ������ϴ�
               MROUTFLAG    = 'N',
               mrinorder    = nvl(mrinorder, 0) + 1,
               mrindate     = sysdate,
               mrinputper   = V_COPER_MEMBER,
               --     mrifsubmit   = V_SUBMIT,  �Ƿ񳭱���˷ŵ�Ӫ������� 20150313
               mrreadok = 'Y',
               --mrecodechar  = ����ֹ��λ������(V_COPY_ECODE, MRMCODE),
               mrecodechar     = V_COPY_ECODE,
               MRSL            = V_COPY_SL,
               MRECODE         = V_COPY_ECODE,
               mrrdate         = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
               mrpdardate      = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
               mrinputdate     = sysdate,
               MRFACE         =
               (select SFLFLAG1 from sysfacelist2 t where sflid = V_COPY_BK), --����̬
               mrface2         = V_COPY_BK, --����̬
               mrmemo          = v_cb_memo,
               MRPRIVILEGEMEMO = v_MRPRIVILEGEMEMO, --�����ֻ�ͼƬ����
               MRIFGU          = v_mrifgu --�������
         WHERE mrmid = V_USER_NO
           AND MRIFREC = 'N';
      
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '000',
               T.TRANS_RETURN_NOTE = '�ϴ��ɹ�',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        o_out_trans := '|000|08001';
      else
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '111',
               T.TRANS_RETURN_NOTE = '�����ϴ�ʧ��',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        o_out_trans := '|999|08001';
      end if;
    
    end if;
  
    COMMIT;
  
  end;

  /*
   * ���ܣ�8002Э��
   * ������:������ 
   * ����ʱ�䣺2014-08-28
   *  Э����|Э�鳤��|��λ��|��ϵ��|��ϵ�绰|�ƶ��绰|����Ա���|��������|����ע
  ��*����5|5|10|50|20|20|20|50|200
   * �޸��ˣ�  
   * �޸�ʱ�䣺
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
    V_USERNm          VARCHAR2(60); --�û�����
    v_MIPFID          varchar2(10); --��ˮ����
    v_MDCALIBER       meterdoc.mdcaliber%type; --�ھ� 
    v_MDNO            meterdoc.mdno%type; --������
    v_DQGFH           meterdoc.DQGFH%type; --�շ��
    v_DQSFH           meterdoc.DQSFH%type; --�ܷ��
    v_qfh             meterdoc.qfh%type; --Ǧ���
    v_JCGFH           meterdoc.JCGFH%type; --������
    v_MRREQUISITION   meterread.MRREQUISITION%type;
    v_MRPRIVILEGEFLAG meterread.MRPRIVILEGEFLAG%type; --��������״̬
    v_MISIDE          meterinfo.miside%type; --��λ��
    v_dy              char(1);
    v_cb_month        VARCHAR2(7); --�����·�
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
    --����|�û�����|��ˮ����|�ھ�|������|�շ��|�ܷ��|Ǧ���|������|�Ƿ��ӡ|�����·�|�û���ַ|���������־|��λ�� 
    --����|60|30|5|20|40|40|20|40|1|7|100|20|20
  
  begin
    if length(i_in_trans) <> 825 then
      --����
      V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
      --��ϵ��
      V_LINK_MAN := TRIM(SUBSTRb(i_in_trans, 24, 50));
      --��ϵ�绰
      V_CONNECT_PHONE := TRIM(SUBSTR(i_in_trans, 75, 20));
      --�ƶ��绰
      V_TEL_PHONE := TRIM(SUBSTR(i_in_trans, 96, 20));
      --����Ա���
      V_COPER_NO := TRIM(SUBSTR(i_in_trans, 117, 20));
      --��������
      V_YQTX := TRIM(SUBSTR(i_in_trans, 138, 50));
      --�û���ע
      V_CBBZ := TRIM(SUBSTR(i_in_trans, 189, 200));
      --�û�����
      V_USERNm := TRIM(SUBSTR(i_in_trans, 390, 60));
      --��ˮ����
      v_MIPFID := TRIM(SUBSTR(i_in_trans, 451, 30));
      --�ھ�
      v_MDCALIBER := to_number(TRIM(SUBSTR(i_in_trans, 482, 2)));
      --������
      v_MDNO := TRIM(SUBSTR(i_in_trans, 485, 20));
      --�շ��
      v_DQGFH := TRIM(SUBSTR(i_in_trans, 506, 40));
      --�ܷ��
      v_DQSFH := TRIM(SUBSTR(i_in_trans, 547, 40));
      --Ǧ���
      v_qfh := TRIM(SUBSTR(i_in_trans, 588, 20));
      --������
      v_JCGFH := TRIM(SUBSTR(i_in_trans, 609, 40));
      --��ӡע��
      v_dy := TRIM(SUBSTR(i_in_trans, 650, 1));
      --�����Ƿ�����
      v_cb_month := TRIM(SUBSTR(i_in_trans, 652, 7));
      -- �û���ַ
      v_adr := TRIM(SUBSTR(i_in_trans, 660, 100));
      --���빤���û�����״̬ δ����   ������   δͨ��   ͨ��
      V_apply_flag := TRIM(SUBSTR(i_in_trans, 761, 20));
      --ˮ��λ��
      v_MISIDE := TRIM(SUBSTR(i_in_trans, 782, 20));
      --�޸�ʱ�� 
    
      begin
        v_apply_date := to_date(TRIM(SUBSTR(i_in_trans, 803, 20)),
                                'yyyymmddhh24miss');
      exception
        when others then
          v_apply_date := sysdate;
      end;
    
    else
      --����
      V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
      --��ϵ��
      V_LINK_MAN := TRIM(SUBSTRb(i_in_trans, 24, 50));
      --��ϵ�绰
      V_CONNECT_PHONE := TRIM(SUBSTR(i_in_trans, 75, 20));
      --�ƶ��绰
      V_TEL_PHONE := TRIM(SUBSTR(i_in_trans, 96, 20));
      --����Ա���
      V_COPER_NO := TRIM(SUBSTR(i_in_trans, 117, 20));
      --��������
      V_YQTX := TRIM(SUBSTR(i_in_trans, 138, 50));
      --�û���ע
      V_CBBZ := TRIM(SUBSTR(i_in_trans, 189, 200));
      --�û�����
      V_USERNm := TRIM(SUBSTR(i_in_trans, 390, 60));
      --��ˮ����
      v_MIPFID := TRIM(SUBSTR(i_in_trans, 451, 30));
      --�ھ�
      v_MDCALIBER := to_number(TRIM(SUBSTR(i_in_trans, 482, 5)));
      --������
      v_MDNO := TRIM(SUBSTR(i_in_trans, 488, 20));
      --�շ��
      v_DQGFH := TRIM(SUBSTR(i_in_trans, 509, 40));
      --�ܷ��
      v_DQSFH := TRIM(SUBSTR(i_in_trans, 550, 40));
      --Ǧ���
      v_qfh := TRIM(SUBSTR(i_in_trans, 591, 20));
      --������
      v_JCGFH := TRIM(SUBSTR(i_in_trans, 612, 40));
      --��ӡע��
      v_dy := TRIM(SUBSTR(i_in_trans, 653, 1));
      --�����Ƿ�����
      v_cb_month := TRIM(SUBSTR(i_in_trans, 655, 7));
      -- �û���ַ
      v_adr := TRIM(SUBSTR(i_in_trans, 663, 100));
      --���빤���û�����״̬ δ����   ������   δͨ��   ͨ��
      V_apply_flag := TRIM(SUBSTR(i_in_trans, 764, 20));
      --ˮ��λ��
      v_MISIDE := TRIM(SUBSTR(i_in_trans, 785, 20));
      --�޸�ʱ�� 
    
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
         where �ֵ�����='�����Ƿ�����' and �ֵ�code =v_cb_month;
         if v_count= 0 then --�жϱ����Ƿ�����������������
             v_message:='�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������'||v_cb_month;
           -- v_message:= v_apply_date;
                o_out_trans := '|999|08002' ;
            o_out_trans :=o_out_trans||'|'|| v_message ;
             UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
             commit; 
             return ;
         end if ;
    EXCEPTION
       WHEN OTHERS THEN
              v_message:='�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������';
              o_out_trans := '|999|08002' ;
            o_out_trans :=o_out_trans||'|'|| v_message ;
             UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
             commit; 
             return ;
    END ; */
    --apply_flag    δ����   ������   δͨ��   ͨ��  
    if V_apply_flag = 'δ����' then
      V_MRPRIVILEGEFLAG := 'N';
    ELSIF V_apply_flag = '������' then
      V_MRPRIVILEGEFLAG := 'X';
    ELSIF V_apply_flag = 'δͨ��' then
      V_MRPRIVILEGEFLAG := 'U';
    ELSIF V_apply_flag = '��ͨ��' then
      V_MRPRIVILEGEFLAG := 'Y';
    END IF;
  
    if v_dy = 'Y' THEN
      v_MRREQUISITION := 1; --��ӡ����
    END IF;
  
    select * into v_mi from meterinfo where miid = V_USER_NO;
    select * into v_ci from custinfo where CIID = V_USER_NO;
    select * into v_md from meterdoc where MDMID = V_USER_NO;
    select * into v_ma from meteraccount where mamid = V_USER_NO;
    --'CF','����','GJ','�ܾ�','QT','����','TJ','�쾮','CS','������'
    /*    if v_MISIDE ='����' then  
      v_mi.miside :='CF';
    ELSIF v_MISIDE ='�ܾ�' then  
      v_mi.miside :='GJ';
    ELSIF v_MISIDE ='����' then  
      v_mi.miside :='QT';
    ELSIF v_MISIDE ='�쾮' then  
      v_mi.miside :='TJ';
    ELSIF v_MISIDE ='������' then  
      v_mi.miside :='CS'; 
    end if ;*/
    --ֱ�Ӵ��ֻ��˹���
    v_mi.miside := v_MISIDE;
    --B ����
    --C �շѷ�ʽ
    ---D ����
    --E ˮ�۱��  
    ---X �û�ˮ����Ϣά��          
    --Y ���ձ�ά��
    --20 �û�״̬���
    --W ˮ�������
  
    if trim(V_USERNm) is null or trim(V_USERNm) = '' then
      --20150806 �ֻ��޸ı�ע��Ϣʱ���µ��û���δ������,Ϊ��.�����Զ���ֵΪԭ����һ��
      V_USERNm := v_mi.MINAME;
    end if;
    
    -- by 20190628 �����ֻ�����ˮ����
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
      --��Ȩ�����߹���
      v_type := 'B'; ---B ����
    end if;
    --��ʱȡ��ˮ�������û�ˮ����Ϣά��
    /*if NVL(v_md.MDCALIBER, 0) <> NVL(v_MDCALIBER, 0) OR
       NVL(v_md.MDNO, 'NULL') <> NVL(v_MDNO, 'NULL') OR
       NVL(v_md.DQGFH, 'NULL') <> NVL(v_DQGFH, 'NULL') OR
       NVL(v_md.DQSFH, 'NULL') <> NVL(v_DQSFH, 'NULL') OR
       NVL(v_md.qfh, 'NULL') <> NVL(v_qfh, 'NULL') OR
       NVL(v_md.JCGFH, 'NULL') <> NVL(v_JCGFH, 'NULL') then
      --ˮ�������
      v_type := 'W'; ---Wˮ�������
    end if;*/
    --ˮ�۱�����ں���,���ͬʱ���������ˮ����ͳһ��ˮ�۱������.ֻ����һ�ʹ���
    if NVL(v_mi.MIPFID, 'NULL') <> NVL(v_MIPFID, 'NULL') then
      --��ˮ�������߹���
      v_type := 'E'; --E ˮ�۱�� 
    end if;
  
    /*    if NVL(v_ci.CICONNECTTEL,'NULL')<> NVL(V_CONNECT_PHONE,'NULL') OR  NVL(v_ci.CIMTEL,'NULL')<> NVL(V_TEL_PHONE,'NULL')  OR   NVL(v_ci.CICONNECTPER,'NULL')<>NVL(V_LINK_MAN,'NULL')   then --ˮ�������
        v_type:='X'; --- X�û�ˮ����Ϣά��
    end if ;*/
  
    /*  UPDATE METERREAD t
      SET  MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION ,
        MRPRIVILEGEFLAG =V_MRPRIVILEGEFLAG, --���Ĺ���״̬��־
        MRPRIVILEGEPER=v_MIPFID, --����ˮ����
        MRPRIVILEGEMEMO =V_USERNm, --�»���
        MRPRIVILEGEDATE=v_apply_date  --��Ϊ�޸�ʱ��ʹ�� by ralph 20150429
    WHERE mrmid = V_USER_NO
      AND MRIFREC = 'N';*/
    update meterinfo
       set MIYL5  = V_MRPRIVILEGEFLAG,
           MIYL6  = v_MIPFID,
           MIJD   = V_USERNm,
           MIYL10 = v_apply_date
     where miid = V_USER_NO;
    --���³���ע
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
    --������Ҫ��������������롢�����Ҫ����Ƿ����ϵͳ��
    --�����û���ע
    v_mi.MIMEMO     := V_CBBZ; --��ע
    v_mi.MIPFID     := v_MIPFID; --��ˮ����
    v_mi.MINAME     := V_USERNm; --��Ȩ��
    --ADD ZB 2018-11-2
    --�ֻ��������ε�ַ�޸�
    --v_mi.miadr      := v_adr; --��ַ
    --v_mi.miposition := v_adr; --��ַ
  
  --ADD ZB 2018-11-2
    --�ֻ��������ε�ַ�޸�
    UPDATE METERINFO T
       SET T.MIMEMO = V_CBBZ,
           T.MISIDE = V_MI.MISIDE --��λ��
           -- MIPFID=v_MIPFID,  --��ˮ�������߹���
           --  MINAME =V_USERNm,  --��Ȩ���������߹���
           --miadr      = v_adr,
           --miposition = v_adr
     WHERE T.MIID = V_USER_NO;
  
    --������ϵ�绰
    v_ci.CICONNECTTEL := V_CONNECT_PHONE;
    v_ci.CITEL1       := V_CONNECT_PHONE;
    v_ci.CIMTEL       := V_TEL_PHONE;
    v_ci.CICONNECTPER := V_LINK_MAN;
    --ADD ZB 2018-11-2
    --�ֻ��������ε�ַ�޸�
    --v_ci.ciadr        := v_adr;
    v_ci.ciname       := V_USERNm;
    v_ci.ciname2      := V_USERNm;
    --ADD ZB 2018-11-2
    --�ֻ��������ε�ַ�޸�
    UPDATE CUSTINFO T
       SET T.CICONNECTTEL = V_CONNECT_PHONE,
           --T.CITEL1       = V_CONNECT_PHONE,
           T.CIMTEL       = V_TEL_PHONE,
           T.CICONNECTPER = V_LINK_MAN
           --t.ciadr        = v_adr
     WHERE T.CIID IN
           (SELECT T1.MICID FROM METERINFO T1 WHERE T1.MIID = V_USER_NO);
    --
    /*MI IN METERINFO%ROWTYPE, --ˮ����Ϣ
    CI IN CUSTINFO%ROWTYPE,  --�û���Ϣ
    MD IN METERDOC%ROWTYPE,  --ˮ����
    MA IN METERACCOUNT%ROWTYPE,--�û�������Ϣ
    P_TYPE IN VARCHAR2,        --�������
    P_CCHCREPER in CUSTCHANGEhd.Cchcreper%type, --������
    P_MESSAGE OUT VARCHAR2   --����*/
    IF TRIM(V_TYPE) IN ('E', 'B'/*, 'W'*/, 'X') THEN
      --�ֻ�������Ĳ�Ȩ������ˮ���ʡ��ھ�������Ϣϵͳ�Զ���������
      select count(*)
        into v_count
        from operaccnt_level
       where oaid = V_COPER_NO; ---ralph by 20150615
      if v_count = 0 then
        v_message   := '���û�û�н��г���Ա��Ӧ��ϵ����!';
        o_out_trans := '|999|08002';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '���û�û�н��г���Ա��Ӧ��ϵ����!',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
      end if;
      PRO_TELSJCB(V_MI, V_CI, V_MD, V_MA, V_TYPE, V_COPER_NO, v_message);
    END IF;
    IF v_message IS NULL OR v_message = '' THEN
      v_message := '�ϴ��ɹ�' || '--' || V_TYPE;
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
  * ���ܣ�8003Э��  
   �ֻ�����ȷ�����������ݸ�Ӫ�գ� -> Ӫ�� (���ݳ������ݽ�����ѣ���������ֻ�) -> �ֻ���������ѽ���� ��ӡ�߷�֪ͨ��
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
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
    v_MRIFGU          meterread.mrifgu%type; --������� 
    v_MRPRIVILEGEMEMO meterread.mrprivilegememo%type; --���ͼƬ������
    v_count           number;
    v_rlje            number(13, 0);
    v_message         VARCHAR2(400);
    v_mrid            meterread.mrid%type;
    v_MRIFREC         meterread.MRIFREC%type;
    v_MRREQUISITION   meterread.MRREQUISITION%type;
    V_mrreadok        meterread.mrreadok%type;
    v_MRSMFID         meterread.MRSMFID%type;
    v_ssly            VARCHAR2(20); --ʾ����Դ
    v_dy              char(1);
    v_�ֵ�code        datadesign.�ֵ�code%type;
    v_mistatus        meterinfo.mistatus%type; --�û�״̬
    v_MRTHREESL       meterread.MRTHREESL%type; --���������
    v_mrchkresult     meterread.mrchkresult%type; --�����
    v_mrmonth         meterreadhis.mrmonth%type;
    v_ifdzsb          meterdoc.ifdzsb%type; --�������� 'Y'--ΪY����
    v_MRSCODE         meterread.mrscode%type; --��ʼָ��
    v_MRSL            meterread.mrsl%type; --����ˮ��
    v_mrface          meterread.mrface%type; --��̬
    v_MROUTFLAG       meterread.MROUTFLAG%type; --�������������־
    v_MICLASS         meterinfo.MICLASS%type; --�ֱܷ� 2-�ܱ�3-�ֱ�
    v_MIPID           meterinfo.MIPID%type; --�ܱ���� 3ʱΪ�ܱ�
    v_MIPRIID         meterinfo.MIPRIID%type; --���������
    v_MIPRIFLAG       meterinfo.MIPRIFLAG%type; --���ձ��־
    v_mipfid          meterinfo.mipfid%type; --ˮ�����
    v_pfprice         priceframe.pfprice%type; --���
    v_cb_month        VARCHAR2(7); --�����·�
    v_mrdatasource    meterread.mrdatasource%type;
    v_MRCHKFLAG       meterread.MRCHKFLAG%type;
    v_MRCHKDATE       meterread.MRCHKDATE%type;
    v_MRCHKPER        meterread.MRCHKPER%type;
    v_mircode         meterinfo.mircode%type;
    v_mrsl1           number(10);
    --20160804
    v_mrdzflag    meterread.mrdzflag%type; --�����־
    v_mrdzcurcode meterread.mrdzcurcode%type; --�����û�ʵ�ʶ���
    v_mrdzsl      meterread.mrdzsl%type; --��������
    v_miyl9       meterinfo.miyl9%type; --ˮ������
    v_mrreadok_pz     VARCHAR2(1);  --��Ƭ���
    V_SHBZ            VARCHAR2(1);  --��Ƭ���
  begin
    --����
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 10));
    --��������
    V_COPY_DATE := TRIM(SUBSTR(i_in_trans, 24, 20));
    --����ֹ��
    V_COPY_ECODE := TRIM(SUBSTR(i_in_trans, 45, 10));
    --����ˮ��
    V_COPY_SL := TRIM(SUBSTR(i_in_trans, 56, 10)); --20150320ȡ��,ˮ����Ӫ��������
    --������
    V_COPY_BK := TRIM(SUBSTR(i_in_trans, 67, 20));
    --�������
    V_SUBMIT := TRIM(SUBSTR(i_in_trans, 88, 5));
    --����Ա���
    V_COPER_MEMBER := TRIM(SUBSTR(i_in_trans, 94, 20));
    --����ע
    -- v_cb_memo := TRIM(SUBSTR(i_in_trans, 105, 200));
    v_cb_memo := TRIM(SUBSTR(i_in_trans, 115, 200)); --20150325
    --�Ƿ�����Ƭ�������
    v_mrreadok_pz := TRIM(SUBSTR(i_in_trans, 345, 1));
    IF v_mrreadok_pz ='N' THEN
      V_SHBZ :='Y';
    ELSIF v_mrreadok_pz ='Y' THEN
      V_SHBZ :='X';
    END IF;
    if v_cb_memo = 'NNUULL' THEN
      --�ֻ�������NNUULL
      v_cb_memo := '';
    END IF;
    --����ʾ����Դ ���� 1 ����2  �绰�� 3  δ����4
    v_ssly := TRIM(SUBSTR(i_in_trans, 316, 20));
    if v_ssly = '����' then
      v_MRIFGU := '1';
    elsif v_ssly = '����' then
      v_MRIFGU := '2';
    elsif v_ssly = '�绰��' then
      v_MRIFGU := '3';
    elsif v_ssly = 'δ����' then
      v_MRIFGU := '4';
    end if;
    v_cb_month := TRIM(SUBSTR(i_in_trans, 337, 7)); --�����Ƿ�����
  
    BEGIN
      select count(*)
        into v_count
        from datadesign
       where �ֵ����� = '�����Ƿ�����'
         and �ֵ�code = v_cb_month;
      if v_count = 0 then
        --�жϱ����Ƿ�����������������
        v_message   := '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
      end if;
    EXCEPTION
      WHEN OTHERS THEN
        v_message   := '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '�ֻ���������Ϊ�ϴγ���������,�������������ݵ��ֻ������',
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
              T.TRANS_RETURN_NOTE = 'δ�ҵ���������',
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
             mi.mircode, --�Ƿ������
             NVL(mr.mrdzflag, 'N'), --�����־
             NVL(mr.mrdzcurcode, 0), --�����û�ʵ�ʶ���
             mi.miyl9 --ˮ������
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
        v_message   := 'δ�ҵ���������';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = 'δ�ҵ���������',
               T.TRANS_MIID        = V_USER_NO
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
    END;
  
    --׷���ܿ�
    /*select TO_CHAR(SYSDATE, 'YYYY.MM') into v_mrmonth from DUAL; 
    select count(rlcid)
      into v_count
      from reclist rl, meterreadhis mrs 
     where RLMRID = MRID
       and rltrans <> '13' --���������ʾ���ɣ�������Դ��׷���ģ�����Ӧ�ò�������� by ��ΰ20141112
       and mrs.mrmonth =v_mrmonth
       and rl.RLREVERSEFLAG <> 'Y'
       AND MRS.MRDATASOURCE = 'Z'
       and rlcid = V_USER_NO;
    
     if v_count > 0 then
            o_out_trans := '|999|08003';
          v_message:='�ϴ�ʧ��,�����Ѳ���׷�����������������';
      
           UPDATE LOG_TRANS T
              SET T.TRANS_RESULT      = '999',
                  T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,�����Ѳ���׷�����������������',
                  T.TRANS_MIID        = V_USER_NO
            WHERE T.TRANS_TASK_NO = i_SEQ;
           o_out_trans :=o_out_trans||'|'|| v_message ;
           commit; 
           return ;
    end if ;
    */
    if v_mistatus = '24' then
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ�������ڹ��ϻ�����,���ܽ������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,���ڹ��ϻ�����',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mistatus = '35' then
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ�����������ڻ�����,���ܽ������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,�������ڻ�����',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mistatus = '36' then
      --Ԥ�������
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ��������Ԥ�������,���ܽ������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,����Ԥ�������',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
    if v_mistatus = '19' then
      --��������
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ��������������,���ܽ������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,��ˮ��������������',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    --byj add 
    if v_mistatus = '39' then
      --Ԥ�泷���˷���
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ��������Ԥ�泷���˷���,���ܽ������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,����Ԥ�泷���˷���',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    if v_mircode <> v_mrscode then
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,��ˮ������Ѿ����ı�,���ܽ������!';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,��ˮ������Ѿ����ı�!',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    end if;
  
    --byj end!
  
    if trunc(TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss')) > trunc(sysdate) then
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,�������ڲ��ܴ��ڵ�ǰϵͳ����,�ϴ����ʧ��';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,�������ڲ��ܴ��ڵ�ǰϵͳ����,�ϴ����ʧ��',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    
    end if;
  
    if fun_getsjcbmpmk(V_USER_NO, v_cb_month) = 'Y' THEN
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,�˳����������Ѿ����ϴ�ͼƬ�������Ѿ����ͨ��,�������ٴγ���';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,�˳����������Ѿ����ϴ�ͼƬ�������Ѿ����ͨ��,�������ٴγ���',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    END IF;
    -- if (v_MRIFREC ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'  ) or ( V_mrreadok ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'  )   then  --���³�������ѡ���������򲻽������ϸ���
  
    if (v_MRIFREC = 'Y' and v_mistatus <> '29' and v_mistatus <> '30') or
       (V_mrreadok = 'Y' and v_mistatus <> '29' and v_mistatus <> '30' and
       v_mrdatasource = '9') then
      --���³�������ѡ���������򲻽������ϸ���
      --v_MRIFREC ���
      --V_mrreadok ������־
    
      --V_mrreadok ='Y' and  v_mistatus <> '29'  and  v_mistatus <> '30'�̶���������������Ѵ�ӡ�߷�֪ͨ��
      o_out_trans := '|999|08003';
      v_message   := '�ϴ�ʧ��,����ѻ��Ѿ��������';
    
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ϴ�ʧ��,����ѻ��Ѿ��������',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := o_out_trans || '|' || v_message;
      commit;
      return;
    elsif V_mrreadok <> 'Y' AND v_MRIFREC <> 'Y' then
      --���Ը��³������� 
      --���µ��³�������
      --  if to_char(sysdate,'yyyy-MM') = to_char(to_date(substrb(V_COPY_DATE,1,8),'yyyy-MM-dd'),'yyyy-MM')  or V_USER_NO ='3061018832' then
      --�ж�Ӫҵ���Ƿ���Ҫ������˹���  1-��Ҫ��� 0-�������
      BEGIN
        select �ֵ�code
          into v_�ֵ�code
          from datadesign
         where �ֵ����� = '�������'
           and ��ע = v_MRSMFID;
      EXCEPTION
        WHEN OTHERS THEN
          v_message   := '�ϴ�ʧ��,���������Ƿ���Ҫ��˲���δ�ҵ�';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '���������Ƿ���Ҫ��˲���δ�ҵ�',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          return;
      END;
    
      if v_�ֵ�code = '0' OR v_mistatus = '29' OR v_mistatus = '30' then
        --�ж�Ӫҵ���Ƿ���Ҫ������˹���  1-��Ҫ��� 0-�������
        V_mrreadok := 'Y'; --Ӫҵ���趨�������,��ϵͳ�Զ����    
        if v_mistatus <> '29' and v_mistatus <> '30' then
          v_MRCHKFLAG := 'Y';
          v_MRCHKDATE := sysdate;
          v_MRCHKPER  := V_COPER_MEMBER;
        end if;
      
      else
        v_MRCHKFLAG := 'N';
        v_MRCHKDATE := null;
        v_MRCHKPER  := null;
        --V_mrreadok  := 'X'; --Ӫҵ���趨�����,��ϵͳ�Զ������
        V_mrreadok  := V_SHBZ;  --���û����Ƭ���Զ����
      end if; --Y�����Ѿ���� X����� N-δ����
      -- ���
      begin
        select SFLFLAG1
          into v_mrface --���ݱ��ץȡ��̬
          from sysfacelist2 t
         where sflid = V_COPY_BK; --���
      exception
        when others then
          v_message   := '�ϴ�ʧ��,�������ϸ��ݱ��ץȡ��̬δ�ҵ�';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '�������ϸ��ݱ��ץȡ��̬δ�ҵ�',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          commit;
          return;
      end;
    
      if v_mrface = '01' then
        --������� 
        --����ܿ�
        --20150320ȡ��,ˮ����Ӫ��������
        /**��������£�ֹ�������С���������������
        *1��ˮ��װ2������3���ߴ�
        *ǰ̨����У�飬�ݲ�֧�ֽ�֯���
        **/
        if v_ifdzsb = 'Y' THEN
          --����
          v_MRSL := v_MRSCODE - V_COPY_ECODE; --ʼָ�� -ĩָ��  
        ELSIF v_mrdzflag = 'Y' THEN
          --����
          IF V_COPY_ECODE < v_mrdzcurcode THEN
            v_message   := '�����û�����ָ��С�ڵ������,������';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = '�����û�����ָ��С�ڵ������,������',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            return;
          END IF;
          IF V_COPY_ECODE >= v_MRSCODE THEN
            --���������ˮ��=ֹ��-���룬����ˮ��=����-�������
            v_MRSL   := V_COPY_ECODE - v_MRSCODE;
            v_mrdzsl := v_MRSCODE - v_mrdzcurcode;
          ELSE
            --���룬ˮ��=0������ˮ��=ֹ��-�������
            v_MRSL   := 0;
            v_mrdzsl := V_COPY_ECODE - v_mrdzcurcode;
          END IF;
        ELSE
        --����
          IF v_miyl9 is not null and  V_COPY_ECODE > v_miyl9 THEN
            v_message   := '�û�����ָ���ˮ�������������,������';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = '�û�����ָ���ˮ�������������,������',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            return;
          END IF;
          --������
          v_MRSL := V_COPY_ECODE - v_MRSCODE; --ĩָ�� -ʼָ��
          IF v_MRSL < 0 AND v_miyl9 IS not null THEN
            --ˮ���ߴ�
            v_MRSL := to_number(v_miyl9) - v_MRSCODE + V_COPY_ECODE;
          END IF;
        END IF;
        if v_MRSL < 0 then
          v_message   := 'ˮ��Ϊ����,������';
          o_out_trans := '|999|08003';
          o_out_trans := o_out_trans || '|' || v_message;
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = 'ˮ��Ϊ����,������',
                 T.TRANS_MIID        = V_USER_NO
           WHERE T.TRANS_TASK_NO = i_SEQ;
          return;
        end if;
        --�������
        if v_MRTHREESL > 0 then
          if v_mrchkresult <> 'ȷ��ͨ��' or v_mrchkresult is null then
            PG_EWIDE_RAEDPLAN_01.SP_MRSLCHECK_HRB(v_mrid,
                                                  v_MRSL,
                                                  V_MRIFSUBMIT);
          end if;
        end if;
      elsif v_mrface = '02' then
        --//02ָ������ֹ��Ϊ���룬ˮ��Ϊ�ϴ�ˮ���������ο���
        V_MRIFSUBMIT := 'N';
        IF V_COPY_ECODE > 0 THEN
          --��ֹ�����0���д���
          v_MRSL := V_COPY_ECODE - v_MRSCODE; --ĩָ�� -ʼָ��
          if v_MRSL < 0 then
            v_message   := 'ˮ��Ϊ����,������';
            o_out_trans := '|999|08003';
            o_out_trans := o_out_trans || '|' || v_message;
            UPDATE LOG_TRANS T
               SET T.TRANS_RESULT      = '999',
                   T.TRANS_RETURN_NOTE = 'ˮ��Ϊ����,������',
                   T.TRANS_MIID        = V_USER_NO
             WHERE T.TRANS_TASK_NO = i_SEQ;
            commit;
            return;
          end if;
        else
          v_MRSL := 0;
        END IF;
        V_COPY_ECODE := v_MRSCODE; -- by ralph 20150724 ���쳣ֹ��Ӧ��������ͬ
      elsif v_mrface = '03' then
        --//03��ˮ����ֹ��Ϊ���룬ˮ��Ϊ0
        V_MRIFSUBMIT := 'N';
        v_MRSL       := 0;
        V_COPY_ECODE := v_MRSCODE; --ֹ��Ϊ���룬ˮ��Ϊ0
      end if;
    
      v_MROUTFLAG := 'N';
    
      UPDATE METERREAD t
         SET mrdatasource = '9', --��ʾ�ֻ������ϴ�
             MROUTFLAG    = v_MROUTFLAG,
             mrinorder    = nvl(mrinorder, 0) + 1,
             mrindate     = sysdate,
             mrinputper   = substrb(V_COPER_MEMBER, 1, 10),
             mrifsubmit   = V_MRIFSUBMIT,
             mrreadok     = V_mrreadok, --�Ƿ񳭱���˷ŵ�Ӫ������� 20150313
             --mrecodechar  = ����ֹ��λ������(V_COPY_ECODE, MRMCODE),
             mrecodechar = V_COPY_ECODE,
             MRSL        = v_MRSL,
             MRECODE     = V_COPY_ECODE,
             mrdzsl = v_mrdzsl,--�������� 20160805
             --mrrdate     = TO_DATE(V_COPY_DATE, 'yyyy-MM-dd'),
             mrrdate         = TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss'),
             mrpdardate      = TO_DATE(V_COPY_DATE, 'yyyymmddhh24miss'),
             mrinputdate     = sysdate,
             MRFACE          = v_mrface, --����̬
             mrface2         = V_COPY_BK, --���
             mrmemo          = v_cb_memo,
             MRCHKFLAG       = v_MRCHKFLAG,
             MRCHKDATE       = v_MRCHKDATE,
             MRCHKPER        = v_MRCHKPER,
             MRPRIVILEGEMEMO = v_MRPRIVILEGEMEMO, --�����ֻ�ͼƬ����
             MRIFGU          = v_mrifgu /*, --�������
             
                                                 MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION*/
       WHERE mrmid = V_USER_NO
         AND NVL(MRIFMCH, 'N') <> 'Y' --�Ⳮ�����ϴ�
         AND MRIFREC <> 'Y' --ֻ����δ��ѡ�δ�������
         and mrreadok <> 'Y';
    
      --����������δͨ��������Ա���³���,���������ϴ�����ɾ��֮ǰ�ϴ���ͼƬ 
      delete from meterpicture
       where mpmiid = V_USER_NO
         and PMBZ = '1' --�����ͼƬ
         and pmtime >= to_date(to_char(sysdate, 'yyyymm') || '01000001',
                               'yyyymmddhh24miss')
         and pmtime <= to_date(to_char(trunc(Last_day(sysdate)), 'yyyymmdd') ||
                               '235959',
                               'yyyymmddhh24miss');
    
      commit;
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '�ϴ��ɹ�',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|000|08003';
      /*             else
         UPDATE LOG_TRANS T
          SET T.TRANS_RESULT      = '111',
              T.TRANS_RETURN_NOTE = '�����ϴ�ʧ��',
              T.TRANS_MIID        = V_USER_NO
        WHERE T.TRANS_TASK_NO = i_SEQ;
           v_message :='�����ϴ�ʧ��';
          o_out_trans := '|999|08003' ;
          o_out_trans :=o_out_trans||'|'|| v_message ;
           commit; 
           return ;
           
      end if; */
    elsif V_mrreadok = 'Y' and (v_mistatus = '29' OR v_mistatus = '30') then
      --�̶�������ֱ�ӵ������
      o_out_trans := '|000|08003';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '�ϴ��ɹ�,�̶���',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      v_mrface := '01';
    elsif v_mrdatasource <> '9' and V_mrreadok = 'Y' AND v_MRIFREC <> 'Y' and
          v_mrface = '01' then
      --�����������г���δ���
      o_out_trans := '|000|08003';
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '�ϴ��ɹ�,����������������,ֻ���',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      -- v_mrface:='01';
    end if;
  
    if v_MICLASS = '2' then
      --�ܱ�
      select count(*), SUM(mrsl)
        into v_count, v_mrsl
        from meterread mr, meterinfo mi
       where mr.MRMID = mi.miid
         and mr.MRFACE = '02'
         and --�ֱܷ�����ֱ�����б��쳣���򲻽������,ֻ���泭������
             mi.MIPID = V_USER_NO;
      If v_count > 0 then
        o_out_trans := '|111|08003'; --�ֱܷ�����ֱ�����б��쳣���򲻽������,ֻ���泭������
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
      --ֻ�б�̬Ϊ�����������
    
      if o_out_trans = '|000|08003' then
        --�����¼�ɹ������Ԥ��ѹ���
        begin
          select pfprice
            into v_pfprice
            from priceframe
           where pfid = v_mipfid;
        exception
          when others then
            v_pfprice := 0;
        end;
        if v_pfprice >= 0 then   ---20161130 ��������ˮ��û��ˮ�� ��Ҫ�����ֻ����� ������0��Ϊ���ڵ�����
          --���۴���0��Ԥ���
          PG_EWIDE_METERREAD_01.CALCULATE_YSFH(v_MRID, v_rlje, v_message);
        end if;
      
        /*if v_rlje = 0 and v_pfprice > 0 then
          --���۴���0��Ԥ���
          o_out_trans := '|999|08003';
        else*/
        o_out_trans := '|000|08003';
        /*end if;*/
        o_out_trans := o_out_trans || '|' || v_message;
      end if;
    
      if o_out_trans = '|111|08003' then
        --�ֱܷ�����ֱ�����б��쳣���򲻽������,ֻ���泭������
        v_message   := '���ܱ��·ֱ��̬Ϊ���쳣,����Ʊ';
        o_out_trans := '|111|08003';
        o_out_trans := o_out_trans || '|' || v_message;
      end if;
    elsif v_mrface = '02' then
      --���쳣
      --  if o_out_trans  = '|000|08003' then  -- 
      v_message   := '��̬Ϊ���쳣,����Ʊ';
      o_out_trans := '|111|08003';
      o_out_trans := o_out_trans || '|' || v_message;
      --  end if ;
      /* elsif v_mrface = '03' then
      --0ˮ��
      v_message   := '��̬Ϊ��ˮ��,����Ʊ';
      o_out_trans := '|111|08003';
      o_out_trans := o_out_trans || '|' || v_message;*/
    end if;
    /*      if  Instrb (o_out_trans,'|999|' ,1) > 0 then
       rollback;
    else*/
    COMMIT;
    --   end if ;
    --|08003����ֵ
    --|�ɹ���־(000-�ɹ� 999-ʧ��)|Э��|Ӧ��ˮ��|Ӧ��ˮ��|Ӧ����ˮ��|Ӧ����������|Ӧ�պϼ�|����Ԥ�����|����Ԥ�����
    -- ע �������000�ɹ� ֵ������Э�鷵�أ��������999�򷵻ش�����Ϣ 
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
    --f8004  ������֤
    -- �û���  VARCHAR2(15)
    --���� VARCHAR2(32)
    --���� '|000|08004' -�ɹ�    '|999|08004' -ʧ��
    V_USER_NO := TRIM(SUBSTR(i_in_trans, 13, 15));
    --����
    v_password := TRIM(SUBSTR(i_in_trans, 29, 32));
  
    select md5(v_password) into v_password from dual;
  
    select count(*)
      into v_count
      from operaccnt
     where (oaid = V_USER_NO)
       and OAPWD = v_password;
    -- where (oagh =V_USER_NO or oaid =V_USER_NO )  and OAPWD =v_password ;  by 20150608 ralph ��Ϊ����Ա���Ųſ��ܹ�������
  
    --v_count ��ʾ�����Ѿ�����
    if v_count > 0 then
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '������֤�ɹ�',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
    
      insert into sys_host_his
        (ip, login_user, host_name, log_date, ip1, os_user)
      values
        ('SJCB',
         V_USER_NO,
         v_password,
         sysdate,
         '�ֻ�����',
         'PG_pad_updata �ֻ��������');
    
      o_out_trans := '|000|08004';
    else
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '������֤ʧ��',
             T.TRANS_MIID        = V_USER_NO
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|999|08004';
    end if;
  
    COMMIT;
  
  end;

  procedure f8005(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_�ֵ�CODE  datadesign.�ֵ�CODE%type;
    v_�ֵ�CODE1 datadesign.�ֵ�CODE%type;
    v_count     number;
  
  begin
    --f8005  �����汾��֤
    -- �ֵ����  VARCHAR2(20) 
    --���� '|000|08005|�汾��'  000-����Ӫ�հ汾���ֻ���    '|999|08005|�汾��'   999-�ֻ���Ӫ�հ汾һ�� 
    v_�ֵ�CODE1 := TRIM(SUBSTR(i_in_trans, 13, 20));
  
    select �ֵ�CODE
      into v_�ֵ�CODE
      from datadesign
     where �ֵ����� = '�ֻ������汾';
  
    --v_count ��ʾ�����Ѿ�����
    if v_�ֵ�CODE > v_�ֵ�CODE1 then
      --Ӫ�հ�����ֻ��汾���򷵻�Ӫ�ղ���
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '�ֻ������汾�ɹ�',
             T.TRANS_MIID        = v_�ֵ�CODE1
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|000|08005|' || v_�ֵ�CODE1; --����������
    else
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '�ֻ������汾һ��',
             T.TRANS_MIID        = v_�ֵ�CODE1
       WHERE T.TRANS_TASK_NO = i_SEQ;
      o_out_trans := '|999|08005|' || v_�ֵ�CODE1; --������������
    end if;
  
    COMMIT;
  
  end;

  procedure f8006(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_�ֵ�CODE  datadesign.�ֵ�CODE%type;
    v_�ֵ�CODE1 datadesign.�ֵ�CODE%type;
    v_count     number;
    v_miid      VARCHAR2(20);
    v_mr        meterread%rowtype;
    v_mi        meterinfo%rowtype;
    v_md        meterdoc%rowtype;
    v_message   VARCHAR2(400);
    v_ysdj      number(10, 2);
    v_wsdj      number(10, 2);
  begin
    /*  * ���ܣ�8006Э��  
    �û��㳭��ȡ��Э�飬����ע��������,�������ȡ�� */
    --���� |000|08006|'���سɹ���Ϣ' --000�ɹ�  |999|08006|'����ʧ����Ϣ' --999ʧ��
    --����
  
    v_miid := TRIM(SUBSTR(i_in_trans, 13, 10));
  
    BEGIN
      /*      select mr.MRID,mr.MRIFREC,mr.MRSMFID,mr.mrreadok,mi.mistatus,mr.MRTHREESL,mr.MRIFSUBMIT,mr.mrchkresult,md.ifdzsb,mr.MRSCODE, mi.MICLASS,mi.MIPID,mi.MIPRIID,mi.MIPRIFLAG,mr.mrdatasource,mr.mrface--�Ƿ������
      into  v_mr.mrid,v_mr.MRIFREC,v_mr.MRSMFID,v_mr.mrreadok,v_mi.mistatus ,v_mr.MRTHREESL,v_mr.MRIFSUBMIT,v_mr.mrchkresult,v_md.ifdzsb,v_mr.MRSCODE,v_mi.MICLASS,v_mi.MIPID,v_mi.MIPRIID,v_mi.MIPRIFLAG,v_mr.mrdatasource,v_mr.mrface --v_ifdzsb����װ��
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
        v_message   := 'δ�ҵ���������';
        o_out_trans := '|999|08003';
        o_out_trans := o_out_trans || '|' || v_message;
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = 'δ�ҵ���������',
               T.TRANS_MIID        = v_miid
         WHERE T.TRANS_TASK_NO = i_SEQ;
        commit;
        return;
    END;
  
    if v_mr.mrifrec = 'Y' THEN
      --20150917 
      o_out_trans := '|999|08006|�˱��Ѿ�������,��������'; --���ϻ���ʧ��
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '���ϻ���ʧ��,�˱��Ѿ����,��������',
             T.TRANS_MIID        = v_miid
       WHERE T.TRANS_TASK_NO = i_SEQ;
      commit;
      return;
    end if;
  
    if v_mr.mrreadok <> 'Y' THEN
      --δ���ͨ���Ŀ���ȡ���ٴγ��� 
      begin
        UPDATE METERREAD t
           SET mrdatasource = '9', --��ʾ�ֻ������ϴ�
               MROUTFLAG    = 'N',
               mrinorder    = 0,
               mrindate     = NULL,
               mrinputper   = '',
               --       mrifsubmit   = V_MRIFSUBMIT,  
               mrreadok = 'N', --�Ƿ񳭱���˷ŵ�Ӫ������� 20150313
               --mrecodechar  = ����ֹ��λ������(V_COPY_ECODE, MRMCODE),
               mrecodechar     = '0',
               MRSL            = 0,
               MRECODE         = 0,
               mrrdate         = NULL,
               mrpdardate      = NULL,
               mrinputdate     = NULL,
               MRFACE          = '', --����̬
               mrface2         = '', --���
               mrmemo          = '',
               MRPRIVILEGEMEMO = '', --�����ֻ�ͼƬ����
               MRIFGU          = '' /*, --�������
                                   MRREQUISITION=NVL(MRREQUISITION,0)+v_MRREQUISITION*/
         WHERE mrmid = v_miid
           AND NVL(MRIFMCH, 'N') <> 'Y' --�Ⳮ�����ϴ�
           AND MRIFREC <> 'Y' --ֻ����δ��ѡ�δ�������
           and mrreadok <> 'Y';
        select fun_getjtdqdj(MIPFID, MIPRIID, miid, '1') ˮ�ѵ���,
               fgetwsf(mipfid) ��ˮ�ѵ���
          into v_ysdj, v_wsdj
          from meterinfo
         where miid = v_miid;
        o_out_trans := '|000|08006|' ||
                       trim(to_char(abs(v_ysdj) * 100, '0000000000')) || '|' ||
                       trim(to_char(abs(v_wsdj) * 100, '0000000000')); --���ϻ��˳ɹ�
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '000',
               T.TRANS_RETURN_NOTE = '���ϻ��˳ɹ�',
               T.TRANS_MIID        = v_miid
         WHERE T.TRANS_TASK_NO = i_SEQ;
        --����������δͨ��������Ա���³���,���������ϴ�����ɾ��֮ǰ�ϴ���ͼƬ 
        delete from meterpicture
         where mpmiid = v_miid
           and PMBZ = '1' --�����ͼƬ
           and pmtime >= to_date(to_char(sysdate, 'yyyymm') || '01000001',
                                 'yyyymmddhh24miss')
           and pmtime <= to_date(to_char(trunc(Last_day(sysdate)),
                                         'yyyymmdd') || '235959',
                                 'yyyymmddhh24miss');
      
        commit;
      
      exception
        when others then
          o_out_trans := '|999|08006|' || sqlerrm; --���ϻ���ʧ��
          UPDATE LOG_TRANS T
             SET T.TRANS_RESULT      = '999',
                 T.TRANS_RETURN_NOTE = '���ϻ���ʧ��',
                 T.TRANS_MIID        = v_miid
           WHERE T.TRANS_TASK_NO = i_SEQ;
          rollback;
          return;
      end;
    else
      o_out_trans := '|999|08006|�˱��Ѿ����,��������'; --���ϻ���ʧ��
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '999',
             T.TRANS_RETURN_NOTE = '���ϻ���ʧ��,�˱��Ѿ����,��������',
             T.TRANS_MIID        = v_miid
       WHERE T.TRANS_TASK_NO = i_SEQ;
    END IF;
  
    COMMIT;
  
  end;
  /*  * ���ܣ�8006Э��  
  �û�Ѳ�� */
  -- 
  --����    
  procedure f8007(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans OUT VARCHAR2) IS
  
    v_�ֵ�CODE  datadesign.�ֵ�CODE%type;
    v_�ֵ�CODE1 datadesign.�ֵ�CODE%type;
    v_count     number;
    tc          telcheck%rowtype;
    -- f8007
    --�û�Ѳ��
    --|�û���|Ѳ�����|Ѳ����|Ѳ�챸ע|Ѳ����|Ѳ��ʱ��|�Ƿ�����|��Ƭ·��
    --|10|20|20|200|15|10|1|200
  begin
    tc.tcmid        := TRIM(SUBSTR(i_in_trans, 13, 10)); --�û���
    tc.TCMONTH      := to_char(sysdate, 'yyyy.mm');
    tc.tctype       := TRIM(SUBSTR(i_in_trans, 24, 20)); --Ѳ�����
    tc.TCRESULT     := TRIM(SUBSTR(i_in_trans, 45, 20)); --Ѳ����
    tc.TCNOTE       := TRIM(SUBSTR(i_in_trans, 66, 200)); --Ѳ�챸ע
    tc.TCUSER       := TRIM(SUBSTR(i_in_trans, 267, 15)); --Ѳ����
    tc.TCDATE       := to_date(TRIM(SUBSTR(i_in_trans, 283, 19)),
                               'YYYY-MM-DD hh24:mI:ss'); --Ѳ��ʱ��
    tc.TCPHOTO_MK   := TRIM(SUBSTR(i_in_trans, 303, 1)); --�Ƿ�����(Y/N)
    tc.TCPHOTO_PATH := TRIM(SUBSTR(i_in_trans, 305, 200)); --��Ƭ·��
    tc.TCINSDATE    := sysdate; --�Ƿ�����(Y/N)
    TC.TCCHK_MK     := 'N';
    begin
      SELECT FGETSEQUENCE('SEQ_TELCHECK') INTO tc.tcid FROM DUAL; --��ȡ��ˮ��
      insert into telcheck values tc;
      o_out_trans := '|000|08007|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                     '���������ɹ�'; --�����ϴ��ɹ�
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '���������ɹ�',
             T.TRANS_MIID        = tc.tcmid
       WHERE T.TRANS_TASK_NO = i_SEQ;
    exception
      when others then
        o_out_trans := '|999|08007|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                       sqlerrm; --���ϻ���ʧ��
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '��������ʧ��',
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
  
    v_�ֵ�CODE  datadesign.�ֵ�CODE%type;
    v_�ֵ�CODE1 datadesign.�ֵ�CODE%type;
    v_count     number;
    mp          meterpicture%rowtype;
  
    /*
    * ���ܣ�8008Э��  
      �û�ͼƬ�����ϴ�
    * ������:�ذ�
    * ����ʱ�䣺2015-07-15
    * �޸��ˣ�  
    * �޸�ʱ�䣺
    */
    --|�û���|ͼƬ��С|·��|ʱ��|ע��|����Ա����|�û���|ͼƬ·��
    --|10|10|400|20|100|10|30|10|400
  
  begin
    mp.MPMIID      := TRIM(SUBSTR(i_in_trans, 13, 10)); --�û���
    mp.PMSIZE      := to_number(SUBSTR(i_in_trans, 24, 10)); --ͼƬ��С
    mp.PMPATH      := TRIM(SUBSTR(i_in_trans, 35, 400)); --·��
    mp.PMTIME      := to_date(TRIM(SUBSTR(i_in_trans, 436, 20)),
                              'YYYY-MM-DD hh24:mI:ss'); --ʱ��
    mp.PMBZ        := TRIM(SUBSTR(i_in_trans, 457, 100)); --ע��
    mp.PMPER       := TRIM(SUBSTR(i_in_trans, 558, 10)); --����Ա����
    mp.PMPNAME     := TRIM(SUBSTR(i_in_trans, 569, 30)); --����Ա����
    mp.CIID        := TRIM(SUBSTR(i_in_trans, 600, 10)); --�û���(Y/N)
    mp.PMFACT_PATH := TRIM(SUBSTR(i_in_trans, 611, 400)); --ͼƬ·��
  
    begin
    
      insert into meterpicture values mp;
      o_out_trans := '|000|08008|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                     '���������ɹ�'; --�����ϴ��ɹ�
      UPDATE LOG_TRANS T
         SET T.TRANS_RESULT      = '000',
             T.TRANS_RETURN_NOTE = '���������ɹ�',
             T.TRANS_MIID        = mp.MPMIID
       WHERE T.TRANS_TASK_NO = i_SEQ;
    exception
      when others then
        o_out_trans := '|999|08008|' || TRIM(SUBSTR(i_in_trans, 283, 19)) || '|' ||
                       sqlerrm; --���ϻ���ʧ��
        UPDATE LOG_TRANS T
           SET T.TRANS_RESULT      = '999',
               T.TRANS_RETURN_NOTE = '��������ʧ��',
               T.TRANS_MIID        = mp.MPMIID
         WHERE T.TRANS_TASK_NO = i_SEQ;
        rollback;
        return;
    end;
  
    COMMIT;
  
  end;

END;
/

