CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PRICEPROP AS
SELECT WATERTYPE 编码,
         PFNAME    名称,
         P0        价格,
         P1        一阶水费单价,
         P2        二阶水费单价,
         P3        三阶水费单价,
         P4        水费单价,
         P5        污水费单价,
         P6        附加费单价
    fROM PRICE_PROP, PRICEFRAME
   WHERE PFID = WATERTYPE;

