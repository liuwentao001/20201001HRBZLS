CREATE OR REPLACE TYPE HRBZLS."CONNSTRIMPL_LIKE"                                          as object
(
  currentstr varchar2(32767),
  currentseprator varchar2(8),
  static function ODCIAggregateInitialize(sctx IN OUT connstrImpl_like)
    return number,
  member function ODCIAggregateIterate(self IN OUT connstrImpl_like,
    value IN VARCHAR2) return number,
  member function ODCIAggregateTerminate(self IN connstrImpl_like,
    returnValue OUT VARCHAR2, flags IN number) return number,
  member function ODCIAggregateMerge(self IN OUT connstrImpl_like,
    ctx2 IN connstrImpl_like) return number
)
/

