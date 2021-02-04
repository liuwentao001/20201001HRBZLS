CREATE OR REPLACE FORCE VIEW HRBZLS.VIE_预存抵扣实收查询 AS
SELECT CCHNO         单据流水号,
       cchsmfid      营销公司,
       cchdept       受理部门,
       ciname        用户名,
       misaving      冲正预存余额,
       cchcredate    受理日期,
       cchcreper     受理人员,
       cchshdate     审核日期,
       cchshper      审核人员,
       cchshflag     审核标志,
       micode        用户号,
       ciidentitylb  证件类型,
       ciidentityno  证件号码,
       ciadr         用户地址,
       miadr         水表地址,
       ciconnectper  联系人,
       ciconnecttel  联系电话,
       cimtel        移动电话,
       ccdappnote    退款类别,
       ccdfilashnote 领导意见,
       ycmonth  预存退款月份 ,substr(ycmibfid,1,5) 代号 ,ycmisaving 预存退款余额 ,
       yccredate 预存退款设定时间 ,yccreuser 预存退款设定人员,
       ycfinflag  预存退款完成注记  ,YCFINDATE 预存退款完成时间,YCFINUSER 预存退款完成人员,
       ycfinpid 预存退款实收单据号 ,ycnote 预存退款备注 ,ycinvflag 预存退款开票注记 ,
       ycinvno 预存退款开票号码 ,yctype 预存退款类别,miemailflag 标志
  FROM CUSTCHANGEDT, CUSTCHANGEHD,METERINFO_YCCZ
 WHERE CUSTCHANGEDT.CCDNO = CUSTCHANGEHD.CCHNO and
 CCDNO= YCID  and YCMID=CIID     and cchlb  in ('36','39') and CCHSHFLAG='Y';

