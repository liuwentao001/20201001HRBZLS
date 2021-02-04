CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORT_01" is

  -- Author  : wangyong
  -- Created : 2011-10-19
  -- Purpose : 欠费

  -- Public type declarations

  -- Public constant declarations
  errcode constant integer := -20012;
   procedure 水表欠费初始化;
   --水表欠费实时结存统计
  procedure 水表实时欠费结存统计(p_miid in varchar2,p_commit in varchar2) ;
  procedure 水表欠费重算job;
  procedure sp_paydaily_营销扎帐(p_no   in varchar2,
                                 p_oper in varchar2,
                                 P_BILLID IN VARCHAR2,
                                 P_DJLB  IN VARCHAR2
                              ) ;
                              
 procedure sp_paydaily_营销扎帐撤销(p_oper in varchar2,
                               p_no   in varchar2
                              );
                              
  procedure sp_paydaily_财务扎帐(p_no   in varchar2,
                                p_oper in varchar2,
                                P_BILLID IN VARCHAR2,
                                P_DJLB  IN VARCHAR2
                                );
end;
/

