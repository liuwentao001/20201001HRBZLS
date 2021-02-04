CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHK_SFQD" (o_base out tools.out_base) is
begin
  open o_base for
    select max(ci.cicode) as ���,
           max(ci.ciname) as ����,
           -------������д
           tools.fuppernumber(
                              ------����ˮ��
                              (SUM(CASE
                                      WHEN RDPIID = '01' THEN
                                       DECODE(RLCD, 'DE', 1, -1) * RDSL
                                      ELSE
                                       0
                                    END) * max(pf.pfprice)) +
                              ---------��ˮ�����
                               SUM(CASE
                                     WHEN RDPIID = '02' THEN
                                      DECODE(RLCD, 'DE', 1, -1) * RDJE
                                     ELSE
                                      0
                                   END) +
                              --------ˮ��Դ��
                               SUM(CASE
                                     WHEN RDPIID = '03' THEN
                                      DECODE(RLCD, 'DE', 1, -1) * RDJE
                                     ELSE
                                      0
                                   END)) as ���ϼ�,
           to_char(sysdate, 'yyyy-mm-dd') AS ��Ʊʱ��,
           max(ci.cicode) as ���2,
           --------�����ֹ�����޸ĵ�ʱ��ȡ���һ������׼
           substr(min(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlscode),
                  21) as ����,
           substr(max(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlecode),
                  21) as ֹ��,
           ------Ӧ��ˮ��
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) as Ӧ��ˮ��,

           max(pf.pfname) as ��ˮ���,
           max(pf.pfprice) as ����,
           --------ˮ��������
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) * max(pf.pfprice) as ���1,
           -------- ��ˮ�������
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) ���2,
           ------- ˮ��Դ����
           SUM(CASE
                 WHEN RDPIID = '03' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) ���3,
           ---------�ϼ�
           (SUM(CASE
                  WHEN RDPIID = '01' THEN
                   DECODE(RLCD, 'DE', 1, -1) * RDSL
                  ELSE
                   0
                END) * max(pf.pfprice)) +
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDJE
                 ELSE
                  0
               END) + SUM(CASE
                            WHEN RDPIID = '03' THEN
                             DECODE(RLCD, 'DE', 1, -1) * RDJE
                            ELSE
                             0
                          END) as Сд�ϼ�,
           ------ˮ��Դ�ѵ���
         /*  (select case RDPIID
                     when '03' then
                      rl.rlje
                   end
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rl.rlmid = c5)

           as ˮ��Դ�ѵ���,
           ---------��ˮ����ѵ���
           (select case RDPIID
                     when '02' then
                      rl.rlje
                   end
              from reclist rl, recdetail rd
             where rl.rlid = rd.rdid
               and rl.rlmid = c5) as ��ˮ����ѵ���,*/
       F_chargeinvsearch_recmx_ocx(max(pl.plid),max(mi.miid),4) as ˮ�����ѷ���,
           null as Ԥ���ֶ�1,
           null as Ԥ���ֶ�2,
           null as Ԥ���ֶ�3
      from custinfo   ci,
           reclist    rl,
           recdetail  rd,
           priceframe pf,
           PBPARMTEMP PP,
           meterinfo  mi,
           paidlist  pl
     where mi.miid = PP.C2
       AND MI.MICID = CI.CIID
       and rl.rlid = rd.rdid
       and rl.rlmid = mi.miid
       and mi.mipfid = pf.pfid
        and pl.plid=rl.rlid
       and mi.miiftax = 'Y'
       and rlmonth = pp.c7
     GROUP BY ci.cicode, rlmonth;
end;
/

