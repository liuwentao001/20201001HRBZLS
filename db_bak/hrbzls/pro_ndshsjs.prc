create or replace procedure hrbzls.pro_ndshsjs is
  v_mibfid1 varchar2(20);
  v_mibfid2 varchar2(20);
  type c_mi is ref cursor;
  c_nd c_mi;
begin
  open c_nd for
    select trim(mibfid1), trim(mibfid2) from handle_unit;
  fetch c_nd
    into v_mibfid1, v_mibfid2;
  while c_nd%found loop
    if length(v_mibfid1) = 8 and length(v_mibfid2) = 8 then
      insert into handle_hs
        select concat(concat(v_mibfid1, '-'), v_mibfid2),
               mipfid,
               rlsl,
               sum(1) hs,
               0 js,
               MICHARGETYPE,
               0,
               0
          from (select round(SUM(RLSL) / 12, 0) rlsl,
                       miid,
                       mipfid,
                       MICHARGETYPE,
                       mipriid
                  from reclist, meterinfo
                 where miid = rlmid
                   and RLTRANS NOT IN
                       ('13', '14', '21', '23', LOWER('U'), LOWER('V'))
                   AND RLREVERSEFLAG = 'N'
                   AND rlbadflag = 'N'
                   AND RLMONTH >= '2014.01'
                   AND RLMONTH <= '2014.12'
                   and MISTATUS IN ('1', '19', '24', '25', '29', '30', '27')
                   AND MIBFID >= v_mibfid1
                   AND MIBFID <= v_mibfid2
                 GROUP BY mipfid, miid, MICHARGETYPE, mipriid)
         group by mipfid, rlsl, MICHARGETYPE;
      /*            select concat(concat(v_mibfid1,'-'),v_mibfid2),mipfid,rlsl, sum( case when miid=mipriid and miid=rlmid then 1 else 0 end) hs,sum(case when miid=rlmid then 1 else 0 end ) js ,MICHARGETYPE,
       sum( case when miid=mipriid then 1 else 0 end ) sjhs,count(miid) sjjs
       from (select  round(SUM(RLSL) / 12, 0) rlsl,rlmid
               from reclist where                              
                RLTRANS NOT IN
                    ('13', '14', '21', '23', LOWER('U'), LOWER('V'))
                AND RLREVERSEFLAG = 'N'
                AND rlbadflag = 'N'
                AND RLMONTH >= '2014.01'
                AND RLMONTH <= '2014.12' 
              GROUP BY rlmid) a ,meterinfo
        where miid=rlmid(+) and MISTATUS IN ('1', '19', '24', '25', '29', '30', '27') AND MIBFID >=v_mibfid1 AND MIBFID<=v_mibfid2
      group by mipfid,rlsl,MICHARGETYPE;*/
    else
      if length(v_mibfid1) = 8 then
        v_mibfid1 := v_mibfid1 || '0';
      end if;
      if length(v_mibfid1) = 7 then
        v_mibfid1 := '0' || v_mibfid1;
      end if;
      if length(v_mibfid2) = 8 then
        v_mibfid2 := v_mibfid2 || '999';
      end if;
      if length(v_mibfid2) = 7 then
        v_mibfid2 := '0' || v_mibfid2;
      end if;
      insert into handle_hs
        select concat(concat(v_mibfid1, '-'), v_mibfid2),
               mipfid,
               rlsl,
               sum(1) hs,
               0,
               MICHARGETYPE,
               0,
               0
          from (select round(SUM(RLSL) / 12, 0) rlsl,
                       mipfid,
                       MICHARGETYPE,
                       mipriid
                  from reclist, meterinfo
                 where miid = rlmid
                   and RLTRANS NOT IN
                       ('13', '14', '21', '23', LOWER('U'), LOWER('V'))
                   AND RLREVERSEFLAG = 'N'
                   AND rlbadflag = 'N'
                   AND RLMONTH >= '2014.01'
                   AND RLMONTH <= '2014.12'
                   and MISTATUS IN ('1', '19', '24', '25', '29', '30', '27')
                   and concat(MIBFID, to_char(MIRORDER)) >= v_mibfid1
                   AND concat(MIBFID, to_char(MIRORDER)) <= v_mibfid2
                 GROUP BY mipfid, MICHARGETYPE, mipriid)
         group by mipfid, rlsl, MICHARGETYPE;
      /*        insert into handle_hs
       select concat(concat(v_mibfid1,'-'),v_mibfid2),mipfid,rlsl, sum( case when miid=mipriid and miid=rlmid then 1 else 0 end) hs,sum(case when miid=rlmid then 1 else 0 end ) js ,MICHARGETYPE,
          sum( case when miid=mipriid then 1 else 0 end ) sjhs,count(miid) sjjs
           from (select  round(SUM(RLSL) / 12, 0) rlsl,rlmid
                  from reclist where                              
                   RLTRANS NOT IN
                       ('13', '14', '21', '23', LOWER('U'), LOWER('V'))
                   AND RLREVERSEFLAG = 'N'
                   AND rlbadflag = 'N'
                   AND RLMONTH >= '2014.01'
                   AND RLMONTH <= '2014.12' 
                 GROUP BY rlmid) a ,meterinfo
           where miid=rlmid(+) and MISTATUS IN ('1', '19', '24', '25', '29', '30', '27') AND concat(MIBFID,to_char(MIRORDER)) >=v_mibfid1 AND concat(MIBFID,to_char(MIRORDER))<=v_mibfid2
         group by mipfid,rlsl,MICHARGETYPE;
      */
    end if;
    fetch c_nd
      into v_mibfid1, v_mibfid2;
  end loop;
  close c_nd;
  commit;
end pro_ndshsjs;
/

