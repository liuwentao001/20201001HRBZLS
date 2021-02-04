CREATE OR REPLACE FUNCTION HRBZLS."FMETERADDSLHIS" (p_id in varchar2,p_type in varchar2)
  RETURN VARCHAR2
AS
  lret    VARCHAR2(60);
  lnum    NUMBER;
BEGIN
  If p_type='D'THEN
    DELETE FROM Meteraddslhis
    WHERE masmrid   = p_id;
    COMMIT;
    lret := 'Y';
  End If;
  If p_type='S'THEN
    SELECT COUNT(*) INTO lnum FROM Meteraddslhis
    WHERE masmrid = p_id;
    If lnum >= 1 Then
       lret := 'Y';
    Else
       lret := 'N';
    End If;
  End If;
  If p_type='MASSCODEO'THEN
     SELECT COUNT(*) INTO lnum FROM Meteraddslhis
      WHERE masmrid   = p_id;
      If lnum >= 1 Then
         SELECT to_char(MASSCODEO) INTO lret FROM Meteraddslhis
         WHERE masmrid   = p_id;
      Else
         lret := '0';
      End If;
  End If;
  If p_type='MASECODEN'THEN
     SELECT COUNT(*) INTO lnum FROM Meteraddslhis
      WHERE masmrid   = p_id;
      If lnum >= 1 Then
         SELECT to_char(MASECODEN) INTO lret FROM Meteraddslhis
         WHERE masmrid   = p_id;
      Else
         lret := '0';
      End If;
  End If;

  If p_type='MASSCODEN'THEN
     SELECT COUNT(*) INTO lnum FROM Meteraddslhis
      WHERE masmrid   = p_id;
      If lnum >= 1 Then
         SELECT to_char(MASSCODEN) INTO lret FROM Meteraddslhis
         WHERE masmrid   = p_id;
      Else
         lret := '0';
      End If;
  End If;
  If p_type='MASSL'THEN
     SELECT COUNT(*) INTO lnum FROM Meteraddslhis
      WHERE masmrid   = p_id;
      If lnum >= 1 Then
         SELECT to_char(MASSL) INTO lret FROM Meteraddslhis
         WHERE masmrid   = p_id;
      Else
         lret := '0';
      End If;
  End If;
  Return lret;
exception when others then
   return '0';
END;
/

