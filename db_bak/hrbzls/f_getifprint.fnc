CREATE OR REPLACE FUNCTION HRBZLS."F_GETIFPRINT" (p_miid in varchar2) return varchar2 is
  v_mi meterinfo%rowtype;
  v_ret varchar2(2);
begin
  /*
    ��;:  �Ƿ��ӡƱ��
    ���ߣ� lgb
    ʱ��:  2012-04-22
  */
  v_ret:='Y';
  select * into v_mi from meterinfo mi where mi.miid=p_miid;

  -- ��ֵ˰����Ʊ

   /* if v_mi.MIIFTAX='Y' then
        v_ret :='N' ;
     end if;*/
  return v_ret;
end f_getifprint;
/

