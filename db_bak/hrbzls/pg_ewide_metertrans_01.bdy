CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERTRANS_01" IS

  CurrentDate date := tools.fGetSysDate;

  --模拟客户端转单功能
procedure sp_billnew_test  AS
begin

 /* --转单处理
表1 billnewhdNOCOMMIT
1、功能
2、事件   定义 ：单据 ：生成单据方式
3生成单据方式
4、责任方式
5、说明
表2  billnewidNOCOMMIT
6、ID
表3
7、责任范围 billnewoperNOCOMMIT
*/
  null;
--插入单体信息
insert into billnewidNOCOMMIT (
c1--id
) values('2070955417') ;
--插入责任人信息
insert into billnewoperNOCOMMIT (
c1--id
) values('5455') ;
insert into billnewoperNOCOMMIT (
c1--id
) values('000010');
--插入单头信息
insert into billnewhdNOCOMMIT (
c1,--1、功能
c2,--2、事件
c3,--3生成单据方式  （可以直接在功能参数中定义）
c4,--4、责任方式     （可以直接在功能参数中定义）
c5  ,--备注
c6  --6操作人员
) values('010301','ue_createbill','每个ID生成一个单','责任到人','请换表','5455' ) ;
 COMMIT;
end;

  --生成单据过程（基于billnewhdNOCOMMIT插入的触发器）
procedure sp_billbuild_test  AS
  bl billnewhdNOCOMMIT%rowtype;
  ep erpfunctionpara%rowtype;
  ep1 erpfunctionpara%rowtype;
  op operaccnt%rowtype;
  sf sysmanaframe%rowtype;
  dt billnewidNOCOMMIT%rowtype;
  bo billnewoperNOCOMMIT%rowtype;
--查询条件
  v_ip varchar2(20);
  v_user varchar2(20);
  v_login_name varCHAR(40);
  v_billno varchar2(10);
  v_id varchar2(20);
--单据体明细
  cursor c_dt is
  select * from billnewidNOCOMMIT;
  cursor c_bo is
  select * from billnewoperNOCOMMIT;
begin

/* --转单处理
表1 billnewhdNOCOMMIT
1、功能
2、事件   定义 ：单据 ：生成单据方式
3生成单据方式
4、责任方式
5、说明
表2  billnewidNOCOMMIT
、ID
表3
、责任范围 billnewoperNOCOMMIT
6、备用数据调用时输入操作员
7、备用数据调用时输入部门
8、备用数据调用时输入营业所
*/

--1、生成单头信息
--2、生成单体信息
--3、发送到人,发送到单据,发送备注

select * into bl from billnewhdNOCOMMIT where rownum=1;
--1判断单据类别
select * into ep from erpfunctionpara t where efid =  bl.c1
and bl.c2=t.efevent and eftype='单据类别' and efrow='001';
select * into ep1 from erpfunctionpara t where efid =  bl.c1
and bl.c2=t.efevent and eftype='功能参数' and efrow='001' ;

    --获取操作员客户端ip
select sys_context('userenv','sid'),sys_context('userenv','SESSION_USER')
into v_ip, v_user from dual;
--2获取操作员id
BEGIN
  select login_user into v_login_name from sys_host where ip = v_ip;
  EXCEPTION
    WHEN OTHERS then
       v_login_name:=bl.c6 ;
END ;
--3部门
begin
select oadept into op.oadept from  operaccnt where  oaid=v_login_name;
exception when others then
  op.oadept :=bl.c7  ;
  null;
end;
--4营业所
begin
  select smfpid into sf.smfpid  from sysmanaframe where smfid=op.oadept;
 exception when others then
  sf.smfpid :=bl.c8;
  null;
end;

--调用过程
--表务单
if ep.efrunpara='K' then
  --生成方式
  if bl.c3 ='每个ID生成一个单' then
    --游标
    open c_dt;
    loop fetch c_dt into dt;
    exit when c_dt%notfound or c_dt%notfound is null;
    v_billno :='';
    sp_mrmrifsubmit(dt.c1  ,
                            ep.efrunpara  ,
                            '2'  ,
                            sf.smfpid  ,
                            op.oadept  ,
                            v_login_name ,
                            '1' ,
                            v_billno ) ;
    if   v_billno is not null then

        open c_bo;
        loop fetch c_bo into bo;
        exit when c_bo%notfound or c_bo%notfound is null;

     KT_DO_REPORT_COMMITFLAG('1',
                  ep1.efrunpara  ,
                  v_login_name,
                  bo.c1 ,
                  v_billno,
                  bl.c5,
                  'N');



        end loop;
        close c_bo;

    end if;
    end loop;
    close c_dt;
  end if;
