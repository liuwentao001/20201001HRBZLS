CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PRICEPROP AS
SELECT WATERTYPE ����,
         PFNAME    ����,
         P0        �۸�,
         P1        һ��ˮ�ѵ���,
         P2        ����ˮ�ѵ���,
         P3        ����ˮ�ѵ���,
         P4        ˮ�ѵ���,
         P5        ��ˮ�ѵ���,
         P6        ���ӷѵ���
    fROM PRICE_PROP, PRICEFRAME
   WHERE PFID = WATERTYPE;

