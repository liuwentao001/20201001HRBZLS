CREATE OR REPLACE FUNCTION HRBZLS."FCHKROLETYPELIST"
   (vrid IN VARCHAR2,vcode IN VARCHAR2,vtype IN VARCHAR2,vsort IN VARCHAR2,vsmfid IN VARCHAR2)
   Return VARCHAR2
AS
   lpcode Integer;
   l_one  CHAR(1);
   l_two  CHAR(1);
   l_three  CHAR(1);
   l_four  CHAR(1);
BEGIN
   SELECT COUNT(*) INTO lpcode FROM operseachrange
    WHERE OSROAID = vrid AND OSRID = vcode AND osrbfsmfid = vsmfid;
     If lpcode = 1 Then
       Select substr(osrtypelist,1,1),substr(osrtypelist,2,1),substr(osrtypelist,3,1),substr(osrtypelist,4,1)
         Into l_one,l_two,l_three,l_four
         FROM operseachrange
       WHERE OSROAID = vrid AND OSRID = vcode and osrsort = vsort;
       If l_one = vtype Then
          Return 'Y';
       End If;
       If l_two = vtype Then
          Return 'Y';
       End If;
       If l_three = vtype Then
          Return 'Y';
       End If;
       If l_four = vtype Then
          Return 'Y';
       End If;
       Return 'N';
     Else
       Return 'N';
     End IF;
EXCEPTION WHEN OTHERS THEN
   lpcode := 0;
   Return lpcode;
END;
/

