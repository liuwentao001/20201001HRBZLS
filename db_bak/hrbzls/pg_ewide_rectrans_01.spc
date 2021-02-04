CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RECTRANS_01" IS

  -- Author  : ADMINISTRATOR
  -- Created : 2011-10-16
  -- Purpose : WANGYONG

  -- Public type declarations
  CURRENTDATE DATE;

  -- Public constant declarations
  ERRCODE CONSTANT INTEGER := -20012;

  -- Public function and procedure declarations
  --�����ύ��ڹ���
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --׷���շ� V --����ԭ�� ׷���շ�
  PROCEDURE SP_RECTRANS102(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --׷���շ� V --����ԭ�� ������ �������󣬲����ֹ��
  PROCEDURE SP_RECTRANS103(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --��ʱ��ˮˮ������
  PROCEDURE SP_RECTRANS104(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2);

  --׷�ղ��볭��ƻ�����ʷ�� ����ԭ��
  PROCEDURE SP_INSERTMRHIS(RTH         IN RECTRANSHD%ROWTYPE, --׷��ͷ
                           P_MRIFTRANS IN VARCHAR2, --������������
                           MI          IN METERINFO%ROWTYPE, --ˮ����Ϣ
                           OMRID       OUT METERREADHIS.MRID%TYPE --������ˮ
                           );
  --׷�ղ��볭��ƻ�  by lgb
  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --׷��ͷ
                        P_MRIFTRANS IN VARCHAR2, --������������
                        MI          IN METERINFO%ROWTYPE, --ˮ����Ϣ
                        OMRID       OUT METERREAD.MRID%TYPE);
  --Ӧ�ճ��������� BY WANGYONG DATE 20111014
  --   ��鵥�Ƿ������
  --FORѭ������ÿһ����������ϸ
  --��鵥�Ƿ�����˹���
  --�����ᣬֱ��·��
  --���ѻ�����������
  --�������������
  --��û����˵���ϸ�������
  --  ����    sp_reccz_one_01

  --ѭ���������������־
  --�ж��ύ��־�����ΪY�ύ COMMIT
  --������쳣�׳��쳣
  PROCEDURE SP_RECCZ(P_BILLNO IN VARCHAR2, --���ݱ��
                     P_PER    IN VARCHAR2, --�����
                     P_MEMO   IN VARCHAR2, --��ע
                     P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                     );

  --���뵥��Ӧ��   �� Ӧ�ճ�������  ��sp_reccz_one_01��   ���ʹ��    BY WANGYONG     DATE 20111014

  PROCEDURE SP_RECCZ_INSERT_01(RCCH     IN RECCZHD%ROWTYPE, --RECCZHT �б���
                               RCCD     IN RECCZDT%ROWTYPE, --RECCZDT �б���
                               RLDE     IN OUT RECLIST%ROWTYPE, --reclist Ӧ��
                               RLCR     IN OUT RECLIST%ROWTYPE, --reclist Ӧ��
                               P_TRANS  IN RECLIST.RLTRANS%TYPE, --Ӧ������
                               P_PER    IN VARCHAR2, --�����
                               P_MEMO   IN VARCHAR2, --��ע
                               P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                               )
  --������Ӧ�ղ���Ϣ�����ɶ�Ӧ�ĸ�Ӧ��

  ;

  PROCEDURE SP_RECCZ_ONE_01(P_RLID     IN RECLIST.RLID%TYPE, --RECCZHT �б���
                               P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                               );

  function sp_recfzsl(p_rlid in VARCHAR2, --������ˮ
                      p_rlje    in number --���ʽ��
                     ) return number ;

  --�����˷�
  --1�������ʣ���ʵ�գ��˿ +��Ӧ�� +��Ӧ�� +��Ӧ��
  --2��δ���ʣ���Ӧ�� +��Ӧ��
  PROCEDURE SP_PAIDRECBACK(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --Ӧ�յ�����׷��/׷����
  PROCEDURE RECADJUST(RAH   IN RECADJUSTHD%ROWTYPE,
                      RAD   IN RECADJUSTDT%ROWTYPE,
                      P_PER IN VARCHAR2,
                      RLCR  OUT RECLIST%ROWTYPE,
                      RLDE  OUT RECLIST%ROWTYPE);

  PROCEDURE RECBACK(P_RLID       IN VARCHAR2,
                    P_RDPIIDLIST IN VARCHAR2,
                    P_TRANS      IN VARCHAR2,
                    P_PER        IN VARCHAR2,
                    P_MEMO       IN VARCHAR2,
                    RLCR         OUT RECLIST%ROWTYPE);

  PROCEDURE SP_���˵�(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2);

    /*PROCEDURE SP_RECFZRLID(P_RLID IN VARCHAR2,  --������ˮ
                         P_SL   IN NUMBER     --����ˮ��

                               );*/

  PROCEDURE �����������(P_RCHSMFID   IN VARCHAR2, --Ӫҵ��
                   P_RCHDEPT    IN VARCHAR2, -- ��������
                   P_RCHCREPER  IN VARCHAR2, --������Ա
                   P_RCHCREDATE IN VARCHAR2, --��������
                   P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                   P_RCHNO      IN OUT VARCHAR2, --������ݺ�
                   P_COMMIT     IN VARCHAR2 --�ύ��־
                   );
  PROCEDURE ����׷������(P_RTHSMFID   IN VARCHAR2, --Ӫҵ��
                   P_RTHDEPT    IN VARCHAR2, -- ��������
                   P_RTHCREPER  IN VARCHAR2, --������Ա
                   P_RTHCREDATE IN VARCHAR2, --��������
                   P_RL         RECLIST%ROWTYPE, --Ӧ����Ϣ
                   P_RTHNO      IN OUT VARCHAR2, --������ݺ�
                   P_COMMIT     IN VARCHAR2, --�ύ��־
                   P_MEMO       IN VARCHAR2);
  PROCEDURE SP_�����˷�(P_BILLNO IN VARCHAR2, --���ݱ��
                    P_PER    IN VARCHAR2, --�����
                    P_MEMO   IN VARCHAR2, --��ע
                    P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                    );
  PROCEDURE SP_�����(P_BILLNO IN VARCHAR2, --���ݱ��
                   P_PER    IN VARCHAR2, --�����
                   P_MEMO   IN VARCHAR2, --��ע
                   P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                   );
      --add by lgb 2013-09-09
  PROCEDURE SP_�����˷�NEW(P_RAHNO  IN VARCHAR2, --���ݱ��
                       P_PER    IN VARCHAR2, --�����
                       P_COMMIT IN VARCHAR --�Ƿ��ύ��־
                       );

  ---ʵ�ճ���
  PROCEDURE SP_PAIDBAK(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  PROCEDURE SP_�ޱ����;

    --׷���շ� V --����ԭ�� ׷���շ�
  PROCEDURE SP_Ԥ�����(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

      --׷���շ� V --����ԭ�� ׷���շ�
  PROCEDURE SP_Ԥ���˷�(P_NO IN VARCHAR2, P_PER IN VARCHAR2);
END;
/

