CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSPZPRINT_OCX" (p_modelno in varchar2) is
  v_constructhd     varchar2(30000);
  v_constructdt     varchar2(30000);
  v_contentstrorder varchar2(30000);
  v_hd              varchar2(30000);
  v_tempstr         varchar2(30000);
  v_conlen          number(10);
  I                 NUMBER(10);
  V_C1              VARCHAR2(3000);
  V_C2              VARCHAR2(3000);
  V_C3              VARCHAR2(3000);
  V_C4              VARCHAR2(3000);
  V_C5              VARCHAR2(3000);
  V_C6              VARCHAR2(3000);
  V_C7              VARCHAR2(3000);
  V_C8              VARCHAR2(3000);
  V_C9              VARCHAR2(3000);
  V_C10             VARCHAR2(3000);
  V_C11             VARCHAR2(3000);
  V_C12             VARCHAR2(3000);
  V_C13             VARCHAR2(3000);
  V_C14             VARCHAR2(3000);
  V_C15             VARCHAR2(3000);
  V_C16             VARCHAR2(3000);
  V_C17             VARCHAR2(3000);
  V_C18             VARCHAR2(3000);
  V_C19             VARCHAR2(3000);
  V_C20             VARCHAR2(3000);
  V_C21             VARCHAR2(3000);
  V_C22             VARCHAR2(3000);
  V_C23             VARCHAR2(3000);
  V_C24             VARCHAR2(3000);
  V_C25             VARCHAR2(3000);
  V_C26             VARCHAR2(3000);
  V_C27             VARCHAR2(3000);
  V_C28             VARCHAR2(3000);
  V_C29             VARCHAR2(3000);
  V_C30             VARCHAR2(3000);
  V_C31             VARCHAR2(3000);
  V_C32             VARCHAR2(3000);
  V_C33             VARCHAR2(3000);
  V_C34             VARCHAR2(3000);
  V_C35             VARCHAR2(3000);
  V_C36             VARCHAR2(3000);
  V_C37             VARCHAR2(3000);
  V_C38             VARCHAR2(3000);
  V_C39             VARCHAR2(3000);
  V_C40             VARCHAR2(3000);
  V_C41             VARCHAR2(3000);
  V_C42             VARCHAR2(3000);
  V_C43             VARCHAR2(3000);
  V_C44             VARCHAR2(3000);
  V_C45             VARCHAR2(3000);
  V_C46             VARCHAR2(3000);
  V_C47             VARCHAR2(3000);
  V_C48             VARCHAR2(3000);
  V_C49             VARCHAR2(3000);
  V_C50             VARCHAR2(3000);
  V_C51             VARCHAR2(3000);
  V_C52             VARCHAR2(3000);
  V_C53             VARCHAR2(3000);
  V_C54             VARCHAR2(3000);
  V_C55             VARCHAR2(3000);
  V_C56             VARCHAR2(3000);
  V_C57             VARCHAR2(3000);
  V_C58             VARCHAR2(3000);
  V_C59             VARCHAR2(3000);
  V_C60             VARCHAR2(3000);
  cursor c_hd is
    select constructhd, constructdt, contentstrorder
      from (select replace(connstr(trim(t.ptditemno) || '^' ||
                                   trim(round(t.ptdx)) || '^' ||
                                   trim(round(t.ptdy)) || '^' ||
                                   trim(round(t.ptdheight)) || '^' ||
                                   trim(round(t.ptdwidth)) || '^' ||
                                   trim(t.ptdfontname) || '^' ||
                                   trim(t.ptdfontsize * -1) || '^' ||
                                   trim(ftransformaling(t.ptdfontalign)) || '|'),
                           '|/',
                           '|') constructdt,
                   replace(connstr(trim(t.ptditemno)), '/', '^') || '|' contentstrorder
              from printtemplatedt_str t
             where ptdid = p_modelno
            --2
            ) b,
           (select pthpaperheight || '^' || pthpaperwidth || '^' || lastpage || '^' || 1 || '|' constructhd
              from printtemplatehd t1
             where pthid = p_modelno --2
            ) c;

  cursor c_dt is

    select etlbatch C1, --�������κ�
           etlmiuiid C2, --����ƾ֤��
           to_char(eloutdate, 'yyyy') || '   ' || to_char(eloutdate, 'mm') ||
           '   ' || to_char(eloutdate, 'dd') C3, --��������
           etlaccountname C4, --|| etlaccountname C4,--�û�������
           etlaccountno C5, --�ʺ�
           etlbankidname C6, --������
           etlbankidno C7, --������ʵ���к�
           etltsaccountname /*fpara(etltsbankid,'HM')*/ C8, --�տ����
           etltsaccountno /*fpara(etltsbankid,'ZH')*/ C9, --�տ���ʺ�
           etltsbankidno C10, --�տ��к�,
           etlbankid C11, --�û�������ϵͳ���
           etltsbankid C12, --��˾������ϵͳ���
           c2 C13, --��ӡԱ���
           fgetopername(c2) C14, --��ӡԱ����
           etlje C15, --�տ���
           tools.fuppernumber(round(etlje, 2)) C16, --��д
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  11,
                  1) C17, -- ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  10,
                  1) C18, -- ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  9,
                  1) C19, -- Ԫ,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  8,
                  1) C20, -- ʮ,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  7,
                  1) C21, -- ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  6,
                  1) C22, -- ǧ,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  5,
                  1) C23, -- ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  4,
                  1) C24, -- ʮ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  3,
                  1) C25, -- ����,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  2,
                  1) C26, -- ǧ��,
           substr(lpad('��' || trim(to_char(round(etlje, 2) * 100)),
                       12,
                       ' '),
                  1,
                  1) C27, -- ����Ҵ���,
           '     ' || etlinvcount C28, --��Ʊ����
           /*replace((case when length(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)))>=116
           then substr(connstr_like((case when instr( (ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)),1,116)||'��'
           else connstr_like((case when instr((ETLRLIDPIID),',02')>0 or instr((ETLRLIDPIID),'/02')>0 then 'P'||rlmcode else rlmcode end)) end),',','��')*/
           '' C29, --�ͻ���
           substr(max(etlrlmonth), 1, 4) || '��' ||
           substr(max(etlrlmonth), 6, 2) || '�·�ˮ��' C30, --Ԥ��1
           '' /*'30500000300201'||lpad(etlmiuiid,30,'0')*/ C31, --Ԥ��2
           '' /*case when    f_getljf(etlmiuiid,etlbatch)  <>0 then '������:    ��'||   tools.fformatnum( round(   f_getljf(etlmiuiid,etlbatch) ,2),2) else '' end*/ C32, --Ԥ��3
           'Ԥ��4' C33, --Ԥ��4
           'Ԥ��5' C34, --Ԥ��5
           'Ԥ��6' C35, --Ԥ��6
           'Ԥ��7' C36, --Ԥ��7
           1 C37, --Ԥ��8
           1 C38, --Ԥ��9
           1 C39, --Ԥ��11
           1 C40, --Ԥ��12
           1 C41, --Ԥ��13
           1 C42, --Ԥ��14
           1 C43, --Ԥ��15
           1 C44, --Ԥ��16
           1 C45, --Ԥ��17
           1 C46, --Ԥ��18
           1 C47, --Ԥ��19
           1 C48, --Ԥ��20
           1 C49, --Ԥ��21
           1 C50, --Ԥ��22
           1 C51, --Ԥ��23
           1 C52, --Ԥ��24
           1 C53, --Ԥ��25
           1 C54, --Ԥ��26
           1 C55, --Ԥ��27
           1 C56, --Ԥ��28
           1 C57, --Ԥ��29
           1 C58, --Ԥ��30
           1 C59, --Ԥ��31
           1 C60 --Ԥ��31
      from reclist t0, entrustlist t, entrustlog t1, pbparmtemp t2
     where
    --instr(ETLRLIDPIID, t0.rlid )>0
     t0.rlentrustseqno = etlseqno
     and t1.elbatch = t.etlbatch
     and c4 = etlseqno
     group by etlbatch,
              etlmiuiid,
              eloutdate,
              etlaccountname,
              etlaccountno,
              etlbankid,
              etlbankidname,
              etlbankidno,
              etltsbankidno,
              etltsbankid,
              etltsaccountno,
              etltsaccountname,
              c2,
              etlje,
              etlinvcount,
              c3
     order by to_number(etlmiuiid);
