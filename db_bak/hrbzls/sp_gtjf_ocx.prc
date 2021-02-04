CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJF_OCX" (p_pbatch    in varchar2, --ʵ������
                        P_PID       IN varchar2, --ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
                        p_plid      in varchar2, --ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
                        p_modelno   in varchar2, --��Ʊ��ʽ��:2/25
                        p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
                        p_ifbd      in varchar2, --�Ƿ񲹴� --��:Y,��:N
                        P_PRINTER   IN VARCHAR2 --��ӡԱ
                        ) is
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
             (select pthpaperheight || '^' || pthpaperwidth || '^' ||
                     lastpage || '^' || 1 || '|' constructhd
                from printtemplatehd t1
               where pthid = p_modelno --2
              ) c;

    cursor c_dt is
      select max(pmcode) C1, --���Ϻ�                  C1
             max(rlcname) C2, --����                    C2
             max(rlcadr) C3, --�û���ַ                C3
             to_char(max(rlscode)) C4, --��������                C4
             to_char(max(rlecode)) C5, --����ֹ��                C5
             '������λ��' ||to_char(sum(rlsl)) C6, --Ӧ��ˮ��                C6
             to_char(sysdate, 'yyyy-mm-dd') C7, --��ӡ����                C7
             fgetopername('1146') C8, --��ӡԱ                  C8
             max(pper) C9, --�շ�Ա                  C9
             '��' || '    ' ||tools.fuppernumber(sum(�ϼƽ���д)) C10, --�ϼƽ���д        C10
             '��' ||to_number(sum(�ϼƽ��Сд)) C11, --�ϼƽ��Сд                C11
             fgetopername(max(��ƱԱ)) C12, --��ƱԱ               C12
             max(����) C13, --����               C13
             '������' || '' C14, --�������              C14
             '' C15, --ϵͳʱ����              C15
             '' C16, --ϵͳʱ����              C16
             '' C17, ----�ɷѽ�������,ϵͳʱ����           C17
             '' C18, ----ʵ������ϸ��ˮ��      C18
             '' C19, --������ˮ��ˮ��          C19
             '' C20, --Ʊ������ /*Ʊ������*/   C20
             '' C21, --ˮ����                C21
             '' C22, --�û����                C22
             max(��������) ��������, --��������                  C23
             '' C24, --ˮ��װ��ַ            C24
             '' C25, --����                  C25
             max(����Ա) C26, --����Ա              C26
             '' C27, --�ƾ�����                C27
             '' C28, --Ӧ�յ���                C28
             '' C29, --ˮ�ѽ��                C29
             '' C30, --����                    C30
             '���ɽ�' ||sum(plznj) C31, --���ɽ�                  C31
             '' C32, --������                  C32
             '' C33, --���ڳ�������    �����ν�Ǯ��        C33
             max(�ϴν��� ) C34, -- �ϴν���           C34
             max(���ν���) C35, --���ν���             C35
             '��ˮ���' ||max(��ˮ���)   C36, --��ˮ���                C36
             'Ӧ��С�ƣ�' ||sum(Ӧ��С��) C37, --Ӧ��С��                          C37
             '' C38, --�շѷ�ʽ                C38
             '' C39, --ˮ����ϸ3               C39
             '' C40, --Ԥ�淢����ϸ            C40
             '' C41, --Ӧ�ս���д           C41
             '' C42, --��ע           C42
             '' C43, --Ӧ�����ɽ�3           C43
             '' C44, --ʵ�����ɽ�4           C44
             '' C45, --Ӧ��ˮ��5           C45
             '' C46, --ʵ��ˮ��6           C46
             '��ˮ��:' ||max(����ˮ�ѵ���) C47, --����ˮ�ѵ��� C47
             '' C48, --�û�Ԥ���ֶ�8           C48
             '' C49, --�û�Ԥ���ֶ�9           C49
             '' C50, --�û�Ԥ���ֶ�10          C50
             '' C51, --�û�Ԥ���ֶ�10         C51
             '��ˮ��:' ||tools.fformatnum(sum(��ˮ��),
                              2) C52, --����ˮ�� C52
             '�������ӷѣ�' ||tools.fformatnum(sum(�������ӷ�),
                              2) C53, --���ӷ�  C53
             '������ˮ����ѣ�' ||tools.fformatnum(sum(������ˮ�����),
                              2) C54, --��ˮ��  C54
             '' C55, --�����                    C55
             tools.fformatnum(sum(������),  2) C56, --������
             '�����ѣ�' ||min(�������·�) || '��' || max(�������·�2) C57, --�������·�           C57
             '' C58, --ϵͳԤ���ֶ�3           C58
             '' C59, --ϵͳԤ���ֶ�4           C59
             '.' C60 --ϵͳԤ���ֶ�5           C60

        from
