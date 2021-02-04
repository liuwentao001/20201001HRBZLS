CREATE OR REPLACE PACKAGE HRBZLS."PG_RAEDPLAN" is

  -- Author  : ADMIN
  -- Created : 2004-4-12 20:49:17
  -- Purpose : �³�����

  --�������

  errcode constant integer := -20012;

  no_data_found exception;
  PROCEDURE createmr(p_mfpcode in VARCHAR2,
                     p_month   in varchar2,
                     p_bfid    in varchar2);
  /*
  ������ҳ���ύ����
  ������p_mtab�� ��ʱ������(PBPARMTEMP.c1)����ŵ��κ�Ŀ����������ˮ����c1,�������c2
        p_smfid: Ŀ��Ӫҵ��
        p_bfid:  Ŀ����
        p_oper�� ����ԱID
  ����1�����³������
        2�����±��
        3�����ţ���ҳ�ţ���ʼ��
        4������ϵͳ��������γ���ʷ�������
  �������
  */
  procedure meterbook(p_smfid in varchar2,
                      p_bfid  in varchar2,
                      p_oper  in varchar2);
  --ɾ������ƻ�
  PROCEDURE deleteplan(p_type    in varchar2,
                       p_mfpcode in varchar2,
                       p_month   in varchar2,
                       p_bfid    in varchar2);

  -- ���մ���
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2009-04-04  by wy
  procedure CarryForward_mr(p_smfid  in varchar2,
                            p_month  in varchar2,
                            p_per    in varchar2,
                            p_commit in varchar2);
  -- �ֹ������½ᴦ��
  --p_smfid Ӫҵ��,��ˮ��˾
  --p_month ��ǰ�·�
  --p_per ����Ա
  --p_commit �ύ��־
  --o_ret ����ֵ
  --time 2010-08-20  by yf
  procedure CarryFpay_mr(p_smfid  in varchar2,
                         p_month  in varchar2,
                         p_per    in varchar2,
                         p_commit in varchar2);
  --���µ�������ƻ�
  procedure sp_updatemrone(p_type   in varchar2, --�������� :01 ��������
                           p_mrid   in varchar2, --������ˮ��
                           p_commit in varchar2 --�Ƿ��ύ
                           );

  --��δ������
  procedure sp_getaddingsl(p_miid      in varchar2, --ˮ���
                           o_masecoden out number, --�ɱ�ֹ��
                           o_masscoden out number, --�±����
                           o_massl     out number, --����
                           o_adddate   out date, --��������
                           o_mastrans  out varchar2, --�ӵ�����
                           o_str       out varchar2 --����ֵ
                           );

  --����������
  procedure sp_getaddedsl(p_mrid      in varchar2, --������ˮ
                          o_masecoden out number, --�ɱ�ֹ��
                          o_masscoden out number, --�±����
                          o_massl     out number, --����
                          o_adddate   out date, --��������
                          o_mastrans  out varchar2, --�ӵ�����
                          o_str       out varchar2 --����ֵ
                          );
  --ȡ����
  procedure sp_fetchaddingsl(p_mrid      in varchar2, --������ˮ
                             p_miid      in varchar2, --ˮ���
                             o_masecoden out number, --�ɱ�ֹ��
                             o_masscoden out number, --�±����
                             o_massl     out number, --����
                             o_adddate   out date, --��������
                             o_mastrans  out varchar2, --�ӵ�����
                             o_str       out varchar2 --����ֵ
                             );

  --������
  procedure sp_rollbackaddedsl(p_mrid in varchar2, --������ˮ
                               o_str  out varchar2 --����ֵ
                               );

  --�����Ⱦ�������12����ʷˮ��������������ˮ��
  procedure updatemrslhis(p_smfid in varchar2, p_month in varchar2);
  --���˼��
  --���˼��
  procedure sp_mrslcheck(p_smfid     in varchar2,
                         p_mrmid     in varchar2,
                         p_MRSCODE   in varchar2,
                         p_MRECODE   in number,
                         p_MRSL      in number,
                         p_MRADDSL   in number,
                         p_MRRDATE   in date,
                         o_errflag   out varchar2,
                         o_ifmsg     out varchar2,
                         o_msg       out varchar2,
                         o_examine   out varchar2,
                         o_subcommit out varchar2);
  --��¼���¾���
  function fgetmrslmonavg(p_miid    in varchar2,
                          p_mrsl    in number,
                          p_mrrdate in date) return number;
  --ȡ����ƽ��
  function fgetthreemonavg(p_miid in varchar2) return number;

  --������
  procedure sp_useaddingsl(p_mrid  in varchar2, --������ˮ
                           p_masid in number, --������ˮ
                           o_str   out varchar2 --����ֵ
                           );
  --������
  procedure sp_retaddingsl(p_MASMRID in varchar2, --������ˮ
                           o_str     out varchar2 --����ֵ
                           );
  --�������μ��
  function fcheckmrbatch(p_mrid in varchar2, p_smfid in varchar2)
    return varchar2;
  --������Ȩ
  procedure sp_mrprivilege(p_mrid in varchar2,
                           p_oper in varchar2,
                           p_memo in varchar2,
                           o_str  out varchar2);
  --��ѯ������Ƿ���ȫ��¼��ˮ��
  function fckkbfidallimputsl(p_smfid in varchar2,
                              p_bfid  in varchar2,
                              p_mon   in varchar2) return varchar2;
  --��ѯ������Ƿ������
  function fckkbfidallsubmit(p_smfid in varchar2,
                             p_bfid  in varchar2,
                             p_mon   in varchar2) return varchar2;
  --�������
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_oper in varchar2,
                            p_memo in varchar2,
                            p_flag in varchar2);

  procedure sp_mrslerrchk(p_mrid            in varchar2, --������ˮ��
                          p_MRCHKPER        in varchar2, --������Ա
                          p_MRCHKSCODE      in number, --ԭ����
                          p_MRCHKECODE      in number, --ԭֹ��
                          p_MRCHKSL         in number, --ԭˮ��
                          p_MRCHKADDSL      in number, --ԭ����
                          p_MRCHKCARRYSL    in number, --ԭ��λˮ��
                          p_MRCHKRDATE      in date, --ԭ��������
                          p_MRCHKFACE       in varchar2, --ԭ���
                          p_MRCHKRESULT     in varchar2, --���������
                          p_MRCHKRESULTMEMO in varchar2, --�����˵��
                          o_str             out varchar2 --����ֵ
                          );

  -- �������������
  --p_cont ���ɳ������������
  --p_commit �ύ��־
  --time 2010-03-14  by wy
  procedure sp_poshandcreate(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2);

  -- �����������ȡ��

  --p_commit �ύ��־
  --time 2010-06-21  by wy
  procedure sp_poshandcancel(p_smfid   in varchar2,
                             p_month   in varchar2,
                             p_bfidstr in varchar2,
                             p_oper    in varchar2,
                             p_commit  in varchar2);

  -- ���������ȡ��
  --p_batch �������������
  --p_commit �ύ��־
  --time 2010-03-15  by wy
  procedure sp_poshanddel(p_batch in varchar2, p_commit in varchar2);
  -- ��������
  --p_type �����������
  --p_batch �������������
  --time 2010-03-15  by wy
  procedure sp_poshandchk(p_type in varchar2, p_batch in varchar2);

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf

  -- ��������ݵ���
  --p_oper �������Ա
  --p_type ���ݵ��뷽ʽ
  --time 2010-03-22  by yf
  procedure sp_poshandimp(p_oper in varchar2, --����Ա
                          p_type in varchar2 --���뷽ʽ
                          );
  procedure sp_poshandimp1(p_oper in varchar2, --����Ա
                           p_type in varchar2 --���뷽ʽ
                           );
  procedure sp_poshandimp_ycb(p_oper  in varchar2, --����Ա
                              p_type  in varchar2, --���뷽ʽ
                              p_bfid  out varchar2,
                              p_bfid1 out varchar2);
  procedure getmrhis(p_miid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number);
  procedure sp_getnoread(vmid   in varchar2,
                         vcont  out number,
                         vtotal out number);

  procedure sp_poshandimp_tp800(p_oper in varchar2, --����Ա
                                p_type in varchar2 --���뷽ʽ
                                );
  procedure sp_poshandcreate_tp900(p_smfid   in varchar2,
                                   p_month   in varchar2,
                                   p_bfidstr in varchar2,
                                   p_oper    in varchar2,
                                   p_commit  in varchar2);
  function  fbdsl(p_mrid   in varchar2)  RETURN VARCHAR2 ;
end ;
/

