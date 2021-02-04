CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_BANK_01" is
  errcode constant integer := -20012;

  dk����      constant varchar2(1) := '0'; --�������ɵ���
  dkͬ����ftp constant varchar2(1) := '1'; --ͬ����ftp
  dkftp�ش�   constant varchar2(1) := '2'; --dkftp�ش�
---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid
  --note:D:���� �ܹ���
  --author:wy
  --date��2011/10/19
  --input: p_bankid:���д���
  --       p_mfcode:Ӫҵ������
  --       p_oper:����Ա
  --       p_srldate:��ʼ�������� ��ʽ: yyyymmdd
  --       p_erldate:��ֹ�������� ��ʽ: yyyymmdd
  --       p_smon:��ʼ�����·� ��ʽ: yyyy.mm
  --       p_emon:��ֹ�����·� ��ʽ: yyyy.mm
  --       p_sftype ���нɷ����� D:���� ,T ����,M �뻧ֱ��
  --       p_commit �ύ��־


  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) ;
  ---------------------------------------------------------------------------
  --name:sp_create_dk_batch_rlid_01
  --note:D:����
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
  --˵�������۷���һ��Ӧ��һ��һ�����շѼ�¼

  ---------------------------------------------------------------------------
  PROCEDURE sp_create_dk_rlid_01(p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2);



---------------------------------------------------------------------------
  --                        �����ܹ��̴�����������
  --name:sp_cancle_dk
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk �������κ�
  --  p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk(p_entrust_batch in varchar2,
                            p_oper in varchar2,--����Ա
                               p_commit        in varchar2)  ;
---------------------------------------------------------------------------
  --                        ����������������
  --name:sp_cancle_dk_batch_01
  --note:����������������
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_batch_01 �������κ�
  --p_oper in varchar2,--����Ա
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------

  procedure sp_cancle_dk_batch_01(p_entrust_batch in varchar2,
                              p_oper in varchar2,--����Ա
                               p_commit        in varchar2)   ;
---------------------------------------------------------------------------
  --                        �������۵���
  --name:sp_cancle_dk_imp
  --note:�������۵���
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_dk_imp �������۵���
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_dk_imp_01(p_entrust_batch in varchar2,
                               p_commit        in varchar2)  ;
---------------------------------------------------------------------------
  --name:sp_dk_exp
  --note:����
  --author:wy
  --date��2009/04/26
  --input: p_type:������
  --       p_batch:��������
  --˵��������
 procedure sp_dk_exp(p_type  in varchar2, --������
                                      p_batch in varchar2, --��������
                                      o_base  out tools.out_base)  ;
 --���ɴ����ļ�������
  ---------------------------------------------------------------------------
  --                        ���ɴ����ļ�������
  --name:fgetdkexpname
  --note:���ɴ����ļ�������
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --       p_batch �������κ�
  --return DS(2λ)+���б��(4λ)+����(8λ)+���κ�+(10λ)
  -- ��:DK03001200904280000000001
  ---------------------------------------------------------------------------
  function fgetdkexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2 ;
  --ȡ���۵�����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���۵�����ʽ�ַ���
  --name:fgetdkexpsqlstr
  --note:ȡ���۵�����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpsqlstr(p_type in varchar2, p_bankid in varchar2)
    return varchar2 ;
--ȡ���۵������ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�����
  --name:fgetdkexpsqlstr
  --note:ȡ���۵������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfiletype(p_type in varchar2, p_bankid in varchar2)
    return varchar2 ;

  --ȡ���۵����ʽ�ַ���
  ---------------------------------------------------------------------------
  --                        ȡ���۵����ʽ�ַ���
  --name:fgetdkimpsqlstr
  --note:ȡ���۵����ʽ�ַ���
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------
function fgetdkimpsqlstr(p_type in varchar2, p_bankid in varchar2)
  return varchar2 ;
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
procedure sq_dkfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2) ;

  --�������ݵ������ ͨ����,��,��,������
  ---------------------------------------------------------------------------
  --                        �������ݵ������
  --name:sq_dkfileimp
  --note:�������ݵ������
  --author:wy
  --date��2009/10/27
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
---------------------------------------------------------------------------
procedure sq_dkfilefastimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2) ;

  --�����������ʺͽ���
  --�����������ʺͽ���
  procedure sp_dkpos(p_batch in varchar2,--����������ˮ ����
               p_oper in varchar2 ,----����Ա
               p_commit in varchar2 --�ύ��־
               ) ;

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
  PROCEDURE sp_create_ts(              P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
                                       p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2) ;
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
  PROCEDURE sp_create_ts_maaccount_01(
                                         P_MODEL   IN VARCHAR2 ,--���� TS ,���� LT
                                        p_bankid  in varchar2,
                                       p_mfsmfid in varchar2,
                                       p_oper    in varchar2,
                                       p_srldate in varchar2,
                                       p_erldate in varchar2,
                                       p_smon    in varchar2,
                                       p_emon    in varchar2,
                                       p_sftype  in varchar2,
                                       p_commit  in varchar2,
                                       o_batch   out varchar2);
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
  procedure sp_cancle_ts_batch_01(p_entrust_batch in varchar2,
                                p_oper in varchar2,--����Ա
                               p_commit        in varchar2)  ;
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
  procedure sp_cancle_ts_entpzseqno_01(p_entrust_batch in varchar2,
                                 p_enterst_pzseqno  in varchar2,
                                 p_oper in varchar2,--����Ա
                                 p_commit        in varchar2) ;
---------------------------------------------------------------------------
  --                        �������յ���
  --name:sp_cancle_ts_imp_01
  --note:�������յ���
  --author:wy
  --date��2009/04/26
  --input: sp_cancle_ts_imp_01 �������յ���
  --       p_commit �ύ��־

  ---------------------------------------------------------------------------
  procedure sp_cancle_ts_imp_01(p_entrust_batch in varchar2,
                               p_commit        in varchar2) ;
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
  function fgettsexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2  ;
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

  function fgettsexpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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

  function fgettsimpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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
function fgettsimpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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

  function fgettsexpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;
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
procedure sq_tsfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2)  ;

  --�����������ʺͽ���
  procedure sp_tspos(p_batch in varchar2,--����������ˮ ����
               p_oper in varchar2 ,----����Ա
               p_commit in varchar2 --�ύ��־
               ) ;

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

