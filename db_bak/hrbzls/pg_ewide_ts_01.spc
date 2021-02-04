CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_TS_01" IS
  ERRCODE CONSTANT INTEGER := -20012;

  DK����      CONSTANT VARCHAR2(1) := '0'; --�������ɵ���
  DKͬ����FTP CONSTANT VARCHAR2(1) := '1'; --ͬ����ftp
  DKFTP�ش�   CONSTANT VARCHAR2(1) := '2'; --dkftp�ش�

  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:����
  --author:wy
  --date��2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ�ʺ�һ��һ�����շѼ�¼

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                         P_BANKID  IN VARCHAR2,
                         P_MFSMFID IN VARCHAR2,
                         P_OPER    IN VARCHAR2,
                         P_SRLDATE IN VARCHAR2,
                         P_ERLDATE IN VARCHAR2,
                         P_SMON    IN VARCHAR2,
                         P_EMON    IN VARCHAR2,
                         P_SFTYPE  IN VARCHAR2,
                         P_COMMIT  IN VARCHAR2,
                         O_BATCH   OUT VARCHAR2);
  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:T:����
  --author:wy
  --date��2009/04/26
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼

  ---------------------------------------------------------------------------
  PROCEDURE SP_CREATE_TS_MAACCOUNT_01(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  PROCEDURE SP_CREATE_TS_MAACCOUNT_02(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  --name:sp_create_dk_batch_rlid_01
  --note:T:����
  --author:lgb
  --date��2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼
  PROCEDURE SP_CREATE_TS_MAACCOUNT_03(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);

  --name:SP_CREATE_TS_MAACCOUNT_04
  --note:T:����
  --author:lgb
  --date��2012/09/21
  --input: P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
  -- p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�������շ���һ��Ӧ��һ��һ�����շѼ�¼
  PROCEDURE SP_CREATE_TS_MAACCOUNT_04(P_MODEL   IN VARCHAR2, --���� TS ,���� LT
                                      P_BANKID  IN VARCHAR2,
                                      P_MFSMFID IN VARCHAR2,
                                      P_OPER    IN VARCHAR2,
                                      P_SRLDATE IN VARCHAR2,
                                      P_ERLDATE IN VARCHAR2,
                                      P_SMON    IN VARCHAR2,
                                      P_EMON    IN VARCHAR2,
                                      P_SFTYPE  IN VARCHAR2,
                                      P_COMMIT  IN VARCHAR2,
                                      P_STSH    IN VARCHAR2,
                                      P_ETSH    IN VARCHAR2,
                                      O_BATCH   OUT VARCHAR2);
  ---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_ts_batch
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: p_entrust_batch �������κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_BATCH_01(P_ENTRUST_BATCH IN VARCHAR2,
                                  P_OPER          IN VARCHAR2, --����Ա
                                  P_COMMIT        IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_ts_entpzseqno_01
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_ts_entpzseqno_01 �������κ�
  --p_enterst_pzseqno  in varchar2,��ˮ��
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_ENTPZSEQNO_01(P_ENTRUST_BATCH   IN VARCHAR2,
                                       P_ENTERST_PZSEQNO IN VARCHAR2,
                                       P_OPER            IN VARCHAR2, --����Ա
                                       P_COMMIT          IN VARCHAR2);

  --����δ���� lgb by 2012-09-27
  PROCEDURE SP_CANCLE_TS_WXZ_01(P_BATCH IN VARCHAR2, P_OPER IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        �������յ���
  --name:sp_cancle_ts_imp_01
  --note:�������յ���
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_ts_imp_01 �������յ���
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  PROCEDURE SP_CANCLE_TS_IMP_01(P_ENTRUST_BATCH IN VARCHAR2,
                                P_COMMIT        IN VARCHAR2);
  ---------------------------------------------------------------------------
  --                        ���������ļ�������
  --name:fgettsexpname
  --note:���������ļ�������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --       p_batch �������κ�
  --return TSDS(4λ)+���б��(6λ)+����(8λ)+���κ�+(10λ)
  -- ��:DK03001200904280000000001
  ---------------------------------------------------------------------------
  FUNCTION FGETTSEXPNAME(P_TYPE   IN VARCHAR2,
                         P_BANKID IN VARCHAR2,
                         P_BATCH  IN VARCHAR2) RETURN VARCHAR2;
  --ȡ���յ������ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���յ������ļ�����
  --name:fgettsexpfiletype
  --note:ȡ���յ������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        ȡ���յ������ļ�·��
  --name:fgettsexpfiletype
  --note:ȡ���յ������ļ�·��
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEPATH(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        ȡ���յ������ļ�·��
  --name:fgettsexpfiletype
  --note:ȡ���յ�����ʽ
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEGS(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  ---------------------------------------------------------------------------
  --                        ȡ���յ������ļ�·��
  --name:fgettsexpfiletype
  --note:ȡ���յ�����׺
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPFILEHZ(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --ȡ���յ�����ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���յ�����ļ�����
  --name:fgettsimpfiletype
  --note:ȡ���յ������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSIMPFILETYPE(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --ȡ���յ����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���յ����ʽ�ַ���
  --name:fgettsimpsqlstr
  --note:ȡ���յ����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------
  FUNCTION FGETTSIMPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;

  --ȡ���յ�����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���յ�����ʽ�ַ���
  --name:fgetdkexpsqlstr
  --note:ȡ���յ�����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  FUNCTION FGETTSEXPSQLSTR(P_TYPE IN VARCHAR2, P_BANKID IN VARCHAR2)
    RETURN VARCHAR2;
  --�������ݵ������
  ---------------------------------------------------------------------------
  --                        �������ݵ������
  --name:sq_dkfileimp
  --note:�������ݵ������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP_BAK(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2);

  --�������ݵ������
  ---------------------------------------------------------------------------
  --                        �������ݵ���������
  --name:sq_dkfile
  --note:�������ݵ������
  --author:lgb
  --date��2013/03/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMP(P_BATCH    IN VARCHAR2,
                         P_COUNT    IN NUMBER,
                         P_LASTTIME IN VARCHAR2);
  --�������ݵ������
  ---------------------------------------------------------------------------
  --                        �������ݵ�����̿��ٵ���
  --name:SQ_TSFILEIMPfast
  --note:�������ݵ������
  --author:lgb
  --date��2013/03/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  ---------------------------------------------------------------------------
  PROCEDURE SQ_TSFILEIMPFAST(P_BATCH    IN VARCHAR2,
                             P_COUNT    IN NUMBER,
                             P_LASTTIME IN VARCHAR2);
  --�����������ʺͽ���
  PROCEDURE SP_TSPOS(P_BATCH  IN VARCHAR2, --����������ˮ ����
                     P_OPER   IN VARCHAR2, ----����Ա
                     P_COMMIT IN VARCHAR2 --�ύ��־
                     );

  --name:sp_dk_exp
  --note:����
  --author:wy
  --date��2009/04/26
  --input: p_type:������
  --       p_batch:��������
  --˵��������
  PROCEDURE SP_TS_EXP(P_TYPE  IN VARCHAR2, --������
                      P_BATCH IN VARCHAR2, --��������
                      O_BASE  OUT TOOLS.OUT_BASE);
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:ȡ��ˮ ��ˮ��
  --author:���Ⲩ
  --date��2011/11/10
  --input: pc ���κ�
  --       tsh  ���պ�
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSSL_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER;
  ---------------------------------------------------------------------------
  --name:F_GETwzTSsl_wz
  --note:ȡ��ˮ �Ľ��
  --author:���Ⲩ
  --date��2011/11/10
  --input: pc ���κ�
  --       tsh  ���պ�
  ---------------------------------------------------------------------------
  FUNCTION F_GETWZTSJE_WZ(PC VARCHAR2, TSH VARCHAR2) RETURN NUMBER;
END;
/

