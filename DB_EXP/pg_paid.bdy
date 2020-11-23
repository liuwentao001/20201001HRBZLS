CREATE OR REPLACE PACKAGE BODY PG_PAID IS
  CURDATETIME DATE;

  FUNCTION OBTWYJ(P_SDATE IN DATE, P_EDATE IN DATE, P_JE IN NUMBER)
    RETURN NUMBER IS
    V_RESULT NUMBER;
  BEGIN
    V_RESULT := P_JE * (TRUNC(P_EDATE) - TRUNC(P_SDATE) + 1) * 0.003;
    V_RESULT := PG_CB_COST.GETMAX(V_RESULT, 0);
    RETURN V_RESULT;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --ΥԼ�����
  function ObtWyjAdj(p_arid     in varchar2, --Ӧ����ˮ
                     p_ardpiids in varchar2, --Ӧ����ϸ���'01|02|03'
                     p_edate    in date --������'������'ΥԼ��,������ʽ'yyyy-mm-dd'
                     ) return number is
    vresult          number;
    v_arzndate       ys_zw_arlist.arzndate%type;
    v_arznj          ys_zw_arlist.arznj%type;
    v_outflag        ys_zw_arlist.aroutflag%type;
    v_sbid           ys_zw_arlist.sbid%type;
    v_arje           ys_zw_arlist.arje%type;
    v_yhifzn         ys_yh_custinfo.yhifzn%type;
    v_arznjreducflag ys_zw_arlist.arznjreducflag%type;
    v_chargetype     varchar2(10);
  begin
    BEGIN
      select a.sbid,
             max(arzndate),
             max(arznj),
             max(aroutflag),
             sum(ardje),
             max(yhifzn),
             max(arznjreducflag),
             max(NVL(sbchargetype, 'X'))
        into v_sbid,
             v_arzndate,
             v_arznj,
             v_outflag,
             v_arje,
             v_yhifzn,
             v_arznjreducflag,
             v_chargetype
        from ys_zw_arlist   a,
             ys_yh_custinfo b,
             ys_zw_ardetail c,
             ys_yh_sbinfo   d
       where a.sbid = d.sbid
         and b.yhid = d.yhid
         and a.arid = c.ardid
         and instr(p_ardpiids, ardpiid) > 0
         and arid = p_arid
       group by arid, a.sbid;
    exception
      when others then
        raise;
    END;
  
    --��ʱ����
    --return 0;
  
    if v_yhifzn = 'N' or v_chargetype in ('D', 'T') then
      return 0;
    end if;
    if v_arje < 0 then
      v_arje := 0;
    end if;
    if v_arznjreducflag = 'Y' then
      return v_arznj;
    end if;
  
    vresult := ObtWyj(v_arzndate, p_edate, v_arje);
    --���ó�������
    if vresult > v_arje then
      vresult := v_arje;
    end if;
  
    return trunc(vresult, 2);
  exception
    when others then
      return 0;
  end;
  /*==========================================================================
  ˮ˾��̨�ɷѣ�һ��,�����򻯰�
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE POSCUSTFORYS(P_SBID     IN VARCHAR2,
                         P_ARSTR    IN VARCHAR2,
                         P_POSITION IN VARCHAR2,
                         P_OPER     IN VARCHAR2,
                         P_PAYPOINT IN VARCHAR2,
                         P_PAYWAY   IN VARCHAR2,
                         P_PAYMENT  IN NUMBER,
                         P_BATCH    IN VARCHAR2,
                         P_PID      OUT VARCHAR2) IS
  
    V_PARM_AR  PARM_PAYAR;
    V_PARM_ARS PARM_PAYAR_TAB;
  BEGIN
    V_PARM_AR  := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS := PARM_PAYAR_TAB();
    FOR I IN 1 .. FMID(P_ARSTR, '|') - 1 LOOP
      V_PARM_AR.ARID     := PG_CB_COST.FGETPARA(P_ARSTR, I, 1);
      V_PARM_AR.ARDPIIDS := REPLACE(REPLACE(PG_CB_COST.FGETPARA(P_ARSTR,
                                                                I,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      V_PARM_AR.ARWYJ    := PG_CB_COST.FGETPARA(P_ARSTR, I, 3);
      V_PARM_AR.FEE1     := PG_CB_COST.FGETPARA(P_ARSTR, I, 4);
      V_PARM_AR.FEE2     := PG_CB_COST.FGETPARA(P_ARSTR, I, 5);
      V_PARM_AR.FEE3     := PG_CB_COST.FGETPARA(P_ARSTR, I, 6);
      V_PARM_ARS.EXTEND;
      V_PARM_ARS(V_PARM_ARS.LAST) := V_PARM_AR;
    END LOOP;
  
    POSCUST(P_SBID,
            V_PARM_ARS,
            P_POSITION,
            P_OPER,
            P_PAYPOINT,
            P_PAYWAY,
            P_PAYMENT,
            P_BATCH,
            P_PID);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  ˮ˾��̨�ɷѣ�һ��
  ���������˵������
  p_sbid        in varchar2 :��һˮ����
  p_parm_ars   in out parm_payr_tab :�������Ӧ�հ���Ա�������£�
                            arid  in number :Ӧ����ˮ�����˳�Ա�������ʣ�
                            ardpiids in varchar2 :������Ŀ��������������Ŀ,��ǰ̨��ѡ��(Y/N)+����ID��ɵĶ�ά���飨����PG_CB_COST.FGETPARA��ά����淶�������磺Y,01|Y,02|N,03|,�������Ҫ��
                            arznj in number :�����ΥԼ�𣨱������ڲ����㲻У�飩��������������
                            fee1 in number  :������ϵͳ����1
  p_position      in varchar2 :�ɷѵ�λ��Ӫ���ܹ���Ӫҵ�����룬ʵ�ռ��ʵ�λ
  p_oper       in varchar2 :����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway     in varchar2 :���ʽ��ÿ�������ҽ���һ�ָ��ʽ
  p_payment    in number   :ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  */
  PROCEDURE POSCUST(P_SBID     IN VARCHAR2,
                    P_PARM_ARS IN PARM_PAYAR_TAB,
                    P_POSITION IN VARCHAR2,
                    P_OPER     IN VARCHAR2,
                    P_PAYPOINT IN VARCHAR2,
                    P_PAYWAY   IN VARCHAR2,
                    P_PAYMENT  IN NUMBER,
                    P_BATCH    IN VARCHAR2,
                    P_PID      OUT VARCHAR2) IS
    VBATCH       VARCHAR2(10);
    VSEQNO       VARCHAR2(10);
    V_PARM_ARS   PARM_PAYAR_TAB;
    VREMAINAFTER NUMBER;
    V_PARM_COUNT NUMBER;
  BEGIN
    VBATCH     := P_BATCH;
    V_PARM_ARS := P_PARM_ARS;
    --���Ĳ���У��
    FOR I IN (SELECT A.AROUTFLAG
                FROM YS_ZW_ARLIST A, TABLE(V_PARM_ARS) B
               WHERE A.ARID = B.ARID) LOOP
      IF �����ظ����� = 0 AND I.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��ǰϵͳ�����������н���Ӧ�ճ���');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO V_PARM_COUNT FROM TABLE(V_PARM_ARS) B;
    IF V_PARM_COUNT = 0 THEN
      IF P_PAYMENT > 0 THEN
        --����Ԥ�����
        PRECUST(P_SBID        => P_SBID,
                P_POSITION    => P_POSITION,
                P_OPER        => P_OPER,
                P_PAYWAY      => P_PAYWAY,
                P_PAYMENT     => P_PAYMENT,
                P_MEMO        => NULL,
                P_BATCH       => VBATCH,
                O_PID         => P_PID,
                O_REMAINAFTER => VREMAINAFTER);
      ELSE
        NULL;
        --��Ԥ�����
        PRECUSTBACK(P_SBID        => P_SBID,
                    P_POSITION    => P_POSITION,
                    P_OPER        => P_OPER,
                    P_PAYWAY      => P_PAYWAY,
                    P_PAYMENT     => P_PAYMENT,
                    P_MEMO        => NULL,
                    P_BATCH       => VBATCH,
                    O_PID         => P_PID,
                    O_REMAINAFTER => VREMAINAFTER);
      END IF;
    ELSE
      PAYCUST(P_SBID,
              V_PARM_ARS,
              PTRANS_��̨�ɷ�,
              P_POSITION,
              P_PAYPOINT,
              NULL,
              NULL,
              P_OPER,
              P_PAYWAY,
              P_PAYMENT,
              NULL,
              ���ύ,
              �ֲ�����֪ͨ,
              �������,
              VBATCH,
              VSEQNO,
              P_PID,
              VREMAINAFTER);
    END IF;
  
    --�ύ����
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      raise_application_error(errcode, sqlerrm);
  END;
  /*==========================================================================
  һˮ���Ӧ������
  paymeter
  ���������˵������
  p_sbid        in varchar2 :��һˮ����
  p_parm_ARs   in out parm_payAR_tab :����Ϊ�գ�Ԥ���ֵ��������Ӧ�հ��ṹ���£�
                            ARid  in number :Ӧ����ˮ�����˳�Ա�������ʣ�
                            Ardpiids in varchar2 :������Ŀ����������YS_ZW_ARDETAIL��ȫ��������������Ŀ,��ǰ̨��ѡ��(Y/N)+����ID��ɵĶ�ά���飨����PG_CB_COST.FGETPARA��ά����淶�������磺Y,01|Y,02|N,03|,�������Ҫ��
                            ARznj in number :�����ʵ��ΥԼ�𣨱������ڲ����㲻У�飩��������������
                            fee1 in number  :������ϵͳʵ�շ���1
  p_trans      in varchar2 :�ɷ�����
  p_position      in varchar2 :�ɷѵ�λ��Ӫ���ܹ���Ӫҵ�����룬ʵ�ռ��ʵ�λ
  p_paypoint   in varchar2 :�ɷѵ㣬�ɷѵ�λ�¼���Ҫ���շ������ͳ����Ҫ������Ϊ��
  p_bdate      in date :ǰ̨���ڣ����н�������(yyyy-mm-dd hh24:mi:ss '2014-02-10 13:53:01')
  p_bseqno     in varchar2 :ǰ̨��ˮ�����н�����ˮ
  p_oper       in varchar2 :����Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payee      in varchar2 :�տ�Ա����̨�ɷ�ʱ������Ա���տ�Աͳһ
  p_payway     in varchar2 :���ʽ��ÿ�������ҽ���һ�ָ��ʽ
  p_payment    in number   :ʵ�գ���Ϊ������-���㣩��������������ǰ̨�����У��
  p_pid_source in number   :�ɿգ���������ʱΪ�գ�Ҳ��ʵ��Ϊ�ո�ֵΪ�µ�ʵ����ˮ�ţ������˷�׷��ʱ��ԭʵ����ˮ����ʵ���а�
  p_commit     in number   :�ύ��ʽ��0:ִ�гɹ����ύ��
                                      1:ִ�гɹ����ύ��
                                      2:���ԣ���ִ�гɹ����ύ����ģ���
  p_ctl_msg  in number   :ȫ�ֿ��Ʋ�������ֹ����֪ͨ�������£��Ƿ���֪ͨ������֯ͳһ�ɷѽ���֪ͨ���ݣ�ͨ��sendmsg���͵��ⲿ�ӿڣ����š�΢�ŵȣ���
                            �ⲿ����ʱѡ���Ƿ���Ҫ���ɷѽ��׺���ͳһ��֯���ݣ��˷�ʱ֪ͨ���ݵ����˷�ͷ��������֯������ʱ���Ȿ�����ظ�������Ҫ���Σ�
                            ֪ͨ�ͻ�  = 1
                            ��֪ͨ�ͻ�= 0
  ���������˵������
  p_batch      in out number������ֵʱ���������ɣ��ǿ�ʱ�ô�ֵ��ʵ�ռ�¼���������ʳɹ���Ľ������Σ�����ӡʱ���β�ѯ
  p_seqno      in out number������ֵʱ���������ɣ��ǿ�ʱ�ô�ֵ��ʵ�ռ�¼���������ʳɹ���Ľ������Σ�����ӡʱ���β�ѯ
  p_pid        out number���������ʳɹ���Ľ�����ˮ���������̵���
  ������˵������
  1��һˮ������������ʴκ��Ĺ��̣��ṩ���ɷ�������̵��ã�
  2��ʵ�� = ����+ʵ��ΥԼ��+Ԥ�棨������+Ԥ�棨������+������ϵͳ����123��
  3��֧��Ԥ�桢��ĩ��Ԥ�棨����ȫ�ְ��������Ƿ�Ԥ�桢�Ƿ�Ԥ�棩��
  4��֧�����ҽ���ΥԼ��Ӧ�ռ�¼����ˮ�ѡ�׷��ΥԼ���ܲ�������
  5����С���ʵ�ԪΪӦ����ϸ�л��Ӧ��ΥԼ������ǰp_parm_rls.rdpiids�г�Ա����N��ѡ״̬ʱ��ִ�С�Ӧ�յ���.�������ʡ���֮���ع�������Ӧ�հ���
  6�����ع�����Ӧ�հ��������϶�����Ŀǰ��δ��״̬��ȫ������
  7������ж�����ʵ�����ʱ�������д�������ʵ������������ǰ̨Ԥ�棩
     1������Ԥ��ʱ�����ʺ�����ĩԤ�棬�Ҽ�¼�ڷֽ�֮����Ԥ�浽������ʼ�¼�ϣ�������Ӧ�հ�ĩβ���ʵ�Ԫ����
     2��δ����Ԥ��ʱ���׳��쳣��
  8������ʵ�ղ���ʱ
     1�����ø�Ԥ��ʱ�����ʺ�����ĩ��Ԥ�棬�Ҽ�¼�ڷֽ�֮����Ԥ�浽������ʼ�¼�ϣ�������Ӧ�հ�ĩβ���ʵ�Ԫ����
     2��δ���ø�Ԥ��ʱ���׳��쳣��
  9�����ڲ��ֹ�ѡ����ɷ�ʱ����˵����ΥԼ����ǰ̨���㣬����ΥԼ��ֻ������Ӧ����ͷ����ֽ⵽Ӧ����ϸ
  ��������־����
  */
  PROCEDURE PAYCUST(P_SBID        IN VARCHAR2,
                    P_PARM_ARS    IN PARM_PAYAR_TAB,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_PID_SOURCE  IN VARCHAR2,
                    P_COMMIT      IN NUMBER,
                    P_CTL_MSG     IN NUMBER,
                    P_CTL_PRE     IN NUMBER,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    P_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_MA(VMAMID VARCHAR2) IS
      SELECT * FROM YS_YH_ACCOUNT WHERE SBID = VMAMID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    MI         YS_YH_SBINFO%ROWTYPE;
    CI         YS_YH_CUSTINFO%ROWTYPE;
    MA         YS_YH_ACCOUNT%ROWTYPE;
    P          YS_ZW_PAIDMENT%ROWTYPE;
    V_PARM_ARS PARM_PAYAR_TAB;
    P_PARM_AR  parm_payar;
    v_exists   NUMBER;
  BEGIN
    V_PARM_ARS := P_PARM_ARS;
    --1��ʵ��У�顢��Ҫ����׼��
    --------------------------------------------------------------------------
    BEGIN
      --ȡˮ����Ϣ
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                'ˮ����롾' || P_SBID || '�������ڣ�');
      END IF;
      --ȡ�û���Ϣ
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���ˮ�����û��Ӧ�û���' || P_SBID);
      END IF;
      --ȡ�û������˻���Ϣ
      OPEN C_MA(MI.SBID);
      FETCH C_MA
        INTO MA;
      IF C_MA%NOTFOUND OR C_MA%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --����У��
      /*if p_parm_rls is null then
        raise_application_error(errcode, '�����ʰ��ǿյ���ô�죿');
      end if;*/
      --��Ӻ���У��,���⻧����������б�һ��
      IF P_PARM_ARS.COUNT > 0 THEN
        --����Ϊ�գ�Ԥ���ֵʱ��
        FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
          P_PARM_AR := P_PARM_ARS(I);
          SELECT COUNT(1)
            INTO V_EXISTS
            FROM YS_ZW_ARLIST A, YS_YH_SBINFO B
           WHERE ARID = P_PARM_AR.ARID
             AND A.SBID = B.SBID
             AND (B.SBID = P_SBID OR SBPRIID = P_SBID);
          IF V_EXISTS = 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '�������������ˢ��ҳ������²���!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2����¼ʵ��
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO P_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE  := MI.HIRE_CODE;
      P.PID        := P_PID; --varchar2(10)      ��ˮ��
      P.YHID       := CI.YHID; --varchar2(10)      �û����
      P.SBID       := P_SBID; --varchar2(10)  y    ˮ����
      P.PDDATE     := TRUNC(SYSDATE); --date  y    ��������
      P.PDATETIME  := SYSDATE; --date  y    ��������
      P.PDMONTH    := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH'); --varchar2(7)  y    �ɷ��·�
      P.MANAGE_NO  := P_POSITION; --varchar2(10)  y    �ɷѻ���
      P.PDTRAN     := P_TRANS; --char(1)      �ɷ�����
      P.PDPERS     := P_OPER; --varchar2(20)  y    ������Ա
      P.PDSAVINGQC := NVL(MI.SBSAVING, 0); --number(12,2)  y    �ڳ�Ԥ�����
      P.PDSAVINGBQ := P_PAYMENT; --number(12,2)  y    ���ڷ���Ԥ����
      P.PDSAVINGQM := P.PDSAVINGQC + P.PDSAVINGBQ; --number(12,2)  y    ��ĩԤ�����
      P.PAIDMENT   := P_PAYMENT; --number(12,2)  y    ������
      P.PDIFSAVING := NULL; --char(1)  y    ����תԤ��
      P.PDCHANGE   := NULL; --number(12,2)  y    ������
      P.PDPAYWAY   := P_PAYWAY; --varchar2(6)  y    ���ʽ
      P.PDBSEQNO   := P_BSEQNO; --varchar2(20)  y    ������ˮ(����ʵʱ�շѽ�����ˮ)
      P.PDCSEQNO   := NULL; --varchar2(20)  y    ����������ˮ(no use)
      P.PDBDATE    := P_BDATE; --date  y    ��������(���нɷ���������)
      P.PDCHKDATE  := NULL; --date  y    ��������
      P.PDCCHKFLAG := 'N'; --char(1)  y    ��־(no use)
      P.PDCDATE    := NULL; --date  y    ��������
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO      := P_SEQNO; --varchar2(10)  y    �ɷѽ�����ˮ(no use)
      P.PDPAYEE      := P_OPER; --varchar2(20)  y    �տ�Ա
      P.PDCHBATCH    := NULL; --varchar2(10)  y    ֧Ʊ��������
      P.PDMEMO       := NULL; --varchar2(200)  y    ��ע
      P.PDPAYPOINT   := P_PAYPOINT; --varchar2(10)  y    �ɷѵص�
      P.PDSXF        := 0; --number(12,2)  y    ������
      P.PDILID       := NULL; --varchar2(40)  y    ��Ʊ��ˮ��
      P.PDFLAG       := 'Y'; --varchar2(1)  y    ʵ�ձ�־��ȫ��Ϊy.�������ã�
      P.PDWYJ        := 0; --number(12,2)  y    ʵ���ͽ�
      P.PDRCRECEIVED := P_PAYMENT; --number(12,2)  y      ʵ���տ��ʵ���տ��� =  ������ -��������ʽ�� + ʵ���ͽ� + ������ + ���ڷ���Ԥ���
      P.PDSPJE       := 0; --number(12,2)  y    ���ʽ��(������ʽ�����ˮ�ѣ����ʽ����Ϊˮ�ѽ������Ԥ����Ϊ0)
      P.PREVERSEFLAG := 'N'; --varchar2(1)  y    ������־����ˮ����Ԥ����Ϊn,��ˮ�ѳ�Ԥ�汻��ʵ�պͳ�ʵ�ղ���������Ϊy��
      IF P_PID_SOURCE IS NULL THEN
        P.PDSCRID    := P.PID;
        P.PDSCRTRANS := P.PDTRAN;
        P.PDSCRMONTH := P.PDMONTH;
        P.PDSCRDATE  := P.PDDATE;
      ELSE
        SELECT PID, PDTRAN, PDMONTH, PDDATE
          INTO P.PDSCRID, P.PDSCRTRANS, P.PDSCRMONTH, P.PDSCRDATE
          FROM YS_ZW_PAIDMENT
         WHERE PID = P_PID_SOURCE;
      END IF;
      P.PDCHKNO  := NULL; --varchar2(10)  y    ���˵���
      P.PDPRIID  := MI.SBPRIID; --varchar2(20)  y    ���������  20150105
      P.TCHKDATE := NULL; --date  y    ��������
    END;
  
    --3�����ַ������ʷ���
    --------------------------------------------------------------------------
    IF P_CTL_PRE = ������� THEN
      PAYZWARPRE(V_PARM_ARS, ���ύ);
    END IF;
  
    --3.1����ΥԼ�����ʷ���
    --------------------------------------------------------------------------
    IF ��������ΥԼ����� THEN
      PAYWYJPRE(V_PARM_ARS, ���ύ);
    END IF;
  
    --4�����ʺ��ĵ��ã�Ӧ�ռ�¼��������ʵ�����ݣ�
    --------------------------------------------------------------------------
    PAYZWARCORE(P.PID,
                P.PDBATCH,
                P_PAYMENT,
                MI.SBSAVING,
                P.PDDATE,
                P.PDMONTH,
                V_PARM_ARS,
                ���ύ,
                P.PDSPJE,
                P.PDWYJ,
                P.PDSXF);
  
    --5������Ԥ�淢����Ԥ����ĩ�������û�Ԥ�����
    P.PDSAVINGQM := P.PDSAVINGQC + P_PAYMENT - P.PDSPJE - P.PDWYJ - P.PDSXF;
    P.PDSAVINGBQ := P.PDSAVINGQM - P.PDSAVINGQC;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --6������Ԥ�����
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --7��������Ӧʵ������ƽ��У�飬��У����֧�ӹ���
    --------------------------------------------------------------------------
  
    --8�������ɷ�����������
  
    --5���ύ����
    BEGIN
      CLOSE C_MA;
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_PAIDMENT VALUES P;
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_MA%ISOPEN THEN
        CLOSE C_MA;
      END IF;
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  ���ַ�����Ŀ����ǰ���Ӧ�գ�һӦ���ʣ�����Ҫ�������ʰ��ǿ�ʱ�ܾ�0���ʵ��
  ���������˵������
  p_parm_ars in out parm_payar_tab������Ϊ�գ�Ԥ���ֵ��������Ӧ�հ�
                arid  in number :Ӧ����ˮ�����˳�Ա�������ʣ�
                ardpiids in varchar2 : ����������Ŀ,���Ƿ�����(Y/N)+����ID��ɵĶ�ά���飨����PG_CB_COST.FGETPARA��ά����淶�������磺Y,01|Y,02|N,03|,�������Ҫ��
                        Ϊ��ʱ�����ԣ�����
                        �ǿ�ʱ��1��������YS_ZW_ARDETAIL��ȫ��������Ŀ����
                                2��YN�����ϱ�������з�0��������ԣ�����
                arznj in number :�����ΥԼ�𣨱������ڲ����㲻У�飩��������������
                fee1 in number  :������ϵͳ����1
  p_commit in number default ���ύ
  ���������˵������
  ������˵������
  1���������ʰ����У�飻
  2�������ڲ��ַ������ʱ�־λ���ҷ�����0����Ӧ�յ�����ʽ���Ӧ���ʣ�����ԭ�����أ�
  3���ع���ȫ�����ʰ������ط���ԭ�����أ�
  ��������־����
  */
  PROCEDURE PAYZWARPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                       P_COMMIT   IN NUMBER DEFAULT ���ύ) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_RD(VARID VARCHAR2, VARDPIID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
         AND ARDPIID = VARDPIID
       ORDER BY ARDCLASS
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    P_PARM_AR          PARM_PAYAR; --���ʰ��ڳ�Ա֮һ
    I                  INTEGER;
    J                  INTEGER;
    K                  INTEGER;
    һ�з�����         INTEGER;
    һ��һ����         VARCHAR2(10);
    һ��һ���������־ CHAR(1);
    �ܽ��             NUMBER(13, 3) := 0;
    ��������           NUMBER(10) := 0;
    ��������           NUMBER(10) := 0;
    ����ˮ��           NUMBER(10) := 0;
    ����ˮ��           NUMBER(10) := 0;
    �������           NUMBER(13, 3) := 0;
    �������           NUMBER(13, 3) := 0;
    --������ԭӦ��
    RL YS_ZW_ARLIST%ROWTYPE;
    RD YS_ZW_ARDETAIL%ROWTYPE;
    --���Ӧ��1��Ҫ���ģ�
    RLY    YS_ZW_ARLIST%ROWTYPE;
    RDY    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABY RD_TABLE;
    --���Ӧ��2������������Ƿ�ѵģ�
    RLN    YS_ZW_ARLIST%ROWTYPE;
    RDN    YS_ZW_ARDETAIL%ROWTYPE;
    RDTABN RD_TABLE;
    --
    O_ARID_REVERSE        YS_ZW_ARLIST.ARID%TYPE;
    O_ARTRANS_REVERSE     VARCHAR2(10);
    O_ARJE_REVERSE        NUMBER;
    O_ARZNJ_REVERSE       NUMBER;
    O_ARSXF_REVERSE       NUMBER;
    O_ARSAVINGBQ_REVERSE  NUMBER;
    IO_ARSAVINGQM_REVERSE NUMBER;
    --
    CURRENTDATE DATE;
  BEGIN
    CURRENTDATE := SYSDATE;
    --����Ϊ�գ�Ԥ���ֵʱ�����հ�����
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '���ʰ���Ӧ����ˮ������' || P_PARM_AR.ARID);
          END IF;
          IF P_PARM_AR.ARDPIIDS IS NOT NULL THEN
            RLY      := RL;
            RLY.ARJE := 0;
            RDTABY   := NULL;
          
            RLN        := RL;
            RLN.ARJE   := 0;
            RLN.ARSXF  := 0; --Rlfee�����У�����rlY���ұ������ʣ��ݲ�֧�ֲ��
            RDTABN     := NULL;
            ��������   := 0;
            ��������   := 0;
            ����ˮ��   := 0;
            ����ˮ��   := 0;
            �������   := 0;
            �������   := 0;
            һ�з����� := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
            FOR J IN 1 .. һ�з����� LOOP
              һ��һ���������־ := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
              һ��һ����         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
              OPEN C_RD(P_PARM_AR.ARID, һ��һ����);
              LOOP
                --���ڽ��ݣ�����Ҫѭ��
                FETCH C_RD
                  INTO RD;
                EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
                RDY    := RD;
                RDN    := RD;
                �ܽ�� := �ܽ�� + RD.ARDJE;
                IF һ��һ���������־ = 'Y' THEN
                  RLY.ARJE     := RLY.ARJE + RDY.ARDJE;
                  ��������     := �������� + 1;
                  ����ˮ��     := ����ˮ�� + RD.ARDSL;
                  �������     := ������� + RD.ARDJE;
                  RDN.ARDYSSL  := 0;
                  RDN.ARDYSJE  := 0;
                  RDN.ARDSL    := 0;
                  RDN.ARDJE    := 0;
                  RDN.ARDADJSL := 0;
                  RDN.ARDADJJE := 0;
                ELSIF һ��һ���������־ = 'N' THEN
                  RLN.ARJE     := RLN.ARJE + RDN.ARDJE;
                  ��������     := �������� + 1;
                  ����ˮ��     := ����ˮ�� + RD.ARDSL;
                  �������     := ������� + RD.ARDJE;
                  RDY.ARDYSSL  := 0;
                  RDY.ARDYSJE  := 0;
                  RDY.ARDSL    := 0;
                  RDY.ARDJE    := 0;
                  RDY.ARDADJSL := 0;
                  RDY.ARDADJJE := 0;
                ELSE
                  RAISE_APPLICATION_ERROR(ERRCODE,
                                          '�޷�ʶ�����ʰ��д����ʱ�־');
                END IF;
                --���Ƶ�rdY
                IF RDTABY IS NULL THEN
                  RDTABY := RD_TABLE(RDY);
                ELSE
                  RDTABY.EXTEND;
                  RDTABY(RDTABY.LAST) := RDY;
                END IF;
                --���Ƶ�rdN
                IF RDTABN IS NULL THEN
                  RDTABN := RD_TABLE(RDN);
                ELSE
                  RDTABN.EXTEND;
                  RDTABN(RDTABN.LAST) := RDN;
                END IF;
              END LOOP;
              CLOSE C_RD;
            END LOOP;
            --ĳһ��Ӧ���ʷ����������ʱ�־�Ų��
            IF �������� != 0 THEN
              IF �������� != 0 THEN
                --Ӧ�յ���1���ڱ���ȫ����
                ZWARREVERSECORE(P_PARM_AR.ARID,
                                RL.ARTRANS,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                ���ύ,
                                O_ARID_REVERSE,
                                O_ARTRANS_REVERSE,
                                O_ARJE_REVERSE,
                                O_ARZNJ_REVERSE,
                                O_ARSXF_REVERSE,
                                O_ARSAVINGBQ_REVERSE,
                                IO_ARSAVINGQM_REVERSE);
                --Ӧ�յ���2.1���ڱ���׷��Ŀ��Ӧ�գ������ʲ��֣�
                RLY.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLY.ARMONTH    := FOBTMANAPARA(RLY.MANAGE_NO, 'READ_MONTH');
                RLY.ARDATE     := TRUNC(SYSDATE);
                RLY.ARDATETIME := CURRENTDATE;
                RLY.ARREADSL   := 0;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABY(K).ARDID FROM DUAL;
                  RDTABY(K).ARDID := RLY.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLY;
                FOR K IN RDTABY.FIRST .. RDTABY.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABY (K);
                END LOOP;
                --Ӧ�յ���2.2���ڱ���׷��Ŀ��Ӧ�գ�������Ƿ�Ѳ��֣�
                RLN.ARID       := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
                RLN.ARMONTH    := FOBTMANAPARA(RLN.MANAGE_NO, 'READ_MONTH');
                RLN.ARDATE     := TRUNC(SYSDATE);
                RLN.ARDATETIME := CURRENTDATE;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  SELECT SEQ_ARID.NEXTVAL INTO RDTABN(K).ARDID FROM DUAL;
                  RDTABN(K).ARDID := RLN.ARID;
                END LOOP;
                INSERT INTO YS_ZW_ARLIST VALUES RLN;
                FOR K IN RDTABN.FIRST .. RDTABN.LAST LOOP
                  INSERT INTO YS_ZW_ARDETAIL VALUES RDTABN (K);
                END LOOP;
                --�ع����ʰ�����
                P_PARM_ARS(I).ARID := RLY.ARID;
                P_PARM_ARS(I).ARDPIIDS := REPLACE(P_PARM_ARS(I).ARDPIIDS,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --��������=0
              P_PARM_ARS.DELETE(I);
            END IF;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    
    END IF;
    --5���ύ����
    BEGIN
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  Ӧ�ճ�������
  ���������˵������
  p_arid_source  in number �������ԭӦ�ռ�¼��ˮ�ţ�
  p_pid_reverse  in number �����ɿղ��������������˷ѵ���ʱ��Ҫ��ǰ�ù��̲����ĳ���ʵ����ˮ�ţ�
                              �ڴ˹��������������Ӧ�ռ�¼��
  p_ppayment_reverse in number �����ɿղ�������ͬ�ϲ����������˷ѵ���ʱ��Ҫ��ǰ�ù��̲����ĳ���ʵ�ս�������
                                  ��������Ӧ�յĳ���ʱ��
                                  1�����˱��ֵ����ʼ�¼��ʵ�ռ�¼������ƽ�⣻
                                  2�����˿�������Ԥ�淢���������˷Ѳ���Ҫ����Ԥ��������ʵ�ճ���ʱ�����У�;
  p_memo ���ⲿ��������ע��Ϣ
  p_commit �� �Ƿ�������ύ
  ���������˵������
  o_arid_reverse out varchar2������Ӧ����ˮ
  o_artrans_reverse out varchar2������Ӧ������
  o_arje_reverse out number���������ʽ��
  o_arznj_reverse out number����������ΥԼ��
  o_arsxf_reverse out number����������������1
  o_arsavingbq_reverse out number����������Ԥ�淢��
  io_arsavingqm_reverse in out number���ⲿ����'����Ӧ��'ѭ��ʱ����ĩԤ�棨�ۼ�����
  ������˵������
  ����һ��Ӧ�����ʼ�¼ȫ���������Ӧ������ͬʱΪ���ʼ�¼����Ҫ���±������ʼ�¼��������Ϣ��
  �ṩ����Ԥ����ʵ�ճ������˷ѡ�Ӧ�յ�����ҵ����̵��ã�
  ��������־����
  */
  PROCEDURE ZWARREVERSECORE(P_ARID_SOURCE         IN VARCHAR2,
                            P_ARTRANS_REVERSE     IN VARCHAR2,
                            P_PBATCH_REVERSE      IN VARCHAR2,
                            P_PID_REVERSE         IN VARCHAR2,
                            P_PPAYMENT_REVERSE    IN NUMBER,
                            P_MEMO                IN VARCHAR2,
                            P_CTL_MIRCODE         IN VARCHAR2,
                            P_COMMIT              IN NUMBER DEFAULT ���ύ,
                            O_ARID_REVERSE        OUT VARCHAR2,
                            O_ARTRANS_REVERSE     OUT VARCHAR2,
                            O_ARJE_REVERSE        OUT NUMBER,
                            O_ARZNJ_REVERSE       OUT NUMBER,
                            O_ARSXF_REVERSE       OUT NUMBER,
                            O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                            IO_ARSAVINGQM_REVERSE IN OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARDETAIL
       WHERE ARDID = VARID
       ORDER BY ARDPIID, ARDCLASS
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_P_REVERSE(VRPID VARCHAR2) IS
      SELECT * FROM YS_ZW_PAIDMENT WHERE PID = VRPID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    SUBTYPE RD_TYPE IS YS_ZW_ARDETAIL%ROWTYPE;
    TYPE RD_TABLE IS TABLE OF RD_TYPE;
    --������ԭӦ��
    RL_SOURCE YS_ZW_ARLIST%ROWTYPE;
    RD_SOURCE YS_ZW_ARDETAIL%ROWTYPE;
    --����Ӧ��
    RL_REVERSE     YS_ZW_ARLIST%ROWTYPE;
    RD_REVERSE     YS_ZW_ARDETAIL%ROWTYPE;
    RD_REVERSE_TAB RD_TABLE;
    --
    P_REVERSE YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    OPEN C_RL(P_ARID_SOURCE);
    FETCH C_RL
      INTO RL_SOURCE;
    IF C_RL%FOUND THEN
      --���Ĳ���У��
      IF �����ظ����� = 0 AND RL_SOURCE.AROUTFLAG = 'Y' THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '��ǰϵͳ�����������н���Ӧ�ճ���');
      END IF;
    
      RL_REVERSE                := RL_SOURCE;
      RL_REVERSE.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
      RL_REVERSE.ARDATE         := TRUNC(SYSDATE);
      RL_REVERSE.ARDATETIME     := SYSDATE; --20140514 add
      RL_REVERSE.ARMONTH        := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                                'READ_MONTH');
      RL_REVERSE.ARCD           := ����;
      RL_REVERSE.ARREADSL       := -RL_REVERSE.ARREADSL; --20140707 add
      RL_REVERSE.ARSL           := -RL_REVERSE.ARSL;
      RL_REVERSE.ARJE           := -RL_REVERSE.ARJE; --��ȫ��
      RL_REVERSE.ARZNJREDUCFLAG := RL_REVERSE.ARZNJREDUCFLAG;
      RL_REVERSE.ARZNJ          := -RL_REVERSE.ARZNJ; --�����������ԭӦ������ΥԼ��,δ�����Ӧ��ΥԼ��
      RL_REVERSE.ARSXF          := -RL_REVERSE.ARSXF; --�����������ԭӦ������������1��,δ�����Ӧ��������1
      RL_REVERSE.ARREVERSEFLAG  := 'Y';
      RL_REVERSE.ARMEMO         := P_MEMO;
      RL_REVERSE.ARTRANS        := P_ARTRANS_REVERSE;
      --Ӧ�ճ��������̵����£�������Ϣ�̳�Դ��
      --ʵ�ճ��������̵����£�������Ϣ��д�����ж�ʵ�ճ�������
      --�˿ʵ�ռơ�ʵ�ճ���������C��Ӧ�ռơ�����������C
      --���˿�̳�ԭʵ�ա�Ӧ������
      IF P_PID_REVERSE IS NOT NULL THEN
        OPEN C_P_REVERSE(P_PID_REVERSE);
        FETCH C_P_REVERSE
          INTO P_REVERSE;
        IF C_P_REVERSE%NOTFOUND OR C_P_REVERSE%NOTFOUND IS NULL THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '�������ʲ�����');
        END IF;
        CLOSE C_P_REVERSE;
      
        RL_REVERSE.ARPAIDDATE  := TRUNC(SYSDATE); --���������¼��������
        RL_REVERSE.ARPAIDMONTH := FOBTMANAPARA(RL_REVERSE.MANAGE_NO,
                                               'READ_MONTH'); --���������¼��������
      
        RL_REVERSE.ARPAIDJE   := P_PPAYMENT_REVERSE; --������Ϣ��д
        RL_REVERSE.ARSAVINGQC := (CASE
                                   WHEN IO_ARSAVINGQM_REVERSE IS NULL THEN
                                    P_REVERSE.PDSAVINGQC
                                   ELSE
                                    IO_ARSAVINGQM_REVERSE
                                 END); --������Ϣ����д
        RL_REVERSE.ARSAVINGBQ := RL_REVERSE.ARPAIDJE - RL_REVERSE.ARJE -
                                 RL_REVERSE.ARZNJ - RL_REVERSE.ARSXF; --������Ϣ��д
        RL_REVERSE.ARSAVINGQM := RL_REVERSE.ARSAVINGQC +
                                 RL_REVERSE.ARSAVINGBQ; --������Ϣ��д
        RL_REVERSE.ARPID      := P_PID_REVERSE;
        RL_REVERSE.ARPBATCH   := P_PBATCH_REVERSE;
        IO_ARSAVINGQM_REVERSE := RL_REVERSE.ARSAVINGQM;
      END IF;
      --rlscrrlid    := ;--�̳�ԭӦ��ֵ
      --rlscrrldate  := ;--�̳�ԭӦ��ֵ
      --rlscrrlmonth := ;--�̳�ԭӦ��ֵ
      --rlscrrllb    := ;--�̳�ԭӦ��ֵ
      OPEN C_RD(P_ARID_SOURCE);
      LOOP
        FETCH C_RD
          INTO RD_SOURCE;
        EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
        RD_REVERSE := RD_SOURCE;
        SELECT SEQ_ARID.NEXTVAL INTO RD_REVERSE.ARDID FROM DUAL;
        RD_REVERSE.ARDID    := RL_REVERSE.ARID;
        RD_REVERSE.ARDYSSL  := -RD_REVERSE.ARDYSSL;
        RD_REVERSE.ARDYSJE  := -RD_REVERSE.ARDYSJE;
        RD_REVERSE.ARDSL    := -RD_REVERSE.ARDSL;
        RD_REVERSE.ARDJE    := -RD_REVERSE.ARDJE;
        RD_REVERSE.ARDADJSL := -RD_REVERSE.ARDADJSL;
        RD_REVERSE.ARDADJJE := -RD_REVERSE.ARDADJJE;
        --���Ƶ�rd_reverse_tab
        IF RD_REVERSE_TAB IS NULL THEN
          RD_REVERSE_TAB := RD_TABLE(RD_REVERSE);
        ELSE
          RD_REVERSE_TAB.EXTEND;
          RD_REVERSE_TAB(RD_REVERSE_TAB.LAST) := RD_REVERSE;
        END IF;
      END LOOP;
      CLOSE C_RD;
    ELSE
      RAISE_APPLICATION_ERROR(ERRCODE, '��Ч��Ӧ����ˮ��');
    END IF;
    --����ֵ
    O_ARID_REVERSE       := RL_REVERSE.ARID;
    O_ARTRANS_REVERSE    := RL_REVERSE.ARTRANS;
    O_ARJE_REVERSE       := RL_REVERSE.ARJE;
    O_ARZNJ_REVERSE      := RL_REVERSE.ARZNJ;
    O_ARSXF_REVERSE      := RL_REVERSE.ARSXF;
    O_ARSAVINGBQ_REVERSE := RL_REVERSE.ARSAVINGBQ;
    --2���ύ����
    BEGIN
      CLOSE C_RL;
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        INSERT INTO YS_ZW_ARLIST VALUES RL_REVERSE;
        FOR K IN RD_REVERSE_TAB.FIRST .. RD_REVERSE_TAB.LAST LOOP
          INSERT INTO YS_ZW_ARDETAIL VALUES RD_REVERSE_TAB (K);
        END LOOP;
        UPDATE YS_ZW_ARLIST
           SET ARREVERSEFLAG = 'Y'
         WHERE ARID = P_ARID_SOURCE;
        --�������Ƹ�ֵ
        IF P_CTL_MIRCODE IS NOT NULL THEN
          UPDATE YS_YH_SBINFO
             SET SBRCODE = TO_NUMBER(P_CTL_MIRCODE)
           WHERE SBID = RL_SOURCE.SBID;
        END IF;
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_P_REVERSE%ISOPEN THEN
        CLOSE C_P_REVERSE;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  ����ΥԼ��������ʰ�Ԥ����
  ���������˵������
  p_parm_ars in out parm_payar_tab������Ϊ�գ�Ԥ���ֵ��������Ӧ�հ�
                arid  in number :Ӧ����ˮ�����˳�Ա�������ʣ�
                ardpiids in varchar2 : ����������Ŀ,���Ƿ�����(Y/N)+����ID��ɵĶ�ά���飨����PG_CB_COST.FGETPARA��ά����淶�������磺Y,01|Y,02|N,03|,�������Ҫ��
                        Ϊ��ʱ�����ԣ�����
                        �ǿ�ʱ��1��������ys_zw_ardetail��ȫ��������Ŀ����
                                2��YN�����ϱ�������з�0��������ԣ�����
                arznj in number :�����ΥԼ�𣨱������ڲ����㲻У�飩��������������
                fee1 in number  :������ϵͳ����1
  p_commit in number default ���ύ
  ���������˵������
  ������˵������
  1���������ʰ����У�飻
  3���ع������ʰ������ط���ԭ�����أ�
  ��������־����
  */
  PROCEDURE PAYWYJPRE(P_PARM_ARS IN OUT PARM_PAYAR_TAB,
                      P_COMMIT   IN NUMBER DEFAULT ���ύ) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARLIST WHERE ARID = VARID;
    CURSOR C_RD(VARID VARCHAR2) IS
      SELECT * FROM YS_ZW_ARDETAIL WHERE ARDID = VARID;
    P_PARM_AR  PARM_PAYAR := PARM_PAYAR(NULL, NULL, NULL, NULL, NULL, NULL);
    V_PARM_ARS PARM_PAYAR_TAB := PARM_PAYAR_TAB();
    --������ԭӦ��
    RL                 YS_ZW_ARLIST%ROWTYPE;
    RD                 YS_ZW_ARDETAIL%ROWTYPE;
    VEXIST             NUMBER := 0;
    һ�з�����         INTEGER;
    һ��һ����         VARCHAR2(10);
    һ��һ���������־ CHAR(1);
  BEGIN
    --����Ϊ�գ�Ԥ���ֵʱ�����հ�����
    IF P_PARM_ARS.COUNT > 0 THEN
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        IF P_PARM_AR.ARWYJ <> 0 AND P_PARM_AR.ARID IS NOT NULL THEN
          OPEN C_RL(P_PARM_AR.ARID);
          FETCH C_RL
            INTO RL;
          IF C_RL%NOTFOUND OR C_RL%NOTFOUND IS NULL THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '���ʰ���Ӧ����ˮ������' || P_PARM_AR.ARID);
          END IF;
          һ�з����� := PG_CB_COST.FBOUNDPARA(P_PARM_AR.ARDPIIDS);
          FOR J IN 1 .. һ�з����� LOOP
            һ��һ���������־ := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 1);
            һ��һ����         := PG_CB_COST.FGETPARA(P_PARM_AR.ARDPIIDS, J, 2);
            IF һ��һ���������־ = 'N' AND UPPER(һ��һ����) = 'ZNJ' THEN
              VEXIST := 1;
            END IF;
          END LOOP;
          IF VEXIST = 1 THEN
            RL.ARID           := LPAD(SEQ_ARID.NEXTVAL, 10, '0');
            RL.ARJE           := 0;
            RL.ARSL           := 0;
            RL.ARZNJ          := P_PARM_AR.ARWYJ;
            RL.ARMEMO         := 'ΥԼ��׷��';
            RL.ARZNJREDUCFLAG := 'Y';
            OPEN C_RD(P_PARM_AR.ARID);
            LOOP
              FETCH C_RD
                INTO RD;
              EXIT WHEN C_RD%NOTFOUND OR C_RD%NOTFOUND IS NULL;
              RD.ARDID    := RL.ARID;
              RD.ARDSL    := 0;
              RD.ARDJE    := 0;
              RD.ARDYSSL  := 0;
              RD.ARDYSJE  := 0;
              RD.ARDADJSL := 0;
              RD.ARDADJJE := 0;
              INSERT INTO YS_ZW_ARDETAIL VALUES RD;
            END LOOP;
            INSERT INTO YS_ZW_ARLIST VALUES RL;
            CLOSE C_RD;
            --
            P_PARM_AR.ARID := RL.ARID;
            IF V_PARM_ARS IS NULL THEN
              V_PARM_ARS := PARM_PAYAR_TAB(P_PARM_AR);
            ELSE
              V_PARM_ARS.EXTEND;
              V_PARM_ARS(V_PARM_ARS.LAST) := P_PARM_AR;
            END IF;
            --
            P_PARM_ARS(I).ARWYJ := 0;
          END IF;
          CLOSE C_RL;
        END IF;
      END LOOP;
    END IF;
    --5���ύ����
    BEGIN
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      IF C_RD%ISOPEN THEN
        CLOSE C_RD;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  ʵ�����ʴ������
  ���������˵������
  p_pid in varchar2,
  p_payment in number��ʵ�ս��
  p_remainbefore in number�����ʰ�����ǰ���ڳ��û�Ԥ�����
  p_paiddate in date,
  p_paidmonth in varchar2,
  p_parm_rls in parm_pay1rl_tab,����Ϊ�գ�Ԥ���ֵʱ�������ʰ�˵��
                                �����̺�����rdpiids��Աֵ��Ĭ�ϡ�����Ӧ�����˺͹���Ӧ����ϸȫ����ȫ������
                                ������Ա���paymeter˵��������
  p_commit in number default ���ύ���Ƿ��ύ
  
  ���������˵������
  o_sum_arje out number���ۼ����ʽ�ֻ������Ӧ����ϸ�еĽ�
  o_sum_arsavingbq out number���ۼ�Ԥ�淢��
  
  ������˵������
  1��Ӧ�����ʰ�����Ϊ�գ�Ԥ���ֵʱ����
  2���ǿ�ʱ��Ҳ�������ʰ�������������������Ӧ��id��������۸������ʱ�����������£�
  3������Ӧ�����˼������Ӧ����ϸȫ�����ʣ�
  4������Ӧ������0������ʣ�
  5������Ӧ����ͷ����ϸ���е�������Ϣ
  6������ʵ�ս����Ϣ
  7��Ԥ�������߼��������ʰ���Ӧ�մ������ʣ��ʽ��Ƚ����������ʺ�ʵ�ս�����¼�����������������һ�����ʼ�¼��
  
  ��������־����
  */
  PROCEDURE PAYZWARCORE(P_PID          IN VARCHAR2,
                        P_BATCH        IN VARCHAR2,
                        P_PAYMENT      IN NUMBER,
                        P_REMAINBEFORE IN NUMBER,
                        P_PAIDDATE     IN DATE,
                        P_PAIDMONTH    IN VARCHAR2,
                        P_PARM_ARS     IN PARM_PAYAR_TAB,
                        P_COMMIT       IN NUMBER DEFAULT ���ύ,
                        O_SUM_ARJE     OUT NUMBER,
                        O_SUM_ARZNJ    OUT NUMBER,
                        O_SUM_ARSXF    OUT NUMBER) IS
    CURSOR C_RL(VARID VARCHAR2) IS
      SELECT *
        FROM YS_ZW_ARLIST
       WHERE ARID = VARID
         AND ARPAIDFLAG = 'N'
         AND ARREVERSEFLAG = 'N' /*and rlje>0*/ /*֧��0�������*/
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    RL          YS_ZW_ARLIST%ROWTYPE;
    P_PARM_AR   PARM_PAYAR;
    SUMRLPAIDJE NUMBER(13, 3) := 0; --�ۼ�ʵ�ս�Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123��
    P_REMAIND   NUMBER(13, 3); --�ڳ�Ԥ���ۼ���
  BEGIN
    --�ڳ�Ԥ���ۼ�����ʼ��
    P_REMAIND := P_REMAINBEFORE;
    --����ֵ��ʼ���������ʰ��ǿյ����α��ֵ����
    O_SUM_ARJE  := 0;
    O_SUM_ARZNJ := 0;
    O_SUM_ARSXF := 0;
    SAVEPOINT δ��״̬;
    IF P_PARM_ARS.COUNT > 0 THEN
      --����Ϊ�գ�Ԥ���ֵʱ��
      FOR I IN P_PARM_ARS.FIRST .. P_PARM_ARS.LAST LOOP
        P_PARM_AR := P_PARM_ARS(I);
        OPEN C_RL(P_PARM_AR.ARID);
        --���ʰ��ǿ�ʱ��Ҳ�����������������������Ӧ��id��������۸������ʱ������������
        FETCH C_RL
          INTO RL;
        IF C_RL%FOUND THEN
          --��֯һ������Ӧ�ռ�¼���±���
          RL.ARPAIDFLAG  := 'Y'; --varchar2(1)  y  'n'    �Ƿ����˱�־��ȫ�����ʡ��������м�״̬��
          RL.ARSAVINGQC  := P_REMAIND; --number(13,2)  y  0    �����ڳ�Ԥ��
          RL.ARSAVINGBQ  := -PG_CB_COST.GETMIN(P_REMAIND,
                                               RL.ARJE + P_PARM_AR.ARWYJ +
                                               P_PARM_AR.FEE1); --number(13,2)  y  0    ����Ԥ�淢����������
          RL.ARSAVINGQM  := RL.ARSAVINGQC + RL.ARSAVINGBQ; --number(13,2)  y  0    ������ĩԤ��
          RL.ARZNJ       := P_PARM_AR.ARWYJ; --number(13,2)  y  0    ʵ��ΥԼ��
          RL.ARSXF       := P_PARM_AR.FEE1; --number(13,2)  y  0    ʵ��������ϵͳ����1
          RL.ARPAIDDATE  := P_PAIDDATE; --date  y      �������ڣ�ʵ������ʱ�ӣ�
          RL.ARPAIDMONTH := P_PAIDMONTH; --varchar2(7)  y      �����·ݣ�ʵ������ʱ�ӣ�
          RL.ARPAIDJE    := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    ʵ�ս�ʵ�ս��=Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123+Ԥ�淢������sum(rl.rlpaidje)=p.ppayment
          RL.ARPID       := P_PID; --
          RL.ARPBATCH    := P_BATCH;
          RL.ARMICOLUMN1 := '';
          --�м��������
          SUMRLPAIDJE := SUMRLPAIDJE + RL.ARPAIDJE;
          --ĩ�����ʼ�¼�������������ʵ�ս�����ĩ�����ʼ�¼��Ԥ�淢���У�����
          IF I = P_PARM_ARS.LAST THEN
            RL.ARSAVINGBQ := RL.ARSAVINGBQ + (P_PAYMENT - SUMRLPAIDJE);
            RL.ARSAVINGQM := RL.ARSAVINGQC + RL.ARSAVINGBQ;
            RL.ARPAIDJE   := RL.ARJE + RL.ARZNJ + RL.ARSXF + RL.ARSAVINGBQ; --number(13,2)  y  0    ʵ�ս�ʵ�ս��=Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123+Ԥ�淢������sum(rl.rlpaidje)=p.ppayment
          END IF;
          --���Ĳ���У��
          IF NOT ����Ԥ�淢�� AND RL.ARSAVINGBQ != 0 THEN
            RAISE_APPLICATION_ERROR(ERRCODE,
                                    '��ǰϵͳ����Ϊ��֧��Ԥ�淢��');
          END IF;
          --����ʵ�ռ�¼
          O_SUM_ARJE  := O_SUM_ARJE + RL.ARJE;
          O_SUM_ARZNJ := O_SUM_ARZNJ + RL.ARZNJ;
          O_SUM_ARSXF := O_SUM_ARSXF + RL.ARSXF;
          P_REMAIND   := P_REMAIND + RL.ARSAVINGBQ;
          --���´�����Ӧ�ռ�¼
          UPDATE YS_ZW_ARLIST
             SET ARPAIDFLAG  = RL.ARPAIDFLAG,
                 ARSAVINGQC  = RL.ARSAVINGQC,
                 ARSAVINGBQ  = RL.ARSAVINGBQ,
                 ARSAVINGQM  = RL.ARSAVINGQM,
                 ARZNJ       = RL.ARZNJ,
                 ARMICOLUMN1 = RL.ARMICOLUMN1,
                 ARSXF       = RL.ARSXF,
                 ARPAIDDATE  = RL.ARPAIDDATE,
                 ARPAIDMONTH = RL.ARPAIDMONTH,
                 ARPAIDJE    = RL.ARPAIDJE,
                 ARPID       = RL.ARPID,
                 ARPBATCH    = RL.ARPBATCH,
                 AROUTFLAG   = 'N'
           WHERE ARID = RL.ARID; --current of c_rl;Ч�ʵ�
        ELSE
          O_SUM_ARSXF := O_SUM_ARSXF + P_PARM_AR.FEE1;
        END IF;
        CLOSE C_RL;
      END LOOP;
    END IF;
  
    --���Ĳ���У��
    IF ����Ϊ��Ԥ�治���� AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      O_SUM_ARJE  := 0;
      O_SUM_ARZNJ := 0;
      O_SUM_ARSXF := 0;
      ROLLBACK TO δ��״̬;
    END IF;
  
    --���Ĳ���У��
    IF NOT ��������Ԥ�� AND P_REMAIND < 0 AND P_REMAIND < P_REMAINBEFORE THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ǰϵͳ����Ϊ��֧�ַ���������ĩ��Ԥ��');
    END IF;
  
    --5���ύ����
    BEGIN
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_RL%ISOPEN THEN
        CLOSE C_RL;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  Ԥ���ֵ��һ��
  ���������˵������
  ���������˵������
  ������˵������
  ��������־����
  */
  PROCEDURE PRECUST(P_SBID        IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --У��
    IF P_PAYMENT <= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'Ԥ���ֵҵ�������Ϊ����Ŷ');
    END IF;
    --���ú���
    PRECORE(P_SBID,
            PTRANS_����Ԥ��,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            ���ύ,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  Ԥ���˷ѣ�һ��
  ���������˵������
  ���������˵������
  ������˵������
  ��������־����
  */
  PROCEDURE PRECUSTBACK(P_SBID        IN VARCHAR2,
                        P_POSITION    IN VARCHAR2,
                        P_OPER        IN VARCHAR2,
                        P_PAYWAY      IN VARCHAR2,
                        P_PAYMENT     IN NUMBER,
                        P_MEMO        IN VARCHAR2,
                        P_BATCH       IN OUT VARCHAR2,
                        O_PID         OUT VARCHAR2,
                        O_REMAINAFTER OUT NUMBER) IS
  
    P_SEQNO VARCHAR2(10);
  BEGIN
    --У��
    IF P_PAYMENT >= 0 THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'Ԥ���ֵҵ�������Ϊ����Ŷ');
    END IF;
    --���ú���
    PRECORE(P_SBID,
            PTRANS_����Ԥ��,
            P_POSITION,
            NULL,
            NULL,
            NULL,
            P_OPER,
            P_PAYWAY,
            P_PAYMENT,
            ���ύ,
            P_MEMO,
            P_BATCH,
            P_SEQNO,
            O_PID,
            O_REMAINAFTER);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  /*==========================================================================
  Ԥ��ʵ�մ������
  ���������˵������
  p_sbid        in varchar2��ָ��Ԥ�淢����ˮ����
  p_trans      in varchar2��ָ��Ԥ�淢������ʵ������
  p_position      in varchar2��ָ��Ԥ�淢���ɷѵ�λ
  p_paypoint   in varchar2��ָ��Ԥ�淢���ɷѵص�
  p_bdate      in date��ָ��Ԥ�淢��������������
  p_bseqno     in varchar2��ָ��Ԥ�淢�����н�����ˮ
  p_oper       in varchar2��Ԥ���տ���
  p_payway     in varchar2��Ԥ�淢�����ʽ
  p_payment    in number��Ԥ�淢����+/-��
  p_commit     in number���Ƿ��ύ
  p_memo       in varchar2����ע��Ϣ
  p_batch      in out number���ɿգ�������
  p_seqno      in out number���ɿգ���������ˮ
  ���������˵������
  p_pid        out number��Ԥ�淢����¼���ʳɹ��󷵻ص�ʵ����ˮ��
  ������˵������
  ��������־����
  */
  PROCEDURE PRECORE(P_SBID        IN VARCHAR2,
                    P_TRANS       IN VARCHAR2,
                    P_POSITION    IN VARCHAR2,
                    P_PAYPOINT    IN VARCHAR2,
                    P_BDATE       IN DATE,
                    P_BSEQNO      IN VARCHAR2,
                    P_OPER        IN VARCHAR2,
                    P_PAYWAY      IN VARCHAR2,
                    P_PAYMENT     IN NUMBER,
                    P_COMMIT      IN NUMBER,
                    P_MEMO        IN VARCHAR2,
                    P_BATCH       IN OUT VARCHAR2,
                    P_SEQNO       IN OUT VARCHAR2,
                    O_PID         OUT VARCHAR2,
                    O_REMAINAFTER OUT NUMBER) IS
    CURSOR C_CI(VCIID VARCHAR2) IS
      SELECT * FROM YS_YH_CUSTINFO WHERE YHID = VCIID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR C_MI(VMIID VARCHAR2) IS
      SELECT * FROM YS_YH_SBINFO WHERE SBID = VMIID FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    MI YS_YH_SBINFO%ROWTYPE;
    CI YS_YH_CUSTINFO%ROWTYPE;
    P  YS_ZW_PAIDMENT%ROWTYPE;
  BEGIN
    IF NOT ����Ԥ�淢�� THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��ǰϵͳ����Ϊ��֧��Ԥ�淢��');
    END IF;
    --1��У�鼰���ʼ��
    BEGIN
      --ȡˮ����Ϣ
      OPEN C_MI(P_SBID);
      FETCH C_MI
        INTO MI;
      IF C_MI%NOTFOUND OR C_MI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '���Ǵ���ˮ����룿' || P_SBID);
      END IF;
      --ȡ�û���Ϣ
      OPEN C_CI(MI.YHID);
      FETCH C_CI
        INTO CI;
      IF C_CI%NOTFOUND OR C_CI%NOTFOUND IS NULL THEN
        RAISE_APPLICATION_ERROR(ERRCODE,
                                '���ˮ�����û��Ӧ�û���' || P_SBID);
      END IF;
    END;
  
    --2����¼ʵ��
    BEGIN
      SELECT TRIM(TO_CHAR(SEQ_PAIDMENT.NEXTVAL, '0000000000'))
        INTO O_PID
        FROM DUAL;
      SELECT SYS_GUID() INTO P.ID FROM DUAL;
      P.HIRE_CODE    := MI.HIRE_CODE;
      P.PID          := O_PID;
      P.YHID         := CI.YHID;
      P.SBID         := MI.SBID;
      P.PDRCRECEIVED := P_PAYMENT;
      P.PDDATE       := TRUNC(SYSDATE);
      P.PDATETIME    := SYSDATE;
      P.PDMONTH      := FOBTMANAPARA(MI.MANAGE_NO, 'READ_MONTH');
      P.MANAGE_NO    := P_POSITION;
      P.PDPAYPOINT   := P_PAYPOINT;
      P.PDTRAN       := P_TRANS;
      P.PDPERS       := P_OPER;
      P.PDPAYEE      := P_OPER;
      P.PDPAYWAY     := P_PAYWAY;
      P.PAIDMENT     := P_PAYMENT;
      P.PDSPJE       := 0;
      P.PDWYJ        := 0;
      P.PDSAVINGQC   := NVL(MI.SBSAVING, 0);
      P.PDSAVINGBQ   := P_PAYMENT;
      P.PDSAVINGQM   := P.PDSAVINGQC + P.PDSAVINGBQ;
      P.PDSXF        := 0; --��Ϊ����Ѻ��;
      P.PREVERSEFLAG := 'N'; --����״̬����ˮ����Ԥ����ΪN,��ˮ�ѳ�Ԥ�汻��ʵ�պͳ�ʵ�ղ���������ΪY��
      P.PDBDATE      := TRUNC(P_BDATE);
      P.PDBSEQNO     := P_BSEQNO;
      P.PDCHKDATE    := NULL;
      P.PDCCHKFLAG   := NULL;
      P.PDCDATE      := NULL;
      P.PDCSEQNO     := NULL;
      P.PDMEMO       := P_MEMO;
      IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO P.PDBATCH
          FROM DUAL;
      ELSE
        P.PDBATCH := P_BATCH;
      END IF;
      P.PDSEQNO    := P_SEQNO;
      P.PDSCRID    := P.PID;
      P.PDSCRTRANS := P.PDTRAN;
      P.PDSCRMONTH := P.PDMONTH;
      P.PDSCRDATE  := P.PDDATE;
    END;
    P.PDCHKNO     := NULL; --varchar2(10)  y    ���˵���
    P.PDPRIID     := MI.SBPRIID; --varchar2(20)  y    ���������  20150105
    P.TCHKDATE    := NULL; --date  y    ��������
    O_REMAINAFTER := P.PDSAVINGQM;
  
    --У��
    IF NOT ��������Ԥ�� AND P.PDSAVINGQM < 0 AND P.PDSAVINGQM < P.PDSAVINGQC THEN
      RAISE_APPLICATION_ERROR(ERRCODE,
                              '��ǰϵͳ����Ϊ��֧�ַ����������ĩ��Ԥ��');
    END IF;
    INSERT INTO YS_ZW_PAIDMENT VALUES P;
    UPDATE YS_YH_SBINFO SET SBSAVING = P.PDSAVINGQM WHERE CURRENT OF C_MI;
  
    --5���ύ����
    BEGIN
      CLOSE C_CI;
      CLOSE C_MI;
      IF P_COMMIT = ���� THEN
        ROLLBACK;
      ELSE
        IF P_COMMIT = �ύ THEN
          COMMIT;
        ELSIF P_COMMIT = ���ύ THEN
          NULL;
        ELSE
          RAISE_APPLICATION_ERROR(ERRCODE, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF C_CI%ISOPEN THEN
        CLOSE C_CI;
      END IF;
      IF C_MI%ISOPEN THEN
        CLOSE C_MI;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END;
  --
  FUNCTION FMID(P_STR IN VARCHAR2, P_SEP IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    I INTEGER;
    N INTEGER := 1;
  BEGIN
    IF TRIM(P_STR) IS NULL THEN
      RETURN 0;
    ELSE
      FOR I IN 1 .. LENGTH(P_STR) LOOP
        IF SUBSTR(P_STR, I, 1) = P_SEP THEN
          N := N + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN N;
  END;
  
   --1��ʵ�ճ��������¸�ʵ�գ�
  PROCEDURE Payreversecorebypid(p_Pid_Source       IN VARCHAR2,
                                p_Position         IN VARCHAR2,
                                p_Paypoint         IN VARCHAR2,
                                p_Ptrans           IN VARCHAR2,
                                p_Bdate            IN DATE,
                                p_Bseqno           IN VARCHAR2,
                                p_Oper             IN VARCHAR2,
                                p_Payway           IN VARCHAR2,
                                p_Memo             IN VARCHAR2,
                                p_Commit           IN NUMBER,
                                p_Ctl_Msg          IN NUMBER,
                                o_Pid_Reverse      OUT VARCHAR2,
                                o_Ppayment_Reverse OUT NUMBER) IS
    CURSOR c_p(Vpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vpid FOR UPDATE NOWAIT;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    Mi        Ys_Yh_Sbinfo%ROWTYPE;
    p_Source  Ys_Zw_Paidment%ROWTYPE;
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_p(p_Pid_Source);
    FETCH c_p
      INTO p_Source;
    IF c_p%FOUND THEN
      OPEN c_Mi(p_Source.Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '��Ч���û����');
      END IF;
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid_Reverse
        FROM Dual;
      SELECT Sys_Guid() INTO p_Reverse.Id FROM Dual;
      p_Reverse.Hire_Code  := Mi.Hire_Code;
      p_Reverse.Pid        := p_Source.Pid;
      p_Reverse.Yhid       := p_Source.Yhid;
      p_Reverse.Sbid       := p_Source.Sbid;
      p_Reverse.Pddate     := Trunc(SYSDATE);
      p_Reverse.Pdatetime  := SYSDATE;
      p_Reverse.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    �ɷ��·�
      p_Reverse.Manage_No  := p_Position;
      p_Reverse.Pdtran     := p_Ptrans;
      p_Reverse.Pdpers     := p_Oper;
      p_Reverse.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    �ڳ�Ԥ�����
      p_Reverse.Pdsavingbq := -p_Source.Pdsavingbq;
      p_Reverse.Pdsavingqm := p_Reverse.Pdsavingqc + p_Reverse.Pdsavingbq; --number(12,2)  y    ��ĩԤ�����;
      p_Reverse.Paidment   := -p_Source.Paidment;
      /* --���Ĳ���У��
      if not ����Ԥ�淢�� and p_reverse.psavingbq != 0 then
        raise_application_error(errcode, '��ǰϵͳ����Ϊ��֧��Ԥ�淢��');
      end if;
      if not ��������Ԥ�� and p_reverse.pdsavingqm < 0 and
         p_reverse.pdsavingqm < p_reverse.pdsavingqc then
        raise_application_error(errcode,
                                '��ǰϵͳ����Ϊ��֧�ַ����������ĩ��Ԥ��');
      end if;*/
      UPDATE Ys_Yh_Sbinfo
         SET Sbsaving = p_Reverse.Pdsavingqm
       WHERE CURRENT OF c_Mi;
    
      p_Reverse.Pdifsaving := NULL;
      p_Reverse.Pdchange   := NULL;
      p_Reverse.Pdpayway   := p_Payway;
      p_Reverse.Pdbseqno   := p_Source.Pdbseqno;
      p_Reverse.Pdcseqno   := p_Source.Pdcseqno;
      p_Reverse.Pdbdate    := p_Source.Pdbdate;
      p_Reverse.Pdchkdate  := p_Source.Pdchkdate;
      p_Reverse.Pdcchkflag := p_Source.Pdcchkflag;
      p_Reverse.Pdcdate    := p_Source.Pdcdate;
      /*IF P_BATCH IS NULL THEN
        SELECT TRIM(TO_CHAR(SEQ_PAIDBATCH.NEXTVAL, '0000000000'))
          INTO p_reverse.PDBATCH
          FROM DUAL;
      ELSE
        p_reverse.PDBATCH := P_BATCH;
      END IF;*/
      p_Reverse.Pdbatch      := p_Source.Pdbatch;
      p_Reverse.Pdseqno      := p_Source.Pdseqno;
      p_Reverse.Pdpayee      := p_Source.Pdpayee;
      p_Reverse.Pdchbatch    := p_Source.Pdchbatch;
      p_Reverse.Pdmemo       := p_Source.Pdmemo;
      p_Reverse.Pdpaypoint   := p_Source.Pdpaypoint;
      p_Reverse.Pdsxf        := -p_Source.Pdsxf;
      p_Reverse.Pdilid       := p_Source.Pdilid;
      p_Reverse.Pdflag       := p_Source.Pdflag;
      p_Reverse.Pdwyj        := -p_Source.Pdwyj;
      p_Reverse.Pdrcreceived := -p_Source.Pdrcreceived;
      p_Reverse.Pdspje       := p_Source.Pdspje;
      p_Reverse.Preverseflag := 'Y';
      IF p_Pid_Source IS NULL THEN
        p_Reverse.Pdscrid    := p_Source.Pid;
        p_Reverse.Pdscrtrans := p_Source.Pdtran;
        p_Reverse.Pdscrmonth := p_Source.Pdmonth;
        p_Reverse.Pdscrdate  := p_Source.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p_Reverse.Pdscrid,
               p_Reverse.Pdscrtrans,
               p_Reverse.Pdscrmonth,
               p_Reverse.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
    
      p_Reverse.Pdchkno  := p_Source.Pdchkno;
      p_Reverse.Pdpriid  := p_Source.Pdpriid;
      p_Reverse.Tchkdate := p_Source.Tchkdate;
      p_Reverse.Pdtax    := p_Source.Pdtax;
      p_Reverse.Pdzdate  := p_Source.Pdzdate;
    
    ELSE
      Raise_Application_Error(Errcode, '��Ч��ʵ����ˮ��');
    END IF;
    o_Ppayment_Reverse := p_Reverse.Paidment;
  
    --------------------------------------------------------------------------
    --2���ύ����
    BEGIN
      CLOSE c_Mi;
      CLOSE c_p;
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p_Reverse;
        UPDATE Ys_Zw_Paidment
           SET Preverseflag = 'Y'
         WHERE Pid = p_Pid_Source;
        IF p_Commit = �ύ THEN
          COMMIT;
        ELSIF p_Commit = ���ύ THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      IF c_p%ISOPEN THEN
        CLOSE c_p;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreversecorebypid;

  /*==========================================================================
  Ӧ��׷�ʺ���
  ���������˵������
  p_rlmid  varchar2(20)  ���ǿգ�ˮ����
  p_rlcname in varchar2 ��Ϊ��ʱreclist.rlcnameȡʵʱci.ciname���ǿ�ʱȥ����ֵ��Ӫҵ���շ�ҵ����ָ��Ʊ�����ƣ�
  p_rlpfid  varchar2(10)  ���ǿգ��۸������
  p_rlrmonth  varchar2(7)  ���ǿգ������·�
  p_rlrdate  date  ���ǿգ���������
  p_rlscode  number(10)  ���ǿգ��ϴγ������
  p_rlecode  number(10)  ���ǿգ����γ������
  p_rlsl  number(10)  ���ǿգ�Ӧ��ˮ��
  p_rlje  number(13,2)  ���ǿգ�Ӧ�ս��
  p_rltrans in varchar2 ���ǿգ�Ӧ��������𣩣�reclist.rllb
  p_rlmemo  varchar2(100)  ���ɿգ���ע��Ϣ
  p_rlid_source in number ���ɿգ���ԭӦ����
  p_parm_append1rds parm_append1rd_tab ���ǿգ�Ӧ������ϸ��
  p_ctl_mircode ���ǿ�ʱ�Դ�ֵ����meterinfo.mircode(��������������)��Ϊ��ʱ�����д˴���
  ���������˵������
  o_rlid out number������׷����Ӧ�ռ�¼��ˮ��
  ������˵������
  ���ݲ���׷��һ��Ӧ�����˺͹���Ӧ����ϸ������׷��ΪǷ�ѣ���
  �ṩӦ�յ�����׷�ӵ���Ŀ���ʡ�׷����Ӫҵ�⡢������׷�����˷���׷����ҵ����̵���
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  PROCEDURE Recappendcore(p_Rlmid           IN VARCHAR2,
                          p_Rlcname         IN VARCHAR2,
                          p_Rlpfid          IN VARCHAR2,
                          p_Rlrdate         IN DATE,
                          p_Rlscode         IN NUMBER,
                          p_Rlecode         IN NUMBER,
                          p_Rlsl            IN NUMBER,
                          p_Rlje            IN NUMBER,
                          p_Rlznjreducflag  IN VARCHAR2,
                          p_Rlzndate        IN DATE,
                          p_Rlznj           IN NUMBER,
                          p_Rltrans         IN VARCHAR2,
                          p_Rlmemo          IN VARCHAR2,
                          p_Rlid_Source     IN VARCHAR2,
                          p_Parm_Append1rds Parm_Append1rd_Tab,
                          p_Ctl_Mircode     IN VARCHAR2,
                          p_Commit          IN NUMBER DEFAULT ���ύ,
                          o_Rlid            OUT VARCHAR2) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid;
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid;
    CURSOR c_Md(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmiid;
    CURSOR c_Ma(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmiid;
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Md Ys_Yh_Sbdoc%ROWTYPE;
    Ma Ys_Yh_Account%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    Bf Ys_Bas_Book%ROWTYPE;
    CURSOR c_Rlsource(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid;
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rl_Append Ys_Zw_Arlist%ROWTYPE;
    Rd_Append Ys_Zw_Ardetail%ROWTYPE;
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    Rdtab_Append Rd_Table;
  
    Vappend1rd Parm_Append1rd;
  BEGIN
    --ȡˮ����Ϣ
    OPEN c_Mi(p_Rlmid);
    FETCH c_Mi
      INTO Mi;
    IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '���Ǵ���ˮ����룿' || p_Rlmid);
    END IF;
    BEGIN
      SELECT * INTO Bf FROM Ys_Bas_Book WHERE Book_No = Mi.Book_No;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
    --
    OPEN c_Md(p_Rlmid);
    FETCH c_Md
      INTO Md;
    IF c_Md%NOTFOUND OR c_Md%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '���Ǵ���ˮ����룿' || p_Rlmid);
    END IF;
    --
    OPEN c_Ma(p_Rlmid);
    FETCH c_Ma
      INTO Ma;
    IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
      NULL;
    END IF;
    --ȡ�û���Ϣ
    OPEN c_Ci(Mi.Yhid);
    FETCH c_Ci
      INTO Ci;
    IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode,
                              '���ˮ�����û��Ӧ�û���' || p_Rlmid);
    END IF;
    --��֯׷��Ӧ�����˺���ϸ�б���
    IF p_Rlid_Source IS NOT NULL THEN
      OPEN c_Rlsource(p_Rlid_Source);
      FETCH c_Rlsource
        INTO Rl_Source;
      IF c_Rlsource%NOTFOUND THEN
        Raise_Application_Error(Errcode,
                                '����Ϊ�յ�ԭӦ������ˮ�ŷǿյ���Ч');
      END IF;
      CLOSE c_Rlsource;
    END IF;
    SELECT TRIM(Lpad(Seq_Arid.Nextval, 10, '0')) INTO o_Rlid FROM Dual;
    SELECT Uuid() INTO Rl_Append.Id FROM Dual;
  
    Rl_Append.Hire_Code   := f_Get_Hire_Code();
    Rl_Append.Manage_No   := Mi.Manage_No;
    Rl_Append.Arid        := o_Rlid;
    Rl_Append.Armonth     := Fobtmanapara(Rl_Source.Manage_No, 'READ_MONTH');
    Rl_Append.Ardate      := p_Rlrdate; --Trunc(SYSDATE);
    Rl_Append.Yhid        := Mi.Yhid;
    Rl_Append.Sbid        := Mi.Sbid;
    Rl_Append.Archargeper := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Archargeper
                               ELSE
                                Bf.Read_Per
                             END);
  
    Rl_Append.Arcpid        := Ci.Yhpid;
    Rl_Append.Arcclass      := Ci.Yhclass;
    Rl_Append.Arcflag       := Ci.Yhflag;
    Rl_Append.Arusenum      := Mi.Sbusenum;
    Rl_Append.Arcname       := Ci.Yhname;
    Rl_Append.Arcadr        := Ci.Yhadr;
    Rl_Append.Armadr        := Mi.Sbadr;
    Rl_Append.Arcstatus     := Ci.Yhstatus;
    Rl_Append.Armtel        := Ci.Yhmtel;
    Rl_Append.Artel         := Ci.Yhtel1;
    Rl_Append.Arbankid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arbankid
                            ELSE
                             Ma.Yhabankid
                          END);
    Rl_Append.Artsbankid := (CASE
                              WHEN Rl_Source.Arid IS NOT NULL THEN
                               Rl_Source.Artsbankid
                              ELSE
                               Ma.Yhatsbankid
                            END);
    Rl_Append.Araccountno := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Araccountno
                               ELSE
                                Ma.Yhaaccountno
                             END);
    Rl_Append.Araccountname := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Araccountname
                                 ELSE
                                  Ma.Yhaaccountname
                               END);
    Rl_Append.Ariftax := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Ariftax
                           ELSE
                            Mi.Sbiftax
                         END);
    Rl_Append.Artaxno := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Artaxno
                           ELSE
                            Mi.Sbtaxno
                         END);
    Rl_Append.Arifinv := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arifinv
                           ELSE
                            Ci.Yhifinv
                         END); --��Ʊ��־ 
    Rl_Append.Armcode       := Mi.Sbcode;
    Rl_Append.Armpid        := Mi.Sbpid;
    Rl_Append.Armclass      := Mi.Sbclass;
    Rl_Append.Armflag       := Mi.Sbflag;
    Rl_Append.Arday := (CASE
                         WHEN Rl_Source.Arid IS NOT NULL THEN
                          Rl_Source.Arday
                         ELSE
                          Trunc(SYSDATE)
                       END);
    Rl_Append.Arbfid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arbfid
                          ELSE
                           Mi.Book_No
                        END);
    Rl_Append.Arprdate := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Arprdate
                            ELSE
                             Trunc(SYSDATE)
                          END);
    Rl_Append.Arrdate := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arrdate
                           ELSE
                            Trunc(SYSDATE)
                         END);
    Rl_Append.Arzndate      := Rl_Append.Ardate + 30;
    Rl_Append.Arcaliber     := Md.Mdcaliber;
    Rl_Append.Arrtid        := Mi.Sbrtid;
    Rl_Append.Armstatus     := Mi.Sbstatus;
    Rl_Append.Armtype       := Mi.Sbtype;
    Rl_Append.Armno         := Md.Mdno;
    Rl_Append.Arscode       := p_Rlscode; --NUMBER(10)  Y    ���� 
    Rl_Append.Arecode       := p_Rlecode; --NUMBER(10)  Y    ֹ�� 
    Rl_Append.Arreadsl      := p_Rlsl; --NUMBER(10)  Y    ����ˮ�� 
  
    Rl_Append.Arinvmemo       := Rl_Source.Arinvmemo;
    Rl_Append.Arentrustbatch  := Rl_Source.Arentrustbatch;
    Rl_Append.Arentrustseqno  := Rl_Source.Arentrustseqno;
    Rl_Append.Aroutflag := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Aroutflag
                             ELSE
                              'N'
                           END);
    Rl_Append.Artrans         := p_Rltrans;
    Rl_Append.Arcd            := 'DE';
    Rl_Append.Aryschargetype := (CASE
                                  WHEN Rl_Source.Arid IS NOT NULL THEN
                                   Rl_Source.Aryschargetype
                                  ELSE
                                   Mi.Sbchargetype
                                END);
    Rl_Append.Arsl            := 0;
    Rl_Append.Arje            := 0;
    Rl_Append.Araddsl         := Rl_Source.Araddsl;
    Rl_Append.Arscrarid := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arscrarid
                             ELSE
                              Rl_Append.Arid
                           END);
    Rl_Append.Arscrartrans := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrartrans
                                ELSE
                                 Rl_Append.Artrans
                              END);
    Rl_Append.Arscrarmonth := (CASE
                                WHEN Rl_Source.Arid IS NOT NULL THEN
                                 Rl_Source.Arscrarmonth
                                ELSE
                                 Rl_Append.Armonth
                              END);
    Rl_Append.Arpaidje        := Rl_Source.Arpaidje;
    Rl_Append.Arpaidflag      := Rl_Source.Arpaidflag;
    Rl_Append.Arpaidper       := Rl_Source.Arpaidper;
    Rl_Append.Arpaiddate      := Rl_Source.Arpaiddate;
    Rl_Append.Armrid          := Rl_Source.Armrid;
    Rl_Append.Armemo          := Nvl(p_Rlmemo, Rl_Source.Armemo);
    Rl_Append.Arznj           := Rl_Source.Arznj;
    Rl_Append.Arlb            := Rl_Source.Arlb;
    Rl_Append.Arcname2        := Rl_Source.Arcname2;
    Rl_Append.Arpfid          := p_Rlpfid; --VARCHAR2(10)  Y    ���۸����
    Rl_Append.Ardatetime      := SYSDATE;
    Rl_Append.Arscrardate := (CASE
                               WHEN Rl_Source.Arid IS NOT NULL THEN
                                Rl_Source.Arscrardate
                               ELSE
                                Rl_Append.Ardate
                             END);
    Rl_Append.Arprimcode      := Rl_Source.Arprimcode;
    Rl_Append.Arpriflag       := Rl_Source.Arpriflag;
    Rl_Append.Arrper          := Rl_Source.Arrper;
    Rl_Append.Arsafid         := Rl_Source.Arsafid;
    Rl_Append.Arscodechar     := Rl_Source.Arscodechar;
    Rl_Append.Arecodechar     := Rl_Source.Arecodechar;
    Rl_Append.Arilid          := Rl_Source.Arilid;
    Rl_Append.Armiuiid        := Rl_Source.Armiuiid;
    Rl_Append.Argroup         := Rl_Source.Argroup;
    Rl_Append.Arpid           := Rl_Source.Arpid;
    Rl_Append.Arpbatch        := Rl_Source.Arpbatch;
    Rl_Append.Arsavingqc      := Rl_Source.Arsavingqc;
    Rl_Append.Arsavingbq      := Rl_Source.Arsavingbq;
    Rl_Append.Arsavingqm      := Rl_Source.Arsavingqm;
    Rl_Append.Arreverseflag   := Rl_Source.Arreverseflag;
    Rl_Append.Arbadflag       := Rl_Source.Arbadflag;
    Rl_Append.Arznjreducflag  := Rl_Source.Arznjreducflag;
    Rl_Append.Armistid        := Rl_Source.Armistid;
    Rl_Append.Arminame        := Rl_Source.Arminame;
    Rl_Append.Arsxf           := Rl_Source.Arsxf;
    Rl_Append.Armiface2       := Rl_Source.Armiface2;
    Rl_Append.Armiface3       := Rl_Source.Armiface3;
    Rl_Append.Armiface4       := Rl_Source.Armiface4;
    Rl_Append.Armiifckf       := Rl_Source.Armiifckf;
    Rl_Append.Armigps         := Rl_Source.Armigps;
    Rl_Append.Armiqfh         := Rl_Source.Armiqfh;
    Rl_Append.Armibox         := Rl_Source.Armibox;
    Rl_Append.Arminame2       := Rl_Source.Arminame2;
    Rl_Append.Armiseqno       := Rl_Source.Armiseqno;
    Rl_Append.Armisaving      := Rl_Source.Armisaving;
    Rl_Append.Arpriorje       := Rl_Source.Arpriorje;
    Rl_Append.Armicommunity   := Rl_Source.Armicommunity;
    Rl_Append.Armiremoteno    := Rl_Source.Armiremoteno;
    Rl_Append.Armiremotehubno := Rl_Source.Armiremotehubno;
    Rl_Append.Armiemail       := Rl_Source.Armiemail;
    Rl_Append.Armiemailflag   := Rl_Source.Armiemailflag;
    Rl_Append.Armicolumn1     := Rl_Source.Armicolumn1;
    Rl_Append.Armicolumn2     := Rl_Source.Armicolumn2;
    Rl_Append.Armicolumn3     := Rl_Source.Armicolumn3;
    Rl_Append.Armicolumn4     := Rl_Source.Armicolumn4;
    Rl_Append.Arpaidmonth     := Rl_Source.Arpaidmonth;
    Rl_Append.Arcolumn5       := Rl_Source.Arcolumn5;
    Rl_Append.Arcolumn9       := Rl_Source.Arcolumn9;
    Rl_Append.Arcolumn10      := Rl_Source.Arcolumn10;
    Rl_Append.Arcolumn11      := Rl_Source.Arcolumn11;
    Rl_Append.Arjtmk          := Rl_Source.Arjtmk;
    Rl_Append.Arjtsrq         := Rl_Source.Arjtsrq;
    Rl_Append.Arcolumn12      := Rl_Source.Arcolumn12;
  
    Rl_Append.Arprimcode  := Mi.Sbpriid; --VARCHAR2(200)  Y    ���ձ������
    Rl_Append.Arpriflag   := Mi.Sbpriflag; --CHAR(1)  Y    ���ձ��־
    Rl_Append.Arrper := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arrper
                          ELSE
                           Bf.Read_Per
                        END); --VARCHAR2(10)  Y    ����Ա
    Rl_Append.Arsafid := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Arsafid
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    ����
    Rl_Append.Arscodechar := To_Char(p_Rlscode); --VARCHAR2(10)  Y    ���ڳ�������λ��
    Rl_Append.Arecodechar := To_Char(p_Rlecode); --VARCHAR2(10)  Y    ���ڳ�������λ��
    Rl_Append.Arilid := (CASE
                          WHEN Rl_Source.Arid IS NOT NULL THEN
                           Rl_Source.Arilid
                          ELSE
                           NULL
                        END); --VARCHAR2(40)  Y    ��Ʊ��ӡ����
    Rl_Append.Armiuiid    := Mi.Sbuiid; --VARCHAR2(10)  Y    ���յ�λ���
    Rl_Append.Argroup := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Argroup
                           ELSE
                            NULL
                         END); --NUMBER(2)  Y    Ӧ���ʷ���
    /**/
    Rl_Append.Arznj := p_Rlznj; --NUMBER(13,3)  Y    ΥԼ��
    /**/
    Rl_Append.Arzndate := p_Rlzndate; --DATE  Y    ΥԼ��������
    /**/
    Rl_Append.Arznjreducflag := p_Rlznjreducflag; --VARCHAR2(1)  Y    ���ɽ�����־,δ����ʱΪN������ʱ���ɽ�ֱ�Ӽ��㣻�����ΪY,����ʱ���ɽ�ֱ��ȡrlznj
    Rl_Append.Armistid := (CASE
                            WHEN Rl_Source.Arid IS NOT NULL THEN
                             Rl_Source.Armistid
                            ELSE
                             NULL
                          END); --VARCHAR2(10)  Y    ��ҵ����
    /**/
    Rl_Append.Arminame      := Nvl(p_Rlcname, Mi.Sbname); --VARCHAR2(64)  Y    Ʊ������
    Rl_Append.Arsxf         := 0; --NUMBER(12,2)  Y    ������
    Rl_Append.Armiface2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface2
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    ��������
    Rl_Append.Armiface3 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface3
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    �ǳ�����
    Rl_Append.Armiface4 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiface4
                             ELSE
                              NULL
                           END); --VARCHAR2(2)  Y    ����ʩ˵��
    Rl_Append.Armiifckf := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiifckf
                             ELSE
                              NULL
                           END); --CHAR(1)  Y    �����ѻ���
    Rl_Append.Armigps := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armigps
                           ELSE
                            NULL
                         END); --VARCHAR2(60)  Y    �Ƿ��Ʊ
    Rl_Append.Armiqfh := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armiqfh
                           ELSE
                            NULL
                         END); --VARCHAR2(20)  Y    Ǧ���
    Rl_Append.Armibox := (CASE
                           WHEN Rl_Source.Arid IS NOT NULL THEN
                            Rl_Source.Armibox
                           ELSE
                            NULL
                         END); --VARCHAR2(10)  Y    ����ˮ�ۣ���ֵ˰ˮ�ۣ���������
    Rl_Append.Arminame2 := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Arminame2
                             ELSE
                              NULL
                           END); --VARCHAR2(64)  Y    ��������(С��������������
    Rl_Append.Armiseqno := (CASE
                             WHEN Rl_Source.Arid IS NOT NULL THEN
                              Rl_Source.Armiseqno
                             ELSE
                              NULL
                           END); --VARCHAR2(50)  Y    ���ţ���ʼ��ʱ���+��ţ�
    Rl_Append.Arsavingqc    := Mi.Sbsaving; --NUMBER(13,3)  Y    ���ʱԤ��
    Rl_Append.Armicommunity := (CASE
                                 WHEN Rl_Source.Arid IS NOT NULL THEN
                                  Rl_Source.Armicommunity
                                 ELSE
                                  NULL
                               END); --VARCHAR2(10)  Y    С��
  
    --rl_append.ARbddsl         := 0; --NUMBER(10)  Y    ����ˮ��
    /**/
    Rl_Append.Arsl := p_Rlsl; --NUMBER(10)  Y    Ӧ��ˮ��
    /**/
    Rl_Append.Arje          := p_Rlje; --NUMBER(13,3)  Y    Ӧ�ս��
    Rl_Append.Arpaidje      := 0; --NUMBER(13,3)  Y    ���ʽ��
    Rl_Append.Arpaidflag    := 'N'; --CHAR(1)  Y    ���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
    Rl_Append.Arpaidper     := NULL; --VARCHAR2(20)  Y    ������Ա
    Rl_Append.Arpaiddate    := NULL; --DATE  Y    ��������
    Rl_Append.Arpaidmonth   := NULL; --VARCHAR2(7)  Y    �����·�
    Rl_Append.Arcolumn11    := NULL; --VARCHAR2(7)  Y    ʵ������
    Rl_Append.Arpid         := NULL; --VARCHAR2(10)  Y    ʵ����ˮ����payment.pid��Ӧ��
    Rl_Append.Arpbatch      := NULL; --VARCHAR2(10)  Y    �ɷѽ������Σ���payment.PBATCH��Ӧ��
    Rl_Append.Arsavingqc    := 0; --NUMBER(12,2)  Y    �ڳ�Ԥ�棨����ʱ������
    Rl_Append.Arsavingbq    := 0; --NUMBER(12,2)  Y    ����Ԥ�淢��������ʱ������
    Rl_Append.Arsavingqm    := 0; --NUMBER(12,2)  Y    ��ĩԤ�棨����ʱ������
    Rl_Append.Arreverseflag := 'N'; --VARCHAR2(1)  Y      ������־��NΪ������YΪ������
    Rl_Append.Arbadflag     := 'N'; --VARCHAR2(1)  Y    ���ʱ�־��Y :�����ʣ�O:�����������У�N:�����ʣ�
    BEGIN
      --NUMBER(13,3)  Y  ֮ǰǷ��
      SELECT Nvl(SUM(Nvl(Arje, 0) - Nvl(Arpaidje, 0)), 0)
        INTO Rl_Append.Arpriorje
        FROM Ys_Zw_Arlist
       WHERE Arreverseflag = 'Y'
         AND Arpaidflag = 'N'
         AND Arje > 0
         AND Sbid = Rl_Append.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        Rl_Append.Arpriorje := 0;
    END;
    IF p_Parm_Append1rds IS NOT NULL THEN
      FOR i IN p_Parm_Append1rds.First .. p_Parm_Append1rds.Last LOOP
        Vappend1rd := p_Parm_Append1rds(i);
        --
        Rd_Append.Id            := Uuid();
        Rd_Append.Hire_Code     := f_Get_Hire_Code();
        Rd_Append.Ardid         := o_Rlid; --VARCHAR2(10)      ��ˮ��
        Rd_Append.Ardpmdid      := Vappend1rd.Ardpmdid; --NUMBER      �����ˮ����
        Rd_Append.Ardpiid       := Vappend1rd.Ardpiid; --CHAR(2)      ������Ŀ
        Rd_Append.Ardpfid       := Nvl(Vappend1rd.Ardpfid, p_Rlpfid); --VARCHAR2(10)      ����
        Rd_Append.Ardpscid      := Vappend1rd.Ardpscid; --NUMBER      ������ϸ����
        Rd_Append.Ardclass      := Vappend1rd.Ardclass; --NUMBER      ���ݼ���
        Rd_Append.Ardysdj       := Vappend1rd.Arddj; --NUMBER(13,3)  Y    Ӧ�յ���
        Rd_Append.Ardyssl       := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    Ӧ��ˮ��
        Rd_Append.Ardysje       := Vappend1rd.Ardje; --NUMBER(13,3)  Y    Ӧ�ս��
        Rd_Append.Arddj         := Vappend1rd.Arddj; --NUMBER(13,3)  Y    ʵ�յ���
        Rd_Append.Ardsl         := Vappend1rd.Ardsl; --NUMBER(12,2)  Y    ʵ��ˮ��
        Rd_Append.Ardje         := Vappend1rd.Ardje; --NUMBER(13,3)  Y    ʵ�ս��
        Rd_Append.Ardadjdj      := 0; --NUMBER(13,3)  Y    ��������
        Rd_Append.Ardadjsl      := 0; --NUMBER(12,2)  Y    ����ˮ��
        Rd_Append.Ardadjje      := 0; --NUMBER(13,3)  Y    �������
        Rd_Append.Ardmethod     := NULL; --CHAR(3)  Y    �Ʒѷ���
        Rd_Append.Ardpaidflag   := NULL; --CHAR(1)  Y    ���ʱ�־
        Rd_Append.Ardpaiddate   := NULL; --DATE  Y    ��������
        Rd_Append.Ardpaidmonth  := NULL; --VARCHAR2(7)  Y    �����·�
        Rd_Append.Ardpaidper    := NULL; --VARCHAR2(20)  Y    ������Ա
        Rd_Append.Ardpmdscale   := NULL; --NUMBER(10,2)  Y    ��ϱ���
        Rd_Append.Ardilid       := Vappend1rd.Ardilid; --VARCHAR2(10)  Y    Ʊ����ˮ
        Rd_Append.Ardznj        := NULL; --NUMBER(12,2)  Y    ΥԼ��
        Rd_Append.Ardmemo       := p_Rlmemo; --VARCHAR2(200)  Y    ��ע
        Rd_Append.Ardmsmfid     := NULL; --VARCHAR2(10)  Y    Ӫ����˾
        Rd_Append.Ardmonth      := NULL; --VARCHAR2(7)  Y    �����·�
        Rd_Append.Ardmid        := NULL; --VARCHAR2(10)  Y    ˮ����
        Rd_Append.Ardpmdtype    := NULL; --VARCHAR2(2)  Y    ������
        Rd_Append.Ardpmdcolumn1 := NULL; --VARCHAR2(10)  Y    �����ֶ�1
        Rd_Append.Ardpmdcolumn2 := NULL; --VARCHAR2(10)  Y    �����ֶ�2
        Rd_Append.Ardpmdcolumn3 := NULL; --VARCHAR2(10)  Y    �����ֶ�3
      
        --���Ƶ�rdTab_append
        IF Rdtab_Append IS NULL THEN
          Rdtab_Append := Rd_Table(Rd_Append);
        ELSE
          Rdtab_Append.Extend;
          Rdtab_Append(Rdtab_Append.Last) := Rd_Append;
        END IF;
      END LOOP;
    END IF;
  
    --�������Ƹ�ֵ
    IF p_Ctl_Mircode IS NOT NULL THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = To_Number(p_Ctl_Mircode),
             Sbrcodechar = p_Ctl_Mircode
       WHERE Sbid = p_Rlmid;
    END IF;
  
    --2���ύ����
    BEGIN
      INSERT INTO Ys_Zw_Arlist VALUES Rl_Append;
      FOR k IN Rdtab_Append.First .. Rdtab_Append.Last LOOP
        INSERT INTO Ys_Zw_Ardetail VALUES Rdtab_Append (k);
      END LOOP;
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        IF p_Commit = �ύ THEN
          COMMIT;
        ELSIF p_Commit = ���ύ THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rlsource%ISOPEN THEN
        CLOSE c_Rlsource;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendcore;

  /*==========================================================================
  Ӧ��׷��
  ���������˵������
  p_rlid_source in number��ԴӦ����ˮ��
  p_rdpiids ��ָ������ԭӦ����������ö�ٷ��һλ�����ַ���������TOOLS.FGETPARA��ά����淶������'01|02|03|'��;
              Ӧ��������ȫ�����'ALL'��
              �˲���Ϊ�գ�׷����Ӧ����ϸ��Ȼ��Ӧ��������ȫ��Ӧ����ϸ��¼�����ɣ������Ѿ���0��
  p_memo in varchar2��������ע
  p_commit in number default ���ύ���Ƿ��ύ
  ���������˵������
  ������˵������
  ����ԭӦ�ռ�¼����׷��һ��Ӧ�գ�Ƿ��״̬����¼������Ӧ����ϸ����ָ��ö�ٵķ�����Ŀ����
  �ṩ����������Ԥ�������Ӧ�գ���ʵ�ճ������˷�ҵ������е���
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  PROCEDURE Recappendinherit(p_Rlid_Source IN VARCHAR2,
                             p_Rdpiids     IN VARCHAR2,
                             p_Rltrans     IN VARCHAR2,
                             p_Memo        IN VARCHAR2,
                             p_Commit      IN NUMBER DEFAULT ���ύ,
                             o_Rlid        OUT VARCHAR2,
                             o_Rlje        OUT NUMBER) IS
    CURSOR c_Rl(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Vrlid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Rd(Vrlid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Vrlid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    --ԭӦ��
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
  
    Vappend1rd  Parm_Append1rd;
    Vappend1rds Parm_Append1rd_Tab;
  BEGIN
    o_Rlje     := Nvl(o_Rlje, 0);
    Vappend1rd := Parm_Append1rd(NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL);
    OPEN c_Rl(p_Rlid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      OPEN c_Rd(p_Rlid_Source);
      FETCH c_Rd
        INTO Rd_Source;
      IF c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '��Ч��Ӧ����ˮ��' || p_Rlid_Source);
      END IF;
      WHILE c_Rd%FOUND LOOP
        ------------------------------------------------
        IF Instr(p_Rdpiids, Rd_Source.Ardpiid || '|') > 0 OR
           Upper(p_Rdpiids) = 'ALL' THEN
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := Rd_Source.Ardsl;
          Vappend1rd.Ardje     := Rd_Source.Ardje;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        ELSE
          Vappend1rd.Hire_Code := Rd_Source.Hire_Code;
          Vappend1rd.Ardpmdid  := Rd_Source.Ardpmdid;
          Vappend1rd.Ardpfid   := Rd_Source.Ardpfid;
          Vappend1rd.Ardpscid  := Rd_Source.Ardpscid;
          Vappend1rd.Ardpiid   := Rd_Source.Ardpiid;
          Vappend1rd.Ardclass  := Rd_Source.Ardclass;
          Vappend1rd.Arddj     := Rd_Source.Arddj;
          Vappend1rd.Ardsl     := 0;
          Vappend1rd.Ardje     := 0;
          Vappend1rd.Ardilid   := Rd_Source.Ardilid;
        END IF;
        --���Ƶ�vappend1rds
        IF Vappend1rds IS NULL THEN
          Vappend1rds := Parm_Append1rd_Tab(Vappend1rd);
        ELSE
          Vappend1rds.Extend;
          Vappend1rds(Vappend1rds.Last) := Vappend1rd;
        END IF;
        o_Rlje := o_Rlje + Vappend1rd.Ardje;
        ------------------------------------------------
        FETCH c_Rd
          INTO Rd_Source;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '��Ч��Ӧ����ˮ��');
    END IF;
  
    Recappendcore(Rl_Source.Sbid,
                  Rl_Source.Arminame,
                  Rl_Source.Arpfid,
                  Rl_Source.Arrdate,
                  Rl_Source.Arscode,
                  Rl_Source.Arecode,
                  Rl_Source.Arsl,
                  o_Rlje,
                  Rl_Source.Arznjreducflag,
                  Rl_Source.Arzndate,
                  Rl_Source.Arznj,
                  p_Rltrans, --rl_source.rltrans,
                  p_Memo,
                  Rl_Source.Arid,
                  Vappend1rds,
                  NULL, --����������
                  ���ύ,
                  o_Rlid);
  
    --2���ύ����
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        IF p_Commit = �ύ THEN
          COMMIT;
        ELSIF p_Commit = ���ύ THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Recappendinherit;

  /*==========================================================================
  ʵ�ճ����κ���
  ���������˵������
  p_pid_source  in number��������ʵ����ˮ�ţ�����Ԥ���ֵʵ�����ͣ��޹���Ӧ�����ʣ�
  p_position      in varchar2���������ɷѵ�λ
  p_paypoint    in varchar2���������ɷѵ�
  p_ptrans      in varchar2��������ʵ������
  p_bdate       in date�����г�������
  p_bseqno      in varchar2�����г�����ˮ
  p_oper        in varchar2����������Ա
  p_payway      in varchar2�����������ʽ
  p_memo        in varchar2��������ע
  p_commit      in number���Ƿ��ύ
  
  ���������˵������
  o_pid_reverse out number�����������ʣ���¼ʵ����ˮ��
  o_ppayment_reverse out number�����������ʣ���¼ʵ�ճ������
  ������˵������
  �ṩˮ˾��̨����������ʵʱ�˵������е����ʳ�������
  ����һ��ʵ�ռ�¼payment.pid����ʵ�ճ����Ĳ������Ҷ�ȫ������Ӧ�ս��������ʣ�
  ���˷ѱ��ʲ�ͬ����
  1��ͬʱ����Ԥ�淢����
  2��Ӧ�ճ��������Ӧ��׷�������˷��Ӳ����˷�����׷����׷����׷��
  ��������Ϊ��ʵ�ճ��������¸�ʵ�գ�-->Ӧ�ճ�����׷�ӵ���ȫ��ʣ�-->Ӧ��׷����׷�ӵ���ȫ�����ʣ�
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  PROCEDURE Payreverse(p_Pid_Source       IN VARCHAR2,
                       p_Position         IN VARCHAR2,
                       p_Paypoint         IN VARCHAR2,
                       p_Ptrans           IN VARCHAR2,
                       p_Bdate            IN DATE,
                       p_Bseqno           IN VARCHAR2,
                       p_Oper             IN VARCHAR2,
                       p_Payway           IN VARCHAR2,
                       p_Memo             IN VARCHAR2,
                       p_Commit           IN NUMBER,
                       o_Pid_Reverse      OUT VARCHAR2,
                       o_Ppayment_Reverse OUT NUMBER,
                       o_Append_Rlid      OUT VARCHAR2) IS
    o_Append_Rlje NUMBER;
    --
    o_Rlid_Reverse        VARCHAR2(10);
    o_Rltrans_Reverse     VARCHAR2(10);
    o_Rlje_Reverse        NUMBER;
    o_Rlznj_Reverse       NUMBER;
    o_Rlsxf_Reverse       NUMBER;
    o_Rlsavingbq_Reverse  NUMBER;
    Io_Rlsavingqm_Reverse NUMBER;
  BEGIN
    --ʵ�ճ��������¸�ʵ�գ�
    Payreversecorebypid(p_Pid_Source,
                        p_Position,
                        p_Paypoint,
                        p_Ptrans,
                        p_Bdate,
                        p_Bseqno,
                        p_Oper,
                        p_Payway,
                        p_Memo,
                        ���ύ,
                        'Y',
                        o_Pid_Reverse,
                        o_Ppayment_Reverse);
    FOR i IN (SELECT Arid, Arpaidje, Artrans
                FROM Ys_Zw_Arlist
               WHERE Arpid = p_Pid_Source
                 AND Arreverseflag = 'N'
               ORDER BY Arid) LOOP
      --Ӧ�ճ�����׷�ӵ���ȫ��ʣ�
      Zwarreversecore(i.Arid, -- P_ARID_SOURCE         IN VARCHAR2,
                      i.Artrans, --P_ARTRANS_REVERSE     IN VARCHAR2,
                      NULL, --    P_PBATCH_REVERSE      IN VARCHAR2,
                      o_Pid_Reverse, --     P_PID_REVERSE         IN VARCHAR2,
                      -i.Arpaidje, --    P_PPAYMENT_REVERSE    IN NUMBER,
                      p_Memo, --    P_MEMO                IN VARCHAR2,
                      NULL, --    P_CTL_MIRCODE         IN VARCHAR2,
                      ���ύ, --    P_COMMIT              IN NUMBER DEFAULT ���ύ,
                      o_Rlid_Reverse,
                      o_Rltrans_Reverse,
                      o_Rlje_Reverse,
                      o_Rlznj_Reverse,
                      o_Rlsxf_Reverse,
                      o_Rlsavingbq_Reverse,
                      Io_Rlsavingqm_Reverse); /* O_ARID_REVERSE        OUT VARCHAR2,
                                O_ARTRANS_REVERSE     OUT VARCHAR2,
                                O_ARJE_REVERSE        OUT NUMBER,
                                O_ARZNJ_REVERSE       OUT NUMBER,
                                O_ARSXF_REVERSE       OUT NUMBER,
                                O_ARSAVINGBQ_REVERSE  OUT NUMBER,
                                IO_ARSAVINGQM_REVERSE IN OUT NUMBER
                                */
      --Ӧ��׷����׷�ӵ���ȫ�����ʣ�
      Recappendinherit(i.Arid,
                       'ALL',
                       o_Rltrans_Reverse,
                       p_Memo,
                       ���ύ,
                       o_Append_Rlid,
                       o_Append_Rlje);
    END LOOP;
  
    --2���ύ����
    BEGIN
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        IF p_Commit = �ύ THEN
          COMMIT;
        ELSIF p_Commit = ���ύ THEN
          NULL;
        ELSE
          Raise_Application_Error(Errcode, '�Ƿ��ύ��������ȷ');
        END IF;
      END IF;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END Payreverse;
  
  /*==========================================================================
  ˮ˾��̨����(���˿�)�����Ƕ���ʵ������
  ���������˵������
  p_pid_source  in number��������ԭʵ����ˮ��
  p_oper        in varchar2����������Ա
  p_memo        in varchar2������������ע��Ϣ
  
  ���������˵������
  p_pid_reverse out number�������ɹ��󷵻صĳ�����¼����ʵ�ռ�¼����ˮ��
  
  ������˵������
  ��̨�ɷ�ҳ�漯�ɹ��ܣ����ջ���վ����������ڣ�����Ϊԭʵ�յ�λ��ԭʵ�սɷѵ㡢ԭʵ������ԭ���ʽ
  ֧�ֳ���Ԥ���ֵ����
  ����������˵�������ӹ���PayReverse��ʵ�ճ����κ��ġ�˵��
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  procedure PosReverse(p_pid_source  in varchar2,
                       p_oper        in varchar2,
                       p_memo        in varchar2,
                       p_commit      in number default ���ύ,
                       p_pid_reverse out varchar2) is
    p                  ys_zw_paidment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from ys_zw_paidment  where pid = p_pid_source;
    --У��
    if not (p.PREVERSEFLAG = 'N' and p.PAIDMENT >= 0) then
      raise_application_error(errcode,
                              '������ʵ�ռ�¼��Ч������Ϊδ�����������ɷ�');
    end if;
    PayReverse(p_pid_source,
               p.MANAGE_NO,
               p.PDPAYPOINT,
               p.PDTRAN,
               null,
               null,
               p_oper,
               p.PDPAYWAY,
               p_memo,
               ���ύ,
               p_pid_reverse,
               vppaymentreverse,
               vappendrlid);
  
    --2���ύ����
    begin
      if p_commit = ���� then
        rollback;
      else
        if p_commit = �ύ then
          commit;
        elsif p_commit = ���ύ then
          null;
        else
          raise_application_error(errcode, '�Ƿ��ύ��������ȷ');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, '�Ƿ��ύ��������ȷ' || p_pid_source); 
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse;

/*==========================================================================
  Ӧ��׷��
  ���������˵������
  p_rlmid  varchar2(20)  ���ǿգ�ˮ����
  p_rlcname in varchar2 ��Ϊ��ʱreclist.rlcnameȡʵʱci.ciname���ǿ�ʱȥ����ֵ��Ӫҵ���շ�ҵ����ָ��Ʊ�����ƣ�
  p_rlpfid  varchar2(10)  ���ǿգ��۸������
  p_rlrmonth  varchar2(7)  ���ǿգ������·�
  p_rlrdate  date  ���ǿգ���������
  p_rlscode  number(10)  ���ǿգ��ϴγ������
  p_rlecode  number(10)  ���ǿգ����γ������
  p_rlsl  number(10)  ���ǿգ�Ӧ��ˮ��
  p_rlje  number(13,2)  ���ǿգ�Ӧ�ս��
  p_rltrans in varchar2 ���ǿգ�Ӧ��������𣩣�reclist.rllb
  p_rlmemo  varchar2(100)  ���ɿգ���ע��Ϣ
  p_rlid_source in number ���ɿգ���ԭӦ����
  p_parm_append1rds parm_append1rd_tab ���ǿգ�Ӧ������ϸ��
  p_ctl_mircode ���ǿ�ʱ�Դ�ֵ����meterinfo.mircode(��������������)��Ϊ��ʱ�����д˴���
  ���������˵������
  o_rlid out number������׷����Ӧ�ռ�¼��ˮ��
  ������˵������
  ����Ӧ�յ���ҵ���еĵ���Ŀ����������+��ϸ��׷��һ��Ӧ�ռ�¼������Ӧ����ϸ
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  procedure RecAppendAdj(p_rlmid           in varchar2,
                         p_rlcname         in varchar2,
                         p_rlpfid          in varchar2,
                         p_rlrdate         in date,
                         p_rlscode         in number,
                         p_rlecode         in number,
                         p_rlsl            in number,
                         p_rlje            in number,
                         p_rlznj           in number,
                         p_rltrans         in varchar2,
                         p_rlmemo          in varchar2,
                         p_rlid_source     in varchar2,
                         p_parm_append1rds parm_append1rd_tab,
                         p_ctl_mircode     in varchar2,
                         p_commit          in number default ���ύ,
                         o_rlid            out varchar2) is
    cursor c_rl(vrlid varchar2) is
      select * from ys_zw_arlist  where arid = vrlid for update nowait; --������ֱ���׳��쳣
    rl_source ys_zw_arlist%rowtype;
  begin
    --�˷�����Ӧ������̳�ԭ����
    open c_rl(p_rlid_source);
    fetch c_rl
      into rl_source;
    if c_rl%notfound or c_rl%notfound is null then
      raise_application_error(errcode, '��ԭ����Ӧ�ռ�¼');
    end if;
    close c_rl;
  
    RecAppendCore(p_rlmid,
                  p_rlcname,
                  p_rlpfid,
                  p_rlrdate,
                  p_rlscode,
                  p_rlecode,
                  p_rlsl,
                  p_rlje,
                  rl_source.arznjreducflag,
                  rl_source.arzndate,
                  p_rlznj,
                  p_rltrans,
                  p_rlmemo,
                  p_rlid_source,
                  p_parm_append1rds,
                  p_ctl_mircode,
                  ���ύ,
                  o_rlid);
    --2���ύ����
    begin
      if p_commit = ���� then
        rollback;
      else
        if p_commit = �ύ then
          commit;
        elsif p_commit = ���ύ then
          null;
        else
          raise_application_error(errcode, '�Ƿ��ύ��������ȷ');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise_application_error(errcode, sqlerrm);
  end RecAppendAdj;
/*==========================================================================
  Ӧ�յ���
  ���������˵������
  p_rlmid  varchar2(20)  ���ǿգ�ˮ����
  p_rlcname in varchar2 ��Ϊ��ʱreclist.rlcnameȡʵʱci.ciname���ǿ�ʱȥ����ֵ��Ӫҵ���շ�ҵ����ָ��Ʊ�����ƣ�
  p_rlpfid  varchar2(10)  ���ǿգ��۸������
  p_rlrmonth  varchar2(7)  ���ǿգ������·�
  p_rlrdate  date  ���ǿգ���������
  p_rlscode  number(10)  ���ǿգ��ϴγ������
  p_rlecode  number(10)  ���ǿգ����γ������
  p_rlsl  number(10)  ���ǿգ�Ӧ��ˮ��
  p_rlje  number(13,2)  ���ǿգ�Ӧ�ս��
  p_rltrans in varchar2 ���ǿգ�Ӧ��������𣩣�reclist.rllb
  p_rlmemo  varchar2(100)  ���ɿգ���ע��Ϣ
  p_rlid_source in number ���ǿգ���ԭӦ����
  p_parm_append1rds parm_append1rd_tab ���ǿգ�Ӧ������ϸ��
  p_ctl_mircode ���ǿ�ʱ�Դ�ֵ����meterinfo.mircode(��������������)��Ϊ��ʱ�����д˴���
  ���������˵������
  o_rlid_reverse out varchar2��
  o_rlid out varchar2������׷����Ӧ�ռ�¼��ˮ��
  ������˵������
  ���ڵ��ݵ���Ӧ�ռ�����
  ��������Ϊ��Ӧ�ճ�����׷�ӵ���ȫ��ʣ�-->Ӧ��׷��
  ��������־����
  --   When         Who       What
  --   -----------  --------  -----------------------------------------------
  --   2014-02-14   jh        ����
  --
  */
  procedure RecAdjust(p_rlmid           in varchar2,
                      p_rlcname         in varchar2,
                      p_rlpfid          in varchar2,
                      p_rlrdate         in date,
                      p_rlscode         in number,
                      p_rlecode         in number,
                      p_rlsl            in number,
                      p_rlje            in number,
                      p_rlznj           in number,
                      p_rltrans         in varchar2,
                      p_rlmemo          in varchar2,
                      p_rlid_source     in varchar2,
                      p_parm_append1rds parm_append1rd_tab,
                      p_commit          in number default ���ύ,
                      p_ctl_mircode     in varchar2,
                      o_rlid_reverse    out varchar2,
                      o_rlid            out varchar2) is
    --
    o_rltrans_reverse     varchar2(10);
    o_rlje_reverse        number;
    o_rlznj_reverse       number;
    o_rlsxf_reverse       number;
    o_rlsavingbq_reverse  number;
    io_rlsavingqm_reverse number;
  begin
    Zwarreversecore(p_rlid_source,
                   p_rltrans,
                   null,
                   null, --Ӧ�յ����޹���ʵ�ռ�¼p_pid_reverse
                   null, --Ӧ�յ����޹���ʵ�ռ�¼
                   p_rlmemo,
                   null, --�˹��̲�����ֹ�룬��׷�����Ĵ���
                   p_commit,
                   o_rlid_reverse,
                   o_rltrans_reverse,
                   o_rlje_reverse,
                   o_rlznj_reverse,
                   o_rlsxf_reverse,
                   o_rlsavingbq_reverse,
                   io_rlsavingqm_reverse);
    if not (p_rlsl = 0 and p_rlje = 0 and p_rlznj = 0) then
      RecAppendAdj(p_rlmid,
                   p_rlcname,
                   p_rlpfid,
                   p_rlrdate,
                   p_rlscode,
                   p_rlecode,
                   p_rlsl,
                   p_rlje,
                   p_rlznj,
                   o_rltrans_reverse,
                   p_rlmemo,
                   p_rlid_source,
                   p_parm_append1rds,
                   p_ctl_mircode,
                   p_commit,
                   o_rlid);
    else
      --�������Ƹ�ֵ
      if p_ctl_mircode is not null then
        update ys_yh_sbinfo
           set sbrcode     = to_number(p_ctl_mircode),
               sbrcodechar = p_ctl_mircode
         where sbid = p_rlmid;
      end if;
    
    end if;
    --2���ύ����
    begin
      if p_commit = ���� then
        rollback;
      else
        if p_commit = �ύ then
          commit;
        elsif p_commit = ���ύ then
          null;
        else
          raise_application_error(errcode, '�Ƿ��ύ��������ȷ');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      /*pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'RecAdjust,p_rlmid:' || p_rlmid);*/
      --raise;
      raise_application_error(errcode, sqlerrm);
  end RecAdjust;
BEGIN
  NULL;

END;
/

