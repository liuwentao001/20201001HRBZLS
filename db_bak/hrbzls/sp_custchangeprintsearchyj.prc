CREATE OR REPLACE PROCEDURE HRBZLS."SP_CUSTCHANGEPRINTSEARCHYJ" (p_CCDNO in varchar2,
p_PRINTTITLE in varchar2,
p_PRINTER in varchar2,
 o_base out tools.out_base) is
 v_sql VARCHAR(20000);
  begin
v_sql := 'SELECT t.CCDNO||''-''||t.CCDROWNO �Ǽǵ���, '||
         't2.cchcredate �Ǽ�����, ' ||
         '''�ͻ����룺''||t1.cicode �ͻ�����, ' ||
         '''��Ȩ����''||t1.ciname ��Ȩ��,  '||
         '''ˮ���ַ��''||t1.miposition ˮ���ַ, ' ||
         '''��ţ�''||t1.MDNO ���, ' ||
         '''ˮ��ھ���''||to_char(t1.mdcaliber) ˮ��ھ�, ' ||
         '''��ˮ���''|| FGETPRICEFRAME(t1.pmdpfid) ��ˮ���, ' ||
         '''�ۺϼ۸�''|| FGETZHPRICE(t1.MIID) �ۺϼ۸�, ' ||
         '''�ɷѷ�ʽ��''|| fgetsyschargetype(t1.michargetype)  �ɷѷ�ʽ, '||
         '''ҵ�����''|| (select bmname  from billmain tt where bmtype= t2.CCHLB  )          ҵ����� ,  '   ||
         'FgetCUSTCHANGESTR(t.CCDNO,t.CCDROWNO  ) �����ϸ, '||
         '''Ƿ�ѽ�     Ԫ'' Ƿ�ѽ��, '   ||
         '''     �Ƿ��壺 ��   ��'' �Ƿ����, '||
          ' FGETBILLMAIN( t2.CCHLB,''BMFLAG1'' )  ��ע��Ϣ, '||
         '''ԭ�û���''  ԭ�û�, '||
         ' fGetOperName(t2.Cchcreper)  ������, '||
         '''���û���''  ���û�,' ||
         'fgetsmfname(t1.CISMFID) �������� '||
    ' FROM CUSTCHANGEDTHIS   t, CUSTCHANGEDT t1, CUSTCHANGEHD t2'||
' where t.CCDNO in ('''||p_CCDNO||''')'||
' and t.CCDNO=t1.CCDNO and t.CCDNO = t2.CCHNO'||
' and t.CCDROWNO = t1.CCDROWNO'||
' order by t.CCDNO,  t.CCDROWNO' ;
    open o_base for v_sql;
  end ;
/

