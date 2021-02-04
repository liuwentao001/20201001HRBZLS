CREATE OR REPLACE FUNCTION HRBZLS."FGETXHGD" (P_ID in varchar2, P_TYPE IN VARCHAR2)
  return varchar2 as
  v_ret  varchar2(10000);
  v_list varchar2(1000);
begin
  IF P_TYPE = '3' THEN
    --ˮ����Ǩ
    select 'ԭ��λ' || ':       ' || NVL(T.MTDSIDEO, 'Ϊ��') ||
           '    ' || '�±�λ' || ':       ' ||
           NVL(T.MTDSIDEN, 'Ϊ��') || chr(13) || 'ԭ��ˮ��ַ' || ': ' ||
           NVL(T.MTDPOSITIONO, 'Ϊ��') || '  ' || '��ˮ��ַ' || ': ' ||
           NVL(T.MTDPOSITIONN, 'Ϊ��')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'G' THEN
    --�ھ����
    select 'ԭ�ھ�' || ':  ' || NVL(T.MTDCALIBERO, '') ||
           '  ' || '�±�ھ�' || ':       ' ||
           NVL(T.MTDCALIBERN, '') || chr(13) || 'ԭ����' || ':  ' ||
           NVL(T.MTDMODELO, '') || '  ' || '�±���' ||
           ': ' || NVL(T.MTDMODELN, '')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'F' THEN
    --ˮ������
    select '    '
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'P' THEN
    --��װ���������
    select '�ھ�    '||' ԭ:' ||rpad(to_char(T.MTDCALIBERO),18,' ')||'����:'||to_char(T.MTDCALIBERN)||chr(13)||
           '����    '||' ԭ:' ||rpad(nvl(FGETSYSMETERTYPE(T.mtdmtypeo),' '),18,' ')||'����:'|| NVL(FGETSYSMETERTYPE(T.mtdmtypen), '')||chr(13)||
           '��ˮ���'||' ԭ:' ||rpad(fGetpricetail(T.MTDMID),18,' ')||'����:'||chr(13)||
           '�ۺϼ۸�'||' ԭ:' ||rpad(fgetzhprice(T.MTDMCODE),18,' ')||'����:'||chr(13)||
           '�������'||'    ' ||rpad(' ',18,' ')||'����:'||to_char(T.MTDMCOUNT)
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'J' THEN
    --У��
    select 'J'
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  IF P_TYPE = 'A' THEN
    --��װ�ܱ�
    select '¥��'||':     '||NVL(T.MTDFLOOR, 0) || chr(13) ||
           '����'||':     '||NVL(T.MTDCCOUNT, 0) || chr(13) ||
           '����'||':     '||NVL(T.MTDMCOUNT, 0) || chr(13) ||
           'תѹ��ʩ'||': '||decode(T.MTDIFZYSB, 'Y', '��', 'N', '��', '') ||chr(13) ||
           'ˮ����'||':   '||decode(T.MTDIFSX, 'Y', '��', 'N', '��', '')
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
    /*select '��ˮ���' || ' (��)��' || NVL(fGetpricetail(T.MTDMID), '') ||
           '   ' || ' ��: ' || '���˱�'
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;*/
  END IF;

  IF P_TYPE = 'Q' THEN
    --��������װ
    select '����' ||':   ' || NVL(T.MTDCCOUNT, 0) || chr(13) ||
           '����' ||':   ' || NVL(T.MTDMCOUNT, 0)
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;

  IF P_TYPE = 'I' THEN
    --��װ
    select '    '
      into v_list
      from METERTRANSDT T, METERTRANSHD T1
     where T1.MTHNO = T.MTDNO
       AND T.MTDNO = P_ID;
    v_ret := v_list;
  END IF;
  return v_ret;
exception
  when others then
    return null;
end;
/

