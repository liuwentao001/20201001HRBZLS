CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCH_FP_OCX1" (
p_pbatch in varchar2, --ʵ������
P_PID IN varchar2 ,--ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
p_plid in varchar2,--ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
p_modelno in varchar2, --��Ʊ��ʽ��:2/25
p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
p_ifbd in varchar2, --�Ƿ񲹴� --��:Y,��:N
P_PRINTER IN VARCHAR2 --��ӡԱ
) is
V_COUNT NUMBER(10);
v_pidstr varchar2(1000);
v_PID varchar2(1000);
v_PMID varchar2(1000);
v_PTRANS  varchar2(1000);
v_plid  varchar2(1000);
v_ycje NUMBER(13,3);
begin
null;
delete PBPARMNNOCOMMIT_PRINT_gt;
if p_printtype='F' THEN
insert into PBPARMNNOCOMMIT_PRINT_gt
( c1    ,
c2    ,
c3    ,
c4    ,
c5    ,
c6    ,
c7    ,
c8    ,
c9    ,
c10   ,
c11   ,
c12   ,
c13   ,
c14   ,
c15   ,
c16   ,
c17   ,
c18   ,
c19   ,
c20   ,
c21   ,
c22   ,
c23   ,
c24   ,
c25   ,
c26   ,
c27   ,
c28   ,
c29   ,
c30   ,
c31   ,
c32   ,
c33   ,
c34   ,
c35   ,
c36   ,
c37   ,
c38   ,
c39   ,
c40   ,
c41   ,
c42   ,
c43   ,
c44   ,
c45   ,
c46   ,
c47   ,
c48   ,
c49   ,
c50   ,
c51   ,
c52   ,
c53   ,
c54   ,
c55   ,
c56   ,
c57   ,
c58   ,
c59   ,
c60   ,
C61   ,
C62   ,
C63   ,
C64   ,
C65
 )


