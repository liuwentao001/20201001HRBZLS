CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_FILEIMP_01" is
 errcode constant integer := -20012;
--Զ�������ĵ����
---------------------------------------------------------------------------
  --                        Զ�������ĵ����
  --name:sp_remotemeterdatechk
  --note:Զ�������ĵ����
  --author:yf
  --date��2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdatechk(p_id in varchar2);

--Զ�����ĵ�����
---------------------------------------------------------------------------
  --                        Զ�����ĵ�����
  --name:sp_remotemeterdateimp
  --note:Զ�����ĵ�����
  --author:yf
  --date��2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdateimp(p_id in varchar2);

--Զ�����ĵ�����
---------------------------------------------------------------------------
  --                        Զ�����ĵ�����
  --name:sp_remotemeterdatesave
  --note:Զ�����ĵ�����
  --author:yf
  --date��2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdatesave(p_id in varchar2);
  --��̬���ù���
  ---------------------------------------------------------------------------
  --                        ��̬���ù���
  --name:sp_execprc
  --note:��̬���ù���
  --author:yf
  --date��2009/10/05

---------------------------------------------------------------------------
PROCEDURE sp_execprc(vfimpid IN VARCHAR2, /*ϵͳ�����*/
                     vtype IN VARCHAR2,
                     vpara IN VARCHAR2 DEFAULT NULL);
end ;
/

