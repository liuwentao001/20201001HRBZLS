CREATE OR REPLACE FUNCTION HRBZLS."F_GETIFZNJ" (p_miid in varchar2) return varchar2 is
  v_mi  meterinfo%rowtype;
  v_ci  custinfo%rowtype;
  v_ret varchar2(2);
begin
  /*
    ��;:  �Ƿ����ɽ�
    ���ߣ� lgb
    ʱ��:  2012-04-22
  */
  v_ret := 'Y';
  select * into v_mi from meterinfo mi where mi.miid = p_miid;
  select * into v_ci from custinfo ci where ci.ciid = v_mi.micid;

 -- ��ֵ˰����Ʊ
  ---����ҵ����Ҫ�����е�ΥԼ��ļ���ͨ���Ƿ���ȡΥԼ��ı�־�ж�  --2013-03-04��
 /* if v_mi.MIIFTAX = 'Y' or v_mi.michargetype in ('T', 'M') then
    v_ret := 'N';
  end if;*/

  if v_ci.ciifzn = 'N'  then
    v_ret := 'N';
  end if;
  return v_ret;
end f_getifznj;
/

