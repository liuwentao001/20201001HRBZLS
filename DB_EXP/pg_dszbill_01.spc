CREATE OR REPLACE PACKAGE Pg_Dszbill_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: PG_DSZBILL_01
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: �����˹��̰�
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/
  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --������ˮ��
                     p_Dshlb     IN VARCHAR2, --�������
                     p_Dshsmfid  IN VARCHAR2, --Ӫ����˾
                     p_Dshdept   IN VARCHAR2, --������
                     p_Dshcreper IN VARCHAR2 --������Ա
                     );
  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --������ˮ��
                     p_Dsdrowno IN VARCHAR2, --�к�
                     p_Arid     IN VARCHAR2 --Ӧ����ˮ
                     );

  -----------------------------------------------------
  --��������ʵ���
  --�ⲿ���ã���Ӧ����ˮ��YS_ZW_AARIST.ARID��ǰ̨���뵽��ʱ��PBPARMTEMP.C1��
  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --������ˮ��
                          p_Dshlb     IN VARCHAR2, --�������
                          p_Dshsmfid  IN VARCHAR2, --Ӫ����˾
                          p_Dshdept   IN VARCHAR2, --������
                          p_Dshcreper IN VARCHAR2, --������Ա
                          p_Arid      IN VARCHAR2 --Ӧ����ˮ��
                          );

  --ɾ������
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --���ݱ��
                       p_Person IN VARCHAR2, --����Ա
                       p_Djlb   IN VARCHAR2); --�������

  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --������ˮ
                         p_Per      IN VARCHAR2, --����Ա
                         p_Billid   IN VARCHAR2, --����ID
                         p_Billtype IN VARCHAR2 --�������
                         );
  --���������
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --������ˮ
                     p_Per      IN VARCHAR2, --����Ա
                     p_Billtype IN VARCHAR2, --�������
                     p_Commit   IN VARCHAR2 --�ύ��־
                     );
END;
/

