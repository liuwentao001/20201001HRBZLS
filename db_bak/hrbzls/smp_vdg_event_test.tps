CREATE OR REPLACE TYPE HRBZLS."SMP_VDG_EVENT_TEST"                                          as OBJECT (
    id integer,
    name varchar2(256),
    agentName varchar2(256),
    args varchar2(2000),
    agentId integer,
    agentOpn integer
)
/

