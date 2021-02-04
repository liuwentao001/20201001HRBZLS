CREATE OR REPLACE PACKAGE HRBZLS."PG_RECTRANS" is

  -- Author  : ADMINISTRATOR
  -- Created : 2009-4-29 13:27:48
  -- Purpose : jh

  -- Public type declarations
  CurrentDate date;

  -- Public constant declarations
  errcode constant integer := -20012;

  -- Public function and procedure declarations

  --�����ύ��ڹ���
  procedure Approve(p_billno in VARCHAR2,
                    p_person in VARCHAR2,
                    p_billid in VARCHAR2,
                    p_djlb   in VARCHAR2);

  --����
  procedure sp_rectrans101(p_no in varchar2, p_per in varchar2);

  --׷��
  procedure sp_rectrans102(p_no in varchar2, p_per in varchar2);

  --Ԥ��
  procedure sp_rectrans103(p_no in varchar2, p_per in varchar2);

  --���
  procedure sp_rectrans104(p_no in varchar2, p_per in varchar2);

  --ˮ��
  procedure sp_rectrans105(p_no in varchar2, p_per in varchar2);

  --���̿�
  procedure sp_rectrans106(p_no in varchar2, p_per in varchar2);

  --�۲�
  procedure sp_rectrans107(p_no in varchar2, p_per in varchar2);
  --
  procedure sp_rectrans108(p_no in varchar2, p_per in varchar2);
  --�����˷ѣ������˿�+��Ӧ�գ�
  procedure sp_paidrecback(p_no in varchar2, p_per in varchar2);
  --ʵ�ճ���
  procedure sp_paidrollback(p_no in varchar2, p_per in varchar2);

  --�ķѳ���
  procedure sp_paidrollback_sf(p_no in varchar2, p_per in varchar2);

  --Ӧ�յ���
  procedure recadjust(rah   in recadjusthd%rowtype,
                      rad   in recadjustdt%rowtype,
                      p_per in varchar2,
                      rlcr  out reclist%rowtype,
                      rlde  out reclist%rowtype);
  --����Ӧ�մ���
  procedure recback(p_rlid       in varchar2,
                    p_rdpiidlist in varchar2,
                    p_trans      in varchar2,
                    p_per        in varchar2,
                    p_memo       in varchar2,
                    bf           in bookframe%rowtype,
                    rlcr         out reclist%rowtype);
  --׷�ղ��볭��ƻ�����ʷ��
  procedure sp_insertmrhis(rth   in rectranshd%rowtype, --׷��ͷ
                           mi    in meterinfo%rowtype, --ˮ����Ϣ
                           omrid out meterreadhis.mrid%type); --������ˮ
  --׷�ճ���
  procedure sp_recrollback(p_billno in VARCHAR2, --��ˮ��
                           p_person in VARCHAR2, --����Ա
                           p_billid in VARCHAR2,
                           p_djlb   in VARCHAR2);
end pg_rectrans;
/

