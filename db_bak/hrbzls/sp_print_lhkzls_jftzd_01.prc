CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHKZLS_JFTZD_01" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 select
  rlmcode  as �û����,           ----�û����
  rlcname as �û�����,         -----�û�����
  rlcadr as �û���ַ,          -----�û���ַ
  to_date(to_char(ADD_MONTHS(trunc(rldate),-1),'yyyy.mm'),'yyyy.mm')+24  as �����·�,
  to_date(to_char(ADD_MONTHS(trunc(rldate),-0),'yyyy.mm'),'yyyy.mm')+24  as �����·�,
  rlscode as �ϴ�ָ�� ,          -----�ϴ�ָ��
  rlecode as ����ָ��,          ------����ָ��
  rlreadsl as ʵ��ˮ�� ,         --------ʵ��ˮ��
  rlje as ���,             --------���
  md.mdcaliber as ��ھ� ,       --------��ھ�
  tools.fuppernumber(rlje) as  ��д���,
            f_jftzd_01('040105') as ����,
            f_jftzd_01('040101') as ����,
            f_jftzd_01('040103') as ũ��,
            f_jftzd_01('040102') as ����,
               '��ˮһ��˾' as   ������,
               '���û��ڱ���25��ǰ����ˮ��˾�շ��ҽ���ˮ�ѣ����򽫰��йع涨����ÿ��25���𣬰��ռ���5��ΥԼ��.' as ��ע,
               '8303102' as ��ϵ�绰,
               to_char(sysdate,'yyyy-mm-dd') as ����ʱ��,
               null as Ԥ���ֶ�1,
               null as Ԥ���ֶ�2,
               null as Ԥ���ֶ�3,
               null as Ԥ���ֶ�4,
               null as Ԥ���ֶ�5,
               null as Ԥ���ֶ�6,
               null as Ԥ���ֶ�7,
               null as Ԥ���ֶ�8,
               null as Ԥ���ֶ�9,
               null as Ԥ���ֶ�10
 from
 reclist rl,meterdoc md,meterinfo mi, pbparmtemp pp
 where
 rlpaidflag='N'
 and rlje >0
 and rlje-rlpaidje >0
 and rl.rlmid=md.mdmid
 and rl.rlmid = mi.miid
 and mi.milb='D'
 and rl.rlcd='DE'
 and rl.rlid=pp.c1
 order by mi.mismfid,mi.mibfid,mi.mirorder;
end ;
/

