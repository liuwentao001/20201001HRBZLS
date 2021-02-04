CREATE OR REPLACE FUNCTION HRBZLS."F_GETPTYPE" (str varchar2, ptype varchar2)
  return number IS
  v_temp   varchar2(200);
  v_return varchar2(200);
  idx      number := 1;
BEGIN
  idx:= LENGTH(str);
  WHILE (idx <= LENGTH(str)) LOOP
    v_temp := SUBSTR(str, idx, 1);
    IF v_temp <>ptype then
      idx := idx -1;
    else
      idx := idx -1;
      exit;
    END IF;
  END LOOP;
  return idx;
END f_Getptype;
/

