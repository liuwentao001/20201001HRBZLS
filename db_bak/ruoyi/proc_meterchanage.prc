create or replace procedure PROC_meterChanage(
	v_ciid1 in varchar,
	v_ciid2 in varchar,
	v_miids in varchar,
	u_result out number(20)	
)
as
begin	
	--不合户 更新户表信息 ，水表余额累加 直接生成应收帐
	--update BS_METERINFO set micode=v_ciid1 where miid in v_miids
	
	---合户 合并余额 销户
END
/

