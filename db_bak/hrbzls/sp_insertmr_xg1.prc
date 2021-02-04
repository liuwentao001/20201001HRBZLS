CREATE OR REPLACE PROCEDURE HRBZLS."SP_INSERTMR_XG1" (p_billno varchar2,
                                              omrid out meterread.mrid%type) as   --抄表流水

  mi meterinfo%rowtype; --水表信息
  mr meterread%rowtype; --抄表历史库
  ci custinfo%rowtype; --用户信息
  mrs METERTRANSDT%rowtype; --工单记录
begin
    begin
      select * into mrs from METERTRANSDT where mtdno=p_billno;
    exception when others then
       raise_application_error(-20010, '此工单不存在!');
    end;
    begin
      select * into mi from meterinfo where miid=mrs.mtdmid;
      exception when others then
         raise_application_error(-20010, '此水表不存在!');
      end;
    begin
      select * into ci from custinfo where ciid = mi.micid;
    exception when others then
      raise_application_error(-20010, '用户不存在!');
    end;
      if mrs.mtbk8='Y' then
      mr.mrID                       := fgetsequence('METERREAD')                        ; --流水号
      omrid                            := mr.mrID         ;
      mr.mrMONTH                    := tools.fgetreadmonth(mi.mismfid)               ; --抄表月份
      mr.mrSMFID                    := fgetmeterinfo(mi.miid,'MISMFID')                  ; --营销公司
      mr.mrBFID                     := mi.mibfid /*rth.RTHBFID*/                                      ; --表册
      begin
      select  BFBATCH into mr.mrBATCH  from bookframe where bfid=mi.mibfid and bfsmfid=mi.mismfid                                      ;
      exception when others then
      mr.mrBATCH                    :=  1 ;     --抄表批次
      end;

      begin
          select mrbsdate
          into  mr.mrDAY
          from meterreadbatch
          where mrbsmfid=mi.mismfid and
                mrbmonth=mr.mrMONTH and
                mrbbatch= mr.mrBATCH ;
        exception when others then
        mr.mrDAY                       := sysdate                                    ; --计划抄表日
     /* if fsyspara('0039')='Y' then--是否按计划抄表日覆盖实际抄表日
             raise_application_error(ErrCode, '取计划抄表日错误，请检查计划抄表批次定义');
       end if;*/
      end;
      mr.mrDAY                       := sysdate                                    ; --计划抄表日
      mr.mrRORDER                   := mi.MIRORDER                                      ; --抄表次序
      mr.mrCID                      := CI.CIID                                       ; --用户编号
      mr.mrCCODE                    := CI.CICODE                                     ; --用户号
      mr.mrMID                      := MI.MIID                                       ; --水表编号
      mr.mrMCODE                    := MI.MICODE                                     ; --水表手工编号
      mr.mrSTID                     := mi.MISTID                                        ; --行业分类
      mr.mrMPID                     := mi.MIPID                                         ; --上级水表
      mr.mrMCLASS                   := mi.MICLASS                                       ; --水表级次
      mr.mrMFLAG                    := mi.MIFLAG                                        ; --末级标志
      mr.mrCREADATE                 := sysdate                                          ; --创建日期
      mr.mrINPUTDATE                := sysdate                                          ; --编辑日期
      mr.mrREADOK                   := 'Y'                                              ; --抄见标志
      mr.mrRDATE                    := mrs.mtdshdate                                    ; --抄表日期
      mr.mrRPER                     := null                                             ; --预留 空抄表员
      mr.mrPRDATE                   := null                                             ; --上次抄见日期
      mr.mrSCODE                    := mrs.mtdscode                                          ; --上期抄见
      mr.mrECODE                    := mrs.mtdecode                                          ; --本期抄见
      mr.mrSL                       := mrs.mtdaddsl                                           ; --本期水量
      mr.mrFACE                     := '01'                                             ; --水表故障
      mr.mrIFSUBMIT                 := 'Y'                                              ; --是否提交计费
      mr.mrIFHALT                   := 'N'                                              ; --系统停算
      mr.mrDATASOURCE               := '1'; --抄表结果来源：表务抄表
      mr.mrIFIGNOREMINSL            := 'N'                                              ; --停算最低抄量
      mr.mrPDARDATE                 := NULL                                             ; --抄表机抄表时间
      mr.mrOUTFLAG                  := 'N'                                              ; --发出到抄表机标志
      mr.mrOUTID                    := NULL                                             ; --发出到抄表机流水号
      mr.mrOUTDATE                  := NULL                                             ; --发出到抄表机日期
      mr.mrINORDER                  := NULL                                             ; --抄表机接收次序
      mr.mrINDATE                   := NULL                                             ; --抄表机接受日期
      mr.mrRPID                     := null                                             ; --计件类型
      mr.mrMEMO                     := '表务抄表'                                     ; --抄表备注
      mr.mrIFGU                     := 'N'                                              ; --估表标志
      mr.mrIFREC                    := 'N'                                              ; --已计费
      mr.mrRECDATE                  := SYSDATE                                          ; --计费日期
      mr.mrRECSL                    := mrs.mtdaddsl                                        ; --应收水量
      mr.mrADDSL                    := 0                                                                                  ; --余量
      mr.mrCARRYSL                  := 0                                                ; --进位水量
      mr.mrCTRL1                    := NULL                                             ; --抄表机控制位1
      mr.mrCTRL2                    := NULL                                             ; --抄表机控制位2
      mr.mrCTRL3                    := NULL                                             ; --抄表机控制位3
      mr.mrCTRL4                    := NULL                                             ; --抄表机控制位4
      mr.mrCTRL5                    := NULL                                             ; --抄表机控制位5
      mr.mrCHKFLAG                  := 'N'                                              ; --复核标志
      mr.mrCHKDATE                  := NULL                                             ; --复核日期
      mr.mrCHKPER                   := NULL                                             ; --复核人员
      mr.mrCHKSCODE                 := NULL                                             ; --原起数
      mr.mrCHKECODE                 := NULL                                             ; --原止数
      mr.mrCHKSL                    := NULL                                             ; --原水量
      mr.mrCHKADDSL                 := NULL                                             ; --原余量
      mr.mrCHKCARRYSL               := NULL                                             ; --原进位水量
      mr.mrCHKRDATE                 := NULL                                             ; --原抄见日期
      mr.mrCHKFACE                  := NULL                                             ; --原表况
      mr.mrCHKRESULT                := NULL                                             ; --检查结果类型
      mr.mrCHKRESULTMEMO            := NULL                                             ; --检查结果说明
      mr.mrPRIMID                   := mi.mipriid                                      ; --合收表主表
      mr.mrPRIMFLAG                 := mi.mipriflag                                    ; --合收表标志
      mr.mrLB                       := mi.milb                                       ; --水表类别
      mr.mrNEWFLAG                  := NULL                                             ; --新表标志
      mr.mrFACE2                    := NULL                                             ; --抄见故障
      mr.mrFACE3                    := NULL                                             ; --非常计量
      mr.mrFACE4                    := NULL                                             ; --表井设施说明
      mr.mrSCODECHAR                := to_char(mrs.mtdscode )                                 ; --上期抄见
      mr.mrECODECHAR                := to_char(mrs.mtdecode )                                ; --本期抄见
      mr.mrPRIVILEGEFLAG            := 'N'                                              ; --特权标志(Y/N)
      mr.mrPRIVILEGEPER             := NULL                                             ; --特权操作人
      mr.mrPRIVILEGEMEMO            := NULL                                             ; --特权操作备注
      mr.mrPRIVILEGEDATE            := NULL                                             ; --特权操作时间
      mr.mrSAFID                    := MI.MISAFID                                       ; --管理区域
      mr.mrIFTRANS                  := 'N'                                              ; --转办工单标志
      mr.mrREQUISITION              := 0                                                ; --通知单打印次数
      mr.mrIFCHK                    := MI.MIIFCHK                                       ; --考核表
      mr.mrbfday                    := 0;
    insert into meterread values mr;
    end if;
end;
/

