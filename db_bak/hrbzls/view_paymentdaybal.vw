create or replace force view hrbzls.view_paymentdaybal as
select pdate pdbdate,
       pposition pdbsmfid,
       ptrans pdbtrans,
       sum(DECODE(pcd, 'DE', 1, 0)) pdbnumde,
       sum(DECODE(pcd, 'DE', ppayment, 0)) pdbjede,
       sum(DECODE(pcd, 'CR', 1, 0)) pdbnumcr,
       sum(DECODE(pcd, 'CR', ppayment, 0)) pdbjecr
  from payment
 group by pdate, pposition, ptrans;

