create or replace procedure hrbzls.SP_合收表维护1(v_miid in varchar2, v_ywbz in char,v_MIPRIID in varchar2)  is
--v_miid 子表号
--v_ywbz所办业务
--v_MIPRIID目的合收表号
   vs_MIPRIFLAG  char;
    ERRCODE CONSTANT INTEGER := -20012;
    v_row number:=0;
    vs_MIPRIID varchar2(10);
    vs_MIIFTAX1 varchar2(10);
    vs_MIIFTAX2 varchar2(10);
    vs_mipfid1 varchar2(10);
    vs_mipfid2 varchar2(10);
begin
  if v_ywbz='Y' THEN  ---合户标志 
    select MIPRIFLAG,MIPRIID into vs_MIPRIFLAG,vs_MIPRIID from meterinfo where miid=v_miid;
    if vs_MIPRIFLAG='Y' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'是合收子表,请先拆分后再合户' );   
    else
        if v_MIPRIID= v_miid then
          RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'不能自己与自己合户' );   
        end if;
    END IF;
    select count(CIID) into v_row from CUSTCHANGEHD,CUSTCHANGEdt WHERE CCHNO=CCDNO and  CCHLB='Y' and nvl(CCHSHFLAG,'N')='N' and
    CIID= v_miid;
    IF v_row>0 THEN 
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'存在合收表工单,请确认后再进行相应工单操作' );
    END IF;
    select  MIIFTAX,mipfid into vs_MIIFTAX1,vs_mipfid1 from meterinfo where miid=v_miid;
    select  MIIFTAX,mipfid into vs_MIIFTAX2,vs_mipfid2 From  meterinfo where miid=v_MIPRIID;
    if vs_MIIFTAX1<>vs_MIIFTAX2 then  
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'与合户增值税状态不一致,请确认后再进行相应工单操作' );
    END IF;
    if vs_mipfid1<>vs_mipfid2 AND vs_MIIFTAX1='Y' AND vs_MIIFTAX2='Y'  then  
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'与合户水价不一致,请确认后再进行相应工单操作' );
    END IF;
    
  --  SELECT COUNT(MIID) INTO v_row from meterinfo  where MIPRIID=v_MIPRIID and MIPRIFLAG='Y' and miid<>MIPRIID;
  --  20141215调整 hb 上述判断错误
   SELECT COUNT(MIID) INTO v_row from meterinfo  where miid=v_MIPRIID and MIPRIFLAG='Y' and miid<>MIPRIID;
    if v_row>0  then
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_MIPRIID||'是合收表子表,不能作为主表进行操作' );
    end if;
  END IF;
  if v_ywbz='N' THEN   --拆分标志
    select MIPRIFLAG,MIPRIID into vs_MIPRIFLAG,vs_MIPRIID from meterinfo where miid=v_miid;
    if vs_MIPRIFLAG='N' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'不是合收表状态' );
    else
       if vs_MIPRIID=v_miid then
         RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'不是合收表子表,不能进行此种拆分' );
       else
         if vs_MIPRIID<>v_MIPRIID then
            RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'的合收主表号不是此号,不能进行此种拆分' );
         end if;
       end if;
    END IF;
    select count(CIID) into v_row from CUSTCHANGEHD,CUSTCHANGEdt WHERE CCHNO=CCDNO and  CCHLB='Y' and nvl(CCHSHFLAG,'N')='N' and
    CIID= v_miid;
    IF v_row>0 THEN 
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'存在合收表工单,请确认后再进行相应工单操作' );
    END IF;
    select count(rlcid) INTO v_row from reclist where rlje>0 and rlcid=v_miid and RLPAIDFLAG='N' AND RLREVERSEFLAG='N';
    IF V_ROW>0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '单据不能保存,此用户:'||v_miid||'存在欠缴记录,不能进行合收表拆分' );
    END IF;
  end if;
end SP_合收表维护1;
/

