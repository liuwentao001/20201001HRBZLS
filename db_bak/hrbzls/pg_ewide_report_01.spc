CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORT_01" is

  -- Author  : wangyong
  -- Created : 2011-10-19
  -- Purpose : Ƿ��

  -- Public type declarations

  -- Public constant declarations
  errcode constant integer := -20012;
   procedure ˮ��Ƿ�ѳ�ʼ��;
   --ˮ��Ƿ��ʵʱ���ͳ��
  procedure ˮ��ʵʱǷ�ѽ��ͳ��(p_miid in varchar2,p_commit in varchar2) ;
  procedure ˮ��Ƿ������job;
  procedure sp_paydaily_Ӫ������(p_no   in varchar2,
                                 p_oper in varchar2,
                                 P_BILLID IN VARCHAR2,
                                 P_DJLB  IN VARCHAR2
                              ) ;
                              
 procedure sp_paydaily_Ӫ�����ʳ���(p_oper in varchar2,
                               p_no   in varchar2
                              );
                              
  procedure sp_paydaily_��������(p_no   in varchar2,
                                p_oper in varchar2,
                                P_BILLID IN VARCHAR2,
                                P_DJLB  IN VARCHAR2
                                );
end;
/

