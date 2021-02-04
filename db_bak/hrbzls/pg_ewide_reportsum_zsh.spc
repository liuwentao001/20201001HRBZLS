CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_REPORTSUM_ZSH" is

  -- Author  : stevewei
  -- Created : 2012-0101
  -- Purpose : 月报

--从实例化视图生成 0--实时 1--重算
  ls_need_reeval constant integer := 1;

function F_STATIS_SAVING_1D(P_DATE IN DATE) return number;

function F_STATIS_SAVING(P_D1 IN DATE,P_D2 IN DATE) return number;
function F_CHK_SAVING(P_DATE IN DATE) return number;
Function F_CHK_PAYMENT(P_DATE IN DATE) return number;
Function F_STATID_PAYMENT_1D(P_DATE IN DATE) return number;
    --综合月报
   procedure 综合月报(a_month in varchar2);
end;
/

