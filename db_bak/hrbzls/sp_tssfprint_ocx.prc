CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSSFPRINT_OCX" (
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
           max(etlbatch) C1, --托收批次号
           max(etlpzno) C2, --托收凭证号
           max(to_char(eloutdate,'yyyy')) C3,--年,
           max(to_char(eloutdate,'mm'))  C4 , --月,
           max(to_char(eloutdate,'dd'))  C5,--日,
           max(to_char(eloutdate,'yyyy')||'/'||to_char(eloutdate,'mm')||'/'||to_char(eloutdate,'dd')) C6 ,--打印日期,
           to_char(max(t0.rldate ),'yyyy')||'  '||to_char(max(t0.rldate ),'mm')||'  '||to_char(max(t0.rldate ),'dd') C7, --应收帐日期,-- 应收帐日期
           '托收'  C8, --收款方式,
          max(t0.rlmcode) C9 ,--客户代码
           max(t0.rlcname) C10 , --用户名
           max(t0.rlmadr)  C11 ,--水表地址
           max(etlmiuiid) C12,
           (case when trim(max(rltel)) is not null then 'tel:'||trim(max(rltel))
                when trim(max(rltel )) is  null and trim(max(rlmtel)) is not null  then 'tel:'||trim(max(rlmtel))
                else '' end) C13,--电话
           max(RLRPER) C14, --抄表员,
           '抄表月份'  C15, --抄表月份标题
           max(substr(t0.rlmonth,1,4)||substr(t0.rlmonth,6,2)) C16, --应收月份
           '起码' C17,--起码标题
           max(t0.rlscodechar)  C18,--起码
           '止码' C19,--止码标题
           max(t0.rlecodechar)  C20,--止码
           '水量' C21,--水量标题
            max(rlsl)    C22,--水量
           '单价' C23,--单价标题
           sum(decode(t3.rdsl,0,0,t3.rddj)) C24,--单价
           '水费' C25,--水费标题
           --sum(case when rdpiid<>'08' then t3.rdje else 0 end)  C26,--水费
           sum(decode(mi.MIIFTAX,'Y',case when rdpiid='01' then 0 else rdje end,rdje))  C26,--水费
           --tools.fuppernumber(round(   sum(case when rdpiid<>'08' then t3.rdje else 0 end)  ,2)  ) C27,--大写
           --tools.fformatnum( round(   sum(case when rdpiid<>'08' then t3.rdje else 0 end)  ,2),2) C28,--实收
           tools.fuppernumber(round(   sum(decode(mi.MIIFTAX,'Y',case when rdpiid='01' then 0 else rdje end,rdje)) ,2)  ) C27,--大写
           tools.fformatnum( round(   sum(decode(mi.MIIFTAX,'Y',case when rdpiid='01' then 0 else rdje end,rdje))  ,2),2) C28,--实收
           tools.fuppernumber(round(   sum(decode(mi.MIIFTAX,'Y',case when rdpiid='01' then 0 else rdje end,rdje))  ,2)  ) C29,--大写
           max(c2) C30,--打印员编号
           max(c3) C31, --顺序号
           '正常抄表'  c32,--备注,
           fgetopername( max(c2)) c33,--打印员中文
          case when   sum(case when rdpiid = '08' then t3.rdje else 0 end)   <>0 then '垃圾费:    ￥'||   tools.fformatnum( round(   sum(case when rdpiid='08' then t3.rdje else 0 end)  ,2),2) else '' end c34,--预留1
      F_chargeinvsearch_recmx_ocx(rlid,'','4')     /*FGETPRICEFRAME(max(t0.rlpfid))*/  c35,--水价类别
           max(rlsl) c36,--用水量
           tools.fformatnum( round(   sum(decode(mi.MIIFTAX,'Y',case when rdpiid='01' then 0 else rdje end,rdje))  ,2),2) c37,--￥金额
           tools.fformatnum(max(RLADDSL), 0) c38,--加减水量
           '加减水量' c39,--预留6
           '' c40,--预留7
           to_char(to_date(to_char(max(rlrdate))),'yyyy-mm-dd') c41,--预留8
           '抄表日期' c42,--预留9
           '' c43,--预留10
           '' c44,--预留11
           '' c45,--预留12
           '' c46,--预留13
           '' c47,--预留14
           '' c48,--预留15
           '' c49,--预留16
           '' c50,--预留17
           '' c51,--预留18
           '' c52,--预留19
           '' c53,--预留20
           '' c54,--预留21
           '' c55,--预留22
           '' c56,--预留23
           '' c57,--预留24
           '' c58,--预留25
           '' c59,--预留26
           '' c60--预留27


    from reclist t0,
         recdetail t3,
         entrustlist t,
         entrustlog  t1,
         pbparmtemp   t2,
         meterinfo mi
   where
      t0.rlid = c5
      and mi.miid = t0.rlmid
      and t0.rlentrustseqno= etlseqno
      and t0.rlid=t3.rdid
      --and t3.rdpiid='01'
      and t1.elbatch=t.etlbatch
      and  c4 = etlseqno
      --and t0.RLIFTAX<>'Y'
      group by rlid
           order by max(t2.c3) /*max(etlmiuiid),max(rlccode)*/  ;


/*  max(c3) c40,--预留7
           to_char(to_date(to_char(max(rlrdate))),'yyyy-mm-dd') c41,--预留8
           '抄表日期' c42,--预留9
           1 c43--预留10*/


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
      fetch c_dt  into V_C1       ,
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
V_C60;
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
    INSERT INTO PRINTLISTTEMP  VALUES (I,v_tempstr);
    end loop;
    close c_dt;
    v_hd :=  trim(to_char(lengthb( v_constructhd||v_constructdt ),'0000000000'))||
        trim(to_char(lengthb( v_contentstrorder )  + v_conlen,'0000000000'))||
        v_constructhd||
        v_constructdt||
        v_contentstrorder  ;
     INSERT INTO PRINTLISTTEMP  VALUES (1,v_hd);


  end ;
/

