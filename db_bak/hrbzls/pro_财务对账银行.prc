create or replace procedure hrbzls.pro_����������� is
       pro_date date;
       pro_num number:=0;
       pro_month varchar(7);
begin
     select to_date(sysdate - 1)  into pro_date from dual;
  select count(*) into  pro_num from ��������м�� ;
  select  to_char(add_months(sysdate,-1),'yyyy.mm') into pro_month from dual; 

     delete from ��������м�� where to_char(PCHKDATE,'yyyy.mm')>=pro_month;

    insert into ��������м��
    SELECT PCHKDATE,
      PPOSITION  ,
      MISMFID ,
      sum(QC) ,
      sum( FS),
      sum( QM) ,
      sum(PAY) , 
      sum(ZNJ) ,
      sum( SF) ,
      sum(FJF) ,
      sum(WS) ,
      sum(SXF),
      PREVERSEFLAG,
      count(PCHKNO),
      PCHKNO
      from (SELECT 'Y' FLAG,--���ʱ�־ 
            max(PCHKNO) PCHKNO,--���ʵ���
            max(PCHKDATE) PCHKDATE,--��������
             max(PDATE) PDATE,--�������ڣ��շ����ڣ� 
             max(PDATETIME) PDATETIME,--�������� 
             max(PPOSITION) PPOSITION,--�ɷѻ��� 
             PBATCH,--�ɷѽ������� 
           max(MISMFID) MISMFID,  
          max(PBSEQNO) PBSEQNO,    
             MAX(PPRIID) PPRIID,--��������� 
             MAX(MINAME) MINAME,--Ʊ������ 
             MAX(MIADR) MIADR,--���ַ 
             MAX(PPAYWAY) PPAYWAY,--���ʽ 
             FGETYCFS(PBATCH, 'QC') QC,--�ڳ�Ԥ��
             FGETPAYLIST(PBATCH, 'FS') FS,--���ڷ���
             FGETPAYLIST(PBATCH, 'QM') QM,--��ĩԤ��
             FGETPAYLIST(PBATCH, 'PAY') PAY,--������ 
             FGETPAYLIST(PBATCH, 'ZNJ') ZNJ,--ΥԼ��
             FGETPAYLIST(PBATCH, 'SF') SF,--ˮ��
             FGETPAYLIST(PBATCH, 'FJF') FJF,--���ӷ�
             FGETPAYLIST(PBATCH, 'WS') WS,--��ˮ��
             FGETPAYLISTCHAR(PBATCH, 'INV') INV,--��Ʊ��
             FGETPAYLIST(PBATCH, 'SXF') SXF, --������
             PREVERSEFLAG
        FROM PAYMENT, METERINFO
       WHERE PPRIID = MIID
      and PPOSITION like '03%'      
     and to_char(PCHKDATE,'yyyy.mm')>=pro_month
      group by PBATCH,PREVERSEFLAG) a
      group by PPOSITION,PCHKNO,MISMFID,PCHKDATE,PREVERSEFLAG;
 commit;
end pro_�����������;
/

