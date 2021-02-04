CREATE OR REPLACE PACKAGE HRBZLS."ZHONGBE" is

  type myarray IS TABLE OF varchar2(500) INDEX BY BINARY_INTEGER;
  /*  arr_1 arr index by binary_integer;*/
  --��������
  errcode constant integer := -20012;
  --���̶����ڴ�

  --���������ڴ�
  function main(P_CODE in VARCHAR2, p_in in arr, p_out in out arr)
    return varchar2;
  function f_set_item(p_arr in out arr, p_data in varchar2) return number;
  function F_SET_TEXT(P_ROW IN VARCHAR2,P_DATE IN VARCHAR2) return number;
  function F_GET_HDTEXT(P_ROW IN VARCHAR2) return VARCHAR2;
  function F_GET_DTTEXT(P_ROW IN VARCHAR2) return VARCHAR2;

  procedure f520(p_in in arr, p_out in out arr);
  procedure f521(p_in in arr, p_out in out arr);
  procedure f522(p_in in arr, p_out in out arr);

  procedure f540(p_in in arr, p_out in out arr);
  procedure sp_qf_month(p_qf in out arr, p_rlid in varchar2);
  procedure sp_ysjl_month(p_qf in out arr, p_rlid in varchar2);
  procedure sp_ssjl_month(p_qf in out arr, p_pid in varchar2);
  procedure sp_ssjy_month(p_qf in out arr, p_rlid in varchar2);
  procedure f600(p_in in arr, p_out in out arr);
  procedure f580(p_in in arr, p_out in out arr);
  procedure f550(p_in in arr, p_out in out arr);
  procedure f510(p_in in arr, p_out in out arr);
  procedure f511(p_in in arr, p_out in out arr);
  procedure f110(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 111 ǩ�����۹�ϵ��������ˮ����������
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f111(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 120 ������۹�ϵ
  Input: p_bankid -- ���б���
         p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f120(p_in in arr, p_out in out arr);
  /*----------------------------------------------------------------------
  Note: 130 ��ѯ�û�ǩԼ״̬
  Input: p_in  -- �����
  Output:p_out --���ذ�
  ----------------------------------------------------------------------*/
  procedure f130(p_in in arr, p_out in out arr);
  procedure sp_test;
  procedure sp_extensiondata(P_ROW IN NUMBER);
  /*---------------------------------------------------------------------
   �� arr ����ת��Ϊ|�ָ����ַ���
  ---------------------------------------------------------------------*/
  function f_arr2var(p_msg in arr) return varchar2;
  /*---------------------------------------------------------------------
  ��¼������־
  ---------------------------------------------------------------------*/
  procedure sp_tran_log(p_code in varchar2, p_req in arr, p_ans in arr);
  procedure sp_tran_errlog(p_code in varchar2, 
                           p_req in arr, 
                           p_ans in arr,
                           p_errid in varchar2,
                           p_errtext in varchar2);
  /*��¼ǩԼ��־*/
  procedure entrust_sign_log(p_ccode       in varchar2,
                             p_cname       in varchar2,
                             p_bankid      in varchar2,
                             p_ACCOUNTNO   in varchar2,
                             p_ACCOUNTNAME in varchar2,
                             p_CHARGETYPE  in varchar2,
                             p_SIGN_TYPE   in char,
                             p_SIGN_OK     in char);
  /*----------------------------------------------------------------------
  Note:����ʵʱ�ɷ����˹���
  Input:  p_bankid    ���б���,
          p_chg_op    �շ�Ա,
          p_mcode     ˮ�����Ϻ�,
          p_chg_total �ɷѽ��
  output: p_chgno     ����Ϊ������ˮ�����Ϊϵͳʵ����ˮ��,
          p_discharge ���νɷ�Ԥ��ķ���ֵ�����Ϊ����Ԥ�����ӣ����Ϊ������ʹ��Ԥ������˵ֿ�
          p_curr_sav  ���νɷѺ�Ԥ������
  return��1  �޴�ˮ���
          5  ����
          21 ���ݿ����
          22 ��������
  ҵ�����˵����
  1��ˮ�����Ϻ���ȫ��Ƿ�ѱ���һͬ���壻
  2������������;ʱ��������ʵʱ���գ����������ջ����ҳɹ�ʱ��Ԥ�棻
  3������ʱ��ÿ��5:00-23:00
  ----------------------------------------------------------------------*/
  function f_bank_chg_total(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2;
  ----------------------------------------------------------------------*/
  -----------ƽ�ʵ���-----------------------------------------------------
  function f_bank_chg_total_pz(p_bankid    in varchar2,
                            p_chg_op    in varchar2,
                            p_mcode     in varchar2,
                            p_chg_total in number,
                            p_trans     in varchar2,
                            p_chgno     in varchar2,
                            p_invpc     in varchar2,
                            p_invno     in varchar2,
                            o_pid       out varchar2,
                            o_discharge out number,
                            o_curr_sav  out number) return varchar2;
  /*����ʵʱ�ɷѳ���----------------------------------------------------------------------
   p_bankid:���д���
   p_transno:������������ˮ
   p_date :���н�������
   return��
         6�����ײ�����
         21�����ݿ������
         22����������
  ------------------------------------------------------------------------------------------*/
  function f_bank_discharged(p_bankid  in varchar2,
                            p_transno in varchar2,
                            p_meterno in varchar2,
                            p_date    in date) return number;
  /* ����ʵʱ�ɷѳ���----------------------------------------------------------------------
  p_bankid:���д���
  p_transno:������������ˮ
  p_date :���н�������
  return�� */
  function f_bank_dischargeone(p_bankid  in varchar2,
                               p_transno in varchar2,
                               p_meterno in varchar2,
                               p_date    in date) return varchar2;
  --���в���
  function f_bank_charged_total(p_bankid    in varchar2, --����
                                p_chg_op    in varchar2, --����Ա
                                p_mcode     in varchar2, --����
                                p_chg_total in number, --�ɷѽ��
                                p_chg_no    in varchar2, --������ˮ
                                p_paydate   in varchar2 --��������
                                ) return number;
  --���в���ƽ��
  function f_bank_charged_total_pz(p_bankid    in varchar2, --����
                                p_chg_op    in varchar2, --����Ա
                                p_mcode     in varchar2, --����
                                p_chg_total in number, --�ɷѽ��
                                p_chg_no    in varchar2, --������ˮ
                                p_paydate   in varchar2 --��������
                                ) return number;
                                
  --���ж��ˣ���������ˮ������Ϣ��
  procedure sp_bankdz(p_date in date,p_smfid in varchar2);
  
    --�жϺ��ձ��ˮ��ˮ�ѵ����Ƿ���ͬ
    function f_priceissame(p_pmiid  in varchar2) return varchar2;
    
   --��ȡ�û��˿���
    function f_getcardno(p_rlcid  in varchar2) return varchar2;
    
    --���븶�ʽ
    function f_getpayway(p_ppayway  in varchar2) return varchar2;
    
    --�ж����н��׿���
    FUNCTION F_GETBANKSYSPARA(P_BANKID IN VARCHAR2) RETURN VARCHAR2;
    
    --�������н��׿���
    PROCEDURE P_SETBANKSYSPARA(P_BANKID IN VARCHAR2, P_TYPE IN VARCHAR2,P_COMMIT IN VARCHAR2);
    
    --�Զ���������
    PROCEDURE SP_AUTOBANKZZ;
    --�Զ����������ֶ�
    PROCEDURE SP_AUTOBANKZZ_�ֶ�;
        
    --�Զ�����ƽ��
    PROCEDURE SP_AUTOBANKPZ(p_date in date,p_smfid in varchar2);
    
    PROCEDURE SP_AUTOBANKPZ_test(p_date in date,p_smfid in varchar2);
     
      
end ZHONGBE;
/

