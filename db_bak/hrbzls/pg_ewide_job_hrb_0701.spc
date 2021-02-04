CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_JOB_HRB_0701" as
 ERRCODE   CONSTANT INTEGER := -20012;
  --月初处理
  procedure 月初处理;
  --抄表月结
  procedure 抄表月结;
  --账务月结
  procedure 账务月结;
  --自动算费（包含自动预存抵扣）
  procedure 自动算费;
  --月售水情况归档
  procedure 月售水情况归档;
  PROCEDURE 月售水情况归档_1(P_MOUTH IN VARCHAR2);
  --每日更新验证码
  procedure 验证码;
  --维护用户数据
  PROCEDURE 维护用户数据(P_SMFID IN VARCHAR2);
  --20140420 迁移后自动抵扣一次，以后算费时扣划
  PROCEDURE 自动预存抵扣(V_SMFID IN VARCHAR2);
  --20140503 维护银行历史实收对账日期
  PROCEDURE 维护银行历史实收对账日期;
  --20140503 维护历史银行缴费机构
  PROCEDURE 维护历史银行缴费机构;
  --20140506 维护低保标志和低保证件号
  PROCEDURE 维护低保标志和低保证件号;
   --20140506 维护身份证号
  PROCEDURE 维护身份证号;
  --20140514 维护财务对账审核日期
  PROCEDURE 维护财务对账审核日期;
end;
/

