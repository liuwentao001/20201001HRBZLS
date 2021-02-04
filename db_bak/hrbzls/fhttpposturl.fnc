CREATE OR REPLACE Function HRBZLS.FHttpPostUrl(Url Varchar2, Param Clob)
  Return Varchar2 As
  Language Java Name 'HttpPost.sendPost(java.lang.String,oracle.sql.CLOB ) return java.lang.String';
/

