CREATE OR REPLACE PROCEDURE HRBZLS."SP_CUSTCHANGEPRINTSEARCH" (p_CCDNO      in varchar2,
                                                     p_PRINTTITLE in varchar2,
                                                     p_PRINTER    in varchar2,
                                                     o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  v_sql := 'SELECT t.CCDNO||''-''||t.CCDROWNO �Ǽǵ���, ' ||
           't2.cchcredate �Ǽ�����, ' ||
           '''�ͻ����룺''||t1.micode  �ͻ�����, ' ||
           '''��Ȩ����''||t1.ciname ��Ȩ��,  ' ||
           '''���ַ��''||t1.miadr ���ַ, ' ||
           '''ˮ��ھ���''||to_char(t1.mdcaliber) ˮ��ھ�, ' ||
           '''��ˮ���''|| fGetpricetail(t1.MIID) ��ˮ���, ' ||
           '''�ɷѷ�ʽ��''|| fgetsyschargetype(t1.michargetype)  �ɷѷ�ʽ, ' ||
           '''ҵ�����''|| (select bmname  from billmain tt where bmtype= t2.CCHLB  )          ҵ����� ,  ' ||
           'FgetCUSTCHANGESTR(t.CCDNO,t.CCDROWNO  ) �����ϸ, ' ||
           '''Ƿ�ѽ�     Ԫ''  Ƿ�ѽ��, ' ||
           '''�Ƿ��壺  ��    ��''  �Ƿ����, ' ||
           ' FGETBILLMAIN( t2.CCHLB,''BMFLAG1'' )  ��ע��Ϣ, ' ||
           '''ԭ�û��� ''  ԭ�û�, ' ||
           ' t2.Cchcreper ||''��''|| fGetOperName(t2.Cchcreper)||''��''   ������, ' ||
           '''���û��� ''  ���û�,' ||
           'fgetsmfname(t1.CISMFID) ��������, ' ||
           '''�ۺϼ۸�''|| FGETZHPRICE(t1.MICODE)||''Ԫ/��''     �ۺϼ۸�, ' ||
           '''��ţ� ''||t1.MDNO ���, ' ||
           '''��ϵ�ˣ� ''||t1.CICONNECTPER ��ϵ��, ' ||
           '''��ϵ�绰�� ''||t1.CICONNECTTEL ��ϵ�绰, ' ||
           '''����ԭ�� ''||t1.CCDAPPNOTE ����ԭ��,' ||
           '''���֤��ӡ����''||t1.ACCESSORYFLAG09 ���֤��ӡ�� ,' ||
           '''ˮ�ѵ����飺 ''||t1.ACCESSORYFLAG04 ˮ�ѵ����� ,' ||
           '''���޺�ͬ��ӡ���� ''||t1.ACCESSORYFLAG05 ���޺�ͬ��ӡ�� ,' ||
           '''����֤�򹺷���ͬ��ӡ���� ''||t1.ACCESSORYFLAG06 ����֤�򹺷���ͬ��ӡ�� ,' ||
           '''��ҵ����Ӫҵִ�գ� ''||t1.ACCESSORYFLAG07 ��ҵ����Ӫҵִ��,' ||
           '''������ ''||t1.ACCESSORYFLAG08 ����,' ||
           ' fgetrecqfmoney(t.MIID)  Ƿ����Ϣ'||
           ' FROM CUSTCHANGEDTHIS   t, CUSTCHANGEDT t1, CUSTCHANGEHD t2' ||
           ' where t.CCDNO in (''' || replace( p_CCDNO,',',''',''' ) || ''')' ||
           ' and t.CCDNO=t1.CCDNO and t.CCDNO = t2.CCHNO' ||
           ' and t.CCDROWNO = t1.CCDROWNO' ||
           ' order by t.CCDNO,  t.CCDROWNO';
  open o_base for v_sql;
end;
/

