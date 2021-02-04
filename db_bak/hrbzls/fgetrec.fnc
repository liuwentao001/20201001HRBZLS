CREATE OR REPLACE FUNCTION HRBZLS."FGETREC" (p_mid in varchar2) return number is
    result number;
  begin
    select sum(recje+rdznj+rlznj)
    into result
    from
    (
      select rlid,
             sum(pije) recje,
             sum(fgetznjadj(rlid,rdpiid,rlzndate,sysdate,pije)) rdznj,
             max(fgetznjadj(rlid,'NA',rlzndate,sysdate,(rlje-rlpaidje))) rlznj
      from
      (
        select rlid,rlzndate,rlje,rlpaidje,rdpiid,sum(rdje) pije
        from reclist,recdetail
        where rlid=rdid and rlmid = p_mid and rlcd = 'DE' and
              (rlpaidflag='V' or rlpaidflag='N') and
              rdpaidflag = 'N' and rdje > 0
        group by rlid,rlzndate,rlje,rlpaidje,rdpiid
      )
    );

    return nvl(result,0);
  exception when others then
    return 0;
  end;
/

