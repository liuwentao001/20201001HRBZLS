CREATE OR REPLACE PROCEDURE HRBZLS."SP_GTJF_OCX_RL" (p_pbatch    in varchar2, --ʵ������
                        P_PID       IN varchar2, --ʵ����ˮ(���հ�ʵ����ˮ��ӡ)
                        p_plid      in varchar2, --ʵ����ϸ��ˮ(���հ�ʵ����ϸ��ˮ��ӡ)
                        p_modelno   in varchar2, --��Ʊ��ʽ��:2/25
                        p_printtype in varchar2, --��Ʊ:H/��Ʊ:F /�������ܷ�Ʊ Z
                        p_ifbd      in varchar2, --�Ƿ񲹴� --��:Y,��:N
                        P_PRINTER   IN VARCHAR2 --��ӡԱ
                        )  is
 /* cursor c_rl is
  select t3.*
  from reclist_bak t3
  order by rlmcode asc, rlmonth asc,rlgroup desc ;*/
 cursor c_rl is
 select  t3.* from payment t, paidlist t1,  reclist t3, meterdoc t4,meterinfo t5
       where pid = plpid
         and rlid = plrlid
         and rlmid = mdmid
         and miid = rlmid
         and pbatch = p_pbatch
         order by rlmcode asc, rlmonth asc,rlgroup desc
     ;
rl reclist%rowtype;
rt reclist_print%rowtype;
v_rlnum reclist_print.rlnum%type;
v_flag number(10);

begin
  delete reclist_print;

  v_flag :=0;
  v_rlnum :=0 ;
 open c_rl;
 loop fetch c_rl into   rl;
 exit when c_rl%notfound or c_rl%notfound is null ;



if    v_flag=0 then
  rt.rlnum            := v_rlnum                 ;--���
/*elsif v_flag=1 and rl.rlgroup=1 then
  rt.rlnum            := v_rlnum                 ;--���*/
else
  v_rlnum            := v_rlnum + 1                 ;
  rt.rlnum            := v_rlnum                 ;--���
  v_flag :=0;
end if;

