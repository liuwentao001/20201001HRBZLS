CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_DK_01" is
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

  --name:sp_create_dk_batch_rlid_01
  --note:T:代扣
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
  PROCEDURE sp_create_dk_rlid_03(

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
function fgetdkexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2  ;
--取代扣导出格文件类型
  ---------------------------------------------------------------------------
  --                        取代扣导出格文件类型
  --name:fgetdkexpfiletype
  --note:取代扣导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;


  ---------------------------------------------------------------------------
  --                        取代扣导出格文件路径
  --name:fgetdkexpfiletype
  --note:取代扣导出格文件路径
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilepath(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

 ---------------------------------------------------------------------------
  --                        取代扣导出格文件路径
  --name:fgetdkexpfiletype
  --note:取代扣导出格式
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilegs(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;


 ---------------------------------------------------------------------------
  --                        取代扣导出格文件路径
  --name:fgetdkexpfiletype
  --note:取代扣导出后缀
  --author:lgb
  --date：2012/09/22
  --input: p_type 类型
  --       p_bankid 银行编号前四位
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilehz(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

   --取代扣导入格文件类型
  ---------------------------------------------------------------------------
  --                        取代扣导入格文件类型
  --name:fgetdkimpfiletype
  --note:取代扣导出格文件类型
  --author:wy
  --date：2009/04/28
  --input: p_type 类型
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkimpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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
function fgetdkimpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;




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

  function fgetdkexpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;
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
procedure sp_DKfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2)  ;

  --代扣批次销帐和解锁
  procedure sp_dkpos(p_batch in varchar2,--代扣批次流水 序列
               p_oper in varchar2 ,----销帐员
               p_commit in varchar2 --提交标志
               ) ;
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
  ---------------------------------------------------------------------------
 ---银行批扣（20121204）
  procedure sp_YHPLDK_exp(p_type  in varchar2, --导出类
                                   p_batch in varchar2, --导出批次
                                    p_filename in varchar2, ---文件名称
                                    o_base  out tools.out_base);
---银行批扣对账（20121211）
procedure sp_yhpkdz_exp(p_type  in varchar2, --导出类
                                     p_batch in varchar2, --导出批次
                                     p_filename in varchar2 ---文件名称
                              );
 end;
/

