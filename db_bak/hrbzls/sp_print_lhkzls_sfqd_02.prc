CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHKZLS_SFQD_02" (o_base out tools.out_base) is
begin
  open o_base for
    select
      max(c1),     -------���û�(�û����)�����ձ�(���ձ��)
      max(c2),      --------�û�(��λ����)
      max(c3),      ------��Ʊʱ��
      max(c4),       -------- ���û�(�û����)�����ձ�(���ձ���µĶ��ˮ��ı��)
      max(c5),      --------����
      max(c6),      --------ֹ��
      max(c7),      --------ˮ��
      max(c8),      --------��ˮ���(������Ŀ)+����+ˮ��+���
      max(c9),       -------Сд�ϼ�
      max(c10),      -------��д�ϼ�
      max(c11),      --------Ԥ���ֶ�1
      max(c12),       --------Ԥ���ֶ�2
      max(c13)       --------Ԥ���ֶ�3
     from
     (
     select max(case
              when mipriflag = 'Y' then
               mipriid
              else
               cicode
            end) as c1,   -------���û�(�û����)�����ձ�(���ձ��)

            max(ciname ) as c2,   --------�û�(��λ����)

            to_char(sysdate, 'yyyy-mm-dd') AS c3,  ------��Ʊʱ��

            max(case
              when mipriflag = 'Y' then
                 f_sfqd_02('mipriid')
                 else
                   cicode
             end) as c4, -------- ���û�(�û����)�����ձ�(���ձ���µĶ��ˮ��ı��)

              substr(min(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlscode),
                  21) as c5,    --------����
           substr(max(to_char(rldate, 'yyyymmdd') || '@' || rlid || '@' ||
                      rlecode),
                  21) as c6,    --------ֹ��

           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  DECODE(RLCD, 'DE', 1, -1) * RDSL
                 ELSE
                  0
               END) as c7,      ------Ӧ��ˮ��

           F_lhkzls_ruzszzsdp_print(pp.c1,pp.c2,pp.c12) as c8,  --------��ˮ���(������Ŀ)+ˮ��+����+���

              null as c9,
              null as c10,
              null as c11,
              null as c12,
              null as c13

          from
           custinfo   ci,
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
       and michargetype='M'
     GROUP BY ci.cicode, rlmonth
 ) x
  group by  c1;
end;
/

