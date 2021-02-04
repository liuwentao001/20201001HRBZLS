CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_JOB_HRB2 AS
  
  --函数名称 : f_getCustomerPwd
  --用途: 根据用户编号返回用户的水表加密密码(已转换小写)
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 加密的用户口令(32位,小写),如果有任何异常,返回null
  --创建日期: 2015/12/8 
  function f_getCustomerPwd(ic_micid   IN    varchar2) return varchar2 AS
  c_encryptPwd  METERINFO.MIYL4%type;
  BEGIN
     select miyl4 into c_encryptPwd from meterinfo where micid = ic_micid;
     return c_encryptPwd;
  exception
    when others then
      return null;
  END f_getCustomerPwd;
  
  --过程名称 : prc_chgCustomerPwd
  --用途 : 修改客户的水表密码
  --参数：ic_micid    in  varchar2  用户编号
  --      ic_plainpwd in  varchar2  用户明文密码
  --      on_appcode  out number    返回码（成功执行返回 1,密码位数错误返回 -2 ,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）  
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_chgCustomerPwd( ic_micid      IN   varchar2,
                                ic_plainpwd   IN   varchar2,
                                on_appcode    OUT  number,
                                oc_error      OUT  varchar2
  )as
  begin
    on_appcode := 1;
    if length(ic_plainpwd) <> 6 then
       on_appcode := ERROR_CUSTOMERPWD_LENGTH;
       oc_error := '密码位数错误!';
       return;
    end if;
    update meterinfo
       set MIYL4 = md5(ic_plainpwd)
     where micid = ic_micid; 
  exception 
    when others then
      on_appcode := -1;
      oc_error := '更改用户密码错误,' || sqlerrm;
  end;
  
  --函数名称 : f_getAccountPrecash
  --用途: 根据编号返回账户的预存余额(如果是合收表,返回合收账户金额)
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 预存余额
  --创建日期: 2016/3/11
  function f_getAccountPrecash(ic_micid   IN    varchar2) return number is
  n_cash   meterinfo.misaving%type;
  begin
    select sum(nvl(misaving,0))
      into n_cash
      from meterinfo mi
     where mipriid = (select mipriid from meterinfo where micid = ic_micid);
    return n_cash;
  exception
    when others then 
      return 0;  
  end;
  
  --过程名称 : prc_meterCancellation
  --创建日期: 2016/3/14
  --用途: 撤表销户(单块水表) 简单的销户操作 不考虑财务
  --参数：ic_micid    in  varchar2  用户编号
  --      ic_trans    in  varchar2  销户事务类型
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,密码位数错误返回 -2 ,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）     
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_meterCancellation( ic_micid      IN   varchar2,
                                   ic_trans      IN   varchar2,
                                   ic_oper       IN   varchar2,
                                   on_appcode    OUT  number,
                                   oc_error      OUT  varchar2
  )is
  begin
    on_appcode := 1;
    --1.更新meterinfo主表状态
    update METERINFO
       set MISTATUS      = '7',      --销户状态
           MISTATUSDATE  = sysdate,
           MISTATUSTRANS = ic_trans,
           MIUNINSDATE   = sysdate
     where micid = ic_micid;
     
    --2.销户后同步用户状态
    UPDATE CUSTINFO
       SET CISTATUS = '7',
           cistatusdate = sysdate,
           cistatustrans = ic_trans
     WHERE CICODE = ic_micid; 
     
    --3. 去掉低度[20110702]
    UPDATE PRICEADJUSTLIST PL
       SET PL.PALSTATUS = 'N'
     WHERE PL.PALMID = ic_micid;
     
    --4.同步更新水表档案 
    update METERDOC
       set MDSTATUS = '7', 
           MDSTATUSDATE = sysdate
     where MDMID = ic_micid; 
     
    --5.作废 水表
    UPDATE ST_METERINFO_STORE
       SET STATUS = '6',       --表身码作废
           MIID = ic_micid, 
           STATUSDATE = SYSDATE
     WHERE BSM = (select mdno from meterdoc where MDMID = ic_micid );  
     
    --6.作废 封号
    UPDATE st_meterfh_store
       set fhstatus = '4',     --封号状态 作废
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   dqsfh,
                   '1',       --塑封号
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );
    UPDATE st_meterfh_store
       set fhstatus = '4',     --封号状态 作废
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   dqgfh,
                   '2',       --刚封号
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );     
    UPDATE st_meterfh_store
       set fhstatus = '4',     --封号状态 作废
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   qfh,
                   '4',       --铅封号
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );
    UPDATE st_meterfh_store
       set fhstatus = '4',     --封号状态 作废
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   jcgfh,
                   '3',       --稽查封号
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );   
                           
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;        
  end;
  
  --函数名称 : f_checkUnfinishedBill
  --用途: 根据编号返回用户未完结的工单号
  --参数：ic_micid  in varchar2  用户编号
  --返回值: 以'|'返回的工单号
  --创建日期: 2016/3/17
  function f_checkUnfinishedBill(ic_micid   IN    varchar2) return varchar2 is
  c_priid  meterinfo.mipriid%type;
  c_result varchar2(1000);
  begin
     --查询合收表号
     select mipriid into c_priid from meterinfo where micid = ic_micid;
     
     select connstr(billno) into c_result from 
     (
       --表务工单检查
       select mthno billno
         from metertranshd hd1,
              metertransdt dt1
        where hd1.mthno = dt1.mtdno and 
              dt1.mtdmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd1.MTHSHFLAG = 'N'
        union all
       select CCHNO billno
         from CUSTCHANGEHD hd2,
              CUSTCHANGEDT dt2 
        where hd2.cchno = dt2.ccdno and
              dt2.miid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd2.CCHSHFLAG = 'N'
        union all
       select rthno billno
         from RECTRANSHD hd3
        where hd3.rthmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              RTHSHFLAG = 'N' 
        union all
       select rahno billno
         from RECADJUSTHD hd4,
              RECADJUSTDT dt4
        where hd4.rahno = dt4.radno and
              dt4.RADMID in (select miid from meterinfo mi where mipriid = c_priid ) and
              hd4.RAHSHFLAG = 'N'
        union all
       select crhno billno
         from TDSJHD hd5
        where hd5.miid in (select miid from meterinfo mi where mipriid = c_priid ) and
              hd5.CRHSHFLAG = 'N' 
        union all
       select PAHNO billno
         from PAIDADJUSTHD hd6
        where HD6.PAHMID in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd6.PAHSHFLAG = 'N'
        union all
       select rchno billno
         from recczhd hd7,
              recczdt dt7
        where hd7.rchno = dt7.rcdno and
              dt7.rcdmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd7.rchshflag = 'N'
     ); 
     return c_result;        
  exception
    when others then
      return '';
  end;
  
  --函数名称 : f_getCBTFtotal
  --用途: 返回指定营业所指定账务月份撤表退费金额(审核后的)
  --参数：ic_smfid  in varchar2  营业所编号
  --      ic_month  in varchar2  账务月份(yyyy.mm)
  --返回值: 撤表退费金额
  --创建日期: 2016/3/30
  function f_getCBTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number is
  n_saving number(13,3) default 0;
  begin
    select abs(sum(ycmisaving))
      into n_saving
      from meterinfo_yccz 
     where ycmfid = decode(ic_smfid,null,ycmfid,ic_smfid) and
           ycmonth = decode(ic_month,null,ycmonth,ic_month) and
           yctype = '2';
    return nvl(n_saving,0);
  exception
    when others then 
      return 0;  
  end;
  
  --函数名称 : f_getYCTFtotal
  --用途: 返回指定营业所指定账务月份预存退费金额(审核后的)
  --参数：ic_smfid  in varchar2  营业所编号
  --      ic_month  in varchar2  账务月份(yyyy.mm)
  --返回值: 撤表退费金额
  --创建日期: 2016/3/30
  function f_getYCTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number is
  n_saving number(13,3) default 0;
  begin
    select abs(sum(ycmisaving))
      into n_saving
      from meterinfo_yccz 
     where ycmfid = decode(ic_smfid,null,ycmfid,ic_smfid) and
           ycmonth = decode(ic_month,null,ycmonth,ic_month) and
           yctype = '1';
    return nvl(n_saving,0);
  exception
    when others then 
      return 0;  
  end;
	
	--函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额
  --参数 ic_rlid   In   varchar2  应收流水号
  --返回值:对应指定应收流水号，已经调拨的预存金额
  function f_getAllotMoney(ic_rlid   IN    varchar2) return number is
  n_allotMoney  number default 0;
  begin
    select sum(BAALLOTSUM)
      into n_allotMoney
      from Baseallot ba
     where ba.barlid = ic_rlid and
           ba.bastatus = 'Y';
    return nvl(n_allotMoney,0);
  exception
    when others then
      return 0;
  end;
  
  --函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份 yyyy.mm
  --返回值:统计指定分公司指定账务业务 已经调拨的预存金额(账务月份 2016.5(含)之后,之前直接返回票面金额)
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month   IN    varchar2
  ) return number is
  n_allotMoney  number default 0;
  begin
    if ic_month >= '2016.05' then
      select sum(baAllotsum)
        into n_allotMoney
        from baseAllot ba
       where (ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
             ba.bamonth = ic_month and
             ba.bastatus = 'Y' ;
    else
/*      select sum(nvl(rlje,0)) 
        into n_allotMoney
        from reclist rl,
             payment p
       where rl.rlpid = p.pid and 
             rl.rltrans = 'u' \*基建水费*\ and   
             p.pmonth = ic_month and
             ( rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' );    */    
        select sum(nvl(RD.CHARGE1,0)) 
        into n_allotMoney
        from reclist rl,
             payment p,
             VIEW_RECLIST_CHARGE RD
       where rl.rlpid = p.pid and 
             rlid= rdid and
             rl.rltrans = 'u' /*基建水费*/ and   
             p.pmonth = ic_month and
             ( rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' );        
    end if;         
    return nvl(n_allotMoney,0);
  exception 
    when others then 
      return 0;
  end;
  
  --函数名称:f_getAllotMoney
  --用途:获取基建临时用水已调拨预存金额(汇总) 如果月份 为空 调用者要传递 'null' 字符串
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务业务 已经调拨的预存金额 (账务月份 2016.5(含)之后,之前直接返回票面金额)
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month1  IN    varchar2,
                           ic_month2  IN    varchar2
  ) return number is
  n_allotMoney  number default 0;
  n_temp        number default 0;
  c_month       varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotsum)
            into n_temp
            from baseAllot ba
           where ( ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
                 ( ba.bamonth = c_month ) and                 
                 ba.bastatus = 'Y' ;
         exception
           when no_data_found then
             n_temp := 0;
         end;        
       else
         begin
/*          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rltrans = 'u' \*基建水费*\ and   
                 p.pmonth = c_month and
                 (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' ); */
            select sum(nvl(RD.CHARGE1,0)) 
            into n_temp
            from reclist rl,
                 payment p,
                 VIEW_RECLIST_CHARGE RD
           where rl.rlpid = p.pid and 
                 RLID = RDID and 
                 rl.rltrans = 'u' /*基建水费*/ and   
                 p.pmonth = c_month and
                 (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' ); 
         exception
           when no_data_found then
             n_temp := 0;
         end;                 
       end if;
       n_allotMoney := n_allotMoney + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    return nvl(n_allotMoney,0);
  exception 
    when others then
      return 0;
  end;

  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量
  --参数 ic_rlid   In   varchar2  应收流水号
  --返回值:对应指定应收流水号，已经调拨的水量 
  function f_getAllotSl(ic_rlid   IN    varchar2) return number is
  n_allotSl  number default 0;
  n_month    varchar2(10);
  begin
 -- select rlmonth into n_month From reclist where rlid =ic_rlid ;   
  select rlpaidmonth into n_month From reclist where rlid =ic_rlid ;  -- by20191008  此处应该以销账月份进行判断
  
  if n_month >='2016.05' then
    select sum(BAALLOTSL)
      into n_allotSl
      from Baseallot ba
     where ba.barlid = ic_rlid and
           ba.bastatus = 'Y';
      return nvl(n_allotSl,0);
  else
     begin
        select sum(nvl(rlsl,0)) 
          into n_allotSl
          from reclist rl,
               payment p
         where rl.rlpid = p.pid and 
               rl.rltrans = 'u' /*基建水费*/ and   
               p.pmonth = n_month;  
               
         return nvl(n_allotsl,0); 
      exception
        when no_data_found then
          n_allotSl := 0;
      end;   
  end if;
      
  exception
    when others then
      return 0;
  end;
  
  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份
  --返回值:统计指定分公司指定账务业务 已经调拨的基建水量 (账务月份 2016.5(含)之后,之前直接返回预存水量)
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month   IN    varchar2
  ) return number is
  n_allotSl  number default 0;
  n_temp     number default 0;
  begin
    if ic_month >= '2016.05' then
      select sum(ba.baallotsl)
        into n_allotSl
        from baseAllot ba
       where (ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
             ba.bamonth = ic_month and
             ba.bastatus = 'Y' ;
    else
      begin
        select sum(nvl(rlsl,0)) 
          into n_temp
          from reclist rl,
               payment p
         where rl.rlpid = p.pid and 
               rl.rltrans = 'u' /*基建水费*/ and   
               p.pmonth = ic_month and
               (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null');   
      exception
        when no_data_found then
          n_temp := 0;
      end;                
    end if;
    
    return nvl(n_allotSl,0);
  exception 
    when others then
      return 0;
  end;
  
  --函数名称:f_getAllotSl
  --用途:获取基建临时用水已调拨水量(汇总)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务业务 已经调拨的水量 (账务月份 2016.5(含)之后,之前直接返回预存水量)
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month1  IN    varchar2,
                        ic_month2  IN    varchar2
  ) return number is
  n_allotSl  number default 0;
  c_month    varchar2(7);
  n_temp     number default 0;
  begin
    
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSl)
            into n_temp
            from baseAllot ba
           where ( decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid ) and  
                 ( ba.bamonth = c_month ) and                 
                 ba.bastatus = 'Y' ;
         exception
           when no_data_found then
             n_temp := 0;        
         end;        
       else
         begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*基建水费*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid; 
         exception
           when no_data_found then
             n_temp := 0;        
         end;                  
       end if;
       n_allotSl := n_allotSl + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
   
    return nvl(n_allotSl,0);
  exception 
    when others then
      return 0;
  end;
	
	--函数名称:f_getAllotSl_current
  --用途:获取基建临时用水已调拨水量(回收当月)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务月份 已经调拨当月的水量
  function f_getAllotSl_current(ic_smfid   IN    varchar2,       
                                ic_month1  IN    varchar2,
                                ic_month2  IN    varchar2
  ) return number is
  n_allotSl number default 0;
  n_temp    number default 0;
  c_month   varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSl)
            into n_temp
            from baseAllot ba
           where (decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid)  and 
                 (ba.bamonth = c_month) and                  
                  ba.bastatus = 'Y' and 
                  exists(select 1 from payment pm where ba.bapid = pm.pid and pm.pmonth = bamonth);
         exception
           when no_data_found then
             n_temp := 0;         
         end;         
       else
         begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rlmonth = p.pmonth and 
                 rl.rltrans = 'u' /*基建水费*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid;    
         exception
           when no_data_found then
             n_temp := 0;
         end;                   
       end if;
       
       n_allotSl := n_allotSl + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');       
    end loop;              
    return nvl(n_allotSl,0);        
  exception
    when others then
      return 0;
  end;
  
  --函数名称:f_getAllotMoney_current
  --用途:获取基建临时用水已调拨金额(回收当月)
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month1  In   varchar2  账务月份-起始
  --     ic_month2  In   varchar2  账务月份-终止 
  --返回值:统计指定分公司指定账务月份 已经调拨当月的金额
  function f_getAllotMoney_current(ic_smfid   IN    varchar2,       
                                   ic_month1  IN    varchar2,
                                   ic_month2  IN    varchar2 
  ) return number is
  n_allotMoney number default 0;
  n_temp       number default 0;
  c_month      varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSum)
            into n_temp
            from baseAllot ba
           where (decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid)  and 
                 (ba.bamonth = c_month) and                  
                  ba.bastatus = 'Y' and 
                  exists(select 1 from payment pm where ba.bapid = pm.pid and pm.pmonth = bamonth);
         exception
           when no_data_found then
             n_temp := 0;         
         end;         
       else
         begin
          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rlmonth = p.pmonth and 
                 rl.rltrans = 'u' /*基建水费*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid;
         exception 
           when no_data_found then
             n_temp := 0;        
         end;                      
       end if;
       
       n_allotMoney := n_allotMoney + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');       
    end loop;
    return nvl(n_allotMoney,0); 
  exception
    when others then
      return 0;
  end;
	
	--函数名称:f_getAllotNumber
  --用途:获取基建临时用水已调拨件数
  --参数 ic_smfid   In   varchar2  营业所
  --     ic_month   In   varchar2  账务月份-起始
  --返回值:统计指定分公司指定账务月份 已经调拨的件数
  function f_getAllotNumber(ic_smfid   IN    varchar2,       
                            ic_month   IN    varchar2 
  ) return number is
	n_count number default 0;
	begin
		 select count(distinct ba.bacid)
       into n_count
       from baseAllot ba
      where (ba.basmfid = ic_smfid or ic_smfid = 'null' or ic_smfid is null) and 
            ba.bamonth = ic_month and
            ba.bastatus = 'Y' ;
     return nvl(n_count,0);
	exception
		when others then 
			return 0;
  end;

  --过程名称 : prc_baseAllot
  --创建日期: 2016/5/17
  --用途: 基建预存水费调拨收入
  --参数：ic_rlid     in  varchar2  应收流水号
  --      in_allotSl  in  number    调拨水量
  --      in_allotJe  in  number    调拨金额
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_baseAllot        ( ic_rlid      IN   varchar2,
                                   in_allotSl   IN   varchar2,
                                   in_allotJe   IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  )is
  rec_reclist    reclist%rowType;     --应收记录
  rec_RECTRANSHD RECTRANSHD%rowType;  --基建用水立账工单记录
  n_price        number(10,2);        --水费价格
  c_umonth       varchar2(7);         --账务月份
  n_pfid         varchar2(7);         --价格分类
  c_rlscrrlid    varchar2(20);         --原应收流水
  begin
    on_appcode := 1;
    
    --检查基建调拨开关
    if FSYSPARA('base') = 'N' then
       on_appcode := -2;
       oc_error := '基建预存调拨已关闭!';
       return;
    end if;

    --检索基建应收记录
    begin
      select * into rec_reclist from reclist where rlid = ic_rlid;
    exception
      when no_data_found then
        on_appcode := -2;
        oc_error := '编号【' || ic_rlid || '】' || '的基建应收记录没有找到!';
        return;
    end;

    --检索基建用水立账工单记录
    begin
      select RLSCRRLID into c_rlscrrlid from reclist where rlid = ic_rlid;
      -- by 20191008 由于有冲正后产生的记录销账，检索工单要用原流水进行检索判断
      select * into rec_RECTRANSHD from RECTRANSHD where RTHRLID = c_rlscrrlid;
    exception
      when no_data_found then
        on_appcode := -3;
        oc_error := '编号【' || c_rlscrrlid || '】' || '的基建立账工单记录没有找到!';
        return;
    end;

    --检索水费价格
    begin
      select rd.rdysdj,rd.rdpfid into n_price,n_pfid from recdetail rd where rd.rdid = ic_rlid and rdpiid = '01';
    exception
      when no_data_found then
        on_appcode := -4;
        oc_error := '检索水费单价错误,未找到数据!';
        return;
    end;

    --检验调拨水量、金额是否有效
    if f_getAllotSl(ic_rlid) + in_allotSl > rec_reclist.rlsl then
       on_appcode := -5;
       oc_error := '本次调拨水量超过剩余可调拨水量!';
       return;
    end if;
    if f_getAllotMoney(ic_rlid) + in_allotJe > rec_reclist.rlje then
       on_appcode := -5;
       oc_error := '本次调拨金额超过剩余可调拨余额!';
       return;
    end if;
    
    --本月调拨 算入上个月收入
    c_umonth := to_char(add_months(to_date(to_char(sysdate,'yyyy.mm') || '.01','yyyy.mm.dd'),-1),'yyyy.mm');

    --插入基建预存调拨表
    insert into baseallot
    (baid, bacid, basmfid, bamonth, bapfid, baprice, baallotsl, baAllotsum, bapid, barlid, barlsl,bapaidje, baoperid, baoperdate, bastatus, bacanceloper, bacanceldate, bamemo)
    values
    ( SEQ_BASEALLOT.Nextval,        --调拨Id
      rec_reclist.rlcid,            --客户编号
      rec_reclist.rlmsmfid,         --营业所
      c_umonth,                     --调拨月份
      --rec_RECTRANSHD.rthpfid,     --价格分类  
      n_pfid,                       --价格分类  by 20191008 价格分类从应收细表中取
      n_price,                      --水费价格
      in_allotSl,                   --调拨水量
      in_allotJe,                   --调拨金额
      rec_reclist.rlpid,            --付款流水号
      ic_rlid,                      --应收流水号
      rec_reclist.rlsl,             --原应收水量
      rec_reclist.rlje,             --预存总金额
      ic_oper,                      --调拨操作员
      sysdate,                      --调拨时间
      'Y',                          --状态 'Y'=正常
      null,                         --调拨撤销人员
      null,                         --调拨撤销时间
      null                          --备注
     );

  exception
    when others then
      on_appcode := -1;
      oc_error := '基建预存调拨失败!' || sqlerrm;
  end;

  --过程名称 : prc_unbaseAllot
  --创建日期: 2016/5/17
  --用途: 取消预存水费调拨
  --参数：in_baid     in  number    调拨流水号
  --      ic_oper     in  varchar2  操作员
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_unbaseAllot      ( in_baid      IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  )is
  cursor cur_baseAllot is
    select * from Baseallot ba where baid = in_baid and ba.bastatus = 'Y' for update;
  rec_baseAllot  baseallot%rowType;
  c_umonth varchar2(7);
  begin
    on_appcode := 1;
    
    --检查基建调拨开关
    if FSYSPARA('base') = 'N' then
       on_appcode := -2;
       oc_error := '基建预存调拨已关闭!';
       return;
    end if;
    
    --调拨月份
    c_umonth := to_char(add_months(to_date(to_char(sysdate,'yyyy.mm') || '.01','yyyy.mm.dd'),-1),'yyyy.mm');
    open cur_baseAllot;

    fetch cur_baseAllot into rec_baseAllot;
    if cur_baseAllot%found then
       if rec_baseAllot.Bamonth < c_umonth then
          on_appcode := -1;
          oc_error := '只能取消当月的调拨记录!';
          return;
       end if;
       update Baseallot ba set ba.bastatus = 'N',
                            ba.bacanceloper = ic_oper,
                            ba.bacanceldate = sysdate
       where current of cur_baseAllot;
    else
       close cur_baseAllot;
       on_appcode := -2;
       oc_error := '调拨记录没找到或已经被取消!';
       return;
    end if;

    if cur_baseAllot%isopen then
       close cur_baseAllot;
    end if;

  exception
    when others then
      on_appcode := -1;
      oc_error := '取消基建预存调拨失败!' || sqlerrm;
  end;
  
  --过程名称 : prc_rpt_allot_sum
  --创建日期: 2016/5/29
  --用途: 基建预存调拨统计汇总
  --参数：ic_month    in  varchar   账务月份
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_rpt_allot_sum( ic_month     in   varchar2,
                               on_appcode   out  number,
                               oc_error     out  varchar2
  ) is
  --已有预存记录
  cursor cur_rpt is
     select *
       from RPT_BASEALLOT_SUM rpt
      where umonth = to_char(add_months(to_date(ic_month||'.01' ,'yyyy.mm.dd'),-1),'yyyy.mm') and
			      LAST_REMAIN_SL <> 0;--by 20190829 冲往年帐务的负记录也要算作基数
  --本月新增预存金额
  cursor cur_add is
    select sum(rl.rlsl) rlsl,
           sum(rl.rlje) rlje,
           max(rl.rlmonth) rlmonth, --by20190829 月末最后一天帐务算次月帐务，要与次月帐务汇总    如：1303197192 帐务月份为2018.11的数据
           rl.rlsmfid rlsmfid,
           rl.rlmid rlmid 
      from reclist rl 
     where rl.rltrans = 'u' and rl.rlpaidmonth = ic_month and rl.rlpaidflag = 'Y' /*and rl.rlreverseflag = 'N'*/ and rl.rlbadflag = 'N' 
     group by rlsmfid,rlmid
     order by rl.rlmid,rlmonth; 
  --本月调拨记录
  cursor cur_allot is
    select bacid,
           basmfid,
           sum(baallotSl) baallotSl,  --本月调拨水量
           sum(baallotSum) baallotsum --本月调拨金额
      from baseAllot ba
     where bamonth = ic_month and
           bastatus = 'Y'
     group by bacid,basmfid;
  begin
    on_appcode := 1;
    
    --生成本月汇总记录(2016.5已初始化,从下个月正常生成)
		/*if ic_month > '2016.05' then
			for rec_rpt in cur_rpt loop
				 insert into rpt_baseallot_sum
						(miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
				 values( rec_rpt.miid,
								 rec_rpt.smfid,
								 ic_month,
								 0,0,0,0,
								 rec_rpt.this_remain_sl,    --上月结余水量
								 rec_rpt.this_remain_money, --上月结余金额
								 0,
								 0
				 );       
			end loop;
    end if;*/
		
		if ic_month > '2016.05' then
			for rec_add in cur_add loop
				update rpt_baseallot_sum rpt
					 set rpt.smfid = rec_add.rlsmfid,
               rpt.add_sl = rec_add.rlsl,
               rpt.add_money = rec_add.rlje
							 
				 where rpt.miid = rec_add.rlmid and
							 rpt.umonth = ic_month;
				 if sql%rowcount = 0 then
						insert into rpt_baseallot_sum
						(miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
					 values
					 (  rec_add.rlmid,
							rec_add.rlsmfid,
							ic_month,   
							rec_add.rlsl,        --本月新增水量
							rec_add.rlje,        --本月新增金额
							0,                   --本月使用水量
							0,                   --本月使用金额
							0,                   --上月结余水量
							0,                   --上月结余金额
							rec_add.rlsl,        --本月结余水量
							rec_add.rlje         --本月结余金额
					 );
				 end if;
			end loop;
    end if;
    
    --本月调拨记录
    for rec_allot in cur_allot loop
       update rpt_baseAllot_sum rpt
          set rpt.smfid = rec_allot.basmfid,
              rpt.allot_sl = rec_allot.baallotSl,
              rpt.allot_money = rec_allot.baallotSum
        where rpt.miid = rec_allot.bacid and
              rpt.umonth = ic_month;
    end loop;
    
    --
    update rpt_baseAllot_sum rpt
       set rpt.this_remain_sl = nvl(rpt.last_remain_sl,0) + nvl(rpt.add_sl,0) - nvl(rpt.allot_sl,0),
           rpt.this_remain_money = nvl(rpt.last_remain_money,0) + nvl(rpt.add_money,0) - nvl(rpt.allot_money,0)
     where rpt.umonth = ic_month;
    
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;
  end;
  
  --过程名称: prc_rpt_allot_carryOver
  --创建日期: 2016.6
  --用途: 基建预存调拨统计表月末结转 每个自然月的最后一天晚运行,结转上月记录.
  --参数: ic_month   in   varchar2  账务月份
  --      on_appcode  out number    返回码（成功执行返回 1,其他未定义异常返回 -1 ）
  --      oc_error    out varchar2  返回错误（如有异常返回对应错误信息）
  --提交方式 ： 调用者根据返回码 提交(回滚 )
  procedure prc_rpt_allot_carryOver( ic_month   in   varchar2,
                                     on_appcode out  number,
                                     oc_error   out  varchar2
  )is
  cursor cur_rpt is
     select *
       from RPT_BASEALLOT_SUM rpt
      where umonth = ic_month and
            THIS_REMAIN_SL <> 0;--by 20190829 冲往年帐务的负记录也要算作基数
        
  begin
    on_appcode := 1;
    for rec_rpt in cur_rpt loop
         
         update rpt_baseallot_sum 
            set last_remain_sl = rec_rpt.this_remain_sl,
                last_remain_money = rec_rpt.this_remain_money
          where miid = rec_rpt.miid and
                umonth = to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm');
         if sql%rowcount = 0 then           
             insert into rpt_baseallot_sum
                (miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
             values( rec_rpt.miid,
                     rec_rpt.smfid,
                     to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm'),
                     0,0,0,0,
                     rec_rpt.this_remain_sl,    --上月结余水量
                     rec_rpt.this_remain_money, --上月结余金额
                     0,
                     0
             );   
         end if;        
    end loop;
    
    update rpt_baseAllot_sum rpt
       set rpt.this_remain_sl = nvl(rpt.last_remain_sl,0) + nvl(rpt.add_sl,0) - nvl(rpt.allot_sl,0),
           rpt.this_remain_money = nvl(rpt.last_remain_money,0) + nvl(rpt.add_money,0) - nvl(rpt.allot_money,0)
     where rpt.umonth = to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm');
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;
  end;
  
  --基建预存调拨统计表 初始化 只执行一次!!!
  PROCEDURE PRC_RPT_ALLOT_INIT is
  c_startMonth  varchar2(7) default '2016.05';
  cursor cur_reclist is
    select sum(rl.rlsl) rlsl,
           sum(rl.rlje) rlje,
           rl.rlmonth rlmonth,
           rl.rlsmfid rlsmfid,
           rl.rlmid rlmid 
      from reclist rl 
     where rl.rltrans = 'u' and rl.rlpaidflag = 'Y' and rl.rlreverseflag = 'N' and rl.rlbadflag = 'N' and rl.rlpaidmonth = c_startMonth
     group by rlsmfid,rlmid,rlmonth
     order by rl.rlmid,rl.rlmonth;
 
  begin
    --清空统计表
    execute immediate 'truncate table RPT_BASEALLOT_SUM';
    for rec_reclist in cur_reclist loop
      
       insert into rpt_baseallot_sum
          (miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
       values
       (  rec_reclist.rlmid,
          rec_reclist.rlsmfid,
          c_startMonth,
          rec_reclist.rlsl,    --本月新增水量
          rec_reclist.rlje,    --本月新增金额
          0,                   --本月使用水量
          0,                   --本月使用金额
          0,                   --上月结余水量
          0,                   --上月结余金额
          rec_reclist.rlsl ,   --本月结余水量
          rec_reclist.rlje     --本月结余金额
       );        
    end loop;
  end;
  
  --水费水量完成情况同期对比
  procedure prc_compareReport( ic_smfid       IN   varchar2,  --营业所Id
                               ic_umonth_beg  IN   varchar2,  --比较起始账务月份
                               ic_umonth_end  IN   varchar2,  --比较终止账务月份                            
                               oc_data        out  myref      --返回数据
  )is
  ic_umonth_beg2     varchar2(10);
  ic_umonth_end2     varchar2(10);
  v_居民_正常_水量1        number(14,2);
  v_居民_正常_水费1        number(14,2);
  v_居民_居民水价_水量1    number(14,2);
  v_居民_居民水价_水费1    number(14,2);
  v_非居民_源水_水量1      number(14,2);
  v_非居民_源水_水费1      number(14,2); 
  v_特业1_水量1            number(14,2);
  v_特业1_水费1            number(14,2);
  v_特业2_水量1            number(14,2);
  v_特业2_水费1            number(14,2);
  v_账面_水量1             number(14,2);
  v_账面_水费1             number(14,2); 
  
  v_居民_正常_污水量1      number(14,2);
  v_居民_正常_污水费1      number(14,2);
  v_居民_居民水价_污水量1  number(14,2);
  v_居民_居民水价_污水费1  number(14,2);
  v_非居民_源水_污水量1    number(14,2);
  v_非居民_源水_污水费1    number(14,2); 
  v_特业1_污水量1          number(14,2);
  v_特业1_污水费1          number(14,2);
  v_特业2_污水量1          number(14,2);
  v_特业2_污水费1          number(14,2);
  v_账面_污水量1           number(14,2);
  v_账面_污水费1           number(14,2); 
  
  v_补缴_水量1             number(14,2);
  v_补缴_水费1             number(14,2);
  v_基建_水量1             number(14,2);
  v_基建_水费1             number(14,2);
  
  v_补缴_污水量1           number(14,2);
  v_补缴_污水费1           number(14,2);
  v_基建_污水量1           number(14,2);
  v_基建_污水费1           number(14,2);
  
  
  
  v_居民_正常_水量2        number(14,2);
  v_居民_正常_水费2        number(14,2);
  v_居民_居民水价_水量2    number(14,2);
  v_居民_居民水价_水费2    number(14,2);
  v_非居民_源水_水量2      number(14,2);
  v_非居民_源水_水费2      number(14,2); 
  v_特业1_水量2            number(14,2);
  v_特业1_水费2            number(14,2);
  v_特业2_水量2            number(14,2);
  v_特业2_水费2            number(14,2);
  v_账面_水量2             number(14,2);
  v_账面_水费2             number(14,2); 
  
  v_居民_正常_污水量2      number(14,2);
  v_居民_正常_污水费2      number(14,2);
  v_居民_居民水价_污水量2  number(14,2);
  v_居民_居民水价_污水费2  number(14,2);
  v_非居民_源水_污水量2    number(14,2);
  v_非居民_源水_污水费2    number(14,2); 
  v_特业1_污水量2          number(14,2);
  v_特业1_污水费2          number(14,2);
  v_特业2_污水量2          number(14,2);
  v_特业2_污水费2          number(14,2);
  v_账面_污水量2           number(14,2);
  v_账面_污水费2           number(14,2); 
  
  v_补缴_水量2             number(14,2);
  v_补缴_水费2             number(14,2);
  v_基建_水量2             number(14,2);
  v_基建_水费2             number(14,2);
  
  v_补缴_污水量2           number(14,2);
  v_补缴_污水费2           number(14,2);
  v_基建_污水量2           number(14,2);
  v_基建_污水费2           number(14,2);
  begin
                      
    ic_umonth_beg2 := to_char(add_months(to_date(ic_umonth_beg,'yyyy.mm'),-12),'yyyy.mm');    
    ic_umonth_end2 := to_char(add_months(to_date(ic_umonth_end,'yyyy.mm'),-12),'yyyy.mm');    
  
    --居民
    select nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X32
                else
                  0
                end
           ),0), --居民正常：水量
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X37
                else
                  0
                end
           ),0), --居民正常: 水费
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X32
                else
                  0
                end
           ),0), --居民居民水价：水量
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X37
                else
                  0
                end
           ),0), --居民居民水价: 水费
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X32
                else
                  0
                end
           ),0), --非居民-源水：水量
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X37
                else
                  0
                end
           ),0), --非居民-源水：水费
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X32
                else
                  0
                end  
           ),0), --特业1：水量
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X37
                else
                  0
                end  
           ),0), --特业1：水费
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X32
                else
                  0
                end  
           ),0), --特业2：水量
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X37
                else
                  0
                end  
           ),0), --特业2：水费
           nvl(sum(x32),0),   --账面水量金额
           nvl(sum(x37),0),   --账面水费金额
           
           
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  W1
                else
                  0
                end
           ),0), --居民正常：污水量
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X38
                else
                  0
                end
           ),0), --居民正常: 污水费
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  W1
                else
                  0
                end
           ),0), --居民居民水价：污水量
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X38
                else
                  0
                end
           ),0), --居民居民水价: 污水费
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  W1
                else
                  0
                end
           ),0), --非居民-源水：污水量
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X38
                else
                  0
                end
           ),0), --非居民-源水：污水费
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  W1
                else
                  0
                end  
           ),0), --特业1：污水量
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X38
                else
                  0
                end  
           ),0), --特业1：污水费
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  W1
                else
                  0
                end  
           ),0), --特业2：污水量
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X38
                else
                  0
                end  
           ),0), --特业2：污水费
           nvl(sum(w1),0),   --账面污水量金额
           nvl(sum(x38),0)   --账面污水费金额
      into v_居民_正常_水量1,
           v_居民_正常_水费1,
           v_居民_居民水价_水量1,
           v_居民_居民水价_水费1,
           v_非居民_源水_水量1,
           v_非居民_源水_水费1,
           v_特业1_水量1,
           v_特业1_水费1,
           v_特业2_水量1,
           v_特业2_水费1,
           v_账面_水量1,
           v_账面_水费1,
           
           v_居民_正常_污水量1,
           v_居民_正常_污水费1,
           v_居民_居民水价_污水量1,
           v_居民_居民水价_污水费1,
           v_非居民_源水_污水量1,
           v_非居民_源水_污水费1,
           v_特业1_污水量1,
           v_特业1_污水费1,
           v_特业2_污水量1,
           v_特业2_污水费1,
           v_账面_污水量1,
           v_账面_污水费1 
      from rpt_sum_read rpt
     where u_month >= ic_umonth_beg and 
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;
           
    --补缴水量1
