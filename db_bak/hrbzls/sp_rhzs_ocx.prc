CREATE OR REPLACE PROCEDURE HRBZLS."SP_RHZS_OCX" (
p_etlseqno IN varchar2,     --�뻧ֱ����ˮ
p_modelno in varchar2, --��Ʊ��ʽ��:2/25
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


------------------------------------------------
 SELECT MAX(rlmid) ˮ����, --ˮ����                                      C1
       MAX(rlmcode) �ͻ�����, --���Ϻ�                                      C2
       MAX(rlcid) �û����, --�û����                                      C3
       max(RLCCODE) �û���, --�û���                                        C4
       MAX(RLCNAME) �û���, --����                                          C5
       MAX(RLCADR) �û���ַ, --�û���ַ                                     C6
       MAX(RLMADR) ˮ���ַ, --ˮ��װ��ַ                                 C7
       MAX(RLBFID) ����, --����                                         C8
       MAX(rlscode) ��������, --��������                                    C9
       MAX(rlecode) ����ֹ��, --����ֹ��                                    C10
       MAX(RLREADSL) ����ˮ��, --����ˮ��                                   C11
       MAX(RLSL) Ӧ��ˮ��, --Ӧ��ˮ��                                       C12
       max(RLADDSL) ����, --����                                            C13
       to_char(max(RLPRDATE), 'yyyy-mm-dd') ���ڳ�������, --���ڳ�������    C14
       to_char(max(RLRDATE), 'yyyy-mm-dd') ��������, --��������             C15
       to_char(max(RLDATE), 'yyyy-mm-dd') ��������, --��������              C16
       max(RLMONTH) �����·�, --�����·�   C23                              C17
       to_char(SYSDATE, 'yyyy-mm-dd') ��ӡ����, --��ӡ����                  C18
       fGetOperName(max(RLCHARGEPER)) �շ�Ա, --�շ�Ա                      C19
       '��  ' || tools.fuppernumber(max(rlje)) �ϼƽ���д, --�ϼƽ���д C20
       '��' || max(rlje) �ϼƽ��2, --�ϼƽ��2                             C21
       FGETSYSCHARGETYPE(max(RLYSCHARGETYPE)) �շѷ�ʽ, --�շѷ�ʽ          C22
       fGetPriceText(rlid) ˮ����ϸ1, --ˮ����ϸ1                           C23
       to_char(sysdate, 'yyyy') ϵͳʱ����, --ϵͳʱ����                    C24
       to_char(sysdate, 'mm') ϵͳʱ����, --ϵͳʱ����                      C25
       to_char(sysdate, 'dd') ϵͳʱ����, --ϵͳʱ����                      C26
       max(etlseqno) ��ˮ�� , --�û�Ԥ���ֶ�5                               C27
       RLID, --Ӧ������ˮ��                                                 C28
       max(RLCHARGEPER) �շ�Ա���, --�շ�Ա���                            C29
       'Ӧ���ֽ� ' || fGetRecZnjMoney(rlid) �ϼ�Ӧ��1, --�ϼ�Ӧ��1          C30
       '' C31,
       '' C32,
       '' C33,
       '' C34,
       '' C35,
       '' C36,
       '' C37,
       '' C38,
       '' C39,
       '' C40,
       '' C41,
       '' C42,
       '' C43,
       '' C44,
       '' C45,
       '' C46,
       '' C47,
       '' C48,
       '' C49,
       '' C50,
       '' C51,
       '' C52,
       '' C53,
       '' C54,
       '' C55,
       '' C56,
       '' C57,
       '' C58,
       '' C59,
       '' C60
  from reclist, recdetail, entrustlog,entrustlist
 WHERE RLID = RDID
   and etlbatch = elbatch
   and etlrlid = rlid
   and elchargetype = 'M'
   and etlseqno = p_etlseqno
 GROUP BY RLID ;

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