rt.rlid             := rl.rlid                 ;--��ˮ��
rt.rlsmfid          := rl.rlsmfid              ;--Ӫ����˾
rt.rlmonth          := rl.rlmonth              ;--�����·�
rt.rldate           := rl.rldate               ;--��������
rt.rlcid            := rl.rlcid                ;--�û����
rt.rlmid            := rl.rlmid                ;--ˮ����
rt.rlmsmfid         := rl.rlmsmfid             ;--ˮ��˾
rt.rlcsmfid         := rl.rlcsmfid             ;--�û���˾
rt.rlccode          := rl.rlccode              ;--���Ϻ�
rt.rlchargeper      := rl.rlchargeper          ;--�շ�Ա
rt.rlcpid           := rl.rlcpid               ;--�ϼ��û����
rt.rlcclass         := rl.rlcclass             ;--�û�����
rt.rlcflag          := rl.rlcflag              ;--ĩ����־
rt.rlusenum         := rl.rlusenum             ;--����ˮ����
rt.rlcname          := rl.rlcname              ;--�û�����
rt.rlcadr           := rl.rlcadr               ;--�û���ַ
rt.rlmadr           := rl.rlmadr               ;--ˮ���ַ
rt.rlcstatus        := rl.rlcstatus            ;--�û�״̬
rt.rlmtel           := rl.rlmtel               ;--�ƶ��绰
rt.rltel            := rl.rltel                ;--�̶��绰
rt.rlbankid         := rl.rlbankid             ;--��������
rt.rltsbankid       := rl.rltsbankid           ;--��������
rt.rlaccountno      := rl.rlaccountno          ;--�����ʺ�
rt.rlaccountname    := rl.rlaccountname        ;--��������
rt.rliftax          := rl.rliftax              ;--�Ƿ�˰Ʊ
rt.rltaxno          := rl.rltaxno              ;--��ֳ˰��
rt.rlifinv          := rl.rlifinv              ;--�Ƿ���Ʊ
rt.rlmcode          := rl.rlmcode              ;--ˮ���ֹ����
rt.rlmpid           := rl.rlmpid               ;--�ϼ�ˮ��
rt.rlmclass         := rl.rlmclass             ;--ˮ����
rt.rlmflag          := rl.rlmflag              ;--ĩ����־
rt.rlmsfid          := rl.rlmsfid              ;--ˮ�����
rt.rlday            := rl.rlday                ;--������
rt.rlbfid           := rl.rlbfid               ;--���
rt.rlprdate         := rl.rlprdate             ;--�ϴγ�������
rt.rlrdate          := rl.rlrdate              ;--���γ�������
rt.rlzndate         := rl.rlzndate             ;--ΥԼ��������
rt.rlcaliber        := rl.rlcaliber            ;--��ھ�
rt.rlrtid           := rl.rlrtid               ;--����ʽ
rt.rlmstatus        := rl.rlmstatus            ;--״̬
rt.rlmtype          := rl.rlmtype              ;--����
rt.rlmno            := rl.rlmno                ;--������
rt.rlscode          := rl.rlscode              ;--����
rt.rlecode          := rl.rlecode              ;--ֹ��
rt.rlreadsl         := rl.rlreadsl             ;--����ˮ��
rt.rlinvmemo        := rl.rlinvmemo            ;--��Ʊ��ע
rt.rlentrustbatch   := rl.rlentrustbatch       ;--���մ�������
rt.rlentrustseqno   := rl.rlentrustseqno       ;--���մ�����ˮ��
rt.rloutflag        := rl.rloutflag            ;--������־
rt.rltrans          := rl.rltrans              ;--Ӧ������
rt.rlcd             := rl.rlcd                 ;--�������
rt.rlyschargetype   := rl.rlyschargetype       ;--Ӧ�շ�ʽ
rt.rlsl             := rl.rlsl                 ;--Ӧ��ˮ��
rt.rlje             := rl.rlje                 ;--Ӧ�ս��
rt.rladdsl          := rl.rladdsl              ;--�ӵ�ˮ��
rt.rlscrrlid        := rl.rlscrrlid            ;--ԭӦ������ˮ
rt.rlscrrltrans     := rl.rlscrrltrans         ;--ԭӦ��������
rt.rlscrrlmonth     := rl.rlscrrlmonth         ;--ԭӦ�����·�
rt.rlpaidje         := rl.rlpaidje             ;--���ʽ��
rt.rlpaidflag       := rl.rlpaidflag           ;--���ʱ�־(y:y��n:n��x:x��v:y/n��t:y/x��k:n/x��w:y/n/x)
rt.rlpaidper        := rl.rlpaidper            ;--������Ա
rt.rlpaiddate       := rl.rlpaiddate           ;--��������
rt.rlmrid           := rl.rlmrid               ;--������ˮ
rt.rlmemo           := rl.rlmemo               ;--��ע
rt.rlznj            := rl.rlznj                ;--ΥԼ��
rt.rllb             := rl.rllb                 ;--���
rt.rlcname2         := rl.rlcname2             ;--������
rt.rlpfid           := rl.rlpfid               ;--���۸����
rt.rldatetime       := rl.rldatetime           ;--��������
rt.rlscrrldate      := rl.rlscrrldate          ;--ԭ��������
rt.rlprimcode       := rl.rlprimcode           ;--���ձ������
rt.rlpriflag        := rl.rlpriflag            ;--���ձ��־
rt.rlrper           := rl.rlrper               ;--����Ա
rt.rlsafid          := rl.rlsafid              ;--����
rt.rlscodechar      := rl.rlscodechar          ;--���ڳ�������λ��
rt.rlecodechar      := rl.rlecodechar          ;--���ڳ�������λ��
rt.rlilid           := rl.rlilid               ;--��Ʊ��ˮ��
rt.rlmiuiid         := rl.rlmiuiid             ;--���յ�λ���
rt.rlgroup          := rl.rlgroup              ;--Ӧ���ʷ���

 insert into reclist_print values rt;

if rl.rlgroup=1  then

  v_flag:=1 ;

end if;


 end loop;
 close c_rl;
 if rl.rlgroup=2 and v_rlnum>0 then
   update reclist_print t set t.rlnum = v_rlnum - 1 where
   t.rlnum=v_rlnum ;
 end if;

end;
/

