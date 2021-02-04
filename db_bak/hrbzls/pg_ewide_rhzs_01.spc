CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RHZS_01" is
  errcode constant integer := -20012;

  dk生成      constant varchar2(1) := '0'; --代扣生成导出
  dk同步到ftp constant varchar2(1) := '1'; --同步到ftp
  dkftp回传   constant varchar2(1) := '2'; --dkftp回传


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
  --                        撤销入户直收批次数据
  --name:sp_cancle_rhzs_batch_01
  --note:撤销代扣批次数据
  --author:wy
  --date：2009/04/26
  --input: sp_cancle_dk_batch_01 入户直收批次号
  --p_oper in varchar2,--操作员
  --       p_commit 提交标志

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_batch_01(p_entrust_batch in varchar2,
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

