CREATE OR REPLACE PACKAGE HRBZLS.PG_PAD_DL IS
 /*
  * ���ܣ������û�������Ϣ
  * ������:������
  * ����ʱ�䣺2014-07-23
  * @�����Ϣ
  * @����Ա���
  * @�����α�
  */
  procedure DOWN_DATA(I_BFIDS IN VARCHAR2,
                       I_BFRPER   IN VARCHAR2,
                       i_version  in varchar2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       
 /*
  * ���ܣ����ݳ�ʼ��
  * ������:������
  * ����ʱ�䣺2014-07-23
  * @�����Ϣ
  * @����Ա���
  * @�����α�
  */
  procedure DATA_INIT(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       

  --�������ע�ǻ�д�ֻ���
  procedure DOWN_DATA_READCHK(I_BFIDS IN VARCHAR2,
                       I_BFRPER   IN VARCHAR2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       
     --�������ע�ǻ�д�ֻ���
  procedure   DOWN_DATA_PICT(I_MPMIID IN VARCHAR2,
                            I_PMSIZE   IN VARCHAR2,
                            I_PMPATH   IN VARCHAR2,
                            I_PMTIME   IN VARCHAR2,
                            I_PMBZ   IN VARCHAR2,
                            I_PMPER   IN VARCHAR2,
                            I_PMPNAME   IN VARCHAR2,
                            I_ciid   IN VARCHAR2,
                            I_PMFACT_PATH   IN VARCHAR2,
                          O_CURRSOR   OUT  VARCHAR2); 
                                            
  --�ֻ��ϴ�ͼƬʱ�����ν���ͼƬ����
  procedure DOWN_DATA_PICTS(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) ;
                       
                       
END;
/