/*    select nvl(sum(x79),0) into v_补缴_水量1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
     SELECT nvl(sum(X32),0) into v_补缴_水量1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
    --补缴水费1       
/*    select nvl(sum(x80),0) into v_补缴_水费1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;  */      
     SELECT nvl(sum(X37),0) into v_补缴_水费1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23'); 
            
    --基建水量1
    v_基建_水量1 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
      
    --基建水费1       
    v_基建_水费1 := f_getAllotMoney(ic_smfid,ic_umonth_beg,ic_umonth_end);
           
    --补缴污水量1
/*    select nvl(sum(x81),0)-nvl(sum(w2),0) into v_补缴_污水量1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
     SELECT nvl(sum(w4),0) into v_补缴_污水量1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23'); 
    --补缴污水费1       
/*    select nvl(sum(x82),0) into v_补缴_污水费1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */  
    SELECT nvl(sum(x38),0) into v_补缴_污水费1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
           
    --基建污水量1
/*    select nvl(sum(x74),0) into v_基建_污水量1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
           
     SELECT nvl(sum(W3),0) into v_基建_污水量1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='基建'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
           
           
    --基建污水费1       
/*    select nvl(sum(x75),0) into v_基建_污水费1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;  */

     SELECT nvl(sum(X22),0) into v_基建_污水费1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='基建'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');         
    
    
    --------------  对比年度数据 -------------------------------------------------------------------------
    
    --居民
    select nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X32
                else
                  0
                end
           ),0), --居民正常：水量
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X37
                else
                  0
                end
           ),0), --居民正常: 水费
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X32
                else
                  0
                end
           ),0), --居民居民水价：水量
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X37
                else
                  0
                end
           ),0), --居民居民水价: 水费
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X32
                else
                  0
                end
           ),0), --非居民-源水：水量
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X37
                else
                  0
                end
           ),0), --非居民-源水：水费
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X32
                else
                  0
                end  
           ),0), --特业1：水量
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X37
                else
                  0
                end  
           ),0), --特业1：水费
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X32
                else
                  0
                end  
           ),0), --特业2：水量
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X37
                else
                  0
                end  
           ),0), --特业2：水费
           nvl(sum(x32),0),   --账面水量金额
           nvl(sum(x37),0),   --账面水费金额
           
           
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  W1
                else
                  0
                end
           ),0), --居民正常：污水量
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X38
                else
                  0
                end
           ),0), --居民正常: 污水费
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  W1
                else
                  0
                end
           ),0), --居民居民水价：污水量
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X38
                else
                  0
                end
           ),0), --居民居民水价: 污水费
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  W1
                else
                  0
                end
           ),0), --非居民-源水：污水量
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X38
                else
                  0
                end
           ),0), --非居民-源水：污水费
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  W1
                else
                  0
                end  
           ),0), --特业1：污水量
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X38
                else
                  0
                end  
           ),0), --特业1：污水费
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  W1
                else
                  0
                end  
           ),0), --特业2：污水量
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X38
                else
                  0
                end  
           ),0), --特业2：污水费
           nvl(sum(w1),0),   --账面污水量金额
           nvl(sum(x38),0)   --账面污水费金额
      into v_居民_正常_水量2,
           v_居民_正常_水费2,
           v_居民_居民水价_水量2,
           v_居民_居民水价_水费2,
           v_非居民_源水_水量2,
           v_非居民_源水_水费2,
           v_特业1_水量2,
           v_特业1_水费2,
           v_特业2_水量2,
           v_特业2_水费2,
           v_账面_水量2,
           v_账面_水费2,
           
           v_居民_正常_污水量2,
           v_居民_正常_污水费2,
           v_居民_居民水价_污水量2,
           v_居民_居民水价_污水费2,
           v_非居民_源水_污水量2,
           v_非居民_源水_污水费2,
           v_特业1_污水量2,
           v_特业1_污水费2,
           v_特业2_污水量2,
           v_特业2_污水费2,
           v_账面_污水量2,
           v_账面_污水费2 
      from rpt_sum_read rpt
     where u_month >= ic_umonth_beg2 and 
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;
           
    --补缴水量2
