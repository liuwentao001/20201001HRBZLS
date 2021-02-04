CREATE OR REPLACE TYPE HRBZLS."SMP_VDD_OPERATION"                                          as OBJECT (
    id integer,
    type varchar2(128),
    subType varchar2(128),
    targetName varchar2(128),
    nodeName varchar2(128),
    userName varchar2(128),
    callbackName varchar2(128)
)
/

