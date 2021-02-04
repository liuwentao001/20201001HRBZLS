CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RHZS_01" is
  errcode constant integer := -20012;

  dk����      constant varchar2(1) := '0'; --�������ɵ���
  dkͬ����ftp constant varchar2(1) := '1'; --ͬ����ftp
  dkftp�ش�   constant varchar2(1) := '2'; --dkftp�ش�


  ---------------------------------------------------------------------------
  --name:sp_create_rhzs
  --note:M:�뻧ֱ��
  --author:wy
  --date��2011/10/19
  --input: p_micode   --ˮ���
  --       p_mibfid   --����
  --       p_miCHARGEPER  --�߷�Ա
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�����뻧ֱ�ղ����ͽ�,����������


  ---------------------------------------------------------------------------
    PROCEDURE sp_create_rhzs(
                         p_micode in varchar2, --ˮ���
                         p_mibfid in varchar2,--����
                         p_MICPER in varchar2,--�߷�Ա
                         p_mfsmfid in varchar2,--Ӫҵ������
                         p_oper    in varchar2,--����Ա
                         p_srldate in varchar2,--��ʼ�������� ��ʽ: yyyymmdd
                         p_erldate in varchar2,--��ֹ�������� ��ʽ: yyyymmdd
                         p_smon    in varchar2,--��ʼ�����·� ��ʽ: yyyy.mm
                         p_emon    in varchar2,--��ֹ�����·� ��ʽ: yyyy.mm
                         p_sftype  in varchar2,--���нɷ����� D:���� ,T ����,M �뻧ֱ��
                         p_commit  in varchar2,--�ύ��־
                         o_batch   out varchar2
                         );

  ---------------------------------------------------------------------------
  --name:sp_create_rhzs_rlid_01
  --note:M:�뻧ֱ��
  --author:wy
  --date��2011/10/19
  --input: p_micode   --ˮ���
  --       p_mibfid   --����
  --       p_miCHARGEPER  --�߷�Ա
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־
  --˵�����뻧ֱ�ղ����ͽ�,����������
  ---------------------------------------------------------------------------
  PROCEDURE sp_create_rhzs_rlid_01(
                                     p_micode in varchar2, --ˮ���
                                     p_mibfid in varchar2,--����
                                     p_MICPER in varchar2,--�߷�Ա
                                     p_mfsmfid in varchar2,--Ӫҵ������
                                     p_oper    in varchar2,--����Ա
                                     p_srldate in varchar2,--��ʼ�������� ��ʽ: yyyymmdd
                                     p_erldate in varchar2,--��ֹ�������� ��ʽ: yyyymmdd
                                     p_smon    in varchar2,--��ʼ�����·� ��ʽ: yyyy.mm
                                     p_emon    in varchar2,--��ֹ�����·� ��ʽ: yyyy.mm
                                     p_sftype  in varchar2,--���нɷ����� D:���� ,T ����,M �뻧ֱ��
                                     p_commit  in varchar2,--�ύ��־
                                     o_batch   out varchar2
                                         );

---------------------------------------------------------------------------
  --                        �����ܹ����뻧ֱ����������
  --name:sp_cancle_rhzs
  --note:�����뻧ֱ����������
  --author:wy
  --date��2009/04/26
  --input: p_entrust_batch �뻧ֱ��
  --p_oper in varcahr2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs(p_entrust_batch in varchar2,
                             p_oper in varchar2,--����Ա
                               p_commit        in varchar2) ;
---------------------------------------------------------------------------
  --                        �����뻧ֱ����������
  --name:sp_cancle_rhzs_batch_01
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_batch_01 �뻧ֱ�����κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_batch_01(p_entrust_batch in varchar2,
                               p_oper in varchar2,--����Ա
                               p_commit        in varchar2) ;
---------------------------------------------------------------------------
  --                        �����뻧ֱ��������ˮ����
  --name:sp_cancle_rhzs_entpzseqno_01
  --note:�����뻧ֱ��������ˮ����
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_rhzs_entpzseqno_01  ���κ�
  --p_enterst_pzseqno  in varchar2,��ˮ��
  --p_oper in varcahr2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_rhzs_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--����Ա
                                 p_commit        in varchar2) ;

end;
/

