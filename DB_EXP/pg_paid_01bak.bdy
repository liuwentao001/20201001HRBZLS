CREATE OR REPLACE PACKAGE BODY Pg_Paid_01bak IS
  Curdatetime DATE;

  FUNCTION Obtwyj(p_Sdate IN DATE, p_Edate IN DATE, p_Je IN NUMBER)
    RETURN NUMBER IS
    v_Result NUMBER;
  BEGIN
    v_Result := p_Je * (Trunc(p_Edate) - Trunc(p_Sdate) + 1) * 0.003;
    v_Result := Pg_Cb_Cost.Getmax(v_Result, 0);
    RETURN v_Result;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  --ΥԼ�����
  FUNCTION Obtwyjadj(p_Arid     IN VARCHAR2, --Ӧ����ˮ
                     p_Ardpiids IN VARCHAR2, --Ӧ����ϸ���'01|02|03'
                     p_Edate    IN DATE --������'������'ΥԼ��,������ʽ'yyyy-mm-dd'
                     ) RETURN NUMBER IS
    Vresult          NUMBER;
    v_Arzndate       Ys_Zw_Arlist.Arzndate%TYPE;
    v_Arznj          Ys_Zw_Arlist.Arznj%TYPE;
    v_Outflag        Ys_Zw_Arlist.Aroutflag%TYPE;
    v_Sbid           Ys_Zw_Arlist.Sbid%TYPE;
    v_Arje           Ys_Zw_Arlist.Arje%TYPE;
    v_Yhifzn         Ys_Yh_Custinfo.Yhifzn%TYPE;
    v_Arznjreducflag Ys_Zw_Arlist.Arznjreducflag%TYPE;
    v_Chargetype     VARCHAR2(10);
  BEGIN
    BEGIN
      SELECT a.Sbid,
             MAX(Arzndate),
             MAX(Arznj),
             MAX(Aroutflag),
             SUM(Ardje),
             MAX(Yhifzn),
             MAX(Arznjreducflag),
             MAX(Nvl(Sbchargetype, 'X'))
        INTO v_Sbid,
             v_Arzndate,
             v_Arznj,
             v_Outflag,
             v_Arje,
             v_Yhifzn,
             v_Arznjreducflag,
             v_Chargetype
        FROM Ys_Zw_Arlist   a,
             Ys_Yh_Custinfo b,
             Ys_Zw_Ardetail c,
             Ys_Yh_Sbinfo   d
       WHERE a.Sbid = d.Sbid
         AND b.Yhid = d.Yhid
         AND a.Arid = c.Ardid
         AND Instr(p_Ardpiids, Ardpiid) > 0
         AND Arid = p_Arid
       GROUP BY Arid, a.Sbid;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE;
    END;
  
    --��ʱ����
    --return 0;
  
    IF v_Yhifzn = 'N' OR v_Chargetype IN ('D', 'T') THEN
      RETURN 0;
    END IF;
    IF v_Arje < 0 THEN
      v_Arje := 0;
    END IF;
    IF v_Arznjreducflag = 'Y' THEN
      RETURN v_Arznj;
    END IF;
  
    Vresult := Obtwyj(v_Arzndate, p_Edate, v_Arje);
    --���ó�������
    IF Vresult > v_Arje THEN
      Vresult := v_Arje;
    END IF;
  
    RETURN Trunc(Vresult, 2);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;
  /*==========================================================================
  ˮ˾��̨�ɷѣ�һ��,�����򻯰�
  '123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|123456789,Y*01!Y*02!Y*03!,0.10,0,0,0|'
  */
  PROCEDURE Poscustforys(p_Sbid     IN VARCHAR2,
                         p_Arstr    IN VARCHAR2,
                         p_Position IN VARCHAR2,
                         p_Oper     IN VARCHAR2,
                         p_Paypoint IN VARCHAR2,
                         p_Payway   IN VARCHAR2,
                         p_Payment  IN NUMBER,
                         p_Batch    IN VARCHAR2,
                         p_Pid      OUT VARCHAR2) IS
  
    v_Parm_Ar  Parm_Payar;
    v_Parm_Ars Parm_Payar_Tab;
  BEGIN
    v_Parm_Ar  := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars := Parm_Payar_Tab();
    FOR i IN 1 .. Fmid(p_Arstr, '|') - 1 LOOP
      v_Parm_Ar.Arid     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 1);
      v_Parm_Ar.Ardpiids := REPLACE(REPLACE(Pg_Cb_Cost.Fgetpara(p_Arstr,
                                                                i,
                                                                2),
                                            '*',
                                            ','),
                                    '!',
                                    '|');
      v_Parm_Ar.Arwyj    := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 3);
      v_Parm_Ar.Fee1     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 4);
      v_Parm_Ar.Fee2     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 5);
      v_Parm_Ar.Fee3     := Pg_Cb_Cost.Fgetpara(p_Arstr, i, 6);
      v_Parm_Ars.Extend;
      v_Parm_Ars(v_Parm_Ars.Last) := v_Parm_Ar;
    END LOOP;
  
    Poscust(p_Sbid,
            v_Parm_Ars,
            p_Position,
            p_Oper,
            p_Paypoint,
            p_Payway,
            p_Payment,
            p_Batch,
            p_Pid);
  EXCEPTION
    WHEN OTHERS THEN
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Poscust(p_Sbid     IN VARCHAR2,
                    p_Parm_Ars IN Parm_Payar_Tab,
                    p_Position IN VARCHAR2,
                    p_Oper     IN VARCHAR2,
                    p_Paypoint IN VARCHAR2,
                    p_Payway   IN VARCHAR2,
                    p_Payment  IN NUMBER,
                    p_Batch    IN VARCHAR2,
                    p_Pid      OUT VARCHAR2) IS
    Vbatch       VARCHAR2(10);
    Vseqno       VARCHAR2(10);
    v_Parm_Ars   Parm_Payar_Tab;
    Vremainafter NUMBER;
    v_Parm_Count NUMBER;
  BEGIN
    Vbatch     := p_Batch;
    v_Parm_Ars := p_Parm_Ars;
    --���Ĳ���У��
    FOR i IN (SELECT a.Aroutflag
                FROM Ys_Zw_Arlist a, TABLE(v_Parm_Ars) b
               WHERE a.Arid = b.Arid) LOOP
      IF �����ظ����� = 0 AND i.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '��ǰϵͳ�����������н���Ӧ�ճ���');
      END IF;
    END LOOP;
  
    SELECT COUNT(*) INTO v_Parm_Count FROM TABLE(v_Parm_Ars) b;
    IF v_Parm_Count = 0 THEN
      IF p_Payment > 0 THEN
        --����Ԥ�����
        Precust(p_Sbid        => p_Sbid,
                p_Position    => p_Position,
                p_Oper        => p_Oper,
                p_Payway      => p_Payway,
                p_Payment     => p_Payment,
                p_Memo        => NULL,
                p_Batch       => Vbatch,
                o_Pid         => p_Pid,
                o_Remainafter => Vremainafter);
      ELSE
        NULL;
        --��Ԥ�����
        Precustback(p_Sbid        => p_Sbid,
                    p_Position    => p_Position,
                    p_Oper        => p_Oper,
                    p_Payway      => p_Payway,
                    p_Payment     => p_Payment,
                    p_Memo        => NULL,
                    p_Batch       => Vbatch,
                    o_Pid         => p_Pid,
                    o_Remainafter => Vremainafter);
      END IF;
    ELSE
      Paycust(p_Sbid,
              v_Parm_Ars,
              Ptrans_��̨�ɷ�,
              p_Position,
              p_Paypoint,
              NULL,
              NULL,
              p_Oper,
              p_Payway,
              p_Payment,
              NULL,
              ���ύ,
              �ֲ�����֪ͨ,
              �������,
              Vbatch,
              Vseqno,
              p_Pid,
              Vremainafter);
    END IF;
  
    --�ύ����
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --PG_EWIDE_INTERFACE.ERRLOG(DBMS_UTILITY.FORMAT_CALL_STACK(), P_SBID);
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Paycust(p_Sbid        IN VARCHAR2,
                    p_Parm_Ars    IN Parm_Payar_Tab,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Pid_Source  IN VARCHAR2,
                    p_Commit      IN NUMBER,
                    p_Ctl_Msg     IN NUMBER,
                    p_Ctl_Pre     IN NUMBER,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    p_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ma(Vmamid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmamid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    Mi         Ys_Yh_Sbinfo%ROWTYPE;
    Ci         Ys_Yh_Custinfo%ROWTYPE;
    Ma         Ys_Yh_Account%ROWTYPE;
    p          Ys_Zw_Paidment%ROWTYPE;
    v_Parm_Ars Parm_Payar_Tab;
    p_Parm_Ar  Parm_Payar;
    v_Exists   NUMBER;
  BEGIN
    v_Parm_Ars := p_Parm_Ars;
    --1��ʵ��У�顢��Ҫ����׼��
    --------------------------------------------------------------------------
    BEGIN
      --ȡˮ����Ϣ
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                'ˮ����롾' || p_Sbid || '�������ڣ�');
      END IF;
      --ȡ�û���Ϣ
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '���ˮ�����û��Ӧ�û���' || p_Sbid);
      END IF;
      --ȡ�û������˻���Ϣ
      OPEN c_Ma(Mi.Sbid);
      FETCH c_Ma
        INTO Ma;
      IF c_Ma%NOTFOUND OR c_Ma%NOTFOUND IS NULL THEN
        NULL;
      END IF;
      --����У��
      /*if p_parm_rls is null then
        raise_application_error(errcode, '�����ʰ��ǿյ���ô�죿');
      end if;*/
      --��Ӻ���У��,���⻧����������б�һ��
      IF p_Parm_Ars.Count > 0 THEN
        --����Ϊ�գ�Ԥ���ֵʱ��
        FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
          p_Parm_Ar := p_Parm_Ars(i);
          SELECT COUNT(1)
            INTO v_Exists
            FROM Ys_Zw_Arlist a, Ys_Yh_Sbinfo b
           WHERE Arid = p_Parm_Ar.Arid
             AND a.Sbid = b.Sbid
             AND (b.Sbid = p_Sbid OR Sbpriid = p_Sbid);
          IF v_Exists = 0 THEN
            Raise_Application_Error(Errcode,
                                    '�������������ˢ��ҳ������²���!');
          END IF;
        END LOOP;
      END IF;
    
    END;
  
    --2����¼ʵ��
    --------------------------------------------------------------------------
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO p_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code  := Mi.Hire_Code;
      p.Pid        := p_Pid; --varchar2(10)      ��ˮ��
      p.Yhid       := Ci.Yhid; --varchar2(10)      �û����
      p.Sbid       := p_Sbid; --varchar2(10)  y    ˮ����
      p.Pddate     := Trunc(SYSDATE); --date  y    ��������
      p.Pdatetime  := SYSDATE; --date  y    ��������
      p.Pdmonth    := Fobtmanapara(Mi.Manage_No, 'READ_MONTH'); --varchar2(7)  y    �ɷ��·�
      p.Manage_No  := p_Position; --varchar2(10)  y    �ɷѻ���
      p.Pdtran     := p_Trans; --char(1)      �ɷ�����
      p.Pdpers     := p_Oper; --varchar2(20)  y    ������Ա
      p.Pdsavingqc := Nvl(Mi.Sbsaving, 0); --number(12,2)  y    �ڳ�Ԥ�����
      p.Pdsavingbq := p_Payment; --number(12,2)  y    ���ڷ���Ԥ����
      p.Pdsavingqm := p.Pdsavingqc + p.Pdsavingbq; --number(12,2)  y    ��ĩԤ�����
      p.Paidment   := p_Payment; --number(12,2)  y    ������
      p.Pdifsaving := NULL; --char(1)  y    ����תԤ��
      p.Pdchange   := NULL; --number(12,2)  y    ������
      p.Pdpayway   := p_Payway; --varchar2(6)  y    ���ʽ
      p.Pdbseqno   := p_Bseqno; --varchar2(20)  y    ������ˮ(����ʵʱ�շѽ�����ˮ)
      p.Pdcseqno   := NULL; --varchar2(20)  y    ����������ˮ(no use)
      p.Pdbdate    := p_Bdate; --date  y    ��������(���нɷ���������)
      p.Pdchkdate  := NULL; --date  y    ��������
      p.Pdcchkflag := 'N'; --char(1)  y    ��־(no use)
      p.Pdcdate    := NULL; --date  y    ��������
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno      := p_Seqno; --varchar2(10)  y    �ɷѽ�����ˮ(no use)
      p.Pdpayee      := p_Oper; --varchar2(20)  y    �տ�Ա
      p.Pdchbatch    := NULL; --varchar2(10)  y    ֧Ʊ��������
      p.Pdmemo       := NULL; --varchar2(200)  y    ��ע
      p.Pdpaypoint   := p_Paypoint; --varchar2(10)  y    �ɷѵص�
      p.Pdsxf        := 0; --number(12,2)  y    ������
      p.Pdilid       := NULL; --varchar2(40)  y    ��Ʊ��ˮ��
      p.Pdflag       := 'Y'; --varchar2(1)  y    ʵ�ձ�־��ȫ��Ϊy.�������ã�
      p.Pdwyj        := 0; --number(12,2)  y    ʵ���ͽ�
      p.Pdrcreceived := p_Payment; --number(12,2)  y      ʵ���տ��ʵ���տ��� =  ������ -��������ʽ�� + ʵ���ͽ� + ������ + ���ڷ���Ԥ���
      p.Pdspje       := 0; --number(12,2)  y    ���ʽ��(������ʽ�����ˮ�ѣ����ʽ����Ϊˮ�ѽ������Ԥ����Ϊ0)
      p.Preverseflag := 'N'; --varchar2(1)  y    ������־����ˮ����Ԥ����Ϊn,��ˮ�ѳ�Ԥ�汻��ʵ�պͳ�ʵ�ղ���������Ϊy��
      IF p_Pid_Source IS NULL THEN
        p.Pdscrid    := p.Pid;
        p.Pdscrtrans := p.Pdtran;
        p.Pdscrmonth := p.Pdmonth;
        p.Pdscrdate  := p.Pddate;
      ELSE
        SELECT Pid, Pdtran, Pdmonth, Pddate
          INTO p.Pdscrid, p.Pdscrtrans, p.Pdscrmonth, p.Pdscrdate
          FROM Ys_Zw_Paidment
         WHERE Pid = p_Pid_Source;
      END IF;
      p.Pdchkno  := NULL; --varchar2(10)  y    ���˵���
      p.Pdpriid  := Mi.Sbpriid; --varchar2(20)  y    ���������  20150105
      p.Tchkdate := NULL; --date  y    ��������
    END;
  
    --3�����ַ������ʷ���
    --------------------------------------------------------------------------
    IF p_Ctl_Pre = ������� THEN
      Payzwarpre(v_Parm_Ars, ���ύ);
    END IF;
  
    --3.1����ΥԼ�����ʷ���
    --------------------------------------------------------------------------
    IF ��������ΥԼ����� THEN
      Paywyjpre(v_Parm_Ars, ���ύ);
    END IF;
  
    --4�����ʺ��ĵ��ã�Ӧ�ռ�¼��������ʵ�����ݣ�
    --------------------------------------------------------------------------
    Payzwarcore(p.Pid,
                p.Pdbatch,
                p_Payment,
                Mi.Sbsaving,
                p.Pddate,
                p.Pdmonth,
                v_Parm_Ars,
                ���ύ,
                p.Pdspje,
                p.Pdwyj,
                p.Pdsxf);
  
    --5������Ԥ�淢����Ԥ����ĩ�������û�Ԥ�����
    p.Pdsavingqm := p.Pdsavingqc + p_Payment - p.Pdspje - p.Pdwyj - p.Pdsxf;
    p.Pdsavingbq := p.Pdsavingqm - p.Pdsavingqc;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --6������Ԥ�����
    o_Remainafter := p.Pdsavingqm;
  
    --7��������Ӧʵ������ƽ��У�飬��У����֧�ӹ���
    --------------------------------------------------------------------------
  
    --8�������ɷ�����������
  
    --5���ύ����
    BEGIN
      CLOSE c_Ma;
      CLOSE c_Ci;
      CLOSE c_Mi;
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Paidment VALUES p;
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
      IF c_Ma%ISOPEN THEN
        CLOSE c_Ma;
      END IF;
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Payzwarpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                       p_Commit   IN NUMBER DEFAULT ���ύ) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Rd(Varid VARCHAR2, Vardpiid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
         AND Ardpiid = Vardpiid
       ORDER BY Ardclass
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    p_Parm_Ar          Parm_Payar; --���ʰ��ڳ�Ա֮һ
    i                  INTEGER;
    j                  INTEGER;
    k                  INTEGER;
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
    Rl Ys_Zw_Arlist%ROWTYPE;
    Rd Ys_Zw_Ardetail%ROWTYPE;
    --���Ӧ��1��Ҫ���ģ�
    Rly    Ys_Zw_Arlist%ROWTYPE;
    Rdy    Ys_Zw_Ardetail%ROWTYPE;
    Rdtaby Rd_Table;
    --���Ӧ��2������������Ƿ�ѵģ�
    Rln    Ys_Zw_Arlist%ROWTYPE;
    Rdn    Ys_Zw_Ardetail%ROWTYPE;
    Rdtabn Rd_Table;
    --
    o_Arid_Reverse        Ys_Zw_Arlist.Arid%TYPE;
    o_Artrans_Reverse     VARCHAR2(10);
    o_Arje_Reverse        NUMBER;
    o_Arznj_Reverse       NUMBER;
    o_Arsxf_Reverse       NUMBER;
    o_Arsavingbq_Reverse  NUMBER;
    Io_Arsavingqm_Reverse NUMBER;
    --
    Currentdate DATE;
  BEGIN
    Currentdate := SYSDATE;
    --����Ϊ�գ�Ԥ���ֵʱ�����հ�����
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '���ʰ���Ӧ����ˮ������' || p_Parm_Ar.Arid);
          END IF;
          IF p_Parm_Ar.Ardpiids IS NOT NULL THEN
            Rly      := Rl;
            Rly.Arje := 0;
            Rdtaby   := NULL;
          
            Rln        := Rl;
            Rln.Arje   := 0;
            Rln.Arsxf  := 0; --Rlfee�����У�����rlY���ұ������ʣ��ݲ�֧�ֲ��
            Rdtabn     := NULL;
            ��������   := 0;
            ��������   := 0;
            ����ˮ��   := 0;
            ����ˮ��   := 0;
            �������   := 0;
            �������   := 0;
            һ�з����� := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
            FOR j IN 1 .. һ�з����� LOOP
              һ��һ���������־ := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
              һ��һ����         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
              OPEN c_Rd(p_Parm_Ar.Arid, һ��һ����);
              LOOP
                --���ڽ��ݣ�����Ҫѭ��
                FETCH c_Rd
                  INTO Rd;
                EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
                Rdy    := Rd;
                Rdn    := Rd;
                �ܽ�� := �ܽ�� + Rd.Ardje;
                IF һ��һ���������־ = 'Y' THEN
                  Rly.Arje     := Rly.Arje + Rdy.Ardje;
                  ��������     := �������� + 1;
                  ����ˮ��     := ����ˮ�� + Rd.Ardsl;
                  �������     := ������� + Rd.Ardje;
                  Rdn.Ardyssl  := 0;
                  Rdn.Ardysje  := 0;
                  Rdn.Ardsl    := 0;
                  Rdn.Ardje    := 0;
                  Rdn.Ardadjsl := 0;
                  Rdn.Ardadjje := 0;
                ELSIF һ��һ���������־ = 'N' THEN
                  Rln.Arje     := Rln.Arje + Rdn.Ardje;
                  ��������     := �������� + 1;
                  ����ˮ��     := ����ˮ�� + Rd.Ardsl;
                  �������     := ������� + Rd.Ardje;
                  Rdy.Ardyssl  := 0;
                  Rdy.Ardysje  := 0;
                  Rdy.Ardsl    := 0;
                  Rdy.Ardje    := 0;
                  Rdy.Ardadjsl := 0;
                  Rdy.Ardadjje := 0;
                ELSE
                  Raise_Application_Error(Errcode,
                                          '�޷�ʶ�����ʰ��д����ʱ�־');
                END IF;
                --���Ƶ�rdY
                IF Rdtaby IS NULL THEN
                  Rdtaby := Rd_Table(Rdy);
                ELSE
                  Rdtaby.Extend;
                  Rdtaby(Rdtaby.Last) := Rdy;
                END IF;
                --���Ƶ�rdN
                IF Rdtabn IS NULL THEN
                  Rdtabn := Rd_Table(Rdn);
                ELSE
                  Rdtabn.Extend;
                  Rdtabn(Rdtabn.Last) := Rdn;
                END IF;
              END LOOP;
              CLOSE c_Rd;
            END LOOP;
            --ĳһ��Ӧ���ʷ����������ʱ�־�Ų��
            IF �������� != 0 THEN
              IF �������� != 0 THEN
                --Ӧ�յ���1���ڱ���ȫ����
                Zwarreversecore(p_Parm_Ar.Arid,
                                Rl.Artrans,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                ���ύ,
                                o_Arid_Reverse,
                                o_Artrans_Reverse,
                                o_Arje_Reverse,
                                o_Arznj_Reverse,
                                o_Arsxf_Reverse,
                                o_Arsavingbq_Reverse,
                                Io_Arsavingqm_Reverse);
                --Ӧ�յ���2.1���ڱ���׷��Ŀ��Ӧ�գ������ʲ��֣�
                Rly.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rly.Armonth    := Fobtmanapara(Rly.Manage_No, 'READ_MONTH');
                Rly.Ardate     := Trunc(SYSDATE);
                Rly.Ardatetime := Currentdate;
                Rly.Arreadsl   := 0;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtaby(k).Ardid FROM Dual;
                  Rdtaby(k).Ardid := Rly.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rly;
                FOR k IN Rdtaby.First .. Rdtaby.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtaby (k);
                END LOOP;
                --Ӧ�յ���2.2���ڱ���׷��Ŀ��Ӧ�գ�������Ƿ�Ѳ��֣�
                Rln.Arid       := Lpad(Seq_Arid.Nextval, 10, '0');
                Rln.Armonth    := Fobtmanapara(Rln.Manage_No, 'READ_MONTH');
                Rln.Ardate     := Trunc(SYSDATE);
                Rln.Ardatetime := Currentdate;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  SELECT Seq_Arid.Nextval INTO Rdtabn(k).Ardid FROM Dual;
                  Rdtabn(k).Ardid := Rln.Arid;
                END LOOP;
                INSERT INTO Ys_Zw_Arlist VALUES Rln;
                FOR k IN Rdtabn.First .. Rdtabn.Last LOOP
                  INSERT INTO Ys_Zw_Ardetail VALUES Rdtabn (k);
                END LOOP;
                --�ع����ʰ�����
                p_Parm_Ars(i).Arid := Rly.Arid;
                p_Parm_Ars(i).Ardpiids := REPLACE(p_Parm_Ars(i).Ardpiids,
                                                  'N',
                                                  'Y');
              END IF;
            ELSE
              --��������=0
              p_Parm_Ars.Delete(i);
            END IF;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    
    END IF;
    --5���ύ����
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Zwarreversecore(p_Arid_Source         IN VARCHAR2,
                            p_Artrans_Reverse     IN VARCHAR2,
                            p_Pbatch_Reverse      IN VARCHAR2,
                            p_Pid_Reverse         IN VARCHAR2,
                            p_Ppayment_Reverse    IN NUMBER,
                            p_Memo                IN VARCHAR2,
                            p_Ctl_Mircode         IN VARCHAR2,
                            p_Commit              IN NUMBER DEFAULT ���ύ,
                            o_Arid_Reverse        OUT VARCHAR2,
                            o_Artrans_Reverse     OUT VARCHAR2,
                            o_Arje_Reverse        OUT NUMBER,
                            o_Arznj_Reverse       OUT NUMBER,
                            o_Arsxf_Reverse       OUT NUMBER,
                            o_Arsavingbq_Reverse  OUT NUMBER,
                            Io_Arsavingqm_Reverse IN OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Ardetail
       WHERE Ardid = Varid
       ORDER BY Ardpiid, Ardclass
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_p_Reverse(Vrpid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Paidment WHERE Pid = Vrpid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    SUBTYPE Rd_Type IS Ys_Zw_Ardetail%ROWTYPE;
    TYPE Rd_Table IS TABLE OF Rd_Type;
    --������ԭӦ��
    Rl_Source Ys_Zw_Arlist%ROWTYPE;
    Rd_Source Ys_Zw_Ardetail%ROWTYPE;
    --����Ӧ��
    Rl_Reverse     Ys_Zw_Arlist%ROWTYPE;
    Rd_Reverse     Ys_Zw_Ardetail%ROWTYPE;
    Rd_Reverse_Tab Rd_Table;
    --
    p_Reverse Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    OPEN c_Rl(p_Arid_Source);
    FETCH c_Rl
      INTO Rl_Source;
    IF c_Rl%FOUND THEN
      --���Ĳ���У��
      IF �����ظ����� = 0 AND Rl_Source.Aroutflag = 'Y' THEN
        Raise_Application_Error(Errcode,
                                '��ǰϵͳ�����������н���Ӧ�ճ���');
      END IF;
    
      Rl_Reverse                := Rl_Source;
      Rl_Reverse.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
      Rl_Reverse.Ardate         := Trunc(SYSDATE);
      Rl_Reverse.Ardatetime     := SYSDATE; --20140514 add
      Rl_Reverse.Armonth        := Fobtmanapara(Rl_Reverse.Manage_No,
                                                'READ_MONTH');
      Rl_Reverse.Arcd           := ����;
      Rl_Reverse.Arreadsl       := -Rl_Reverse.Arreadsl; --20140707 add
      Rl_Reverse.Arsl           := -Rl_Reverse.Arsl;
      Rl_Reverse.Arje           := -Rl_Reverse.Arje; --��ȫ��
      Rl_Reverse.Arznjreducflag := Rl_Reverse.Arznjreducflag;
      Rl_Reverse.Arznj          := -Rl_Reverse.Arznj; --�����������ԭӦ������ΥԼ��,δ�����Ӧ��ΥԼ��
      Rl_Reverse.Arsxf          := -Rl_Reverse.Arsxf; --�����������ԭӦ������������1��,δ�����Ӧ��������1
      Rl_Reverse.Arreverseflag  := 'Y';
      Rl_Reverse.Armemo         := p_Memo;
      Rl_Reverse.Artrans        := p_Artrans_Reverse;
      --Ӧ�ճ��������̵����£�������Ϣ�̳�Դ��
      --ʵ�ճ��������̵����£�������Ϣ��д�����ж�ʵ�ճ�������
      --�˿ʵ�ռơ�ʵ�ճ���������C��Ӧ�ռơ�����������C
      --���˿�̳�ԭʵ�ա�Ӧ������
      IF p_Pid_Reverse IS NOT NULL THEN
        OPEN c_p_Reverse(p_Pid_Reverse);
        FETCH c_p_Reverse
          INTO p_Reverse;
        IF c_p_Reverse%NOTFOUND OR c_p_Reverse%NOTFOUND IS NULL THEN
          Raise_Application_Error(Errcode, '�������ʲ�����');
        END IF;
        CLOSE c_p_Reverse;
      
        Rl_Reverse.Arpaiddate  := Trunc(SYSDATE); --���������¼��������
        Rl_Reverse.Arpaidmonth := Fobtmanapara(Rl_Reverse.Manage_No,
                                               'READ_MONTH'); --���������¼��������
      
        Rl_Reverse.Arpaidje   := p_Ppayment_Reverse; --������Ϣ��д
        Rl_Reverse.Arsavingqc := (CASE
                                   WHEN Io_Arsavingqm_Reverse IS NULL THEN
                                    p_Reverse.Pdsavingqc
                                   ELSE
                                    Io_Arsavingqm_Reverse
                                 END); --������Ϣ����д
        Rl_Reverse.Arsavingbq := Rl_Reverse.Arpaidje - Rl_Reverse.Arje -
                                 Rl_Reverse.Arznj - Rl_Reverse.Arsxf; --������Ϣ��д
        Rl_Reverse.Arsavingqm := Rl_Reverse.Arsavingqc +
                                 Rl_Reverse.Arsavingbq; --������Ϣ��д
        Rl_Reverse.Arpid      := p_Pid_Reverse;
        Rl_Reverse.Arpbatch   := p_Pbatch_Reverse;
        Io_Arsavingqm_Reverse := Rl_Reverse.Arsavingqm;
      END IF;
      --rlscrrlid    := ;--�̳�ԭӦ��ֵ
      --rlscrrldate  := ;--�̳�ԭӦ��ֵ
      --rlscrrlmonth := ;--�̳�ԭӦ��ֵ
      --rlscrrllb    := ;--�̳�ԭӦ��ֵ
      OPEN c_Rd(p_Arid_Source);
      LOOP
        FETCH c_Rd
          INTO Rd_Source;
        EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
        Rd_Reverse := Rd_Source;
        SELECT Seq_Arid.Nextval INTO Rd_Reverse.Ardid FROM Dual;
        Rd_Reverse.Ardid    := Rl_Reverse.Arid;
        Rd_Reverse.Ardyssl  := -Rd_Reverse.Ardyssl;
        Rd_Reverse.Ardysje  := -Rd_Reverse.Ardysje;
        Rd_Reverse.Ardsl    := -Rd_Reverse.Ardsl;
        Rd_Reverse.Ardje    := -Rd_Reverse.Ardje;
        Rd_Reverse.Ardadjsl := -Rd_Reverse.Ardadjsl;
        Rd_Reverse.Ardadjje := -Rd_Reverse.Ardadjje;
        --���Ƶ�rd_reverse_tab
        IF Rd_Reverse_Tab IS NULL THEN
          Rd_Reverse_Tab := Rd_Table(Rd_Reverse);
        ELSE
          Rd_Reverse_Tab.Extend;
          Rd_Reverse_Tab(Rd_Reverse_Tab.Last) := Rd_Reverse;
        END IF;
      END LOOP;
      CLOSE c_Rd;
    ELSE
      Raise_Application_Error(Errcode, '��Ч��Ӧ����ˮ��');
    END IF;
    --����ֵ
    o_Arid_Reverse       := Rl_Reverse.Arid;
    o_Artrans_Reverse    := Rl_Reverse.Artrans;
    o_Arje_Reverse       := Rl_Reverse.Arje;
    o_Arznj_Reverse      := Rl_Reverse.Arznj;
    o_Arsxf_Reverse      := Rl_Reverse.Arsxf;
    o_Arsavingbq_Reverse := Rl_Reverse.Arsavingbq;
    --2���ύ����
    BEGIN
      CLOSE c_Rl;
      IF p_Commit = ���� THEN
        ROLLBACK;
      ELSE
        INSERT INTO Ys_Zw_Arlist VALUES Rl_Reverse;
        FOR k IN Rd_Reverse_Tab.First .. Rd_Reverse_Tab.Last LOOP
          INSERT INTO Ys_Zw_Ardetail VALUES Rd_Reverse_Tab (k);
        END LOOP;
        UPDATE Ys_Zw_Arlist
           SET Arreverseflag = 'Y'
         WHERE Arid = p_Arid_Source;
        --�������Ƹ�ֵ
        IF p_Ctl_Mircode IS NOT NULL THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = To_Number(p_Ctl_Mircode)
           WHERE Sbid = Rl_Source.Sbid;
        END IF;
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
      IF c_p_Reverse%ISOPEN THEN
        CLOSE c_p_Reverse;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Paywyjpre(p_Parm_Ars IN OUT Parm_Payar_Tab,
                      p_Commit   IN NUMBER DEFAULT ���ύ) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Arlist WHERE Arid = Varid;
    CURSOR c_Rd(Varid VARCHAR2) IS
      SELECT * FROM Ys_Zw_Ardetail WHERE Ardid = Varid;
    p_Parm_Ar  Parm_Payar := Parm_Payar(NULL, NULL, NULL, NULL, NULL, NULL);
    v_Parm_Ars Parm_Payar_Tab := Parm_Payar_Tab();
    --������ԭӦ��
    Rl                 Ys_Zw_Arlist%ROWTYPE;
    Rd                 Ys_Zw_Ardetail%ROWTYPE;
    Vexist             NUMBER := 0;
    һ�з�����         INTEGER;
    һ��һ����         VARCHAR2(10);
    һ��һ���������־ CHAR(1);
  BEGIN
    --����Ϊ�գ�Ԥ���ֵʱ�����հ�����
    IF p_Parm_Ars.Count > 0 THEN
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        IF p_Parm_Ar.Arwyj <> 0 AND p_Parm_Ar.Arid IS NOT NULL THEN
          OPEN c_Rl(p_Parm_Ar.Arid);
          FETCH c_Rl
            INTO Rl;
          IF c_Rl%NOTFOUND OR c_Rl%NOTFOUND IS NULL THEN
            Raise_Application_Error(Errcode,
                                    '���ʰ���Ӧ����ˮ������' || p_Parm_Ar.Arid);
          END IF;
          һ�з����� := Pg_Cb_Cost.Fboundpara(p_Parm_Ar.Ardpiids);
          FOR j IN 1 .. һ�з����� LOOP
            һ��һ���������־ := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 1);
            һ��һ����         := Pg_Cb_Cost.Fgetpara(p_Parm_Ar.Ardpiids, j, 2);
            IF һ��һ���������־ = 'N' AND Upper(һ��һ����) = 'ZNJ' THEN
              Vexist := 1;
            END IF;
          END LOOP;
          IF Vexist = 1 THEN
            Rl.Arid           := Lpad(Seq_Arid.Nextval, 10, '0');
            Rl.Arje           := 0;
            Rl.Arsl           := 0;
            Rl.Arznj          := p_Parm_Ar.Arwyj;
            Rl.Armemo         := 'ΥԼ��׷��';
            Rl.Arznjreducflag := 'Y';
            OPEN c_Rd(p_Parm_Ar.Arid);
            LOOP
              FETCH c_Rd
                INTO Rd;
              EXIT WHEN c_Rd%NOTFOUND OR c_Rd%NOTFOUND IS NULL;
              Rd.Ardid    := Rl.Arid;
              Rd.Ardsl    := 0;
              Rd.Ardje    := 0;
              Rd.Ardyssl  := 0;
              Rd.Ardysje  := 0;
              Rd.Ardadjsl := 0;
              Rd.Ardadjje := 0;
              INSERT INTO Ys_Zw_Ardetail VALUES Rd;
            END LOOP;
            INSERT INTO Ys_Zw_Arlist VALUES Rl;
            CLOSE c_Rd;
            --
            p_Parm_Ar.Arid := Rl.Arid;
            IF v_Parm_Ars IS NULL THEN
              v_Parm_Ars := Parm_Payar_Tab(p_Parm_Ar);
            ELSE
              v_Parm_Ars.Extend;
              v_Parm_Ars(v_Parm_Ars.Last) := p_Parm_Ar;
            END IF;
            --
            p_Parm_Ars(i).Arwyj := 0;
          END IF;
          CLOSE c_Rl;
        END IF;
      END LOOP;
    END IF;
    --5���ύ����
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      IF c_Rd%ISOPEN THEN
        CLOSE c_Rd;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Payzwarcore(p_Pid          IN VARCHAR2,
                        p_Batch        IN VARCHAR2,
                        p_Payment      IN NUMBER,
                        p_Remainbefore IN NUMBER,
                        p_Paiddate     IN DATE,
                        p_Paidmonth    IN VARCHAR2,
                        p_Parm_Ars     IN Parm_Payar_Tab,
                        p_Commit       IN NUMBER DEFAULT ���ύ,
                        o_Sum_Arje     OUT NUMBER,
                        o_Sum_Arznj    OUT NUMBER,
                        o_Sum_Arsxf    OUT NUMBER) IS
    CURSOR c_Rl(Varid VARCHAR2) IS
      SELECT *
        FROM Ys_Zw_Arlist
       WHERE Arid = Varid
         AND Arpaidflag = 'N'
         AND Arreverseflag = 'N' /*and rlje>0*/ /*֧��0�������*/
         FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    Rl          Ys_Zw_Arlist%ROWTYPE;
    p_Parm_Ar   Parm_Payar;
    Sumrlpaidje NUMBER(13, 3) := 0; --�ۼ�ʵ�ս�Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123��
    p_Remaind   NUMBER(13, 3); --�ڳ�Ԥ���ۼ���
  BEGIN
    --�ڳ�Ԥ���ۼ�����ʼ��
    p_Remaind := p_Remainbefore;
    --����ֵ��ʼ���������ʰ��ǿյ����α��ֵ����
    o_Sum_Arje  := 0;
    o_Sum_Arznj := 0;
    o_Sum_Arsxf := 0;
    SAVEPOINT δ��״̬;
    IF p_Parm_Ars.Count > 0 THEN
      --����Ϊ�գ�Ԥ���ֵʱ��
      FOR i IN p_Parm_Ars.First .. p_Parm_Ars.Last LOOP
        p_Parm_Ar := p_Parm_Ars(i);
        OPEN c_Rl(p_Parm_Ar.Arid);
        --���ʰ��ǿ�ʱ��Ҳ�����������������������Ӧ��id��������۸������ʱ������������
        FETCH c_Rl
          INTO Rl;
        IF c_Rl%FOUND THEN
          --��֯һ������Ӧ�ռ�¼���±���
          Rl.Arpaidflag  := 'Y'; --varchar2(1)  y  'n'    �Ƿ����˱�־��ȫ�����ʡ��������м�״̬��
          Rl.Arsavingqc  := p_Remaind; --number(13,2)  y  0    �����ڳ�Ԥ��
          Rl.Arsavingbq  := -Pg_Cb_Cost.Getmin(p_Remaind,
                                               Rl.Arje + p_Parm_Ar.Arwyj +
                                               p_Parm_Ar.Fee1); --number(13,2)  y  0    ����Ԥ�淢����������
          Rl.Arsavingqm  := Rl.Arsavingqc + Rl.Arsavingbq; --number(13,2)  y  0    ������ĩԤ��
          Rl.Arznj       := p_Parm_Ar.Arwyj; --number(13,2)  y  0    ʵ��ΥԼ��
          Rl.Arsxf       := p_Parm_Ar.Fee1; --number(13,2)  y  0    ʵ��������ϵͳ����1
          Rl.Arpaiddate  := p_Paiddate; --date  y      �������ڣ�ʵ������ʱ�ӣ�
          Rl.Arpaidmonth := p_Paidmonth; --varchar2(7)  y      �����·ݣ�ʵ������ʱ�ӣ�
          Rl.Arpaidje    := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    ʵ�ս�ʵ�ս��=Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123+Ԥ�淢������sum(rl.rlpaidje)=p.ppayment
          Rl.Arpid       := p_Pid; --
          Rl.Arpbatch    := p_Batch;
          Rl.Armicolumn1 := '';
          --�м��������
          Sumrlpaidje := Sumrlpaidje + Rl.Arpaidje;
          --ĩ�����ʼ�¼�������������ʵ�ս�����ĩ�����ʼ�¼��Ԥ�淢���У�����
          IF i = p_Parm_Ars.Last THEN
            Rl.Arsavingbq := Rl.Arsavingbq + (p_Payment - Sumrlpaidje);
            Rl.Arsavingqm := Rl.Arsavingqc + Rl.Arsavingbq;
            Rl.Arpaidje   := Rl.Arje + Rl.Arznj + Rl.Arsxf + Rl.Arsavingbq; --number(13,2)  y  0    ʵ�ս�ʵ�ս��=Ӧ�ս��+ʵ��ΥԼ��+ʵ��������ϵͳ����123+Ԥ�淢������sum(rl.rlpaidje)=p.ppayment
          END IF;
          --���Ĳ���У��
          IF NOT ����Ԥ�淢�� AND Rl.Arsavingbq != 0 THEN
            Raise_Application_Error(Errcode,
                                    '��ǰϵͳ����Ϊ��֧��Ԥ�淢��');
          END IF;
          --����ʵ�ռ�¼
          o_Sum_Arje  := o_Sum_Arje + Rl.Arje;
          o_Sum_Arznj := o_Sum_Arznj + Rl.Arznj;
          o_Sum_Arsxf := o_Sum_Arsxf + Rl.Arsxf;
          p_Remaind   := p_Remaind + Rl.Arsavingbq;
          --���´�����Ӧ�ռ�¼
          UPDATE Ys_Zw_Arlist
             SET Arpaidflag  = Rl.Arpaidflag,
                 Arsavingqc  = Rl.Arsavingqc,
                 Arsavingbq  = Rl.Arsavingbq,
                 Arsavingqm  = Rl.Arsavingqm,
                 Arznj       = Rl.Arznj,
                 Armicolumn1 = Rl.Armicolumn1,
                 Arsxf       = Rl.Arsxf,
                 Arpaiddate  = Rl.Arpaiddate,
                 Arpaidmonth = Rl.Arpaidmonth,
                 Arpaidje    = Rl.Arpaidje,
                 Arpid       = Rl.Arpid,
                 Arpbatch    = Rl.Arpbatch,
                 Aroutflag   = 'N'
           WHERE Arid = Rl.Arid; --current of c_rl;Ч�ʵ�
        ELSE
          o_Sum_Arsxf := o_Sum_Arsxf + p_Parm_Ar.Fee1;
        END IF;
        CLOSE c_Rl;
      END LOOP;
    END IF;
  
    --���Ĳ���У��
    IF ����Ϊ��Ԥ�治���� AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      o_Sum_Arje  := 0;
      o_Sum_Arznj := 0;
      o_Sum_Arsxf := 0;
      ROLLBACK TO δ��״̬;
    END IF;
  
    --���Ĳ���У��
    IF NOT ��������Ԥ�� AND p_Remaind < 0 AND p_Remaind < p_Remainbefore THEN
      Raise_Application_Error(Errcode,
                              '��ǰϵͳ����Ϊ��֧�ַ���������ĩ��Ԥ��');
    END IF;
  
    --5���ύ����
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
      IF c_Rl%ISOPEN THEN
        CLOSE c_Rl;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  Ԥ���ֵ��һ��
  ���������˵������
  ���������˵������
  ������˵������
  ��������־����
  */
  PROCEDURE Precust(p_Sbid        IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --У��
    IF p_Payment <= 0 THEN
      Raise_Application_Error(Errcode, 'Ԥ���ֵҵ�������Ϊ����Ŷ');
    END IF;
    --���ú���
    Precore(p_Sbid,
            Ptrans_����Ԥ��,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            ���ύ,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  /*==========================================================================
  Ԥ���˷ѣ�һ��
  ���������˵������
  ���������˵������
  ������˵������
  ��������־����
  */
  PROCEDURE Precustback(p_Sbid        IN VARCHAR2,
                        p_Position    IN VARCHAR2,
                        p_Oper        IN VARCHAR2,
                        p_Payway      IN VARCHAR2,
                        p_Payment     IN NUMBER,
                        p_Memo        IN VARCHAR2,
                        p_Batch       IN OUT VARCHAR2,
                        o_Pid         OUT VARCHAR2,
                        o_Remainafter OUT NUMBER) IS
  
    p_Seqno VARCHAR2(10);
  BEGIN
    --У��
    IF p_Payment >= 0 THEN
      Raise_Application_Error(Errcode, 'Ԥ���ֵҵ�������Ϊ����Ŷ');
    END IF;
    --���ú���
    Precore(p_Sbid,
            Ptrans_����Ԥ��,
            p_Position,
            NULL,
            NULL,
            NULL,
            p_Oper,
            p_Payway,
            p_Payment,
            ���ύ,
            p_Memo,
            p_Batch,
            p_Seqno,
            o_Pid,
            o_Remainafter);
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
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
  PROCEDURE Precore(p_Sbid        IN VARCHAR2,
                    p_Trans       IN VARCHAR2,
                    p_Position    IN VARCHAR2,
                    p_Paypoint    IN VARCHAR2,
                    p_Bdate       IN DATE,
                    p_Bseqno      IN VARCHAR2,
                    p_Oper        IN VARCHAR2,
                    p_Payway      IN VARCHAR2,
                    p_Payment     IN NUMBER,
                    p_Commit      IN NUMBER,
                    p_Memo        IN VARCHAR2,
                    p_Batch       IN OUT VARCHAR2,
                    p_Seqno       IN OUT VARCHAR2,
                    o_Pid         OUT VARCHAR2,
                    o_Remainafter OUT NUMBER) IS
    CURSOR c_Ci(Vciid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vciid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
    CURSOR c_Mi(Vmiid VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmiid FOR UPDATE NOWAIT; --������ֱ���׳��쳣
  
    Mi Ys_Yh_Sbinfo%ROWTYPE;
    Ci Ys_Yh_Custinfo%ROWTYPE;
    p  Ys_Zw_Paidment%ROWTYPE;
  BEGIN
    IF NOT ����Ԥ�淢�� THEN
      Raise_Application_Error(Errcode, '��ǰϵͳ����Ϊ��֧��Ԥ�淢��');
    END IF;
    --1��У�鼰���ʼ��
    BEGIN
      --ȡˮ����Ϣ
      OPEN c_Mi(p_Sbid);
      FETCH c_Mi
        INTO Mi;
      IF c_Mi%NOTFOUND OR c_Mi%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode, '���Ǵ���ˮ����룿' || p_Sbid);
      END IF;
      --ȡ�û���Ϣ
      OPEN c_Ci(Mi.Yhid);
      FETCH c_Ci
        INTO Ci;
      IF c_Ci%NOTFOUND OR c_Ci%NOTFOUND IS NULL THEN
        Raise_Application_Error(Errcode,
                                '���ˮ�����û��Ӧ�û���' || p_Sbid);
      END IF;
    END;
  
    --2����¼ʵ��
    BEGIN
      SELECT TRIM(To_Char(Seq_Paidment.Nextval, '0000000000'))
        INTO o_Pid
        FROM Dual;
      SELECT Sys_Guid() INTO p.Id FROM Dual;
      p.Hire_Code    := Mi.Hire_Code;
      p.Pid          := o_Pid;
      p.Yhid         := Ci.Yhid;
      p.Sbid         := Mi.Sbid;
      p.Pdrcreceived := p_Payment;
      p.Pddate       := Trunc(SYSDATE);
      p.Pdatetime    := SYSDATE;
      p.Pdmonth      := Fobtmanapara(Mi.Manage_No, 'READ_MONTH');
      p.Manage_No    := p_Position;
      p.Pdpaypoint   := p_Paypoint;
      p.Pdtran       := p_Trans;
      p.Pdpers       := p_Oper;
      p.Pdpayee      := p_Oper;
      p.Pdpayway     := p_Payway;
      p.Paidment     := p_Payment;
      p.Pdspje       := 0;
      p.Pdwyj        := 0;
      p.Pdsavingqc   := Nvl(Mi.Sbsaving, 0);
      p.Pdsavingbq   := p_Payment;
      p.Pdsavingqm   := p.Pdsavingqc + p.Pdsavingbq;
      p.Pdsxf        := 0; --��Ϊ����Ѻ��;
      p.Preverseflag := 'N'; --����״̬����ˮ����Ԥ����ΪN,��ˮ�ѳ�Ԥ�汻��ʵ�պͳ�ʵ�ղ���������ΪY��
      p.Pdbdate      := Trunc(p_Bdate);
      p.Pdbseqno     := p_Bseqno;
      p.Pdchkdate    := NULL;
      p.Pdcchkflag   := NULL;
      p.Pdcdate      := NULL;
      p.Pdcseqno     := NULL;
      p.Pdmemo       := p_Memo;
      IF p_Batch IS NULL THEN
        SELECT TRIM(To_Char(Seq_Paidbatch.Nextval, '0000000000'))
          INTO p.Pdbatch
          FROM Dual;
      ELSE
        p.Pdbatch := p_Batch;
      END IF;
      p.Pdseqno    := p_Seqno;
      p.Pdscrid    := p.Pid;
      p.Pdscrtrans := p.Pdtran;
      p.Pdscrmonth := p.Pdmonth;
      p.Pdscrdate  := p.Pddate;
    END;
    p.Pdchkno     := NULL; --varchar2(10)  y    ���˵���
    p.Pdpriid     := Mi.Sbpriid; --varchar2(20)  y    ���������  20150105
    p.Tchkdate    := NULL; --date  y    ��������
    o_Remainafter := p.Pdsavingqm;
  
    --У��
    IF NOT ��������Ԥ�� AND p.Pdsavingqm < 0 AND p.Pdsavingqm < p.Pdsavingqc THEN
      Raise_Application_Error(Errcode,
                              '��ǰϵͳ����Ϊ��֧�ַ����������ĩ��Ԥ��');
    END IF;
    INSERT INTO Ys_Zw_Paidment VALUES p;
    UPDATE Ys_Yh_Sbinfo SET Sbsaving = p.Pdsavingqm WHERE CURRENT OF c_Mi;
  
    --5���ύ����
    BEGIN
      CLOSE c_Ci;
      CLOSE c_Mi;
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
      IF c_Ci%ISOPEN THEN
        CLOSE c_Ci;
      END IF;
      IF c_Mi%ISOPEN THEN
        CLOSE c_Mi;
      END IF;
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  --
  FUNCTION Fmid(p_Str IN VARCHAR2, p_Sep IN VARCHAR2) RETURN INTEGER IS
    --help:
    --tools.fmidn('/123/123/123/','/')=5
    --tools.fmidn(null,'/')=0
    --tools.fmidn('','/')=0
    --tools.fmidn('null','/')=1
    i INTEGER;
    n INTEGER := 1;
  BEGIN
    IF TRIM(p_Str) IS NULL THEN
      RETURN 0;
    ELSE
      FOR i IN 1 .. Length(p_Str) LOOP
        IF Substr(p_Str, i, 1) = p_Sep THEN
          n := n + 1;
        END IF;
      END LOOP;
    END IF;
  
    RETURN n;
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

-----
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


/* procedure PosReverse$(p_pid_source  in varchar2,
                        p_oper        in varchar2,
                        p_pposition   in varchar2,
                        p_ppaypoint   in varchar2,
                        p_ppayway     in varchar2,
                        p_memo        in varchar2,
                        p_commit      in number default ���ύ,
                        p_pid_reverse out varchar2) is
    p                payment%rowtype;
    vppaymentreverse number(12, 2);
    vappendrlid      varchar2(10);
  begin
    select * into p from payment where pid = p_pid_source;
    --У��
    if not (p.preverseflag = 'N' and p.ppayment >= 0) then
      raise_application_error(errcode,
                              '������ʵ�ռ�¼��Ч������Ϊδ�����������ɷ�');
    end if;
    PayReverse(p_pid_source,
               p_pposition,
               p_ppaypoint,
               'C',
               null,
               null,
               p_oper,
               p_ppayway,
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
      pg_ewide_interface.ErrLog(dbms_utility.format_call_stack(),
                                'PosReverse,p_pid_source:' || p_pid_source);
      raise;
      --raise_application_error(errcode, sqlerrm);
  end PosReverse$;
  */ /*******************************************************************************************
  ��������F_PAYBACK_BY_PMID
  ��;��ʵ�ճ���,��ʵ����ˮid����
  ������
  ҵ�����

  ����ֵ��
  *******************************************************************************************/
/*FUNCTION F_PAYBACK_BY_PMID(P_PAYID    IN YS_ZW_PAIDMENT.PID%TYPE,
                             P_POSITION IN YS_ZW_PAIDMENT.MANAGE_NO%TYPE,
                             P_OPER     IN YS_ZW_PAIDMENT.PDPERS%TYPE,
                             P_BATCH    IN YS_ZW_PAIDMENT.PDBATCH%TYPE,
                             P_PAYPOINT IN YS_ZW_PAIDMENT.PDPAYPOINT%TYPE,
                             P_TRANS    IN YS_ZW_PAIDMENT.PDTRAN%TYPE,
                             P_COMMIT   IN VARCHAR2) 
                              RETURN VARCHAR2 IS

    PM YS_ZW_PAIDMENT%ROWTYPE;
    MI  ys_yh_sbinfo%ROWTYPE;
    CQ CHEQUE%ROWTYPE;
    --���������ڴ�˵��F
    V_STEP    NUMBER; --��������ȱ������������
    V_PRC_MSG VARCHAR2(400); --��������Ϣ�������������

    V_RESULT VARCHAR2(3); --������
    V_RECID  YS_ZW_ARLIST.ARID%TYPE;

    ERR_SAVING EXCEPTION;

    V_CALL NUMBER;
    V_COUNT NUMBER:=0;
    R1 RECLIST_1METER_TMP%ROWTYPE;
    RL1 RECLIST%ROWTYPE;

    \*�������³���֮�������·�Ϊ��ǰ�µ�BUG*\
     cursor c_sscz_list is
        select s.* from reclist_1meter_tmp s;

      v_sscz_list  reclist_1meter_tmp%rowtype;

  BEGIN
    --STEP 1:ʵ���ʴ���----------------------------------

    V_STEP    := 1;
    V_PRC_MSG := 'ʵ���ʴ���';
    --����Ƿ��з��������Ĵ�������¼
    SELECT T.*
      INTO PM
      FROM PAYMENT T
     WHERE T.PID = P_PAYID
       AND T.PREVERSEFLAG <> 'Y';

    --֧Ʊ������,����ʱ��д��һ���ʸ�����֧Ʊ��cheque
    --�����д�����������˲�һ�¡����Բ���
      -- modify 201406708 hb
      --20160503 ����  PS  ԭ��ͬ��
      IF PM.PPAYWAY in ('ZP','MZ','DC','PS') THEN
          SELECT COUNT(CHEQUEID) INTO V_COUNT FROM CHEQUE   WHERE CHEQUEID=PM.PBATCH;
          IF V_COUNT> 0 THEN  --����ʱ��д�����ϣ����������������δд��
              select * into CQ from  CHEQUE   WHERE CHEQUEID=PM.PBATCH;
               CQ.CHEQUEID :=P_BATCH;
               cq.enteringtime :=sysdate;
               --cq.chequemoney:=0 - cq.chequemoney;
               cq.chequemoney:= 0 - PM.PPAYMENT;
               CQ.CHEQUECWNO :='';
               CQ.CHEQUEYXNO :='';
            --   if  cq.chequemoney > 0 then --ADD 20140905
               --   CQ.chequecrflag:='Y';
            --   else
                  CQ.chequecrflag:='Y';
                  CQ.CHEQUEMEMO:='ʵ�ճ���д��'; --ADD 20140905
             --  end if ;
               CQ.chequecrdate:=SYSDATE;
               CQ.chequecroper:=P_OPER;
               DELETE FROM cheque  WHERE CHEQUEID=CQ.CHEQUEID ;
               insert into cheque values CQ;
           END IF ;
       end if ;
     --end ֧Ʊ����

    --ȡˮ����Ϣ
    SELECT T.* INTO MI FROM METERINFO T WHERE T.MIID = PM.PMID;

    \*--��鵱ǰԤ���Ƿ񹻳�������,�������˳� [yujia 2012-02-08]
    IF PM.PSAVINGBQ>MI.MISAVING THEN
       RAISE ERR_SAVING;
    END IF;*\

    --׼��ʵ�ճ�������¼������
    PM.PPOSITION    := P_POSITION; --����
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  ���ʵ�ճ�����Ԥ��ֿۣ����û���дsystem���������ʳ�����
      --���û�5038003584���е����ʶ�300Ԫ��ϵͳ����Ԥ��ֿۣ�ֻ���û����г���������֮��ϵͳ��¼�����û��˺ţ���ʱ���շ�Ա����������
          PM.PPER         := 'SYSTEM'; --����
    else
          PM.PPER         := P_OPER; --����
    end if ;
    PM.PSAVINGQC    := MI.MISAVING; --ȡ��ǰ
    PM.PSAVINGBQ    := 0 - PM.PSAVINGBQ; --ȡ��
    PM.PSAVINGQM    := MI.MISAVING + PM.PSAVINGBQ; --����
    PM.PPAYMENT     := 0 - PM.PPAYMENT; --ȡ��
    PM.PBATCH       := P_BATCH; --����
    if PM.PTRANS ='U' AND upper(PM.PPER) ='SYSTEM' THEN
       --add 20140826 hb  ���ʵ�ճ�����Ԥ��ֿۣ����û���дsystem���������ʳ�����
      --���û�5038003584���е����ʶ�300Ԫ��ϵͳ����Ԥ��ֿۣ�ֻ���û����г���������֮��ϵͳ��¼�����û��˺ţ���ʱ���շ�Ա����������
           PM.PPAYEE        := 'SYSTEM'; --����
    else
             PM.PPAYEE       := P_OPER; --����
    end if ;

    pm.pchkdate     :=sysdate ; --������Ҫ���������ڼ�¼Ϊ��ǰ��ϵͳ�������� by 20150203 ralph
    PM.PPAYPOINT    := P_PAYPOINT; --����
    PM.PSXF         := 0 - PM.PSXF; --ȡ��
    PM.PILID        := ''; --��
    PM.PZNJ         := 0 - PM.PZNJ; --ȡ��
    PM.PRCRECEIVED  := 0 - PM.PRCRECEIVED; --ȡ��
    PM.PSPJE        := 0 - PM.PSPJE; --ȡ��
    PM.PREVERSEFLAG := 'Y'; --Y
    PM.PSCRID       := PM.PID; --ԭ��¼.PID
    PM.PSCRTRANS    := PM.PTRANS; --ԭ��¼.PTRANS
    PM.PSCRMONTH    := PM.PMONTH; --ԭ��¼.PMONTH
    PM.PSCRDATE     := PM.PDATE; --ԭ��¼.PDATE
    ----���¼���������ֵһ��Ҫ������󣬺ʹ����й�
    PM.PID   := FGETSEQUENCE('PAYMENT'); --������
    PM.PDATE := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    ----���¼���������ֵһ��Ҫ������󣬺ʹ����й�
    PM.PID       := FGETSEQUENCE('PAYMENT'); --������
    PM.PDATE     := TOOLS.FGETPAYDATE(MI.MISMFID); --SYSDATE
    PM.PDATETIME := SYSDATE; --SYSDATE
    PM.PMONTH    := TOOLS.FGETRECMONTH(MI.MISMFID); --��ǰ�·�
    PM.PCHKNO := null ;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
    pm.TCHKDATE :=null;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
    pm.pdzdate :=null;-- 20140806Ӫ������д��Ϊ�գ�������ɶ������
   -- PM.PTRANS    := P_TRANS; --����  modify 20140625 hb ȡ��,�����ʱ��Ӧ��������ԭӦ������Ӧ����ȣ���������ⲿ����������²���
    -----------------------------------------------------------------
    --�������ʵ�ո���¼
    INSERT INTO PAYMENT T VALUES PM;
    --ԭ��������¼���ϳ�����־
    UPDATE PAYMENT T SET T.PREVERSEFLAG = 'Y' WHERE T.PID = P_PAYID;
    --END OF STEP 1: ��������---------------------------------------------------
    --PAYMENT ��������һ������¼
    -- ��������¼�ĳ�����־ΪY
    ----------------------------------------------------------------------------------------
 
    --Ӧ���˴���--------------------------------------------------------------
    -----STEP 10: ���Ӹ�Ӧ�ռ�¼
    ------����ʱ���д����Ҫ���������Ӧ�����˺���ϸ�ʼ�¼
    ---�������ʱ��
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---������Ҫ���������Ӧ�����˼�¼
    V_STEP    := 10;
    V_PRC_MSG := '������Ҫ���������Ӧ�����˼�¼';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';
  

    ---������Ҫ���������Ӧ����ϸ�ʼ�¼
    V_STEP    := 11;
    V_PRC_MSG := '������Ҫ���������Ӧ����ϸ�ʼ�¼';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    V_PRC_MSG := '��Ӧ��������ʱ����������¼�ĵ���';
    \* UPDATE RECLIST_1METER_TMP T
    SET T.RLID    = FGETSEQUENCE('RECLIST'),
        T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --��ǰ              �����·�
        T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --��ǰ              ��������
       \* T.RLMONTH = PM.PMONTH, --��ǰ              �����·�
        T.RLDATE  = PM.PDATE, --��ǰ              ��������*\
        T.RLREADSL     = 0 - T.RLREADSL ,--����ˮ��
        t.rlentrustbatch = null,--���մ�������
        t.rlentrustseqno = null,-- ���մ�����ˮ��
        -- T.RLCHARGEPER   = PM.PPER, --ͬʵ��            �շ�Ա
        T.RLSL          = 0 - T.RLSL, --ȡ��              Ӧ��ˮ��
        T.RLJE          = 0 - T.RLJE, --ȡ��              Ӧ�ս��
        T.RLADDSL       = 0 - T.RLADDSL, --ȡ��              �ӵ�ˮ��

        T.rlcolumn9     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
        T.rlcolumn11  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
        T.rlcolumn10  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�
        T.RLCOLUMN5   = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������

        \*T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID       ԭӦ������ˮ
        T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS    ԭӦ��������
        T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH    ԭӦ�����·�*\
        T.RLPAIDJE      = 0 - T.RLPAIDJE, --ȡ��              ���ʽ��
        --T.RLPAIDFLAG    = 'Y', --Y                 ���ʱ�־(Y:Y��N:N��X:X��V:Y/N��T:Y/X��K:N/X��W:Y/N/X)
        T.RLPAIDPER     = PM.PPER, --ͬʵ��            ������Ա
        T.RLPAIDDATE    = PM.PDATE, --ͬʵ��            ��������
        T.RLZNJ         = 0 - T.RLZNJ, --ȡ��              ΥԼ��
        T.RLDATETIME    = SYSDATE, --SYSDATE           ��������

       \* T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE     ԭ��������*\
        T.RLPID         = PM.PID, --��Ӧ�ĸ�ʵ����ˮ  ʵ����ˮ����YS_ZW_PAIDMENT.pid��Ӧ��
        T.RLPBATCH      = PM.PBATCH, --��Ӧ�ĸ�ʵ����ˮ  �ɷѽ������Σ���YS_ZW_PAIDMENT.PBATCH��Ӧ��
        T.RLSAVINGQC    = T.RLSAVINGQM + nvl(mi.misaving,0) , --����              �ڳ�Ԥ�棨����ʱ������
        T.RLSAVINGBQ    = 0 - T.RLSAVINGBQ, --����              ����Ԥ�淢��������ʱ������
        T.RLSAVINGQM    = T.RLSAVINGQC + nvl(mi.misaving,0), --����              ��ĩԤ�棨����ʱ������
        T.RLREVERSEFLAG = 'Y', --Y                   ������־��NΪ������YΪ������
        t.rlilid        =null ,--��Ʊ��ˮ��
        t.rlmisaving    = 0,--���ʱԤ��
        t.rlpriorje     = 0,--���֮ǰǷ��
        T.RLSXF         = 0 - T.RLSXF;*\

    --����ʱӦ���ʸ�����
    V_CALL := F_SET_CR_RECLIST(PM);

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 13;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S);

    ---��Ӧ����ϸ��ʱ����������¼�ĵ���
    V_STEP    := 14;
    V_PRC_MSG := '��Ӧ����ϸ��ʱ����������¼�ĵ���';

    --һ���ֶε���
    UPDATE RECDETAIL_TMP T
       SET T.RDYSSL  = 0 - T.RDYSSL,
           T.RDYSJE  = 0 - T.RDYSJE,
           T.RDSL    = 0 - T.RDSL,
           T.RDJE    = 0 - T.RDJE,
           T.RDADJSL = 0 - T.RDADJSL,
           T.RDADJJE = 0 - T.RDADJJE,
           T.RDZNJ   = 0 - T.RDZNJ;
    --��ˮid����
    UPDATE RECDETAIL_TMP T
       SET T.RDID =
           (SELECT S.RLID
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��

    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);
 

    -----END OF  STEP 10: ���Ӹ�Ӧ�ռ�¼�������---------------------------------------

    -----STEP 20: ������Ӧ�ռ�¼--------------------------------------------------------------
    ------����ʱ���д����Ҫ���������Ӧ�����˺���ϸ�ʼ�¼
    ---�������ʱ��
    DELETE RECLIST_1METER_TMP;
    DELETE RECDETAIL_TMP;

    ---������Ҫ���������Ӧ�����˼�¼
    V_STEP    := 20;
    V_PRC_MSG := '������Ҫ���������Ӧ�����˼�¼';
    INSERT INTO RECLIST_1METER_TMP T
      SELECT S.*
        FROM RECLIST S
       WHERE S.RLPID = P_PAYID
         AND S.RLPAIDFLAG = 'Y';

    ---������Ҫ���������Ӧ����ϸ�ʼ�¼
    V_STEP    := 21;
    V_PRC_MSG := '������Ҫ���������Ӧ����ϸ�ʼ�¼';
    INSERT INTO RECDETAIL_TMP T
      (SELECT A.*
         FROM RECDETAIL A, RECLIST_1METER_TMP B
        WHERE A.RDID = B.RLID);

    ---��Ӧ��������ʱ����������¼�ĵ���
    V_STEP    := 22;
    V_PRC_MSG := '��Ӧ��������ʱ����������¼�ĵ���';
    UPDATE RECLIST_1METER_TMP T
       SET T.RLID    = FGETSEQUENCE('RECLIST'), --������
           T.RLMONTH = TOOLS.FGETRECMONTH(MI.MISMFID), --��ǰ              �����·�
           T.RLDATE  = TOOLS.FGETRECDATE(MI.MISMFID), --��ǰ              ��������
           \*           T.RLMONTH       = PM.PMONTH, --��ǰ
           T.RLDATE        = PM.PDATE, --��ǰ*\
           --T.RLCHARGEPER   = '', --��

           T.RLCOLUMN5  = T.RLDATE, --�ϴ�Ӧ��������
           T.RLCOLUMN9  = T.RLID, --�ϴ�Ӧ������ˮ
           T.RLCOLUMN10 = T.RLMONTH, --�ϴ�Ӧ�����·�
           T.RLCOLUMN11 = T.RLTRANS, --�ϴ�Ӧ��������

           \*           T.RLSCRRLID     = T.RLID, --ԭ��¼.RLID
           T.RLSCRRLTRANS  = T.RLTRANS, --ԭ��¼.RLTRANS
           T.RLSCRRLMONTH  = T.RLMONTH, --ԭ��¼.RLMONTH*\
           T.RLPAIDFLAG = 'N', --N
           T.RLPAIDPER  = '', --��
           T.RLPAIDDATE = '', --��
           T.RLDATETIME = SYSDATE, --SYSDATE
           \*           T.RLSCRRLDATE   = T.RLDATE, --ԭ��¼.RLDATE*\
           T.RLPID         = NULL, --��
           T.RLPBATCH      = NULL, --��
           T.RLSAVINGQC    = 0, --��
           T.RLSAVINGBQ    = 0, --��
           T.RLSAVINGQM    = 0, --��
           T.RLREVERSEFLAG = 'N',
           T.RLPAIDJE      = 0,
           T.RLSXF         = 0, --������
           T.RLZNJ         = 0, --ΥԼ��
           T.RLOUTFLAG     = 'N'; --N

    --��Ӧ�ճ�������¼���뵽Ӧ��������
    V_STEP    := 23;
    V_PRC_MSG := '��Ӧ�ճ�������¼���뵽Ӧ��������';

    INSERT INTO RECLIST T (SELECT S.* FROM RECLIST_1METER_TMP S); 

    --���߼����˷�
    INSERT INTO RECLISTTEMPCZ
      (SELECT S.RLID, RLCOLUMN9 FROM RECLIST_1METER_TMP S);

    ---��Ӧ����ϸ��ʱ����������¼�ĵ���
    V_STEP    := 14;
    V_PRC_MSG := '��Ӧ����ϸ��ʱ����������¼�ĵ���';

    UPDATE RECDETAIL_TMP T
       SET (T.RDID,
            T.RDPAIDFLAG,
            T.RDPAIDDATE,
            T.RDPAIDMONTH,
            T.RDPAIDPER,
            T.RDMONTH,
            T.RDZNJ) =
           (SELECT S.RLID, 'N', NULL, NULL, NULL, S.RLMONTH, 0
              FROM RECLIST_1METER_TMP S
             WHERE T.RDID = S.RLCOLUMN9)
     WHERE T.RDID IN (SELECT RLCOLUMN9 FROM RECLIST_1METER_TMP);
    --���뵽Ӧ����ϸ��
    INSERT INTO RECDETAIL T (SELECT S.* FROM RECDETAIL_TMP S);
    --add 2013.02.01 ��reclist_charge_01���в�����Ӧ�ռ�¼
    \*   for  i in (SELECT S.RDID FROM RECDETAIL_TMP S)
     LOOP
      sp_reclist_charge_01(i.RDID ,'1');
    END LOOP;*\
    --add 2013.02.01
    ----END OF STEP 20: ������Ӧ�ռ�¼  ������� ------------------------------------------
    ----STEP 30 ԭӦ�ռ�¼��������
    V_STEP    := 30;
    V_PRC_MSG := 'ԭӦ�ռ�¼��������';
    UPDATE RECLIST T
       SET T.RLREVERSEFLAG = 'Y'

     WHERE T.RLPID = P_PAYID
       AND T.RLPAIDFLAG = 'Y';
    --END OF  Ӧ���˴������--------------------------------------------------------------

    --STEP 40 ˮ������Ԥ��������--------------------------------------------------------------
    V_STEP    := 40;
    V_PRC_MSG := 'ˮ������Ԥ��������';
    UPDATE METERINFO T
       SET T.MISAVING = PM.PSAVINGQM, T.MIPAYMENTID = P_PAYID
     WHERE T.MIID = PM.PMID;
    -- END OF STEP 40 ˮ������Ԥ��������------------------------------------------------------------

    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
    RETURN '000';

  EXCEPTION
    WHEN OTHERS THEN
      RETURN '999';
  END;
*/
BEGIN
  NULL;

END;
/

