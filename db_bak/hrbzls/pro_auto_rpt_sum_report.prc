create or replace procedure hrbzls.pro_auto_rpt_sum_report  is
--add hb 20150120
--�򱨱��ٶ���,���������м������
v_month varchar2(7) ;
--v_sysdate rpt_sum_report_mi.ins_date%type;
begin
  v_month:= to_char(sysdate, 'yyyy.mm') ;
  --v_sysdate:=sysdate;
  --ֻ����ÿ�µ�����
  --ÿ������ɾ�����µ�����Ȼ��������ץȡִ������
  /***************************************************
     01-�û�������Ϣ�м��
     begin
    -- �������ֶ�Ϊ��Ĭ��ΪXX��X,
  ****************************************************/
/* delete from rpt_sum_report_mi where ID ='01' and MONTH=v_month;
 INSERT INTO rpt_sum_report_mi (id, month, mismfid, mibfid, zkh, michargetype, michargetype_note, milb, milb_note, mistatus, mistatus_note, mipfid, mipfid_note, miyl2, miyl2_note, mdcaliber, mdbrand, mdbrand_note, mirtid, mirtid_note, mitype, mitype_note, hs, miusenum, misaving,INS_DATE) 
select '01' ��ĿID, ---ˮ�������Ϣ�м��
    v_month �����·�,
     mismfid Ӫҵ��,  
     nvl(mibfid,'XX') ���,  -- �������ֶ�Ϊ��Ĭ��ΪXX��X
     substrb(NVL(mibfid,'XX'), 1, 5) �ʿ���,-- �������ֶ�Ϊ��Ĭ��ΪXX��X
     MICHARGETYPE �շѷ�ʽ,  
     (select sctname from syschargetype where sctid = MICHARGETYPE) �շѷ�ʽ˵��,  
     MILB ˮ�����,
     (select t.sclvalue
        from syscharlist t
       where t.scltype = 'ˮ�����'
         and t.sclid = MILB) ˮ�����˵��,
    nvl( MISTATUS,'XX') ˮ��״̬,-- �������ֶ�Ϊ��Ĭ��ΪXX��X
     (select NVL(smsname,'ˮ��״̬��')
        from sysmeterstatus
       where smsmemo = 'Y'
         and smsid =  nvl( MISTATUS,'XX')) ˮ��״̬˵��,
     MIPFID ��ˮ����,
     FGETPRICEFRAME_TM(MIPFID) ��ˮ����˵��,
     nvl(MIYL2, '0') �����־,
     decode(nvl(MIYL2, '0'),
            '0',
            '��ͨ��',
            '1',
            '�ܱ�����',
            '2',
            '�༶��') �����־˵��,
NVL(mdcaliber,0) �ھ� ,  --�ھ�  -- �������ֶ�Ϊ��Ĭ��Ϊ0
nvl(MDBRAND,'XX') ��Ʒ�ƴ���,--Ʒ�� -- �������ֶ�Ϊ��Ĭ��ΪXX��X
(select nvl( mbname,'��Ʒ�ƿ�') from meterbrand where mbid =nvl(MDBRAND,'XX')) ��Ʒ��˵��,
NVL(mirtid,'X') ����ʽ����,--����ʽ -- �������ֶ�Ϊ��Ĭ��ΪX
( select t.srtname from sysreadtype t where t.srtid = NVL(mirtid,'X') ) ����ʽ˵��,--����ʽ˵��
NVL(mitype,'X')   ���ʹ���,--����  -- �������ֶ�Ϊ��Ĭ��ΪX
(select t.smtname from sysmetertype t WHERE smtifread='Y' and t.smtid= NVL(mitype,'X')) ����˵��,

     sum(case
           when (miid = MIPRIID and MIPRIFLAG = 'Y') or MIPRIFLAG = 'N' then
            '1'
           else
            '0'
         end) ����,
     SUM(MIUSENUM) ����,
     sum(MISAVING) Ԥ����� ,
     v_sysdate
from meterinfo,meterdoc
where meterinfo.miid =meterdoc.mdmid  
group by to_char(sysdate, 'yyyy.mm'), --�·�
        mismfid, --Ӫҵ�� 
        nvl(mibfid,'XX'), --���
      substrb(NVL(mibfid,'XX'), 1, 5) ,  --����
        MICHARGETYPE, --�շѷ�ʽ 
        MILB,  --ˮ�����
        nvl( MISTATUS,'XX'), --�û�״̬
        MIPFID,  --��ˮ����
      nvl(MIYL2, '0') ,  --�����־
        NVL(mdcaliber,0),  --�ھ�
     nvl(MDBRAND,'XX'),   --Ʒ��
         NVL(mirtid,'X'),   --����ʽ����
         NVL(mitype,'X') ;   --���ʹ���*/
        --   commit ;
  /***************************************************
     01-�û�������Ϣ�м��
      end 
  ****************************************************/
  
    /***************************************************
     02-������Ϣ�м�� 
     begin
  ****************************************************/
    
  null;
    /***************************************************
     02-������Ϣ�м�� 
     end
  ****************************************************/
  
      /***************************************************
     03-Ӧ����Ϣ�м�� 
     begin
  ****************************************************/
      null;
    /***************************************************
     03-Ӧ����Ϣ�м�� 
     end
  ****************************************************/
  
  /***************************************************
     04-ʵ����Ϣ�м�� 
     begin
  ****************************************************/
      null;
    /***************************************************
     04-ʵ����Ϣ�м�� 
     end
  ****************************************************/
end pro_auto_rpt_sum_report;
/

