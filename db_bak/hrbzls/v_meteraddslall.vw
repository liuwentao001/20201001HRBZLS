create or replace force view hrbzls.v_meteraddslall as
select MASID,
       MASSCODEO,
       MASECODEN,
       MASUNINSDATE,
       MASUNINSPER,
       MASCREDATE,
       MASCID,
       MASMID,
       MASSL,
       MASCREPER,
       MASTRANS,
       MASBILLNO,
       MASSCODEN,
       MASINSDATE,
       MASINSPER,
       '' masmrid
  from meteraddsl
union
select MASID,
       MASSCODEO,
       MASECODEN,
       MASUNINSDATE,
       MASUNINSPER,
       MASCREDATE,
       MASCID,
       MASMID,
       MASSL,
       MASCREPER,
       MASTRANS,
       MASBILLNO,
       MASSCODEN,
       MASINSDATE,
       MASINSPER,
       MASMRID
  from meteraddslhis;

