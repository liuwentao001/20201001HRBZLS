CREATE OR REPLACE PROCEDURE HRBZLS."SP_FCHARGEINVSEARCHHP_MX_OCX" (
p_batch in varchar2,
p_modelno in varchar2)  is
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

 select
            max(rlmcode)                                                           C1              ,--���Ϻ�                  C1
            max(rlcname )                                                           C2              ,--����                    C2
            max(rlcadr )                                                            C3              ,--�û���ַ                C3
            min(rlscode )                                                           C4              ,--��������                C4
            max(rlecode )                                                           C5              ,--����ֹ��                C5
            sum(decode(pdpiid,'01',pdsl,0))                                                           C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--��ӡԱ                  C8
            max(ppayee)                                          C9              ,--�շ�Ա                  C9
          tools.fuppernumber(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ))                 C10             ,--�ϼƽ���д            C10
            '��'||/*tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)*/ tools.fformatnum(max(rlje),2)                  C11             ,--�ϼƽ��                C11
            fGetPriceText_gtmx(plid)                C12             ,--ˮ����ϸ1               C12
                   case when  sum(case when pdpiid ='08' then  pdje else 0 end )<>0 then '������:     ��'||to_char(round(sum(case when pdpiid ='08' then  pdje else 0 end ),2),'99.00')     else '' end                     C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(max(rldate) ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(max(rldate) ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������,ϵͳʱ����           C17
            to_char(max(rldate) ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
            '��������'                                                         C21             ,--ˮ����                C21
            '����Ա��'                                                         C22             ,--�û����                C22
            max(plrlmonth)                                                         C23             ,--Ӧ�����·�                  C23
            max(rlmadr )                                                         C24             ,--ˮ��װ��ַ            C24
            max(RLBFID)                                                         C25             ,--����                  C25
            max(RLRPER)                                                         C26             ,--����Ա              C26
            to_char(max(RLDATE),'yyyy-mm-dd')                                                        C27             ,--�ƾ�����                C27
            fgetunitprice_mx_wzzls(max(rlid))                                                   C28             ,--Ӧ�յ���                C28
            fGetUnitMoney_gtmx(plid)                                      C29             ,--ˮ�ѽ��                C29
            '��������'                                                         C30             ,--����                    C30
              case when sum(pdznj)=0 then '0.00' else TO_CHAR( sum(pdznj),'9990.00') end                                                      C31             ,--���ɽ�                  C31
         '�ܼ�:'|| TO_CHAR( SUM(pdje)+sum(pdznj ),'9999999.00')                                                         C32             ,--������                  C32
       ''                                                        C33             ,--���ڳ�������    �����ν�Ǯ��        C33
            '�ϴ�����:'||replace( tools.fformatnum(max(PLSAVINGQC), 2)   ,'-.','-0.')/*tools.fformatnum(max(PLSAVINGQC),2)*/                                                      C34             ,--��������  (�ϴν���)             C34
            '��������:'||replace( tools.fformatnum(max(PLSAVINGQM), 2)   ,'-.','-0.')/*tools.fformatnum(max(PLSAVINGQM),2)*/                                                        C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            'Ӧ���ֽ� '||fGetRecZnjMoney_gtmx(plid)                 C37                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
            '��������'                                                         C39             ,--ˮ����ϸ3               C39
           ''                                                        C40             ,--Ԥ�淢����ϸ            C40
           ''                                  C41             ,--Ӧ�ս���д           C41
          case
             when sum(RLADDSL) > 0 then
              '����' || '������Ϊ' || tools.fformatnum(max(RLADDSL), 0) || '��'
                when max(RLTRANS)='O' then
              '׷���շ�'
             when sum(RLECODE - RLSCODE) <> sum(RLREADSL) then
              '����'

             else
              '��������'
           end                                                           C42             ,--��ע           C42
            'Ӧ�����ɽ�:'||tools.fformatnum(max(PLZNJ),2)                                                       C43             ,--Ӧ�����ɽ�3           C43
            'ʵ�����ɽ�:'||tools.fformatnum(max(PLZNJ),2)                                                         C44             ,--ʵ�����ɽ�4           C44
            'Ӧ��ˮ��:'||tools.fformatnum(max(plje)+max(PLZNJ)-max(PLSAVINGQC),2)                                                        C45             ,--Ӧ��ˮ��5           C45
            'ʵ��ˮ��:'||/*tools.fformatnum(max(PLJE),2)*/tools.fformatnum(sum(pdje)+sum(pdznj)+max(PLSAVINGBQ ) ,2)                                                        C46             ,--ʵ��ˮ��6           C46
            case when max(plcd)='DE' then '' else '���Ʊ' end                                                         C47             ,--�û�Ԥ���ֶ�7           C47
            ''                                                  C48             ,--�û�Ԥ���ֶ�8           C48
            ''                                                         C49             ,--�û�Ԥ���ֶ�9           C49
            ''                                                         C50             ,--�û�Ԥ���ֶ�10          C50
            ''                                                            C51             ,--Ӧ������ˮ��            C51
            ''                            C52             ,--������Ŀ                C52
            MAX('c2')                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա              C54
            '.'                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX('c3')                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            ''                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment,paidlist,paiddetail,reclist/* ,  pbparmtemp*/
   where pid=plpid and
         plid=pdid and
         plrlid=rlid and
         --plpid = C1
         plid = p_batch

         group by plid,pid
UNION

select
            max(NVL(MIPRIID, pmcode))                                                           C1              ,--���Ϻ�                  C1
            max(ciname )                                                           C2              ,--����                    C2
            max(ciadr )                                                            C3              ,--�û���ַ                C3
            case when 0=0 then null else 0 end                                                           C4              ,--��������                C4
            case when 0=0 then null else 0 end                                                            C5              ,--����ֹ��                C5
            case when 0=0 then null else 0 end                                                            C6              ,--Ӧ��ˮ��                C6
            to_char(SYSDATE,'yyyy-mm-dd'  )                                    C7              ,--��ӡ����                C7
            fGetOperName(MAX('c2'))                                                   C8              ,--��ӡԱ                  C8
            max(ppayee)                                          C9              ,--�շ�Ա                  C9
           '��  '|| tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                     C10             ,--�ϼƽ���д            C10
            '��'||tools.fformatnum(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)) ,2)                    C11             ,--�ϼƽ��                C11
            ''                C12             ,--ˮ����ϸ1               C12
            ''                 C13             ,--ˮ����ϸ2               C13
            to_char(sysdate ,'yyyy') ||'    '||to_char(sysdate ,'mm')||'    '|| to_char(sysdate ,'dd')||' '                                       C14             ,--ϵͳʱ����              C14
            to_char(max(pdatetime) ,'mm')                                             C15             ,--ϵͳʱ����              C15
            to_char(max(pdatetime) ,'dd')                                             C16             ,--ϵͳʱ����              C16
            max(pbatch )                                                            C17             ,----�ɷѽ�������          C17
             to_char(max(pdatetime) ,'yyyy')                                                                C18             ,----ʵ������ϸ��ˮ��      C18
            ''                                                             C19             ,--������ˮ��ˮ��          C19
            ''                 C20             ,--Ʊ������ /*Ʊ������*/   C20
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
            '����Ԥ��'||tools.fuppernumber(sum( decode(pcd,'DE',1,-1)*(ppayment -pchange)))                                                        C34             ,--��������  (�ϴν���)  '���ν��� '||tools.fformatnum(max(PSAVINGQM),2)            C34
            ''                                                        C35             ,--�������� (���ν���)               C35
            '��������'                                                         C36             ,--�����·�                C36
            ''                 �ϼ�Ӧ��1                                                  ,--�ϼ�Ӧ��1                            C37
            '�ֽ�'                                                         C38             ,--�շѷ�ʽ                C38
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
            MAX('c2')                                                                 C53             ,--��ӡԱ���              C53
            ''                                                       C54             ,--�շ�Ա���              C54
            ''                                                                 C55             ,--���                    C55
            max(PCD )                                                               C56             ,--ϵͳԤ���ֶ�1           C56
            MAX('c3')                                                        C57             ,--ϵͳԤ���ֶ�2           C57
            ''                                                        C58             ,--ϵͳԤ���ֶ�3           C58
            ''                                                         C59             ,--ϵͳԤ���ֶ�4           C59
            MAX(PID)                                                         C60              --ϵͳԤ���ֶ�5           C60
     from payment , /* pbparmtemp,*/custinfo,METERINFO
   where  pmid=miid and
         pcid=ciid and
        -- pid = C1 and
        pid = p_batch and
         PTRANS ='S'
         group by PBATCH
         HAVING sum( decode(pcd,'DE',1,-1)*(ppayment -pchange))<>0

order by c55 ,c60
 ;

begin

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
V_C31      ,
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
V_C49      ,
V_C50      ,
V_C51      ,
V_C52      ,
V_C53      ,
V_C54      ,
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

