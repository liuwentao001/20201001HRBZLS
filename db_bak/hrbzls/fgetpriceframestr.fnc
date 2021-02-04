CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICEFRAMESTR" (p_code in varchar2) return string is
  pfstr varchar2(500);
  mi_row meterinfo%rowtype;
  pf_row priceframe%rowtype;
  pd_row pricedetail%rowtype;
  pmd_row pricemultidetail%rowtype;

  cursor cur_pf is
  select max(pfname),sum(pddj),pmdscale,pmdid  from pricemultidetail,pricedetail,priceframe
    where pmdmid = p_code and pmdpfid = pfid and pdpfid = pfid
    group by pdpfid,pmdscale,pmdid order by pmdid;

begin
  select * into mi_row from meterinfo where miid = p_code;
  if mi_row.miifmp = 'N' then
    select max(pfname),sum(pddj) into pf_row.pfname,pd_row.pddj from pricedetail,priceframe
    where pdpfid = mi_row.mipfid and pdpfid = pfid group by pdpfid;
  --  pfstr :='100%'|| pf_row.pfname ||'水价' ||tools.fformatnum( pd_row.pddj,2)||'元';
      pfstr := pf_row.pfname ||'水价' ||tools.fformatnum( pd_row.pddj,2)||'元';
  else
    open cur_pf;
      loop fetch cur_pf into pf_row.pfname,pd_row.pddj,pmd_row.pmdscale,pmd_row.pmdid;
      exit when cur_pf%notfound or cur_pf%notfound is null;
      if pmd_row.pmdid = 0 then

      pfstr :=pfstr ||'固定量'|| pd_row.pddj ||'吨'|| pf_row.pfname ||'水价' ||tools.fformatnum( pd_row.pddj,2)||'元 ';
      else
        pfstr :=pfstr || pmd_row.pmdscale*100||'%'|| pf_row.pfname ||'水价' ||tools.fformatnum( pd_row.pddj,2)||'元 ';
      end if;
      end loop;
    close cur_pf;
  end if;
  return pfstr;

exception when others then
  return 0;
end ;
/

