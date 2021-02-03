create or replace package body pg_pj is
  --票据处理包
  
  --补缴收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_bjsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --将应收账流水号按用户分组
    for i in (select rlcid, rldatasource, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
               group by rlcid, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.rldatasource <> 'Z' then 
        o_log := o_log || i.rlid || ' 不是补缴收费的应收账' || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' 无效的应收账流水号' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已销账，无法出票' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已冲正，无法出票' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已出票，无法重复出票' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'BJSF');
        o_log := o_log || i.rlid || ' 出票完成' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --上门收费出票
  /*
  p_rlids         应收账编码，多个按逗号分隔
  p_fkfs          付款类型(XJ 现金,ZP,支票
  */
  procedure pj_smsf(p_rlids varchar2, p_fkfs varchar2, o_log out varchar2 )is
  begin    
    --将应收账流水号按用户分组
    for i in (select rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp, listagg(t_rl.id,',') within group(order by t_rl.id) rlid
                from (select regexp_substr(p_rlids, '[^,]+', 1, level) id from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1) t_rl
                     left join bs_reclist on t_rl.id = bs_reclist.rlid
                     left join bs_custinfo on bs_reclist.rlcid = bs_custinfo.ciid
               group by rlcid, michargetype, rlpaidflag, rlreverseflag, rlifinv, isprintfp) loop
                
      if i.michargetype <> '2' then 
        o_log := o_log || i.rlid || ' 不是上门收费的用户' || i.rlcid || chr(10);
        continue;
      elsif i.rlcid is null then
        o_log := o_log || i.rlid || ' 无效的应收账流水号' || chr(10);
        continue;
      elsif i.rlpaidflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已销账，无法出票' || chr(10);
        continue;
      elsif i.rlreverseflag = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已冲正，无法出票' || chr(10);
        continue;
      elsif i.rlifinv = 'Y' or i.isprintfp = 'Y' then
        o_log := o_log || i.rlid || ' 应收账已出票，无法重复出票' || chr(10);
        continue;
      else
        pj_sf(i.rlid, p_fkfs, 'SMSF');
        o_log := o_log || i.rlid || ' 出票完成' || chr(10);
      end if;
      
    end loop;
  end;
  
  
  --票据 收费 单用户应收账
  /*
  p_rlids     应收账编码，多个按逗号分隔
  p_fkfs      付款类型(XJ 现金,ZP,支票
  p_cply      出票来源：SMSF 上门收费 BJSF 补缴收费
  */
  procedure pj_sf(p_rlids varchar2, p_fkfs varchar2, p_cply varchar2)is
    v_pj_id varchar2(10);
  begin
    v_pj_id := seq_paidbatch.nextval;

    insert into pj_inv_info(id, dyfs, status, cplx, fkfs, month, mcode, rlcname, rlcadr,  scode, ecode, sl, kpje, rlid ,cpje01, cpje02, cpje03, cply)
    with rd as (
         select rdid,
                sum(case when rdpiid = '01' then rdje end) je01 ,
                sum(case when rdpiid = '02' then rdje end) je02 ,
                sum(case when rdpiid = '03' then rdje end) je03
         from bs_recdetail
         where rdid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
         group by rdid
    )
    select v_pj_id, '0', '0','L', p_fkfs, max(rlmonth), rlcid , rlcname, rlcadr, min(rlscode) , max(rlecode), sum(rlsl) ,sum(rlje), p_rlids, sum(je01), sum(je02), sum(je03), p_cply
    from bs_reclist rl left join rd on rl.rlid = rd.rdid
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y'
    group by v_pj_id, rlcid ,rlcname, rlcadr, p_rlids;

    --更新出票标志
    update bs_reclist 
    set rlifinv = 'Y', isprintfp = 'Y' 
    where rlid in (select regexp_substr(p_rlids, '[^,]+', 1, level) pid from dual connect by level <= length(p_rlids) - length(replace(p_rlids, ',', '')) + 1)
          and rlpaidflag <> 'Y'
          and rlreverseflag <> 'Y';
    commit;
  end;

end pg_pj;
/

