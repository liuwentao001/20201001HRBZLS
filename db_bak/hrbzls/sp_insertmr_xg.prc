CREATE OR REPLACE PROCEDURE HRBZLS."SP_INSERTMR_XG" (p_month  in varchar2,--Ӧ���·�
                                              p_rlsl   in number,--Ӧ��ˮ��
                                              p_scode  in number,--����
                                              p_ecode  in number,--ֹ��
                                              mi in meterinfo%rowtype,  --ˮ����Ϣ
                                              omrid out meterread.mrid%type) as   --������ˮ
  mrhis meterread%rowtype; --������ʷ��
  ci custinfo%rowtype; --�û���Ϣ
begin
    begin
      select * into ci from custinfo where ciid = mi.micid;
    exception when others then
      raise_application_error(-20010, '�û�������!');
    end;

      mrhis.MRID                       := fgetsequence('METERREAD')                        ; --��ˮ��
      omrid                            := mrhis.MRID         ;
      mrhis.MRMONTH                    := tools.fGetmeterplanMon(mi.mismfid)               ; --�����·�
      mrhis.MRSMFID                    := fgetmeterinfo(mi.miid,'MISMFID')                  ; --Ӫ����˾
      mrhis.MRBFID                     := mi.mibfid /*rth.RTHBFID*/                                      ; --���
      begin
      select  BFBATCH into mrhis.MRBATCH  from bookframe where bfid=mi.mibfid and bfsmfid=mi.mismfid                                      ;
      exception when others then
      mrhis.MRBATCH                    :=  1 ;     --��������
      end;

      begin
          select mrbsdate
          into  mrhis.MRDAY
          from meterreadbatch
          where mrbsmfid=mi.mismfid and
                mrbmonth=mrhis.MRMONTH and
                mrbbatch= mrhis.MRBATCH ;
        exception when others then
        mrhis.MRDAY                       := sysdate                                    ; --�ƻ�������
     /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
             raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
       end if;*/
      end;
      mrhis.MRDAY                       := sysdate                                    ; --�ƻ�������
      mrhis.MRRORDER                   := mi.MIRORDER                                      ; --�������
      mrhis.MRCID                      := CI.CIID                                       ; --�û����
      mrhis.MRCCODE                    := CI.CICODE                                     ; --�û���
      mrhis.MRMID                      := MI.MIID                                       ; --ˮ����
      mrhis.MRMCODE                    := MI.MICODE                                     ; --ˮ���ֹ����
      mrhis.MRSTID                     := mi.MISTID                                        ; --��ҵ����
      mrhis.MRMPID                     := mi.MIPID                                         ; --�ϼ�ˮ��
      mrhis.MRMCLASS                   := mi.MICLASS                                       ; --ˮ����
      mrhis.MRMFLAG                    := mi.MIFLAG                                        ; --ĩ����־
      mrhis.MRCREADATE                 := sysdate                                          ; --��������
      mrhis.MRINPUTDATE                := sysdate                                          ; --�༭����
      mrhis.MRREADOK                   := 'Y'                                              ; --������־
      mrhis.MRRDATE                    := SYSDATE                            ; --��������
      mrhis.MRRPER                     := null                                             ; --Ԥ�� �ճ���Ա
      mrhis.MRPRDATE                   := null                                             ; --�ϴγ�������
      mrhis.MRSCODE                    := p_scode                                          ; --���ڳ���
      mrhis.MRECODE                    := p_ecode                                          ; --���ڳ���
      mrhis.MRSL                       := p_rlsl                                           ; --����ˮ��
      mrhis.MRFACE                     := NULL                                             ; --ˮ�����
      mrhis.MRIFSUBMIT                 := 'Y'                                              ; --�Ƿ��ύ�Ʒ�
      mrhis.MRIFHALT                   := 'N'                                              ; --ϵͳͣ��
      mrhis.MRDATASOURCE               := '1'; --��������Դ�����񳭱�
      mrhis.MRIFIGNOREMINSL            := 'N'                                              ; --ͣ����ͳ���
      mrhis.MRPDARDATE                 := NULL                                             ; --���������ʱ��
      mrhis.MROUTFLAG                  := 'N'                                              ; --�������������־
      mrhis.MROUTID                    := NULL                                             ; --�������������ˮ��
      mrhis.MROUTDATE                  := NULL                                             ; --���������������
      mrhis.MRINORDER                  := NULL                                             ; --��������մ���
      mrhis.MRINDATE                   := NULL                                             ; --�������������
      mrhis.MRRPID                     := null                                             ; --�Ƽ�����
      mrhis.MRMEMO                     := '�ֹ�¼��Ƿ��'                                     ; --����ע
      mrhis.MRIFGU                     := 'N'                                              ; --�����־
      mrhis.MRIFREC                    := 'N'                                              ; --�ѼƷ�
      mrhis.MRRECDATE                  := SYSDATE                                          ; --�Ʒ�����
      mrhis.MRRECSL                    := p_rlsl                                        ; --Ӧ��ˮ��
      mrhis.MRADDSL                    := 0                                                                                  ; --����
      mrhis.MRCARRYSL                  := 0                                                ; --��λˮ��
      mrhis.MRCTRL1                    := NULL                                             ; --���������λ1
      mrhis.MRCTRL2                    := NULL                                             ; --���������λ2
      mrhis.MRCTRL3                    := NULL                                             ; --���������λ3
      mrhis.MRCTRL4                    := NULL                                             ; --���������λ4
      mrhis.MRCTRL5                    := NULL                                             ; --���������λ5
      mrhis.MRCHKFLAG                  := 'N'                                              ; --���˱�־
      mrhis.MRCHKDATE                  := NULL                                             ; --��������
      mrhis.MRCHKPER                   := NULL                                             ; --������Ա
      mrhis.MRCHKSCODE                 := NULL                                             ; --ԭ����
      mrhis.MRCHKECODE                 := NULL                                             ; --ԭֹ��
      mrhis.MRCHKSL                    := NULL                                             ; --ԭˮ��
      mrhis.MRCHKADDSL                 := NULL                                             ; --ԭ����
      mrhis.MRCHKCARRYSL               := NULL                                             ; --ԭ��λˮ��
      mrhis.MRCHKRDATE                 := NULL                                             ; --ԭ��������
      mrhis.MRCHKFACE                  := NULL                                             ; --ԭ���
      mrhis.MRCHKRESULT                := NULL                                             ; --���������
      mrhis.MRCHKRESULTMEMO            := NULL                                             ; --�����˵��
      mrhis.MRPRIMID                   := mi.mipriid                                      ; --���ձ�����
      mrhis.MRPRIMFLAG                 := mi.mipriflag                                    ; --���ձ��־
      mrhis.MRLB                       := mi.milb                                       ; --ˮ�����
      mrhis.MRNEWFLAG                  := NULL                                             ; --�±��־
      mrhis.MRFACE2                    := NULL                                             ; --��������
      mrhis.MRFACE3                    := NULL                                             ; --�ǳ�����
      mrhis.MRFACE4                    := NULL                                             ; --����ʩ˵��
      mrhis.MRSCODECHAR                := to_char(p_scode)                                 ; --���ڳ���
      mrhis.MRECODECHAR                := to_char(p_ecode)                                ; --���ڳ���
      mrhis.MRPRIVILEGEFLAG            := 'N'                                              ; --��Ȩ��־(Y/N)
      mrhis.MRPRIVILEGEPER             := NULL                                             ; --��Ȩ������
      mrhis.MRPRIVILEGEMEMO            := NULL                                             ; --��Ȩ������ע
      mrhis.MRPRIVILEGEDATE            := NULL                                             ; --��Ȩ����ʱ��
      mrhis.MRSAFID                    := MI.MISAFID                                       ; --��������
      mrhis.MRIFTRANS                  := 'N'                                              ; --ת�칤����־
      mrhis.MRREQUISITION              := 0                                                ; --֪ͨ����ӡ����
      mrhis.MRIFCHK                    := MI.MIIFCHK                                       ; --���˱�
    insert into meterread values mrhis;
end;
/

