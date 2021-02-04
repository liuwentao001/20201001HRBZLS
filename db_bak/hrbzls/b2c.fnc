CREATE OR REPLACE FUNCTION HRBZLS."B2C" (B IN BLOB)
   RETURN CLOB
-- typecasts BLOB to CLOB (binary conversion)
IS
   res            CLOB;
   b_len          number  := dbms_lob.getlength(b) ;
   dest_offset1   NUMBER  := 1;
   src_offset1    NUMBER  := 1;
   amount_c       INTEGER := DBMS_LOB.lobmaxsize;
   blob_csid      NUMBER  := DBMS_LOB.default_csid;
   lang_ctx       INTEGER := DBMS_LOB.default_lang_ctx;
   warning        INTEGER;
BEGIN

   DBMS_LOB.createtemporary (res, TRUE);
   DBMS_LOB.OPEN (res, DBMS_LOB.lob_readwrite);

   DBMS_LOB.convertToClob(res,
                           b,
                           amount_c,
                           dest_offset1,
                           src_offset1,
                           blob_csid,
                           lang_ctx,
                           warning
                          );

   RETURN res;
END ;
/