(select rlnum,
             max(pmcode) pmcode  , --���Ϻ�                  C1
             max(rlcname) rlcname, --����                    C2
             max(rlcadr) rlcadr, --�û���ַ                C3
             to_char(max(t3.rlscode)) rlscode, --��������                C4
             to_char(max(t3.rlecode)) rlecode, --����ֹ��                C5
             max(t3.rlsl) rlsl, --Ӧ��ˮ��                C6

             fgetopername('1146') C8, --��ӡԱ                  C8
             fgetopername(max(pper)) pper, --�շ�Ա                  C9
             (max(decode(rlgroup,'1',ppayment-pchange,0))+max(decode(rlgroup,'2',ppayment-pchange,0)))  �ϼƽ���д, --�ϼƽ���д        C10
             max(decode(rlgroup,'1',ppayment-pchange,0))+max(decode(rlgroup,'2',ppayment-pchange,0)) �ϼƽ��Сд, --�ϼƽ��Сд                C11
             fgetopername(max(pper)) ��ƱԱ, --��ƱԱ               C12
             max(case
                   when length(t4.mdmodel) <> 1 then
                    FGETMETERTYPE(substr(t4.mdmodel, 2, 1))
                   else
                    FGETMETERTYPE(t4.mdmodel)
                 end) ����, --����               C13
             '������' || ''  �������, --�������              C14

             max(to_char(rldate, 'YYYY-MM-DD')) ��������, --��������                  C23

             max(fgetopername(RLRPER)) ����Ա, --����Ա              C26

              max(plznj) plznj, --���ɽ�                  C31
             max(case when psavingbq <>0 then  psavingqc else 0 end ) �ϴν���, -- �ϴν���           C34
             max(case when psavingbq <>0 then  psavingqm else 0 end ) ���ν���, --���ν���             C35
             '��ˮ���' ||(case when max(MIIFMP)='N' then max(FGETPRICEFRAME_jh(rlpfid)) else '�����ˮ' end) ��ˮ���, --��ˮ���                C36
             max(rlje) Ӧ��С��, --Ӧ��С��                          C37

             '��ˮ��:' ||(case when max(MIIFMP)='N' then tools.fformatnum(sum(case
                                    when pdpiid = '01' then
                                     pddj
                                  end),
                              2) else '����ˮ��' end) ����ˮ�ѵ���, --����ˮ�ѵ��� C47

             sum(case
                                    when pdpiid = '01' then
                                     pdje
                                  end) ��ˮ��, --����ˮ�� C52
             sum(case
                                    when pdpiid = '03' then
                                     pdje
                                  end) �������ӷ�, --���ӷ�  C53
             sum(case
                                    when pdpiid = '02' then
                                     pdje
                                  end) ������ˮ�����, --��ˮ��  C54

             sum(case
                                    when pdpiid = '04' then
                                     pdje
                                  end)  ������, --������
             min(to_char(rlprdate,'YYYY.MM')) �������·�, --�������·�           C57
             max(to_char(rlrdate,'YYYY.MM')) �������·�2, --ϵͳԤ���ֶ�3           C58
             rlmonth ,
             rlmcode,
              pbatch
        from payment t, paidlist t1, paiddetail t2, reclist_print t3, meterdoc t4,meterinfo t5
       where pid = plpid
         and plid = pdid
         and rlid = plrlid
         and rlmid = mdmid
         and miid = rlmid
         and pbatch = p_pbatch
       group by pbatch, rlmcode, rlmonth, RLMRID,t3.rlnum
       )  group by rlnum
      order by  max(pbatch), max(rlmcode), max(rlmonth)
       ;

  begin

sp_gtjf_ocx_rl(p_pbatch   , --ʵ������
                        P_PID  , --ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
                        p_plid   , --ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
                        p_modelno  , --��Ʊ��ʽ��:2/25
                        p_printtype  , --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
                        p_ifbd      , --�Ƿ񲹴� --��:Y,��:N
                        P_PRINTER    --��ӡԱ
                        )  ;


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
      INSERT INTO PRINTLISTTEMP VALUES (I, v_tempstr); /*
                              INSERT INTO Printlisttemp_New VALUE select * from PRINTLISTTEMP;*/
    end loop;
    close c_dt;

    v_hd := trim(to_char(lengthb(v_constructhd || v_constructdt),
                         '0000000000')) ||
            trim(to_char(lengthb(v_contentstrorder) + v_conlen,
                         '0000000000')) || v_constructhd || v_constructdt ||
            v_contentstrorder;
    INSERT INTO PRINTLISTTEMP VALUES (1, v_hd);

  end;
/

