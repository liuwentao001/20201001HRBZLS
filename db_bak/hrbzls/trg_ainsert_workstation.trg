CREATE OR REPLACE TRIGGER HRBZLS."TRG_AINSERT_WORKSTATION"
  AFTER INSERT ON WORKSTATION
  FOR EACH ROW
DECLARE
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  INSERT INTO WORKPRINTSET
    SELECT :NEW.WSID,T.WPSITID, SEQ_PRINTTEMPLATEHD.NEXTVAL
      FROM WORKPRINTSET T, DYNDWPRINT T1
     WHERE T.WPSWSID = '0000'
       AND T.WPSPTHID = T1.DYDPID
       AND T.WPSITID = T1.DYDPTYPE;
  INSERT INTO WORKPRINTSET
    SELECT :NEW.WSID, T.WPSITID, SEQ_PRINTTEMPLATEHD.NEXTVAL
      FROM WORKPRINTSET T, PRINTTEMPLATEHD T1
     WHERE T.WPSWSID = '0000'
       AND T.WPSPTHID = T1.PTHID
       AND T.WPSITID = T1.PTHITID;

  INSERT INTO DYNDWPRINT
    select t3.wpspthid,
           t1.dydpdwname,
           t1.dydptitle,
           t1.dydpheight,
           t1.dydpwidth,
           t1.dydplastpage,
           t1.dydpcolumns,
           t1.dydpdwblod,
           t1.marginleft,
           t1.marginright,
           t1.margintop,
           t1.marginbottom,
           t1.dydfalg,
           t1.dydptype,
           t1.dydpflag
      from WORKPRINTSET t,
           DYNDWPRINT t1,
           (select * from WORKPRINTSET t2 where t2.wpswsid = :NEW.WSID) t3
     WHERE T.WPSWSID = '0000'
       AND T1.DYDPID = t.wpspthid
       AND T.WPSITID = T1.DYDPTYPE
       and t3.wpsitid = T.WPSITID;

  INSERT INTO printtemplatehd
    select t3.wpspthid,
           t1.pthname,
           t1.pthitid,
           t1.pthpaperheight,
           t1.pthpaperwidth,
           t1.lastpage,
           t1.columns,
           t1.marginleft,
           t1.marginright,
           t1.margintop,
           t1.marginbottom,
           t1.pthflag
      from WORKPRINTSET t,
           printtemplatehd t1,
           (select * from WORKPRINTSET t2 where t2.wpswsid = :NEW.WSID) t3
     WHERE T.WPSWSID = '0000'
       AND T1.PTHID = t.wpspthid
       AND T.WPSITID = T1.PTHITID
       and t3.wpsitid = T.WPSITID;

  INSERT INTO printtemplatedt
   select t3.wpspthid,
       t4.ptditemno,
       t4.ptditemname,
       t4.ptdx,
       t4.ptdy,
       t4.ptdheight,
       t4.ptdwidth,
       t4.ptdfontname,
       t4.ptdfontsize,
       t4.ptdfontalign

  from WORKPRINTSET t,
       printtemplatehd t1,
       (select * from WORKPRINTSET t2 where t2.wpswsid =:NEW.WSID) t3,
       printtemplatedt t4
 WHERE T.WPSWSID = '0000'
   AND T1.PTHID = t.wpspthid
   AND T.WPSITID = T1.PTHITID
   and t3.wpsitid = T.WPSITID
   and t1.pthid = t4.ptdid;


   INSERT INTO printtemplatedt_str
   select t3.wpspthid,
       t4.ptditemno,
       t4.ptditemname,
       t4.ptdx,
       t4.ptdy,
       t4.ptdheight,
       t4.ptdwidth,
       t4.ptdfontname,
       t4.ptdfontsize,
       t4.ptdfontalign

  from WORKPRINTSET t,
       printtemplatehd t1,
       (select * from WORKPRINTSET t2 where t2.wpswsid =:NEW.WSID) t3,
       printtemplatedt_str t4
 WHERE T.WPSWSID = '0000'
   AND T1.PTHID = t.wpspthid
   AND T.WPSITID = T1.PTHITID
   and t3.wpsitid = T.WPSITID
   and t1.pthid = t4.ptdid;



END;
/

