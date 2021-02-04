CREATE OR REPLACE PACKAGE BODY HRBZLS."TOOLS" is

  function f0null(p_n in number) return number is
  begin
    if p_n=0 then
      return null;
    else
      return p_n;
    end if;
  end;

  function fnull0(p_n in number) return number is
  begin
    if p_n is null then
      return 0;
    else
      return p_n;
    end if;
  end;

  --构造所有下级子表集合
  procedure getmeterchildall(p_mid in varchar2,
                             p_mitab in out tminfotree) is
    mi tmeterinfo;
    cursor c_child is
    select micid,miid,mismfid,miclass,miflag,mipid
    from meterinfo
    where mipid = p_mid;
  begin
    mi := tmeterinfo(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    open c_child;
    loop
    fetch c_child into mi.micid,mi.miid,mi.mismfid,mi.miclass,mi.miflag,mi.mipid ;
    exit when c_child%notfound or c_child%notfound is null;
      --追加子表记录到table表
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --递归子表
      getmeterchildall(mi.miid,p_mitab);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;

  --构造非末级子表集合1
  procedure getmeterchild(p_mid in varchar2,
                          p_mitab in out tminfotree) is
    mi tmeterinfo;
    cursor c_child is
    select micid,miid,mismfid,miclass,miflag,mipid
    from meterinfo
    where mipid = p_mid and miflag='N';
  begin
    mi := tmeterinfo(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    open c_child;
    loop
    fetch c_child into mi.micid,mi.miid,mi.mismfid,mi.miclass,mi.miflag,mi.mipid ;
    exit when c_child%notfound or c_child%notfound is null;
      --追加子表记录到table表
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --递归子表
      getmeterchild(mi.miid,p_mitab);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;

  --构造父表集合1
  procedure getmeterparent(p_mid in varchar2,
                           p_mitab in out tminfotree) is
    mi tmeterinfo;
    i number;
    bexist integer:= 0;
    cursor c_parent is
    select micid,miid,mismfid,miclass,miflag,mipid
    from meterinfo where miid=(select mipid from meterinfo where miid=p_mid);
  begin
    mi := tmeterinfo(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    open c_parent;
    loop
    fetch c_parent into mi.micid,mi.miid,mi.mismfid,mi.miclass,mi.miflag,mi.mipid ;
    exit when c_parent%notfound or c_parent%notfound is null;
      --追加子表记录到table表
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
         getmeterparent(mi.miid,p_mitab);
      else
         bexist := 0;
         for i in 1..p_mitab.count loop
           if p_mitab(i).milabelno=mi.milabelno then
             bexist := 1;
             exit;
           end if;
         end loop;

         if bexist=0 then
           p_mitab.extend;
           p_mitab(p_mitab.last) := mi;
           getmeterparent(mi.miid,p_mitab);
         end if;
      end if;
    end loop;
    close c_parent;

  exception when others then
    if c_parent%isopen then
      close c_parent;
    end if;
  end;

  --构造非末级子表集合2
  /*procedure getmeterchildlist(p_mid in varchar2,
                              p_mitab in out tminfotree,
                              numrowtotal in out number) is
    mi tmeterinfo;
    cursor c_child is
    select ciid,miid,mibfid||trim(to_char(mirorder,'0000')),cicode,ciname,ciadr,mino,micaliber,cistatus
    From custinfo,meterinfo
    where ciid=micid and mipid = p_mid and miflag='N';
  begin
    mi :=tmeterinfo(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    open c_child;
    loop
    fetch c_child into mi.ciid,mi.miid,mi.cmcbh,mi.cicode,mi.ciname,mi.ciadr,mi.milabelno,mi.micaliber,mi.cistatus;
    exit when c_child%notfound or c_child%notfound is null;
      numrowtotal := numrowtotal + 1;
      mi.rn := numrowtotal;
      --追加子表记录到table表
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --递归子表
      getmeterchildlist(mi.miid,p_mitab,numrowtotal);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;*/

  --构造父表集合2
  /*procedure getmeterparentlist(p_mid in varchar2,
                               p_mitab in out tminfotree,
                               numrowtotal  in out number) is
    mi tmeterinfo;
    i number;
    bexist integer := 0;
    cursor c_parent is
    select ciid,miid,mibfid||trim(to_char(mirorder,'0000')),cicode,ciname,ciadr,mino,micaliber,cistatus
    from custinfo,meterinfo
    where ciid=micid and miid=(select mipid from meterinfo where miid=p_mid);
  begin
    mi := tmeterinfo(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);

    open c_parent;
    loop
    fetch c_parent into mi.ciid,mi.miid,mi.cmcbh,mi.cicode,mi.ciname,mi.ciadr,mi.milabelno,mi.micaliber,mi.cistatus;
    exit when c_parent%notfound or c_parent%notfound is null;
      --追加子表记录到table表
      if p_mitab is null then
         numrowtotal:=numrowtotal+1;
         mi.rn:=numrowtotal;
         p_mitab := Tminfotree(mi);
         getmeterparentlist(mi.miid,p_mitab,numrowtotal);--递归父表
      else
         bexist := 0;
         for i in 1..p_mitab.count loop
            if p_mitab(i).miid=mi.miid then
               bexist := 1;
               exit;
            end if;
         end loop;

         if bexist=0 then
           numrowtotal:=numrowtotal+1;
           mi.rn:=numrowtotal;
           p_mitab.extend;
           p_mitab(p_mitab.last) := mi;
           getmeterparentlist(mi.miid,p_mitab,numrowtotal);--递归父表
         end if;
      end if;
    end loop;
    close c_parent;

  exception when others then
    if c_parent%isopen then
      close c_parent;
    end if;
  end;*/

  function fgetpmonth(p_month in varchar2,p_cycid in char) return varchar2 is
    cursor c_cyc is
    select t.scdsmid
    from syscycdetail t
    where t.scdschid = p_cycid and t.scdsmid <= to_number(substr(p_month,6,2))
    order by scdsmid desc;

    vmonth varchar2(10);
    vm number;
  begin
    open c_cyc;
    fetch c_cyc into vm;
    if c_cyc%notfound or c_cyc%notfound is null then
       select max(scdsmid) into vm
       from syscycdetail where scdschid = p_cycid;
       if vm is null then
          return null;
       end if;
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'))||'.01';
       vmonth := substr(to_char(add_months(to_date(vmonth,'yyyy.mm.dd'),-12),'yyyy.mm.dd'),1,7);
    else
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'));
    end if;
    close c_cyc;

    return vmonth;
  end;

  function fgetaheadmonth(p_month in varchar2,p_cycid in char) return varchar2 is
    cursor c_cyc is
    select t.scdsmid
    from syscycdetail t
    where t.scdschid = p_cycid and t.scdsmid < to_number(substr(p_month,6,2))
    order by scdsmid desc;

    vmonth varchar2(10);
    vm number;
  begin
    open c_cyc;
    fetch c_cyc into vm;
    if c_cyc%notfound or c_cyc%notfound is null then
       select max(scdsmid) into vm
       from syscycdetail where scdschid = p_cycid;
       if vm is null then
          return null;
       end if;
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'))||'.01';
       vmonth := substr(to_char(add_months(to_date(vmonth,'yyyy.mm.dd'),-12),'yyyy.mm.dd'),1,7);
    else
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'));
    end if;
    close c_cyc;

    return vmonth;
  end;

  function fgetmonth(p_month in varchar2,p_cycid in char) return varchar2 is
    cursor c_cyc is
    select t.scdsmid
    from syscycdetail t
    where t.scdschid = p_cycid and t.scdsmid >= to_number(substr(p_month,6,2))
    order by scdsmid asc;

    vmonth varchar2(10);
    vm number;
  begin
    open c_cyc;
    fetch c_cyc into vm;
    if c_cyc%notfound or c_cyc%notfound is null then
       select min(scdsmid) into vm
       from syscycdetail where scdschid = p_cycid;
       if vm is null then
          return null;
       end if;
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'))||'.01';
       vmonth := substr(to_char(add_months(to_date(vmonth,'yyyy.mm.dd'),12),'yyyy.mm.dd'),1,7);
    else
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'));
    end if;
    close c_cyc;

    return vmonth;
  end;

  function fgetnextmonth(p_month in varchar2,p_cycid in char) return varchar2 is
    cursor c_cyc is
    select t.scdsmid
    from syscycdetail t
    where t.scdschid = p_cycid and t.scdsmid > to_number(substr(p_month,6,2))
    order by scdsmid asc;

    vmonth varchar2(10);
    vm number;
  begin
    open c_cyc;
    fetch c_cyc into vm;
    if c_cyc%notfound or c_cyc%notfound is null then
       select min(scdsmid) into vm
       from syscycdetail where scdschid = p_cycid;
       if vm is null then
          return null;
       end if;
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'))||'.01';
       vmonth := substr(to_char(add_months(to_date(vmonth,'yyyy.mm.dd'),12),'yyyy.mm.dd'),1,7);
    else
       vmonth := substr(p_month,1,4)||'.'||trim(to_char(vm,'00'));
    end if;
    close c_cyc;

    return vmonth;
  end;

  procedure sp_createcal is
    sdate date;
    edate date;
    i integer;
  begin
    select max(caldate)+1 into sdate from calendar;
    if sdate is null then
       sdate := to_date('20000101','yyyymmdd');
    end if;
    edate := to_date(to_char(sdate,'yyyy')||'1201','yyyymmdd');
    edate := last_day(edate);

    for i in 0..(edate - sdate)
    loop
      insert into calendar
      values(sdate+i,to_number(to_char(sdate+i-1,'d')),'0',null);
    end loop;

    commit;
  end;

  function  fgetpaymonth(p_smfid in varchar2) return varchar2 is
v_month varchar2(7);
 begin
  --实收月份
  --return   fpara(p_smfid,'000010');
    return to_char(sysdate, 'yyyy.mm'); --【哈尔滨】账务月份取自然月份
    /*select
 (case
   when to_number(to_char(sysdate, 'dd')) <= to_number(
   fpara(p_smfid,'000010')
   ) then
    to_char(sysdate, 'yyyy.mm')
   else
    to_char(add_months(sysdate, 1), 'yyyy.mm')
 end) into v_month
  from dual;*/

   return v_month ;
    --return fpara(p_smfid,'000010');
    exception when others then
   return to_char(sysdate, 'yyyy.mm') ;
  end;

  function  fgetrecmonth(p_smfid in varchar2) return varchar2 is
  begin
  --应月份
    --return fpara(p_smfid,'000008');
      return to_char(sysdate, 'yyyy.mm'); --【哈尔滨】账务月份取自然月份
  end;

  function fgetinvmonth(p_smfid in varchar2) return varchar2 is

  v_month varchar2(7);
 begin
 /*--发票月份
    select
 (case
   when to_number(to_char(sysdate, 'dd')) <= to_number(
   fpara(p_smfid,'000007')
   ) then
    to_char(sysdate, 'yyyy.mm')
   else
    to_char(add_months(sysdate, 1), 'yyyy.mm')
 end) into v_month
  from dual;

   return v_month ;*/
     return to_char(sysdate, 'yyyy.mm'); --【哈尔滨】账务月份取自然月份

   -- return fpara(p_smfid,'000007');
  end;

  function fgetreadmonth(p_smfid in varchar2) return varchar2 is
  begin
  --抄表月份
    return fpara(p_smfid,'000009');
  end;

  function fgetinvdate(p_smfid in varchar2) return varchar2 is
  begin
  --本期票务日期
     return to_char(sysdate,'yyyy.mm.dd') ;
    --return fpara(p_smfid,'000002');
  end;

  function  fgetpaydate(p_smfid in varchar2) return date is
  begin
  --本期实收帐务日期
      return trunc(sysdate);
    --return to_date(fpara(p_smfid,'000014'),'yyyy.mm.dd');
  end;

  function  fgetrecdate(p_smfid in varchar2) return date is
  begin
  --本期应收帐务日期
      return trunc(sysdate);
    --return to_date(fpara(p_smfid,'000013'),'yyyy.mm.dd');
  end;

/*  --取当月营业所抄表计划月份
  FUNCTION fGetmeterplanMon(p_smfid in VARCHAR2) RETURN varchar2 is
  BEGIN
    return fpara(p_smfid,'000009');
  END;*/

  FUNCTION fGetSysDate RETURN DATE
  AS
	  xtrq	DATE;
  BEGIN
    select to_date(to_char(sysdate,'YYYYMMDD'),'YYYY/MM/DD') INTO xtrq
	  FROM dual;
	RETURN xtrq;
  END;

function fmidn_sepmore(p_str in varchar2,p_sep in varchar2) return integer is
  --help:
  --tools.fmidn_sepmore('@#null@#123@#321@#456@#','@#')=5
  --tools.fmidn_sepmore(null,'@#')=0
  --tools.fmidn_sepmore('','@#')=0
  --tools.fmidn_sepmore('null','@#')=1
    i integer;
    n integer:=1;
    V_SEPLEN  number;
  begin
   V_SEPLEN := length(p_sep);
    IF V_SEPLEN<=0 THEN
      RETURN 0;
    END IF ;
    if trim(p_str) is null then
      return 0;
    else
      for i in 1..length(p_str)
      loop
        if substr(p_str,i,V_SEPLEN)=p_sep  then
          n := n +1;
        end if;
      end loop;
    end if;

    return n;
  end;

-- tools.fmid_sepmore 增加函数 fmid_sepmore

 function fmid_sepmore(p_str in varchar2,p_n in number,p_null in char,p_sep in varchar2) return varchar2 is
  --help:
  --tools.fmid_sepmore('@#null@#123@#321@#456@#',2,'N','@#')='null'
  --tools.fmid_sepmore('@#null@#123@#321@#456@#',2,'N','@#')=NULL
    vstr arr;
    vintstr varchar2(30000);
    i number;
    V_SEPLEN  number;
    V_LOOPCOUNT  number;

    v_count number;
  begin
    V_SEPLEN := length(p_sep);
    IF V_SEPLEN<=0 THEN
      RETURN '';
    END IF ;

    v_count :=0 ;--不需要累加的字符数
    for i in 1..length(p_str)
    loop
       if substr(p_str,i,V_SEPLEN)=p_sep then

         v_count :=V_SEPLEN - 1;
         if p_null='Y' then
         if lower(vintstr)='null' then
            vintstr := null;
         end if;
         end if;
         if vstr is null then
           vstr := arr(vintstr);
         else
           vstr.extend;
           vstr(vstr.last) := vintstr;
         end if;
         vintstr := null;
      elsif i=length(p_str) then
         IF v_count>0 THEN
           v_count :=v_count - 1;
         ELSE
             if vstr is null then
               vstr := arr(vintstr||substr(p_str,i,1));
             else
               vstr.extend;
               vstr(vstr.last) := vintstr||substr(p_str,i,1);
             end if;
         END IF;
      else
         IF v_count>0 THEN
           v_count :=v_count - 1;
         ELSE
            vintstr := vintstr||substr(p_str,i,1);
         end if;
      end if;
    end loop;
    return trim(vstr(p_n));
  exception when others then
    return null;
  end;

  function fmidn(p_str in varchar2,p_sep in varchar2) return integer is
  --help:
  --tools.fmidn('/123/123/123/','/')=5
  --tools.fmidn(null,'/')=0
  --tools.fmidn('','/')=0
  --tools.fmidn('null','/')=1
    i integer;
    n integer:=1;
  begin
    if trim(p_str) is null then
      return 0;
    else
      for i in 1..length(p_str)
      loop
        if substr(p_str,i,1)=p_sep then
          n := n +1;
        end if;
      end loop;
    end if;

    return n;
  end;

  function fmid(p_str in varchar2,p_n in number,p_null in char,p_sep in varchar2) return varchar2 is
  --help:
  --tools.fmid('/null/123/321/456/',2,'N','/')='null'
  --tools.fmid('/null/123/321/456/',2,'Y','/')=NULL
    vstr arr;
    vintstr varchar2(30000);
    i number;
  begin
    for i in 1..length(p_str)
    loop
      if substr(p_str,i,1)=p_sep then
         if p_null='Y' then
         if lower(vintstr)='null' then
            vintstr := null;
         end if;
         end if;
         if vstr is null then
           vstr := arr(vintstr);
         else
           vstr.extend;
           vstr(vstr.last) := vintstr;
         end if;
         vintstr := null;
      elsif i=length(p_str) then
         if vstr is null then
           vstr := arr(vintstr||substr(p_str,i,1));
         else
           vstr.extend;
           vstr(vstr.last) := vintstr||substr(p_str,i,1);
         end if;
      else
         vintstr := vintstr||substr(p_str,i,1);
      end if;
    end loop;
    return trim(vstr(p_n));
  exception when others then
    return null;
  end;
  ---------------------------------------------------------------------------------
  --本函数和下面同名的函数为重载函数
  function fgetpara(p_parastr in varchar2,rown in integer,coln in integer)
  return varchar2 is
    --一维数组规则：#####|####|####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'数组字符串格式错误'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--一行读完
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;
       when ',' then--一列读完
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            vstr := '';
          end;
       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;

  function fgetpara(p_parastr in clob,rown in integer,coln in integer)
  return varchar2 is
    --一维数组规则：#####|####|####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'数组字符串格式错误'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--一行读完
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;
       when ',' then--一列读完
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            vstr := '';
          end;
       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;

  function fgetpara2(p_parastr in clob,rown in integer,coln in integer)
  return varchar2 is
    --一维数组规则：#####|####|####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'数组字符串格式错误'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--一行读完(每行只一列)
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;

       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;

  function fboundpara(p_parastr in clob) return integer is
    --一维数组规则：#####,####,####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    i integer;
    n integer:=0;
    vchar nchar(1);
  begin
    for i in 1..length(p_parastr) loop
      vchar := substr(p_parastr,i,1);
      if vchar='|' then
        n := n+1;
      end if;
    end loop;

    return n;
  end;

  function fboundpara2(p_parastr in varchar2) return integer is
    --一维数组规则：#####,####,####|
    --二维数组规则：#####,####,####|#####,####,#######|##,####,####|
    i integer;
    n integer:=0;
    vchar nchar(1);
  begin
    for i in 1..length(p_parastr) loop
      vchar := substr(p_parastr,i,1);
      if vchar=',' then
        n := n+1;
      end if;
    end loop;

    return n+1;
  end;

  function fuppernumber(input_nbr in number default 0) return varchar2 is
  /*函数名称: fuppernumber
    用 于: 将以分为单位输入的数值转换为大写汉字形式
    注 释: 当转换后的汉字以分结尾时,不加“整”,当以角或元结尾时加“整”,这符合银行的规定。
    数字金额凡是中间出现0的,必须转为大写的“零”,连续多个0时只转为一个“零”字,
    结尾出现0时要加“整”,结尾不是0时不加“整”,这与前面的规定是一致的。
    由于圆是货币单位,所以在多于1元钱时,圆是必须出现的。但是,万佰等是数字单位,有
    时可能不出现。*/
    input_nbr_bak  number(20); /*用于接收输入参数 input_nbr */
    num_character  varchar2(20) := '零壹贰叁肆伍陆柒捌玖';
    unit_character varchar2(40) := '分角元拾佰仟万拾佰仟亿拾佰仟万拾佰仟亿';
    output_string  varchar2(100) := '';
    remain_nbr     number(20);
    bit_num        number(20); /*每一位上的数字*/
    bit_unit       varchar2(2); /*每一位所对的单位*/
    bit_indic      number(1) := 0; /*每一位的数字是否为0,0表示为0,1表示不为0*/
    i              number(2) := 0; /*循环次数,索引变量从0开始*/
    spe_unit       varchar2(2) := 'a'; /*特殊位,包括万和亿,表示该亿汉字是否已写入结果字串*/
    sign_indic     varchar2(1); /*用于标志数值符号:0为正,1为负*/
  begin

    if input_nbr = 0 then
      return '零元整';
    elsif input_nbr > 0 then
      sign_indic    := '0';
      input_nbr_bak := input_nbr * 100;
    elsif input_nbr < 0 then
      sign_indic    := '1';
      input_nbr_bak := -input_nbr * 100;
    end if;
    loop
      remain_nbr    := floor(input_nbr_bak / 10); /*取出除后的商*/
      bit_num       := input_nbr_bak - remain_nbr * 10; /*取出当前位的数值*/
      input_nbr_bak := remain_nbr; /*保存商以做下一次循环*/
      bit_unit      := rtrim(substr(unit_character, i + 1, 1)); /*取出当前位的单位汉字*/
      if bit_num > 0 then
        /*当前位的值不为0*/
        bit_indic := 1;
        if i = 6 or i = 14 then
          /*当前位是'万'位或'万亿'位*/
          spe_unit := '万'; /*表示万已经写入output_string中,在bit_unit中会包含万字*/
        elsif (i >= 7 and i <= 9) or (i >= 15 and i <= 17) then
          /*当前位在万及千万之间或万亿及千万亿之间*/
          if spe_unit != '万' then
            /*万还没写入output_string中,则要写入一次*/
            output_string := '万' || output_string;
            spe_unit      := '万'; /*表示万已经写入output_string中*/
          end if;
        end if; /*高于千万亿的数本程序不考虑了*/
        output_string := substr(num_character, bit_num + 1, 1) || bit_unit ||
                         output_string;
      else
        /*当前位等于0时,走此分支*/
        if bit_indic = 1 then
          /*当前位的前一位不为0时写
              零 */
          output_string := '零' || output_string;
        end if;
        if bit_unit in ('元', '亿') then
          /*若已达圆位,则圆是必须出现的,由于亿太大,不与万相同处理,所以就与圆一样处理*/
          spe_unit      := bit_unit; /*保存圆与亿,以与万相区别*/
          output_string := bit_unit || output_string;
        end if;
        bit_indic := 0; /*当前位的值为0*/
      end if;
      i := i + 1;
      exit when input_nbr_bak = 0;
    end loop;
    if mod(input_nbr, 0.1) = 0 then
      /*输入的数字没有分,最小的是角,则尾部串个整*/
      output_string := output_string || '整';
    end if;
    if sign_indic = '1' then
      output_string := '负' || output_string;
    end if;
    return output_string;
  end;

  function fformatnum(p_n in number,p_float in integer) return varchar2 is
   vformat varchar2(64);
    v_fh varchar2(64);
    v_n number;
  begin

    if p_n>= 0 then
       v_fh :='';
    else
       v_fh :='-';
    end if;
    v_n :=abs(p_n) ;

    if v_n>=0 and v_n<1 then
       if p_float>0 then
          vformat := rpad('0.', 2+p_float, '9');
       else
          vformat := '0';
       end if;
    elsif v_n>=1 then
       if p_float>0 then
          vformat := rpad('9999999999.', 11+p_float, '9');
       else
          vformat := '9999999999';
       end if;
    end if;

    return v_fh||trim(to_char(v_n,vformat));
  end;

  function fgetznlimitday return integer is
    vday integer;
  begin
    select to_number(spvalue)
    into vday
    from syspara
    where spid='0030';
    return vday;
  exception when others then
    return 9999999999;
    --raise_application_error(errcode,'取全局违约金宽限天数参数错误');
  end;

  function fgetznscale return number is
    vs number;
  begin
    select to_number(spvalue)
    into vs
    from syspara
    where spid='0031';
    return vs;
  exception when others then
    return 0;
    --raise_application_error(errcode,'取全局违约金收取比例参数错误');
  end;
  --营业所收滞金额比例
  function fgetsmfidznscale(p_smfid in varchar2) return number is
    vs number;
  begin
    select to_number(SMPPVALUE)
    into vs
    from sysmanapara
    where SMPID=p_smfid
    and SMPPID='SMFZNJ';
    return vs;
  exception when others then
    return 0;
    --raise_application_error(errcode,'取全局违约金收取比例参数错误');
  end;
  --营业所收滞金宽限天数
  function fgetsmfidzndays(p_smfid in varchar2) return number is
    vs number;
  begin
    select to_number(SMPPVALUE)
    into vs
    from sysmanapara
    where SMPID=p_smfid
    and SMPPID='SMFZNJDAYS';
    return vs;
  exception when others then
    return 0;
    --raise_application_error(errcode,'取全局违约金收取比例参数错误');
  end;


  procedure sp_login(p_wsid in varchar2,
                     p_oper in varchar2,
                     p_hostname in varchar2,
                     p_memo in varchar2) is
  begin
    --raise_application_error(errcode,p_wsid||','||to_char(p_date)||','||p_oper||','||p_hostname);
    begin
      
    null;
    
    /*  insert into workstation
        (wsid, wsname, wsstatus, wsonline,
         wsoperid, wshostname, wsmemo)
      values
        (p_wsid, null, 'Y', sysdate,
         p_oper, p_hostname, p_memo);
    exception when others then
      begin
        update workstation
           set wsonline = sysdate,
               wsoperid = p_oper,
               wshostname = p_hostname,
               wsmemo = p_memo
         where wsid = p_wsid;
      end;*/
    end;
    commit;
  exception when others then
    raise_application_error(errcode,'当前工作站登录异常，可能造成打印模板失效！');
  end;


  function fgetznscale02 return number is
    vs number;
  begin
    select to_number(spvalue)
    into vs
    from syspara
    where spid='0047';
    return vs;
  exception when others then
    return 0;
    --raise_application_error(errcode,'取全局违污水费约金收取比例参数错误');
  end;

  function  getmin(n1 in number,n2 in number)
  return number
  is
  begin
      if nvl(n1,0) <= nvl(n2,0) then
         return nvl(n1,0);
      else
         return nvl(n2,0);
      end if;
  end getmin;

  function  getmax(n1 in number,n2 in number)
  return number
  is
  begin
      if nvl(n1,0) >= nvl(n2,0) then
         return nvl(n1,0);
      else
         return nvl(n2,0);
      end if;
  end getmax;

  function fgetinvprop(p_id in varchar2,no in integer) return varchar2 is
    rn varchar2(500);
  begin
    case no
       when 1 then
          select t.itproperty1 into rn from invoicetype t where t.itid= p_id;
       when 2 then
          select t.itproperty2 into rn from invoicetype t where t.itid= p_id;
       when 3 then
          select t.itproperty3 into rn from invoicetype t where t.itid= p_id;
       when 4 then
          select t.itproperty4 into rn from invoicetype t where t.itid= p_id;
       when 5 then
          select t.itproperty5 into rn from invoicetype t where t.itid= p_id;
       else return null;
    end case;

    return rn;
  end;

--生成单据游水号

 PROCEDURE SP_BillSeq
   (vBillId  IN  varCHAR2,
    vBillSeqno   OUT varCHAR2,
    vCommit    IN varCHAR2 default 'Y')
  AS
    lseq number;
  BEGIN
/*  IF LTRIM(vBillId) IS NULL THEN
     raise_application_error(-20201,'传递参数错误,请检查!');
  END IF;
  \*YYMM+单据类别+流水号*\
  BEGIN
  select ltrim(rtrim(to_char(fGetSysDate,'YYMM')||BMType)),
        BMSeq + 1
  into vBillSeqno,lseq
  from BillMAIN
  where BMId=vBillid
  for update;
  EXCEPTION WHEN OTHERS THEN
     raise_application_error(-20201,'获得单据初始序号错误,请检查!');
  END;*/
  BEGIN
/*   select vBillSeqno||lPad(lseq,10 - length(vBillSeqno),'0')
    into vBillSeqno from dual;*/
   vBillSeqno := FGETSEQUENCE('SEQ_BILLSEQNO');
  EXCEPTION WHEN OTHERS THEN
     raise_application_error(-20201,'根据规则生成单据号错误,请检查!');
  END;
  update Billmain
    set BMSeq = BMseq + 1
  where BMId=vBillid;
  if vCommit='Y' then
  COMMIT;
  end if;
  EXCEPTION WHEN OTHERS THEN
   ROLLBACK;
   Raise;
  END;
  FUNCTION fGetmeterplanMon(p_smfid in VARCHAR2) RETURN varchar2 is
  BEGIN
    return fpara(p_smfid,'000009');
  END;
/*系统任务号*/
PROCEDURE sp_execprc(vtaskid IN VARCHAR2,  /*系统任务号*/
               vpara IN VARCHAR2 DEFAULT NULL)
    AS
	   lProcName 		varchar2(250);
     dest_cursor 	integer;
     rowp				integer;
     Row_task    TaskDefine%RowType;
    BEGIN
	  BEGIN
		  SELECT * INTO row_task FROM TASKDEFINE
	 	   WHERE tdid = vtaskid;
	  EXCEPTION WHEN OTHERS THEN
        raise_application_error( -20201,vtaskid||'任务未定义,请检查!');
	  END;
	  IF LTRIM(vpara) IS NULL THEN
		  lProcName := 'BEGIN  '||row_task.TDmproc||';  END;';  /*执行主过程*/
	  ELSE
		  lProcName := 'BEGIN  '||row_task.TDmproc||'('||vpara||');  END;';
	  END IF;
	  dest_cursor := dbms_sql.open_cursor;
	  dbms_sql.parse(dest_cursor,lProcName,dbms_sql.V7);
	  rowp 	:= dbms_sql.execute(dest_cursor);
	  dbms_sql.close_cursor(dest_cursor);
    COMMIT;
  EXCEPTION WHEN OTHERS THEN
    IF dbms_sql.is_open(dest_cursor) THEN
      dbms_sql.close_cursor(dest_cursor);
    END IF;
    ROLLBACK;
    Raise;
  END;

/*****************************************************************************
后台任务事件记录
  时间id序列  seq_event_bk
  后台事件记录表EVENT_BACKGROUND
*****************************************************************************/
PROCEDURE SP_BKEVENT_REC(P_TASKNAME VARCHAR2,
                                               P_TASKSTEP NUMBER,
                                               P_STEPMSG VARCHAR2,
                                               P_PARAS VARCHAR2)  AS
   V_ID  NUMBER;
   V_ETIME DATE;
   V_ECODE NUMBER;
   V_EMSG VARCHAR2(1000);
BEGIN
   SELECT SYSDATE,SEQ_EVENT_BK.NEXTVAL INTO V_ETIME,V_ID FROM DUAL;
   V_EMSG:=sqlerrm;
   V_ECODE:=sqlcode;
   INSERT INTO EVENT_BACKGROUND
   VALUES
     (V_ID,
      V_ETIME,
      V_ECODE,
      V_EMSG,
      P_TASKNAME,
      P_TASKSTEP,
      P_STEPMSG,
      P_PARAS,
      '');

   commit;


END SP_BKEVENT_REC;

/*****************************************************************************
后台任务事件记录
  时间id序列  seq_event_bk
  后台事件记录表EVENT_BACKGROUND
*****************************************************************************/
PROCEDURE SP_BKEVENT_REC(P_TASKNAME VARCHAR2,
                                               P_TASKSTEP NUMBER,
                                               P_STEPMSG VARCHAR2,
                                               P_PARAS VARCHAR2,
                                               P_COMMIT VARCHAR2
                                               )  AS
   V_ID  NUMBER;
   V_ETIME DATE;
   V_ECODE NUMBER;
   V_EMSG VARCHAR2(1000);
   V_TS  VARCHAR2(20);
BEGIN
   SELECT SYSDATE,SEQ_EVENT_BK.NEXTVAL INTO V_ETIME,V_ID FROM DUAL;
   V_EMSG:=sqlerrm;
   V_ECODE:=sqlcode;

/*   V_TS:= to_char(current_timestamp(3),'HH24:MI:SSXFF');*/
   SELECT  to_char(current_timestamp(3),'HH24:MI:SSXFF') INTO V_TS FROM DUAL;
   INSERT INTO EVENT_BACKGROUND
   VALUES
     (V_ID,
      V_ETIME,
      V_ECODE,
      V_EMSG,
      P_TASKNAME,
      P_TASKSTEP,
      P_STEPMSG,
      V_TS,
      '');
/*
   commit;
   */

END SP_BKEVENT_REC;

--生成验证码
PROCEDURE SP_OAIC  AS
   OA  OPERACCNT%ROWTYPE;
   CURSOR C_OAIC IS
   SELECT * FROM OPERACCNT WHERE OAICFLAG='Y';
BEGIN
   OPEN C_OAIC;
    LOOP
      FETCH C_OAIC
        INTO OA;
      EXIT WHEN C_OAIC%NOTFOUND OR C_OAIC%NOTFOUND IS NULL;
      select TRIM(TO_CHAR(trunc(dbms_random.value(1,999999)),'000000')) INTO OA.OAIC from dual;
      UPDATE OPERACCNT
      SET OAIC=OA.OAIC
      WHERE OAID=OA.OAID;
    END LOOP;
   CLOSE C_OAIC;
   commit;
   

END SP_OAIC;

function fgetinsertchar(p_num in number,p_char varchar2)
  return varchar2 is
    --规则：p_num=2 p_char=' ret ''
    
    ret varchar2(10000);
  begin
    
    for i in 1..p_num loop
        ret := ret||p_char;
    end loop;
    
    if p_num<=0 then
       return '';
    end if;
    return ret;
  end;
  

PROCEDURE sp_fgetpcodetemp(p_rllist in varchar2,P_RLJE IN NUMBER,ret out varchar2)
  as
    --参数：p_rllist
    --XXXX|XXXX|XXXX|
    
    --ret    varchar2(10);
    v_col  number;
    i      number;
    v_rlid reclist.rlid%type;
    RL     RECLIST%ROWTYPE;
    PPT    PAY_PARA_TMP%ROWTYPE;
    VJE    RECLIST.RLJE%TYPE;
begin
  ret := 'Y';
  VJE := 0;
  if p_rllist is null then
     ret := 'N';
     return;
  end if;
  
  v_col := tools.fmidn(p_rllist,'|') - 1;
  for i in 1..v_col loop
      v_rlid := tools.fgetpara2(p_rllist,i,1);
      BEGIN
      select *
        INTO RL
        from reclist
       where rlid = v_rlid
         --and rloutflag = 'Y'   --20140515 前台做限制后台不做判断，允许销走收合收老账
         and rlpaidflag = 'N'
         and rlreverseflag = 'N'
         AND rlbadflag = 'N';
          BEGIN  
             SELECT * INTO PPT FROM PAY_PARA_TMP WHERE MID=RL.RLMID;
             PPT.PLIDS := SUBSTR(PPT.PLIDS,1,LENGTH(PPT.PLIDS)-1)||','||RL.RLID||'|';
             PPT.RLJE  := PPT.RLJE + RL.RLJE;
             PPT.RLSXF := PPT.RLSXF + RL.RLSXF;
             PPT.RLZNJ := PPT.RLZNJ + RL.RLZNJ;
             UPDATE PAY_PARA_TMP P
             SET P.PLIDS=PPT.PLIDS,
                 P.RLJE=PPT.RLJE,
                 P.RLSXF=PPT.RLSXF,
                 P.RLZNJ=PPT.RLZNJ
             WHERE P.MID=PPT.MID;
          EXCEPTION
             WHEN OTHERS THEN
             
             INSERT INTO PAY_PARA_TMP
			       VALUES (RL.RLMID,V_RLID||'|',RL.RLJE,RL.RLSXF,RL.RLZNJ) ;    
          END;
          
          VJE := VJE + nvl(RL.RLJE,0) + nvl(RL.RLSXF,0) + nvl(RL.RLZNJ,0);
      EXCEPTION
         WHEN OTHERS THEN
         ret := 'N';    
      END;
      
  end loop;
  IF VJE<>P_RLJE THEN
     ret := 'N';    
  END IF;
  
end sp_fgetpcodetemp;


end tools;
/