end if;




end;

--抄表计划批量生成故障换表工单
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_type in varchar2,
                            p_source in varchar2,
                            p_smfid in varchar2,
                            p_dept in varchar2,
                            p_oper in varchar2,
                            p_flag in varchar2,
                            o_billno out varchar2) is
    cursor c_exist is
    select * from metertranshd
    where mthno in (select mtdno from metertransdt
                   where mtdmid=(select mrmid from meterread where mrid=p_mrid)
                   ) and
          mthshflag not in ('Q','Y') and mthlb=p_type
    for update;

    v_billid varchar2(10);
    v_id varchar2(10);
    mr meterread%rowtype;
    ci custinfo%rowtype;
    mi meterinfo%rowtype;
    md meterdoc%rowtype;
    mh metertranshd%rowtype;
    mt metertransdt%rowtype;
  begin
    if p_flag='0' then--取消
      update meterread
      set mrface=null
      where mrid=p_mrid;
    else--生成工单(重复工单设置加急值，否则生成工单)
      begin
        select * into mr from meterread where mrid=p_mrid;
      exception when others then
        raise_application_error(errcode, '抄表计划不存在!');
      end;
      begin
        select * into ci from custinfo where ciid=mr.mrcid;
      exception when others then
        raise_application_error(errcode, '客户信息不存在!');
      end;
      begin
        select * into mi from meterinfo where miid=mr.mrmid;
      exception when others then
        raise_application_error(errcode, '水表信息信息不存在!');
      end;
      begin
        select * into md from meterdoc where meterdoc.mdmid =mr.mrmid;
      exception when others then
        raise_application_error(errcode, '水表档案信息信息不存在!');
      end;
      begin
        select bmid into v_billid  from billmain  where bmtype=p_type;
      exception when others then
        raise_application_error(errcode, '此种类型单据未定义!');
      end;



      open c_exist;
      fetch c_exist into mh;
      if c_exist%notfound or c_exist%notfound is null then
        --生成工单
        tools.sp_billseq(v_billid,v_id,'N');
        o_billno :=v_id;

        mh.MTHNO          := v_id   ;--单据流水号
        mh.MTHBH          := mh.MTHNO   ;--单据编号
        mh.MTHLB          := p_type   ;--单据类别
        mh.MTHSOURCE      := p_source   ;--单据来源
        mh.MTHSMFID       := p_smfid   ;--营销公司
        mh.MTHDEPT        := p_dept   ;--受理部门
        mh.MTHCREDATE     := SYSDATE   ;--受理日期
        mh.MTHCREPER      := p_oper   ;--受理人员
        mh.MTHSHFLAG      := 'N'   ;--审核标志
        mh.MTHSHDATE      := NULL  ;--审核日期
        mh.MTHSHPER       := NULL  ;--审核人员
        mh.mthhot         := 1;
        mh.mthmrid        := p_mrid;
        insert into metertranshd values mh;



        mt.MTDNO                := mh.MTHNO  ; --单据流水
        mt.MTDROWNO             := 1  ; --行号
        mt.MTDSMFID             := mi.mismfid  ; --营业所
        mt.MTDREQUDATE          := sysdate + 7  ; --要求完成时间
        mt.MTDTEL               := ci.CIMTEL  ; --电话
        mt.MTDCONPER            := ci.CINAME  ; --联系人
        mt.MTDCONTEL            := substr(ci.cimtel||' '||ci.citel1||' '||ci.citel2||' '||ci.ciconnecttel,90); --联系电话
        mt.MTDSHDATE            := null  ; --完工录入日期
        mt.MTDSHPER             := null  ; --完工录入人员
        mt.MTDSENTDEPT          := null  ; --派工部门
        mt.MTDSENTDATE          := null  ; --派工时间
        mt.MTDSENTPER           := null  ; --派工人员
        mt.MTDFLAG              := 'N'  ; --完工标志（N创建S派工Y完工X作废）
        mt.MTDCHKPER            := null  ; --验收收人
        mt.MTDCHKDATE           := null  ; --验收日期
        mt.MTDCHKMEMO           := null  ; --验收结果
        mt.MTDMID               := mi.miid  ; --原水表编号
        mt.MTDMCODE             := mi.micode  ; --原资料号
        mt.MTDMDIDO             := MD.MDID  ; --原表档案号
        mt.MTDMDIDN             := MD.MDID  ; --新表档案号
        mt.MTDCNAME             := ci.CINAME  ; --原用户名
        mt.MTDMADRO             := mi.miadr  ; --原水表地址
        mt.MTDCALIBERO          := md.mdcaliber  ; --原表口径
        mt.MTDBRANDO            := md.mdbrand  ; --原表厂家
        mt.MTDMODELO            := md.mdmodel  ; --原表型号
        mt.MTDMNON              := md.mdno ; --新表身号
        mt.MTDCALIBERN          := null  ; --新表口径
        mt.MTDBRANDN            := null  ; --新表厂家
        mt.MTDMODELN            := null  ; --新表型号
        mt.MTDPOSITIONO         := mi.miposition  ; --原表位描述
        mt.MTDSIDEO             := mi.miside  ; --原表位
        mt.MTDMNOO              := md.mdno  ; --原表身号
        mt.MTDMADRN             := null  ; --新表
        mt.MTDPOSITIONN         := null  ; --新表
        mt.MTDSIDEN             := null  ; --新表
        mt.MTDUNINSPER          := null  ; --拆表员
        mt.MTDUNINSDATE         := null  ; --拆表日期
        mt.MTDSCODE             := mr.mrecode  ; --上期读数
        mt.MTDSCODECHAR         := mr.mrecodechar ;
        mt.MTDECODE             := null  ; --拆表底数
        mt.MTDADDSL             := null  ; --余量
        mt.MTDREINSPER          := null  ; --换表员
        mt.MTDREINSDATE         := null  ; --换表日期
        mt.MTDREINSCODE         := null  ; --新表起数
        mt.MTDREINSDATEO        := null  ; --回滚换表日期
        mt.MTDMSTATUSO          := mi.mistatus  ; --回滚水表状态
        mt.MTDAPPNOTE           := null  ; --申请说明
        mt.MTDFILASHNOTE        := null  ; --领导意见
        mt.MTDMEMO              := '抄见故障表转单'; --备注
        mt.mtdycchkdate         := md.mdcycchkdate;
        mt.mtface1 := mr.mrface;--水表故障
        mt.mtface2 := mr.mrface2;--抄见故障
        mt.miface4 := mr.mrface4;--表井故障
        insert into metertransdt values mt;
        --标记抄表计划转单标志
      update meterread set mriftrans='Y' , MRCHKFLAG='Y'
      , MRIFSUBMIT='N',MRPRIVILEGEPER=v_id   where mrid=p_mrid;

      end if;
      while c_exist%found loop
        update metertranshd set mthhot=nvl(mthhot,0)+1 where current of c_exist;
        fetch c_exist into mh;
      end loop;
      close c_exist;
    end if;
    --commit;
  exception when others then
    if c_exist%isopen then
       close c_exist;
    end if;
    --rollback;
    raise_application_error(errcode,sqlerrm);
  end sp_mrmrifsubmit;



  --单头总体审核
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and t.mtdflag='N' for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单头信息不存在!');
    END;
    --工单信息已经审核不能再审
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --单体完工
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    end loop;
    close c_md;
    --更新单头
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --更新流程
    update kpi_task t set t.do_date=sysdate,t.isfinish='Y' where t.report_id=trim(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;

 --单个单体总体审核
  PROCEDURE SP_METERTRANS_BY(
                          P_MTHNO IN VARCHAR2, --批次流水
                          P_mtdrowno IN VARCHAR2,--行号
                          P_PER   IN VARCHAR2, --操作员
                          P_COMMIT IN VARCHAR2  --提交标志
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and mtdrowno=P_mtdrowno for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单头信息不存在!');
    END;
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '工单已经审核,不需重复审核!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --工单信息已经审核不能再审
    if MD.Mtdflag='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '工单明细已经审核,不需重复审核!');
    end if;
      --单体完工
      SP_METERTRANS_ONE(P_PER, MD,'N');----20131125
    end loop;
    close c_md;
   /* --更新单头
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
*/


    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;


  --表务单体单个明细审核，单据类别字段为单体的 METERTRANSDT 表 MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- 操作员
                             P_MD   IN METERTRANSDT%ROWTYPE, --单体行变更
                             p_commit in varchar2 --提交标志
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    mdsl meteraddsl%ROWTYPE;
    V_COUNT NUMBER(4);
    v_number number(10);
    v_crhno  varchar2(10);
    v_omrid  varchar2(20);
    o_str varchar2(20);

  begin
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表资料不存在!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '用户资料不存在!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '水表不存在!');
    END;

    if mi.mircode != md.MTDSCODE then
      raise_application_error(errcode,'上期抄见发生变化，请重置上期抄见');
    end if;

    --F销户拆表
    if P_MD.MTBK8 = bt销户拆表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;


      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO    ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      --算费
      --?????
    --修改用户状态 custinfo
      UPDATE custinfo  t
      set t.cistatus=c销户 where CIID= mi.micid ;

    ---- METERINFO 有效状态 --状态日期 --状态表务 【yujia 20110323】
      update METERINFO
      set MISTATUS =m销户,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=sysdate
      where MIID=P_MD.Mtdmid;
    -----METERDOC  表状态 表状态发生时间  【yujia 20110323】

      update METERDOC set MDSTATUS =m销户,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;
    elsif P_MD.MTBK8 = bt口径变更 then
      -- METERINFO 有效状态 --状态日期 --状态表务

      --备份记录回滚信息 METERTRANSROLLBACK
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER, --换表人
          mitype = p_md.mtdmtypen  --表型
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS =m立户 ,
          mdcaliber =P_MD.MTDCALIBERN,
          mdno = p_md.mtdmnon, ---表型号
          MDSTATUSDATE=sysdate,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;
/*      --METERTRANSDT 回滚换表日期 回滚水表状态   备份记录回滚信息 METERTRANSROLLBACK 已处理
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE Mtdmid=MI.MIID;*/


      --算费
      --?????


    elsif P_MD.MTBK8 = bt欠费停水 then

      --备份记录回滚信息
      delete    METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      update METERINFO set MISTATUS =m暂停 ,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC set MDSTATUS =m暂停 ,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????


    elsif P_MD.MTBK8 = bt校表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO 有效状态 --状态日期 --状态表务
      --暂不更新本期读数     ,MIRCODE=P_MD.MTDREINSCODE
      update METERINFO
      set MISTATUS      = m立户 ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      where MIID=P_MD.Mtdmid;
      --METERDOC  表状态 表状态发生时间
      update METERDOC
      set MDSTATUS     = m立户 ,
          MDSTATUSDATE = sysdate,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;


      --算费
      --?????
    elsif P_MD.MTBK8 = bt复装 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;



      --暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS =m立户 ,--状态
          MISTATUSDATE=sysdate,--状态日期
          MISTATUSTRANS=P_MD.MTBK8,--状态表务
          MIADR= P_MD.MTDMADRN,--水表地址
          MISIDE= P_MD.MTDSIDEN,--表位
          MIPOSITION = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE =  P_MD.MTDREINSDATE , --换表日期
          MIREINSPER = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS =m立户 ,--状态
          MDSTATUSDATE=sysdate,--状态发生时间
          MDNO=P_MD.MTDMNON,--表身号
          MDCALIBER=P_MD.MTDCALIBERN,--表口径
          MDBRAND=P_MD.MTDBRANDN,--表厂家
          MDMODEL=P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;



      --算费
      --????

    elsif P_MD.MTBK8 = bt故障换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS     =m立户 ,--状态
          MDSTATUSDATE =sysdate,--表状态发生时间
          MDNO         =P_MD.MTDMNON,--表身号
          MDCALIBER    =P_MD.MTDCALIBERN,--表口径
          MDBRAND      =P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;

      --算费
      --??????

    elsif P_MD.MTBK8 = bt周期换表 then

      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --记余量表 METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--记录流水号
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--旧表起度
      MA.MASECODEN       :=P_MD.MTDECODE     ;--旧表止度
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--拆表日期
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--拆表人
      MA.MASCREDATE      :=SYSDATE     ;--创建日期
      MA.MASCID          :=MI.MICID     ;--用户编号
      MA.MASMID          :=MI.MIID     ;--水表编号
      MA.MASSL           :=P_MD.MTDADDSL     ;--余量
      MA.MASCREPER       :=p_per     ;--创建人员
      MA.MASTRANS        :=P_MD.MTBK8     ;--加调事务
      MA.MASBILLNO       :=P_MD.MTDNO     ;--单据流水
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--新表起度
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--装表日期
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--装表人
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO暂不更新本期读数  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m立户 ,--状态
          MISTATUSDATE  = sysdate,--状态日期
          MISTATUSTRANS = P_MD.MTBK8,--状态表务
          --MIADR         = P_MD.MTDMADRN,--水表地址
          --MISIDE        = P_MD.MTDSIDEN,--表位
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--水表接水地址
          MIREINSCODE   = P_MD.MTDREINSCODE ,--换表起度
          MIREINSDATE   = P_MD.MTDREINSDATE , --换表日期
          MIREINSPER    = P_MD.MTDREINSPER --换表人
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS      = m立户 ,--状态
          MDSTATUSDATE  = sysdate,--表状态发生时间
          MDNO          = P_MD.MTDMNON,--表身号
           MDCALIBER     = P_MD.MTDCALIBERN,--表口径
          MDBRAND       = P_MD.MTDBRANDN,--表厂家
          MDMODEL      =P_MD.MTDMODELN,--表型号
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;
      --算费
      --？？？？

    elsif P_MD.MTBK8 = bt复查工单 then
      null;
    elsif P_MD.MTBK8 = bt改装总表 then
       null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
          insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmcode);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
      elsif P_MD.MTBK8 = bt补装户表 then
         null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
           insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmpid);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
    elsif  P_MD.MTBK8 = bt安装分类计量表 then
       null;
      /*tools.SP_BillSeq('100',v_crhno);

      insert into custreghd
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

      insert into custmeterregdt
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR)
      VALUES(v_crhno,1,MI.MISMFID,'新用户','新用户',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
      P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
      P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000');*/
     elsif P_MD.MTBK8 = bt水表升移 then
        null;
             /*-- METERINFO 有效状态 --状态日期 --状态表务
                 update METERINFO
                         set MISTATUS      = m立户 ,
                          MISTATUSDATE  = sysdate,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.Mtdpositionn
                 where MIID=P_MD.Mtdmid;
                 -- meterdoc
                update METERDOC
                 set MDSTATUS     = m立户 ,
                  MDSTATUSDATE = sysdate
                where MDMID=P_MD.Mtdmid;
      --METERTRANSDT 回滚换表日期 回滚水表状态
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE Mtdmid=MI.MIID;
      --备份记录回滚信息
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--单据流水
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--行号
      MK.MTRBDATE                :=SYSDATE       ;--回滚备份日期
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--状态
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--状态日期
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--状态表务
      MK.MTRBRCODE               :=MI.MIRCODE       ;--本期读数
      MK.MTRBADR                 :=MI.MIADR       ;--表地址
      MK.MTRBSIDE                :=MI.MISIDE       ;--表位
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--水表接水地址
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--新装起度
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--换表起度
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--换表日期
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--换表人
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--用户状态
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--状态日期
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--状态表务
      MK.MTRBNO                  :=MC.MDNO       ;--表身码
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--表口径
      MK.MTRBBRAND               :=MC.MDBRAND       ;--表厂家
      MK.MTRBMODEL               :=MC.MDMODEL       ;--表型号
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--表状态
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--表状态发生时间
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --记余量表 METERADDSL
      --算费*/
    END IF;

    --算费 对余量算费开关已打开，且余量大于0 进行算费 进行算费
 IF FSYSPARA('1102')='Y' THEN
    if P_MD.MTDADDSL >= 0 and P_MD.MTDADDSL is not null then        --余量大于0 进行算费
    --将余量添加抄表库
    v_omrid := to_char(sysdate,'yyyy.mm');
      sp_insertmr(p_per,to_char(sysdate,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,mi,v_omrid);

      if v_omrid is not null then --返回流水不等于空，添加成功

           --算费
           pg_ewide_meterread_01.Calculate(v_omrid);

          --将之前余用掉
           PG_ewide_RAEDPLAN_01.sp_useaddingsl(v_omrid, --抄表流水
                        MA.Masid     , --余量流水
                           o_str     --返回值
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=v_omrid ;
           DELETE METERREAD WHERE  MRID=v_omrid ;


    end if;
      MR :=null;
      --查询抄表计划，如果有抄表计划没有抄表就可以修改本抄表计划期抄码
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=mi.micode
      AND MRMONTH= TOOLS.fgetreadmonth(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      if mr.mrid is not null then
         if mr.mrreadok='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      end if;

    end if;
  END IF;

  --更新完工标志
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=sysdate,MTDSHPER=P_PER where MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --提交标志
  if p_commit='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
  end;

procedure sp_insertmr(
                      p_pper in varchar2,--操作员
                      p_month  in varchar2,--应收月份
                      p_mrtrans in varchar2,--抄表事务
                      p_rlsl   in number,--应收水量
                      p_scode  in number,--起码
                      p_ecode  in number,--止码
                      mi in meterinfo%rowtype,  --水表信息
                      omrid out meterread.mrid%type --抄表流水
                      ) as
  mrhis meterread%rowtype; --抄表历史库
  ci custinfo%rowtype; --用户信息
begin
    begin
      select * into ci from custinfo where ciid = mi.micid;
    exception when others then
      raise_application_error(-20010, '用户不存在!');
    end;

      mrhis.MRID                       := fgetsequence('METERREAD')                        ; --流水号
      omrid                            := mrhis.MRID         ;
      mrhis.MRMONTH                    := tools.fgetreadmonth(mi.mismfid)               ; --抄表月份
      mrhis.MRSMFID                    := fgetmeterinfo(mi.miid,'MISMFID')                  ; --营销公司
      mrhis.MRBFID                     := mi.mibfid /*rth.RTHBFID*/                                      ; --表册
      begin
      select  BFBATCH into mrhis.MRBATCH  from bookframe where bfid=mi.mibfid and bfsmfid=mi.mismfid                                      ;
      exception when others then
      mrhis.MRBATCH                    :=  1 ;     --抄表批次
      end;

      begin
          select mrbsdate
          into  mrhis.MRDAY
          from meterreadbatch
          where mrbsmfid=mi.mismfid and
                mrbmonth=mrhis.MRMONTH and
                mrbbatch= mrhis.MRBATCH ;
        exception when others then
        mrhis.MRDAY                       := sysdate                                    ; --计划抄表日
     /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
             raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
       end if;*/
      end;
      mrhis.MRDAY                       := sysdate                                    ; --计划抄表日
      mrhis.MRRORDER                   := mi.MIRORDER                                      ; --抄表次序
      mrhis.MRCID                      := CI.CIID                                       ; --用户编号
      mrhis.MRCCODE                    := CI.CICODE                                     ; --用户号
      mrhis.MRMID                      := MI.MIID                                       ; --水表编号
      mrhis.MRMCODE                    := MI.MICODE                                     ; --水表手工编号
      mrhis.MRSTID                     := mi.MISTID                                        ; --行业分类
      mrhis.MRMPID                     := mi.MIPID                                         ; --上级水表
      mrhis.MRMCLASS                   := mi.MICLASS                                       ; --水表级次
      mrhis.MRMFLAG                    := mi.MIFLAG                                        ; --末级标志
      mrhis.MRCREADATE                 := sysdate                                          ; --创建日期
      mrhis.MRINPUTDATE                := sysdate                                          ; --编辑日期
      mrhis.MRREADOK                   := 'Y'                                              ; --抄见标志
      mrhis.MRRDATE                    := sysdate /*TO_DATE(p_month||'.15','YYYY.MM.DD') */                              ; --抄表日期
     BEGIN
      SELECT MAX( T.BFRPER ) INTO mrhis.MRRPER  FROM BOOKFRAME T WHERE T.BFID=MI.MIBFID AND T.BFSMFID=MI.MISMFID;
     EXCEPTION WHEN OTHERS THEN
       mrhis.MRRPER                     := p_pper                                             ; --预留 空抄表员
     END;
      mrhis.MRPRDATE                   := null                                             ; --上次抄见日期
      mrhis.MRSCODE                    := p_scode                                          ; --上期抄见
      mrhis.MRECODE                    := p_ecode                                          ; --本期抄见
      mrhis.MRSL                       := p_rlsl                                           ; --本期水量
      mrhis.MRFACE                     := NULL                                             ; --水表故障
      mrhis.MRIFSUBMIT                 := 'Y'                                              ; --是否提交计费
      mrhis.MRIFHALT                   := 'N'                                              ; --系统停算
      mrhis.MRDATASOURCE               := p_mrtrans; --抄表结果来源：表务抄表
      mrhis.MRIFIGNOREMINSL            := 'N'                                              ; --停算最低抄量
      mrhis.MRPDARDATE                 := NULL                                             ; --抄表机抄表时间
      mrhis.MROUTFLAG                  := 'N'                                              ; --发出到抄表机标志
      mrhis.MROUTID                    := NULL                                             ; --发出到抄表机流水号
      mrhis.MROUTDATE                  := NULL                                             ; --发出到抄表机日期
      mrhis.MRINORDER                  := NULL                                             ; --抄表机接收次序
      mrhis.MRINDATE                   := NULL                                             ; --抄表机接受日期
      mrhis.MRRPID                     := null                                             ; --计件类型
      mrhis.MRMEMO                     := '换表余量欠费'                                     ; --抄表备注
      mrhis.MRIFGU                     := 'N'                                              ; --估表标志
      mrhis.MRIFREC                    := 'N'                                              ; --已计费
      mrhis.MRRECDATE                  := SYSDATE                                          ; --计费日期
      mrhis.MRRECSL                    := p_rlsl                                        ; --应收水量
      mrhis.MRADDSL                    := 0                                                                                  ; --余量
      mrhis.MRCARRYSL                  := 0                                                ; --进位水量
      mrhis.MRCTRL1                    := NULL                                             ; --抄表机控制位1
      mrhis.MRCTRL2                    := NULL                                             ; --抄表机控制位2
      mrhis.MRCTRL3                    := NULL                                             ; --抄表机控制位3
      mrhis.MRCTRL4                    := NULL                                             ; --抄表机控制位4
      mrhis.MRCTRL5                    := NULL                                             ; --抄表机控制位5
      mrhis.MRCHKFLAG                  := 'N'                                              ; --复核标志
      mrhis.MRCHKDATE                  := NULL                                             ; --复核日期
      mrhis.MRCHKPER                   := NULL                                             ; --复核人员
      mrhis.MRCHKSCODE                 := NULL                                             ; --原起数
      mrhis.MRCHKECODE                 := NULL                                             ; --原止数
      mrhis.MRCHKSL                    := NULL                                             ; --原水量
      mrhis.MRCHKADDSL                 := NULL                                             ; --原余量
      mrhis.MRCHKCARRYSL               := NULL                                             ; --原进位水量
      mrhis.MRCHKRDATE                 := NULL                                             ; --原抄见日期
      mrhis.MRCHKFACE                  := NULL                                             ; --原表况
      mrhis.MRCHKRESULT                := NULL                                             ; --检查结果类型
      mrhis.MRCHKRESULTMEMO            := NULL                                             ; --检查结果说明
      mrhis.MRPRIMID                   := mi.mipriid                                      ; --合收表主表
      mrhis.MRPRIMFLAG                 := mi.mipriflag                                    ; --合收表标志
      mrhis.MRLB                       := mi.milb                                         ; --水表类别
      mrhis.MRNEWFLAG                  := NULL                                             ; --新表标志
      mrhis.MRFACE2                    := NULL                                             ; --抄见故障
      mrhis.MRFACE3                    := NULL                                             ; --非常计量
      mrhis.MRFACE4                    := NULL                                             ; --表井设施说明
      mrhis.MRSCODECHAR                := to_char(p_scode)                                 ; --上期抄见
      mrhis.MRECODECHAR                := to_char(p_ecode)                                ; --本期抄见
      mrhis.MRPRIVILEGEFLAG            := 'N'                                              ; --特权标志(Y/N)
      mrhis.MRPRIVILEGEPER             := NULL                                             ; --特权操作人
      mrhis.MRPRIVILEGEMEMO            := NULL                                             ; --特权操作备注
      mrhis.MRPRIVILEGEDATE            := NULL                                             ; --特权操作时间
      mrhis.MRSAFID                    := MI.MISAFID                                       ; --管理区域
      mrhis.MRIFTRANS                  := 'N'                                        ; --抄表事务
      mrhis.MRREQUISITION              := 0                                                ; --通知单打印次数
      mrhis.MRIFCHK                    := MI.MIIFCHK                                       ; --考核表
    insert into meterread values mrhis;
end;

end;
/

