CREATE OR REPLACE PROCEDURE HRBZLS."SP_MSS_SEND" (p_sende in  varchar2,--������
                            p_bilephonenumber in  varchar2, --���պ���
                            p_bilephonetext in  varchar2, --��������
                            p_sendtype in  number ,      --ģ�����
                            p_modeno in  varchar2   default '0'       --ģ����
                             ) is

 v_id  number ;
 v_c1  varchar2(11);
 v_c2  varchar2(140);
 v_bh  varchar2(6) ;
  cursor c_mn  is
         select c1,c2 from pbparmtemp;
 tr TSMSSENDCACHE%rowtype;
begin
   if p_modeno='0' then
       select TMDBH into v_bh from tsmssendmode where tmdlb=p_sendtype  and TMDTACITLY='Y';
   else
       v_bh :=  p_modeno;
   end if;
  if p_sendtype =101 THEN

        select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --��¼���
        tr.ssender           :=p_sende ;          --�����߱�ʶ
        tr.dbegintime        :=SYSDATE();         --����ʱ��
        tr.ntimingtag        :='0' ;              --��ʱ��־
        tr.dtimingtime       := null;             --��ʱ����ʱ��
        tr.ncontenttype      := p_sendtype;       --��������
        tr.exNumber          := null ;            --��չ����
        tr.ssendno           :=p_bilephonenumber ;--���պ���
        tr.ssmsmessage       :=p_bilephonetext ;  --������Ϣ
        tr.cflag             :='N' ;              --�����־
        tr.RETURNFLAG        :=null ;             --������
        tr.ismgstatus        :=null;              --���ܷ���ֵ
        tr.statustime        :=null;              --������Ӧ״̬

        insert into TSMSSENDCACHE values  tr ;

 elsif p_sendtype =102 THEN

open c_mn;
fetch c_mn into v_c1 ,v_c2 ;
  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --��¼���
        tr.ssender           :=p_sende ;          --�����߱�ʶ
        tr.dbegintime        :=SYSDATE();         --����ʱ��
        tr.ntimingtag        :='0' ;              --��ʱ��־
        tr.dtimingtime       := null;             --��ʱ����ʱ��
        tr.ncontenttype      := p_sendtype;       --��������
        tr.exNumber          := null ;            --��չ����
        tr.ssendno           :=v_c1 ;             --���պ���
        tr.ssmsmessage       :=v_c2 ;             --������Ϣ
        tr.cflag             :='N' ;              --�����־
        tr.RETURNFLAG        :=null ;             --������
        tr.ismgstatus        :=null;              --���ܷ���ֵ
        tr.statustime        :=null;              --������Ӧ״̬
        insert into TSMSSENDCACHE values  tr ;
       end loop;
elsif p_sendtype =103 THEN
open c_mn;
  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --��¼���
        tr.ssender           :=p_sende ;          --�����߱�ʶ
        tr.dbegintime        :=SYSDATE();         --����ʱ��
        tr.ntimingtag        :='0' ;              --��ʱ��־
        tr.dtimingtime       := null;             --��ʱ����ʱ��
        tr.ncontenttype      := p_sendtype;       --��������
        tr.exNumber          := null ;            --��չ����
        tr.ssendno           :=v_c1 ;             --���պ���
        tr.ssmsmessage       :=p_bilephonetext ;   --������Ϣ
        tr.cflag             :='N' ;              --�����־
        tr.RETURNFLAG        :=null ;             --������
        tr.ismgstatus        :=null;              --���ܷ���ֵ
        tr.statustime        :=null;              --������Ӧ״̬
        insert into TSMSSENDCACHE values  tr ;
       end loop;

 else

open c_mn;

  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;
        tr.id                :=v_id ;             --��¼���
        tr.ssender           :=p_sende ;          --�����߱�ʶ
        tr.dbegintime        :=SYSDATE();         --����ʱ��
        tr.ntimingtag        :='0' ;              --��ʱ��־
        tr.dtimingtime       := null;             --��ʱ����ʱ��
        tr.ncontenttype      := p_sendtype;       --��������
        tr.exNumber          := null ;            --��չ����
        tr.ssendno           :=v_c2 ;             --���պ���
        tr.ssmsmessage       :=fSetsmmtext(v_c1,p_sendtype,p_modeno) ;  --������Ϣ
        tr.cflag             :='N' ;              --�����־
        tr.RETURNFLAG        :=null ;             --������
        tr.ismgstatus        :=null;              --���ܷ���ֵ
        tr.statustime        :=null;              --������Ӧ״̬
        insert into TSMSSENDCACHE values  tr ;
       end loop;



  --elsif p_sendtype =102 THEN
  end if;
  commit;
  close c_mn;

exception
  when others then
    rollback;
end;
/

