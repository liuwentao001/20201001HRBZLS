CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHARGEINVSEARCHHP_NEWHZ" (
                  o_base out tools.out_base) is
  begin
    --�°淢Ʊ(��̨�ɷ�)
    open o_base for
    select
                MAX(C1 ) C1 ,
MAX(C2 ) C2 ,
MAX(C3 ) C3 ,
MAX(C4 ) C4 ,
MAX(C5 ) C5 ,
MAX(C6 ) C6 ,
MAX(C7 ) C7 ,
MAX(C8 ) C8 ,
MAX(C9 ) C9 ,
'��  '|| tools.fuppernumber(SUM(C10)) C10,
'��'||tools.fformatnum(SUM(C11),2) C11,
MAX(C12) C12,
MAX(C13) C13,
MAX(C14) C14,
MAX(C15) C15,
MAX(C16) C16,
MAX(C17) C17,
MAX(C18) C18,
MAX(C19) C19,
MAX(C20) C20,
MAX(C21) C21,
MAX(C22) C22,
MAX(C23) C23,
MAX(C24) C24,
MAX(C25) C25,
MAX(C26) C26,
MAX(C27) C27,
MAX(C28) C28,
MAX(C29) C29,
MAX(C30) C30,
MAX(C31) C31,
MAX(C32) C32,
MAX(C33) C33,
MAX(C34) C34,
'���ν��� '||tools.fformatnum(SUM(C35),2) C35,
MAX(C36) C36,
MAX(C37) C37,
MAX(C38) C38,
MAX(C39) C39,
MAX(C40) C40,
MAX(C41) C41,
MAX(C42) C42,
MAX(C43) C43,
MAX(C44) C44,
MAX(C45) C45,
MAX(C46) C46,
MAX(C47) C47,
MAX(C48) C48,
MAX(C49) C49,
MAX(C50) C50,
MAX(C51) C51,
MAX(C52) C52,
MAX(C53) C53,
MAX(C54) C54,
MAX(C55) C55,
MAX(C56) C56,
MAX(C57) C57,
MAX(C58) C58,
MAX(C59) C59,
MAX(C60) C60
         FROM (
              select
            max(rlmcode)                                                           C1              ,--���Ϻ�                  C1
            max(rlcname )                                                           C2              ,--����                    C2
            max(rlcadr )                                                            C3              ,--�û���ַ                C3
            min(rlscode )                                                           C4              ,--��������                C4
            max(rlecode )                                                           C5              ,--����ֹ��                C5
            sum(decode(pdpiid,'01',pdsl,0))                                                           C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX(c2))                                                   C8              ,--��ӡԱ                  C8
            fGetOperName(max(ppayee))                                          C9              ,--�շ�Ա                  C9
           sum(pdje)+sum(pdznj)+max(PSAVINGBQ )                    C10             ,--�ϼƽ���д            C10
           sum(pdje)+sum(pdznj)+max(PSAVINGBQ )                    C11             ,--�ϼƽ��                C11
            fGetPriceText_gt(pid)                C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������          C17
            ''                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            ''                                                         C21             ,--ˮ����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            max(plrlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ��װ��ַ            C24
            ''                                                         C25             ,--����                  C25
            ''                                                         C26             ,--��������              C26
            ''                                                         C27             ,--����ˮ��                C27
            fGetUnitPrice_gt(pid)                                                           C28             ,--Ӧ�յ���                C28
            fGetUnitMoney_gt(pid)                                      C29             ,--Ӧ�ս��                C29
            ''                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33
            '�ϴν��� '||tools.fformatnum(max(psavingqc),2)                                                        C34             ,--��������  (�ϴν���)             C34
            max(psavingqm)                                                      C35             ,--�������� (���ν���)               C35
            ''                                                         C36             ,--�����·�                C36
            'Ӧ���ֽ� '||fGetRecZnjMoney_gt(pid)                 C37                                                  ,--�ϼ�Ӧ��1                            C37
            ''                                                         C38             ,--�շѷ�ʽ                C38
            ''                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
           ''                                                         C42             ,--�û�Ԥ���ֶ�2           C42
            ''                                                       C43             ,--�û�Ԥ���ֶ�3           C43
            ''                                                         C44             ,--�û�Ԥ���ֶ�4           C44
            ''                                                         C45             ,--�û�Ԥ���ֶ�5           C45
            ''                                                         C46             ,--�û�Ԥ���ֶ�6           C46
            ''                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX(c2)                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            '.'                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX(c3)                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            MAX(PID)                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment,paidlist,paiddetail,reclist ,  pbparmtemp
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         plpid = C1
         group by pid
       having sum(pdje)+sum(pdznj)+max(PSAVINGBQ )>0

UNION
select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--���Ϻ�                  C1
            max(ciname )                                                           C2              ,--����                    C2
            max(ciadr )                                                            C3              ,--�û���ַ                C3
            case when 0=0 then null else 0 end                                                           C4              ,--��������                C4
            case when 0=0 then null else 0 end                                                            C5              ,--����ֹ��                C5
            case when 0=0 then null else 0 end                                                            C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX(c2))                                                   C8              ,--��ӡԱ                  C8
            fGetOperName(max(ppayee))                                          C9              ,--�շ�Ա                  C9
           sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))                   C10             ,--�ϼƽ���д            C10
           sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))                   C11             ,--�ϼƽ��                C11
            ''                C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������          C17
            ''                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            ''                                                         C24             ,--ˮ��װ��ַ            C24
            '��������'                                                         C25             ,--����                  C25
            '��������'                                                         C26             ,--��������              C26
            '��������'                                                         C27             ,--����ˮ��                C27
            ''                                                           C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--Ӧ�ս��                C29
            '��������'                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33 '�ϴν��� '||tools.fformatnum(max(PSAVINGQC),2)
            ''                                                        C34             ,--��������  (�ϴν���)  '���ν��� '||tools.fformatnum(max(PSAVINGQM),2)            C34
            sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))                                                       C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            ''                 C37                                                  ,--�ϼ�Ӧ��1                            C37
            '��������'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
           ''                                                         C42             ,--�û�Ԥ���ֶ�2           C42
            ''                                                       C43             ,--�û�Ԥ���ֶ�3           C43
            ''                                                         C44             ,--�û�Ԥ���ֶ�4           C44
            ''                                                         C45             ,--�û�Ԥ���ֶ�5           C45
            ''                                                         C46             ,--�û�Ԥ���ֶ�6           C46
            ''                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX(c2)                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            '.'                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX(c3)                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            MAX(PID)                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment ,  pbparmtemp,custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
         pid = C1 and
         PTRANS ='S'
         group by PBATCH
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))>0
ORDER BY C60 )
GROUP BY C1
 ;

  end ;
/

