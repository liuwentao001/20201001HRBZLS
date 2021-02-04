CREATE OR REPLACE PROCEDURE HRBZLS."SP_CHARGEINVSEARCHHP_MISAING" (
                  o_base out tools.out_base) is
  begin
    --�°淢Ʊ(��̨�ɷ�)
    open o_base for
           select
            max(pmcode)                                                           C1              ,--���Ϻ�                  C1
            max(ciname )                                                           C2              ,--����                    C2
            max(ciadr )                                                            C3              ,--�û���ַ                C3
            ''                                                           C4              ,--��������                C4
            ''                                                           C5              ,--����ֹ��                C5
            ''                                                           C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX(c2))                                                   C8              ,--��ӡԱ                  C8
            fGetOperName(max(ppayee))                                          C9              ,--�շ�Ա                  C9
           '��  '||case when max(PCD)='DE' then tools.fuppernumber(sum(ppayment)-sum(pchange)) else tools.fuppernumber((sum(ppayment)-sum(pchange))*-1) end                     C10             ,--�ϼƽ���д            C10
            '��'||case when max(pcd)='DE' then tools.fformatnum(sum(ppayment)-sum(pchange) ,2) else tools.fformatnum((sum(ppayment)-sum(pchange))*-1 ,2)  end                   C11             ,--�ϼƽ��                C11
            ''                C12             ,--ˮ����ϸ1               C12
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
            ''                                                         C23             ,--Ӧ�����·�                  C23
            ''                                                         C24             ,--ˮ��װ��ַ            C24
            ''                                                         C25             ,--����                  C25
            ''                                                         C26             ,--��������              C26
            ''                                                         C27             ,--����ˮ��                C27
            ''                                                           C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--Ӧ�ս��                C29
            ''                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33
            '�ϴν��� '||tools.fformatnum(max(PSAVINGQC),2)                                                        C34             ,--��������  (�ϴν���)             C34
            '���ν��� '||tools.fformatnum(max(PSAVINGQM),2)                                                        C35             ,--�������� (���ν���)               C35
            ''                                                         C36             ,--�����·�                C36
            ''                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            ''                                                         C38             ,--�շѷ�ʽ                C38
            ''                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
           ''                                                         C42             ,--�û�Ԥ���ֶ�2           C42
            ''                                                       C43             ,--�û�Ԥ���ֶ�3           C43
            ''                                                         C44             ,--�û�Ԥ���ֶ�4           C44
            ''                                                         C45             ,--�û�Ԥ���ֶ�5           C45
            ''                                                         C46             ,--�û�Ԥ���ֶ�6           C46
            case when max(pcd)='DE' then '' else '���Ʊ' end                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX(c2)                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            '.'                                                                C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX(c3)                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            ''                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment,  pbparmtemp,custinfo
   where
         pcid=ciid and
         pid = C1
         group by pid

order by c3 ,pid
    ;

  end ;
/

