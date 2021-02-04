CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_BANK_01" is
  errcode constant integer := -20012;

  dk生成      constant varchar2(1) := '0'; --代扣生成导出
  dk同步到ftp constant varchar2(1) := '1'; --同步到ftp
  dkftp回传   constant varchar2(1) := '2'; --dkftp回传
---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid
  --note:D:代扣 总过程
  --author:wy
  --date：2011/10/19
  --input: p_bankid:银行代码
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志


  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) ;
  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:D:代扣
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
  --说明：代扣发出一条应收一个一条代收费记录

  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk_rlid_01(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2);



---------------------------------------------------------------------------
  --                        撤销总过程代扣批次数据
  --name:sp_cancle_dk
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk 代扣批次号
  --  p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk(p_entrust_batch in varchar2,
                            p_oper in varchar2,--操作员
                               p_commit        in varchar2)  ;
---------------------------------------------------------------------------
  --                        撤销代扣批次数据
  --name:sp_cancle_dk_batch_01
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_batch_01 代扣批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------

  procedure sp_cancle_dk_batch_01(p_entrust_batch in varchar2,
                              p_oper in varchar2,--操作员
                               p_commit        in varchar2)   ;
---------------------------------------------------------------------------
  --                        撤销代扣导入
  --name:sp_cancle_dk_imp
  --note:撤销代扣导入
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_imp 撤销代扣导入
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_imp_01(p_entrust_batch in varchar2,
                               p_commit        in varchar2)  ;
---------------------------------------------------------------------------
  --name:sp_dk_exp
  --note:导出
  --author:wy
  --date：2009/04/26
  --input: p_type:导出类
  --       p_batch:导出批次
  --说明：导出
 procedure sp_dk_exp(p_type  in varchar2, --导出类
                                      p_batch in varchar2, --导出批次
                                      o_base  out tools.out_base)  ;
 --生成代扣文件名函数
  ---------------------------------------------------------------------------
  --                        生成代扣文件名函数
  --name:fgetdkexpname
  --note:生成代扣文件名函数
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --       p_batch 代扣批次号
  --return DS(2位)+银行编号(4位)+日期(8位)+批次号+(10位)
  -- 如:DK03001200904280000000001
  ---------------------------------------------------------------------------
  function fgetdkexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2 ;
  --取代扣导出格式字符串
  ---------------------------------------------------------------------------
  --                        取代扣导出格式字符串
  --name:fgetdkexpsqlstr
  --note:取代扣导出格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 ;
--取代扣导出格文件类型
  ---------------------------------------------------------------------------
  --                        取代扣导出格文件类型
  --name:fgetdkexpsqlstr
  --note:取代扣导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 ;

  --取代扣导入格式字符串
  ---------------------------------------------------------------------------
  --                        取代扣导入格式字符串
  --name:fgetdkimpsqlstr
  --note:取代扣导入格式字符串
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------
function fgetdkimpsqlstr(p_type in varchar2, p_bankid in varchar2)
  return varchar2 ;
 --代扣数据导入过程
  ---------------------------------------------------------------------------
  --                        代扣数据导入过程
  --name:sq_dkfileimp
  --note:代扣数据导入过程
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
---------------------------------------------------------------------------
procedure sq_dkfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2) ;

  --代扣数据导入过程 通过差,交,并,集处理
  ---------------------------------------------------------------------------
  --                        代扣数据导入过程
  --name:sq_dkfileimp
  --note:代扣数据导入过程
  --author:wy
  --date：2009/10/27
  --input: p_type 类型
  --       p_bankid 银行编号前四位
---------------------------------------------------------------------------
procedure sq_dkfilefastimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2) ;

  --代扣批次销帐和解锁
  --代扣批次销帐和解锁
  procedure sp_dkpos(p_batch in varchar2,--代扣批次流水 序列
               p_oper in varchar2 ,----销帐员
               p_commit in varchar2 --提交标志
               ) ;

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
  PROCEDURE sp_create_ts(              P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
                                       p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) ;
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
  PROCEDURE sp_create_ts_maaccount_01(
                                         P_MODEL   IN VARCHAR2 ,--托收 TS ,零托 LT
                                        p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2);
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
  procedure sp_cancle_ts_batch_01(p_entrust_batch in varchar2,
                                p_oper in varchar2,--操作员
                               p_commit        in varchar2)  ;
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
  procedure sp_cancle_ts_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--操作员
                                 p_commit        in varchar2) ;
