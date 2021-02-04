CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PRINT_01" is
  --票据打印包
  procedure sp_gtjf_ocx1(p_pbatch    in varchar2, --实收批次
                        P_PID       IN varchar2, --实收流水(不空按实收流水打印)
                        p_plid      in varchar2, --实收明细流水(不空按实收明细流水打印)
                        p_modelno   in varchar2, --发票格式号:2/25
                        p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
                        p_ifbd      in varchar2, --是否补打 --是:Y,否:N
                        P_PRINTER   IN VARCHAR2 --打印员
                        );

 procedure sp_gtjf_ocx(p_pbatch    in varchar2, --实收批次
                        P_PID       IN varchar2, --实收流水(不空按实收流水打印)
                        p_plid      in varchar2, --实收明细流水(不空按实收明细流水打印)
                        p_modelno   in varchar2, --发票格式号:2/25
                        p_printtype in varchar2, --合票:H/分票:F /按户汇总发票 Z
                        p_ifbd      in varchar2, --是否补打 --是:Y,否:N
                        P_PRINTER   IN VARCHAR2 --打印员
                        );
end;
/

