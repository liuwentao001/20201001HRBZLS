CREATE OR REPLACE PACKAGE HRBZLS.PG_PAD_UPDATA IS
  /*
  * ���ܣ��ϴ�������
  * ������:������
  * ����ʱ�䣺2014-06-22
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */
  procedure main(i_trans_code IN varchar2,i_in_trans IN VARCHAR2, o_out_trans OUT VARCHAR2);
  
 /*
  * ���ܣ�8001Э��
  * ������:������
  * ����ʱ�䣺2014-08-28
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */
  procedure f8001(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
  /*
  * ���ܣ�8001Э��
  * ������:������
  * ����ʱ�䣺2014-08-28
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */
  procedure f8002(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * ���ܣ�8003Э��  
   �ֻ�����ȷ�����������ݸ�Ӫ�գ� -> Ӫ�� (���ݳ������ݽ�����ѣ���������ֻ�) -> �ֻ���������ѽ���� ��ӡ�߷�֪ͨ��
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */              
  procedure f8003(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * ���ܣ�8004Э��  
     ������֤����Э��
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */                
  procedure f8004(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
  /*
  * ���ܣ�8005Э��  
     �����汾��֤����Э��
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */                
  procedure f8005(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
                  
                                    
  /*
  * ���ܣ�8006Э��  
    �û��㳭��ȡ��Э�飬����ע��������
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */                
  procedure f8006(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * ���ܣ�8007Э��  
    �û�Ѳ�������ϴ�
  * ������:�ذ�
  * ����ʱ�䣺2015-03-12
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */                
  procedure f8007(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);

                  
   /*
  * ���ܣ�8008Э��  
    �û�ͼƬ�����ϴ�
  * ������:�ذ�
  * ����ʱ�䣺2015-07-15
  * �޸��ˣ�  
  * �޸�ʱ�䣺
  */   
  procedure f8008(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
END;
/

