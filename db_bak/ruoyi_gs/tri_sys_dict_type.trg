﻿CREATE OR REPLACE TRIGGER tri_Sys_Dict_Type BEFORE INSERT ON Sys_Dict_Type FOR EACH ROW
BEGIN SELECT Sys_Dict_Type_Dict_ID_Seq.NEXTVAL INTO :NEW.Dict_ID FROM DUAL;
END tri_Sys_Dict_Type;
/

