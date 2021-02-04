CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJF_OCX_RL" (p_pbatch    in varchar2, --实收批次
                        P_PID       IN varchar2, --实收流水(不空按实收流水打印)
                        p_plid      in varchar2, --实收明细流水(不空按实收明细流水打印)
                        p_modelno   in varchar2, --发票格式号:2/25
                        p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
                        p_ifbd      in varchar2, --是否补打 --是:Y,否:N
                        P_PRINTER   IN VARCHAR2 --打印员
                        )  is
 /* cursor c_rl is
  select t3.*
  from reclist_bak t3
  order by rlmcode asc, rlmonth asc,rlgroup desc ;*/
 cursor c_rl is
 select  t3.* from payment t, paidlist t1,  reclist t3, meterdoc t4,meterinfo t5
       where pid = plpid
         and rlid = plrlid
         and rlmid = mdmid
         and miid = rlmid
         and pbatch = p_pbatch
         order by rlmcode asc, rlmonth asc,rlgroup desc
     ;
rl reclist%rowtype;
rt reclist_print%rowtype;
v_rlnum reclist_print.rlnum%type;
v_flag number(10);

begin
  delete reclist_print;

  v_flag :=0;
  v_rlnum :=0 ;
 open c_rl;
 loop fetch c_rl into   rl;
 exit when c_rl%notfound or c_rl%notfound is null ;



if    v_flag=0 then
  rt.rlnum            := v_rlnum                 ;--组号
/*elsif v_flag=1 and rl.rlgroup=1 then
  rt.rlnum            := v_rlnum                 ;--组号*/
else
  v_rlnum            := v_rlnum + 1                 ;
  rt.rlnum            := v_rlnum                 ;--组号
  v_flag :=0;
end if;

