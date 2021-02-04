CREATE OR REPLACE PROCEDURE HRBZLS."SP_CUSTXHGD" (p_CCDNO      in varchar2,
                                        p_PRINTTITLE in varchar2,
                                        p_PRINTER    in varchar2,
                                        o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  v_sql := 'SELECT T1.MTHNO  �Ǽǵ���, ' || 'T1.MTHCREDATE �Ǽ�����, ' ||
           '
           (CASE WHEN (T1.MTHLB)=''A'' THEN ''ԭ�����ܱ�ͻ����룺''
                 WHEN (T1.MTHLB)=''Q'' THEN ''�ο��ͻ����룺''
                 WHEN (T1.MTHLB)=''P'' THEN ''�ο��ͻ����룺''
                 ELSE ''�ͻ����룺 ''
                 END)

           ||T2.MICODE �ͻ�����, ' ||
           '''��Ȩ����''||T3.CINAME ��Ȩ��,  ' ||
           '''ˮ���ַ��''||t2.MIADR ˮ���ַ, ' ||
           '''�ھ���''||to_char(T4.mdcaliber) �ھ�, ' ||
           '''��ˮ���''|| fGetpricetail(T2.MIID) ��ˮ���, ' ||
           '''�ɷѷ�ʽ��''|| fgetsyschargetype(T2.michargetype)  �ɷѷ�ʽ, ' ||
           '''ҵ�����''|| (select bmname  from billmain tt where bmtype= t1.MTHLB) ҵ�����,  ' ||
           ' FGETBILLMAIN(T1.MTHLB,''BMFLAG1'' ) ��ע��Ϣ, ' ||
           ' FGETXHGD(T1.MTHNO,T1.MTHLB ) ������Ϣ, ' ||
           ' T1.MTHCREPER||''��''|| fgetopername(T1.MTHCREPER)||''��'' ������, ' ||
           ' fgetsmfname(T1.MTHSMFID) ��������, ' ||
           '''�ۺϼ۸�:''|| FGETZHPRICE(T2.MICODE)||''Ԫ/��'' �ۺϼ۸�, ' ||
           '''���:''||T4.MDNO ���, ' ||
           '''��ϵ�ˣ� ''||T.mtdconper ��ϵ��, ' ||
           '''��ϵ�绰�� ''||T.mtdcontel ��ϵ�绰, ' ||
           '''��ˮ��ַ�� ''||T.MTDMADRN ��ˮ��ַ, ' ||
           '''����ԭ�� ''||T.MTDAPPNOTE ����ԭ�� ,' ||
           ' fgetrecqfmoney(t.MTDMID) Ƿ����Ϣ ,' ||
           ' (CASE WHEN (T1.MTHLB)=''A'' THEN ''ԭ�����ܱ�ͻ�����:''
                 ELSE '' ''
                 END)  �Ͽͻ����� ' ||
           ' FROM METERTRANSDT  T, METERTRANSHD  T1, METERINFO T2, CUSTINFO T3,METERDOC T4' ||
           ' where T.MTDNO IN  ('''||replace(p_CCDNO,',',''',''')||''')' ||
           ' AND  T1.MTHNO=T.MTDNO AND T.MTDMID = T2.MIID  AND T2.MICID=T3.CIID  AND T2.MIID=T4.MDMID' ||
           ' ORDER BY  T1.MTHNO';
/*   INSERT INTO ���Ա�(STR1 ) VALUES(v_sql);
   COMMIT;*/
  open o_base for v_sql;
end;
/

