create or replace force view hrbzls.v_bank_path as
select BANKID,
       max(DECODE(P_type,'���۷���',path,'')) as dkout,
       max(DECODE(P_type,'���۷���',path,'')) as dkin,
       max(DECODE(P_type,'���շ���',path,'')) as tsout,
       max(DECODE(P_type,'���շ���',path,'')) as tsin,
       max(DECODE(P_type,'ǩԼ����',path,'')) as qyout,
       max(DECODE(P_type,'ǩԼ����',path,'')) as qyin,
       max(DECODE(P_type,'����',path,'')) as dz
from bank_path t
group by bankid;

