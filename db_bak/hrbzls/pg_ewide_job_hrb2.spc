CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_JOB_HRB2 AS
  /*  CREATE DATE : 2015/12/8 
   *  AUTHOR : BiYanJun
   *  PURPOSE : ������ά����̨������
   *  LAST MODI DATE : 2015/12/8
   */
   
  --�Զ���������
  ERROR_CUSTOMERPWD_LENGTH constant integer := -2; 
  
  TYPE myref IS REF CURSOR;
  
  --�������� : f_getCustomerPwd
  --��;: �����û���ŷ����û���ˮ���������(��ת��Сд)
  --������ic_micid  in varchar2  �û����
  --����ֵ: ���ܵ��û�����(32λ,Сд),������κ��쳣,����null
  --��������: 2015/12/8
  function f_getCustomerPwd(ic_micid   IN    varchar2) return varchar2; 
  
  --�������� : prc_chgCustomerPwd
  --��������: 2015/12/8
  --��;: �޸Ŀͻ���ˮ������
  --������ic_micid    in  varchar2  �û����
  --      ic_plainpwd in  varchar2  �û���������
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����λ�����󷵻� -2 ,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��     
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_chgCustomerPwd( ic_micid      IN   varchar2,
                                ic_plainpwd   IN   varchar2,
                                on_appcode    OUT  number,
                                oc_error      OUT  varchar2
  ); 
  
  --�������� : f_getAccountPrecash
  --��;: ���ݱ�ŷ����˻���Ԥ�����(����Ǻ��ձ�,���غ����˻����)
  --������ic_micid  in varchar2  �û����
  --����ֵ: Ԥ�����
  --��������: 2016/3/11
  function f_getAccountPrecash(ic_micid   IN    varchar2) return number; 
  
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
  );
  
  
  --�������� : f_checkUnfinishedBill
  --��;: ���ݱ�ŷ����û�δ���Ĺ�����
  --������ic_micid  in varchar2  �û����
  --����ֵ: ��'|'���صĹ�����
  --��������: 2016/3/17
  function f_checkUnfinishedBill(ic_micid   IN    varchar2) return varchar2; 
  
  
  --�������� : f_getCBTFtotal
  --��;: ����ָ��Ӫҵ��ָ�������·ݳ����˷ѽ��(��˺��)
  --������ic_smfid  in varchar2  Ӫҵ�����
  --      ic_month  in varchar2  �����·� (yyyy.mm)
  --����ֵ: �����˷ѽ��
  --��������: 2016/3/30
  function f_getCBTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number; 
  
  
  --�������� : f_getYCTFtotal
  --��;: ����ָ��Ӫҵ��ָ�������·�Ԥ���˷ѽ��(��˺��)
  --������ic_smfid  in varchar2  Ӫҵ�����
  --      ic_month  in varchar2  �����·� (yyyy.mm)
  --����ֵ: �����˷ѽ��
  --��������: 2016/3/30
  function f_getYCTFtotal(ic_smfid   IN    varchar2,
                          ic_month   IN    varchar2
  ) return number; 
	
	--��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����
  --���� ic_rlid   In   varchar2  Ӧ����ˮ��
  --����ֵ:��Ӧָ��Ӧ����ˮ�ţ��Ѿ�������Ԥ����
  function f_getAllotMoney(ic_rlid   IN    varchar2) return number;
  
  --��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·�
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������Ԥ����
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month   IN    varchar2
  ) return number;
  
  
  --��������:f_getAllotMoney
  --��;:��ȡ������ʱ��ˮ�ѵ���Ԥ����(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������Ԥ����
  function f_getAllotMoney(ic_smfid   IN    varchar2,       
                           ic_month1  IN    varchar2,
                           ic_month2  IN    varchar2
  ) return number;
  

  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��
  --���� ic_rlid   In   varchar2  Ӧ����ˮ��
  --����ֵ:��Ӧָ��Ӧ����ˮ�ţ��Ѿ�������ˮ��
  function f_getAllotSl(ic_rlid   IN    varchar2) return number;
  
  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·�
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������Ԥ����
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month   IN    varchar2
  ) return number;
  
  
  --��������:f_getAllotSl
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(����)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
  --     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ������ҵ�� �Ѿ�������ˮ��
  function f_getAllotSl(ic_smfid   IN    varchar2,       
                        ic_month1  IN    varchar2,
                        ic_month2  IN    varchar2
  ) return number;
  
	--��������:f_getAllotSl_current
  --��;:��ȡ������ʱ��ˮ�ѵ���ˮ��(���յ���)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
	--     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ��������µ�ˮ��
  function f_getAllotSl_current(ic_smfid   IN    varchar2,       
                                ic_month1  IN    varchar2,
																ic_month2  IN    varchar2
  ) return number;
	
	--��������:f_getAllotMoney_current
  --��;:��ȡ������ʱ��ˮ�ѵ������(���յ���)
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month1  In   varchar2  �����·�-��ʼ
	--     ic_month2  In   varchar2  �����·�-��ֹ 
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ��������µĽ��
  function f_getAllotMoney_current(ic_smfid   IN    varchar2,       
                                   ic_month1  IN    varchar2,
																	 ic_month2  IN    varchar2 
  ) return number; 
	
	--��������:f_getAllotNumber
  --��;:��ȡ������ʱ��ˮ�ѵ�������
  --���� ic_smfid   In   varchar2  Ӫҵ��
  --     ic_month   In   varchar2  �����·�-��ʼ
  --����ֵ:ͳ��ָ���ֹ�˾ָ�������·� �Ѿ������ļ���
  function f_getAllotNumber(ic_smfid   IN    varchar2,       
                            ic_month   IN    varchar2 
  ) return number;

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
  );

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
  );
  
  
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
  ); 
  
  
  --����Ԥ�����ͳ�Ʊ� ��ʼ��
  PROCEDURE PRC_RPT_ALLOT_INIT;
  
  --��������: prc_rpt_allot_carryOver
  --��������: 2016.6
  --��;: ����Ԥ�����ͳ�Ʊ���ĩ��ת
  --����: ic_month   in   varchar2  �����·�
  --      on_appcode  out number    �����루�ɹ�ִ�з��� 1,����δ�����쳣���� -1 ��
  --      oc_error    out varchar2  ���ش��������쳣���ض�Ӧ������Ϣ��
  --�ύ��ʽ �� �����߸��ݷ����� �ύ(�ع� )
  procedure prc_rpt_allot_carryOver( ic_month   in   varchar2,
                                     on_appcode out  number,
                                     oc_error   out  varchar2
  );
  
  --ˮ��ˮ��������ͬ�ڶԱ�
  procedure prc_compareReport( ic_smfid       IN   varchar2,  --Ӫҵ��Id
                               ic_umonth_beg  IN   varchar2,  --�Ƚ���ʼ�����·�
                               ic_umonth_end  IN   varchar2,  --�Ƚ���ֹ�����·�                            
                               oc_data        out  myref      --��������
  );
  
  --ˮ��ˮ��������ͬ�ڶԱ�-��̬
  procedure prc_compareReport2(ic_smfid       IN   varchar2,  --Ӫҵ��Id
                               ic_umonth_beg  IN   varchar2,  --�Ƚ���ʼ�����·�
                               ic_umonth_end  IN   varchar2,  --�Ƚ���ֹ�����·�                            
                               oc_data        out  myref      --��������
  );
  
   
END PG_EWIDE_JOB_HRB2;
/

