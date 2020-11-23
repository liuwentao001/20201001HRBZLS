CREATE OR REPLACE PACKAGE Pg_Arsplit_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_ARSPLIT_01
  -- Author:  � Gary 190388857@qq.com    date: 2020��11��14��
  ----------------------------------------------------------------------
  -- Description: ����˵����̰�
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
  --����˵�����
  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --������ˮ
                       p_Per     IN VARCHAR2, --����Ա
                       p_Commit  IN VARCHAR2 --�ύ��־;
                       );
   --����˵�����
  PROCEDURE Sp_Arsplit_change_one(p_Arsplitdt   IN Ys_Gd_Arsplitdt%rowTYPE,  
                       p_Per     IN VARCHAR2, --����Ա
                       p_Commit  IN VARCHAR2 --�ύ��־;
                       ); 
                                           
  --���뵥��Ӧ����Ӧ�ճ���  --����                     
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, -- �б���
                            p_Commit IN VARCHAR --�Ƿ��ύ��־
                            );
  
  --Ӧ�շ��˴���  
  --����Ӧ����ˮ�����ʽ�
  --���ط���ˮ��
  --1��ˮ���˵��۷�
  --2�ֵ�����һ��ˮΪֹ
  --3�Ӹ�ˮ���������ˮ��Ϊ1��Ϊֹ
  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --������ˮ
                      p_Arje IN NUMBER --���ʽ��
                      ) RETURN NUMBER;

END;
/

