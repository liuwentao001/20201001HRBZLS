CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_METERTRANS_01" is

  -- Author  : ����
  -- Created : 2009-3-20 10:50:48
  -- Purpose : PG_CUSTCHANGE

  -- Public type declarations
  errcode constant integer := -20012;

--0 �û�״̬
   c����   constant varchar2(1) := '0';  --����
   c����   constant varchar2(1) := '1';  --����
   cԤ����   constant varchar2(1) := '2';  --����

  /*ˮ��״̬:�ܲ֡��ֹ�˾��������*/
  --1�����ˮ��״̬
  m������     constant varchar2(2) := '2';  --���ֹ�˾��ˮ������û�а�װ
  m�ݲ�       constant varchar2(2) := '3';  --���ֹ�˾��Ƿ�Ѳ��������ݲ�
  m�¹�       constant varchar2(2) := '4';  --���ܲ֡������ֹ�˾���¹����ˮ��
  m����       constant varchar2(2) := '5';  --���ֹ�˾�����ϴ����Ϊ����
  m����       constant varchar2(2) := '6';  --���ֹ�˾��ˮ���ͼ���ڴ���״̬
  m����       constant varchar2(2) := '8';  --���ֹ�˾�����ϲ������û���ͼ죬ˮ��״̬Ϊ����
  m�ܼ쵽��   constant varchar2(2) := '9';  --���ֹ�˾���ܼ�������û���ͼ죬ˮ��״̬Ϊ�ܼ쵽��
  m�����ϱ�   constant varchar2(2) := '10'; --���ܲ֡������ֹ�˾�������޺���ϱ����û�б��ϣ�����״̬��Ϊ�����ϱ�
  m����       constant varchar2(2) := '11'; --���ֹ�˾������������û���ͼ죬ˮ��״̬Ϊ����
  mΥ��       constant varchar2(2) := '12'; --���ֹ�˾��Υ�²���ˮ��״̬ΪΥ��
  m��ͣ       constant varchar2(2) := '13'; --���ֹ�˾����ͣ�������ڱ�ͣ
  m��ͣ       constant varchar2(2) := '14'; --���ֹ�˾����ͣ����������ͣ
  m��ʧ       constant varchar2(2) := '15'; --���ֹ�˾����ʧ�����Ϊ��ʧ
  m�ֳܲ���   constant varchar2(2) := '17'; --���ܲ֡��ܲ�����ֹ�˾���ܲ�ˮ��Ϊ�ֳܲ���
  m��Ǩ       constant varchar2(2) := '16'; --���ֹ�˾����Ǩ�������û���ͼ죬Ϊ��Ǩ

  --2����װˮ��״̬
  m����       constant varchar2(2) := '1';  --���ֹ�˾���û�����ʹ��
  m����       constant varchar2(2) := '7';  --���ֹ�˾�������������û���ͼ죬��������
  m������     constant varchar2(2) := '19'; --���ֹ�˾����������ɹ�����깤ǰ
  m�ھ������ constant varchar2(2) := '20'; --���ֹ�˾���ھ�����ɹ����깤ǰ
  mǷ��ͣˮ�� constant varchar2(2) := '21'; --���ֹ�˾��Ƿ��ͣˮ�ɹ����깤ǰ
  m��װ��     constant varchar2(2) := '22'; --���ֹ�˾����װ�ɹ����깤ǰ
  mУ����     constant varchar2(2) := '23'; --���ֹ�˾��У���ɹ����깤ǰ
  m���ϻ����� constant varchar2(2) := '24'; --���ֹ�˾�����ϻ����ɹ����깤ǰ
  m�ܼ컻���� constant varchar2(2) := '25'; --���ֹ�˾���ܼ컻���ɹ����깤ǰ
  m������     constant varchar2(2) := '26'; --���ֹ�˾�������ɹ����깤ǰ
  m������     constant varchar2(2) := '27'; --���ֹ�˾��ˮ�����Ƹ����ɹ����깤ǰ

  --Ӧ������
  �ƻ�����   constant char(1) :='1';
  ������׶�   constant char(1) :='5';

  Ӫҵ������ constant char(1) :='T';
  ׷��       constant char(1) :='O';
  ��Ƿ       constant char(1) :='V';
  �ޱ�       constant char(2) :='29';
  ���ϱ�       constant char(2) :='30';

  --�������,�������
  bt������         constant char(1) :='R';

  bt�������ϱ��   constant char(1) :='B';
  bt������Ϣ���   constant char(1) :='C';
  bt����           constant char(1) :='D';
  btˮ�۱��       constant char(1) :='E';
  --
  btˮ������       constant char(1) :='3';
  bt��װ�ܱ�       constant char(1) :='A';--��װ��
  bt�������       constant char(1) :='F';
  bt�ھ����       constant char(1) :='G';
  btǷ��ͣˮ       constant char(1) :='H';
  bt��װ           constant char(1) :='I';
  btУ��           constant char(1) :='J';
  bt���ϻ���       constant char(1) :='K';
  bt���ڻ���       constant char(1) :='L';
  bt���鹤��       constant char(1) :='M';
  bt��װ��������� constant char(1) :='P';--��װ��
  bt��װ����       constant char(1) :='Q';--��װ��
  bt��ͣ           constant char(1) :='6';--��װ��
  bt��ˮ           constant char(1) :='9';--��װ��

  --�������״̬
  δ��    constant char(1) :='N';
  ���ɹ�  constant char(1) :='W';
  �����  constant char(1) :='D';
  �ѽ��  constant char(1) :='Z';
  �깤    constant char(1) :='Y';
  �˵�    constant char(1) :='Q';



   --ģ��ͻ���ת������
procedure sp_billnew_test ;
  --���ɵ��ݹ��̣�����billnewhdNOCOMMIT����Ĵ�������
procedure sp_billbuild_test;
--����ƻ��������ɹ��ϻ�����
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_type in varchar2,
                            p_source in varchar2,
                            p_smfid in varchar2,
                            p_dept in varchar2,
                            p_oper in varchar2,
                            p_flag in varchar2,
                            o_billno out varchar2);
  --��ͷ�������
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --������ˮ
                          P_PER   IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2  --�ύ��־
                         ) ;
   --���������������
  PROCEDURE SP_METERTRANS_BY(
                          P_MTHNO IN VARCHAR2, --������ˮ
                          P_mtdrowno IN VARCHAR2,--�к�
                          P_PER   IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2  --�ύ��־
                         )  ;
  --�����嵥����ϸ��ˣ���������ֶ�Ϊ����� METERTRANSDT �� MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- ����Ա
                             P_MD   IN METERTRANSDT%ROWTYPE, --�����б��
                             p_commit in varchar2 --�ύ��־
                             ) ;
--���볭��ƻ�
procedure sp_insertmr(
                      p_pper in varchar2,--����Ա
                      p_month  in varchar2,--Ӧ���·�
                      p_mrtrans in varchar2,--��������
                      p_rlsl   in number,--Ӧ��ˮ��
                      p_scode  in number,--����
                      p_ecode  in number,--ֹ��
                      mi in meterinfo%rowtype,  --ˮ����Ϣ
                      omrid out meterread.mrid%type --������ˮ
                      ) ;
end ;
/

