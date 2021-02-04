CREATE OR REPLACE PROCEDURE HRBZLS."WX_MHIS" is
    /*mi meterinfo%rowtype;
    ci custinfo%rowtype;*/
    mh meterreadhis%rowtype;
  begin

    delete meterreadhis;

    for i in (select * from reclist) loop
             select SEQ_MHIS.NEXTVAL into mh.mrid from dual; -- 流水号
             mh.mrmonth                      := i.rlmonth; -- 抄表月份
             mh.mrsmfid                      := '020101'; -- 营销公司
             mh.mrbfid                       := i.rlbfid; -- 表册
             mh.mrbatch                      := 1; -- 抄表批次
             mh.mrday                        := null; -- 计划抄表日
             mh.mrrorder                     := null; -- 抄表次序
             mh.mrcid                        := i.rlcid; -- 用户编号
             mh.mrccode                      := i.rlccode; -- 用户号
             mh.mrmid                        := i.rlmid; -- 水表编号
             mh.mrmcode                      := i.rlmcode; -- 水表手工编号
             mh.mrstid                       := '01'; -- 行业分类      meterinfo
             mh.mrmpid                       := i.rlmpid ; -- 上级水表
             mh.mrmclass                     := i.rlmclass ; -- 水表级次
             mh.mrmflag                      := 'Y'; -- 末级标志
             mh.mrcreadate                   := null; -- 创建日期
             mh.mrinputdate                  := null; -- 编辑日期
             mh.mrreadok                     := 'Y'; -- 抄见标志
             mh.mrrdate                      := i.rldate; -- 抄表日期
             mh.mrrper                       := i.rlrper; -- 抄表员
             mh.mrprdate                     := i.rlprdate ; -- 上次抄见日期
             mh.mrscode                      := i.rlscode ; -- 上期抄见
             mh.mrecode                      := i.rlecode ; -- 本期抄见
             mh.mrsl                         := i.rlreadsl ; -- 本期水量
             mh.mrface                       := 'N'; -- 水表故障
             mh.mrifsubmit                   := 'Y'; -- 是否提交计费
             mh.mrifhalt                     := 'N'; -- 系统停算
             mh.mrdatasource                 := '1'; -- 抄表结果来源
             mh.mrifignoreminsl              := null; -- 停算最低抄量
             mh.mrpdardate                   := null; -- 抄表机抄表时间
             mh.mroutflag                    := 'N'; -- 发出到抄表机标志
             mh.mroutid                      := null; -- 发出到抄表机流水号
             mh.mroutdate                    := null; -- 发出到抄表机日期
             mh.mrinorder                    := null; -- 抄表机接收次序
             mh.mrindate                     := null; -- 抄表机接受日期
             mh.mrrpid                       := null; -- 计件类型
             mh.mrmemo                       := i.rlaccountname; -- 抄表备注
             mh.mrifgu                       := 'N'; -- 估表标志
             mh.mrifrec                      := 'Y'; -- 已计费
             mh.mrrecdate                    := i.rldate; -- 计费日期
             mh.mrrecsl                      := i.rlsl; -- 应收水量
             mh.mraddsl                      := null; -- 余量
             mh.mrcarrysl                    := null; -- 进位水量
             mh.mrctrl1                      := null; -- 抄表机控制位1
             mh.mrctrl2                      := null; -- 抄表机控制位2
             mh.mrctrl3                      := null; -- 抄表机控制位3
             mh.mrctrl4                      := null; -- 抄表机控制位4
             mh.mrctrl5                      := null; -- 抄表机控制位5
             mh.mrchkflag                    := null; -- 复核标志
             mh.mrchkdate                    := null; -- 复核日期
             mh.mrchkper                     := null; -- 复核人员
             mh.mrchkscode                   := null; -- 原起数
             mh.mrchkecode                   := null; -- 原止数
             mh.mrchksl                      := null; -- 原水量
             mh.mrchkaddsl                   := null; -- 原余量
             mh.mrchkcarrysl                 := null; -- 原进位水量
             mh.mrchkrdate                   := null; -- 原抄见日期
             mh.mrchkface                    := null; -- 原表况
             mh.mrchkresult                  := null; -- 检查结果类型
             mh.mrchkresultmemo              := null; -- 检查结果说明
             mh.mrprimid                     := i.rlprimcode ; -- 合收表主表
             mh.mrprimflag                   := i.rlpriflag ; -- 合收表标志
             mh.mrlb                         := i.rllb; -- 水表类别
             mh.mrnewflag                    := 'N'; -- 新表标志
             mh.mrface2                      := null; -- 抄见故障
             mh.mrface3                      := null; -- 非常计量
             mh.mrface4                      := null; -- 表井设施说明
             mh.mrscodechar                  := i.rlscodechar ; -- 上期抄见
             mh.mrecodechar                  := i.rlecodechar ; -- 本期抄见
             mh.mrprivilegeflag              := 'N'; -- 特权标志(y/n)
             mh.mrprivilegeper               := null; -- 特权操作人
             mh.mrprivilegememo              := null; -- 特权操作备注
             mh.mrprivilegedate              := null; -- 特权操作时间
             mh.mrsafid                      := null; -- 管理区域
             mh.mriftrans                    := 'N'; -- 转办工单标志
             mh.mrrequisition                := null; -- 通知单打印次数
             mh.mrifchk                      := 'N'; -- 考核表
             mh.mrinputper                   := null; -- 入账人员
             mh.mrpfid                       := i.rlpfid; -- 用水类别
             mh.mrcaliber                    := i.rlcaliber; -- 口径
             mh.mrside                       := 'O'; -- 表位
             mh.mrlastsl                     := null; -- 上次抄表水量
             mh.mrthreesl                    := null; -- 前三月抄表水量
             mh.mryearsl                     := null; -- 去年同期抄表水量
             mh.mrrecje01                    := null; -- 应收金额费用项目01
             mh.mrrecje02                    := null; -- 应收金额费用项目02
             mh.mrrecje03                    := null; -- 应收金额费用项目03
             mh.mrrecje04                    := null; -- 应收金额费用项目04

    insert into meterreadhis values mh;
    commit;
    end loop;

    exception when others then
    raise_application_error(-20010,sqlerrm||'kkkkkk');
    rollback;

  end;
/

