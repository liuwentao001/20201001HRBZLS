create or replace package body pg_chkout is
  --对账处理程序包
  
  /*
  生成建账工单        
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数：  p_userid        收费员编码
  */
  procedure ins_jzgd(p_userid varchar2) is
    v_chkdate date;
    v_deptid varchar2(20); 
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    
    --获取操作员最后对账时间
    select chk_date, dept_id into v_chkdate, v_deptid from sys_user where user_id = p_userid;
    
    --生成对账信息
    insert into request_jzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hauditflag, hauditdate, hauditper,  hauditno,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch, st_sdate, st_edate
    )
    select v_reno reno, v_deptid resmfid,
    
           sum(case when ppayway in ('XJ','ZP') then 1 else 0 end) hcount,         --收款总笔数（=现金总笔数+支票总笔数）
           sum(case when ppayway in ('XJ','ZP') then ppayment else 0 end) hje,   --收款总金额（=现金总金额+支票总金额）
           null hqc,             --期初预存
           null hfs,             --预存发生
           null hqm,            --期末预存
           
           null hsf,              --水费
           null hwsf,             --污水费
           null hljf,             --垃圾费
           null hznj,             --违约金
           null hfpsl,            --票据张数（=有效发票数+作废发票数）
           null hauditflag,       --发出标志(总财务)
           null hauditdate,       --发出时间(总财务)
           null hauditper,        --发出人(总财务)
           null hauditno,         --发出单号
           
           sum(case when ppayway = 'XJ' then ppayment else 0 end) hxjje,       --现金总金额（=现金实际金额+现金冲正金额）
           sum(case when ppayway = 'ZP' then ppayment else 0 end) hzpje,       --支票总金额（=支票实际金额+支票冲正金额）
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then ppayment else 0 end) hcolumn1,    --现金实际金额
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn2,    --现金冲正金额
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then ppayment else 0 end) hcolumn3,    --支票实际金额
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then ppayment else 0 end) hcolumn4,    --支票冲正金额
           
           null hcolumn5,        --违约金笔数
           null hcolumn6,        --手续费笔数
           null hcolumn7,        --手续费
           
           sum(case when ppayway = 'XJ' then 1 else 0 end) hcolumn8,             --现金总笔数（=现金实际笔数-现金冲正笔数）
           sum(case when ppayway = 'ZP' then 1 else 0 end) hcolumn9,             --支票总笔数（=支票实际笔数-支票冲正笔数）
           sum(case when ppayway = 'XJ' and preverseflag = 'N' then 1 else 0 end) hcolumn10,    --现金实际笔数
           sum(case when ppayway = 'XJ' and preverseflag = 'Y' then 1 else 0 end) hcolumn11,    --现金冲正笔数
           sum(case when ppayway = 'ZP' and preverseflag = 'N' then 1 else 0 end) hcolumn12,    --支票实际笔数
           sum(case when ppayway = 'ZP' and preverseflag = 'Y' then 1 else 0 end) hcolumn13,    --支票冲正笔数
           
           sum(case when preverseflag = 'N' then 1 else 0 end) hcolumn14,           --实际总笔数（=现金实际笔数+支票实际笔数）
           sum(case when preverseflag = 'N' then ppayment else 0 end) hcolumn15,    --实际总金额（=现金实际金额+支票实际金额）
           sum(case when preverseflag = 'Y' then 1 else 0 end) hcolumn16,           --冲正总笔数（=现金冲正笔数+支票冲正笔数）
           sum(case when preverseflag = 'Y' then ppayment else 0 end) hcolumn17,    --冲正总金额（=现金冲正金额+支票冲正金额）
           
           null hcolumn18,            --有效发票数
           null hcolumn19,            --作废发票数
           
           sum(case when ppayway = 'DC' then 1 else 0 end) hcolumn20,                                        --倒存总笔数（=倒存实际总笔数-倒存冲正总笔数） 
           sum(case when ppayway = 'DC' and preverseflag = 'N' then 1 else 0 end) hcolumn21,                 --倒存实际总笔数
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then 1 else 0 end) hcolumn22,                 --倒存冲正总笔数
           sum(case when ppayway = 'DC' then ppayment else 0 end) hcolumn23,                                 --倒存总金额（=倒存实际总金额-倒存冲正总金额）
           sum(case when ppayway = 'DC' and preverseflag = 'N' then ppayment else 0 end) hcolumn24,          --倒存实际总金额 
           sum(case when ppayway = 'DC' and preverseflag = 'Y' then ppayment else 0 end) hcolumn25,          --倒存冲正总金额
           
           sum(case when ppayway = 'MZ' then 1 else 0 end) hcolumn26,                                        --抹账总笔数（=抹账实际总笔数-抹账冲正总笔数）
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then 1 else 0 end) hcolumn27,                 --抹账实际总笔数
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then 1 else 0 end) hcolumn28,                 --抹账冲正总笔数
           sum(case when ppayway = 'MZ' then ppayment else 0 end) hcolumn29,                                 --抹账总金额（=抹账实际总金额-抹账冲正总金额）
           sum(case when ppayway = 'MZ' and preverseflag = 'N' then ppayment else 0 end) hcolumn30,          --抹账实际总金额 
           sum(case when ppayway = 'MZ' and preverseflag = 'Y' then ppayment else 0 end) hcolumn31,          --抹账冲正总金额
           
           sum(case when ppayway = 'POS' then ppayment else 0 end) hcolumn32,                                        --POS总金额（=POS实际金额+POS冲正金额）
           sum(case when ppayway = 'POS' and preverseflag = 'N' then ppayment else 0 end) hcolumn33,                 --POS实际金额
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then ppayment else 0 end) hcolumn34,                 --POS冲正金额pos实际笔数 
           sum(case when ppayway = 'POS' then 1 else 0 end) hcolumn35,                                               --POS总笔数（=POS实际笔数-POS冲正笔数）
           sum(case when ppayway = 'POS' and preverseflag = 'N' then 1 else 0 end) hcolumn36,                        --POS实际笔数 
           sum(case when ppayway = 'POS' and preverseflag = 'Y' then 1 else 0 end) hcolumn37,                        --POS冲正笔数
           
           null reappnote, null restaus, null reper, null reflag,
           null enabled,
           null sortcode, null deletemark, sysdate createdate, p_userid createuserid, null createusername,
           null modifydate, null modifyuserid, null modifyusername,
           null remark, null workno, null workbatch, v_chkdate st_sdate, sysdate st_edate
    from bs_payment
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null
          and (preverseflag = 'N' or (preverseflag = 'Y' and ppayment > 0)) ;
    
    --更新对账信息水费，污水费
    update request_jzgd 
    set (hsf,hwsf,hljf) = (select 
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
    )
    where reno = v_reno;
    
    --更新期初、期末
    update request_jzgd
    set (hqc, hfs, hqm) = (select sum(hqc),sum(hqm) - sum(hqc),sum(hqm)
                               from (select distinct pcid, 
                                            first_value(psavingqc) over (partition by pcid order by pdatetime) hqc,
                                            first_value(psavingqc) over (partition by pcid order by pdatetime desc) hqm
                                       from bs_payment
                                      where ppayee = p_userid
                                            and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
                                            and pchkno is null) t );
    
    --更新交易信息
    update bs_payment 
    set pchkno = v_reno 
    where ppayee = p_userid
          and (pdatetime >= v_chkdate or v_chkdate is null) and pdatetime <= sysdate
          and pchkno is null;
    
    --更新操作员信息
    update sys_user set chk_date = sysdate where user_id = p_userid;
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  删除建账工单
  收费员结账   收费员可对自己自上次结账到当前时间的收费记录进行结账的功能。
  参数     p_reno      建账工单编码
  */
  procedure del_jzgd(p_reno varchar2) is
    v_chkdate date;
    v_userid varchar2(50);
  begin
    select st_sdate, createuserid into v_chkdate, v_userid from request_jzgd where reno = p_reno;
    --更新操作员信息
    update sys_user set chk_date = v_chkdate where user_id = v_userid;
    --更新交易信息
    update bs_payment set pchkno = null where pchkno = p_reno;
    --删除建账工单
    delete from request_jzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  生成对账工单        
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_deptid    机构编码
  */
  procedure ins_dzgd(p_deptid varchar2) is
    v_reno varchar2(10);
  begin
    v_reno := seq_jzgd.nextval;
    --生成对账信息
    insert into request_dzgd(reno, resmfid,
           hcount, hje, hqc, hfs,  hqm,
           hsf, hwsf, hljf, hznj, hfpsl,
           hxjje, hzpje, hcolumn1,  hcolumn2, hcolumn3,  hcolumn4,
           hcolumn5,  hcolumn6, hcolumn7,
           hcolumn8,  hcolumn9, hcolumn10, hcolumn11, hcolumn12, hcolumn13,
           hcolumn14, hcolumn15, hcolumn16, hcolumn17,
           hcolumn18, hcolumn19,
           hcolumn20, hcolumn21, hcolumn22, hcolumn23, hcolumn24, hcolumn25,
           hcolumn26, hcolumn27, hcolumn28, hcolumn29, hcolumn30, hcolumn31,
           hcolumn32, hcolumn33, hcolumn34, hcolumn35, hcolumn36, hcolumn37,
           reappnote, restaus, reper, reflag,
           enabled,
           sortcode,  deletemark, createdate,  createuserid, createusername,
           modifydate,  modifyuserid, modifyusername,
           remark,  workno,  workbatch)
    select v_reno reno, resmfid,
           sum(hcount), sum(hje), sum(hqc), sum(hfs), sum(hqm),
           sum(hsf), sum(hwsf), sum(hljf), sum(hznj), sum(hfpsl),
           sum(hxjje), sum(hzpje), sum(hcolumn1),  sum(hcolumn2), sum(hcolumn3),  sum(hcolumn4),
           sum(hcolumn5),  sum(hcolumn6), sum(hcolumn7),
           sum(hcolumn8),  sum(hcolumn9), sum(hcolumn10), sum(hcolumn11), sum(hcolumn12), sum(hcolumn13),
           sum(hcolumn14), sum(hcolumn15), sum(hcolumn16), sum(hcolumn17),
           sum(hcolumn18), sum(hcolumn19),
           sum(hcolumn20), sum(hcolumn21), sum(hcolumn22), sum(hcolumn23), sum(hcolumn24), sum(hcolumn25),
           sum(hcolumn26), sum(hcolumn27), sum(hcolumn28), sum(hcolumn29), sum(hcolumn30), sum(hcolumn31),
           sum(hcolumn32), sum(hcolumn33), sum(hcolumn34), sum(hcolumn35), sum(hcolumn36), sum(hcolumn37),
           null reappnote,null  restaus, null reper, null reflag,
           null enabled,
           null sortcode,  null deletemark, null createdate,  null createuserid, null createusername,
           null modifydate, null  modifyuserid, null modifyusername,
           null remark,  null workno,  null workbatch
    from request_jzgd 
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y'
    group by resmfid;
    
    --更新建账信息
    update request_jzgd 
    set   dzgd_no = v_reno, rewcbz = 'Y'
    where resmfid = p_deptid and reshbz = 'Y' and rewcbz <> 'Y';
    
    commit;
  exception
    when others then rollback;
  end;
  
  /*
  删除对账工单        
  对账管理   地区财务对各收费员结账的汇总管理功能，汇总后可发给集团财务。
  参数     p_reno    对账工单  编码
  */  
  procedure del_dzgd(p_reno varchar2) is
  begin
    --更新建账信息
    update request_jzgd set dzgd_no = null, rewcbz = 'N' where dzgd_no = p_reno;
    --删除对账工单
    delete from request_dzgd where reno = p_reno;
    commit;
  exception
    when others then rollback;
  end;
  
end pg_chkout;
/

