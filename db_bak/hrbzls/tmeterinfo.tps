CREATE OR REPLACE TYPE HRBZLS."TMETERINFO"                                          as object
(
   micid      varchar2(10),
   miid       varchar2(10),
   mipid      varchar2(20),
   milabelno  varchar2(20),
   mismfid    varchar2(10),
   miclass    number,
   miflag     char(1),
   ciid       varchar2(20),
   cmcbh      varchar2(20),
   cicode     varchar2(20),
   ciname     varchar2(128),
   ciadr      varchar2(100),
   micaliber  varchar2(20),
   cistatus   varchar2(10),
   RN         number,
   mibfid     varchar(10)
)
/

