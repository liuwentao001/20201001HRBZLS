CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_JOB_HRB2 AS
  
  --�������� : f_getCustomerPwd
  --��;: �����û���ŷ����û���ˮ���������(��ת��Сд)
  --������ic_micid  in varchar2  �û����
  --����ֵ: ���ܵ��û�����(32λ,Сд),������κ��쳣,����null
  --��������: 2015/12/8 
  function f_getCustomerPwd(ic_micid   IN    varchar2) return varchar2 AS
  c_encryptPwd  METERINFO.MIYL4%type;
  BEGIN
     select miyl4 into c_encryptPwd from meterinfo where micid = ic_micid;
     return c_encryptPwd;
  exception
    when others then
      return null;
  END f_getCustomerPwd;
  
  --�������� : prc_chgCustomerPwd
  --��; : �޸Ŀͻ���ˮ������
  --������ic_micid    in  varchar2  �û����
  --      ic_plainpwd in  varchar2  �û���������
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����λ�����󷵻� -2 ,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��  
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_chgCustomerPwd( ic_micid      IN   varchar2,
                                ic_plainpwd   IN   varchar2,
                                on_appcode    OUT  number,
                                oc_error      OUT  varchar2
  )as
  begin
    on_appcode := 1;
    if length(ic_plainpwd) <> 6 then
       on_appcode := ERROR_CUSTOMERPWD_LENGTH;
       oc_error := '����λ������!';
       return;
    end if;
    update meterinfo
       set MIYL4 = md5(ic_plainpwd)
     where micid = ic_micid; 
  exception 
    when others then
      on_appcode := -1;
      oc_error := '�����û��������,' || sqlerrm;
  end;
  
  --�������� : f_getAccountPrecash
  --��;: ���ݱ�ŷ����˻���Ԥ�����(����Ǻ��ձ�,���غ����˻����)
  --������ic_micid  in varchar2  �û����
  --����ֵ: Ԥ�����
  --��������: 2016/3/11
  function f_getAccountPrecash(ic_micid   IN    varchar2) return number is
  n_cash   meterinfo.misaving%type;
  begin
    select sum(nvl(misaving,0))
      into n_cash
      from meterinfo mi
     where mipriid = (select mipriid from meterinfo where micid = ic_micid);
    return n_cash;
  exception
    when others then 
      return 0;  
  end;
  
  --�������� : prc_meterCancellation
  --��������: 2016/3/14
  --��;: ��������(����ˮ��) �򵥵��������� �����ǲ���
  --������ic_micid    in  varchar2  �û����
  --      ic_trans    in  varchar2  ������������
  --      ic_oper     in  varchar2  ����Ա
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����λ�����󷵻� -2 ,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��     
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_meterCancellation( ic_micid      IN   varchar2,
                                   ic_trans      IN   varchar2,
                                   ic_oper       IN   varchar2,
                                   on_appcode    OUT  number,
                                   oc_error      OUT  varchar2
  )is
  begin
    on_appcode := 1;
    --1.����meterinfo����״̬
    update METERINFO
       set MISTATUS      = '7',      --����״̬
           MISTATUSDATE  = sysdate,
           MISTATUSTRANS = ic_trans,
           MIUNINSDATE   = sysdate
     where micid = ic_micid;
     
    --2.������ͬ���û�״̬
    UPDATE CUSTINFO
       SET CISTATUS = '7',
           cistatusdate = sysdate,
           cistatustrans = ic_trans
     WHERE CICODE = ic_micid; 
     
    --3. ȥ���Ͷ�[20110702]
    UPDATE PRICEADJUSTLIST PL
       SET PL.PALSTATUS = 'N'
     WHERE PL.PALMID = ic_micid;
     
    --4.ͬ������ˮ���� 
    update METERDOC
       set MDSTATUS = '7', 
           MDSTATUSDATE = sysdate
     where MDMID = ic_micid; 
     
    --5.���� ˮ��
    UPDATE ST_METERINFO_STORE
       SET STATUS = '6',       --����������
           MIID = ic_micid, 
           STATUSDATE = SYSDATE
     WHERE BSM = (select mdno from meterdoc where MDMID = ic_micid );  
     
    --6.���� ���
    UPDATE st_meterfh_store
       set fhstatus = '4',     --���״̬ ����
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   dqsfh,
                   '1',       --�ܷ��
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );
    UPDATE st_meterfh_store
       set fhstatus = '4',     --���״̬ ����
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   dqgfh,
                   '2',       --�շ��
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );     
    UPDATE st_meterfh_store
       set fhstatus = '4',     --���״̬ ����
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   qfh,
                   '4',       --Ǧ���
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );
    UPDATE st_meterfh_store
       set fhstatus = '4',     --���״̬ ����
           mainman = ic_oper,
           maindate = sysdate
     where (storeId,meterfh,fhtype,caliber) in 
           (select mismfid,
                   jcgfh,
                   '3',       --������
                   MDCALIBER
              from meterinfo mi,
                   meterdoc md
             where mi.micid = ic_micid and 
                   mi.micid = md.mdmid                   
            );   
                           
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;        
  end;
  
  --�������� : f_checkUnfinishedBill
  --��;: ���ݱ�ŷ����û�δ���Ĺ�����
  --������ic_micid  in varchar2  �û����
  --����ֵ: ��'|'���صĹ�����
  --��������: 2016/3/17
  function f_checkUnfinishedBill(ic_micid   IN    varchar2) return varchar2 is
  c_priid  meterinfo.mipriid%type;
  c_result varchar2(1000);
  begin
     --��ѯ���ձ��
     select mipriid into c_priid from meterinfo where micid = ic_micid;
     
     select connstr(billno) into c_result from 
     (
       --���񹤵����
       select mthno billno
         from metertranshd hd1,
              metertransdt dt1
        where hd1.mthno = dt1.mtdno and 
              dt1.mtdmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd1.MTHSHFLAG = 'N'
        union all
       select CCHNO billno
         from CUSTCHANGEHD hd2,
              CUSTCHANGEDT dt2 
        where hd2.cchno = dt2.ccdno and
              dt2.miid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd2.CCHSHFLAG = 'N'
        union all
       select rthno billno
         from RECTRANSHD hd3
        where hd3.rthmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              RTHSHFLAG = 'N' 
        union all
       select rahno billno
         from RECADJUSTHD hd4,
              RECADJUSTDT dt4
        where hd4.rahno = dt4.radno and
              dt4.RADMID in (select miid from meterinfo mi where mipriid = c_priid ) and
              hd4.RAHSHFLAG = 'N'
        union all
       select crhno billno
         from TDSJHD hd5
        where hd5.miid in (select miid from meterinfo mi where mipriid = c_priid ) and
              hd5.CRHSHFLAG = 'N' 
        union all
       select PAHNO billno
         from PAIDADJUSTHD hd6
        where HD6.PAHMID in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd6.PAHSHFLAG = 'N'
        union all
       select rchno billno
         from recczhd hd7,
              recczdt dt7
        where hd7.rchno = dt7.rcdno and
              dt7.rcdmid in (select miid from meterinfo mi where mipriid = c_priid ) and 
              hd7.rchshflag = 'N'
     ); 
     return c_result;        
  exception
    when others then
      return '';
  end;
  
  --�������� : f_getCBTFtotal
  --��;: ����ָ��Ӫҵ��ָ�������·ݳ����˷ѽ��(��˺��)
  --������ic_smfid  in varchar2  Ӫҵ�����
  --      ic_month  in varchar2  �����·�(yyyy.mm)
  --����ֵ: �����˷ѽ��
  --��������: 2016/3/30
  function f_getCBTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number is
  n_saving number(13,3) default 0;
  begin
    select abs(sum(ycmisaving))
      into n_saving
      from meterinfo_yccz 
     where ycmfid = decode(ic_smfid,null,ycmfid,ic_smfid) and
           ycmonth = decode(ic_month,null,ycmonth,ic_month) and
           yctype = '2';
    return nvl(n_saving,0);
  exception
    when others then 
      return 0;  
  end;
  
  --�������� : f_getYCTFtotal
  --��;: ����ָ��Ӫҵ��ָ�������·�Ԥ���˷ѽ��(��˺��)
  --������ic_smfid  in varchar2  Ӫҵ�����
  --      ic_month  in varchar2  �����·�(yyyy.mm)
  --����ֵ: �����˷ѽ��
  --��������: 2016/3/30
  function f_getYCTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number is
  n_saving number(13,3) default 0;
  begin
    select abs(sum(ycmisaving))
      into n_saving
      from meterinfo_yccz 
     where ycmfid = decode(ic_smfid,null,ycmfid,ic_smfid) and
           ycmonth = decode(ic_month,null,ycmonth,ic_month) and
           yctype = '1';
    return nvl(n_saving,0);
  exception
    when others then 
      return 0;  
  end;
	
	--��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����
  --���� ic_rlid   In   varchar2  Ӧ����ˮ��
  --����ֵ:��Ӧָ��Ӧ����ˮ�ţ��Ѿ�������Ԥ����
  function f_getAllotMoney(ic_rlid   IN    varchar2) return number is
  n_allotMoney  number default 0;
  begin
    select sum(BAALLOTSUM)
      into n_allotMoney
      from Baseallot ba
     where ba.barlid = ic_rlid and
           ba.bastatus = 'Y';
    return nvl(n_allotMoney,0);
  exception
    when others then
      return 0;
  end;
  
  --��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·� yyyy.mm
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������Ԥ����(�����·� 2016.5(��)֮��,֮ǰֱ�ӷ���Ʊ����)
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month   IN    varchar2
  ) return number is
  n_allotMoney  number default 0;
  begin
    if ic_month >= '2016.05' then
      select sum(baAllotsum)
        into n_allotMoney
        from baseAllot ba
       where (ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
             ba.bamonth = ic_month and
             ba.bastatus = 'Y' ;
    else
/*      select sum(nvl(rlje,0)) 
        into n_allotMoney
        from reclist rl,
             payment p
       where rl.rlpid = p.pid and 
             rl.rltrans = 'u' \*����ˮ��*\ and   
             p.pmonth = ic_month and
             ( rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' );    */    
        select sum(nvl(RD.CHARGE1,0)) 
        into n_allotMoney
        from reclist rl,
             payment p,
             VIEW_RECLIST_CHARGE RD
       where rl.rlpid = p.pid and 
             rlid= rdid and
             rl.rltrans = 'u' /*����ˮ��*/ and   
             p.pmonth = ic_month and
             ( rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' );        
    end if;         
    return nvl(n_allotMoney,0);
  exception 
    when others then 
      return 0;
  end;
  
  --��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����(����) ����·� Ϊ�� ������Ҫ���� 'null' �ַ���
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������Ԥ���� (�����·� 2016.5(��)֮��,֮ǰֱ�ӷ���Ʊ����)
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month1  IN    varchar2,
                           ic_month2  IN    varchar2
  ) return number is
  n_allotMoney  number default 0;
  n_temp        number default 0;
  c_month       varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotsum)
            into n_temp
            from baseAllot ba
           where ( ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
                 ( ba.bamonth = c_month ) and                 
                 ba.bastatus = 'Y' ;
         exception
           when no_data_found then
             n_temp := 0;
         end;        
       else
         begin
/*          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rltrans = 'u' \*����ˮ��*\ and   
                 p.pmonth = c_month and
                 (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' ); */
            select sum(nvl(RD.CHARGE1,0)) 
            into n_temp
            from reclist rl,
                 payment p,
                 VIEW_RECLIST_CHARGE RD
           where rl.rlpid = p.pid and 
                 RLID = RDID and 
                 rl.rltrans = 'u' /*����ˮ��*/ and   
                 p.pmonth = c_month and
                 (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null' ); 
         exception
           when no_data_found then
             n_temp := 0;
         end;                 
       end if;
       n_allotMoney := n_allotMoney + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    return nvl(n_allotMoney,0);
  exception 
    when others then
      return 0;
  end;

  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��
  --���� ic_rlid   In   varchar2  Ӧ����ˮ��
  --����ֵ:��Ӧָ��Ӧ����ˮ�ţ��Ѿ�������ˮ�� 
  function f_getAllotSl(ic_rlid   IN    varchar2) return number is
  n_allotSl  number default 0;
  n_month    varchar2(10);
  begin
 -- select rlmonth into n_month From reclist where rlid =ic_rlid ;   
  select rlpaidmonth into n_month From reclist where rlid =ic_rlid ;  -- by20191008  �˴�Ӧ���������·ݽ����ж�
  
  if n_month >='2016.05' then
    select sum(BAALLOTSL)
      into n_allotSl
      from Baseallot ba
     where ba.barlid = ic_rlid and
           ba.bastatus = 'Y';
      return nvl(n_allotSl,0);
  else
     begin
        select sum(nvl(rlsl,0)) 
          into n_allotSl
          from reclist rl,
               payment p
         where rl.rlpid = p.pid and 
               rl.rltrans = 'u' /*����ˮ��*/ and   
               p.pmonth = n_month;  
               
         return nvl(n_allotsl,0); 
      exception
        when no_data_found then
          n_allotSl := 0;
      end;   
  end if;
      
  exception
    when others then
      return 0;
  end;
  
  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·�
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ������Ļ���ˮ�� (�����·� 2016.5(��)֮��,֮ǰֱ�ӷ���Ԥ��ˮ��)
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month   IN    varchar2
  ) return number is
  n_allotSl  number default 0;
  n_temp     number default 0;
  begin
    if ic_month >= '2016.05' then
      select sum(ba.baallotsl)
        into n_allotSl
        from baseAllot ba
       where (ba.basmfid = ic_smfid or lower(ic_smfid) = 'null') and 
             ba.bamonth = ic_month and
             ba.bastatus = 'Y' ;
    else
      begin
        select sum(nvl(rlsl,0)) 
          into n_temp
          from reclist rl,
               payment p
         where rl.rlpid = p.pid and 
               rl.rltrans = 'u' /*����ˮ��*/ and   
               p.pmonth = ic_month and
               (rl.rlsmfid = ic_smfid or lower(ic_smfid) = 'null');   
      exception
        when no_data_found then
          n_temp := 0;
      end;                
    end if;
    
    return nvl(n_allotSl,0);
  exception 
    when others then
      return 0;
  end;
  
  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������ˮ�� (�����·� 2016.5(��)֮��,֮ǰֱ�ӷ���Ԥ��ˮ��)
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month1  IN    varchar2,
                        ic_month2  IN    varchar2
  ) return number is
  n_allotSl  number default 0;
  c_month    varchar2(7);
  n_temp     number default 0;
  begin
    
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSl)
            into n_temp
            from baseAllot ba
           where ( decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid ) and  
                 ( ba.bamonth = c_month ) and                 
                 ba.bastatus = 'Y' ;
         exception
           when no_data_found then
             n_temp := 0;        
         end;        
       else
         begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*����ˮ��*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid; 
         exception
           when no_data_found then
             n_temp := 0;        
         end;                  
       end if;
       n_allotSl := n_allotSl + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
   
    return nvl(n_allotSl,0);
  exception 
    when others then
      return 0;
  end;
	
	--��������:f_getAllotSl_current
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(���յ���)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ��������µ�ˮ��
  function f_getAllotSl_current(ic_smfid   IN    varchar2,       
                                ic_month1  IN    varchar2,
                                ic_month2  IN    varchar2
  ) return number is
  n_allotSl number default 0;
  n_temp    number default 0;
  c_month   varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSl)
            into n_temp
            from baseAllot ba
           where (decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid)  and 
                 (ba.bamonth = c_month) and                  
                  ba.bastatus = 'Y' and 
                  exists(select 1 from payment pm where ba.bapid = pm.pid and pm.pmonth = bamonth);
         exception
           when no_data_found then
             n_temp := 0;         
         end;         
       else
         begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rlmonth = p.pmonth and 
                 rl.rltrans = 'u' /*����ˮ��*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid;    
         exception
           when no_data_found then
             n_temp := 0;
         end;                   
       end if;
       
       n_allotSl := n_allotSl + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');       
    end loop;              
    return nvl(n_allotSl,0);        
  exception
    when others then
      return 0;
  end;
  
  --��������:f_getAllotMoney_current
  --��;:��ȡ������ʱ��ˮ�ѵ������(���յ���)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ��������µĽ��
  function f_getAllotMoney_current(ic_smfid   IN    varchar2,       
                                   ic_month1  IN    varchar2,
                                   ic_month2  IN    varchar2 
  ) return number is
  n_allotMoney number default 0;
  n_temp       number default 0;
  c_month      varchar2(7);
  begin
    c_month := ic_month1;
    while c_month <= ic_month2 loop
       if c_month >= '2016.05' then
         begin
          select sum(baAllotSum)
            into n_temp
            from baseAllot ba
           where (decode(lower(ic_smfid),'null',basmfid,ic_smfid) = ba.basmfid)  and 
                 (ba.bamonth = c_month) and                  
                  ba.bastatus = 'Y' and 
                  exists(select 1 from payment pm where ba.bapid = pm.pid and pm.pmonth = bamonth);
         exception
           when no_data_found then
             n_temp := 0;         
         end;         
       else
         begin
          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where rl.rlpid = p.pid and 
                 rl.rlmonth = p.pmonth and 
                 rl.rltrans = 'u' /*����ˮ��*/ and   
                 p.pmonth = c_month and
                 decode(lower(ic_smfid),'null',rlsmfid,ic_smfid) = rl.rlsmfid;
         exception 
           when no_data_found then
             n_temp := 0;        
         end;                      
       end if;
       
       n_allotMoney := n_allotMoney + nvl(n_temp,0);
       c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');       
    end loop;
    return nvl(n_allotMoney,0); 
  exception
    when others then
      return 0;
  end;
	
	--��������:f_getAllotNumber
  --��;:��ȡ������ʱ��ˮ�ѵ�������
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·�-��ʼ
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ������ļ���
  function f_getAllotNumber(ic_smfid   IN    varchar2,       
                            ic_month   IN    varchar2 
  ) return number is
	n_count number default 0;
	begin
		 select count(distinct ba.bacid)
       into n_count
       from baseAllot ba
      where (ba.basmfid = ic_smfid or ic_smfid = 'null' or ic_smfid is null) and 
            ba.bamonth = ic_month and
            ba.bastatus = 'Y' ;
     return nvl(n_count,0);
	exception
		when others then 
			return 0;
  end;

  --�������� : prc_baseAllot
  --��������: 2016/5/17
  --��;: ����Ԥ��ˮ�ѵ�������
  --������ic_rlid     in  varchar2  Ӧ����ˮ��
  --      in_allotSl  in  number    ����ˮ��
  --      in_allotJe  in  number    �������
  --      ic_oper     in  varchar2  ����Ա
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_baseAllot        ( ic_rlid      IN   varchar2,
                                   in_allotSl   IN   varchar2,
                                   in_allotJe   IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  )is
  rec_reclist    reclist%rowType;     --Ӧ�ռ�¼
  rec_RECTRANSHD RECTRANSHD%rowType;  --������ˮ���˹�����¼
  n_price        number(10,2);        --ˮ�Ѽ۸�
  c_umonth       varchar2(7);         --�����·�
  n_pfid         varchar2(7);         --�۸����
  c_rlscrrlid    varchar2(20);         --ԭӦ����ˮ
  begin
    on_appcode := 1;
    
    --��������������
    if FSYSPARA('base') = 'N' then
       on_appcode := -2;
       oc_error := '����Ԥ������ѹر�!';
       return;
    end if;

    --��������Ӧ�ռ�¼
    begin
      select * into rec_reclist from reclist where rlid = ic_rlid;
    exception
      when no_data_found then
        on_appcode := -2;
        oc_error := '��š�' || ic_rlid || '��' || '�Ļ���Ӧ�ռ�¼û���ҵ�!';
        return;
    end;

    --����������ˮ���˹�����¼
    begin
      select RLSCRRLID into c_rlscrrlid from reclist where rlid = ic_rlid;
      -- by 20191008 �����г���������ļ�¼���ˣ���������Ҫ��ԭ��ˮ���м����ж�
      select * into rec_RECTRANSHD from RECTRANSHD where RTHRLID = c_rlscrrlid;
    exception
      when no_data_found then
        on_appcode := -3;
        oc_error := '��š�' || c_rlscrrlid || '��' || '�Ļ������˹�����¼û���ҵ�!';
        return;
    end;

    --����ˮ�Ѽ۸�
    begin
      select rd.rdysdj,rd.rdpfid into n_price,n_pfid from recdetail rd where rd.rdid = ic_rlid and rdpiid = '01';
    exception
      when no_data_found then
        on_appcode := -4;
        oc_error := '����ˮ�ѵ��۴���,δ�ҵ�����!';
        return;
    end;

    --�������ˮ��������Ƿ���Ч
    if f_getAllotSl(ic_rlid) + in_allotSl > rec_reclist.rlsl then
       on_appcode := -5;
       oc_error := '���ε���ˮ������ʣ��ɵ���ˮ��!';
       return;
    end if;
    if f_getAllotMoney(ic_rlid) + in_allotJe > rec_reclist.rlje then
       on_appcode := -5;
       oc_error := '���ε�������ʣ��ɵ������!';
       return;
    end if;
    
    --���µ��� �����ϸ�������
    c_umonth := to_char(add_months(to_date(to_char(sysdate,'yyyy.mm') || '.01','yyyy.mm.dd'),-1),'yyyy.mm');

    --�������Ԥ�������
    insert into baseallot
    (baid, bacid, basmfid, bamonth, bapfid, baprice, baallotsl, baAllotsum, bapid, barlid, barlsl,bapaidje, baoperid, baoperdate, bastatus, bacanceloper, bacanceldate, bamemo)
    values
    ( SEQ_BASEALLOT.Nextval,        --����Id
      rec_reclist.rlcid,            --�ͻ����
      rec_reclist.rlmsmfid,         --Ӫҵ��
      c_umonth,                     --�����·�
      --rec_RECTRANSHD.rthpfid,     --�۸����  
      n_pfid,                       --�۸����  by 20191008 �۸�����Ӧ��ϸ����ȡ
      n_price,                      --ˮ�Ѽ۸�
      in_allotSl,                   --����ˮ��
      in_allotJe,                   --�������
      rec_reclist.rlpid,            --������ˮ��
      ic_rlid,                      --Ӧ����ˮ��
      rec_reclist.rlsl,             --ԭӦ��ˮ��
      rec_reclist.rlje,             --Ԥ���ܽ��
      ic_oper,                      --��������Ա
      sysdate,                      --����ʱ��
      'Y',                          --״̬ 'Y'=����
      null,                         --����������Ա
      null,                         --��������ʱ��
      null                          --��ע
     );

  exception
    when others then
      on_appcode := -1;
      oc_error := '����Ԥ�����ʧ��!' || sqlerrm;
  end;

  --�������� : prc_unbaseAllot
  --��������: 2016/5/17
  --��;: ȡ��Ԥ��ˮ�ѵ���
  --������in_baid     in  number    ������ˮ��
  --      ic_oper     in  varchar2  ����Ա
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_unbaseAllot      ( in_baid      IN   varchar2,
                                   ic_oper      IN   varchar2,
                                   on_appcode   OUT  number,
                                   oc_error     OUT  varchar2
  )is
  cursor cur_baseAllot is
    select * from Baseallot ba where baid = in_baid and ba.bastatus = 'Y' for update;
  rec_baseAllot  baseallot%rowType;
  c_umonth varchar2(7);
  begin
    on_appcode := 1;
    
    --��������������
    if FSYSPARA('base') = 'N' then
       on_appcode := -2;
       oc_error := '����Ԥ������ѹر�!';
       return;
    end if;
    
    --�����·�
    c_umonth := to_char(add_months(to_date(to_char(sysdate,'yyyy.mm') || '.01','yyyy.mm.dd'),-1),'yyyy.mm');
    open cur_baseAllot;

    fetch cur_baseAllot into rec_baseAllot;
    if cur_baseAllot%found then
       if rec_baseAllot.Bamonth < c_umonth then
          on_appcode := -1;
          oc_error := 'ֻ��ȡ�����µĵ�����¼!';
          return;
       end if;
       update Baseallot ba set ba.bastatus = 'N',
                            ba.bacanceloper = ic_oper,
                            ba.bacanceldate = sysdate
       where current of cur_baseAllot;
    else
       close cur_baseAllot;
       on_appcode := -2;
       oc_error := '������¼û�ҵ����Ѿ���ȡ��!';
       return;
    end if;

    if cur_baseAllot%isopen then
       close cur_baseAllot;
    end if;

  exception
    when others then
      on_appcode := -1;
      oc_error := 'ȡ������Ԥ�����ʧ��!' || sqlerrm;
  end;
  
  --�������� : prc_rpt_allot_sum
  --��������: 2016/5/29
  --��;: ����Ԥ�����ͳ�ƻ���
  --������ic_month    in  varchar   �����·�
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_rpt_allot_sum( ic_month     in   varchar2,
                               on_appcode   out  number,
                               oc_error     out  varchar2
  ) is
  --����Ԥ���¼
  cursor cur_rpt is
     select *
       from RPT_BASEALLOT_SUM rpt
      where umonth = to_char(add_months(to_date(ic_month||'.01' ,'yyyy.mm.dd'),-1),'yyyy.mm') and
			      LAST_REMAIN_SL <> 0;--by 20190829 ����������ĸ���¼ҲҪ��������
  --��������Ԥ����
  cursor cur_add is
    select sum(rl.rlsl) rlsl,
           sum(rl.rlje) rlje,
           max(rl.rlmonth) rlmonth, --by20190829 ��ĩ���һ���������������Ҫ������������    �磺1303197192 �����·�Ϊ2018.11������
           rl.rlsmfid rlsmfid,
           rl.rlmid rlmid 
      from reclist rl 
     where rl.rltrans = 'u' and rl.rlpaidmonth = ic_month and rl.rlpaidflag = 'Y' /*and rl.rlreverseflag = 'N'*/ and rl.rlbadflag = 'N' 
     group by rlsmfid,rlmid
     order by rl.rlmid,rlmonth; 
  --���µ�����¼
  cursor cur_allot is
    select bacid,
           basmfid,
           sum(baallotSl) baallotSl,  --���µ���ˮ��
           sum(baallotSum) baallotsum --���µ������
      from baseAllot ba
     where bamonth = ic_month and
           bastatus = 'Y'
     group by bacid,basmfid;
  begin
    on_appcode := 1;
    
    --���ɱ��»��ܼ�¼(2016.5�ѳ�ʼ��,���¸�����������)
		/*if ic_month > '2016.05' then
			for rec_rpt in cur_rpt loop
				 insert into rpt_baseallot_sum
						(miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
				 values( rec_rpt.miid,
								 rec_rpt.smfid,
								 ic_month,
								 0,0,0,0,
								 rec_rpt.this_remain_sl,    --���½���ˮ��
								 rec_rpt.this_remain_money, --���½�����
								 0,
								 0
				 );       
			end loop;
    end if;*/
		
		if ic_month > '2016.05' then
			for rec_add in cur_add loop
				update rpt_baseallot_sum rpt
					 set rpt.smfid = rec_add.rlsmfid,
               rpt.add_sl = rec_add.rlsl,
               rpt.add_money = rec_add.rlje
							 
				 where rpt.miid = rec_add.rlmid and
							 rpt.umonth = ic_month;
				 if sql%rowcount = 0 then
						insert into rpt_baseallot_sum
						(miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
					 values
					 (  rec_add.rlmid,
							rec_add.rlsmfid,
							ic_month,   
							rec_add.rlsl,        --��������ˮ��
							rec_add.rlje,        --�����������
							0,                   --����ʹ��ˮ��
							0,                   --����ʹ�ý��
							0,                   --���½���ˮ��
							0,                   --���½�����
							rec_add.rlsl,        --���½���ˮ��
							rec_add.rlje         --���½�����
					 );
				 end if;
			end loop;
    end if;
    
    --���µ�����¼
    for rec_allot in cur_allot loop
       update rpt_baseAllot_sum rpt
          set rpt.smfid = rec_allot.basmfid,
              rpt.allot_sl = rec_allot.baallotSl,
              rpt.allot_money = rec_allot.baallotSum
        where rpt.miid = rec_allot.bacid and
              rpt.umonth = ic_month;
    end loop;
    
    --
    update rpt_baseAllot_sum rpt
       set rpt.this_remain_sl = nvl(rpt.last_remain_sl,0) + nvl(rpt.add_sl,0) - nvl(rpt.allot_sl,0),
           rpt.this_remain_money = nvl(rpt.last_remain_money,0) + nvl(rpt.add_money,0) - nvl(rpt.allot_money,0)
     where rpt.umonth = ic_month;
    
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;
  end;
  
  --��������: prc_rpt_allot_carryOver
  --��������: 2016.6
  --��;: ����Ԥ�����ͳ�Ʊ���ĩ��ת ÿ����Ȼ�µ����һ��������,��ת���¼�¼.
  --����: ic_month   in   varchar2  �����·�
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_rpt_allot_carryOver( ic_month   in   varchar2,
                                     on_appcode out  number,
                                     oc_error   out  varchar2
  )is
  cursor cur_rpt is
     select *
       from RPT_BASEALLOT_SUM rpt
      where umonth = ic_month and
            THIS_REMAIN_SL <> 0;--by 20190829 ����������ĸ���¼ҲҪ��������
        
  begin
    on_appcode := 1;
    for rec_rpt in cur_rpt loop
         
         update rpt_baseallot_sum 
            set last_remain_sl = rec_rpt.this_remain_sl,
                last_remain_money = rec_rpt.this_remain_money
          where miid = rec_rpt.miid and
                umonth = to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm');
         if sql%rowcount = 0 then           
             insert into rpt_baseallot_sum
                (miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
             values( rec_rpt.miid,
                     rec_rpt.smfid,
                     to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm'),
                     0,0,0,0,
                     rec_rpt.this_remain_sl,    --���½���ˮ��
                     rec_rpt.this_remain_money, --���½�����
                     0,
                     0
             );   
         end if;        
    end loop;
    
    update rpt_baseAllot_sum rpt
       set rpt.this_remain_sl = nvl(rpt.last_remain_sl,0) + nvl(rpt.add_sl,0) - nvl(rpt.allot_sl,0),
           rpt.this_remain_money = nvl(rpt.last_remain_money,0) + nvl(rpt.add_money,0) - nvl(rpt.allot_money,0)
     where rpt.umonth = to_char(add_months(to_date(ic_month || '.01','yyyy.mm.dd'),1),'yyyy.mm');
  exception
    when others then
      on_appcode := -1;
      oc_error := sqlerrm;
  end;
  
  --����Ԥ�����ͳ�Ʊ� ��ʼ�� ִֻ��һ��!!!
  PROCEDURE PRC_RPT_ALLOT_INIT is
  c_startMonth  varchar2(7) default '2016.05';
  cursor cur_reclist is
    select sum(rl.rlsl) rlsl,
           sum(rl.rlje) rlje,
           rl.rlmonth rlmonth,
           rl.rlsmfid rlsmfid,
           rl.rlmid rlmid 
      from reclist rl 
     where rl.rltrans = 'u' and rl.rlpaidflag = 'Y' and rl.rlreverseflag = 'N' and rl.rlbadflag = 'N' and rl.rlpaidmonth = c_startMonth
     group by rlsmfid,rlmid,rlmonth
     order by rl.rlmid,rl.rlmonth;
 
  begin
    --���ͳ�Ʊ�
    execute immediate 'truncate table RPT_BASEALLOT_SUM';
    for rec_reclist in cur_reclist loop
      
       insert into rpt_baseallot_sum
          (miid, smfid, umonth, add_sl, add_money, allot_sl, allot_money, last_remain_sl, last_remain_money, this_remain_sl, this_remain_money)
       values
       (  rec_reclist.rlmid,
          rec_reclist.rlsmfid,
          c_startMonth,
          rec_reclist.rlsl,    --��������ˮ��
          rec_reclist.rlje,    --�����������
          0,                   --����ʹ��ˮ��
          0,                   --����ʹ�ý��
          0,                   --���½���ˮ��
          0,                   --���½�����
          rec_reclist.rlsl ,   --���½���ˮ��
          rec_reclist.rlje     --���½�����
       );        
    end loop;
  end;
  
  --ˮ��ˮ��������ͬ�ڶԱ�
  procedure prc_compareReport( ic_smfid       IN   varchar2,  --Ӫҵ��Id
                               ic_umonth_beg  IN   varchar2,  --�Ƚ���ʼ�����·�
                               ic_umonth_end  IN   varchar2,  --�Ƚ���ֹ�����·�                            
                               oc_data        out  myref      --��������
  )is
  ic_umonth_beg2     varchar2(10);
  ic_umonth_end2     varchar2(10);
  v_����_����_ˮ��1        number(14,2);
  v_����_����_ˮ��1        number(14,2);
  v_����_����ˮ��_ˮ��1    number(14,2);
  v_����_����ˮ��_ˮ��1    number(14,2);
  v_�Ǿ���_Դˮ_ˮ��1      number(14,2);
  v_�Ǿ���_Դˮ_ˮ��1      number(14,2); 
  v_��ҵ1_ˮ��1            number(14,2);
  v_��ҵ1_ˮ��1            number(14,2);
  v_��ҵ2_ˮ��1            number(14,2);
  v_��ҵ2_ˮ��1            number(14,2);
  v_����_ˮ��1             number(14,2);
  v_����_ˮ��1             number(14,2); 
  
  v_����_����_��ˮ��1      number(14,2);
  v_����_����_��ˮ��1      number(14,2);
  v_����_����ˮ��_��ˮ��1  number(14,2);
  v_����_����ˮ��_��ˮ��1  number(14,2);
  v_�Ǿ���_Դˮ_��ˮ��1    number(14,2);
  v_�Ǿ���_Դˮ_��ˮ��1    number(14,2); 
  v_��ҵ1_��ˮ��1          number(14,2);
  v_��ҵ1_��ˮ��1          number(14,2);
  v_��ҵ2_��ˮ��1          number(14,2);
  v_��ҵ2_��ˮ��1          number(14,2);
  v_����_��ˮ��1           number(14,2);
  v_����_��ˮ��1           number(14,2); 
  
  v_����_ˮ��1             number(14,2);
  v_����_ˮ��1             number(14,2);
  v_����_ˮ��1             number(14,2);
  v_����_ˮ��1             number(14,2);
  
  v_����_��ˮ��1           number(14,2);
  v_����_��ˮ��1           number(14,2);
  v_����_��ˮ��1           number(14,2);
  v_����_��ˮ��1           number(14,2);
  
  
  
  v_����_����_ˮ��2        number(14,2);
  v_����_����_ˮ��2        number(14,2);
  v_����_����ˮ��_ˮ��2    number(14,2);
  v_����_����ˮ��_ˮ��2    number(14,2);
  v_�Ǿ���_Դˮ_ˮ��2      number(14,2);
  v_�Ǿ���_Դˮ_ˮ��2      number(14,2); 
  v_��ҵ1_ˮ��2            number(14,2);
  v_��ҵ1_ˮ��2            number(14,2);
  v_��ҵ2_ˮ��2            number(14,2);
  v_��ҵ2_ˮ��2            number(14,2);
  v_����_ˮ��2             number(14,2);
  v_����_ˮ��2             number(14,2); 
  
  v_����_����_��ˮ��2      number(14,2);
  v_����_����_��ˮ��2      number(14,2);
  v_����_����ˮ��_��ˮ��2  number(14,2);
  v_����_����ˮ��_��ˮ��2  number(14,2);
  v_�Ǿ���_Դˮ_��ˮ��2    number(14,2);
  v_�Ǿ���_Դˮ_��ˮ��2    number(14,2); 
  v_��ҵ1_��ˮ��2          number(14,2);
  v_��ҵ1_��ˮ��2          number(14,2);
  v_��ҵ2_��ˮ��2          number(14,2);
  v_��ҵ2_��ˮ��2          number(14,2);
  v_����_��ˮ��2           number(14,2);
  v_����_��ˮ��2           number(14,2); 
  
  v_����_ˮ��2             number(14,2);
  v_����_ˮ��2             number(14,2);
  v_����_ˮ��2             number(14,2);
  v_����_ˮ��2             number(14,2);
  
  v_����_��ˮ��2           number(14,2);
  v_����_��ˮ��2           number(14,2);
  v_����_��ˮ��2           number(14,2);
  v_����_��ˮ��2           number(14,2);
  begin
                      
    ic_umonth_beg2 := to_char(add_months(to_date(ic_umonth_beg,'yyyy.mm'),-12),'yyyy.mm');    
    ic_umonth_end2 := to_char(add_months(to_date(ic_umonth_end,'yyyy.mm'),-12),'yyyy.mm');    
  
    --����
    select nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X32
                else
                  0
                end
           ),0), --����������ˮ��
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X37
                else
                  0
                end
           ),0), --��������: ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X32
                else
                  0
                end
           ),0), --�������ˮ�ۣ�ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X37
                else
                  0
                end
           ),0), --�������ˮ��: ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X32
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ��ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X37
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ��ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X32
                else
                  0
                end  
           ),0), --��ҵ1��ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X37
                else
                  0
                end  
           ),0), --��ҵ1��ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X32
                else
                  0
                end  
           ),0), --��ҵ2��ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X37
                else
                  0
                end  
           ),0), --��ҵ2��ˮ��
           nvl(sum(x32),0),   --����ˮ�����
           nvl(sum(x37),0),   --����ˮ�ѽ��
           
           
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  W1
                else
                  0
                end
           ),0), --������������ˮ��
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X38
                else
                  0
                end
           ),0), --��������: ��ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  W1
                else
                  0
                end
           ),0), --�������ˮ�ۣ���ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X38
                else
                  0
                end
           ),0), --�������ˮ��: ��ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  W1
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ����ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X38
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ����ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  W1
                else
                  0
                end  
           ),0), --��ҵ1����ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X38
                else
                  0
                end  
           ),0), --��ҵ1����ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  W1
                else
                  0
                end  
           ),0), --��ҵ2����ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X38
                else
                  0
                end  
           ),0), --��ҵ2����ˮ��
           nvl(sum(w1),0),   --������ˮ�����
           nvl(sum(x38),0)   --������ˮ�ѽ��
      into v_����_����_ˮ��1,
           v_����_����_ˮ��1,
           v_����_����ˮ��_ˮ��1,
           v_����_����ˮ��_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1,
           v_��ҵ1_ˮ��1,
           v_��ҵ1_ˮ��1,
           v_��ҵ2_ˮ��1,
           v_��ҵ2_ˮ��1,
           v_����_ˮ��1,
           v_����_ˮ��1,
           
           v_����_����_��ˮ��1,
           v_����_����_��ˮ��1,
           v_����_����ˮ��_��ˮ��1,
           v_����_����ˮ��_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1,
           v_��ҵ1_��ˮ��1,
           v_��ҵ1_��ˮ��1,
           v_��ҵ2_��ˮ��1,
           v_��ҵ2_��ˮ��1,
           v_����_��ˮ��1,
           v_����_��ˮ��1 
      from rpt_sum_read rpt
     where u_month >= ic_umonth_beg and 
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;
           
    --����ˮ��1
