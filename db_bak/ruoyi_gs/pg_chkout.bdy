create or replace package body pg_chkout is
  --对账处理程序包
  
  --收费员结账
  procedure chkout_by_user(p_userid varchar2) is
    v_chkdate date;
    v_reno varchar2(10);
  begin
    v_reno := seq_chkout_user.nextval;
    
    --获取操作员最后对账时间
    select chk_date into v_chkdate from sys_user where user_id = p_userid;

    --生成对账信息
    insert into chkout_user_list(reno, createdate, createuserid,
                                 je_sk, je_sj, je_cz, num_sj, num_dz, num_cz, 
                                 sf_je, wsf_je, wyj_num, wyj_je, sxf_num, sxf_je,
                                 xj_num, xj_num_sj, xj_num_cz,  xj_je, xj_je_sj, xj_je_cz,
                                 zp_num, zp_num_sj, zp_num_cz, zp_je, zp_je_sj, zp_je_cz,
                                 dc_num, dc_num_sj, dc_num_cz, dc_je, dc_je_sj, dc_je_cz,
                                 mz_num, mz_num_sj, mz_num_cz, mz_je, mz_je_sj, mz_je_cz,
                                 pj_num, pj_num_zf, pj_num_yx
                                 )
    select v_reno reno, sysdate createdate, p_userid createuserid,
    
           sum(ppayment) je_sk, 
           sum(case when preverseflag = 'N' then ppayment else 0 end) je_sj, 
           sum(case when preverseflag = 'Y' then ppayment else 0 end) je_cz, 
           sum(1) num_sj, 
           sum(case when preverseflag = 'N' then 1 else 0 end) num_dz, 
           sum(case when preverseflag = 'Y' then 1 else 0 end) num_cz, 
           
           null sf_je, 
           null wsf_je,
           null wyj_num, 
           null wyj_je, 
           null sxf_num, 
           null sxf_je,
           
           sum(case when ppayway = 'XJ' then 1 else 0 end) xj_num, 
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then 1 else 0 end) xj_num_sj, 
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then 1 else 0 end) xj_num_cz, 
           sum(case when ppayway = 'XJ' then ppayment else 0 end) xj_je,
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then ppayment else 0 end) xj_je_sj, 
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then ppayment else 0 end) xj_je_cz,
           
           sum(case when ppayway = 'ZP' then 1 else 0 end) zp_num,
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then 1 else 0 end) zp_num_sj, 
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then 1 else 0 end) zp_num_cz, 
           sum(case when ppayway = 'ZP' then ppayment else 0 end) zp_je, 
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then ppayment else 0 end)  zp_je_sj, 
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then ppayment else 0 end) zp_je_cz,
           
           sum(case when ppayway = 'DC' then 1 else 0 end) dc_num, 
           sum(case when ppayway = 'DC' and preverseflag = 'N' then 1 else 0 end) dc_num_sj, 
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then 1 else 0 end) dc_num_cz, 
           sum(case when ppayway = 'DC' then ppayment else 0 end) dc_je, 
           sum(case when ppayway = 'DC' and preverseflag = 'N' then ppayment else 0 end) dc_je_sj, 
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then ppayment else 0 end) dc_je_cz,
           
           sum(case when ppayway = 'MZ' then 1 else 0 end) mz_num, 
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then 1 else 0 end) mz_num_sj, 
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then 1 else 0 end) mz_num_cz, 
           sum(case when ppayway = 'MZ' then ppayment else 0 end) mz_je, 
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then ppayment else 0 end) mz_je_sj, 
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then ppayment else 0 end) mz_je_cz,
           
           null pj_num, 
           null pj_num_zf, 
           null pj_num_yx
    from bs_payment
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null
          and (preverseflag = 'N' or (preverseflag = 'Y' and ppayment > 0)) ;
    
    --生成对账信息明细
    insert into chkout_user_detail(reno, fpid, zpid, cid, ciname, ciadr,
                                   pdate, ppayway, preverseflag, psavingqc, psavingbq, psavingqm,
                                   je, je_sf, je_wsf, je_fjf, je_wyj,
                                   batch, pid
                                   )
    with je as(
      select  rl.rlpid id, 
              sum(rd.rdje) je,
              sum(case when rd.rdpiid = '01' then rd.rdje end) je_sf ,
              sum(case when rd.rdpiid = '02' then rd.rdje end) je_wsf,
              sum(case when rd.rdpiid = '03' then rd.rdje end) je_fjf
      from bs_reclist rl 
           left join bs_recdetail rd on rl.rlid = rd.rdid
      where rl.rlpid in (select pid 
                         from  bs_payment 
                         where ppayee = p_userid
                               and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                               and pchkno is null)
      group by rl.rlpid
    )
    select v_reno reno, null fpid, null zpid, pcid cid, null ciname, null ciadr,
           pdate, ppayway, preverseflag, psavingqc, psavingbq, psavingqm,
           je, je_sf, je_wsf, je_fjf, null je_wyj,
           v_reno batch, pid
    from bs_payment 
         left join je on bs_payment.pid = je.id
    where ppayee = p_userid
      and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
      and pchkno is null;
    
    
    --更新对账信息水费，污水费
    update chkout_user_list 
    set (sf_je,wsf_je) = (select sum(je_sf), sum(je_wsf) from chkout_user_detail where reno = v_reno)
    where reno = v_reno;
    
    --更新交易信息
    update bs_payment 
    set pchkno = v_reno 
    where ppayee = p_userid
          and pdatetime >= v_chkdate and pdatetime <= sysdate
          and pchkno is null;
    
    --更新操作员信息
    update sys_user set chk_date = sysdate where user_id = p_userid;
    
    commit;
    
  exception
    when others then rollback;
  end;
  
end pg_chkout;
/

