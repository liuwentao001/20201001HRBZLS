CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PAY_DAILY AS
SELECT PDHID,
       MAX(PDPID) PDPID,
       PBATCH ,
       MAX(PPRIID) PPRIID,
       MAX(PDATE) PDATE,
       MAX(PREVERSEFLAG) PREVERSEFLAG,
       fgetycfs(PBATCH,'QC') QC,
       fgetpaylist(PBATCH,'FS') FS,
       fgetpaylist(PBATCH,'QM') QM,
       fgetpaylist(PBATCH,'PAY') PAY,
       fgetpaylist(PBATCH,'ZNJ') ZNJ,
       fgetpaylist(PBATCH,'SF') SF,
       fgetpaylist(PBATCH,'WS') WS,
       fgetpaylist(PBATCH,'INV') INV
from PAYMENT ,pay_daily_pid
WHERE PID=PDPID
GROUP BY PBATCH,
         PDHID;

