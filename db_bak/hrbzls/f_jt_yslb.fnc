CREATE OR REPLACE FUNCTION HRBZLS."F_JT_YSLB" (drtrans in varchar2,drpfid IN VARCHAR2,drclass IN NUMBER) return varchar2 as
/* ��ˮ���ͳ�Ʊ������ ,Ӧ�շ������*/
begin
  if drtrans='T' then
    RETURN 'Ӫҵ������';
  end if;

  IF drclass IN (0,1) THEN
    RETURN fpriceframejcbm(drpfid,1);
  ELSIF drclass=2 then
    RETURN '�ڶ�����';
  ELSE
    RETURN '��������';
  END IF;
end;
/

