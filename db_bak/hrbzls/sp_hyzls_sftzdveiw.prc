CREATE OR REPLACE PROCEDURE HRBZLS."SP_HYZLS_SFTZDVEIW" (
                  o_base out tools.out_base) is
  begin
    open o_base for
        select
          rlid,
          fgetopername(MICPER)||'['||MICPER||']'    �߷�Ա ,                   -- rlmonth,
          rlmid,
          to_char(sysdate,'YY') ��, to_char(sysdate,'MM') ��, to_char(sysdate,'DD') ��,
          mibfid ̨����,RLCADR �û���ַ,
          rlmcode ����,rlcname ����,rlprdate ���ڳ���ʱ��,rlrdate ���ڳ���ʱ��,
          rlscode ���ڱ���,rlecode ���ڳ���,rlsl ����ˮ��,rlje ����ˮ��,
          tools.fformatnum ( (rlje - rlpaidje) ,2) ����Ƿ��,
          '����' ˮ��״̬,
          tools.fformatnum ((select tools.fformatnum (nvl(sum(pddj),0),2) from pricedetail  where pdpscid=0 and pdmethod='dj1' and pdpfid=RLPFID),2) �ۺ�ˮ��,
          ''  ��Ƿˮ��,
          tools.fformatnum (0,2) ΥԼ��,
          tools.fformatnum (misaving,2)   Ԥ�����,
          tools.fformatnum (rlje  ,2) Ӧ��ˮ��,
          fgetopername(RLRPER) ����Ա,
          --||'['||RLRPER||']'
          'Ӧ��' Ӧ��,
           '' Ƿ�Ѵ���,
          '' ��ϸ,
          c2
           from reclist t,meterinfo t1,PBPARMTEMP   where
           rlpaidflag in ('Y','N','V','K','T','W')
           and rlid =trim(c1)
           AND RLCD='DE'
           and miid=rlmid
           order by c3
          ;
end;
/

