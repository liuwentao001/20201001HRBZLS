CREATE OR REPLACE PROCEDURE HRBZLS."SP_DYSLZJB" (p_month date) is
 v_month varchar2(20);
 cursor c_dytqndz is
    select mismfid,

       micper,
       mibfid,
       rlmonth,
       to_char(case
                 when sum(b01 + b02 + b03 + b04 + b05) = 0 or sum(rlsl) = 0 then
                  0
                 else
                  sum(b01 + b02 + b03 + b04 + b05) / sum(rlsl)
               end,
               '0.00') dj,
       sum(rlsl) rlsl,
       sum(b01 + b02 + b03 + b04 + b05) rlje
  from (select miid,
               max(micper) micper,
               max(mismfid) mismfid,
               max(mibfid) mibfid,
               max(rlmonth) rlmonth,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = v_month and rdpiid = '01' then
                       rdje
                      else
                       0
                    end)) b01,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = v_month and rdpiid = '02' then
                       rdje
                      else
                       0
                    end)) b02,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = v_month and rdpiid = '03' then
                       rdje
                      else
                       0
                    end)) b03,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = v_month and rdpiid = '04' then
                       rdje
                      else
                       0
                    end)) b04,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = v_month and rdpiid = '05' then
                       rdje
                      else
                       0
                    end)) b05,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = to_number(substr(v_month, 1, 4)) - 1 || '.' ||
                           substr(v_month, 6, 7) and rdpiid = '01' then
                       rdje
                      else
                       0
                    end)) q01,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = to_number(substr(v_month, 1, 4)) - 1 || '.' ||
                           substr(v_month, 6, 7) and rdpiid = '02' then
                       rdje
                      else
                       0
                    end)) q02,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = to_number(substr(v_month, 1, 4)) - 1 || '.' ||
                           substr(v_month, 6, 7) and rdpiid = '03' then
                       rdje
                      else
                       0
                    end)) q03,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = to_number(substr(v_month, 1, 4)) - 1 || '.' ||
                           substr(v_month, 6, 7) and rdpiid = '04' then
                       rdje
                      else
                       0
                    end)) q04,
               sum(decode(rlcd, 'DE', 1, -1) *
                   (case
                      when rlmonth = to_number(substr(v_month, 1, 4)) - 1 || '.' ||
                           substr(v_month, 6, 7) and rdpiid = '05' then
                       rdje
                      else
                       0
                    end)) q05,
               case
                 when max(rlmonth) = v_month then
                  decode(MAX(rlcd), 'DE', 1, -1) * max(rlsl)
                 else
                  0
               end rlsl
          from recdetail, reclist
          left join (select miid, micper, mismfid, mibfid
                      from meterinfo, custinfo
                     where micid = ciid) mi
            on (mi.miid(+) = rlmid)
         where rlid = rdid
           and rdje > 0
           and rlmonth = v_month
         group by miid)
 group by micper, mismfid, mibfid, rlmonth;

 v_dytqndz dytqndz%rowtype;

begin
  v_month := to_char(p_month,'yyyy.mm');
  open c_dytqndz;
  LOOP
    FETCH c_dytqndz
      INTO v_dytqndz;
    EXIT WHEN c_dytqndz%NOTFOUND OR c_dytqndz%NOTFOUND IS NULL;
  insert into dytqndz values(v_dytqndz.mismfid,v_dytqndz.micper,v_dytqndz.mibfid,v_dytqndz.rlmonth,v_dytqndz.zhdj,v_dytqndz.rlsl,v_dytqndz.rlje);
  end loop;
  close c_dytqndz;
commit;
exception
  when others then
    rollback;
end;
/