/*    select nvl(sum(x79),0) into v_����_ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
     SELECT nvl(sum(X32),0) into v_����_ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
    --����ˮ��1       
/*    select nvl(sum(x80),0) into v_����_ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;  */      
     SELECT nvl(sum(X37),0) into v_����_ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23'); 
            
    --����ˮ��1
    v_����_ˮ��1 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
      
    --����ˮ��1       
    v_����_ˮ��1 := f_getAllotMoney(ic_smfid,ic_umonth_beg,ic_umonth_end);
           
    --������ˮ��1
/*    select nvl(sum(x81),0)-nvl(sum(w2),0) into v_����_��ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
     SELECT nvl(sum(w4),0) into v_����_��ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23'); 
    --������ˮ��1       
/*    select nvl(sum(x82),0) into v_����_��ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */  
    SELECT nvl(sum(x38),0) into v_����_��ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
           
    --������ˮ��1
/*    select nvl(sum(x74),0) into v_����_��ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
           
     SELECT nvl(sum(W3),0) into v_����_��ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
           
           
    --������ˮ��1       
/*    select nvl(sum(x75),0) into v_����_��ˮ��1 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;  */

     SELECT nvl(sum(X22),0) into v_����_��ˮ��1 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');         
    
    
    --------------  �Ա�������� -------------------------------------------------------------------------
    
    --����
    select nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X32
                else
                  0
                end
           ),0), --����������ˮ��
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X37
                else
                  0
                end
           ),0), --��������: ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X32
                else
                  0
                end
           ),0), --�������ˮ�ۣ�ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X37
                else
                  0
                end
           ),0), --�������ˮ��: ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X32
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ��ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X37
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ��ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X32
                else
                  0
                end  
           ),0), --��ҵ1��ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X37
                else
                  0
                end  
           ),0), --��ҵ1��ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X32
                else
                  0
                end  
           ),0), --��ҵ2��ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X37
                else
                  0
                end  
           ),0), --��ҵ2��ˮ��
           nvl(sum(x32),0),   --����ˮ�����
           nvl(sum(x37),0),   --����ˮ�ѽ��
           
           
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  W1
                else
                  0
                end
           ),0), --������������ˮ��
           nvl(sum(
                case when watertype in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') then
                  X38
                else
                  0
                end
           ),0), --��������: ��ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  W1
                else
                  0
                end
           ),0), --�������ˮ�ۣ���ˮ��
           nvl(sum(
                case when watertype in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') then
                  X38
                else
                  0
                end
           ),0), --�������ˮ��: ��ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  W1
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ����ˮ��
           nvl(sum(
                case when watertype in ('B0208','B0209','B0212') then
                  X38
                else
                  0
                end
           ),0), --�Ǿ���-Դˮ����ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  W1
                else
                  0
                end  
           ),0), --��ҵ1����ˮ��
           nvl(sum(
                case when watertype in ('E0101','E0403','E050202','E06') then
                  X38
                else
                  0
                end  
           ),0), --��ҵ1����ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  W1
                else
                  0
                end  
           ),0), --��ҵ2����ˮ��
           nvl(sum(
                case when watertype in ('E0201','F01','F02','F03') then
                  X38
                else
                  0
                end  
           ),0), --��ҵ2����ˮ��
           nvl(sum(w1),0),   --������ˮ�����
           nvl(sum(x38),0)   --������ˮ�ѽ��
      into v_����_����_ˮ��2,
           v_����_����_ˮ��2,
           v_����_����ˮ��_ˮ��2,
           v_����_����ˮ��_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2,
           v_��ҵ1_ˮ��2,
           v_��ҵ1_ˮ��2,
           v_��ҵ2_ˮ��2,
           v_��ҵ2_ˮ��2,
           v_����_ˮ��2,
           v_����_ˮ��2,
           
           v_����_����_��ˮ��2,
           v_����_����_��ˮ��2,
           v_����_����ˮ��_��ˮ��2,
           v_����_����ˮ��_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2,
           v_��ҵ1_��ˮ��2,
           v_��ҵ1_��ˮ��2,
           v_��ҵ2_��ˮ��2,
           v_��ҵ2_��ˮ��2,
           v_����_��ˮ��2,
           v_����_��ˮ��2 
      from rpt_sum_read rpt
     where u_month >= ic_umonth_beg2 and 
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;
           
    --����ˮ��2
