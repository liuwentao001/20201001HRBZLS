CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECLISTCR" (
                  o_base out tools.out_base) is
  begin
    --�°淢Ʊ(��̨�ɷ�)
    open o_base for
            select
            max(rlmcode)                                                           C1              ,--���Ϻ�                  C1
            max(rlcname )                                                           C2              ,--����                    C2
            max(rlcadr )                                                            C3              ,--�û���ַ                C3
            min(rlscode )                                                           C4              ,--��������                C4
            max(rlecode )                                                           C5              ,--����ֹ��                C5
            max(rlsl)                                                           C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX(c2))                                                   C8              ,--��ӡԱ                  C8
            fGetOperName(max('δ��'))                                          C9              ,--�շ�Ա                  C9
           '��  '||(case when max(rLCD)='DE' then tools.fuppernumber(tools.fformatnum(max(rlje),2)) else  tools.fuppernumber((tools.fformatnum(max(rlje),2))*-1)   end )                 C10             ,--�ϼƽ���д            C10
            '��'||(case when max(rLCD)='DE' then tools.fformatnum(tools.fformatnum(max(rlje),2) ,2) else  tools.fformatnum((tools.fformatnum(max(rlje),2))*-1 ,2) end  )                  C11             ,--�ϼƽ��                C11
           --  '��  '|| tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ))                  C10             ,--�ϼƽ���д            C10
           -- '��'||tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                   C11             ,--�ϼƽ��                C11
            ''               C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            ''                                                           C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            to_char(sysdate ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            max(rlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ��װ��ַ            C24
            max(RLBFID)                                                         C25             ,--����                  C25
            max(RLRPER)                                                         C26             ,--����Ա              C26
            to_char(max(RLDATE),'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            fGetUnitPrice_mx(max(rlid),'01,02,03,04|',4)                                                   C28             ,--Ӧ�յ���                C28
            tools.fformatnum(max(rlje),2)                                      C29             ,--ˮ�ѽ��                C29
            '��������'                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33
            '�ϴ�����:'||tools.fformatnum(max(misaving),2)                                                        C34             ,--��������  (�ϴν���)             C34
            '��������:'||tools.fformatnum(max(misaving),2)                                                        C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            'Ӧ���ֽ� '||tools.fformatnum(max(rlje),2)                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
           '��������'                                                         C42             ,--��ע           C42
            'Ӧ�����ɽ�:'||tools.fformatnum(max(0),2)                                                       C43             ,--Ӧ�����ɽ�3           C43
            'ʵ�����ɽ�:'||tools.fformatnum(max(0),2)                                                         C44             ,--ʵ�����ɽ�4           C44
            'Ӧ��ˮ��:'||tools.fformatnum(max(rlje),2)                                                         C45             ,--Ӧ��ˮ��5           C45
            'ʵ��ˮ��:'||tools.fformatnum(max(rlje),2)                                                         C46             ,--ʵ��ˮ��6           C46
            case when max(rlcd)='DE' then '' else '���Ʊ' end                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX(c2)                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա              C54
            MAX(c3)                                                                 C55             ,--���                    C55
            max(rlcd )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            ''                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            ''                                                         C60              --ϵͳԤ���ֶ�5           C60
     from reclist,recdetail,meterinfo,  pbparmtemp
   where rlid=rdid and
         miid=rlmid and
         rlid = C1
         group by rlid;
  end ;
/

