CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCHHP_OCX" (
p_pbatch in varchar2, --ʵ������
P_PID IN varchar2 ,--ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
p_plid in varchar2,--ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
p_modelno in varchar2, --��Ʊ��ʽ��:2/25
p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
p_ifbd in varchar2, --�Ƿ񲹴� --��:Y,��:N
P_PRINTER IN VARCHAR2 --��ӡԱ
)  is
v_constructhd varchar2(30000);
v_constructdt varchar2(30000);
v_contentstrorder varchar2(30000);
v_hd varchar2(30000);
v_tempstr varchar2(30000);
v_conlen number(10);
I NUMBER(10);
V_C1         VARCHAR2(3000);
V_C2         VARCHAR2(3000);
V_C3         VARCHAR2(3000);
V_C4         VARCHAR2(3000);
V_C5         VARCHAR2(3000);
V_C6         VARCHAR2(3000);
V_C7         VARCHAR2(3000);
V_C8         VARCHAR2(3000);
V_C9         VARCHAR2(3000);
V_C10        VARCHAR2(3000);
V_C11        VARCHAR2(3000);
V_C12        VARCHAR2(3000);
V_C13        VARCHAR2(3000);
V_C14        VARCHAR2(3000);
V_C15        VARCHAR2(3000);
V_C16        VARCHAR2(3000);
V_C17        VARCHAR2(3000);
V_C18        VARCHAR2(3000);
V_C19        VARCHAR2(3000);
V_C20        VARCHAR2(3000);
V_C21        VARCHAR2(3000);
V_C22        VARCHAR2(3000);
V_C23        VARCHAR2(3000);
V_C24        VARCHAR2(3000);
V_C25        VARCHAR2(3000);
V_C26        VARCHAR2(3000);
V_C27        VARCHAR2(3000);
V_C28        VARCHAR2(3000);
V_C29        VARCHAR2(3000);
V_C30        VARCHAR2(3000);
V_C31        VARCHAR2(3000);
V_C32        VARCHAR2(3000);
V_C33        VARCHAR2(3000);
V_C34        VARCHAR2(3000);
V_C35        VARCHAR2(3000);
V_C36        VARCHAR2(3000);
V_C37        VARCHAR2(3000);
V_C38        VARCHAR2(3000);
V_C39        VARCHAR2(3000);
V_C40        VARCHAR2(3000);
V_C41        VARCHAR2(3000);
V_C42        VARCHAR2(3000);
V_C43        VARCHAR2(3000);
V_C44        VARCHAR2(3000);
V_C45        VARCHAR2(3000);
V_C46        VARCHAR2(3000);
V_C47        VARCHAR2(3000);
V_C48        VARCHAR2(3000);
V_C49        VARCHAR2(3000);
V_C50        VARCHAR2(3000);
V_C51        VARCHAR2(3000);
V_C52        VARCHAR2(3000);
V_C53        VARCHAR2(3000);
V_C54        VARCHAR2(3000);
V_C55        VARCHAR2(3000);
V_C56        VARCHAR2(3000);
V_C57        VARCHAR2(3000);
V_C58        VARCHAR2(3000);
V_C59        VARCHAR2(3000);
V_C60        VARCHAR2(3000);
cursor c_hd is
select
        constructhd,
        constructdt,
        contentstrorder
        from (
select
replace(connstr(
trim(t.ptditemno)||'^'||trim(round(t.ptdx ) )||'^'||trim(round(t.ptdy  ))||'^'||trim(round(t.ptdheight ))||'^'||
trim(round(t.ptdwidth ))||'^'||trim(t.ptdfontname)||'^'||trim(t.ptdfontsize*-1)||'^'||trim(ftransformaling(t.ptdfontalign))||'|'),'|/','|') constructdt,
 replace(connstr(trim(t.ptditemno)),'/','^')||'|'  contentstrorder
 from printtemplatedt_str t where ptdid= p_modelno
 --2
  ) b,
(
select pthpaperheight||'^'||pthpaperwidth||'^'||lastpage||'^'||1||'|' constructhd  from printtemplatehd t1 where  pthid =p_modelno --2
) c ;


cursor c_dt is

select * from