begin
  open c_hd;
  fetch c_hd
    into v_constructhd, v_constructdt, v_contentstrorder;
  null;
  close c_hd;

  I        := 1;
  v_conlen := 0;
  DELETE PRINTLISTTEMP;
  open c_dt;
  loop
    fetch c_dt
      into V_C1,
           V_C2,
           V_C3,
           V_C4,
           V_C5,
           V_C6,
           V_C7,
           V_C8,
           V_C9,
           V_C10,
           V_C11,
           V_C12,
           V_C13,
           V_C14,
           V_C15,
           V_C16,
           V_C17,
           V_C18,
           V_C19,
           V_C20,
           V_C21,
           V_C22,
           V_C23,
           V_C24,
           V_C25,
           V_C26,
           V_C27,
           V_C28,
           V_C29,
           V_C30,
           V_C31,
           V_C32,
           V_C33,
           V_C34,
           V_C35,
           V_C36,
           V_C37,
           V_C38,
           V_C39,
           V_C40,
           V_C41,
           V_C42,
           V_C43,
           V_C44,
           V_C45,
           V_C46,
           V_C47,
           V_C48,
           V_C49,
           V_C50,
           V_C51,
           V_C52,
           V_C53,
           V_C54,
           V_C55,
           V_C56,
           V_C57,
           V_C58,
           V_C59,
           V_C60;
    exit when c_dt%notfound or c_dt%notfound is null;
    select replace(connstr(trim(v_c1) || '^' || trim(v_c2) || '^' ||
                           trim(v_c3) || '^' || trim(v_c4) || '^' ||
                           trim(v_c5) || '^' || trim(v_c6) || '^' ||
                           trim(v_c7) || '^' || trim(v_c8) || '^' ||
                           trim(v_c9) || '^' || trim(v_c10) || '^' ||
                           trim(v_c11) || '^' || trim(v_c12) || '^' ||
                           trim(v_c13) || '^' || trim(v_c14) || '^' ||
                           trim(v_c15) || '^' || trim(v_c16) || '^' ||
                           trim(v_c17) || '^' || trim(v_c18) || '^' ||
                           trim(v_c19) || '^' || trim(v_c20) || '^' ||
                           trim(v_c21) || '^' || trim(v_c22) || '^' ||
                           trim(v_c23) || '^' || trim(v_c24) || '^' ||
                           trim(v_c25) || '^' || trim(v_c26) || '^' ||
                           trim(v_c27) || '^' || trim(v_c28) || '^' ||
                           trim(v_c29) || '^' || trim(v_c30) || '^' ||
                           trim(v_c31) || '^' || trim(v_c32) || '^' ||
                           trim(v_c33) || '^' || trim(v_c34) || '^' ||
                           trim(v_c35) || '^' || trim(v_c36) || '^' ||
                           trim(v_c37) || '^' || trim(v_c38) || '^' ||
                           trim(v_c39) || '^' || trim(v_c40) || '^' ||
                           trim(v_c41) || '^' || trim(v_c42) || '^' ||
                           trim(v_c43) || '^' || trim(v_c44) || '^' ||
                           trim(v_c45) || '^' || trim(v_c46) || '^' ||
                           trim(v_c47) || '^' || trim(v_c48) || '^' ||
                           trim(v_c49) || '^' || trim(v_c50) || '^' ||
                           trim(v_c51) || '^' || trim(v_c52) || '^' ||
                           trim(v_c53) || '^' || trim(v_c54) || '^' ||
                           trim(v_c55) || '^' || trim(v_c56) || '^' ||
                           trim(v_c57) || '^' || trim(v_c58) || '^' ||
                           trim(v_c59) || '^' || trim(v_c60) || '|'),
                   '|/',
                   '|')
      into v_tempstr
      from dual;
    I        := I + 1;
    v_conlen := v_conlen + lengthb(v_tempstr);
    INSERT INTO PRINTLISTTEMP VALUES (I, v_tempstr);
  end loop;
  close c_dt;
  v_hd := trim(to_char(lengthb(v_constructhd || v_constructdt),
                       '0000000000')) ||
          trim(to_char(lengthb(v_contentstrorder) + v_conlen, '0000000000')) ||
          v_constructhd || v_constructdt || v_contentstrorder;
  INSERT INTO PRINTLISTTEMP VALUES (1, v_hd);

end;
/

