CREATE OR REPLACE FUNCTION HRBZLS.isnumeric (str IN VARCHAR2)
     RETURN NUMBER
 IS
     v_str FLOAT;
 BEGIN
     IF str IS NULL
     THEN
        RETURN 0;
     ELSE
        BEGIN
           SELECT TO_NUMBER (str)
             INTO v_str
             FROM DUAL;
        EXCEPTION
           WHEN INVALID_NUMBER
           THEN
              RETURN 0;
        END;

        RETURN 1;
     END IF;
 END isnumeric;
/