(
--��Ʊ(����)
/*            select
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
            'ʵ�ս��:'||replace( tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y' AND PDPIID='01'  THEN   PDJE  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--�ϼƽ��                C11
           F_chargeinvsearch_recmx_ocx(plid,null,'1')                C12             ,--ˮ����ϸ1               C12
           '                                '                           C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy')              C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            max(pid)                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            '                                '                                                            C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--Ʊ������ \*Ʊ������*\   C20
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
           '���ν���:'||   replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')                                                    C35             ,--�������� (���ν���)               C35
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
          MAX(pbatch)|| pid||plid                                                        C60              --ϵͳԤ���ֶ�5           C60

    from payment,paidlist,paiddetail,reclist ,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='F'

         group by plid,pid
UNION
--��Ʊ(Ԥ��)
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
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--Ʊ������ \*Ʊ������*\   C20
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
           MAX(PBATCH)|| PID                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='F'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0
*/


SELECT
 c1    ,
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
c60    FROM PBPARMNNOCOMMIT_PRINT_gt

/*-----------------------------------------
UNION

--��ƱPID(����)
            select
            max(rlmcode)                          C1              ,--���Ϻ�                  C1
            max(rlcname )                       C2              ,--����                    C2
            max(rlcadr )                                C3              ,--�û���ַ                C3
            '���³�����  :'||to_char(min(rlscode ) )     C4              ,--��������                C4
            '���³�����  :'||to_char(max(rlecode ) )     C5              ,--����ֹ��                C5
            'ʵ������    :'||to_char(sum(rlsl )     )       C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--��ӡ����                C7
            fGetOperName(P_PRINTER)                     C8              ,--��ӡԱ                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--�շ�Ա                  C9
            ''            C10             ,--�ϼƽ���д            C10
            'ʵ�ս��:'||replace( tools.fformatnum(sum(plje)+sum(plznj)+sum(PLSAVINGBQ ) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END)  ,2)   ,'-.','-0.')                  C11             ,--�ϼƽ��                C11
           F_chargeinvsearch_recmx_ocx(pid,'3')                C12             ,--ˮ����ϸ1               C12
           '                                '                           C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy')              C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            max(pid)                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            '                                '                                                            C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--Ʊ������ \*Ʊ������*\   C20
           '                                '                                                        C21             ,--ˮ����                C21
            '                                '                                                       C22             ,--�û����                C22
            max(plrlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ��װ��ַ            C24
            max(RLBFID)                                                         C25             ,--����                  C25
           '����Ա��'||    max(FGETBFRPER_smfid(rlbfid,rlsmfid))                                                          C26             ,--����Ա              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            ''                  C28             ,--Ӧ�յ���                C28
           replace(  tools.fformatnum(sum(plje),2)   ,'-.','-0.')                                      C29             ,--ˮ�ѽ��                C29
            '                                '                                                         C30             ,--����                    C30
          'ΥԼ��:'|| replace( tools.fformatnum( sum(plznj)  ,2)  ,'-.','-0.')           C31             ,--���ɽ�                  C31
           '                                '                                                        C32             ,--������                  C32
           '                                '                                                      C33             ,--���ڳ�������    �����ν�Ǯ��        C33
           '�ϴν���:'||   replace( tools.fformatnum(to_number(substr(min(plid||PLSAVINGQC),10))  , 2)   ,'-.','-0.')                                                    C34             ,--��������  (�ϴν���)             C34
           '���ν���:'||   replace( tools.fformatnum(to_number(substr(max(plid||PLSAVINGQM),10)) , 2)   ,'-.','-0.')                                                    C35             ,--�������� (���ν���)               C35
            '���³�������:'||max(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--�����·�                C36
          replace(  tools.fformatnum(sum(plje) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END) ,2)  ,'-.','-0.')                     C37  ,--�ϼ�Ӧ��1                            C37
            '                                '                                                         C38             ,--�շѷ�ʽ                C38
            '                                '                                                         C39             ,--ˮ����ϸ3               C39
           '                                '                                                     C40             ,--Ԥ�淢����ϸ            C40
           tools.fuppernumber(sum(plje) - SUM(CASE WHEN MIIFTAX='Y'    THEN   to_number(F_chargeinvsearch_pdje01_ocx(pid,'1'))  ELSE 0 END) )                                C41             ,--Ӧ�ս���д           C41
            '�Ӽ�ˮ��    :' || tools.fformatnum(sum(RLADDSL), 0)  C42             ,--��ע           C42
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
          ''                                                                 C55             ,--���                    C55
          '                                '            C56             ,--ϵͳԤ���ֶ�1           C56
           '                                '                                                      C57             ,--ϵͳԤ���ֶ�2           C57
           '                                '                                                        C58             ,--ϵͳԤ���ֶ�3           C58
          (case when  p_ifbd='Y' THEN '�� '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                        C59             ,--ϵͳԤ���ֶ�4           C59
          MAX(pbatch)|| pid                                                        C60              --ϵͳԤ���ֶ�5           C60

    from payment,paidlist,reclist ,meterinfo
   where pid=plpid and

         plrlid=rlid and
         pmid=miid   AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='Z'

         group by pid
UNION
--��ƱPID(Ԥ��)
select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--���Ϻ�                  C1
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
            to_char(max(pdatetime) ,'yyyy-mm-dd')                  C20             ,--Ʊ������ \*Ʊ������*\   C20
            '��������'                                                         C21             ,--ˮ����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            ''                                                         C24             ,--ˮ��װ��ַ            C24
            max(MIBFID)                                                         C25             ,--����                  C25
            ''                                                         C26             ,--��������              C26
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
           MAX(PBATCH)|| PID                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment , custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         PTRANS ='S' AND
         p_printtype ='Z'
         group by PID
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0

--------------------------------------------- */

UNION
------------------------------------------------
--��Ʊpid(����Ԥ��)
            select
        tools.fmid( max(cminfo),1,'N','/')                           C1              ,--���Ϻ�                  C1
        tools.fmid( max(cminfo) ,2,'N','/')                         C2              ,--����                    C2
        tools.fmid( max(cminfo),3,'N','/')                                 C3              ,--�û���ַ                C3
            '���³�����  :'||to_char(min(rlscode ) )     C4              ,--��������                C4
            '���³�����  :'||to_char(max(rlecode ) )     C5              ,--����ֹ��                C5
            'ʵ������    :'||to_char(sum(rlsl )     )       C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--��ӡ����                C7
            fGetOperName(P_PRINTER)                     C8              ,--��ӡԱ                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--�շ�Ա                  C9
            ''              C10             ,--�ϼƽ���д            C10
  'ʵ�ս��:'||F_PRINTINV_OCX('C10' ,pbatch,max(pmid) )     /*'ʵ�ս��:'|| tools.fformatnum(sum(pdje)+sum(pdznj)+sum(PLSAVINGBQ ) + max(YC) - nvl(SUM(PD01JE),0) ,2) */                   C11             ,--�ϼƽ��                C11
           F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',1)               C12             ,--ˮ����ϸ1               C12
           '                                '                           C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy')              C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            ''                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            '                                '                                                            C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--Ʊ������ /*Ʊ������*/   C20
           '                                '                                                        C21             ,--ˮ����                C21
            '                                '                                                       C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            tools.fmid( max(cminfo) ,3,'N','/')                                                           C24             ,--ˮ��װ��ַ            C24
            tools.fmid( max(cminfo) ,6,'N','/')                                                        C25             ,--����                  C25
           '����Ա��'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  �绰��'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--����Ա              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            ''                  C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--ˮ�ѽ��                C29
            '                                '                                                         C30             ,--����                    C30
          'ΥԼ��:'||replace( tools.fformatnum( sum(pdznj)  ,2) ,'-.','-0.')            C31             ,--���ɽ�                  C31
           '                                '                                                        C32             ,--������                  C32
           '                                '                                                      C33             ,--���ڳ�������    �����ν�Ǯ��        C33
     '�ϴν���:'||   F_PRINTINV_OCX('C7' ,pbatch,max(pmid) )        /*'�ϴν���:'||   replace( tools.fformatnum(max(qcsaving),2)   ,'-.','-0.')  */                                                  C34             ,--��������  (�ϴν���)             C34
     '���ν���:'||   F_PRINTINV_OCX('C9' ,pbatch,max(pmid) ) /* '���ν���:'||   tools.fformatnum( max(qcsaving) + SUM(PLSAVINGBQ ) + max(YC) ,2) */                                                    C35             ,--�������� (���ν���)               C35
            '���³�������:'||MAX(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--�����·�                C36
        replace(  tools.fformatnum(  sum(pdje) - SUM(PD01JE ) ,2)  ,'-.','-0.')                   C37  ,--�ϼ�Ӧ��1                            C37
            '                                '                                                         C38             ,--�շѷ�ʽ                C38
            '                                '                                                         C39             ,--ˮ����ϸ3               C39
           '                                '                                                     C40             ,--Ԥ�淢����ϸ            C40
            tools.fuppernumber(  sum(pdje) - SUM(PD01JE ) )                                C41             ,--Ӧ�ս���д           C41
            '�Ӽ�ˮ��    :' || tools.fformatnum(SUM(RLADDSL), 0)  C42             ,--��ע           C42
            '                                '                                                      C43             ,--Ӧ�����ɽ�3           C43
            '                                '                                                        C44             ,--ʵ�����ɽ�4           C44
            '                                '           C45             ,--Ӧ��ˮ��5           C45
            '                                '   C46             ,--ʵ��ˮ��6           C46
           ''                                                     C47             ,--�û�Ԥ���ֶ�7           C47
         fgetopername(  MAX(ppayee)  )                                               C48             ,--�û�Ԥ���ֶ�8           C48
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',2)                                                         C49            ,--�û�Ԥ���ֶ�9           C49
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',3)                                                         C50             ,--�û�Ԥ���ֶ�10          C50
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',4)                                                             C51             ,--Ӧ������ˮ��            C51
          F_chargeinvsearch_recmx_ocx1(PBATCH,max(pmid),'3',5)                            C52             ,--������Ŀ                C52
           '                                '                                                                C53             ,--��ӡԱ���              C53
          '                                '                                                       C54             ,--�շ�Ա              C54
         TO_CHAR( SUM(PD01JE ) )                                                                C55             ,--���                    C55
          '                                '            C56             ,--ϵͳԤ���ֶ�1           C56
           '                                '                                                      C57             ,--ϵͳԤ���ֶ�2           C57
           '                                '                                                        C58             ,--ϵͳԤ���ֶ�3           C58
           (case when  p_ifbd='Y' THEN '�� '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--ϵͳԤ���ֶ�4           C59
          pbatch                                                       C60              --ϵͳԤ���ֶ�5           C60

from
(
SELECT max(rlmcode||'/'||rlcname||'/'||rlcadr||'/'||
              rlmadr||'/'||rlmonth||'/'||RLBFID||'/'||rlsmfid) cminfo,max(pmid) pmid,
min(rlscode) rlscode,max(rlecode) rlecode,max(rlsl) rlsl,max(RLADDSL) RLADDSL,MIN(RLDATE) RLDATE, MIN(RLRDATE) RLRDATE,
max(ppayee) ppayee,sum(pdje) pdje, sum(pdznj) pdznj , max(PLSAVINGBQ ) PLSAVINGBQ,
max(PLSAVINGQC) PLSAVINGQC,max(PLSAVINGQm) PLSAVINGQm, max(pdatetime) pdatetime ,
MAX(PID) PID,MAX(ptrans) ptrans,
max(psavingqc ) psavingqc ,max(psavingbq ) psavingbq  ,max(psavingqm ) psavingqm  ,
max(ppayment ) ppayment  ,max(pchange ) pchange ,max(pcd) pcd,max(pbatch)  pbatch,
F_chargeinvsearch_sqmaving_ocx(max(pbatch),max(pmid)) qcsaving,
F_chargeinvsearch_yc_ocx(max(pbatch),max(pmid)) yc,
SUM(CASE WHEN PDPIID='01' AND MIIFTAX='Y'  THEN DECODE(PLCD,'DE',1,-1)*PDJE ELSE 0 END) PD01JE,
max(mibfid) mibfid,max(mismfid) mismfid,max(mistatus) mistatus
   from payment,paidlist,paiddetail,reclist,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='Z'
         group by plid
)
group by pbatch,pmid




---------------------------------------------------------------------------------
UNION
--��Ʊ(����Ԥ��)
            select
        tools.fmid( max(cminfo),1,'N','/')                           C1              ,--���Ϻ�                  C1
        tools.fmid( max(cminfo) ,2,'N','/')                         C2              ,--����                    C2
        tools.fmid( max(cminfo),3,'N','/')                                 C3              ,--�û���ַ                C3
            '���³�����  :'||to_char(min(rlscode ) )     C4              ,--��������                C4
            '���³�����  :'||to_char(max(rlecode ) )     C5              ,--����ֹ��                C5
            'ʵ������    :'||to_char(sum(rlsl )     )       C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd')              C7              ,--��ӡ����                C7
            fGetOperName(P_PRINTER)                     C8              ,--��ӡԱ                  C8
           fgetopername(   max(ppayee)  )                                        C9              ,--�շ�Ա                  C9
            ''              C10             ,--�ϼƽ���д            C10
            'ʵ�ս��:'|| tools.fformatnum(sum(pdje)+sum(pdznj)+sum(PLSAVINGBQ ) + max(YC) - nvl(SUM(PD01JE),0) ,2)                    C11             ,--�ϼƽ��                C11
           F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',1)               C12             ,--ˮ����ϸ1               C12
           '                                '                           C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy')              C14             ,--ϵͳʱ����              C14
            to_char(sysdate ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(sysdate ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            ''                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            '                                '                                                            C19             ,--������ˮ��ˮ��          C19
            to_char(max(pdatetime),'yyyy-mm-dd')                 C20             ,--Ʊ������ /*Ʊ������*/   C20
           '                                '                                                        C21             ,--ˮ����                C21
            '                                '                                                       C22             ,--�û����                C22
            ''                                                         C23             ,--Ӧ�����·�                  C23
            tools.fmid( max(cminfo) ,3,'N','/')                                                           C24             ,--ˮ��װ��ַ            C24
            tools.fmid( max(cminfo) ,6,'N','/')                                                        C25             ,--����                  C25
           '����Ա��'||    max(FGETBFRPER_smfid(mibfid,mismfid))||max(case when mistatus in ('13','21') then '  �绰��'||FGETBFRPERtel_smfid(mibfid,mismfid) else '' end)                                                          C26             ,--����Ա              C26
            to_char(SYSDATE,'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            ''                  C28             ,--Ӧ�յ���                C28
            ''                                      C29             ,--ˮ�ѽ��                C29
            '                                '                                                         C30             ,--����                    C30
          'ΥԼ��:'||replace( tools.fformatnum( sum(pdznj)  ,2) ,'-.','-0.')            C31             ,--���ɽ�                  C31
           '                                '                                                        C32             ,--������                  C32
           '                                '                                                      C33             ,--���ڳ�������    �����ν�Ǯ��        C33
           '�ϴν���:'||   replace( tools.fformatnum(max(qcsaving),2)   ,'-.','-0.')                                                    C34             ,--��������  (�ϴν���)             C34
           '���ν���:'||   tools.fformatnum( max(qcsaving) + SUM(PLSAVINGBQ ) + max(YC) ,2)                                                     C35             ,--�������� (���ν���)               C35
            '���³�������:'||MAX(to_char(RLRDATE,'yyyy-mm-dd'))                                                         C36             ,--�����·�                C36
        replace(  tools.fformatnum(  sum(pdje) - SUM(PD01JE ) ,2)  ,'-.','-0.')                   C37  ,--�ϼ�Ӧ��1                            C37
            '                                '                                                         C38             ,--�շѷ�ʽ                C38
            '                                '                                                         C39             ,--ˮ����ϸ3               C39
           '                                '                                                     C40             ,--Ԥ�淢����ϸ            C40
            tools.fuppernumber(  sum(pdje) - SUM(PD01JE ) )                                C41             ,--Ӧ�ս���д           C41
            '�Ӽ�ˮ��    :' || tools.fformatnum(SUM(RLADDSL), 0)  C42             ,--��ע           C42
            '                                '                                                      C43             ,--Ӧ�����ɽ�3           C43
            '                                '                                                        C44             ,--ʵ�����ɽ�4           C44
            '                                '           C45             ,--Ӧ��ˮ��5           C45
            '                                '   C46             ,--ʵ��ˮ��6           C46
           ''                                                     C47             ,--�û�Ԥ���ֶ�7           C47
         fgetopername(  MAX(ppayee)  )                                               C48             ,--�û�Ԥ���ֶ�8           C48
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',2)                                                        C49            ,--�û�Ԥ���ֶ�9           C49
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',3)                                                       C50             ,--�û�Ԥ���ֶ�10          C50
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',4)                                                           C51             ,--Ӧ������ˮ��            C51
        F_chargeinvsearch_recmx_ocx1(PBATCH,null,'2',5)                         C52             ,--������Ŀ                C52
           '                                '                                                                C53             ,--��ӡԱ���              C53
          '                                '                                                       C54             ,--�շ�Ա              C54
         TO_CHAR( SUM(PD01JE ) )                                                                C55             ,--���                    C55
          '                                '            C56             ,--ϵͳԤ���ֶ�1           C56
           '                                '                                                      C57             ,--ϵͳԤ���ֶ�2           C57
           '                                '                                                        C58             ,--ϵͳԤ���ֶ�3           C58
           (case when  p_ifbd='Y' THEN '�� '||to_char(sysdate,'yyyy-mm-dd') else ''  END )                                                         C59             ,--ϵͳԤ���ֶ�4           C59
          pbatch                                                       C60              --ϵͳԤ���ֶ�5           C60

from
(
SELECT max(rlmcode||'/'||rlcname||'/'||rlcadr||'/'||
              rlmadr||'/'||rlmonth||'/'||RLBFID||'/'||rlsmfid) cminfo,
min(rlscode) rlscode,max(rlecode) rlecode,max(rlsl) rlsl,max(RLADDSL) RLADDSL,MIN(RLDATE) RLDATE, MIN(RLRDATE) RLRDATE,
max(ppayee) ppayee,sum(pdje) pdje, sum(pdznj) pdznj , max(PLSAVINGBQ ) PLSAVINGBQ,
max(PLSAVINGQC) PLSAVINGQC,max(PLSAVINGQm) PLSAVINGQm, max(pdatetime) pdatetime ,
MAX(PID) PID,MAX(ptrans) ptrans,
max(psavingqc ) psavingqc ,max(psavingbq ) psavingbq  ,max(psavingqm ) psavingqm  ,
max(ppayment ) ppayment  ,max(pchange ) pchange ,max(pcd) pcd,max(pbatch)  pbatch,
F_chargeinvsearch_sqmaving_ocx(max(pbatch),null) qcsaving,
F_chargeinvsearch_yc_ocx(max(pbatch),null) yc,
SUM(CASE WHEN PDPIID='01' AND MIIFTAX='Y'  THEN DECODE(PLCD,'DE',1,-1)*PDJE ELSE 0 END) PD01JE ,
max(mibfid) mibfid,max(mismfid) mismfid ,max(mistatus ) mistatus
  from payment,paidlist,paiddetail,reclist,meterinfo
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         pmid=miid AND
         pbatch = p_pbatch and
         (p_pid is null or p_pid=pid) and
         (p_plid is null or p_plid=plid) and
         p_printtype ='H'
         group by plid
)
group by pbatch


order by c60
)
order by c60
 ;

begin
sp_fchargeinvsearch_fp_ocx(
p_pbatch  , --ʵ������
P_PID   ,--ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
p_plid  ,--ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
p_modelno  , --��Ʊ��ʽ��:2/25
p_printtype  , --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
p_ifbd   , --�Ƿ񲹴� --��:Y,��:N
P_PRINTER  --��ӡԱ
)  ;
SP_PRINTINV_OCX( p_pbatch ,p_printtype ) ;

open c_hd   ;
  fetch c_hd
    into v_constructhd,v_constructdt,v_contentstrorder;
  null;
close c_hd;

I := 1 ;
v_conlen := 0 ;
DELETE PRINTLISTTEMP;
    open c_dt   ;
    loop
      fetch c_dt
        into V_C1       ,
V_C2       ,
V_C3       ,
V_C4       ,
V_C5       ,
V_C6       ,
V_C7       ,
V_C8       ,
V_C9       ,
V_C10      ,
V_C11      ,
V_C12      ,
V_C13      ,
V_C14      ,
V_C15      ,
V_C16      ,
V_C17      ,
V_C18      ,
V_C19      ,
V_C20      ,
V_C21      ,
V_C22      ,
V_C23      ,
V_C24      ,
V_C25      ,
V_C26      ,
V_C27      ,
V_C28      ,
V_C29      ,
V_C30      ,
V_C31     ,
V_C32      ,
V_C33      ,
V_C34      ,
V_C35      ,
V_C36      ,
V_C37      ,
V_C38      ,
V_C39      ,
V_C40      ,
V_C41      ,
V_C42      ,
V_C43      ,
V_C44      ,
V_C45      ,
V_C46      ,
V_C47      ,
V_C48      ,
V_C49     ,
V_C50      ,
V_C51       ,
V_C52    ,
V_C53      ,
V_C54         ,
V_C55      ,
V_C56      ,
V_C57      ,
V_C58      ,
V_C59      ,
V_C60
;
      exit when c_dt%notfound or c_dt%notfound is null;
     select replace(
connstr(
  trim(v_c1  )||'^'
||trim(v_c2  )||'^'
||trim(v_c3  )||'^'
||trim(v_c4  )||'^'
||trim(v_c5  )||'^'
||trim(v_c6  )||'^'
||trim(v_c7  )||'^'
||trim(v_c8  )||'^'
||trim(v_c9  )||'^'
||trim(v_c10 )||'^'
||trim(v_c11 )||'^'
||trim(v_c12 )||'^'
||trim(v_c13 )||'^'
||trim(v_c14 )||'^'
||trim(v_c15 )||'^'
||trim(v_c16 )||'^'
||trim(v_c17 )||'^'
||trim(v_c18 )||'^'
||trim(v_c19 )||'^'
||trim(v_c20 )||'^'
||trim(v_c21 )||'^'
||trim(v_c22 )||'^'
||trim(v_c23 )||'^'
||trim(v_c24 )||'^'
||trim(v_c25 )||'^'
||trim(v_c26 )||'^'
||trim(v_c27 )||'^'
||trim(v_c28 )||'^'
||trim(v_c29 )||'^'
||trim(v_c30 )||'^'
||trim(v_c31 )||'^'
||trim(v_c32 )||'^'
||trim(v_c33 )||'^'
||trim(v_c34 )||'^'
||trim(v_c35 )||'^'
||trim(v_c36 )||'^'
||trim(v_c37 )||'^'
||trim(v_c38 )||'^'
||trim(v_c39 )||'^'
||trim(v_c40 )||'^'
||trim(v_c41 )||'^'
||trim(v_c42 )||'^'
||trim(v_c43 )||'^'
||trim(v_c44 )||'^'
||trim(v_c45 )||'^'
||trim(v_c46 )||'^'
||trim(v_c47 )||'^'
||trim(v_c48 )||'^'
||trim(v_c49 )||'^'
||trim(v_c50 )||'^'
||trim(v_c51 )||'^'
||trim(v_c52 )||'^'
||trim(v_c53 )||'^'
||trim(v_c54 )||'^'
||trim(v_c55 )||'^'
||trim(v_c56 )||'^'
||trim(v_c57 )||'^'
||trim(v_c58 )||'^'
||trim(v_c59 )||'^'
||trim(v_c60 )
||'|' )
,'|/','|') into v_tempstr   from dual;
     I := I + 1;
     v_conlen :=v_conlen +  lengthb( v_tempstr ) ;
    INSERT INTO PRINTLISTTEMP VALUES (I,v_tempstr);
    end loop;
    close c_dt;
    v_hd :=  trim(to_char(lengthb( v_constructhd||v_constructdt ),'0000000000'))||
        trim(to_char(lengthb( v_contentstrorder )  + v_conlen,'0000000000'))||
        v_constructhd||
        v_constructdt||
        v_contentstrorder  ;
     INSERT INTO PRINTLISTTEMP VALUES (1,v_hd);


  end ;
/

