create or replace procedure hrbzls.pro_财务对账银行 is
       pro_date date;
       pro_num number:=0;
       pro_month varchar(7);
begin
     select to_date(sysdate - 1)  into pro_date from dual;
  select count(*) into  pro_num from 财务对账中间表 ;
  select  to_char(add_months(sysdate,-1),'yyyy.mm') into pro_month from dual; 

     delete from 财务对账中间表 where to_char(PCHKDATE,'yyyy.mm')>=pro_month;

    insert into 财务对账中间表
    SELECT PCHKDATE,
      PPOSITION  ,
      MISMFID ,
      sum(QC) ,
      sum( FS),
      sum( QM) ,
      sum(PAY) , 
      sum(ZNJ) ,
      sum( SF) ,
      sum(FJF) ,
      sum(WS) ,
      sum(SXF),
      PREVERSEFLAG,
      count(PCHKNO),
      PCHKNO
      from (SELECT 'Y' FLAG,--扎帐标志 
            max(PCHKNO) PCHKNO,--扎帐单号
            max(PCHKDATE) PCHKDATE,--扎帐日期
             max(PDATE) PDATE,--帐务日期（收费日期） 
             max(PDATETIME) PDATETIME,--发生日期 
             max(PPOSITION) PPOSITION,--缴费机构 
             PBATCH,--缴费交易批次 
           max(MISMFID) MISMFID,  
          max(PBSEQNO) PBSEQNO,    
             MAX(PPRIID) PPRIID,--合收主表号 
             MAX(MINAME) MINAME,--票据名称 
             MAX(MIADR) MIADR,--表地址 
             MAX(PPAYWAY) PPAYWAY,--付款方式 
             FGETYCFS(PBATCH, 'QC') QC,--期初预存
             FGETPAYLIST(PBATCH, 'FS') FS,--本期发生
             FGETPAYLIST(PBATCH, 'QM') QM,--期末预存
             FGETPAYLIST(PBATCH, 'PAY') PAY,--付款金额 
             FGETPAYLIST(PBATCH, 'ZNJ') ZNJ,--违约金
             FGETPAYLIST(PBATCH, 'SF') SF,--水费
             FGETPAYLIST(PBATCH, 'FJF') FJF,--附加费
             FGETPAYLIST(PBATCH, 'WS') WS,--污水费
             FGETPAYLISTCHAR(PBATCH, 'INV') INV,--发票号
             FGETPAYLIST(PBATCH, 'SXF') SXF, --手续费
             PREVERSEFLAG
        FROM PAYMENT, METERINFO
       WHERE PPRIID = MIID
      and PPOSITION like '03%'      
     and to_char(PCHKDATE,'yyyy.mm')>=pro_month
      group by PBATCH,PREVERSEFLAG) a
      group by PPOSITION,PCHKNO,MISMFID,PCHKDATE,PREVERSEFLAG;
 commit;
end pro_财务对账银行;
/

