CREATE OR REPLACE PROCEDURE HRBZLS."SP_INSERTMR_XG" (p_month  in varchar2,--应收月份
                                              p_rlsl   in number,--应收水量
                                              p_scode  in number,--起码
                                              p_ecode  in number,--止码
                                              mi in meterinfo%rowtype,  --水表信息
                                              omrid out meterread.mrid%type) as   --抄表流水
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
      mrhis.MRMONTH                    := tools.fGetmeterplanMon(mi.mismfid)               ; --抄表月份
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
      mrhis.MRRDATE                    := SYSDATE                            ; --抄表日期
      mrhis.MRRPER                     := null                                             ; --预留 空抄表员
      mrhis.MRPRDATE                   := null                                             ; --上次抄见日期
      mrhis.MRSCODE                    := p_scode                                          ; --上期抄见
      mrhis.MRECODE                    := p_ecode                                          ; --本期抄见
      mrhis.MRSL                       := p_rlsl                                           ; --本期水量
      mrhis.MRFACE                     := NULL                                             ; --水表故障
      mrhis.MRIFSUBMIT                 := 'Y'                                              ; --是否提交计费
      mrhis.MRIFHALT                   := 'N'                                              ; --系统停算
      mrhis.MRDATASOURCE               := '1'; --抄表结果来源：表务抄表
      mrhis.MRIFIGNOREMINSL            := 'N'                                              ; --停算最低抄量
      mrhis.MRPDARDATE                 := NULL                                             ; --抄表机抄表时间
      mrhis.MROUTFLAG                  := 'N'                                              ; --发出到抄表机标志
      mrhis.MROUTID                    := NULL                                             ; --发出到抄表机流水号
      mrhis.MROUTDATE                  := NULL                                             ; --发出到抄表机日期
      mrhis.MRINORDER                  := NULL                                             ; --抄表机接收次序
      mrhis.MRINDATE                   := NULL                                             ; --抄表机接受日期
      mrhis.MRRPID                     := null                                             ; --计件类型
      mrhis.MRMEMO                     := '手工录入欠费'                                     ; --抄表备注
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
      mrhis.MRLB                       := mi.milb                                       ; --水表类别
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
      mrhis.MRIFTRANS                  := 'N'                                              ; --转办工单标志
      mrhis.MRREQUISITION              := 0                                                ; --通知单打印次数
      mrhis.MRIFCHK                    := MI.MIIFCHK                                       ; --考核表
    insert into meterread values mrhis;
end;
/

