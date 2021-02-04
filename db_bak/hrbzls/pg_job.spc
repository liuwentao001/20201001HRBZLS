CREATE OR REPLACE PACKAGE HRBZLS."PG_JOB" is

  -- Author  : ����
  -- Created : 2008-06-15 17:08:35
  -- Purpose : jh

  --�������
  errcode constant integer:= -20012;

  function  fwhatname(job_what in varchar2) return varchar2;

  --�����ö�JOB���˹�����ϵͳ���г�ʼ�ֹ�ִ��һ��
  procedure Topjobsubmit(p_time in varchar2);
  --�ö�JOB���õ��ؽ�����JOB����
  procedure Rebuildalljobs;

  --���ƻ�ʱ������JOB���ճ���
  procedure SetCarryover(p_time in varchar2);
  --���ƻ�ʱ������JOB�����۵�����
  procedure Setdkexp(p_time in varchar2);
  --���ƻ�ʱ������JOB�����۵��롿
  procedure Setdkimp(p_time in varchar2);
    --���ƻ�ʱ������JOB�����˵��롿
  procedure SetbankXCZLStaskd(P_bankid in varchar2);
  --���ƻ�ʱ������JOB���ֹ����۵��롿
  procedure Sethanddkimp(p_time in date , p_bankid in varchar2 ) ;
  --���ƻ�ʱ������JOB�����۵�����
  procedure Sethanddkexp( p_bankid in varchar2 );
  --���ƻ�ʱ������JOB����̨��ѡ�
  procedure SetCal(p_time in varchar2);
  --���ƻ�ʱ������JOB��Ԥ��ֿ����ʡ�
  procedure SetSavingPay(p_time in varchar2);
  --���ƻ�ʱ������JOB�����д��ն��ʡ�
  procedure SetDz(p_time in varchar2);
  --���ƻ�ʱ������JOB��������־ת�桿
  procedure SetClearTransLog(p_time in varchar2);
  --���ƻ�ʱ������JOB����װ���ݵ��롿
  procedure SetRefmv(p_time in varchar2);
  procedure SetCarryFee(p_time in varchar2);
  procedure CarryFee;
  --�ճ�����
  procedure Carryover;
end pg_job;
/

