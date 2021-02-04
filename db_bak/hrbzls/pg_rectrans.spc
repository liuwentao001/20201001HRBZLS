CREATE OR REPLACE PACKAGE HRBZLS."PG_RECTRANS" is

  -- Author  : ADMINISTRATOR
  -- Created : 2009-4-29 13:27:48
  -- Purpose : jh

  -- Public type declarations
  CurrentDate date;

  -- Public constant declarations
  errcode constant integer := -20012;

  -- Public function and procedure declarations

  --单据提交入口过程
  procedure Approve(p_billno in VARCHAR2,
                    p_person in VARCHAR2,
                    p_billid in VARCHAR2,
                    p_djlb   in VARCHAR2);

  --稽查
  procedure sp_rectrans101(p_no in varchar2, p_per in varchar2);

  --追量
  procedure sp_rectrans102(p_no in varchar2, p_per in varchar2);

  --预留
  procedure sp_rectrans103(p_no in varchar2, p_per in varchar2);

  --余度
  procedure sp_rectrans104(p_no in varchar2, p_per in varchar2);

  --水损
  procedure sp_rectrans105(p_no in varchar2, p_per in varchar2);

  --工程款
  procedure sp_rectrans106(p_no in varchar2, p_per in varchar2);

  --价差
  procedure sp_rectrans107(p_no in varchar2, p_per in varchar2);
  --
  procedure sp_rectrans108(p_no in varchar2, p_per in varchar2);
  --减量退费（冲销退款+冲应收）
  procedure sp_paidrecback(p_no in varchar2, p_per in varchar2);
  --实收冲正
  procedure sp_paidrollback(p_no in varchar2, p_per in varchar2);

  --四费冲正
  procedure sp_paidrollback_sf(p_no in varchar2, p_per in varchar2);

  --应收调整
  procedure recadjust(rah   in recadjusthd%rowtype,
                      rad   in recadjustdt%rowtype,
                      p_per in varchar2,
                      rlcr  out reclist%rowtype,
                      rlde  out reclist%rowtype);
  --贷记应收处理
  procedure recback(p_rlid       in varchar2,
                    p_rdpiidlist in varchar2,
                    p_trans      in varchar2,
                    p_per        in varchar2,
                    p_memo       in varchar2,
                    bf           in bookframe%rowtype,
                    rlcr         out reclist%rowtype);
  --追收插入抄表计划到历史库
  procedure sp_insertmrhis(rth   in rectranshd%rowtype, --追收头
                           mi    in meterinfo%rowtype, --水表信息
                           omrid out meterreadhis.mrid%type); --抄表流水
  --追收撤销
  procedure sp_recrollback(p_billno in VARCHAR2, --流水号
                           p_person in VARCHAR2, --操作员
                           p_billid in VARCHAR2,
                           p_djlb   in VARCHAR2);
end pg_rectrans;
/

