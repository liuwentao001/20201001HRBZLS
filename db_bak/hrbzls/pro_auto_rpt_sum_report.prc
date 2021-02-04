create or replace procedure hrbzls.pro_auto_rpt_sum_report  is
--add hb 20150120
--因报表速度慢,重新制作中间表数据
v_month varchar2(7) ;
--v_sysdate rpt_sum_report_mi.ins_date%type;
begin
  v_month:= to_char(sysdate, 'yyyy.mm') ;
  --v_sysdate:=sysdate;
  --只存在每月的资料
  --每天晚上删除当月的资料然后再重新抓取执行最新
  /***************************************************
     01-用户基本信息中间表
     begin
    -- 表里面字段为空默认为XX或X,
  ****************************************************/
/* delete from rpt_sum_report_mi where ID ='01' and MONTH=v_month;
 INSERT INTO rpt_sum_report_mi (id, month, mismfid, mibfid, zkh, michargetype, michargetype_note, milb, milb_note, mistatus, mistatus_note, mipfid, mipfid_note, miyl2, miyl2_note, mdcaliber, mdbrand, mdbrand_note, mirtid, mirtid_note, mitype, mitype_note, hs, miusenum, misaving,INS_DATE) 
select '01' 项目ID, ---水表基本信息中间表
    v_month 账务月份,
     mismfid 营业所,  
     nvl(mibfid,'XX') 表册,  -- 表里面字段为空默认为XX或X
     substrb(NVL(mibfid,'XX'), 1, 5) 帐卡号,-- 表里面字段为空默认为XX或X
     MICHARGETYPE 收费方式,  
     (select sctname from syschargetype where sctid = MICHARGETYPE) 收费方式说明,  
     MILB 水表类别,
     (select t.sclvalue
        from syscharlist t
       where t.scltype = '水表类别'
         and t.sclid = MILB) 水表类别说明,
    nvl( MISTATUS,'XX') 水表状态,-- 表里面字段为空默认为XX或X
     (select NVL(smsname,'水表状态空')
        from sysmeterstatus
       where smsmemo = 'Y'
         and smsid =  nvl( MISTATUS,'XX')) 水表状态说明,
     MIPFID 用水性质,
     FGETPRICEFRAME_TM(MIPFID) 用水性质说明,
     nvl(MIYL2, '0') 收免标志,
     decode(nvl(MIYL2, '0'),
            '0',
            '普通表',
            '1',
            '总表收免',
            '2',
            '多级表') 收免标志说明,
NVL(mdcaliber,0) 口径 ,  --口径  -- 表里面字段为空默认为0
nvl(MDBRAND,'XX') 表品牌代号,--品牌 -- 表里面字段为空默认为XX或X
(select nvl( mbname,'表品牌空') from meterbrand where mbid =nvl(MDBRAND,'XX')) 表品牌说明,
NVL(mirtid,'X') 抄表方式代号,--抄表方式 -- 表里面字段为空默认为X
( select t.srtname from sysreadtype t where t.srtid = NVL(mirtid,'X') ) 抄表方式说明,--抄表方式说明
NVL(mitype,'X')   表型代号,--表型  -- 表里面字段为空默认为X
(select t.smtname from sysmetertype t WHERE smtifread='Y' and t.smtid= NVL(mitype,'X')) 表型说明,

     sum(case
           when (miid = MIPRIID and MIPRIFLAG = 'Y') or MIPRIFLAG = 'N' then
            '1'
           else
            '0'
         end) 户数,
     SUM(MIUSENUM) 人数,
     sum(MISAVING) 预存余额 ,
     v_sysdate
from meterinfo,meterdoc
where meterinfo.miid =meterdoc.mdmid  
group by to_char(sysdate, 'yyyy.mm'), --月份
        mismfid, --营业所 
        nvl(mibfid,'XX'), --表册
      substrb(NVL(mibfid,'XX'), 1, 5) ,  --代号
        MICHARGETYPE, --收费方式 
        MILB,  --水表类别
        nvl( MISTATUS,'XX'), --用户状态
        MIPFID,  --用水性质
      nvl(MIYL2, '0') ,  --收免标志
        NVL(mdcaliber,0),  --口径
     nvl(MDBRAND,'XX'),   --品牌
         NVL(mirtid,'X'),   --抄表方式代号
         NVL(mitype,'X') ;   --表型代号*/
        --   commit ;
  /***************************************************
     01-用户基本信息中间表
      end 
  ****************************************************/
  
    /***************************************************
     02-抄表信息中间表 
     begin
  ****************************************************/
    
  null;
    /***************************************************
     02-抄表信息中间表 
     end
  ****************************************************/
  
      /***************************************************
     03-应收信息中间表 
     begin
  ****************************************************/
      null;
    /***************************************************
     03-应收信息中间表 
     end
  ****************************************************/
  
  /***************************************************
     04-实收信息中间表 
     begin
  ****************************************************/
      null;
    /***************************************************
     04-实收信息中间表 
     end
  ****************************************************/
end pro_auto_rpt_sum_report;
/

