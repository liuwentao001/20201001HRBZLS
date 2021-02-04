CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINTINV_OCX" (P_pbatch IN VARCHAR2,
 P_TYPE IN VARCHAR2) IS
 pbt PBPARMNNOCOMMIT_PRINT%rowtype;

      V_YCYE NUMBER;
BEGIN
if P_TYPE='Z' THEN
BEGIN
select
NVL(SUM(decode(pcd,'DE',1,-1)*(PPAYMENT-PCHANGE )),0) INTO V_YCYE
 from payment t where pbatch=P_pbatch /*'0103908960'*/
group by pmid,pmcode,pcid,pccode,pbatch
HAVING replace(replace(connstr(ptrans),'S','' ),'/','') IS NULL
 ;
 EXCEPTION WHEN OTHERS THEN
  V_YCYE   :=0 ;
 END ;

 --V_YCYE := 400;
 DELETE PBPARMNNOCOMMIT_PRINT;

if V_YCYE<0 then

INSERT INTO PBPARMNNOCOMMIT_PRINT
(C1, C2, C3, C4, C5, C6, C7, C8, C9, C10,C11 )

SELECT
C.pmid,
C.pmcode,
C.pcid,
C.pccode,
C.pbatch,
C.ptrans,
C.psavingqc,
C.psavingbq,
C.psavingqm,
C.JE,
(
case when
(case when SUM(C.JE) OVER ( order by C.JE desc ) + V_YCYE  < 0 then
 C.JE
 else
 C.JE - ( SUM(C.JE) OVER ( order by C.JE desc ) +  V_YCYE  )
 end) >=0 then
 (case when SUM(C.JE) OVER ( order by C.JE desc ) +  V_YCYE   < 0 then
 C.JE
 else
 C.JE - ( SUM(C.JE) OVER ( order by C.JE desc ) +  V_YCYE  )

 end)
 else
 0
 end) tzz
 FROM
(
SELECT
 B.pmid,
 B.pmcode,
 B.pcid,
 B.pccode,
 B.pbatch,
 B.ptrans,
 B.psavingqc,
 B.psavingbq,
 B.psavingqm,
 B.PPAYMENT - B.PD01JE JE  FROM
(
SELECT
             A.pmid,
             A.pmcode,
             A.pcid,
             A.pccode,
             A.pbatch,
             A.ptrans,
             A.psavingqc,
             A.psavingbq,
             A.psavingqm,
             A.PPAYMENT,
             SUM(CASE WHEN A3.PDPIID='01' AND A4.MIIFTAX='Y'
             THEN DECODE(A2.PLCD,'DE',1,-1)*A3.PDJE ELSE 0 END) PD01JE
             FROM (
             select pmid,
             pmcode,
             pcid,
             pccode,
             pbatch,
             connstr(ptrans) ptrans,
            TRIM( TO_CHAR(substr(min(pid || '@' || psavingqc), 12))) psavingqc,
            TRIM( TO_CHAR(sum(psavingbq))) psavingbq,
            TRIM( TO_CHAR(substr(max(pid || '@' || psavingqm), 12))) psavingqm,
           SUM(decode(pcd, 'DE', 1, -1) * (PPAYMENT - PCHANGE)) PPAYMENT

        from payment t
       where pbatch = P_pbatch /*'0103908960'*/
       group by pmid, pmcode, pcid, pccode, pbatch
       HAVING replace(replace(connstr(ptrans),'S','' ),'/','') IS  NOT NULL
       ) A,
       payment A1,
       paidlist A2,
       paiddetail  A3,
       METERINFO A4
       WHERE A.pmid=A1.PMID AND A.PBATCH=A1.PBATCH
       AND A1.PID=A2.PLPID AND A2.PLID=A3.PDID
       AND A.PMID=MIID
       GROUP BY A.pmid,
             A.pmcode,
             A.pcid,
             A.pccode,
             A.pbatch,
             A.ptrans,
             A.psavingqc,
             A.psavingbq,
             A.psavingqm,
             A.PPAYMENT
             ) B
             ) C
      ;
      update PBPARMNNOCOMMIT_PRINT
set c7=to_number(c7)+to_number(c11),
c8=to_number(c8)-to_number(c11),
c10=to_number(c10)-to_number(c11);

else

INSERT INTO PBPARMNNOCOMMIT_PRINT
(C1, C2, C3, C4, C5, C6, C7, C8, C9, C10,C11 )

SELECT
C.pmid,
C.pmcode,
C.pcid,
C.pccode,
C.pbatch,
C.ptrans,
C.psavingqc,
C.psavingbq,
C.psavingqm,
C.JE,
0 tzz
 FROM
(
SELECT
 B.pmid,
 B.pmcode,
 B.pcid,
 B.pccode,
 B.pbatch,
 B.ptrans,
 B.psavingqc,
 B.psavingbq,
 B.psavingqm,
 B.PPAYMENT - B.PD01JE JE  FROM
(
SELECT
             A.pmid,
             A.pmcode,
             A.pcid,
             A.pccode,
             A.pbatch,
             A.ptrans,
             A.psavingqc,
             A.psavingbq,
             A.psavingqm,
             A.PPAYMENT,
             SUM(CASE WHEN A3.PDPIID='01' AND A4.MIIFTAX='Y'
             THEN DECODE(A2.PLCD,'DE',1,-1)*A3.PDJE ELSE 0 END) PD01JE
             FROM (
             select pmid,
             pmcode,
             pcid,
             pccode,
             pbatch,
             connstr(ptrans) ptrans,
            TRIM( TO_CHAR(substr(min(pid || '@' || psavingqc), 12))) psavingqc,
            TRIM( TO_CHAR(sum(psavingbq))) psavingbq,
            TRIM( TO_CHAR(substr(max(pid || '@' || psavingqm), 12))) psavingqm,
           SUM(decode(pcd, 'DE', 1, -1) * (PPAYMENT - PCHANGE)) PPAYMENT

        from payment t
       where pbatch = P_pbatch /*'0103908960'*/
       group by pmid, pmcode, pcid, pccode, pbatch
       HAVING replace(replace(connstr(ptrans),'S','' ),'/','') IS  NOT NULL
       ) A,
       payment A1,
       paidlist A2,
       paiddetail  A3,
       METERINFO A4
       WHERE A.pmid=A1.PMID AND A.PBATCH=A1.PBATCH
       AND A1.PID=A2.PLPID AND A2.PLID=A3.PDID
       AND A.PMID=MIID
       GROUP BY A.pmid,
             A.pmcode,
             A.pcid,
             A.pccode,
             A.pbatch,
             A.ptrans,
             A.psavingqc,
             A.psavingbq,
             A.psavingqm,
             A.PPAYMENT
             ) B
             ) C
      ;
update PBPARMNNOCOMMIT_PRINT set c11= -V_YCYE where rownum=1 ;

update PBPARMNNOCOMMIT_PRINT
set c7=to_number(c7),
c8=to_number(c8) - to_number(c11),
c9=to_number(c9) - to_number(c11),
c10=to_number(c10)-to_number(c11);

end if;



END IF;

END;
/

