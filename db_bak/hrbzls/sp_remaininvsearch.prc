CREATE OR REPLACE PROCEDURE HRBZLS."SP_REMAININVSEARCH" (
                  o_base out tools.out_base) is
  begin

    open o_base for
select  pcid                                         C1  ,       --�û���                    C1
        pmid                                         C2  ,       --ˮ����                  C2
        micode                                       C3  ,       --���Ϻ�                    C3
        ciname                                       C4  ,       --�û���                    C4
        miadr                                        C5  ,       --���ַ                    C5
        pdate                                        C6  ,       --��������                  C6
        psavingqc                                    C7  ,       --�ڳ�Ԥ�����              C7
        psavingbq                                    C8  ,       --���ڷ���Ԥ����          C8
        psavingqm                                    C9  ,       --��ĩԤ�����              C9
        PCD                                          C10 ,       --�������                  C10
        fGetOperName(pper)                           C11 ,       --������Ա                  C11
        tools.fuppernumber(psavingbq)                C12 ,       --����д                  C12
        psavingbq                                    C13 ,       --���ϼ�                  C13
        fGetOperName(c2)                             C14 ,       --��ӡԱ                    C14
        '����Ԥ�ս��:'||tools.fformatnum(psavingbq, 2)||'�ϴν���:'||tools.fformatnum(psavingqc, 2)||'���ν���:'||tools.fformatnum(psavingqm, 2)   C15,        --Ԥ����ϸ                  C15
        'Ԥ���ֶ�1'                                  C16  ,          --Ԥ���ֶ�1                 C16
        'Ԥ���ֶ�2'                                  C17  ,          --Ԥ���ֶ�2                 C17
        'Ԥ���ֶ�3'                                  C18  ,          --Ԥ���ֶ�3                 C18
        'Ԥ���ֶ�4'                                  C19  ,          --Ԥ���ֶ�4                 C19
        'Ԥ���ֶ�5'                                  C20  ,          --Ԥ���ֶ�5                 C20
        'Ԥ���ֶ�6'                                  C21  ,          --Ԥ���ֶ�6                 C21
        'Ԥ���ֶ�7'                                  C22  ,          --Ԥ���ֶ�7                 C22
        'Ԥ���ֶ�8'                                  C23  ,          --Ԥ���ֶ�8                 C23
        'Ԥ���ֶ�9'                                  C24  ,          --Ԥ���ֶ�9                 C24
        'Ԥ���ֶ�10'                                 C25  ,          --Ԥ���ֶ�10                C25
        'Ԥ���ֶ�11'                                 C26  ,          --Ԥ���ֶ�11                C26
        'Ԥ���ֶ�12'                                 C27  ,          --Ԥ���ֶ�12                C27
        'Ԥ���ֶ�13'                                 C28  ,          --Ԥ���ֶ�13                C28
        'Ԥ���ֶ�14'                                 C29  ,          --Ԥ���ֶ�14                C29
        'Ԥ���ֶ�15'                                 C30  ,          --Ԥ���ֶ�15                C30
        'Ԥ���ֶ�16'                                 C31  ,          --Ԥ���ֶ�16                C31
        'Ԥ���ֶ�17'                                 C32  ,          --Ԥ���ֶ�17                C32
        'Ԥ���ֶ�18'                                 C33  ,          --Ԥ���ֶ�18                C33
        'Ԥ���ֶ�19'                                 C34  ,          --Ԥ���ֶ�19                C34
        'Ԥ���ֶ�20'                                 C35  ,          --Ԥ���ֶ�20                C35
         PID                                         C36  ,          --�������ˮ��            C36
         c2                                          C37  ,          --��ӡԱ���                C37
         c3                                          C38  ,          --���                      C38
        'ϵͳԤ���ֶ�1'                              C39  ,          --ϵͳԤ���ֶ�1             C39
        'ϵͳԤ���ֶ�2'                              C40  ,          --ϵͳԤ���ֶ�2             C40
        'ϵͳԤ���ֶ�3'                              C41  ,          --ϵͳԤ���ֶ�3             C41
        'ϵͳԤ���ֶ�4'                              C42  ,          --ϵͳԤ���ֶ�4             C42
        'ϵͳԤ���ֶ�5'                              C43  ,          --ϵͳԤ���ֶ�5             C43
        'ϵͳԤ���ֶ�6'                              C44  ,          --ϵͳԤ���ֶ�6             C44
        'ϵͳԤ���ֶ�7'                              C45  ,          --ϵͳԤ���ֶ�7             C45
        'ϵͳԤ���ֶ�8'                              C46  ,          --ϵͳԤ���ֶ�8             C46
        'ϵͳԤ���ֶ�9'                              C47  ,          --ϵͳԤ���ֶ�9             C47
        'ϵͳԤ���ֶ�10'                             C48             --ϵͳԤ���ֶ�10            C48
          from payment, meterinfo, custinfo,pbparmtemp
 where pid=c1
   and pmid = miid
   and micid = ciid
   order by c3 ;
 end ;
/

