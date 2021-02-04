CREATE OR REPLACE FUNCTION HRBZLS."F_ANALYPBSQL" (p_contSTR   in varchar2 )
  return varchar2 is
  v_count        number;
  V_contSTR      VARCHAR2(4000);
  V_TEMPSTR      VARCHAR2(4000);
  V_WHERESTR     VARCHAR2(4000);
  v_tablestr     VARCHAR2(4000);
  v_temptablestr VARCHAR2(4000);
begin
  /* f_�������ݴ�����������
  ����
      PBSQLSTR  PBSQL�ַ���
  ���
      SQL���
  ���̣�
      ��1������ ����1��rthsl^t<=^t100^t^t0^t100^tdeci^tRECTRANSHD.RTHSL
                ����2��rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL

          B�ж���������
          C�ұ�
          Dѭ���ֽ�ƴ����
          E����ѭ����ƴSQL���
          F������������  */

  V_contSTR := 'rthsl^t<=^t100^t^t0^t100^tdeci^tRECTRANSHD.RTHSL';
  V_contSTR := 'rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL';

  V_contSTR := p_contSTR;
  --V_contSTR :='cchcredate^t>=^t2009-10-01^tAND^t1^t2009-10-01^tdate^tCUSTCHANGEHD.CCHCREDATE^r^ncchshflag^t=^tN^t^t1^tN^tchar^tCUSTCHANGEdt.CCHSHFLAG';
/*begin
select t.dcifdwconstr into V_contSTR   from dwcontinfo t
where  DCIFID=p_DCIFID ;
exception when others then
  return '1=1';
end;*/

  --A�ַ��滻
  v_count := tools.fmidn_sepmore(V_contSTR, '^r^n');

  -- rthsl^t<=^t100^tAND^t0^t100^tdeci^tRECTRANSHD.RTHSL^r^nrthsl^t>=^t0^t^t0^t0^tdeci^tRECTRANSHD.RTHSL
  for i in 1 .. v_count loop
    V_TEMPSTR  := tools.fmid_sepmore(V_contSTR, i, 'N', '^r^n');
    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 1, 'N', '^t') ||
                  '   '; --�ֶ�
    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 2, 'N', '^t') ||
                  '   '; --������ϵ > =

    --V_WHERESTR :=V_WHERESTR ||tools.fmid_sepmore (V_TEMPSTR,7,'N','^t')||'   ';--ֵ���
    if tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'deci' then
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --ֵ
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'numb' then
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --ֵ
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'char' then
      V_WHERESTR := V_WHERESTR || '''' ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '''' ||
                    '   '; --ֵ
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'date' then
      V_WHERESTR := V_WHERESTR || 'to_date(''' ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') ||
                    ''',''yyyy-mm-dd'')' || '   '; --ֵ
    elsif tools.fmid_sepmore(V_TEMPSTR, 7, 'N', '^t') = 'datetime' then
      -- V_WHERESTR :=V_WHERESTR ||'to_date('||tools.fmid_sepmore (V_TEMPSTR,6,'N','^t')||',''yyyy-mm-dd hh24:mi:ss'')'||'   ';--ֵ
      null;
    else
      V_WHERESTR := V_WHERESTR ||
                    tools.fmid_sepmore(V_TEMPSTR, 6, 'N', '^t') || '   '; --ֵ
    end if;

    V_WHERESTR := V_WHERESTR || tools.fmid_sepmore(V_TEMPSTR, 4, 'N', '^t') ||
                  '   '; --��ϵ AND OR
    --ȡ��
    if v_tablestr is null then
      v_tablestr := tools.fmid_sepmore(tools.fmid_sepmore(V_TEMPSTR,
                                                          8,
                                                          'N',
                                                          '^t'),
                                       1,
                                       'N',
                                       '.'); --ȡ��
    else
      --������
      v_temptablestr := tools.fmid_sepmore(tools.fmid_sepmore(V_TEMPSTR,
                                                              8,
                                                              'N',
                                                              '^t'),
                                           1,
                                           'N',
                                           '.');
      if instr(v_tablestr || ',', v_temptablestr || ',') < 1 then
        v_tablestr := v_tablestr || ',' || v_temptablestr;
      end if;
    end if;
  end loop;

  return  v_tablestr || '��#$#��' || V_WHERESTR;

exception
  when others then

    return 'N';
end;
/

