create or replace force view hrbzls.v_bank_path as
select BANKID,
       max(DECODE(P_type,'代扣发出',path,'')) as dkout,
       max(DECODE(P_type,'代扣返回',path,'')) as dkin,
       max(DECODE(P_type,'托收发出',path,'')) as tsout,
       max(DECODE(P_type,'托收返回',path,'')) as tsin,
       max(DECODE(P_type,'签约发出',path,'')) as qyout,
       max(DECODE(P_type,'签约返回',path,'')) as qyin,
       max(DECODE(P_type,'对账',path,'')) as dz
from bank_path t
group by bankid;

