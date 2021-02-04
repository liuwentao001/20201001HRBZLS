CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECINVSEARCH" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      SELECT
           MAX(rlmid) ˮ����                                                                        ,--ˮ����                   C1
            MAX(rlmcode) �ͻ�����                                                                      ,--���Ϻ�                     C2
            MAX(rlcid) �û����                                                                        ,--�û����                   C3
            max(RLCCODE) �û���                                                                      ,--�û���                       C4
            MAX(RLCNAME) �û���                                                                     ,--����                          C5
            MAX(RLCADR) �û���ַ                                                                       ,--�û���ַ                   C6
            MAX(RLMADR)    ˮ���ַ                                                                    ,--ˮ��װ��ַ               C7
            MAX(RLBFID ) ˮ�۱��                                                                      ,--����                     C8
            '��������'   ��������                                                                ,--��������                     C9
            MAX(rlscode) ��������                                                                      ,--��������                   C10
            MAX(rlecode) ����ֹ��                                                                      ,--����ֹ��                   C11
            MAX(RLREADSL ) ����ˮ��                                                                    ,--����ˮ��                   C12
            MAX(RLSL ) Ӧ��ˮ��                                                                         ,--Ӧ��ˮ��       C13
            fGetUnitPrice(rlid)  Ӧ�յ���         ,--Ӧ�յ���                    C14
            fGetUnitMoney(rlid)                          Ӧ�ս��                           ,--Ӧ�ս��                    C15
            max(RLADDSL) ����                                                                      ,--����                           C16
            '��������'        ���ɽ�                                                           ,--���ɽ�                             C17
            '��������'        ������                                                           ,--������                             C18
            to_char(max(RLPRDATE),'yyyy-mm-dd'  )          ���ڳ�������                                   ,--���ڳ�������            C19
            to_char(max(RLRDATE),'yyyy-mm-dd'  )          ��������                                    ,--��������                    C20
            to_char(max(RLDATE),'yyyy-mm-dd'  )           ��������                                    ,--��������                    C21
            '��������'                        �����·�                                           ,--�����·�                         C22
            max(RLMONTH)     �����·�                                                                  ,--�����·�                   C23
            to_char(SYSDATE,'yyyy-mm-dd'  )              ��ӡ����                                ,--��ӡ����                         C24
            fGetOperName(max(c8))                            ��ӡԱ                                 ,--��ӡԱ                        C25
            fGetOperName(max(RLCHARGEPER))                �շ�Ա                                    ,--�շ�Ա                        C26
            '��  '||tools.fuppernumber(to_number(fGetRecZnjMoney(rlid)))             �ϼƽ���д                               ,--�ϼƽ���д             C27
            '��'||fGetRecZnjMoney(rlid)                      �ϼƽ��2                               ,--�ϼƽ��2              C28
            FGETSYSCHARGETYPE(max(RLYSCHARGETYPE)) �շѷ�ʽ                             ,--�շѷ�ʽ                 c89              C29
            fGetPriceText(rlid) ˮ����ϸ1                             ,--ˮ����ϸ1                       C30
            'pg_recinv.getinvdetail(rlid,''2'',''ALLPI'')'  ˮ����ϸ2                            ,--ˮ����ϸ2                        C31
            '��������'          ˮ����ϸ3                                                          ,--ˮ����ϸ3                      C32
            '��������'          Ԥ�淢����ϸ                                                         ,--Ԥ�淢����ϸ                 C33
            to_char(sysdate ,'yyyy') ϵͳʱ����                                               ,--ϵͳʱ����                          C34
            to_char(sysdate ,'mm') ϵͳʱ����                                                  ,--ϵͳʱ����                         C35
            to_char(sysdate ,'dd') ϵͳʱ����                                                  ,--ϵͳʱ����                         C36
            'Ӧ���ֽ� '||fGetRecZnjMoney(rlid)                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            '��������'                                                                   ,--�û�Ԥ���ֶ�5                            C38
            '��������'                                                                   ,--�û�Ԥ���ֶ�6                            C39
            '��������'                                                                   ,--�û�Ԥ���ֶ�7                            C40
            '��������'                                                                   ,--�û�Ԥ���ֶ�8                            C41
            '��������'                                                                   ,--�û�Ԥ���ֶ�9                            C42
            '��������'                                                                   ,--�û�Ԥ���ֶ�10                           C43
            '��������'                                                                   ,--�û�Ԥ���ֶ�11                           C44
            '��������'                                                                   ,--�û�Ԥ���ֶ�12                           C45
            '��������'                                                                   ,--�û�Ԥ���ֶ�13                           C46
            '��������'                                                                   ,--�û�Ԥ���ֶ�14                           C47
            '��������'                                                                   ,--�û�Ԥ���ֶ�15                           C48
            '��������'                                                                   ,--�û�Ԥ���ֶ�16                           C49
            '��������'                                                                   ,--�û�Ԥ���ֶ�17                           C50
            RLID                                                                         ,--Ӧ������ˮ��                             C51
            '������Ŀ' ������Ŀ                                             ,--������Ŀ                                              C52
            max(c8)                                                                           ,--��ӡԱ���                          C53
            max(RLCHARGEPER) �շ�Ա���                                                                 ,--�շ�Ա���                C54
            max(c9) ���                                                                           ,--���                           C55
            '��������'                                                                   ,--ϵͳԤ���ֶ�6                            C56
            '��������'                                                                   ,--ϵͳԤ���ֶ�7                            C57
            '��������'                                                                   ,--ϵͳԤ���ֶ�8                            C58
            '��������'                                                                   ,--ϵͳԤ���ֶ�9                            C59
            '��������'                                                                   --ϵͳԤ���ֶ�10                            C60
       from reclist, recdetail ,pbparmtemp
  WHERE RLID=RDID
  and rlid=c1
  and instr(c5 , rdpiid ) >0
  --AND RLID='0000107301'
  GROUP BY RLID
order by max(c9)
    ;

  end ;
/

