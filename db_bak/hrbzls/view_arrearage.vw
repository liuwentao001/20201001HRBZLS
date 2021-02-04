CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_ARREARAGE AS
SELECT RLID ��ˮ��,
         RLDATE ��������,
         RLcid �ͻ�����,
         RLPRIMCODE  ���ձ������,
         RLSCODECHAR ����,
         RLECODECHAR ֹ��,
         MIN(RLSL) ˮ��,
         SUM(RDJE) Ƿ�ѽ��,
         0 ΥԼ��,
         sum(decode(RDPIID,'01',rdje,0)) ˮ��,
         sum(decode(RDPIID,'02',rdje,0)) ��ˮ��,
         sum(decode(RDPIID,'03',rdje,0)) ���ӷ�
    FROM RECLIST, RECDETAIL
   WHERE RLID = RDID
     --AND RLcid IN ('9121265479')
          and  rlcd='DE'
and (rlje-rlpaidje)>0
and rlpaidflag ='N'
and rlreverseflag ='N'
AND rlbadflag ='N'
     AND RLJE<>0
GROUP BY RLID,
         RLPRIMCODE,
         RLDATE,
         RLcid,
         RLSCODECHAR,
         RLECODECHAR,
         RLPFID,
         rlgroup,
         RLSMFID
ORDER BY ��������
;

