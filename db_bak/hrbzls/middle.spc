CREATE OR REPLACE PACKAGE HRBZLS."MIDDLE" is
  errcode constant integer := 0;
  err001 EXCEPTION;--���Ѻ��벻����
  err002 EXCEPTION;--�����û�������
  err003 EXCEPTION;--��¼����������ת��ʵʱ��ʽ����
  err004 EXCEPTION;--��Ƿ�Ѽ�¼��ˮ��δ¼����ѽ��ѣ�
  err005 EXCEPTION;--����
  err006 EXCEPTION;--���ײ�����
  err007 EXCEPTION;--�����ظ�
  err008 EXCEPTION;--����(�����)ʱ�䲻����ϵͳʱ��
  err009 EXCEPTION;--Ƿ�ѽ����ڽ��ѽ��
  err020 EXCEPTION;--���ݰ���ʽ��
  err021 EXCEPTION;--���ݿ������
  err022 EXCEPTION;--��������
  err023 EXCEPTION;--Ƿ�Ѽ�¼��������Ӧ��Ӫҵ���ɷ�
  err024 EXCEPTION;--����δ����
  err025 EXCEPTION;--δ���Ͷ����ļ���δͬ��
  err026 EXCEPTION;--�����Ѷ���

  procedure mainzb(p_tran_code in varchar2,
                    i_char in varchar2,
                    o_char out varchar2);
                    
  --��BANK_TRAN_LOG_ALL�в�����־
  procedure addlogall(p_t_code in varchar2,
                    p_i_char in varchar2,
                    p_o_char in varchar2) ;
  
  function lengthValidation(i_char in varchar2,i_start in number,i_length in number) return varchar;
  function typeValidation(i_char in varchar2,type in number) return varchar;
  function charFormat(i_char in varchar2,i_length number,i_type number,i_align number,i_stuff varchar,i_default varchar) return varchar;
  function getValueByNname(narr in arr,iarr in arr,i_name in varchar)return varchar;

end MIDDLE;
/

