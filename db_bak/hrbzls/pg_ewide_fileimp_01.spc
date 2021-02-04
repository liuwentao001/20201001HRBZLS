CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_FILEIMP_01" is
 errcode constant integer := -20012;
--远传表导入文档检查
---------------------------------------------------------------------------
  --                        远传表导入文档检查
  --name:sp_remotemeterdatechk
  --note:远传表导入文档检查
  --author:yf
  --date：2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdatechk(p_id in varchar2);

--远传表文档导入
---------------------------------------------------------------------------
  --                        远传表文档导入
  --name:sp_remotemeterdateimp
  --note:远传表文档导入
  --author:yf
  --date：2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdateimp(p_id in varchar2);

--远传表文档保存
---------------------------------------------------------------------------
  --                        远传表文档保存
  --name:sp_remotemeterdatesave
  --note:远传表文档保存
  --author:yf
  --date：2009/10/05

---------------------------------------------------------------------------
procedure sp_remotemeterdatesave(p_id in varchar2);
  --动态调用过程
  ---------------------------------------------------------------------------
  --                        动态调用过程
  --name:sp_execprc
  --note:动态调用过程
  --author:yf
  --date：2009/10/05

---------------------------------------------------------------------------
PROCEDURE sp_execprc(vfimpid IN VARCHAR2, /*系统任务号*/
                     vtype IN VARCHAR2,
                     vpara IN VARCHAR2 DEFAULT NULL);
end ;
/

