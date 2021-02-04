CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSTZD_OCX" (
p_modelno in varchar2 --发票格式号:2/25
) is
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
   select ' （ '||max(rlmcode)||' ） '        C1,--用户编号
       max(rlcname)         C2,--用户名
       max(rlcadr)         C3,--用户地址
       '打印日期:'||to_char(sysdate,'yyyy-mm-dd')        C4,
       '表码:'||MAX(mdno)         C5,
       '水费、滞纳金合计：'||SUM(rlje-rlpaidje)        C6,
       '欠费月数:'||fgetrlmonthnum(miid)        C7,
       fgettstzd_mx(miid,1)  C8,
       fgettstzd_mx(miid,2)       C9,
       fgettstzd_mx(miid,3)         C10,
       fgettstzd_mx(miid,4)         C11,
       fgettstzd_mx(miid,5)         C12,
       fgettstzd_mx(miid,6)         C13,
       fgettstzd_mx(miid,7)         C14,
       fgettstzd_mx(miid,8)         C15,
       fgettstzd_mx(miid,9)         C16,
       fgettstzd_mx(miid,10)         C17,
       '存  根'         C18,
       '贵用户因拖欠水费，将于     '||'月'||'    日对你处停水，由此产'        C19,
       '编号:'||''                                       C20,
       '生一切后果，由贵用户自行负责。'         C21,
       to_char(sysdate,'yyyy')||'年'         C22,
       to_char(sysdate,'MM')||'月'         C23,
       to_char(sysdate,'dd')||'日'         C24,
       '.........................................................................'         C25,
       '松 滋 市 自 来 水 公 司 '         C26,
       ' （ '||max(rlmcode)||' ） '         C27,
       max(rlcname)         C28,
       '_______________:' C29,
       '_______________:' C30,
       '贵用户因拖欠水费，经多次催交尚未解决，根据《城镇供水管'          C31,
       '理办法》第十一条之规定，决定由     '||'月'||'    日对贵用户停止供'         C32,
       '水，一切经济损失由贵用户自负。'         C33,
       '松滋市自来水公司供水部'         C34,
       to_char(sysdate,'yyyy')||'年'         C35,
       to_char(sysdate,'MM')||'月'         C36,
       to_char(sysdate,'dd')||'日'         C37,
       '限 期 缴 纳 水 费 通 知  书'         C38,
       '编号:'||''         C39,
       NULL         C40,
       NULL         C41,
       NULL         C42,
       NULL         C43,
       NULL         C44,
       NULL         C45,
       NULL         C46,
       NULL         C47,
       NULL         C48,
       NULL         C49,
       NULL         C50,
       NULL         C51,
       NULL         C52,
       NULL         C53,
       NULL         C54,
       NULL         C55,
       NULL         C56,
       NULL         C57,
       NULL         C58,
       NULL         C59,
       miid         C60
 from reclist, pbparmtemp,meterdoc,meterinfo
 where micode = trim(c1) and mdmid=rlmid
       and rlmid=miid
       and RLPAIDFLAG='N' and rlje-RLPAIDJE>0
       and rlcd='DE'
group by mibfid,MIRORDER,miid
 order by mibfid,MIRORDER,miid
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
    INSERT INTO PRINTLISTTEMP VALUES (I,v_tempstr);/*
    INSERT INTO Printlisttemp_New VALUE select * from PRINTLISTTEMP;*/
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

