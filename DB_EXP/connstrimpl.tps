CREATE OR REPLACE TYPE CONNSTRIMPL as object
(
  currentstr varchar2(4000),
  currentseprator varchar2(8),
  static function ODCIAggregateInitialize(sctx IN OUT connstrImpl)
    return number,
  member function ODCIAggregateIterate(self IN OUT connstrImpl,
    value IN VARCHAR2) return number,
  member function ODCIAggregateTerminate(self IN connstrImpl,
    returnValue OUT VARCHAR2, flags IN number) return number,
  member function ODCIAggregateMerge(self IN OUT connstrImpl,
    ctx2 IN connstrImpl) return number)
/

