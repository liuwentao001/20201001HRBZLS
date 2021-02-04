CREATE OR REPLACE FUNCTION HRBZLS."FRETRECLISTBYMIID" (P_MIID IN VARCHAR2,
                                             P_ROW  IN NUMBER,
                                             P_COL  IN NUMBER)
  RETURN VARCHAR2 AS
  V_STR VARCHAR(30000);
  v_mon varchar(10);
  v_count  NUMBER :=0;
  v_je  NUMBER;
  v_allje  NUMBER;
  I     NUMBER :=0;
  J     NUMBER :=0;
  v_allbs NUMBER :=0;
  str0 VARCHAR(30000);
  str1 VARCHAR(30000);
  str2 VARCHAR(30000);
  str3 VARCHAR(30000);
  str4 VARCHAR(30000);
  str5 VARCHAR(30000);
  str6 VARCHAR(30000);
  mindate varchar2(10) ;
  maxdate varchar2(10);
  rldatestr varchar2(10);
  outflagstr varchar2(10);
  v_outflagstr varchar2(10);
  CURSOR C_REC IS
  SELECT max(RLMONTH), SUM(RDJE),to_char(max(rldate),'yyyy-mm-dd'),max(rloutflag)
    FROM RECLIST, RECDETAIL
   WHERE RLID = RDID
     AND RLMID = P_MIID
     AND RLCD = 'DE'
     AND RLPAIDFLAG IN ('N', 'V', 'K', 'W')
     AND RDPAIDFLAG = 'N'
     AND RDJE > 0
   group by rlid, rlmonth
   order by RLMONTH;
BEGIN
  OPEN C_REC;
  LOOP
      FETCH C_REC
        INTO v_mon,v_je,rldatestr,outflagstr;
      EXIT WHEN C_REC%NOTFOUND or C_REC%NOTFOUND is null;
      v_count :=v_count + 1;
      v_allbs := v_allbs + 1 ;
      v_allje := nvl(v_allje,0) + v_je ;
      if v_count=1 then
         mindate := rldatestr;
         v_outflagstr :=outflagstr ;
      end if;
         maxdate := rldatestr;

      if v_count>=11 then
         str6 :=' 等';
      else

        if mod(v_count, P_ROW)=1 then
           str1 :=nvl(str1,'  ') || substr(v_mon,1,4)||'年'||substr(v_mon,6,2)||'月'||' 水费 '||(case when length(tools.fformatnum(v_je,2))>6 then tools.fformatnum(v_je,2) else lpad(tools.fformatnum(v_je,2),6,' ')  end) ||' 元 ';
        elsif mod(v_count, P_ROW)=2 then
           str2 :=nvl(str2,'  ') || substr(v_mon,1,4)||'年'||substr(v_mon,6,2)||'月'||' 水费 '||(case when length(tools.fformatnum(v_je,2))>6 then tools.fformatnum(v_je,2) else lpad(tools.fformatnum(v_je,2),6,' ')  end)||' 元 ';
        elsif mod(v_count, P_ROW)=3 then
           str3 :=nvl(str3,'  ') || substr(v_mon,1,4)||'年'||substr(v_mon,6,2)||'月'||' 水费 '||(case when length(tools.fformatnum(v_je,2))>6 then tools.fformatnum(v_je,2) else lpad(tools.fformatnum(v_je,2),6,' ')  end)||' 元 ';
        elsif mod(v_count, P_ROW)=4 then
           str4 :=nvl(str4,'  ') || substr(v_mon,1,4)||'年'||substr(v_mon,6,2)||'月'||' 水费 '||(case when length(tools.fformatnum(v_je,2))>6 then tools.fformatnum(v_je,2) else lpad(tools.fformatnum(v_je,2),6,' ')  end)||' 元 ';
        elsif mod(v_count, P_ROW)=0 then
           str5 :=nvl(str5,'  ') || substr(v_mon,1,4)||'年'||substr(v_mon,6,2)||'月'||' 水费 '||(case when length(tools.fformatnum(v_je,2))>6 then tools.fformatnum(v_je,2) else lpad(tools.fformatnum(v_je,2),6,' ')  end)||' 元 ';
        end if;
      end if;
  end loop;
  close C_REC;
  if str1 is not null then
     str0 :='截止'||to_char(sysdate,'yyyy-mm-dd')||'欠水费['||to_char(v_allbs)||']笔['||tools.fformatnum(v_allje,2)  ||']元,'||chr(10)||'最早欠费日期:['||mindate||']-最近欠费日期['||maxdate||'],'||chr(10)||(case when v_outflagstr='Y' THEN '您的水费已发到银行扣款,' else '' end)||'欠费明细如下:'||chr(10) ;
  end if;
  RETURN nvl(str0,'')||nvl(str1,'')||chr(10)||nvl(str2,'')||chr(10)||nvl(str3,'')||chr(10)||nvl(str4,'')||chr(10)||nvl(str5,'')||nvl(str6,'');
EXCEPTION
  WHEN OTHERS THEN
    if C_REC%isopen then
      close C_REC;
    end if;
    RETURN NULL;
END;
/

