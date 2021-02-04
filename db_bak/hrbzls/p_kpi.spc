CREATE OR REPLACE PACKAGE HRBZLS."P_KPI"
as
    --定义主过程
    procedure sp_get_kpi(a_type number,a_dim number,id_array varchar2, as_month varchar2);
    --营业所
    procedure sp_insert_type1;
    --抄表员
    procedure sp_insert_type2;
    --行业
    procedure sp_insert_type3;
    --抄本
    procedure sp_insert_type4;
    --收费员
    procedure sp_insert_type5;
    --用户
    procedure sp_insert_type6;
    --考核表
    procedure sp_insert_type7;
    --区域
    procedure sp_insert_type8;
end;
/

