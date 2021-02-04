CREATE OR REPLACE TRIGGER HRBZLS."TR_OPERACCNTPARA_AFTER_UPDATE" AFTER update
  ON operaccntpara
  FOR EACH ROW


BEGIN

  if nvl(fsyspara('data'), 'N') = 'Y' then
    return;
  end if;
  if updating('OAPVALUE') then
    if :new.OAPTYPE = '108'   then

      DELETE dwcontinfo
       WHERE
       dciftype IN (select TRIM(:new.OAPTYPE || trim(to_char(T1.FNO)))
                      from billmain t, flow_define t1
                     where t.BMID = :new.OAPTYPE
                       and t.bmflag2 = t1.fid
                       AND T1.FCHKTYPE='1' )
       AND DCIFOWNER = :new.OAPOAID;
      insert into dwcontinfo
        SELECT SEQ_DWCONTINFO.NEXTVAL,
               sysdate,
               :new.OAPTYPE || trim(to_char(FNO)),
               :new.OAPOAID,
               '',
               '',
               FPARA3,
               'zadvalue^t<=^t' || trim(to_char(:new.OAPVALUE)) || '^t^t0^t' ||
               trim(to_char(:new.OAPVALUE)) ||
               '^tnumb^tZNJADJUSTDT.zadvalue',
               'Y'

          from billmain t, flow_define t1
         where t.BMID = :new.OAPTYPE
           and t1.fchktype='1'
           and t.bmflag2 = t1.fid;

    end if;

  if :new.OAPTYPE = '110' then

      DELETE dwcontinfo
       WHERE
       dciftype IN (select TRIM(:new.OAPTYPE || trim(to_char(T1.FNO)))
                      from billmain t, flow_define t1
                     where t.BMID = :new.OAPTYPE
                       and t.bmflag2 = t1.fid
                       AND T1.FCHKTYPE='1' )
       AND DCIFOWNER = :new.OAPOAID;
      insert into dwcontinfo
        SELECT SEQ_DWCONTINFO.NEXTVAL,
               sysdate,
               :new.OAPTYPE || trim(to_char(FNO)),
               :new.OAPOAID,
               '',
               '',
               FPARA3,
               'zadvalue^t<=^t' || trim(to_char(:new.OAPVALUE)) || '^t^t0^t' ||
               trim(to_char(:new.OAPVALUE)) ||
               '^tnumb^tZNJADJUSTDT.zadvalue',
               'Y'

          from billmain t, flow_define t1
         where t.BMID = :new.OAPTYPE
           and t1.fchktype='1'
           and t.bmflag2 = t1.fid;

    end if;

  end if;
END;
/

