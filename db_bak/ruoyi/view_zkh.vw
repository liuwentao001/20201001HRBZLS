create or replace force view view_zkh as
select bfid    表册编码,
         bfsmfid 营业所,
         bfpid   上级编码,
         bfclass 级次,
         bfrper  抄表员
    From bs_bookframe
   where bfid in
         ('01', '01001', '01001001', '01001002', '01001003', '01001003')
   order by bfclass;
comment on table VIEW_ZKH is '帐卡号树';

