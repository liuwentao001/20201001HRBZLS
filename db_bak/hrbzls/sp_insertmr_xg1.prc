CREATE OR REPLACE PROCEDURE HRBZLS."SP_INSERTMR_XG1" (p_billno varchar2,
                                              omrid out meterread.mrid%type) as   --������ˮ

  mi meterinfo%rowtype; --ˮ����Ϣ
  mr meterread%rowtype; --������ʷ��
  ci custinfo%rowtype; --�û���Ϣ
  mrs METERTRANSDT%rowtype; --������¼
begin
    begin
      select * into mrs from METERTRANSDT where mtdno=p_billno;
    exception when others then
       raise_application_error(-20010, '�˹���������!');
    end;
    begin
      select * into mi from meterinfo where miid=mrs.mtdmid;
      exception when others then
         raise_application_error(-20010, '��ˮ������!');
      end;
    begin
      select * into ci from custinfo where ciid = mi.micid;
    exception when others then
      raise_application_error(-20010, '�û�������!');
    end;
      if mrs.mtbk8='Y' then
      mr.mrID                       := fgetsequence('METERREAD')                        ; --��ˮ��
      omrid                            := mr.mrID         ;
      mr.mrMONTH                    := tools.fgetreadmonth(mi.mismfid)               ; --�����·�
      mr.mrSMFID                    := fgetmeterinfo(mi.miid,'MISMFID')                  ; --Ӫ����˾
      mr.mrBFID                     := mi.mibfid /*rth.RTHBFID*/                                      ; --���
      begin
      select  BFBATCH into mr.mrBATCH  from bookframe where bfid=mi.mibfid and bfsmfid=mi.mismfid                                      ;
      exception when others then
      mr.mrBATCH                    :=  1 ;     --��������
      end;

      begin
          select mrbsdate
          into  mr.mrDAY
          from meterreadbatch
          where mrbsmfid=mi.mismfid and
                mrbmonth=mr.mrMONTH and
                mrbbatch= mr.mrBATCH ;
        exception when others then
        mr.mrDAY                       := sysdate                                    ; --�ƻ�������
     /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
             raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
       end if;*/
      end;
      mr.mrDAY                       := sysdate                                    ; --�ƻ�������
      mr.mrRORDER                   := mi.MIRORDER                                      ; --�������
      mr.mrCID                      := CI.CIID                                       ; --�û����
      mr.mrCCODE                    := CI.CICODE                                     ; --�û���
      mr.mrMID                      := MI.MIID                                       ; --ˮ����
      mr.mrMCODE                    := MI.MICODE                                     ; --ˮ���ֹ����
      mr.mrSTID                     := mi.MISTID                                        ; --��ҵ����
      mr.mrMPID                     := mi.MIPID                                         ; --�ϼ�ˮ��
      mr.mrMCLASS                   := mi.MICLASS                                       ; --ˮ����
      mr.mrMFLAG                    := mi.MIFLAG                                        ; --ĩ����־
      mr.mrCREADATE                 := sysdate                                          ; --��������
      mr.mrINPUTDATE                := sysdate                                          ; --�༭����
      mr.mrREADOK                   := 'Y'                                              ; --������־
      mr.mrRDATE                    := mrs.mtdshdate                                    ; --��������
      mr.mrRPER                     := null                                             ; --Ԥ�� �ճ���Ա
      mr.mrPRDATE                   := null                                             ; --�ϴγ�������
      mr.mrSCODE                    := mrs.mtdscode                                          ; --���ڳ���
      mr.mrECODE                    := mrs.mtdecode                                          ; --���ڳ���
      mr.mrSL                       := mrs.mtdaddsl                                           ; --����ˮ��
      mr.mrFACE                     := '01'                                             ; --ˮ�����
      mr.mrIFSUBMIT                 := 'Y'                                              ; --�Ƿ��ύ�Ʒ�
      mr.mrIFHALT                   := 'N'                                              ; --ϵͳͣ��
      mr.mrDATASOURCE               := '1'; --��������Դ�����񳭱�
      mr.mrIFIGNOREMINSL            := 'N'                                              ; --ͣ����ͳ���
      mr.mrPDARDATE                 := NULL                                             ; --���������ʱ��
      mr.mrOUTFLAG                  := 'N'                                              ; --�������������־
      mr.mrOUTID                    := NULL                                             ; --�������������ˮ��
      mr.mrOUTDATE                  := NULL                                             ; --���������������
      mr.mrINORDER                  := NULL                                             ; --��������մ���
      mr.mrINDATE                   := NULL                                             ; --�������������
      mr.mrRPID                     := null                                             ; --�Ƽ�����
      mr.mrMEMO                     := '���񳭱�'                                     ; --����ע
      mr.mrIFGU                     := 'N'                                              ; --�����־
      mr.mrIFREC                    := 'N'                                              ; --�ѼƷ�
      mr.mrRECDATE                  := SYSDATE                                          ; --�Ʒ�����
      mr.mrRECSL                    := mrs.mtdaddsl                                        ; --Ӧ��ˮ��
      mr.mrADDSL                    := 0                                                                                  ; --����
      mr.mrCARRYSL                  := 0                                                ; --��λˮ��
      mr.mrCTRL1                    := NULL                                             ; --���������λ1
      mr.mrCTRL2                    := NULL                                             ; --���������λ2
      mr.mrCTRL3                    := NULL                                             ; --���������λ3
      mr.mrCTRL4                    := NULL                                             ; --���������λ4
      mr.mrCTRL5                    := NULL                                             ; --���������λ5
      mr.mrCHKFLAG                  := 'N'                                              ; --���˱�־
      mr.mrCHKDATE                  := NULL                                             ; --��������
      mr.mrCHKPER                   := NULL                                             ; --������Ա
      mr.mrCHKSCODE                 := NULL                                             ; --ԭ����
      mr.mrCHKECODE                 := NULL                                             ; --ԭֹ��
      mr.mrCHKSL                    := NULL                                             ; --ԭˮ��
      mr.mrCHKADDSL                 := NULL                                             ; --ԭ����
      mr.mrCHKCARRYSL               := NULL                                             ; --ԭ��λˮ��
      mr.mrCHKRDATE                 := NULL                                             ; --ԭ��������
      mr.mrCHKFACE                  := NULL                                             ; --ԭ���
      mr.mrCHKRESULT                := NULL                                             ; --���������
      mr.mrCHKRESULTMEMO            := NULL                                             ; --�����˵��
      mr.mrPRIMID                   := mi.mipriid                                      ; --���ձ�����
      mr.mrPRIMFLAG                 := mi.mipriflag                                    ; --���ձ��־
      mr.mrLB                       := mi.milb                                       ; --ˮ�����
      mr.mrNEWFLAG                  := NULL                                             ; --�±��־
      mr.mrFACE2                    := NULL                                             ; --��������
      mr.mrFACE3                    := NULL                                             ; --�ǳ�����
      mr.mrFACE4                    := NULL                                             ; --����ʩ˵��
      mr.mrSCODECHAR                := to_char(mrs.mtdscode )                                 ; --���ڳ���
      mr.mrECODECHAR                := to_char(mrs.mtdecode )                                ; --���ڳ���
      mr.mrPRIVILEGEFLAG            := 'N'                                              ; --��Ȩ��־(Y/N)
      mr.mrPRIVILEGEPER             := NULL                                             ; --��Ȩ������
      mr.mrPRIVILEGEMEMO            := NULL                                             ; --��Ȩ������ע
      mr.mrPRIVILEGEDATE            := NULL                                             ; --��Ȩ����ʱ��
      mr.mrSAFID                    := MI.MISAFID                                       ; --��������
      mr.mrIFTRANS                  := 'N'                                              ; --ת�칤����־
      mr.mrREQUISITION              := 0                                                ; --֪ͨ����ӡ����
      mr.mrIFCHK                    := MI.MIIFCHK                                       ; --���˱�
      mr.mrbfday                    := 0;
    insert into meterread values mr;
    end if;
end;
/