---------------------------------------------------------------------------
  --                        撤销托收导入
  --name:sp_cancle_ts_imp_01
  --note:撤销托收导入
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_ts_imp_01 撤销托收导入
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_ts_imp_01(p_entrust_batch in varchar2,
                               p_commit        in varchar2) ;
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
  function fgettsexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2  ;
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

  function fgettsexpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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

  function fgettsimpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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
function fgettsimpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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

  function fgettsexpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;
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
procedure sq_tsfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2)  ;

  --代扣批次销帐和解锁
  procedure sp_tspos(p_batch in varchar2,--代扣批次流水 序列
               p_oper in varchar2 ,----销帐员
               p_commit in varchar2 --提交标志
               ) ;

  ---------------------------------------------------------------------------
  --name:sp_create_rhzs
  --note:M:入户直收
  --author:wy
  --date：2011/10/19
  --input: p_micode   --水表号
  --       p_mibfid   --表册号
  --       p_miCHARGEPER  --催费员
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：入户直收不收滞金,不收手续费


  ---------------------------------------------------------------------------
    PROCEDURE sp_create_rhzs(
                         p_micode in varchar2, --水表号
                         p_mibfid in varchar2,--表册号
                         p_MICPER in varchar2,--催费员
                         p_mfsmfid in varchar2,--营业所代码
                         p_oper    in varchar2,--操作员
                         p_srldate in varchar2,--起始帐务日期 格式: yyyymmdd
                         p_erldate in varchar2,--终止帐务日期 格式: yyyymmdd
                         p_smon    in varchar2,--起始帐务月份 格式: yyyy.mm
                         p_emon    in varchar2,--终止帐务月份 格式: yyyy.mm
                         p_sftype  in varchar2,--银行缴费类型 D:代扣 ,T 托收,M 入户直收
                         p_commit  in varchar2,--提交标志
                         o_batch   out varchar2
                         );

  ---------------------------------------------------------------------------
  --name:sp_create_rhzs_rlid_01
  --note:M:入户直收
  --author:wy
  --date：2011/10/19
  --input: p_micode   --水表号
  --       p_mibfid   --表册号
  --       p_miCHARGEPER  --催费员
  --       p_mfcode:营业所代码
  --       p_oper:操作员
  --       p_srldate:起始帐务日期 格式: yyyymmdd
  --       p_erldate:终止帐务日期 格式: yyyymmdd
  --       p_smon:起始帐务月份 格式: yyyy.mm
  --       p_emon:终止帐务月份 格式: yyyy.mm
  --       p_sftype 银行缴费类型 D:代扣 ,T 托收,M 入户直收
  --       p_commit 提交标志
  --说明：入户直收不收滞金,不收手续费
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_rhzs_rlid_01(
                                     p_micode in varchar2, --水表号
                                     p_mibfid in varchar2,--表册号
                                     p_MICPER in varchar2,--催费员
                                     p_mfsmfid in varchar2,--营业所代码
                                     p_oper    in varchar2,--操作员
                                     p_srldate in varchar2,--起始帐务日期 格式: yyyymmdd
                                     p_erldate in varchar2,--终止帐务日期 格式: yyyymmdd
                                     p_smon    in varchar2,--起始帐务月份 格式: yyyy.mm
                                     p_emon    in varchar2,--终止帐务月份 格式: yyyy.mm
                                     p_sftype  in varchar2,--银行缴费类型 D:代扣 ,T 托收,M 入户直收
                                     p_commit  in varchar2,--提交标志
                                     o_batch   out varchar2
                                         );

---------------------------------------------------------------------------
  --                        撤销总过程入户直收批次数据
  --name:sp_cancle_rhzs
  --note:撤销入户直收批次数据
  --author:wy
  --date：2009/04/26
  --input: p_entrust_batch 入户直收
  --p_oper in varcahr2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs(p_entrust_batch in varchar2,
                             p_oper in varchar2,--操作员
                               p_commit        in varchar2) ;
---------------------------------------------------------------------------
  --                        撤销入户直收批次流水数据
  --name:sp_cancle_rhzs_entpzseqno_01
  --note:撤销入户直收批次流水数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_rhzs_entpzseqno_01  批次号
  --p_enterst_pzseqno  in varchar2,流水号
  --p_oper in varcahr2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--操作员
                                 p_commit        in varchar2) ;

end;
/

