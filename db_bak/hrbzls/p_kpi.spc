CREATE OR REPLACE PACKAGE HRBZLS."P_KPI"
as
    --����������
    procedure sp_get_kpi(a_type number,a_dim number,id_array varchar2, as_month varchar2);
    --Ӫҵ��
    procedure sp_insert_type1;
    --����Ա
    procedure sp_insert_type2;
    --��ҵ
    procedure sp_insert_type3;
    --����
    procedure sp_insert_type4;
    --�շ�Ա
    procedure sp_insert_type5;
    --�û�
    procedure sp_insert_type6;
    --���˱�
    procedure sp_insert_type7;
    --����
    procedure sp_insert_type8;
end;
/

