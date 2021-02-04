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

  --���������¼��ӱ���
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
      --׷���ӱ��¼��table��
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --�ݹ��ӱ�
      getmeterchildall(mi.miid,p_mitab);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;

  --�����ĩ���ӱ���1
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
      --׷���ӱ��¼��table��
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --�ݹ��ӱ�
      getmeterchild(mi.miid,p_mitab);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;

  --���츸����1
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
      --׷���ӱ��¼��table��
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

  --�����ĩ���ӱ���2
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
      --׷���ӱ��¼��table��
      if p_mitab is null then
         p_mitab := Tminfotree(mi);
      else
         p_mitab.extend;
         p_mitab(p_mitab.last) := mi;
      end if;
      --�ݹ��ӱ�
      getmeterchildlist(mi.miid,p_mitab,numrowtotal);
    end loop;
    close c_child;

  exception when others then
    if c_child%isopen then
      close c_child;
    end if;
  end;*/

  --���츸����2
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
      --׷���ӱ��¼��table��
      if p_mitab is null then
         numrowtotal:=numrowtotal+1;
         mi.rn:=numrowtotal;
         p_mitab := Tminfotree(mi);
         getmeterparentlist(mi.miid,p_mitab,numrowtotal);--�ݹ鸸��
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
           getmeterparentlist(mi.miid,p_mitab,numrowtotal);--�ݹ鸸��
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
  --ʵ���·�
  --return   fpara(p_smfid,'000010');
    return to_char(sysdate, 'yyyy.mm'); --���������������·�ȡ��Ȼ�·�
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
  --Ӧ�·�
    --return fpara(p_smfid,'000008');
      return to_char(sysdate, 'yyyy.mm'); --���������������·�ȡ��Ȼ�·�
  end;

  function fgetinvmonth(p_smfid in varchar2) return varchar2 is

  v_month varchar2(7);
 begin
 /*--��Ʊ�·�
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
     return to_char(sysdate, 'yyyy.mm'); --���������������·�ȡ��Ȼ�·�

   -- return fpara(p_smfid,'000007');
  end;

  function fgetreadmonth(p_smfid in varchar2) return varchar2 is
  begin
  --�����·�
    return fpara(p_smfid,'000009');
  end;

  function fgetinvdate(p_smfid in varchar2) return varchar2 is
  begin
  --����Ʊ������
     return to_char(sysdate,'yyyy.mm.dd') ;
    --return fpara(p_smfid,'000002');
  end;

  function  fgetpaydate(p_smfid in varchar2) return date is
  begin
  --����ʵ����������
      return trunc(sysdate);
    --return to_date(fpara(p_smfid,'000014'),'yyyy.mm.dd');
  end;

  function  fgetrecdate(p_smfid in varchar2) return date is
  begin
  --����Ӧ����������
      return trunc(sysdate);
    --return to_date(fpara(p_smfid,'000013'),'yyyy.mm.dd');
  end;

/*  --ȡ����Ӫҵ������ƻ��·�
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

-- tools.fmid_sepmore ���Ӻ��� fmid_sepmore

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

    v_count :=0 ;--����Ҫ�ۼӵ��ַ���
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
  --������������ͬ���ĺ���Ϊ���غ���
  function fgetpara(p_parastr in varchar2,rown in integer,coln in integer)
  return varchar2 is
    --һά�������#####|####|####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'�����ַ�����ʽ����'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--һ�ж���
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;
       when ',' then--һ�ж���
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
    --һά�������#####|####|####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'�����ַ�����ʽ����'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--һ�ж���
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;
       when ',' then--һ�ж���
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
    --һά�������#####|####|####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'�����ַ�����ʽ����'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--һ�ж���(ÿ��ֻһ��)
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
    --һά�������#####,####,####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
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
    --һά�������#####,####,####|
    --��ά�������#####,####,####|#####,####,#######|##,####,####|
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
  /*��������: fuppernumber
    �� ��: ���Է�Ϊ��λ�������ֵת��Ϊ��д������ʽ
    ע ��: ��ת����ĺ����Էֽ�βʱ,���ӡ�����,���Խǻ�Ԫ��βʱ�ӡ�����,��������еĹ涨��
    ���ֽ����м����0��,����תΪ��д�ġ��㡱,�������0ʱֻתΪһ�����㡱��,
    ��β����0ʱҪ�ӡ�����,��β����0ʱ���ӡ�����,����ǰ��Ĺ涨��һ�µġ�
    ����Բ�ǻ��ҵ�λ,�����ڶ���1ԪǮʱ,Բ�Ǳ�����ֵġ�����,��۵������ֵ�λ,��
    ʱ���ܲ����֡�*/
    input_nbr_bak  number(20); /*���ڽ���������� input_nbr */
    num_character  varchar2(20) := '��Ҽ��������½��ƾ�';
    unit_character varchar2(40) := '�ֽ�Ԫʰ��Ǫ��ʰ��Ǫ��ʰ��Ǫ��ʰ��Ǫ��';
    output_string  varchar2(100) := '';
    remain_nbr     number(20);
    bit_num        number(20); /*ÿһλ�ϵ�����*/
    bit_unit       varchar2(2); /*ÿһλ���Եĵ�λ*/
    bit_indic      number(1) := 0; /*ÿһλ�������Ƿ�Ϊ0,0��ʾΪ0,1��ʾ��Ϊ0*/
    i              number(2) := 0; /*ѭ������,����������0��ʼ*/
    spe_unit       varchar2(2) := 'a'; /*����λ,���������,��ʾ���ں����Ƿ���д�����ִ�*/
    sign_indic     varchar2(1); /*���ڱ�־��ֵ����:0Ϊ��,1Ϊ��*/
  begin

    if input_nbr = 0 then
      return '��Ԫ��';
    elsif input_nbr > 0 then
      sign_indic    := '0';
      input_nbr_bak := input_nbr * 100;
    elsif input_nbr < 0 then
      sign_indic    := '1';
      input_nbr_bak := -input_nbr * 100;
    end if;
    loop
      remain_nbr    := floor(input_nbr_bak / 10); /*ȡ���������*/
      bit_num       := input_nbr_bak - remain_nbr * 10; /*ȡ����ǰλ����ֵ*/
      input_nbr_bak := remain_nbr; /*������������һ��ѭ��*/
      bit_unit      := rtrim(substr(unit_character, i + 1, 1)); /*ȡ����ǰλ�ĵ�λ����*/
      if bit_num > 0 then
        /*��ǰλ��ֵ��Ϊ0*/
        bit_indic := 1;
        if i = 6 or i = 14 then
          /*��ǰλ��'��'λ��'����'λ*/
          spe_unit := '��'; /*��ʾ���Ѿ�д��output_string��,��bit_unit�л��������*/
        elsif (i >= 7 and i <= 9) or (i >= 15 and i <= 17) then
          /*��ǰλ����ǧ��֮������ڼ�ǧ����֮��*/
          if spe_unit != '��' then
            /*��ûд��output_string��,��Ҫд��һ��*/
            output_string := '��' || output_string;
            spe_unit      := '��'; /*��ʾ���Ѿ�д��output_string��*/
          end if;
        end if; /*����ǧ���ڵ��������򲻿�����*/
        output_string := substr(num_character, bit_num + 1, 1) || bit_unit ||
                         output_string;
      else
        /*��ǰλ����0ʱ,�ߴ˷�֧*/
        if bit_indic = 1 then
          /*��ǰλ��ǰһλ��Ϊ0ʱд
              �� */
          output_string := '��' || output_string;
        end if;
        if bit_unit in ('Ԫ', '��') then
          /*���Ѵ�Բλ,��Բ�Ǳ�����ֵ�,������̫��,��������ͬ����,���Ծ���Բһ������*/
          spe_unit      := bit_unit; /*����Բ����,������������*/
          output_string := bit_unit || output_string;
        end if;
        bit_indic := 0; /*��ǰλ��ֵΪ0*/
      end if;
      i := i + 1;
      exit when input_nbr_bak = 0;
    end loop;
    if mod(input_nbr, 0.1) = 0 then
      /*���������û�з�,��С���ǽ�,��β��������*/
      output_string := output_string || '��';
    end if;
    if sign_indic = '1' then
      output_string := '��' || output_string;
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
    --raise_application_error(errcode,'ȡȫ��ΥԼ�����������������');
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
    --raise_application_error(errcode,'ȡȫ��ΥԼ����ȡ������������');
  end;
  --Ӫҵ�����ͽ�����
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
    --raise_application_error(errcode,'ȡȫ��ΥԼ����ȡ������������');
  end;
  --Ӫҵ�����ͽ��������
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
    --raise_application_error(errcode,'ȡȫ��ΥԼ����ȡ������������');
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
    raise_application_error(errcode,'��ǰ����վ��¼�쳣��������ɴ�ӡģ��ʧЧ��');
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
    --raise_application_error(errcode,'ȡȫ��Υ��ˮ��Լ����ȡ������������');
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

