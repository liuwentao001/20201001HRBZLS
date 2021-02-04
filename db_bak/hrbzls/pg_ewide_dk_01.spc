CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_DK_01" is
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
  PROCEDURE sp_create_dk_rlid_03(

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
function fgetdkexpname(p_type   in varchar2,
                         p_bankid in varchar2,
                         p_batch  in varchar2) return varchar2  ;
--ȡ���۵������ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�����
  --name:fgetdkexpfiletype
  --note:ȡ���۵������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;


  ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�·��
  --name:fgetdkexpfiletype
  --note:ȡ���۵������ļ�·��
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilepath(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

 ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�·��
  --name:fgetdkexpfiletype
  --note:ȡ���۵�����ʽ
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilegs(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;


 ---------------------------------------------------------------------------
  --                        ȡ���۵������ļ�·��
  --name:fgetdkexpfiletype
  --note:ȡ���۵�����׺
  --author:lgb
  --date��2012/09/22
  --input: p_type ����
  --       p_bankid ���б��ǰ��λ
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkexpfilehz(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

   --ȡ���۵�����ļ�����
  ---------------------------------------------------------------------------
  --                        ȡ���۵�����ļ�����
  --name:fgetdkimpfiletype
  --note:ȡ���۵������ļ�����
  --author:wy
  --date��2009/04/28
  --input: p_type ����
  --       p_bankid
  --return
  --
  ---------------------------------------------------------------------------

  function fgetdkimpfiletype(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;

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
function fgetdkimpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;




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

  function fgetdkexpsqlstr(p_type in varchar2, p_bankid in varchar2)  return varchar2  ;
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
procedure sp_DKfileimp(p_batch in varchar2 , p_count in number,p_lasttime in varchar2)  ;

  --�����������ʺͽ���
  procedure sp_dkpos(p_batch in varchar2,--����������ˮ ����
               p_oper in varchar2 ,----����Ա
               p_commit in varchar2 --�ύ��־
               ) ;
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
  ---------------------------------------------------------------------------
 ---�������ۣ�20121204��
  procedure sp_YHPLDK_exp(p_type  in varchar2, --������
                                   p_batch in varchar2, --��������
                                    p_filename in varchar2, ---�ļ�����
                                    o_base  out tools.out_base);
---�������۶��ˣ�20121211��
procedure sp_yhpkdz_exp(p_type  in varchar2, --������
                                     p_batch in varchar2, --��������
                                     p_filename in varchar2 ---�ļ�����
                              );
 end;
/

