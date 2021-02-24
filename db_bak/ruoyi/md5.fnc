CREATE OR REPLACE FUNCTION "MD5" (input_string VARCHAR2) return varchar2
IS
raw_input RAW(128) := UTL_RAW.CAST_TO_RAW(input_string);
decrypted_raw RAW(2048);
error_in_input_buffer_length EXCEPTION;
BEGIN
sys.dbms_obfuscation_toolkit.MD5(input => raw_input, checksum => decrypted_raw);
return lower(rawtohex(decrypted_raw));
END;
/