/*    select nvl(sum(x79),0) into v_����_ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
    SELECT nvl(sum(X32),0) into v_����_ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
    --����ˮ��2       
/*    select nvl(sum(x80),0) into v_����_ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */ 
    SELECT nvl(sum(X37),0) into v_����_ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');   
            
    --����ˮ��2
    v_����_ˮ��2 := f_getAllotSl(ic_smfid,ic_umonth_beg2,ic_umonth_end2);
      
    --����ˮ��2       
    v_����_ˮ��2 := f_getAllotMoney(ic_smfid,ic_umonth_beg2,ic_umonth_end2);
           
    --������ˮ��2
/*    select nvl(sum(x81),0) into v_����_��ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
    SELECT nvl(sum(w4),0) into v_����_��ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
    --������ˮ��2       
/*    select nvl(sum(x82),0) into v_����_��ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;   */  
    SELECT nvl(sum(x38),0) into v_����_��ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');  
           
    --������ˮ��2
/*    select nvl(sum(x74),0) into v_����_��ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent; */
           
     SELECT nvl(sum(W3),0) into v_����_��ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');
           
    --������ˮ��2       
/*    select nvl(sum(x75),0) into v_����_��ˮ��2 
      from RPT_SUM_CHARGE rpt 
     where U_MONTH >= ic_umonth_beg2 and  
           u_month <= ic_umonth_end2 and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent;   */   
                                   
           
      SELECT nvl(sum(X22),0) into v_����_��ˮ��2 
      FROM RPT_SUM_DETAIL
     where U_MONTH >= ic_umonth_beg and  
           u_month <= ic_umonth_end and
           decode(lower(ic_smfid),'null',ofagent,ic_smfid) = ofagent
           AND T19='����'
           AND NVL(T16,'NULL')  NOT IN ( LOWER('V'), '21','23');            
              
           
           
    open oc_data for 
    select ic_smfid Ӫҵ��,
           ic_umonth_beg �����·�_��ʼ,
           ic_umonth_end �����·�_��ֹ,
           v_����_����_ˮ��1 ����_����_ˮ��1,
           v_����_����_ˮ��1 ����_����_ˮ��1,
           v_����_����_��ˮ��1 ����_����_��ˮ��1,
           v_����_����_��ˮ��1 ����_����_��ˮ��1,    
           v_����_����_ˮ��2 ����_����_ˮ��2,
           v_����_����_ˮ��2 ����_����_ˮ��2,
           v_����_����_��ˮ��2 ����_����_��ˮ��2,
           v_����_����_��ˮ��2 ����_����_��ˮ��2,
           v_����_����ˮ��_ˮ��1 ����_����ˮ��_ˮ��1,
           v_����_����ˮ��_ˮ��1 ����_����ˮ��_ˮ��1,
           v_����_����ˮ��_��ˮ��1 ����_����ˮ��_��ˮ��1,
           v_����_����ˮ��_��ˮ��1 ����_����ˮ��_��ˮ��1,    
           v_����_����ˮ��_ˮ��2 ����_����ˮ��_ˮ��2,
           v_����_����ˮ��_ˮ��2 ����_����ˮ��_ˮ��2,
           v_����_����ˮ��_��ˮ��2 ����_����ˮ��_��ˮ��2,
           v_����_����ˮ��_��ˮ��2 ����_����ˮ��_��ˮ��2,
           v_����_����_ˮ��1 + v_����_����ˮ��_ˮ��1     ����_С��_ˮ��1,
           v_����_����_ˮ��1 + v_����_����ˮ��_ˮ��1     ����_С��_ˮ��1,
           v_����_����_��ˮ��1 + v_����_����ˮ��_��ˮ��1 ����_С��_��ˮ��1,
           v_����_����_��ˮ��1 + v_����_����ˮ��_��ˮ��1 ����_С��_��ˮ��1,    
           v_����_����_ˮ��2 + v_����_����ˮ��_ˮ��2     ����_С��_ˮ��2,
           v_����_����_ˮ��2 + v_����_����ˮ��_ˮ��2     ����_С��_ˮ��2,
           v_����_����_��ˮ��2 + v_����_����ˮ��_��ˮ��2 ����_С��_��ˮ��2,
           v_����_����_��ˮ��2 + v_����_����ˮ��_��ˮ��2 ����_С��_��ˮ��2,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 �Ǿ���_�Ǿ���_ˮ��1,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 �Ǿ���_�Ǿ���_ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 �Ǿ���_�Ǿ���_��ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 �Ǿ���_�Ǿ���_��ˮ��1,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 �Ǿ���_�Ǿ���_ˮ��2,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 �Ǿ���_�Ǿ���_ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 �Ǿ���_�Ǿ���_��ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 �Ǿ���_�Ǿ���_��ˮ��2,          
           v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_Դˮ_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_Դˮ_��ˮ��1,    
           v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_Դˮ_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_Դˮ_��ˮ��2,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 + v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_С��_ˮ��1,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 + v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_С��_ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 + v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_С��_��ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 + v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_С��_��ˮ��1,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 + v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_С��_ˮ��2,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 + v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_С��_ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 + v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_С��_��ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 + v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_С��_��ˮ��2,           
           v_��ҵ1_ˮ��1 ��ҵ1_ˮ��1,
           v_��ҵ1_ˮ��1 ��ҵ1_ˮ��1,
           v_��ҵ1_��ˮ��1 ��ҵ1_��ˮ��1,
           v_��ҵ1_��ˮ��1 ��ҵ1_��ˮ��1,    
           v_��ҵ1_ˮ��2 ��ҵ1_ˮ��2,
           v_��ҵ1_ˮ��2 ��ҵ1_ˮ��2,
           v_��ҵ1_��ˮ��2 ��ҵ1_��ˮ��2,
           v_��ҵ1_��ˮ��2 ��ҵ1_��ˮ��2,  
           v_��ҵ2_ˮ��1 ��ҵ2_ˮ��1,
           v_��ҵ2_ˮ��1 ��ҵ2_ˮ��1,
           v_��ҵ2_��ˮ��1 ��ҵ2_��ˮ��1,
           v_��ҵ2_��ˮ��1 ��ҵ2_��ˮ��1,    
           v_��ҵ2_ˮ��2 ��ҵ2_ˮ��2,
           v_��ҵ2_ˮ��2 ��ҵ2_ˮ��2,
           v_��ҵ2_��ˮ��2 ��ҵ2_��ˮ��2,
           v_��ҵ2_��ˮ��2 ��ҵ2_��ˮ��2,   
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,  
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2, 
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_ˮ��1 + v_����_ˮ��1 ����_С��_ˮ��1,
           v_����_ˮ��1 + v_����_ˮ��1 ����_С��_ˮ��1,
           v_����_��ˮ��1 + v_����_��ˮ��1 ����_С��_��ˮ��1,
           v_����_��ˮ��1 + v_����_��ˮ��1 ����_С��_��ˮ��1,    
           v_����_ˮ��2 + v_����_ˮ��2 ����_С��_ˮ��2,
           v_����_ˮ��2 + v_����_ˮ��2 ����_С��_ˮ��2,
           v_����_��ˮ��2 + v_����_��ˮ��2 ����_С��_��ˮ��2,
           v_����_��ˮ��2 + v_����_��ˮ��2 ����_С��_��ˮ��2 
      from dual;      
  end;
  
  --ˮ��ˮ��������ͬ�ڶԱ�-��̬
  procedure prc_compareReport2(ic_smfid       IN   varchar2,  --Ӫҵ��Id
                               ic_umonth_beg  IN   varchar2,  --�Ƚ���ʼ�����·�
                               ic_umonth_end  IN   varchar2,  --�Ƚ���ֹ�����·�                            
                               oc_data        out  myref      --��������
  )is
  c_umonth_beg2     varchar2(10);
  c_umonth_end2     varchar2(10);
  c_month          varchar2(10);
  n_temp            number(12,0);
  
  v_����_����_ˮ��1        number(14,2) default 0;
  v_����_����_ˮ��1        number(14,2) default 0;
  v_����_����ˮ��_ˮ��1    number(14,2) default 0;
  v_����_����ˮ��_ˮ��1    number(14,2) default 0;
  v_�Ǿ���_Դˮ_ˮ��1      number(14,2) default 0;
  v_�Ǿ���_Դˮ_ˮ��1      number(14,2) default 0; 
  v_��ҵ1_ˮ��1            number(14,2) default 0;
  v_��ҵ1_ˮ��1            number(14,2) default 0;
  v_��ҵ2_ˮ��1            number(14,2) default 0;
  v_��ҵ2_ˮ��1            number(14,2) default 0;
  v_����_ˮ��1             number(14,2) default 0;
  v_����_ˮ��1             number(14,2) default 0; 
  
  v_����_����_��ˮ��1      number(14,2) default 0;
  v_����_����_��ˮ��1      number(14,2) default 0;
  v_����_����ˮ��_��ˮ��1  number(14,2) default 0;
  v_����_����ˮ��_��ˮ��1  number(14,2) default 0;
  v_�Ǿ���_Դˮ_��ˮ��1    number(14,2) default 0;
  v_�Ǿ���_Դˮ_��ˮ��1    number(14,2) default 0; 
  v_��ҵ1_��ˮ��1          number(14,2) default 0;
  v_��ҵ1_��ˮ��1          number(14,2) default 0;
  v_��ҵ2_��ˮ��1          number(14,2) default 0;
  v_��ҵ2_��ˮ��1          number(14,2) default 0; 
  v_����_��ˮ��1           number(14,2) default 0;
  v_����_��ˮ��1           number(14,2) default 0; 
  
  v_����_ˮ��1             number(14,2) default 0;
  v_����_ˮ��1             number(14,2) default 0;
  v_����_ˮ��1             number(14,2) default 0;
  v_����_ˮ��1             number(14,2) default 0;
  
  v_����_��ˮ��1           number(14,2) default 0;
  v_����_��ˮ��1           number(14,2) default 0;
  v_����_��ˮ��1           number(14,2) default 0;
  v_����_��ˮ��1           number(14,2) default 0;
   
  v_����_����_ˮ��2        number(14,2) default 0;
  v_����_����_ˮ��2        number(14,2) default 0;
  v_����_����ˮ��_ˮ��2    number(14,2) default 0;
  v_����_����ˮ��_ˮ��2    number(14,2) default 0;
  v_�Ǿ���_Դˮ_ˮ��2      number(14,2) default 0;
  v_�Ǿ���_Դˮ_ˮ��2      number(14,2) default 0; 
  v_��ҵ1_ˮ��2            number(14,2) default 0;
  v_��ҵ1_ˮ��2            number(14,2) default 0;
  v_��ҵ2_ˮ��2            number(14,2) default 0;
  v_��ҵ2_ˮ��2            number(14,2) default 0;
  v_����_ˮ��2             number(14,2) default 0;
  v_����_ˮ��2             number(14,2) default 0; 
  
  v_����_����_��ˮ��2      number(14,2) default 0;
  v_����_����_��ˮ��2      number(14,2) default 0;
  v_����_����ˮ��_��ˮ��2  number(14,2) default 0;
  v_����_����ˮ��_��ˮ��2  number(14,2) default 0;
  v_�Ǿ���_Դˮ_��ˮ��2    number(14,2) default 0;
  v_�Ǿ���_Դˮ_��ˮ��2    number(14,2) default 0; 
  v_��ҵ1_��ˮ��2          number(14,2) default 0;
  v_��ҵ1_��ˮ��2          number(14,2) default 0;
  v_��ҵ2_��ˮ��2          number(14,2) default 0;
  v_��ҵ2_��ˮ��2          number(14,2) default 0;
  v_����_��ˮ��2           number(14,2) default 0;
  v_����_��ˮ��2           number(14,2) default 0; 
  
  v_����_ˮ��2             number(14,2) default 0;
  v_����_ˮ��2             number(14,2) default 0;
  v_����_ˮ��2             number(14,2) default 0;
  v_����_ˮ��2             number(14,2) default 0;
  
  v_����_��ˮ��2           number(14,2) default 0;
  v_����_��ˮ��2           number(14,2) default 0;
  v_����_��ˮ��2           number(14,2) default 0;
  v_����_��ˮ��2           number(14,2) default 0;
  begin                      
    c_umonth_beg2 := to_char(add_months(to_date(ic_umonth_beg,'yyyy.mm'),-12),'yyyy.mm');    
    c_umonth_end2 := to_char(add_months(to_date(ic_umonth_end,'yyyy.mm'),-12),'yyyy.mm');    
    
     
    --����
    select sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--����������ˮ�� 
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0
             end  
           ),--����������ˮ��            
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ�ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ�ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ��ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end   
           ),--�Ǿ���-Դˮ��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ1��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ1��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ2��ˮ��
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--����ˮ��
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           ),--����ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--������������ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--������������ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ���ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ���ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ����ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ1����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ1����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2����ˮ��
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--������ˮ��
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           ) --������ˮ��     
      into v_����_����_ˮ��1,
           v_����_����_ˮ��1,
           v_����_����ˮ��_ˮ��1,
           v_����_����ˮ��_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1,
           v_��ҵ1_ˮ��1,
           v_��ҵ1_ˮ��1,
           v_��ҵ2_ˮ��1,
           v_��ҵ2_ˮ��1,
           v_����_ˮ��1,
           v_����_ˮ��1,
           
           v_����_����_��ˮ��1,
           v_����_����_��ˮ��1,
           v_����_����ˮ��_��ˮ��1,
           v_����_����ˮ��_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1,
           v_��ҵ1_��ˮ��1,
           v_��ҵ1_��ˮ��1,
           v_��ҵ2_��ˮ��1,
           v_��ҵ2_��ˮ��1,
           v_����_��ˮ��1,
           v_����_��ˮ��1 
      from reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and 
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and      
           rl.rlid = rd.rdid and                  
           rltrans not in ( 'u', 'v', '13', '14', '21','23') and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );     
           
    --����ˮ��1
    --v_����_ˮ��1 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
    c_month := ic_umonth_beg;
    while c_month <= ic_umonth_end loop
      if c_month >= '2016.05' then
        begin
          select nvl(sum(ba.baallotsl),0)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select nvl(sum(nvl(rlsl,0)),0)
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*����ˮ��*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_����_ˮ��1 := nvl(n_temp,0) + nvl(v_����_ˮ��1,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    --����ˮ��1
    c_month := ic_umonth_beg;
    while c_month <= ic_umonth_end loop
      if c_month >= '2016.05' then
        begin
          select nvl(sum(ba.baallotsum),0)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select nvl(sum(nvl(rlje,0)),0) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*����ˮ��*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_����_ˮ��1 := nvl(n_temp,0) + nvl(v_����_ˮ��1,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
     
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and 
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��1 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= ic_umonth_beg and  
           pmonth <= ic_umonth_end and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    --------------  �Ա�������� -------------------------------------------------------------------------
    
    --����
    select sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--����������ˮ�� 
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0
             end  
           ),--����������ˮ��            
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ�ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ�ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ��ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end   
           ),--�Ǿ���-Դˮ��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ1��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ1��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2��ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ2��ˮ��
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--����ˮ��
           sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           ),--����ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--������������ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0101','A0102','A0103','A0104','A0106','A0107','A03','A04','A10') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--������������ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ���ˮ��
           sum(
             case 
               when rl.rlpfid in ('A0105','A0108','A0201','A0202','A05','A06','A08','A09','B010301','B010302','B010303','B010304','B010306','B010307'/*,'B040102'*/,'A11','A12') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�������ˮ�ۣ���ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ����ˮ��
           sum(
             case 
               when rl.rlpfid in ('B0208','B0209','B0212') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--�Ǿ���-Դˮ����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ1����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0101','E0403','E050202','E06') and rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0  
             end  
           ),--��ҵ1����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2����ˮ��
           sum(
             case 
               when rl.rlpfid in ('E0201','F01','F02','F03') and rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0  
             end  
           ),--��ҵ2����ˮ��
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           ),--������ˮ��
           sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           ) --������ˮ��     
      into v_����_����_ˮ��2,
           v_����_����_ˮ��2,
           v_����_����ˮ��_ˮ��2,
           v_����_����ˮ��_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2,
           v_��ҵ1_ˮ��2,
           v_��ҵ1_ˮ��2,
           v_��ҵ2_ˮ��2,
           v_��ҵ2_ˮ��2,
           v_����_ˮ��2,
           v_����_ˮ��2,
           
           v_����_����_��ˮ��2,
           v_����_����_��ˮ��2,
           v_����_����ˮ��_��ˮ��2,
           v_����_����ˮ��_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2,
           v_��ҵ1_��ˮ��2,
           v_��ҵ1_��ˮ��2,
           v_��ҵ2_��ˮ��2,
           v_��ҵ2_��ˮ��2,
           v_����_��ˮ��2,
           v_����_��ˮ��2 
      from reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and 
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and 
           rltrans not in ( 'u', 'v', '13', '14', '21','23') and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    SELECT sum(
             case
               when rd.rdpiid = '01' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
           
    --����ˮ��2
    --v_����_ˮ��2 := f_getAllotSl(ic_smfid,ic_umonth_beg,ic_umonth_end);
    c_month := c_umonth_beg2;
    while c_month <= c_umonth_end2 loop
      if c_month >= '2016.05' then
        begin
          select sum(ba.baallotsl)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid  and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select sum(nvl(rlsl,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*����ˮ��*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_����_ˮ��2 := n_temp + nvl(v_����_ˮ��2,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    --����ˮ��2
    c_month := c_umonth_beg2;
    while c_month <= c_umonth_end2 loop
      if c_month >= '2016.05' then
        begin
          select sum(ba.baallotsum)
            into n_temp
            from baseAllot ba
           where exists(select 1 from meterinfo mi where ba.bacid = mi.miid  and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) ) and
                 ba.bamonth = c_month and
                 ba.bastatus = 'Y' ;
        exception
          when no_data_found then
            n_temp := 0;         
        end;         
      else
        begin
          select sum(nvl(rlje,0)) 
            into n_temp
            from reclist rl,
                 payment p
           where p.pmonth = c_month and
                 rl.rlpid = p.pid and 
                 rl.rltrans = 'u' /*����ˮ��*/ and                    
                 exists(select 1 from meterinfo mi where p.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
        exception
          when no_data_found then
            n_temp := 0;
        end;                
      end if; 
      v_����_ˮ��2 := n_temp + nvl(v_����_ˮ��2,0);
      c_month := to_char(add_months(to_date(c_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and        
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = '13' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdsl,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    SELECT sum(
             case
               when rd.rdpiid = '02' then
                 nvl(rdje,0)
               else
                 0 
             end
           )
      into v_����_��ˮ��2 
      FROM reclist rl,
           recdetail rd,
           payment pm
     where pmonth >= c_umonth_beg2 and  
           pmonth <= c_umonth_end2 and
           pm.pid = rl.rlpid and 
           rl.rlid = rd.rdid and
           rltrans = 'v' and
           NVL(RLBADFLAG, 'N') = 'N' and
           RL.RLPFID <> 'A07' AND
           exists(select 1 from meterinfo mi where pm.pcid = mi.miid and mi.mismfid = decode(lower(ic_smfid),'null',mismfid,ic_smfid) );
    
    
    open oc_data for 
    select ic_smfid Ӫҵ��,
           ic_umonth_beg �����·�_��ʼ,
           ic_umonth_end �����·�_��ֹ,
           v_����_����_ˮ��1 ����_����_ˮ��1,
           v_����_����_ˮ��1 ����_����_ˮ��1,
           v_����_����_��ˮ��1 ����_����_��ˮ��1,
           v_����_����_��ˮ��1 ����_����_��ˮ��1,    
           v_����_����_ˮ��2 ����_����_ˮ��2,
           v_����_����_ˮ��2 ����_����_ˮ��2,
           v_����_����_��ˮ��2 ����_����_��ˮ��2,
           v_����_����_��ˮ��2 ����_����_��ˮ��2,
           v_����_����ˮ��_ˮ��1 ����_����ˮ��_ˮ��1,
           v_����_����ˮ��_ˮ��1 ����_����ˮ��_ˮ��1,
           v_����_����ˮ��_��ˮ��1 ����_����ˮ��_��ˮ��1,
           v_����_����ˮ��_��ˮ��1 ����_����ˮ��_��ˮ��1,    
           v_����_����ˮ��_ˮ��2 ����_����ˮ��_ˮ��2,
           v_����_����ˮ��_ˮ��2 ����_����ˮ��_ˮ��2,
           v_����_����ˮ��_��ˮ��2 ����_����ˮ��_��ˮ��2,
           v_����_����ˮ��_��ˮ��2 ����_����ˮ��_��ˮ��2,
           v_����_����_ˮ��1 + v_����_����ˮ��_ˮ��1     ����_С��_ˮ��1,
           v_����_����_ˮ��1 + v_����_����ˮ��_ˮ��1     ����_С��_ˮ��1,
           v_����_����_��ˮ��1 + v_����_����ˮ��_��ˮ��1 ����_С��_��ˮ��1,
           v_����_����_��ˮ��1 + v_����_����ˮ��_��ˮ��1 ����_С��_��ˮ��1,    
           v_����_����_ˮ��2 + v_����_����ˮ��_ˮ��2     ����_С��_ˮ��2,
           v_����_����_ˮ��2 + v_����_����ˮ��_ˮ��2     ����_С��_ˮ��2,
           v_����_����_��ˮ��2 + v_����_����ˮ��_��ˮ��2 ����_С��_��ˮ��2,
           v_����_����_��ˮ��2 + v_����_����ˮ��_��ˮ��2 ����_С��_��ˮ��2,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 �Ǿ���_�Ǿ���_ˮ��1,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 �Ǿ���_�Ǿ���_ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 �Ǿ���_�Ǿ���_��ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 �Ǿ���_�Ǿ���_��ˮ��1,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 �Ǿ���_�Ǿ���_ˮ��2,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 �Ǿ���_�Ǿ���_ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 �Ǿ���_�Ǿ���_��ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 �Ǿ���_�Ǿ���_��ˮ��2,          
           v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_Դˮ_ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_Դˮ_��ˮ��1,
           v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_Դˮ_��ˮ��1,    
           v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_Դˮ_ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_Դˮ_��ˮ��2,
           v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_Դˮ_��ˮ��2,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 + v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_С��_ˮ��1,
           v_����_ˮ��1 - v_����_����_ˮ��1 - v_����_����ˮ��_ˮ��1 - v_�Ǿ���_Դˮ_ˮ��1 - v_��ҵ1_ˮ��1 - v_��ҵ2_ˮ��1 + v_�Ǿ���_Դˮ_ˮ��1 �Ǿ���_С��_ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 + v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_С��_��ˮ��1,
           v_����_��ˮ��1 - v_����_����_��ˮ��1 - v_����_����ˮ��_��ˮ��1 - v_�Ǿ���_Դˮ_��ˮ��1 - v_��ҵ1_��ˮ��1 - v_��ҵ2_��ˮ��1 + v_�Ǿ���_Դˮ_��ˮ��1 �Ǿ���_С��_��ˮ��1,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 + v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_С��_ˮ��2,
           v_����_ˮ��2 - v_����_����_ˮ��2 - v_����_����ˮ��_ˮ��2 - v_�Ǿ���_Դˮ_ˮ��2 - v_��ҵ1_ˮ��2 - v_��ҵ2_ˮ��2 + v_�Ǿ���_Դˮ_ˮ��2 �Ǿ���_С��_ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 + v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_С��_��ˮ��2,
           v_����_��ˮ��2 - v_����_����_��ˮ��2 - v_����_����ˮ��_��ˮ��2 - v_�Ǿ���_Դˮ_��ˮ��2 - v_��ҵ1_��ˮ��2 - v_��ҵ2_��ˮ��2 + v_�Ǿ���_Դˮ_��ˮ��2 �Ǿ���_С��_��ˮ��2,           
           v_��ҵ1_ˮ��1 ��ҵ1_ˮ��1,
           v_��ҵ1_ˮ��1 ��ҵ1_ˮ��1,
           v_��ҵ1_��ˮ��1 ��ҵ1_��ˮ��1,
           v_��ҵ1_��ˮ��1 ��ҵ1_��ˮ��1,    
           v_��ҵ1_ˮ��2 ��ҵ1_ˮ��2,
           v_��ҵ1_ˮ��2 ��ҵ1_ˮ��2,
           v_��ҵ1_��ˮ��2 ��ҵ1_��ˮ��2,
           v_��ҵ1_��ˮ��2 ��ҵ1_��ˮ��2,  
           v_��ҵ2_ˮ��1 ��ҵ2_ˮ��1,
           v_��ҵ2_ˮ��1 ��ҵ2_ˮ��1,
           v_��ҵ2_��ˮ��1 ��ҵ2_��ˮ��1,
           v_��ҵ2_��ˮ��1 ��ҵ2_��ˮ��1,    
           v_��ҵ2_ˮ��2 ��ҵ2_ˮ��2,
           v_��ҵ2_ˮ��2 ��ҵ2_ˮ��2,
           v_��ҵ2_��ˮ��2 ��ҵ2_��ˮ��2,
           v_��ҵ2_��ˮ��2 ��ҵ2_��ˮ��2,   
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,  
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2, 
           v_����_ˮ��1 ����_ˮ��1,
           v_����_ˮ��1 ����_ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,
           v_����_��ˮ��1 ����_��ˮ��1,    
           v_����_ˮ��2 ����_ˮ��2,
           v_����_ˮ��2 ����_ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_��ˮ��2 ����_��ˮ��2,
           v_����_ˮ��1 + v_����_ˮ��1 ����_С��_ˮ��1,
           v_����_ˮ��1 + v_����_ˮ��1 ����_С��_ˮ��1,
           v_����_��ˮ��1 + v_����_��ˮ��1 ����_С��_��ˮ��1,
           v_����_��ˮ��1 + v_����_��ˮ��1 ����_С��_��ˮ��1,    
           v_����_ˮ��2 + v_����_ˮ��2 ����_С��_ˮ��2,
           v_����_ˮ��2 + v_����_ˮ��2 ����_С��_ˮ��2,
           v_����_��ˮ��2 + v_����_��ˮ��2 ����_С��_��ˮ��2,
           v_����_��ˮ��2 + v_����_��ˮ��2 ����_С��_��ˮ��2 
      from dual;      
    
                      
  end;
  
  
    
END PG_EWIDE_JOB_HRB2;
/