rt.rlid             := rl.rlid                 ;--流水号
rt.rlsmfid          := rl.rlsmfid              ;--营销公司
rt.rlmonth          := rl.rlmonth              ;--帐务月份
rt.rldate           := rl.rldate               ;--帐务日期
rt.rlcid            := rl.rlcid                ;--用户编号
rt.rlmid            := rl.rlmid                ;--水表编号
rt.rlmsmfid         := rl.rlmsmfid             ;--水表公司
rt.rlcsmfid         := rl.rlcsmfid             ;--用户公司
rt.rlccode          := rl.rlccode              ;--资料号
rt.rlchargeper      := rl.rlchargeper          ;--收费员
rt.rlcpid           := rl.rlcpid               ;--上级用户编号
rt.rlcclass         := rl.rlcclass             ;--用户级次
rt.rlcflag          := rl.rlcflag              ;--末级标志
rt.rlusenum         := rl.rlusenum             ;--户用水人数
rt.rlcname          := rl.rlcname              ;--用户名称
rt.rlcadr           := rl.rlcadr               ;--用户地址
rt.rlmadr           := rl.rlmadr               ;--水表地址
rt.rlcstatus        := rl.rlcstatus            ;--用户状态
rt.rlmtel           := rl.rlmtel               ;--移动电话
rt.rltel            := rl.rltel                ;--固定电话
rt.rlbankid         := rl.rlbankid             ;--代扣银行
rt.rltsbankid       := rl.rltsbankid           ;--托收银行
rt.rlaccountno      := rl.rlaccountno          ;--开户帐号
rt.rlaccountname    := rl.rlaccountname        ;--开户名称
rt.rliftax          := rl.rliftax              ;--是否税票
rt.rltaxno          := rl.rltaxno              ;--增殖税号
rt.rlifinv          := rl.rlifinv              ;--是否普票
rt.rlmcode          := rl.rlmcode              ;--水表手工编号
rt.rlmpid           := rl.rlmpid               ;--上级水表
rt.rlmclass         := rl.rlmclass             ;--水表级次
rt.rlmflag          := rl.rlmflag              ;--末级标志
rt.rlmsfid          := rl.rlmsfid              ;--水表类别
rt.rlday            := rl.rlday                ;--抄表日
rt.rlbfid           := rl.rlbfid               ;--表册
rt.rlprdate         := rl.rlprdate             ;--上次抄表日期
rt.rlrdate          := rl.rlrdate              ;--本次抄表日期
rt.rlzndate         := rl.rlzndate             ;--违约金起算日
rt.rlcaliber        := rl.rlcaliber            ;--表口径
rt.rlrtid           := rl.rlrtid               ;--抄表方式
rt.rlmstatus        := rl.rlmstatus            ;--状态
rt.rlmtype          := rl.rlmtype              ;--类型
rt.rlmno            := rl.rlmno                ;--表身码
rt.rlscode          := rl.rlscode              ;--起数
rt.rlecode          := rl.rlecode              ;--止数
rt.rlreadsl         := rl.rlreadsl             ;--抄见水量
rt.rlinvmemo        := rl.rlinvmemo            ;--发票备注
rt.rlentrustbatch   := rl.rlentrustbatch       ;--托收代扣批号
rt.rlentrustseqno   := rl.rlentrustseqno       ;--托收代扣流水号
rt.rloutflag        := rl.rloutflag            ;--发出标志
rt.rltrans          := rl.rltrans              ;--应收事务
rt.rlcd             := rl.rlcd                 ;--借贷方向
rt.rlyschargetype   := rl.rlyschargetype       ;--应收方式
rt.rlsl             := rl.rlsl                 ;--应收水量
rt.rlje             := rl.rlje                 ;--应收金额
rt.rladdsl          := rl.rladdsl              ;--加调水量
rt.rlscrrlid        := rl.rlscrrlid            ;--原应收帐流水
rt.rlscrrltrans     := rl.rlscrrltrans         ;--原应收帐事务
rt.rlscrrlmonth     := rl.rlscrrlmonth         ;--原应收帐月份
rt.rlpaidje         := rl.rlpaidje             ;--销帐金额
rt.rlpaidflag       := rl.rlpaidflag           ;--销帐标志(y:y，n:n，x:x，v:y/n，t:y/x，k:n/x，w:y/n/x)
rt.rlpaidper        := rl.rlpaidper            ;--销帐人员
rt.rlpaiddate       := rl.rlpaiddate           ;--销帐日期
rt.rlmrid           := rl.rlmrid               ;--抄表流水
rt.rlmemo           := rl.rlmemo               ;--备注
rt.rlznj            := rl.rlznj                ;--违约金
rt.rllb             := rl.rllb                 ;--类别
rt.rlcname2         := rl.rlcname2             ;--曾用名
rt.rlpfid           := rl.rlpfid               ;--主价格类别
rt.rldatetime       := rl.rldatetime           ;--发生日期
rt.rlscrrldate      := rl.rlscrrldate          ;--原帐务日期
rt.rlprimcode       := rl.rlprimcode           ;--合收表主表号
rt.rlpriflag        := rl.rlpriflag            ;--合收表标志
rt.rlrper           := rl.rlrper               ;--抄表员
rt.rlsafid          := rl.rlsafid              ;--区域
rt.rlscodechar      := rl.rlscodechar          ;--上期抄表（带表位）
rt.rlecodechar      := rl.rlecodechar          ;--本期抄表（带表位）
rt.rlilid           := rl.rlilid               ;--发票流水号
rt.rlmiuiid         := rl.rlmiuiid             ;--合收单位编号
rt.rlgroup          := rl.rlgroup              ;--应收帐分组

 insert into reclist_print values rt;

if rl.rlgroup=1  then

  v_flag:=1 ;

end if;


 end loop;
 close c_rl;
 if rl.rlgroup=2 and v_rlnum>0 then
   update reclist_print t set t.rlnum = v_rlnum - 1 where
   t.rlnum=v_rlnum ;
 end if;

end;
/

