CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_PRINT_01" is
  --Ʊ�ݴ�ӡ��
  procedure sp_gtjf_ocx1(p_pbatch    in varchar2, --ʵ������
                        P_PID       IN varchar2, --ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
                        p_plid      in varchar2, --ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
                        p_modelno   in varchar2, --��Ʊ��ʽ��:2/25
                        p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
                        p_ifbd      in varchar2, --�Ƿ񲹴� --��:Y,��:N
                        P_PRINTER   IN VARCHAR2 --��ӡԱ
                        );

 procedure sp_gtjf_ocx(p_pbatch    in varchar2, --ʵ������
                        P_PID       IN varchar2, --ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
                        p_plid      in varchar2, --ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
                        p_modelno   in varchar2, --��Ʊ��ʽ��:2/25
                        p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
                        p_ifbd      in varchar2, --�Ƿ񲹴� --��:Y,��:N
                        P_PRINTER   IN VARCHAR2 --��ӡԱ
                        );
end;
/

