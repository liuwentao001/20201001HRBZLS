CREATE OR REPLACE TYPE BODY HRBZLS."CONNSTRIMPL" is
      static function ODCIAggregateInitialize(sctx IN OUT connstrImpl)
      return number is
      begin
        sctx := connstrImpl('','/');
        return ODCIConst.Success;
      end;
      member function ODCIAggregateIterate(self IN OUT connstrImpl, value IN VARCHAR2) return number is
      begin
        if self.currentstr is null then
          self.currentstr := value;
        else
          self.currentstr := self.currentstr ||currentseprator || value;
        end if;
        return ODCIConst.Success;
      end;
      member function ODCIAggregateTerminate(self IN connstrImpl, returnValue OUT VARCHAR2, flags IN number) return number is
      begin
        returnValue := self.currentstr;
        return ODCIConst.Success;
      end;
      member function ODCIAggregateMerge(self IN OUT connstrImpl, ctx2 IN connstrImpl) return number is
      begin
        if ctx2.currentstr is null then
          self.currentstr := self.currentstr;
        elsif self.currentstr is null then
          self.currentstr := ctx2.currentstr;
        else
          self.currentstr := self.currentstr || currentseprator || ctx2.currentstr;
        end if;
        return ODCIConst.Success;
      end;
      end;
/

