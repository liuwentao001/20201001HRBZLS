CREATE OR REPLACE FUNCTION HRBZLS."FGET_PY" (P_���� CHAR DEFAULT '%') RETURN CHAR IS

  /********************************************************************
  �������ƣ�PUB_GET_PY
  ���ܣ����ɺ���ƴ�������ַ�
  �����ߣ����Ⲩ
  ��ϵ��ʽ��
  ����޸�ʱ�䣺2012-12-07
  ˵����

  �޸ļ�¼��
        2012-12-07 ���Ⲩ ����
  ********************************************************************/

  V_�������� NUMBER(8);
  V_ƴ��     CHAR(1);
BEGIN
  V_�������� := ASCII(P_����);

  IF V_�������� BETWEEN 45217 AND 45252 THEN
    V_ƴ�� := 'A';
  ELSIF V_�������� BETWEEN 45253 AND 45760 THEN
    V_ƴ�� := 'B';
  ELSIF V_�������� BETWEEN 45761 AND 46317 THEN
    V_ƴ�� := 'C';
  ELSIF V_�������� BETWEEN 46318 AND 46825 THEN
    V_ƴ�� := 'D';
  ELSIF V_�������� BETWEEN 46826 AND 47009 THEN
    V_ƴ�� := 'E';
  ELSIF V_�������� BETWEEN 47010 AND 47296 THEN
    V_ƴ�� := 'F';
  ELSIF V_�������� BETWEEN 47297 AND 47613 THEN
    V_ƴ�� := 'G';
  ELSIF V_�������� BETWEEN 47614 AND 48116 THEN
    V_ƴ�� := 'H';
  ELSIF V_�������� BETWEEN 48117 AND 49061 THEN
    V_ƴ�� := 'J';
  ELSIF V_�������� BETWEEN 49062 AND 49323 THEN
    V_ƴ�� := 'K';
  ELSIF V_�������� BETWEEN 49324 AND 49895 THEN
    V_ƴ�� := 'L';
  ELSIF V_�������� BETWEEN 49896 AND 50370 THEN
    V_ƴ�� := 'M';
  ELSIF V_�������� BETWEEN 50371 AND 50613 THEN
    V_ƴ�� := 'N';
  ELSIF V_�������� BETWEEN 50614 AND 50621 THEN
    V_ƴ�� := 'O';
  ELSIF V_�������� BETWEEN 50622 AND 50925 THEN
    V_ƴ�� := 'P';
  ELSIF V_�������� BETWEEN 50926 AND 51386 THEN
    V_ƴ�� := 'Q';
  ELSIF V_�������� BETWEEN 51387 AND 51445 THEN
    V_ƴ�� := 'R';
  ELSIF V_�������� BETWEEN 51446 AND 52217 THEN
    V_ƴ�� := 'S';
  ELSIF V_�������� BETWEEN 52218 AND 52697 THEN
    V_ƴ�� := 'T';
  ELSIF V_�������� BETWEEN 52698 AND 52979 THEN
    V_ƴ�� := 'W';
  ELSIF V_�������� BETWEEN 52980 AND 53640 THEN
    V_ƴ�� := 'X';
  ELSIF V_�������� BETWEEN 53641 AND 54480 THEN
    V_ƴ�� := 'Y';
  ELSIF V_�������� BETWEEN 54481 AND 55289 THEN
    V_ƴ�� := 'Z';
  ELSE
    V_ƴ�� := NULL;
  END IF;

  RETURN V_ƴ��;
END FGET_PY;
/

