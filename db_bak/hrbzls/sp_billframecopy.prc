CREATE OR REPLACE PROCEDURE HRBZLS."SP_BILLFRAMECOPY" (
p_type in varchar2,p_wsid in varchar2,
p_dydpid in number ,p_dydptype in varchar2) as
 v_dydpid number(10);
 V_COUNT NUMBER(10);
 wst WORKPRINTSET%rowtype;
 begin
 begin
 select WPSPTHID into v_dydpid from  WORKPRINTSET where WPSWSID=p_wsid and WPSITID=p_dydptype;
  EXCEPTION
  WHEN OTHERS THEN
     /*raise_application_error(-20010,'['||p_wsid||']工作站['||p_dydptype||']类型模板不存在');*/
     wst.wpswsid :=p_wsid ;
     wst.WPSITID :=p_dydptype ;
     select SEQ_PRINTTEMPLATEHD.NEXTVAL into  wst.WPSPTHID from dual;
     v_dydpid := wst.WPSPTHID;
     insert into WORKPRINTSET values wst;

  end;
if   p_type='1' then
delete dyndwprint t where t.dydpid=v_dydpid;
insert into  dyndwprint
(dydpid,
       dydpdwname,
       dydptitle,
       dydpheight,
       dydpwidth,
       dydplastpage,
       dydpcolumns,
       dydpdwblod,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       dydfalg,
       dydptype,
       dydpflag)
(select v_dydpid,
       dydpdwname,
       dydptitle,
       dydpheight,
       dydpwidth,
       dydplastpage,
       dydpcolumns,
       dydpdwblod,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       dydfalg,
       dydptype,
       dydpflag
  from dyndwprint t1 where t1.dydpid = p_dydpid  and  t1.dydptype=p_dydptype )
  ;
/*update  dyndwprint t set (dydpdwname,
       dydptitle,
       dydpheight,
       dydpwidth,
       dydplastpage,
       dydpcolumns,
       dydpdwblod,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       dydfalg,
       dydptype,
       dydpflag) =
(select
       dydpdwname,
       dydptitle,
       dydpheight,
       dydpwidth,
       dydplastpage,
       dydpcolumns,
       dydpdwblod,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       dydfalg,
       dydptype,
       dydpflag
  from dyndwprint t1 where t1.dydpid = p_dydpid  and  t1.dydptype=p_dydptype )
  where t.dydpid=v_dydpid;*/
elsif p_type='2' then

delete printtemplatehd t  where t.pthid =v_dydpid;
insert into printtemplatehd
(select v_dydpid,
       pthname,
       pthitid,
       pthpaperheight,
       pthpaperwidth,
       lastpage,
       columns,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       pthflag
  from printtemplatehd t1 where t1.pthid = p_dydpid  and  t1.pthitid=p_dydptype );
  /*
   update  printtemplatehd t set (
       pthname,
       pthitid,
       pthpaperheight,
       pthpaperwidth,
       lastpage,
       columns,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       pthflag
) =
(select
       pthname,
       pthitid,
       pthpaperheight,
       pthpaperwidth,
       lastpage,
       columns,
       marginleft,
       marginright,
       margintop,
       marginbottom,
       pthflag
  from printtemplatehd t1 where t1.pthid = p_dydpid  and  t1.pthitid=p_dydptype )
  where t.pthid =v_dydpid;*/

delete printtemplatedt t  where t.ptdid  =v_dydpid;

insert into printtemplatedt t
(select v_dydpid,
        ptditemno,
       ptditemname,
       ptdx,
       ptdy,
       ptdheight,
       ptdwidth,
       ptdfontname,
       ptdfontsize,
       ptdfontalign
  from printtemplatedt t1 where t1.ptdid = p_dydpid   ) ;

delete printtemplatedt_str t  where t.ptdid  =v_dydpid;
insert into printtemplatedt_str t
(select v_dydpid,
        ptditemno,
       ptditemname,
       ptdx,
       ptdy,
       ptdheight,
       ptdwidth,
       ptdfontname,
       ptdfontsize,
       ptdfontalign
  from printtemplatedt_str t1 where t1.ptdid = p_dydpid   ) ;

/*update  printtemplatedt t set (
        ptditemno,
       ptditemname,
       ptdx,
       ptdy,
       ptdheight,
       ptdwidth,
       ptdfontname,
       ptdfontsize,
       ptdfontalign
) =
(select
        ptditemno,
       ptditemname,
       ptdx,
       ptdy,
       ptdheight,
       ptdwidth,
       ptdfontname,
       ptdfontsize,
       ptdfontalign
  from printtemplatedt t1 where t1.ptdid = p_dydpid and t.ptditemno=t1.ptditemno )
  where t.ptdid  =v_dydpid;*/

else
  raise_application_error(-20010,'类别错误');
end if;
 EXCEPTION
  WHEN OTHERS THEN
       ROLLBACK;
 end;
/

