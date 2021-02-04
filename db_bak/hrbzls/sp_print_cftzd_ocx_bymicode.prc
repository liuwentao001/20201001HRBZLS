CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_CFTZD_OCX_BYMICODE" (
p_mindate in varchar2,--开始欠费时间
p_maxdate in varchar2,--结束欠费时间
p_modelno in varchar2, --发票格式号
p_memo    in varchar2, --发票备注
P_PRINTER IN VARCHAR2 --打印员
)  is
/*打印催费通知单*/
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

select max(rlid),
       max(fgetopername(MICPER) || '[' || MICPER || ']') 催费员,
       max(rlmid),
       max(to_char(sysdate, 'YY')) 年,
       max(to_char(sysdate, 'MM')) 月,
       max(to_char(sysdate, 'DD')) 日,
       max(mibfid) 表册号,
       max(RLCADR) 用户地址,
       rlmcode 户号,
       max(rlcname) 户名,
       max(to_char(rlprdate,'YYYY-MM-DD')) 上期抄表时间,
       max(to_char(rlrdate,'YYYY-MM-DD')) 本期抄表时间,
       substr( min(to_char(rldate,'yyyymmdd')||'@'||rlid ||'@'|| rlscode ),21) 上期表码,
       substr( max(to_char(rldate,'yyyymmdd')||'@'||rlid ||'@'|| rlecode ),21)  本期抄码,
       sum(rlsl) 本期水量,
       sum(rlje) 本期水费,
       sum(tools.fformatnum((rlje - rlpaidje), 2)) 本期欠费,
       '正常' 水表状态,
       max(tools.fformatnum((select tools.fformatnum(nvl(sum(pddj), 0), 2)
                          from pricedetail
                         where pdpscid = 0
                           and pdmethod = 'dj1'
                           and pdpfid = RLPFID),
                        2)) 综合水价,
       '' 陈欠水费,
       max(tools.fformatnum(0, 2)) 违约金,
       max(tools.fformatnum(misaving, 2)) 预存余额,
       max(tools.fformatnum(rlje, 2)) 应缴水费,
       max(fgetopername(RLRPER)) 抄表员,
       '应缴' 应缴,
       max(mismfid),
       max(mirorder),
       (min(rlmonth)||' 至 '||max(rlmonth)) 欠费时间段
  from reclist t, meterinfo t1,pbparmtemp
 where rlpaidflag in (/*'Y',*/ 'N'/*, 'V', 'K', 'T', 'W'*/)
   and rlmcode = trim(c1)
   AND RLJE>0
   AND RLCD = 'DE'
   and miid = rlmid
   and ((p_mindate is not null and rlmonth >= p_mindate) or (p_mindate is null) )
   and ((p_maxdate is not null and rlmonth <= p_maxdate) or (p_maxdate is null) )
   group by rlmcode
 order by max(c2);
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
V_C28
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
||trim(v_c28 )
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

