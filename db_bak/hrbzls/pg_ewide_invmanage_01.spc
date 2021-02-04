CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_INVMANAGE_01" IS

  --Ʊ�ݹ���
  ERRCODE CONSTANT INTEGER := -20012;

  ---------------------------------------------------------------------------------------------

  --�ܲ���� zhangrong
  PROCEDURE HQINSTORE(P_IITYPE     IN CHAR, --Ʊ������
                      P_IIRECEIVER IN VARCHAR2, --��ȡ��Ա
                      P_IISMFID    IN VARCHAR2, --��ⵥλ
                      P_IIBCNO     IN VARCHAR2, --����
                      P_IISNO      IN VARCHAR2, --���
                      P_IIENO      IN VARCHAR2 --ֹ��
                      );

  --�ֳܲ��� zhangrong
  PROCEDURE HQOUTSTORE(P_IOTYPE   IN CHAR, --Ʊ������
                       P_IOSENDER IN VARCHAR2, --������Ա
                       P_IOSMFID  IN VARCHAR2, --���ⵥλ
                       P_IOBCNO   IN VARCHAR2, --����
                       P_IOSNO    IN VARCHAR2, --���
                       P_IOENO    IN VARCHAR2 --ֹ��
                       );

  --Ʊ�����
  PROCEDURE INSTORE(P_IITYPE     IN CHAR, --Ʊ������
                    P_IISENDER   IN VARCHAR2, --�ɷ���Ա
                    P_IIRECEIVER IN VARCHAR2, --��ȡ��Ա
                    P_IISMFID    IN VARCHAR2, --��ⵥλ
                    P_IIBCNO     IN VARCHAR2, --����
                    P_IISNO      IN VARCHAR2, --���
                    P_IIENO      IN VARCHAR2); --ֹ��

  --Ʊ�ݳ���
  PROCEDURE OUTSTORE(P_IOTYPE     IN CHAR, --Ʊ������
                     P_IOSENDER   IN VARCHAR2, --�ɷ���Ա
                     P_IORECEIVER IN VARCHAR2, --������Ա
                     P_IOSMFID    IN VARCHAR2, --���ⵥλ
                     P_IOBCNO     IN VARCHAR2, --����
                     P_IOSNO      IN VARCHAR2, --���
                     P_IOENO      IN VARCHAR2); --ֹ��

  --��¼��ӡƱ��
  PROCEDURE RECINVNO(P_ILNO     IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                     P_ILRLID   IN VARCHAR2, --Ӧ����ˮ(###|###|)
                     P_ILRDPIID IN VARCHAR2, --������Ŀ(###|###|)
                     P_ILJE     IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                     P_ILTYPE   IN CHAR, --Ʊ������
                     P_ILCD     IN CHAR, --�������
                     P_ILPER    IN VARCHAR2, --��Ʊ��
                     P_ILSTATUS IN CHAR, --Ʊ��״̬
                     P_ILSMFID  IN VARCHAR2 --�ֹ�˾
                     );

  --Ʊ���ս�
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR); --Ʊ������

  --Ʊ���ս�_�ֶ�ִ��
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR, BALDATE VARCHAR2); --Ʊ������

  PROCEDURE CANCEL(P_ICPER   IN VARCHAR2, --Ʊ��������
                   P_ICSMFID IN VARCHAR2, --���ϵ�λ
                   P_ICTYPE  IN CHAR, --Ʊ������
                   P_ICNO    IN VARCHAR2 --Ʊ�ݱ��
                   );
  --��������ˮ
  --ȡ��
  FUNCTION FGETINVNO(P_PER    IN VARCHAR2, --����
                     P_IITYPE IN VARCHAR2, --��Ʊ����
                     P_SNO    IN NUMBER --��Ʊ����
                     ) RETURN NUMBER;
  --��������ˮ
  --ȡ����Ҫʹ�÷�Ʊ��
  FUNCTION FGETINVNO_STR(P_PER    IN VARCHAR2, --����Ա
                         P_IITYPE IN VARCHAR2 --��Ʊ����
                         ) RETURN VARCHAR2;
  --��������ԱƱ����Ϣ
  FUNCTION FGETHADINV(P_PER IN VARCHAR2 --����Ա  p_iitype in varchar2 --��Ʊ����
                      ) RETURN VARCHAR2;
  --��������ԱƱ����Ϣ[ts]
  FUNCTION FGETHADINVTS(P_PER IN VARCHAR2 --����Ա
                        
                        ) RETURN VARCHAR2;

  --��������ˮ
  --ȡ����Ҫʹ�÷�Ʊ�Ŵ��������Ự����
  FUNCTION FGETINVNO_TEMP(P_PER    IN VARCHAR2, --����Ա
                          P_IITYPE IN VARCHAR2, --��Ʊ����
                          P_COUNT  IN NUMBER, --Ҫȡ��Ʊ����
                          P_SNO    IN NUMBER) RETURN NUMBER;

  --��������ˮ
  --ȡ�Ự���� ��Ʊ��
  FUNCTION FGETINVNO_FROMTEMP(P_I IN NUMBER --�ڼ��ŷ�Ʊ
                              
                              ) RETURN NUMBER;
  --��������ˮ
  --ȡ���÷�Ʊ������
  FUNCTION FGETINVCOUNT(P_PER    IN VARCHAR2, --����Ա
                        P_IITYPE IN VARCHAR2 --��Ʊ����
                        ) RETURN NUMBER;
  --��¼��ӡƱ�� ����
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE RECINVNO_EZ(P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                        P_ILNO        IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                        P_ILRLID      IN VARCHAR2, --Ӧ����ˮ(###|###|)
                        P_ILRDPIID    IN VARCHAR2, --������Ŀ(###|###|)
                        P_ILJE        IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                        P_ILTYPE      IN CHAR, --Ʊ������
                        P_ILCD        IN CHAR, --�������
                        P_ILPER       IN VARCHAR2, --��Ʊ��
                        P_ILSTATUS    IN CHAR, --Ʊ��״̬
                        P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                        P_TRANS       IN VARCHAR2, --����
                        P_ISZZS       IN VARCHAR2 --��ֵ˰
                        );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE SP_FCHARGEINVREG(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER --��Ʊ��ˮ
                             );
  --��������ˮ
  --��鷢Ʊ�Ƿ񹻴�
  FUNCTION FCHKINVFULL(P_PER    IN VARCHAR2, --����Ա
                       P_IITYPE IN VARCHAR2, --��Ʊ����
                       P_TYPE   IN VARCHAR2, --��ˮ�����
                       P_ID     IN VARCHAR2 --��ˮ��
                       ) RETURN NUMBER --�����Ƿ�Ʊ����
  ;
  --��Ʊ״̬����
  PROCEDURE SP_CANCEL_HADPRINTNO(P_PER    IN VARCHAR2, --����Ա
                                 P_TYPE   IN VARCHAR2, --��Ʊ���
                                 P_STATUS IN VARCHAR2, --����״̬
                                 P_ID     IN VARCHAR2, --��ˮ��
                                 P_MODE   IN VARCHAR2, --��ˮ�����
                                 O_FLAG   OUT VARCHAR2 --����ֵ
                                 );
  FUNCTION FGETINVDWDETAILSTR(P_ID IN NUMBER) RETURN VARCHAR2;
  --ɾ����Ʊ
  PROCEDURE SP_INVMANG_DELETE(P_ISNOSTART   VARCHAR2, --��Ʊ���
                              P_ISNOEND     VARCHAR2, --��Ʊֹ��
                              P_ISBCNO      VARCHAR2, --��Ʊ����
                              P_ISSTATUSPER VARCHAR2, --״̬�����
                              P_MEMO        VARCHAR2, --��ע
                              MSG           OUT VARCHAR2);
  --�޸ķ�Ʊ״̬
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_ISNOSTART   VARCHAR2, --��Ʊ���
                                    P_ISNOEND     VARCHAR2, --��Ʊֹ��
                                    P_ISBCNO      VARCHAR2, --���κ�
                                    P_ISSTATUSPER VARCHAR2, --״̬�����Ա
                                    P_STATUS      NUMBER, --״̬2
                                    P_MEMO        VARCHAR2, --��ע
                                    MSG           OUT VARCHAR2);
  --��Ʊת��
  PROCEDURE SP_INVMANG_ZLY(P_ISNOSTART   VARCHAR2, --��Ʊ���
                           P_ISNOEND     VARCHAR2, --��Ʊֹ��
                           P_ISBCNO      VARCHAR2, --���κ�
                           P_ISSTATUSPER VARCHAR2, --������Ա
                           P_STATUS      NUMBER, --״̬0
                           P_MEMO        VARCHAR2, --��ע
                           MSG           OUT VARCHAR2);

  --�޸ķ�Ʊ
  PROCEDURE SP_INVMANG_MODIFYINV(P_ISNOSTART   VARCHAR2, --��Ʊ���
                                 P_ISNOEND     VARCHAR2, --��Ʊֹ��
                                 P_ISBCNO      VARCHAR2, --���κ�
                                 P_ISSTATUSPER VARCHAR2, --״̬�����Ա
                                 P_TYPE        VARCHAR2, --״̬2
                                 P_NUM         VARCHAR2, --��ע
                                 MSG           OUT VARCHAR2);

  --��Ʊ����                                 
  PROCEDURE SP_SPTZ(P_ISBCNO      IN VARCHAR2, --���κ�
                    P_MINSOURCENO IN VARCHAR2,
                    P_MAXSOURCENO IN VARCHAR2,
                    P_MINDESTNO   IN VARCHAR2, --����Ŀ�귢Ʊ��ʼ��
                    P_MAXDESTNO   IN VARCHAR2, --����Ŀ��ԭ��Ʊ��ֹ��
                    P_TYPE        IN VARCHAR2); -- FPDT ��Ʊ�Ե�  FPTH ��Ʊ����                                 

  --������Ʊ
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --���κ�
                           P_ISPER     VARCHAR2, --��Ʊ��
                           P_ISTYPE    VARCHAR2, --��Ʊ���
                           P_ISNOSTART VARCHAR2, --��Ʊ���
                           P_ISNOEND   VARCHAR2, --��Ʊֹ��
                           P_OUTPER    VARCHAR2, --����Ʊ����
                           MSG         OUT VARCHAR2);

  --��Ʊ��⡢�ַ������á��˻�
  PROCEDURE SP_STOCK(P_ISBCNO    VARCHAR2, --���κ�
                     P_ISSTOCKDO VARCHAR2, --�ֿ����
                     P_ISSMFID   VARCHAR2, --�ֿ�
                     P_ISPER     VARCHAR2, --��Ʊ��
                     P_ISTYPE    VARCHAR2, --��Ʊ���
                     P_ISNOSTART VARCHAR2, --��Ʊ���
                     P_ISNOEND   VARCHAR2, --��Ʊֹ��
                     P_OUTPER    VARCHAR2, --����Ʊ����
                     MSG         OUT VARCHAR2);

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE SP_CHARGEINV(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                         P_ID          IN VARCHAR2, --ʵ������
                         P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                         P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                         P_ILTYPE      IN VARCHAR2, --Ʊ������
                         P_PRINTER     IN VARCHAR2, --��ӡԱ
                         P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                         P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                         P_ISPRINTCD   IN VARCHAR2, --�����
                         P_SNO         IN NUMBER --��ʼ��Ʊ��
                         );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE SP_CHARGEINV_BAK(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER --��Ʊ��ˮ
                             );

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_H_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --��ʼ��Ʊ��
                                );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_H_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --��ʼ��Ʊ��
                                 );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                             P_ID          IN VARCHAR2, --ʵ������
                             P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                             P_ILTYPE      IN VARCHAR2, --Ʊ������
                             P_PRINTER     IN VARCHAR2, --��ӡԱ
                             P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                             P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                             P_ISPRINTCD   IN VARCHAR2, --�����
                             P_SNO         IN NUMBER --��ʼ��Ʊ��
                             );

  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F_TS(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_F_ZS(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --Ʊ����ˮ
                                );
  --���մ�ӡ
  PROCEDURE SP_CHARGEINV_1_F_HSB(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --Ʊ����ˮ
                                 );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_G_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --��ʼ��Ʊ��
                                );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_G_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --��ʼ��Ʊ��
                                 );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_Z_SF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                P_ID          IN VARCHAR2, --ʵ������
                                P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                P_ILTYPE      IN VARCHAR2, --Ʊ������
                                P_PRINTER     IN VARCHAR2, --��ӡԱ
                                P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                P_ISPRINTCD   IN VARCHAR2, --�����
                                P_SNO         IN NUMBER --��ʼ��Ʊ��
                                );
  --�ɷѼ�Ʊ��(��̨)
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid,7:������ˮ mrid
  PROCEDURE SP_CHARGEINV_1_Z_WSF(P_IFFPHP      IN VARCHAR2, --F��ƱH��Ʊ
                                 P_ID          IN VARCHAR2, --ʵ������
                                 P_PIID        IN VARCHAR2, --������Ŀ 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                                 P_ILTYPE      IN VARCHAR2, --Ʊ������
                                 P_PRINTER     IN VARCHAR2, --��ӡԱ
                                 P_ILSTATUS    IN VARCHAR2, --Ʊ��״̬
                                 P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                                 P_ISPRINTCD   IN VARCHAR2, --�����
                                 P_SNO         IN NUMBER --��ʼ��Ʊ��
                                 );
  --ISPRINTTYPE ��ӡ��ʽ 1:ʵ�մ�ӡ����pbatch��2:ʵ��pID3:ʵ����ϸ:plid��4:ʵ��pdid+pdpiid,5:Ӧ����ˮrlid,6:ʵ����ϸrdid+rdpiid
  PROCEDURE RECINVNO(P_ISPRINTTYPE IN VARCHAR2, --��ӡ��ʽ
                     P_ILNO        IN VARCHAR2, --Ʊ�ݺ���(###|###|)
                     P_ILRLID      IN VARCHAR2, --Ӧ����ˮ(###|###|)
                     P_ILRDPIID    IN VARCHAR2, --������Ŀ(###|###|)
                     P_ILJE        IN VARCHAR2, --Ʊ�ݽ��(###|###|)
                     P_ILTYPE      IN CHAR, --Ʊ������
                     P_ILCD        IN CHAR, --�������
                     P_ILPER       IN VARCHAR2, --��Ʊ��
                     P_ILSTATUS    IN CHAR, --Ʊ��״̬
                     P_ILSMFID     IN VARCHAR2, --�ֹ�˾
                     P_TRANS       IN VARCHAR2, --����
                     P_ISZZS       IN VARCHAR2 --��ֵ˰
                     );
  --�����Զ����Ϸ�Ʊ
  PROCEDURE SP_CANCEL(P_PER    IN VARCHAR2, --����Ա
                      P_TYPE   IN VARCHAR2, --��Ʊ���
                      P_STATUS IN VARCHAR2, --����״̬
                      P_ID     IN VARCHAR2, --��ˮ��
                      P_MODE   IN VARCHAR2, --��ˮ�����
                      O_FLAG   OUT VARCHAR2 --����ֵ
                      );
  --������Ʊ�����޸�
  PROCEDURE SP_SNO_MODEFY_FP(P_OLDISBCO IN VARCHAR2, --ԭ����
                             P_OLDISNO  IN VARCHAR2, --ԭ����
                             P_NEWISBCO IN VARCHAR2, --����״̬
                             P_NEWISNO  IN VARCHAR2, --��ˮ��
                             P_TYPE     IN VARCHAR2, --��ˮ��
                             P_OPER     IN VARCHAR2, --��ˮ�����
                             O_FLAG     OUT VARCHAR2 --����ֵ
                             );
  --��֯��Ʊ����
  PROCEDURE SWAP_TO_INV(P_TYPE   IN VARCHAR2,
                        P_BATCH  IN VARCHAR2,
                        P_PBATCH IN OUT VARCHAR2);

  --�ж��û��Ƿ�Ϊ�Ⳮ��                      
  FUNCTION fgetmeterstatus(P_CODE IN VARCHAR2 --�û���
                           ) RETURN VARCHAR2;

  --��̨��Ʊ��ӡ��ϸ
  FUNCTION fgetinvdeatil_gt(P_BATCH IN VARCHAR2, --���κ�
                            P_TYPE  IN VARCHAR2, --����
                            P_ROW   IN NUMBER --����  
                            ) RETURN VARCHAR2;

  --���մ�ӡ��ϸ����
  FUNCTION fgetinvdeatil_zs(P_RLIDLIST IN VARCHAR2, --Ӧ����ˮ��
                            P_TYPE     IN VARCHAR2, --����
                            P_ROW      IN NUMBER --����  
                            ) RETURN VARCHAR2;
  --��ȡ���ջ���                    
  FUNCTION fgethscode(P_MIID IN VARCHAR2 --�ͻ�����  
                      ) RETURN varchar2;

  --��ȡ�û�ԭˮ�˱�ʶ��                   
  FUNCTION fgetcltno(P_MIID IN VARCHAR2 --�ͻ�����  
                     ) RETURN VARCHAR2;

  --��ȡ��ע��Ϣ                  
  FUNCTION fgetinvmemo(P_RLID IN VARCHAR2, --Ӧ����ˮ
                       P_TYPE IN VARCHAR2 --��ע����
                       ) RETURN VARCHAR2;

  --��ȡ�û����˿��ţ�����+������ţ�                   
  FUNCTION fgetnewcardno(P_MIID IN VARCHAR2 --�ͻ�����  
                         ) RETURN VARCHAR2;

  --���뷢Ʊ��עrlinvmemo                 
  FUNCTION fgettranslate(P_RLTRANS   IN VARCHAR2, --Ӧ������
                         P_RLINVMEMO IN VARCHAR2 -- ��Ʊ��ע
                         ) RETURN VARCHAR2;

  --��ȡһ�������ĩԤ�����        
  FUNCTION fgethsqmsaving(P_MIID IN VARCHAR2 --�ͻ�����  
                          ) RETURN VARCHAR2;

  --��Ʊ��ӡ��ϸ(һ�����)
  FUNCTION fgethsinvdeatil(P_MIID IN VARCHAR2 --�ͻ�����  
                           ) RETURN VARCHAR2;

  PROCEDURE SP_CHEQUE(P_BATCH    IN VARCHAR2, --�շ����κ� 
                      P_CODE     IN VARCHAR2, --�ͻ�����
                      P_SMFID    IN VARCHAR2, --Ӫҵ��
                      P_OPER     IN VARCHAR2, --�շ�Ա
                      P_STATUS   IN VARCHAR2, --֧Ʊ״̬
                      P_NO       IN VARCHAR2, --֧Ʊ��
                      P_BANKNAME IN VARCHAR2, --��������
                      P_BANKID   IN VARCHAR2, --�к�
                      P_BANKNO   IN VARCHAR2, --�����˺�
                      P_CWDH     IN VARCHAR2, --���񵥺�
                      P_TYPE     IN VARCHAR2 --��������
                      );

  PROCEDURE sp_������(P_ID   IN VARCHAR2, --���˵���ˮ
                    P_OPER IN VARCHAR2 --�ʽ���Դ
                    );

  PROCEDURE sp_������Ʊ(P_ID    IN VARCHAR2, --���˵���ˮ
                    P_SMFID IN VARCHAR, --Ӫҵ��
                    P_OPER  IN VARCHAR2 --��Ʊ��
                    );

  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --��Ʊ���κ�
                                P_ISNO  IN VARCHAR2 --��Ʊ��
                                );

  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --��Ʊ���κ�
                              P_ISNO   IN VARCHAR2, --��Ʊ��
                              P_STATUS NUMBER);

end;
/

