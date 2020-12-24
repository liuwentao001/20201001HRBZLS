create or replace package body PG_METER_READ is




  --抄表录入处调用的重抄
  PROCEDURE METERREAD_RE(
            --mrid IN VARCHAR2,  --meterread表当前流水号
            smiid IN VARCHAR2,  --水表编号
            gs_oper_id  IN VARCHAR2,  --登录人员id
            RES IN OUT INTEGER )--返回结果 0成功 >0 失败
  IS 
    ls_mrifrec varchar2(10);
    ls_MRDATASOURCE varchar2(10);                   
    ls_readok varchar2(1);
    ls_BFRPER varchar2(20);
    ls_mistatus varchar2(20);
    ll_micolumn5 varchar2(20);
    ls_BFRPER1 varchar2(20);

  BEGIN

    RES := 0;
        
    select mrifrec,MRDATASOURCE,mrreadok,MRRPER into ls_mrifrec,ls_MRDATASOURCE,ls_readok,ls_BFRPER from bs_meterread where MRMID =smiid ;
     
    IF ls_MRDATASOURCE = '9' And ls_readok = 'Y' THEN
       res := 1;
       RETURN;
    END IF;
    IF ls_mrifrec = 'Y' THEN 
        res := 2;
        RETURN ;
    end if;
    
    --判断当前是否免抄户
    SELECT BFRPER INTO ls_BFRPER1 FROM bs_bookframe WHERE
    bfid = (SELECT MIBFID From bs_meterinfo Where  miid = smiid);
    IF  ls_BFRPER1 <> ls_BFRPER THEN
      ls_BFRPER := ls_BFRPER1;
    END IF;
    
        
    SELECT mistatus,micolumn5
    INTO ls_mistatus,ll_micolumn5
    From bs_meterinfo Where miid = smiid;
          

        
  
    If (ls_mistatus = '29' Or ls_mistatus = '30') THEN
      update bs_meterread set
      mrreadok = 'Y',
      mrifsubmit = 'N',  --免拆户重抄后进抄表审核
      MRCHKFLAG = 'Y',    --重抄时是复核标志重置为'N'
      MRCHKRESULT = null, --重抄时检查结果类型重置为空
      MRINPUTPER = gs_oper_id ,--入账人员，取系统登录人员
      mrinputdate = SYSDATE,
      mrmemo = '免抄户',
      mrface = '01',
      mrface2 = '01',
      mrcarrysl = 0,
      mrifmch = 'Y',
      MRRPER = ls_BFRPER
      where MRMID =smiid ;         
    else
      update bs_meterread set
      mrreadok = 'N',
      mrifsubmit = 'Y',  --重抄时是否提交计费标志重置为'Y'
      MRCHKFLAG = 'Y',    --重抄时是复核标志重置为'N'
      MRCHKRESULT = null, --重抄时检查结果类型重置为空
      MRINPUTPER = gs_oper_id ,--入账人员，取系统登录人员
      mrinputdate = SYSDATE,
      mrmemo = null,
      mrface = '01',
      mrface2 = '01',
      mrcarrysl = 0,
      mrifmch = 'Y',
      MRRPER = ls_BFRPER,
      mrecode = null,
      mrsl = null
      where MRMID =smiid;
           

    END IF;
        
  END ;
                         

                           
end ;
/