--���ɵ�����ˮ��

 PROCEDURE SP_BillSeq
   (vBillId  IN  varCHAR2,
    vBillSeqno   OUT varCHAR2,
    vCommit    IN varCHAR2 default 'Y')
  AS
    lseq number;
  BEGIN
/*  IF LTRIM(vBillId) IS NULL THEN
     raise_application_error(-20201,'���ݲ�������,����!');
  END IF;
  \*YYMM+�������+��ˮ��*\
  BEGIN
  select ltrim(rtrim(to_char(fGetSysDate,'YYMM')||BMType)),
        BMSeq + 1
  into vBillSeqno,lseq
  from BillMAIN
  where BMId=vBillid
  for update;
  EXCEPTION WHEN OTHERS THEN
     raise_application_error(-20201,'��õ��ݳ�ʼ��Ŵ���,����!');
  END;*/
  BEGIN
/*   select vBillSeqno||lPad(lseq,10 - length(vBillSeqno),'0')
    into vBillSeqno from dual;*/
   vBillSeqno := FGETSEQUENCE('SEQ_BILLSEQNO');
  EXCEPTION WHEN OTHERS THEN
     raise_application_error(-20201,'���ݹ������ɵ��ݺŴ���,����!');
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
/*ϵͳ�����*/
PROCEDURE sp_execprc(vtaskid IN VARCHAR2,  /*ϵͳ�����*/
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
        raise_application_error( -20201,vtaskid||'����δ����,����!');
	  END;
	  IF LTRIM(vpara) IS NULL THEN
		  lProcName := 'BEGIN  '||row_task.TDmproc||';  END;';  /*ִ��������*/
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
��̨�����¼���¼
  ʱ��id����  seq_event_bk
  ��̨�¼���¼��EVENT_BACKGROUND
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
��̨�����¼���¼
  ʱ��id����  seq_event_bk
  ��̨�¼���¼��EVENT_BACKGROUND
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

--������֤��
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
    --����p_num=2 p_char=' ret ''
    
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
    --������p_rllist
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
         --and rloutflag = 'Y'   --20140515 ǰ̨�����ƺ�̨�����жϣ����������պ�������
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