/*    select nvl(sum(x79),0) into v_补缴_水量2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
    SELECT nvl(sum(X32),0) into v_补缴_水量2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
    --补缴水费2       
/*    select nvl(sum(x80),0) into v_补缴_水费2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */ 
    SELECT nvl(sum(X37),0) into v_补缴_水费2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');   
            
    --基建水量2
    v_基建_水量2 := f_getAllotSl(ic_smfid,ic_umonth_beg2,ic_umonth_end2);
      
    --基建水费2       
    v_基建_水费2 := f_getAllotMoney(ic_smfid,ic_umonth_beg2,ic_umonth_end2);
           
    --补缴污水量2
/*    select nvl(sum(x81),0) into v_补缴_污水量2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
    SELECT nvl(sum(w4),0) into v_补缴_污水量2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
    --补缴污水费2       
/*    select nvl(sum(x82),0) into v_补缴_污水费2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;   */  
    SELECT nvl(sum(x38),0) into v_补缴_污水费2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='补缴'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
           
    --基建污水量2
/*    select nvl(sum(x74),0) into v_基建_污水量2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
           
     SELECT nvl(sum(W3),0) into v_基建_污水量2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='基建'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
           
    --基建污水费2       
/*    select nvl(sum(x75),0) into v_基建_污水费2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;   */   
                                   
           
      SELECT nvl(sum(X22),0) into v_基建_污水费2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='基建'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');            
              
           
           
    open oc_data for 
    select ic_smfid 营业所,
           ic_umonth_beg 账务月份_开始,
           ic_umonth_end 账务月份_截止,
           v_居民_正常_水量1 居民_正常_水量1,
           v_居民_正常_水费1 居民_正常_水费1,
           v_居民_正常_污水量1 居民_正常_污水量1,
           v_居民_正常_污水费1 居民_正常_污水费1,    
           v_居民_正常_水量2 居民_正常_水量2,
           v_居民_正常_水费2 居民_正常_水费2,
           v_居民_正常_污水量2 居民_正常_污水量2,
           v_居民_正常_污水费2 居民_正常_污水费2,
           v_居民_居民水价_水量1 居民_居民水价_水量1,
           v_居民_居民水价_水费1 居民_居民水价_水费1,
           v_居民_居民水价_污水量1 居民_居民水价_污水量1,
           v_居民_居民水价_污水费1 居民_居民水价_污水费1,    
           v_居民_居民水价_水量2 居民_居民水价_水量2,
           v_居民_居民水价_水费2 居民_居民水价_水费2,
           v_居民_居民水价_污水量2 居民_居民水价_污水量2,
           v_居民_居民水价_污水费2 居民_居民水价_污水费2,
           v_居民_正常_水量1 + v_居民_居民水价_水量1     居民_小计_水量1,
           v_居民_正常_水费1 + v_居民_居民水价_水费1     居民_小计_水费1,
           v_居民_正常_污水量1 + v_居民_居民水价_污水量1 居民_小计_污水量1,
           v_居民_正常_污水费1 + v_居民_居民水价_污水费1 居民_小计_污水费1,    
           v_居民_正常_水量2 + v_居民_居民水价_水量2     居民_小计_水量2,
           v_居民_正常_水费2 + v_居民_居民水价_水费2     居民_小计_水费2,
           v_居民_正常_污水量2 + v_居民_居民水价_污水量2 居民_小计_污水量2,
           v_居民_正常_污水费2 + v_居民_居民水价_污水费2 居民_小计_污水费2,
           v_账面_水量1 - v_居民_正常_水量1 - v_居民_居民水价_水量1 - v_非居民_源水_水量1 - v_特业1_水量1 - v_特业2_水量1 非居民_非居民_水量1,
           v_账面_水费1 - v_居民_正常_水费1 - v_居民_居民水价_水费1 - v_非居民_源水_水费1 - v_特业1_水费1 - v_特业2_水费1 非居民_非居民_水费1,
           v_账面_污水量1 - v_居民_正常_污水量1 - v_居民_居民水价_污水量1 - v_非居民_源水_污水量1 - v_特业1_污水量1 - v_特业2_污水量1 非居民_非居民_污水量1,
           v_账面_污水费1 - v_居民_正常_污水费1 - v_居民_居民水价_污水费1 - v_非居民_源水_污水费1 - v_特业1_污水费1 - v_特业2_污水费1 非居民_非居民_污水费1,
           v_账面_水量2 - v_居民_正常_水量2 - v_居民_居民水价_水量2 - v_非居民_源水_水量2 - v_特业1_水量2 - v_特业2_水量2 非居民_非居民_水量2,
           v_账面_水费2 - v_居民_正常_水费2 - v_居民_居民水价_水费2 - v_非居民_源水_水费2 - v_特业1_水费2 - v_特业2_水费2 非居民_非居民_水费2,
           v_账面_污水量2 - v_居民_正常_污水量2 - v_居民_居民水价_污水量2 - v_非居民_源水_污水量2 - v_特业1_污水量2 - v_特业2_污水量2 非居民_非居民_污水量2,
           v_账面_污水费2 - v_居民_正常_污水费2 - v_居民_居民水价_污水费2 - v_非居民_源水_污水费2 - v_特业1_污水费2 - v_特业2_污水费2 非居民_非居民_污水费2,          
           v_非居民_源水_水量1 非居民_源水_水量1,
           v_非居民_源水_水费1 非居民_源水_水费1,
           v_非居民_源水_污水量1 非居民_源水_污水量1,
           v_非居民_源水_污水费1 非居民_源水_污水费1,    
           v_非居民_源水_水量2 非居民_源水_水量2,
           v_非居民_源水_水费2 非居民_源水_水费2,
           v_非居民_源水_污水量2 非居民_源水_污水量2,
           v_非居民_源水_污水费2 非居民_源水_污水费2,
           v_账面_水量1 - v_居民_正常_水量1 - v_居民_居民水价_水量1 - v_非居民_源水_水量1 - v_特业1_水量1 - v_特业2_水量1 + v_非居民_源水_水量1 非居民_小计_水量1,
           v_账面_水费1 - v_居民_正常_水费1 - v_居民_居民水价_水费1 - v_非居民_源水_水费1 - v_特业1_水费1 - v_特业2_水费1 + v_非居民_源水_水费1 非居民_小计_水费1,
           v_账面_污水量1 - v_居民_正常_污水量1 - v_居民_居民水价_污水量1 - v_非居民_源水_污水量1 - v_特业1_污水量1 - v_特业2_污水量1 + v_非居民_源水_污水量1 非居民_小计_污水量1,
           v_账面_污水费1 - v_居民_正常_污水费1 - v_居民_居民水价_污水费1 - v_非居民_源水_污水费1 - v_特业1_污水费1 - v_特业2_污水费1 + v_非居民_源水_污水费1 非居民_小计_污水费1,
           v_账面_水量2 - v_居民_正常_水量2 - v_居民_居民水价_水量2 - v_非居民_源水_水量2 - v_特业1_水量2 - v_特业2_水量2 + v_非居民_源水_水量2 非居民_小计_水量2,
           v_账面_水费2 - v_居民_正常_水费2 - v_居民_居民水价_水费2 - v_非居民_源水_水费2 - v_特业1_水费2 - v_特业2_水费2 + v_非居民_源水_水费2 非居民_小计_水费2,
           v_账面_污水量2 - v_居民_正常_污水量2 - v_居民_居民水价_污水量2 - v_非居民_源水_污水量2 - v_特业1_污水量2 - v_特业2_污水量2 + v_非居民_源水_污水量2 非居民_小计_污水量2,
           v_账面_污水费2 - v_居民_正常_污水费2 - v_居民_居民水价_污水费2 - v_非居民_源水_污水费2 - v_特业1_污水费2 - v_特业2_污水费2 + v_非居民_源水_污水费2 非居民_小计_污水费2,           
           v_特业1_水量1 特业1_水量1,
           v_特业1_水费1 特业1_水费1,
           v_特业1_污水量1 特业1_污水量1,
           v_特业1_污水费1 特业1_污水费1,    
           v_特业1_水量2 特业1_水量2,
           v_特业1_水费2 特业1_水费2,
           v_特业1_污水量2 特业1_污水量2,
           v_特业1_污水费2 特业1_污水费2,  
           v_特业2_水量1 特业2_水量1,
           v_特业2_水费1 特业2_水费1,
           v_特业2_污水量1 特业2_污水量1,
           v_特业2_污水费1 特业2_污水费1,    
           v_特业2_水量2 特业2_水量2,
           v_特业2_水费2 特业2_水费2,
           v_特业2_污水量2 特业2_污水量2,
           v_特业2_污水费2 特业2_污水费2,   
           v_账面_水量1 账面_水量1,
           v_账面_水费1 账面_水费1,
           v_账面_污水量1 账面_污水量1,
           v_账面_污水费1 账面_污水费1,    
           v_账面_水量2 账面_水量2,
           v_账面_水费2 账面_水费2,
           v_账面_污水量2 账面_污水量2,
           v_账面_污水费2 账面_污水费2,  
           v_基建_水量1 基建_水量1,
           v_基建_水费1 基建_水费1,
           v_基建_污水量1 基建_污水量1,
           v_基建_污水费1 基建_污水费1,    
           v_基建_水量2 基建_水量2,
           v_基建_水费2 基建_水费2,
           v_基建_污水量2 基建_污水量2,
           v_基建_污水费2 基建_污水费2, 
           v_补缴_水量1 补缴_水量1,
           v_补缴_水费1 补缴_水费1,
           v_补缴_污水量1 补缴_污水量1,
           v_补缴_污水费1 补缴_污水费1,    
           v_补缴_水量2 补缴_水量2,
           v_补缴_水费2 补缴_水费2,
           v_补缴_污水量2 补缴_污水量2,
           v_补缴_污水费2 补缴_污水费2,
           v_基建_水量1 + v_补缴_水量1 补缴_小计_水量1,
           v_基建_水费1 + v_补缴_水费1 补缴_小计_水费1,
           v_基建_污水量1 + v_补缴_污水量1 补缴_小计_污水量1,
           v_基建_污水费1 + v_补缴_污水费1 补缴_小计_污水费1,    
           v_基建_水量2 + v_补缴_水量2 补缴_小计_水量2,
           v_基建_水费2 + v_补缴_水费2 补缴_小计_水费2,
           v_基建_污水量2 + v_补缴_污水量2 补缴_小计_污水量2,
           v_基建_污水费2 + v_补缴_污水费2 补缴_小计_污水费2 
      from dual;      
  end;
  
  --水费水量完成情况同期对比-动态
  procedure prc_compareReport2(ic_smfid       IN   varchar2,  --营业所Id
                               ic_umonth_beg  IN   varchar2,  --比较起始账务月份
                               ic_umonth_end  IN   varchar2,  --比较终止账务月份                            
                               oc_data        out  myref      --返回数据
  )is
  c_umonth_beg2     varchar2(10);
  c_umonth_end2     varchar2(10);
  c_month          varchar2(10);
  n_temp            number(12,0);
  
  v_居民_正常_水量1        number(14,2) default 0;
  v_居民_正常_水费1        number(14,2) default 0;
  v_居民_居民水价_水量1    number(14,2) default 0;
  v_居民_居民水价_水费1    number(14,2) default 0;
  v_非居民_源水_水量1      number(14,2) default 0;
  v_非居民_源水_水费1      number(14,2) default 0; 
  v_特业1_水量1            number(14,2) default 0;
  v_特业1_水费1            number(14,2) default 0;
  v_特业2_水量1            number(14,2) default 0;
  v_特业2_水费1            number(14,2) default 0;
  v_账面_水量1             number(14,2) default 0;
  v_账面_水费1             number(14,2) default 0; 
  
  v_居民_正常_污水量1      number(14,2) default 0;
  v_居民_正常_污水费1      number(14,2) default 0;
  v_居民_居民水价_污水量1  number(14,2) default 0;
  v_居民_居民水价_污水费1  number(14,2) default 0;
  v_非居民_源水_污水量1    number(14,2) default 0;
  v_非居民_源水_污水费1    number(14,2) default 0; 
  v_特业1_污水量1          number(14,2) default 0;
  v_特业1_污水费1          number(14,2) default 0;
  v_特业2_污水量1          number(14,2) default 0;
  v_特业2_污水费1          number(14,2) default 0; 
  v_账面_污水量1           number(14,2) default 0;
  v_账面_污水费1           number(14,2) default 0; 
  
  v_补缴_水量1             number(14,2) default 0;
  v_补缴_水费1             number(14,2) default 0;
  v_基建_水量1             number(14,2) default 0;
  v_基建_水费1             number(14,2) default 0;
  
  v_补缴_污水量1           number(14,2) default 0;
  v_补缴_污水费1           number(14,2) default 0;
  v_基建_污水量1           number(14,2) default 0;
  v_基建_污水费1           number(14,2) default 0;
   
  v_居民_正常_水量2        number(14,2) default 0;
  v_居民_正常_水费2        number(14,2) default 0;
  v_居民_居民水价_水量2    number(14,2) default 0;
  v_居民_居民水价_水费2    number(14,2) default 0;
  v_非居民_源水_水量2      number(14,2) default 0;
  v_非居民_源水_水费2      number(14,2) default 0; 
  v_特业1_水量2            number(14,2) default 0;
  v_特业1_水费2            number(14,2) default 0;
  v_特业2_水量2            number(14,2) default 0;
  v_特业2_水费2            number(14,2) default 0;
  v_账面_水量2             number(14,2) default 0;
  v_账面_水费2             number(14,2) default 0; 
  
  v_居民_正常_污水量2      number(14,2) default 0;
  v_居民_正常_污水费2      number(14,2) default 0;
  v_居民_居民水价_污水量2  number(14,2) default 0;
  v_居民_居民水价_污水费2  number(14,2) default 0;
  v_非居民_源水_污水量2    number(14,2) default 0;
  v_非居民_源水_污水费2    number(14,2) default 0; 
  v_特业1_污水量2          number(14,2) default 0;
  v_特业1_污水费2          number(14,2) default 0;
  v_特业2_污水量2          number(14,2) default 0;
  v_特业2_污水费2          number(14,2) default 0;
  v_账面_污水量2           number(14,2) default 0;
  v_账面_污水费2           number(14,2) default 0; 
  
  v_补缴_水量2             number(14,2) default 0;
  v_补缴_水费2             number(14,2) default 0;
  v_基建_水量2             number(14,2) default 0;
  v_基建_水费2             number(14,2) default 0;
  
  v_补缴_污水量2           number(14,2) default 0;
  v_补缴_污水费2           number(14,2) default 0;
  v_基建_污水量2           number(14,2) default 0;
  v_基建_污水费2           number(14,2) default 0;
  begin                      
    c_umonth_beg2 := to_char(add_months(to_date(ic_umonth_beg,'yyyy.mm'),-12),'yyyy.mm');    
    c_umonth_end2 := to_char(add_months(to_date(ic_umonth_end,'yyyy.mm'),-12),'yyyy.mm');    
    
     
    --居民
    select sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民正常：水量 
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0
             end  
           ),--居民正常：水费            
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民居民水价：水量
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民居民水价：水费
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--非居民-源水：水量
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end   
           ),--非居民-源水：水费
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业1：水量
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业1：水费
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：水量
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业2：水费
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--账面水量
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           ),--账面水费
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民正常：污水量
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民正常：污水费
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民居民水价：污水量
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民居民水价：污水费
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--非居民-源水：污水量
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--非居民-源水：污水费
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业1：污水量
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业1：污水费
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：污水量
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：污水费
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--账面污水量
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           ) --账面污水费     
      into v_居民_正常_水量1,
           v_居民_正常_水费1,
           v_居民_居民水价_水量1,
           v_居民_居民水价_水费1,
           v_非居民_源水_水量1,
           v_非居民_源水_水费1,
           v_特业1_水量1,
           v_特业1_水费1,
           v_特业2_水量1,
           v_特业2_水费1,
           v_账面_水量1,
           v_账面_水费1,
           
           v_居民_正常_污水量1,
           v_居民_正常_污水费1,
           v_居民_居民水价_污水量1,
           v_居民_居民水价_污水费1,
           v_非居民_源水_污水量1,
           v_非居民_源水_污水费1,
           v_特业1_污水量1,
           v_特业1_污水费1,
           v_特业2_污水量1,
           v_特业2_污水费1,
           v_账面_污水量1,
           v_账面_污水费1 
      from reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and 
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and      
           rl.rlid = rd.rdid and                  
           rltrans not in ( 'u', 'v', '13', '14', '21','23') and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_补缴_水量1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_补缴_水费1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );     
           
    --基建水量1
    --v_基建_水量1 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
    c_month := ic_umonth_beg;
    while c_month <= ic_umonth_end loop
      if c_month >= '2016.05' then
        begin
          select nvl(sum(ba.baallotsl),0)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select nvl(sum(nvl(rlsl,0)),0)
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*基建水费*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_基建_水量1 := nvl(n_temp,0) + nvl(v_基建_水量1,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    --基建水费1
    c_month := ic_umonth_beg;
    while c_month <= ic_umonth_end loop
      if c_month >= '2016.05' then
        begin
          select nvl(sum(ba.baallotsum),0)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select nvl(sum(nvl(rlje,0)),0) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*基建水费*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_基建_水费1 := nvl(n_temp,0) + nvl(v_基建_水费1,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
     
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_补缴_污水量1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_补缴_污水费1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_基建_污水量1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and 
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_基建_污水费1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    --------------  对比年度数据 -------------------------------------------------------------------------
    
    --居民
    select sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民正常：水量 
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0
             end  
           ),--居民正常：水费            
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民居民水价：水量
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民居民水价：水费
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--非居民-源水：水量
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end   
           ),--非居民-源水：水费
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业1：水量
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业1：水费
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：水量
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业2：水费
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--账面水量
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           ),--账面水费
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民正常：污水量
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民正常：污水费
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--居民居民水价：污水量
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--居民居民水价：污水费
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--非居民-源水：污水量
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--非居民-源水：污水费
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业1：污水量
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--特业1：污水费
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：污水量
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--特业2：污水费
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--账面污水量
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           ) --账面污水费     
      into v_居民_正常_水量2,
           v_居民_正常_水费2,
           v_居民_居民水价_水量2,
           v_居民_居民水价_水费2,
           v_非居民_源水_水量2,
           v_非居民_源水_水费2,
           v_特业1_水量2,
           v_特业1_水费2,
           v_特业2_水量2,
           v_特业2_水费2,
           v_账面_水量2,
           v_账面_水费2,
           
           v_居民_正常_污水量2,
           v_居民_正常_污水费2,
           v_居民_居民水价_污水量2,
           v_居民_居民水价_污水费2,
           v_非居民_源水_污水量2,
           v_非居民_源水_污水费2,
           v_特业1_污水量2,
           v_特业1_污水费2,
           v_特业2_污水量2,
           v_特业2_污水费2,
           v_账面_污水量2,
           v_账面_污水费2 
      from reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and 
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and 
           rltrans not in ( 'u', 'v', '13', '14', '21','23') and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_补缴_水量2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_补缴_水费2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    --基建水量2
    --v_基建_水量2 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
    c_month := c_umonth_beg2;
    while c_month <= c_umonth_end2 loop
      if c_month >= '2016.05' then
        begin
          select sum(ba.baallotsl)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid  and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*基建水费*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_基建_水量2 := n_temp + nvl(v_基建_水量2,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    --基建水费2
    c_month := c_umonth_beg2;
    while c_month <= c_umonth_end2 loop
      if c_month >= '2016.05' then
        begin
          select sum(ba.baallotsum)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid  and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*基建水费*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_基建_水费2 := n_temp + nvl(v_基建_水费2,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_补缴_污水量2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and        
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_补缴_污水费2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_基建_污水量2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_基建_污水费2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    open oc_data for 
    select ic_smfid 营业所,
           ic_umonth_beg 账务月份_开始,
           ic_umonth_end 账务月份_截止,
           v_居民_正常_水量1 居民_正常_水量1,
           v_居民_正常_水费1 居民_正常_水费1,
           v_居民_正常_污水量1 居民_正常_污水量1,
           v_居民_正常_污水费1 居民_正常_污水费1,    
           v_居民_正常_水量2 居民_正常_水量2,
           v_居民_正常_水费2 居民_正常_水费2,
           v_居民_正常_污水量2 居民_正常_污水量2,
           v_居民_正常_污水费2 居民_正常_污水费2,
           v_居民_居民水价_水量1 居民_居民水价_水量1,
           v_居民_居民水价_水费1 居民_居民水价_水费1,
           v_居民_居民水价_污水量1 居民_居民水价_污水量1,
           v_居民_居民水价_污水费1 居民_居民水价_污水费1,    
           v_居民_居民水价_水量2 居民_居民水价_水量2,
           v_居民_居民水价_水费2 居民_居民水价_水费2,
           v_居民_居民水价_污水量2 居民_居民水价_污水量2,
           v_居民_居民水价_污水费2 居民_居民水价_污水费2,
           v_居民_正常_水量1 + v_居民_居民水价_水量1     居民_小计_水量1,
           v_居民_正常_水费1 + v_居民_居民水价_水费1     居民_小计_水费1,
           v_居民_正常_污水量1 + v_居民_居民水价_污水量1 居民_小计_污水量1,
           v_居民_正常_污水费1 + v_居民_居民水价_污水费1 居民_小计_污水费1,    
           v_居民_正常_水量2 + v_居民_居民水价_水量2     居民_小计_水量2,
           v_居民_正常_水费2 + v_居民_居民水价_水费2     居民_小计_水费2,
           v_居民_正常_污水量2 + v_居民_居民水价_污水量2 居民_小计_污水量2,
           v_居民_正常_污水费2 + v_居民_居民水价_污水费2 居民_小计_污水费2,
           v_账面_水量1 - v_居民_正常_水量1 - v_居民_居民水价_水量1 - v_非居民_源水_水量1 - v_特业1_水量1 - v_特业2_水量1 非居民_非居民_水量1,
           v_账面_水费1 - v_居民_正常_水费1 - v_居民_居民水价_水费1 - v_非居民_源水_水费1 - v_特业1_水费1 - v_特业2_水费1 非居民_非居民_水费1,
           v_账面_污水量1 - v_居民_正常_污水量1 - v_居民_居民水价_污水量1 - v_非居民_源水_污水量1 - v_特业1_污水量1 - v_特业2_污水量1 非居民_非居民_污水量1,
           v_账面_污水费1 - v_居民_正常_污水费1 - v_居民_居民水价_污水费1 - v_非居民_源水_污水费1 - v_特业1_污水费1 - v_特业2_污水费1 非居民_非居民_污水费1,
           v_账面_水量2 - v_居民_正常_水量2 - v_居民_居民水价_水量2 - v_非居民_源水_水量2 - v_特业1_水量2 - v_特业2_水量2 非居民_非居民_水量2,
           v_账面_水费2 - v_居民_正常_水费2 - v_居民_居民水价_水费2 - v_非居民_源水_水费2 - v_特业1_水费2 - v_特业2_水费2 非居民_非居民_水费2,
           v_账面_污水量2 - v_居民_正常_污水量2 - v_居民_居民水价_污水量2 - v_非居民_源水_污水量2 - v_特业1_污水量2 - v_特业2_污水量2 非居民_非居民_污水量2,
           v_账面_污水费2 - v_居民_正常_污水费2 - v_居民_居民水价_污水费2 - v_非居民_源水_污水费2 - v_特业1_污水费2 - v_特业2_污水费2 非居民_非居民_污水费2,          
           v_非居民_源水_水量1 非居民_源水_水量1,
           v_非居民_源水_水费1 非居民_源水_水费1,
           v_非居民_源水_污水量1 非居民_源水_污水量1,
           v_非居民_源水_污水费1 非居民_源水_污水费1,    
           v_非居民_源水_水量2 非居民_源水_水量2,
           v_非居民_源水_水费2 非居民_源水_水费2,
           v_非居民_源水_污水量2 非居民_源水_污水量2,
           v_非居民_源水_污水费2 非居民_源水_污水费2,
           v_账面_水量1 - v_居民_正常_水量1 - v_居民_居民水价_水量1 - v_非居民_源水_水量1 - v_特业1_水量1 - v_特业2_水量1 + v_非居民_源水_水量1 非居民_小计_水量1,
           v_账面_水费1 - v_居民_正常_水费1 - v_居民_居民水价_水费1 - v_非居民_源水_水费1 - v_特业1_水费1 - v_特业2_水费1 + v_非居民_源水_水费1 非居民_小计_水费1,
           v_账面_污水量1 - v_居民_正常_污水量1 - v_居民_居民水价_污水量1 - v_非居民_源水_污水量1 - v_特业1_污水量1 - v_特业2_污水量1 + v_非居民_源水_污水量1 非居民_小计_污水量1,
           v_账面_污水费1 - v_居民_正常_污水费1 - v_居民_居民水价_污水费1 - v_非居民_源水_污水费1 - v_特业1_污水费1 - v_特业2_污水费1 + v_非居民_源水_污水费1 非居民_小计_污水费1,
           v_账面_水量2 - v_居民_正常_水量2 - v_居民_居民水价_水量2 - v_非居民_源水_水量2 - v_特业1_水量2 - v_特业2_水量2 + v_非居民_源水_水量2 非居民_小计_水量2,
           v_账面_水费2 - v_居民_正常_水费2 - v_居民_居民水价_水费2 - v_非居民_源水_水费2 - v_特业1_水费2 - v_特业2_水费2 + v_非居民_源水_水费2 非居民_小计_水费2,
           v_账面_污水量2 - v_居民_正常_污水量2 - v_居民_居民水价_污水量2 - v_非居民_源水_污水量2 - v_特业1_污水量2 - v_特业2_污水量2 + v_非居民_源水_污水量2 非居民_小计_污水量2,
           v_账面_污水费2 - v_居民_正常_污水费2 - v_居民_居民水价_污水费2 - v_非居民_源水_污水费2 - v_特业1_污水费2 - v_特业2_污水费2 + v_非居民_源水_污水费2 非居民_小计_污水费2,           
           v_特业1_水量1 特业1_水量1,
           v_特业1_水费1 特业1_水费1,
           v_特业1_污水量1 特业1_污水量1,
           v_特业1_污水费1 特业1_污水费1,    
           v_特业1_水量2 特业1_水量2,
           v_特业1_水费2 特业1_水费2,
           v_特业1_污水量2 特业1_污水量2,
           v_特业1_污水费2 特业1_污水费2,  
           v_特业2_水量1 特业2_水量1,
           v_特业2_水费1 特业2_水费1,
           v_特业2_污水量1 特业2_污水量1,
           v_特业2_污水费1 特业2_污水费1,    
           v_特业2_水量2 特业2_水量2,
           v_特业2_水费2 特业2_水费2,
           v_特业2_污水量2 特业2_污水量2,
           v_特业2_污水费2 特业2_污水费2,   
           v_账面_水量1 账面_水量1,
           v_账面_水费1 账面_水费1,
           v_账面_污水量1 账面_污水量1,
           v_账面_污水费1 账面_污水费1,    
           v_账面_水量2 账面_水量2,
           v_账面_水费2 账面_水费2,
           v_账面_污水量2 账面_污水量2,
           v_账面_污水费2 账面_污水费2,  
           v_基建_水量1 基建_水量1,
           v_基建_水费1 基建_水费1,
           v_基建_污水量1 基建_污水量1,
           v_基建_污水费1 基建_污水费1,    
           v_基建_水量2 基建_水量2,
           v_基建_水费2 基建_水费2,
           v_基建_污水量2 基建_污水量2,
           v_基建_污水费2 基建_污水费2, 
           v_补缴_水量1 补缴_水量1,
           v_补缴_水费1 补缴_水费1,
           v_补缴_污水量1 补缴_污水量1,
           v_补缴_污水费1 补缴_污水费1,    
           v_补缴_水量2 补缴_水量2,
           v_补缴_水费2 补缴_水费2,
           v_补缴_污水量2 补缴_污水量2,
           v_补缴_污水费2 补缴_污水费2,
           v_基建_水量1 + v_补缴_水量1 补缴_小计_水量1,
           v_基建_水费1 + v_补缴_水费1 补缴_小计_水费1,
           v_基建_污水量1 + v_补缴_污水量1 补缴_小计_污水量1,
           v_基建_污水费1 + v_补缴_污水费1 补缴_小计_污水费1,    
           v_基建_水量2 + v_补缴_水量2 补缴_小计_水量2,
           v_基建_水费2 + v_补缴_水费2 补缴_小计_水费2,
           v_基建_污水量2 + v_补缴_污水量2 补缴_小计_污水量2,
           v_基建_污水费2 + v_补缴_污水费2 补缴_小计_污水费2 
      from dual;      
    
                      
  end;
  
  
    
END PG_EWIDE_JOB_HRB2;
/

