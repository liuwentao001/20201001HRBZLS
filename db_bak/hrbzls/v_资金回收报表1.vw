create or replace force view hrbzls.v_�ʽ���ձ���1 as
(
 select ofagent,
        �����·�,
        sum(���ս��) ���ս��,
        sum(���ս��+����) ���ս��,
        sum(����) ����,
        sum(����Ʊ��) ����Ʊ��,
        round(sum((����Ʊ��-����1-���ս��-������ˮ��)*sf_rate),2) ������ˮ����,
        sum(����Ʊ��) ����Ʊ��,
        round(sum(����Ʊ��*sf_rate),2) ����,
        round(sum((����Ʊ��-����1-���ս��-������ˮ��)*psf_rate),2) ��ˮ������ˮ,
        round(sum(����Ʊ��*psf_rate),2) ������ˮ,
        sum(������ˮ��) ������ˮ��,
        sum(������ˮ��+������ˮ��) ������ˮ��
 from
      (select t.ofagent,
             t.�����·�,
             t.watertype,
             sf_rate,
             psf_rate,
             sum(decode(t.chargetype,'X',t.ˮ��,0)) ���ս��,
             sum(case when t.chargetype='M'  then t.ˮ�� else 0 end) ���ս��,
              sum(DECODE(chargetype,'M'  ,��ˮ�� ,0)) ������ˮ��,
             sum(t.����ˮ��+t.����ˮ��) ����,
             sum(t.����ˮ��+t.����ˮ��+t.������ˮ��) ����1,
             sum(decode(t.�ɷѻ���,'02',t.Ʊ����,0)) ����Ʊ��,
             sum(decode(t.�ɷѻ���,'03',t.Ʊ����,0)) ����Ʊ��,
             sum(t.������ˮ��) ������ˮ��,
             sum(decode(t.chargetype,'X',t.��ˮ�� ,0)) ������ˮ��

      from rpt_sum_cwzjbb t ,V_ˮ�����۷ѷ�̯���� k
      where /*t.�����·�='2014.06'
            and*/ t.watertype=K.pfid
      group by t.ofagent,
             t.�����·�,
             t.watertype,
             sf_rate,
             psf_rate)
  group by ofagent,
        �����·�
 );

