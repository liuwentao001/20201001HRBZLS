CREATE OR REPLACE FUNCTION HRBZLS."FGET_PY" (P_汉字 CHAR DEFAULT '%') RETURN CHAR IS

  /********************************************************************
  过程名称：PUB_GET_PY
  功能：生成汉字拼音的首字符
  开发者：刘光波
  联系方式：
  最后修改时间：2012-12-07
  说明：

  修改记录：
        2012-12-07 刘光波 创建
  ********************************************************************/

  V_汉字内码 NUMBER(8);
  V_拼音     CHAR(1);
BEGIN
  V_汉字内码 := ASCII(P_汉字);

  IF V_汉字内码 BETWEEN 45217 AND 45252 THEN
    V_拼音 := 'A';
  ELSIF V_汉字内码 BETWEEN 45253 AND 45760 THEN
    V_拼音 := 'B';
  ELSIF V_汉字内码 BETWEEN 45761 AND 46317 THEN
    V_拼音 := 'C';
  ELSIF V_汉字内码 BETWEEN 46318 AND 46825 THEN
    V_拼音 := 'D';
  ELSIF V_汉字内码 BETWEEN 46826 AND 47009 THEN
    V_拼音 := 'E';
  ELSIF V_汉字内码 BETWEEN 47010 AND 47296 THEN
    V_拼音 := 'F';
  ELSIF V_汉字内码 BETWEEN 47297 AND 47613 THEN
    V_拼音 := 'G';
  ELSIF V_汉字内码 BETWEEN 47614 AND 48116 THEN
    V_拼音 := 'H';
  ELSIF V_汉字内码 BETWEEN 48117 AND 49061 THEN
    V_拼音 := 'J';
  ELSIF V_汉字内码 BETWEEN 49062 AND 49323 THEN
    V_拼音 := 'K';
  ELSIF V_汉字内码 BETWEEN 49324 AND 49895 THEN
    V_拼音 := 'L';
  ELSIF V_汉字内码 BETWEEN 49896 AND 50370 THEN
    V_拼音 := 'M';
  ELSIF V_汉字内码 BETWEEN 50371 AND 50613 THEN
    V_拼音 := 'N';
  ELSIF V_汉字内码 BETWEEN 50614 AND 50621 THEN
    V_拼音 := 'O';
  ELSIF V_汉字内码 BETWEEN 50622 AND 50925 THEN
    V_拼音 := 'P';
  ELSIF V_汉字内码 BETWEEN 50926 AND 51386 THEN
    V_拼音 := 'Q';
  ELSIF V_汉字内码 BETWEEN 51387 AND 51445 THEN
    V_拼音 := 'R';
  ELSIF V_汉字内码 BETWEEN 51446 AND 52217 THEN
    V_拼音 := 'S';
  ELSIF V_汉字内码 BETWEEN 52218 AND 52697 THEN
    V_拼音 := 'T';
  ELSIF V_汉字内码 BETWEEN 52698 AND 52979 THEN
    V_拼音 := 'W';
  ELSIF V_汉字内码 BETWEEN 52980 AND 53640 THEN
    V_拼音 := 'X';
  ELSIF V_汉字内码 BETWEEN 53641 AND 54480 THEN
    V_拼音 := 'Y';
  ELSIF V_汉字内码 BETWEEN 54481 AND 55289 THEN
    V_拼音 := 'Z';
  ELSE
    V_拼音 := NULL;
  END IF;

  RETURN V_拼音;
END FGET_PY;
/

