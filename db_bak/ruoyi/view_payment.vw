create or replace force view view_payment as
select "用户编号","合收主表号","缴费月份","发生日期","缴费机构","收费员","付款金额","交易流水","付款方式","缴费交易批次","微信交易流水","微信申请日期","老户号"
    from view_payment@hrbzls;

