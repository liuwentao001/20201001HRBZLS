CREATE OR REPLACE PACKAGE HRBZLS."PG_MMZLS_ZFB_01" is
       ZB constant varchar2(1) :='2';   --总表
       FB constant varchar2(1):='3';   --分表
       PT constant varchar2(1):='1';   --普通
      errcode constant integer := -20012;  --错误类型
      callogtxt   clob;
       --author:    刘光波
       --Created: 2011-11-06
       --user      :总分表包

       --提供水分表外部调用过程
       /*参数： p_MIPID  上级水表编号，
                       p_miid    下级水表编号
                       p_type    水表级别操作类型:
                                       （AZ  新增总表,DZ 删除总表，AF 新增分表,DF,删除分表）
               p_fttype  水费分摊方式, 在基础字典表里面（syscharlist）
       */
       PROCEDURE sp_mmzls_zfb_set_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2, --下级水表编号
                                                   p_type in varchar2,--水表级别操作类型
                                                   p_fttype in varchar2, --水费分摊方式
                                                    p_msg   out varchar2
                                                    );
       --新增总表
       --参数：p_MIPID  上级水表编号
       --           p_fttype  水费分摊方式
       PROCEDURE sp_mmzls_zfb_addzb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                    p_fttype in varchar2   --水费分摊方式
                                                    );
       --删除总表
       --参数：p_MIPID  上级水表编号
       PROCEDURE sp_mmzls_zfb_deletezb_01(
                                                   p_MIPID in varchar2 --上级水表编号
                                                    );
        --新增分表
        --参数:p_MIPID 上级水表编号
         --          p_miid   下级水表编号
         PROCEDURE sp_mmzls_zfb_addfb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2 --水表编号
                                                    );
        --删除分表
        --参数:p_MIPID 上级水表编号
         -- -         p_miid   下级水表编号
        PROCEDURE sp_mmzls_zfb_deletefb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2 --水表编号
                                                    );
          --获取营业所
         function f_mmzls_getsmfid(p_mid in varchar2)return varchar2;
         -- 总分表算费过程
          procedure SUBMIT_ZFB(P_MRPID in varchar2);
          --  -- 总分表算费过程
           procedure SUBMIT_ZFB(P_MRPID in varchar2, log out clob);
           ----总分表算费过程 【分摊水费】
            function f_mmzls_ftsf(p_mpid in varchar2,p_mrsl in number )return number;
end;
/

