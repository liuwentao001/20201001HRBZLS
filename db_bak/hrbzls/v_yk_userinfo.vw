create or replace force view hrbzls.v_yk_userinfo as
select micid �û����,
       cicode �û���,
       ciname �û���,
       CICONID ��ˮ�ƺ�,
       substr(mibfid,1,5) ���մ���,
       ciname ����,
       mibfid||MIRORDER �ʿ���,
       mdno ˮ����,
       oaname ����Ա,
       /*nvl((select oaname
          from operaccnt,
               bookframe
         where operaccnt.oaid = bookframe.bfrper and
               bookframe.bfid = mi.mibfid)
       ,'') ����Ա,  --ת*/
       MINAME Ʊ������,
       pfname ��ˮ����,
       decode(MICHARGETYPE,'X','����','M','����') �ɷѷ�ʽ,
       bf.bfrcyc ��������,
       --(select bfrcyc from bookframe bf where bf.bfid = mi.mibfid ) ��������,
       mismfid Ӫ����˾,
       MIPID �ϼ�ˮ����,
       MICLASS ˮ����,
       MIFLAG ĩ����־,
       CINAME ��Ȩ��,
       CINAME2 ������,
       CIADR �û���ַ,
       decode(CISTATUS,'1','����','2','Ԥ����','7','����',cistatus) �û�״̬,
       CISTATUSDATE ״̬����,
       CISTATUSTRANS ״̬����,
       CINEWDATE ��������,
       MIINSDATE ����ʱ��,
       decode(CIIDENTITYLB,'0','��','1','���֤','2','Ӫҵִ��',CIIDENTITYLB) ֤������,
       CIIDENTITYNO  ֤������,
       CIMTEL �ƶ��绰,
       CITEL1 �̶��绰1,
       CITEL2 �̶��绰2,
       CITEL3 �̶��绰3,
       CICONNECTPER ��ϵ��,
       CICONNECTTEL ��ϵ�绰,
       CIIFINV �Ƿ���Ʊ,
       CIIFSMS �Ƿ��ṩ���ŷ���,
       CIIFZN  �Ƿ����ɽ�,
       CIPROJNO ���̱��_ˮ�˱�ʶ�� ,
       CIFILENO ������_��ˮ��ͬ�� ,
       CIMEMO ��ע��Ϣ,
       CIDEPTID ��������,
       MIRTID ����ʽ,
       MDCALIBER ��ھ�,
       MDBRAND ����
  from meterinfo mi ,
       custinfo ci ,
       meterdoc md ,
       priceframe pf,
       bookframe bf,
       operaccnt op
 where EXISTS (select 1 from (select mdno,count(mdno) From meterdoc group by mdno having count(mdno) =1) aa where aa.mdno=md.mdno) --Ӫ���б������ظ����û���Ϣ���������� by20190605
   and mi.miid = ci.ciid
   and mi.miid = md.mdmid
   --and (mi.MIRTID = '4' /*����Զ��*/ or mi.mirtid = '7' /*������*/ )
   and mi.MIPFID = pf.pfid(+)
   and mi.mibfid = bf.bfid (+)
   and op.oaid = bf.bfrper
;

