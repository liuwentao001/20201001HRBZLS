CREATE OR REPLACE PACKAGE HRBZLS.PG_ZFB IS

  -- Author  : ���Ⲩ
  -- Created : 2014-07-27 ������ 16:56:19
  -- Purpose : ����֧�����ӿ�

  /*���������
  �������˵�� ������Ϣϵͳ
  200001  Ƿ�Ѳ�ѯ
  200002  ���սɷ�
  200003  �û���Ϣ��ѯ
  200004  �û���֪ͨ
  200005  �˵�ʵʱ��ѯ
  200006  �û��ɷ����Ͳ�ѯ
  200007  ����ѯ
  200008  �ɷѼ�¼��ѯ
  200009  ������ҵƽ̨����Э��ά��
  200010  �ѿ��û�������Ϣ��ѯ
  200011  ���������ı�����
  */
  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB);
  /*Ƿ�Ѳ�ѯ
  ��Ӧ��
  1000  �ɷѵ��Ѿ�֧��
  1001  �ɷѵ�δ����
  1002  ��ѯ�ĺ��벻�Ϸ�
  1003  δǷ��
  1004  �ɷѺ��볬�������ڣ������շѵ�λ�ɷѡ�
  1005  ��ʱ�޷��ɷѻ򳬹��޶��ɷѽ�����ѯ��ҵ��λ
  1006  ���д����ڼ��ֹ�ɷ�*/

  FUNCTION F200001(JSONSTR IN VARCHAR2) RETURN CLOB;
  --  --���սɷ�
  /*2001  �ɷѵ��Ѿ����� �ɷѵ��Ѿ��ڽ��ɹ�
  2002  �ɷѽ���  �����еĽ������˻�������Ҫ���ɵĽ����
  2003  �ɷѺ��볬�������ڣ������շѵ�λ�ɷѡ� �ɷѺ��볬�������ڣ������շѵ�λ�ɷѡ�
  2004  �����޶��ɷѽ��  �����޶��ɷѽ��
  2005  ҵ��״̬�쳣  ҵ��״̬�쳣����ʱ�޷��ɷ�
  ��ѯȷ�ϴ���*/

  FUNCTION F200002(JSONSTR IN VARCHAR2) RETURN CLOB;

  --�û���ѯ
  /*  3000  û�и�����¼  ���˻���û�д��������ɷѼ�¼��
      3001  ����ʧ��  ���˻�����������ɷѼ�¼��ʱ����ʧ��
      3002  ����״̬����ȷ ״̬����ȷ�������ڶ��˵�ʱ����ͬ�����ߵĽɷѼ�¼״̬��
  */
  FUNCTION F200003(JSONSTR IN VARCHAR2) RETURN CLOB;
  --�û���֪ͨ
  FUNCTION F200004(JSONSTR IN VARCHAR2) RETURN CLOB;
  --�˵�ʵʱ��ѯ
  FUNCTION F200005(JSONSTR IN VARCHAR2) RETURN CLOB;
   --�û������޸�
  FUNCTION F200006(JSONSTR IN VARCHAR2) RETURN CLOB;
  --����ѯ
  FUNCTION F200007(JSONSTR IN VARCHAR2) RETURN CLOB;
  --�ɷѼ�¼��ѯ
  FUNCTION F200008(JSONSTR IN VARCHAR2) RETURN CLOB;
  --ǰ�û�״̬����
  FUNCTION F300001(JSONSTR IN VARCHAR2) RETURN CLOB;
  --�ɷѳ���
  FUNCTION F300002(JSONSTR IN VARCHAR2) RETURN CLOB;
  --״̬����
  FUNCTION F300003(JSONSTR IN VARCHAR2) RETURN CLOB;
  --����
  FUNCTION F200011(JSONSTR IN VARCHAR2) RETURN CLOB;

  --�ı�ʵʱ���ͱ���
  --�ɷѼ�¼�ı�
  --�賿��������ĽɷѼ�¼
  PROCEDURE SP_JFJLFILE;
  --�˵��ı�
  PROCEDURE SP_ZDFILE;
  --�߷�֪ͨ;
  PROCEDURE SP_CFTZFILE;
  /* Note:֧����ʵʱ�ɷ����˹���
  Input:  p_bankid    ���б���,
          p_chg_op    �շ�Ա,
          p_mcode     ˮ�����Ϻ�,
          p_chg_total �ɷѽ��*/
  FUNCTION F_BANK_CHG_TOTAL(P_BANKID     IN VARCHAR2,
                            P_CHG_OP     IN VARCHAR2,
                            P_TYPE       IN VARCHAR2,
                            P_CHG_TOTAL  IN NUMBER,
                            P_TRANS      IN VARCHAR2,
                            P_MICODE     IN VARCHAR2,
                            P_CHGNO      IN VARCHAR2,
                            P_PAYDATE    IN DATE,
                            P_BANKBILLNO OUT VARCHAR2) RETURN VARCHAR2;

procedure sp_zfbdz(p_sdate in VARCHAR2,
                   p_edate in VARCHAR2,
                   p_smfid in varchar2,
                   p_zfbid out varchar2);

procedure SP_DZ_IMP(
                    p_clob  in clob --�ۿ��ı�
                    );

procedure SP_ZFBLOG(
                    P_TYPE IN VARCHAR2,
                    P_NAME IN VARCHAR2,
                    P_GETCLOB IN CLOB,
                    P_RETNO IN VARCHAR2,
                    P_OUTCLOB IN CLOB,
                    P_STAP IN VARCHAR2
                    );
FUNCTION ERR_LOG_RET(JS         IN JSON,
                      ECODE     IN VARCHAR2, --������
                      ESMG      IN VARCHAR2, --������Ϣ
                      PCODE     IN VARCHAR2, --Э����
                      PNAME     IN VARCHAR2, --Э������
                      PJS       IN VARCHAR2,
                      rtnCode   IN VARCHAR2,
                      stap      IN VARCHAR2,
                      P_OUTISONSTR IN CLOB) RETURN CLOB;
                      
                      
END PG_ZFB;
/

