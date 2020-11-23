CREATE OR REPLACE PACKAGE Pg_Arznj_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_Arznj_01
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��11��
  ----------------------------------------------------------------------
  -- Description: ΥԼ��������̰�
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- �޸���ʷ:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   �      ����
  --====================================================================*/

  --�����ύ��ڹ���
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --���ⵥ��
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --������ˮ
                       p_Per     IN VARCHAR2, --����Ա
                       p_Commit  IN VARCHAR2 --�ύ��־;
                       );
END;
/