--��Ʊ(����)
            select
            max(rlmcode)                          C1              ,--���Ϻ�                  C1
            max(rlcname )                       C2              ,--����                    C2
            max(rlcadr )                                C3              ,--�û���ַ                C3
            '���³�����  :'||to_char(min(rlscode ) )     C4              ,--��������                C4
            '���³�����  :'||to_char(max(rlecode ) )     C5              ,--����ֹ��                C5
            'ʵ������    :'||to_char(max(rlsl )     )       C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--��ӡ����                C7
            fGetOperName(P_PRINTER)                     C8              ,--��ӡԱ                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--�շ�Ա                  C9
          replace(   tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) )   ,'-.','-0.')            C10             ,--�ϼƽ���д            C10
            replace( tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--�ϼƽ��                C11
           F_chargeinvsearch_recmx_ocx(plid,null,'1')                C12             ,--ˮ����ϸ1               C12
           '                                '                           C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy')              C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            max(pid)                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            '                                '                                                            C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--Ʊ������ /*Ʊ������*/   C20
           '                                '                                                        C21             ,--ˮ����                C21
            '                                '                                                       C22             ,--�û����                C22
            max(plrlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ��װ��ַ            C24
            max(RLBFID)                                                         C25             ,--����                  C25
           '����Ա��'||    max(FGETBFRPER_smfid(mibfid,mismfid))||  max(case when mistatus in ('13','21') then '  �绰��'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--����Ա              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            ''                  C28             ,--Ӧ�յ���                C28
           replace(  tools.fformatnum(sum(pdje),2)   ,'-.','-0.')                                      C29             ,--ˮ�ѽ��                C29
            '                                '                                                         C30             ,--����                    C30
          'ΥԼ��:'|| replace( tools.fformatnum( sum(pdznj)  ,2)  ,'-.','-0.')           C31             ,--���ɽ�                  C31
           '                                '                                                        C32             ,--������                  C32
           '                                '                                                      C33             ,--���ڳ�������    �����ν�Ǯ��        C33
           '�ϴν���:'||   replace( tools.fformatnum(max(PLSAVINGQC), 2)   ,'-.','-0.')                                                    C34             ,--��������  (�ϴν���)             C34
             replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')                                                    C35             ,--�������� (���ν���)               C35
            '���³�������:'||max(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--�����·�                C36
          replace(  tools.fformatnum(sum(pdje) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END) ,2)  ,'-.','-0.')                     C37  ,--�ϼ�Ӧ��1                            C37
            '                                '                                                         C38             ,--�շѷ�ʽ                C38
            '                                '                                                         C39             ,--ˮ����ϸ3               C39
           '                                '                                                     C40             ,--Ԥ�淢����ϸ            C40
           tools.fuppernumber(sum(pdje) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END) )                                C41             ,--Ӧ�ս���д           C41
            '�Ӽ�ˮ��    :' || tools.fformatnum(max(RLADDSL), 0)  C42             ,--��ע           C42
            '                                '                                                      C43             ,--Ӧ�����ɽ�3           C43
            '                                '                                                        C44             ,--ʵ�����ɽ�4           C44
            '                                '           C45             ,--Ӧ��ˮ��5           C45
            '                                '   C46             ,--ʵ��ˮ��6           C46
           ''                                                     C47             ,--�û�Ԥ���ֶ�7           C47
         fgetopername(  max(ppayee)  )                                               C48             ,--�û�Ԥ���ֶ�8           C48
        '                              '                                                        C49            ,--�û�Ԥ���ֶ�9           C49
            '                                '                                                         C50             ,--�û�Ԥ���ֶ�10          C50
          '                                '                                                             C51             ,--Ӧ������ˮ��            C51
           '                                '                            C52             ,--������Ŀ                C52
           '                                '                                                                C53             ,--��ӡԱ���              C53
          '                                '                                                       C54             ,--�շ�Ա              C54
          TO_CHAR(SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END))                                                                 C55             ,--���                    C55
          '                                '            C56             ,--ϵͳԤ���ֶ�1           C56
           '                                '                                                      C57             ,--ϵͳԤ���ֶ�2           C57
           '                                '                                                        C58             ,--ϵͳԤ���ֶ�3           C58
          (case when  p_ifbd='Y' THEN '�� '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                        C59             ,--ϵͳԤ���ֶ�4           C59
          MAX(pbatch)|| pid||plid                                                    C60      ,          --ϵͳԤ���ֶ�5           C60
            MAX(pbatch),
          pid,
          plid,
          MAX(PMID),
          MAX(PCID)
    from payment,paidlist,paiddetail,reclist ,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='F'
         group by plid,pid ;

  SELECT COUNT(*) INTO V_COUNT FROM PAYMENT T WHERE PBATCH=p_pbatch AND PTRANS<>'S';
IF V_COUNT>0 THEN
  SELECT MAX(PID||'@'||PMID||PTRANS||  (ppayment - pchange )   ) into v_pidstr
   FROM PAYMENT T WHERE PBATCH=p_pbatch;
  v_pid :=substr(v_pidstr,1,10 ) ;
  v_PMID :=substr(v_pidstr,12,10 ) ;
  v_PTRANS :=substr(v_pidstr,22,1 ) ;
  v_ycje :=to_number( substr(v_pidstr,23 ) ) ;
  if v_PTRANS='S' THEN
  begin
  SELECT MAX(PlID ) into v_plid
   FROM PAYMENT T,paidlist t1 WHERE pid=plpid
   and  PBATCH=p_pbatch /*and pmid=v_PMID*/ ;
  exception when others then
  raise_application_error(-20010,'��Ʊ�쳣');
  end;

UPDATE PBPARMNNOCOMMIT_PRINT_gt
  SET c11=   replace(  tools.fformatnum(  to_number(c11) +  v_ycje ,2) ,'-.','-0.')     ,
      c35=    replace(  tools.fformatnum(   to_number(c35) + v_ycje,2 ) ,'-.','-0.')
  WHERE c63=v_plid ;
    END IF;
  UPDATE PBPARMNNOCOMMIT_PRINT_gt
  SET c11= 'ʵ�ս��:'|| c11    ,
      c35=  '���ν���:'||c35 ;
ELSE
 insert into PBPARMNNOCOMMIT_PRINT_gt
( c1    ,
c2    ,
c3    ,
c4    ,
c5    ,
c6    ,
c7    ,
c8    ,
c9    ,
c10   ,
c11   ,
c12   ,
c13   ,
c14   ,
c15   ,
c16   ,
c17   ,
c18   ,
c19   ,
c20   ,
c21   ,
c22   ,
c23   ,
c24   ,
c25   ,
c26   ,
c27   ,
c28   ,
c29   ,
c30   ,
c31   ,
c32   ,
c33   ,
c34   ,
c35   ,
c36   ,
c37   ,
c38   ,
c39   ,
c40   ,
c41   ,
c42   ,
c43   ,
c44   ,
c45   ,
c46   ,
c47   ,
c48   ,
c49   ,
c50   ,
c51   ,
c52   ,
c53   ,
c54   ,
c55   ,
c56   ,
c57   ,
c58   ,
c59   ,
c60   ,
C61   ,
C62   ,
C63   ,
C64   ,
C65
 )
      select
            max(pmcode)                                                           C1              ,--���Ϻ�                  C1
            max(ciname )                                                           C2              ,--����                    C2
            max(ciadr )                                                            C3              ,--�û���ַ                C3
            ''                                                          C4              ,--��������                C4
            ''                                                             C5              ,--����ֹ��                C5
            ''                                                            C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(P_PRINTER)                                                   C8              ,--��ӡԱ                  C8
            fgetopername(  max(ppayee)   )                                       C9              ,--�շ�Ա                  C9
           '��  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                       C10             ,--�ϼƽ���д            C10
            'ʵ�ս��:'||replace(tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2),'-.','-0.')                     C11             ,--�ϼƽ��                C11
            ''                C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ����                C21
            ''                                                      C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            ''                                                         C24             ,--ˮ��װ��ַ            C24
            max(MIBFID)                                                         C25             ,--����                  C25
            '����Ա��'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  �绰��'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--����Ա              C26
            ''                                                         C27             ,--����ˮ��                C27
            ''                                                           C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--Ӧ�ս��                C29
            '��������'                                                         C30             ,--����                    C30
            ''                                                       C31             ,--���ɽ�                  C31
            ''                                                         C32             ,--������                  C32
            ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33 '�ϴν��� '||tools.fformatnum(max(PSAVINGQC),2)
            '�ϴν���:'||   replace( tools.fformatnum(sum(PSAVINGQC), 2)   ,'-.','-0.')                                                        C34             ,--��������  (�ϴν���)  '���ν��� '||tools.fformatnum(max(PSAVINGQM),2)            C34
            '���ν���:'||   replace( tools.fformatnum(sum(PSAVINGQM), 2)   ,'-.','-0.')                                                        C35             ,--�������� (���ν���)               C35
            ''                                                         C36             ,--�����·�                C36
            tools.fformatnum(0,2)                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           tools.fuppernumber(0)                                  C41             ,--Ӧ�ս���д           C41
           ''                                                         C42             ,--�û�Ԥ���ֶ�2           C42
            ''                                                       C43             ,--�û�Ԥ���ֶ�3           C43
            ''                                                         C44             ,--�û�Ԥ���ֶ�4           C44
            ''                                                         C45             ,--�û�Ԥ���ֶ�5           C45
            ''                                                         C46             ,--�û�Ԥ���ֶ�6           C46
            ''                                                         C47             ,--�û�Ԥ���ֶ�7           C47
           fgetopername(   max(ppayee)      )                                            C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX('c2')                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            ''                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX('c3')                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            'Ԥ��'||(case when  p_ifbd='Y' THEN '�� '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--ϵͳԤ���ֶ�4           C59
           MAX(PBATCH)|| PID                                                         C60   ,           --ϵͳԤ���ֶ�5           C60
           MAX(PBATCH) ,
           PID,
            '',
          MAX(PMID),
          MAX(PCID)
   from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='F'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0 ;
      END IF;
END IF;
end;
/

