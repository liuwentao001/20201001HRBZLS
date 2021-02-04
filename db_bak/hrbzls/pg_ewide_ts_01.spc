CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_TS_01" IS
  ERRCODE CONSTANT INTEGER := -20012;

  DK生成      CONSTANT VARCHAR2(1) := '0'; --代扣生成导出
  DK同步到FTP CONSTANT VARCHAR2(1) := '1'; --同步到ftp
  DKFTP回传   CONSTANT VARCHAR2(1) := '2'; --dkftp回传

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:托收
  --author:wy
  --date：2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一帐号一个一条代收费记录

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                         P_BANKID  IN VARCHAR2,
                         P_MFSMFID IN VARCHAR2,
                         P_OPER    IN VARCHAR2,
                         P_SRLDATE IN VARCHAR2,
                         P_ERLDATE IN VARCHAR2,
                         P_SMON    IN VARCHAR2,
                         P_EMON    IN VARCHAR2,
                         P_SFTYPE  IN VARCHAR2,
                         P_COMMIT  IN VARCHAR2,
                         O_BATCH   OUT VARCHAR2);
  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:托收
  --author:wy
  --date：2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_01(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  PROCEDURE SP_CREATE_TS_MAACCOUNT_02(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  --name:sp_create_dk_batch_rlid_01
  --note:T:托收
  --author:lgb
  --date：2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录
  PROCEDURE SP_CREATE_TS_MAACCOUNT_03(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);

  --name:SP_CREATE_TS_MAACCOUNT_04
  --note:T:托收
  --author:lgb
  --date：2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
  -- p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：托收发出一条应收一个一条代收费记录
  PROCEDURE SP_CREATE_TS_MAACCOUNT_04(P_MODEL   IN VARCHAR2, --托收 TS ,零托 LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      P_STSH    IN VARCHAR2,
                                      P_ETSH    IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  ---------------------------------------------------------------------------
  --                        撤销托收批次数据
  --name:sp_cancle_ts_batch
  --note:撤销托收批次数据
  --author:wy
  --date：2009/04/26
  --input: p_entrust_batch 托收批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_BATCH_01(P_ENTRUST_BATCH IN VARCHAR2,
                                  P_OPER          IN VARCHAR2, --操作员
                                  P_COMMIT        IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        撤销托收批次数据
  --name:sp_cancle_ts_entpzseqno_01
  --note:撤销托收批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_ts_entpzseqno_01 托收批次号
  --p_enterst_pzseqno  in varchar2,流水号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_ENTPZSEQNO_01(P_ENTRUST_BATCH   IN VARCHAR2,
                                       P_ENTERST_PZSEQNO IN VARCHAR2,
                                       P_OPER            IN VARCHAR2, --操作员
                                       P_COMMIT          IN VARCHAR2);

  --撤销未销账 lgb by 2012-09-27
  PROCEDURE SP_CANCLE_TS_WXZ_01(P_BATCH IN VARCHAR2, P_OPER IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        撤销托收导入
  --name:sp_cancle_ts_imp_01
  --note:撤销托收导入
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_ts_imp_01 撤销托收导入
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH IN VARCHAR2,
                                P_COMMIT        IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        生成托收文件名函数
  --name:fgettsexpname
  --note:生成托收文件名函数
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --       p_batch 托收批次号
  --return TSDS(4位)+银行编号(6位)+日期(8位)+批次号+(10位)
  -- 如:DK03001200904280000000001
  ---------------------------------------------------------------------------
  FUNCTION FGETTSEXPNAME(P_TYPE   IN VARCHAR2,
                         P_BANKID IN VARCHAR2,
                         P_BATCH  IN VARCHAR2) RETURN VARCHAR2;
  --取托收导出格文件类型
  ---------------------------------------------------------------------------
  --                        取托收导出格文件类型
  --name:fgettsexpfiletype
  --note:取托收导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        取托收导出格文件路径
  --name:fgettsexpfiletype
  --note:取托收导出格文件路径
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEPATH(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        取托收导出格文件路径
  --name:fgettsexpfiletype
  --note:取托收导出格式
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEGS(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        取托收导出格文件路径
  --name:fgettsexpfiletype
  --note:取托收导出后缀
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEHZ(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --取托收导入格文件类型
  ---------------------------------------------------------------------------
  --                        取托收导入格文件类型
  --name:fgettsimpfiletype
  --note:取托收导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSIMPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --取托收导入格式字符串
  ---------------------------------------------------------------------------
  --                        取托收导入格式字符串
  --name:fgettsimpsqlstr
  --note:取托收导入格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------
  FUNCTION FGETTSIMPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --取托收导出格式字符串
  ---------------------------------------------------------------------------
  --                        取托收导出格式字符串
  --name:fgetdkexpsqlstr
  --note:取托收导出格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;
  --托收数据导入过程
  ---------------------------------------------------------------------------
  --                        托收数据导入过程
  --name:sq_dkfileimp
  --note:托收数据导入过程
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP_BAK(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2);

  --托收数据导入过程
  ---------------------------------------------------------------------------
  --                        托收数据导入主过程
  --name:sq_dkfile
  --note:托收数据导入过程
  --author:lgb
  --date：2013/03/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP(P_BATCH    IN VARCHAR2,
                         P_COUNT    IN NUMBER,
                         P_LASTTIME IN VARCHAR2);
  --托收数据导入过程
  ---------------------------------------------------------------------------
  --                        托收数据导入过程快速导入
  --name:SQ_TSFILEIMPfast
  --note:托收数据导入过程
  --author:lgb
  --date：2013/03/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMPFAST(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2);
  --代扣批次销帐和解锁
  PROCEDURE SP_TSPOS(P_BATCH  IN VARCHAR2, --代扣批次流水 序列
                     P_OPER   IN VARCHAR2, ----销帐员
                     P_COMMIT IN VARCHAR2 --提交标志
                     );

  --name:sp_dk_exp
  --note:导出
  --author:wy
  --date：2009/04/26
  --input: p_type:导出类
  --       p_batch:导出批次
  --说明：导出
  PROCEDURE SP_TS_EXP(P_TYPE  IN VARCHAR2, --导出类
                      P_BATCH IN VARCHAR2, --导出批次
                      O_BASE  OUT TOOLS.OUT_BASE);
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:取污水 的水量
  --author:刘光波
  --date：2011/11/10
  --input: pc 批次号
  --       tsh  托收号
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSSL_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:取污水 的金额
  --author:刘光波
  --date：2011/11/10
  --input: pc 批次号
  --       tsh  托收号
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSJE_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER;
END;
/

