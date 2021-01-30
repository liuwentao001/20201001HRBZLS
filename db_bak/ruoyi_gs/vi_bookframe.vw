create or replace force view vi_bookframe as
select
BFID  编码,
BFSMFID 营业分公司,
BFBATCH 抄表批次,
BFNAME 名称,
BFPID 上级编码,
BFCLASS 级次,
BFFLAG  末级标志,
BFSTATUS  有效状态,
BFHANDLES 下级数量,
BFMEMO  备注,
BFORDER 册间次序,
BFCREPER  创建人,
BFCREDATE 创建日期,
BFRCYC  抄表周期,
BFLB  表册类别,
BFRPER  抄表员,
BFSAFID 区域,
BFNRMONTH   下次抄表月份,
BFDAY 偏移天数,
BFSDATE 计划起始日期,
BFEDATE 计划结束日期,
BFMONTH 本期抄表月份,
BFPPER    收费员,
BFJTSNY   阶梯开始月

 from BS_BOOKFRAME bf
LEFT JOIN BS_METERINFO mo on BF.BFID=MO.MIBFID
 where rownum<=100;
comment on table VI_BOOKFRAME is '帐卡号管理';

