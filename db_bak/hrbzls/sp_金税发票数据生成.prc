CREATE OR REPLACE PROCEDURE HRBZLS.SP_��˰��Ʊ��������(P_INVTYPE IN VARCHAR2) IS

  GH INV_GOLDTAX%ROWTYPE;
  GD INV_GOLDTAX_DETAIL%ROWTYPE;

BEGIN

  IF P_INVTYPE = 'P' THEN
    DELETE INV_GOLDTAX;
    DELETE INV_GOLDTAX_DETAIL;
    --���ӷ�Ʊ
    FOR R1 IN (SELECT * FROM INV_EINVOICE ORDER BY ICID) LOOP
      --�����ͷ��Ϣ
      GH.IVID       := R1.ICID; --��Ʊ��¼ID
      GH.CNAME      := R1.GHFMC; --��������
      GH.CTAXCODE   := R1.GHFNSRSBH; --����˰��
      GH.CBANKACC   := R1.GHFYHZH; --���������м��˺�
      GH.CADDRPHONE := R1.GHFDZ || ' ' || R1.GHFGDDH; --������ַ�绰
      GH.SNAME      := R1.XHFMC; --��������
      GH.STAXCODE   := R1.XHFNSRSBH; --����˰��
      GH.SBANKACC   := R1.XHFYHZH; --���������м��˺�
      GH.SADDRPHONE := R1.XHFDZ || ' ' || R1.XHFDH; --������ַ�绰
      GH.TAXRATE    := NULL; --˰��
      GH.NOTES      := R1.BZ; --��ע
      GH.INVOICER   := R1.KPY; --��Ʊ��
      GH.CHECKER    := R1.FHR; --������
      GH.CASHIER    := R1.SKY; --�տ���
      GH.ISPCISNO   := R1.ISPCISNO; --��Ʊ��
      GH.CREATEDATE := R1.KPRQ; --��������
      GH.KIND       := '2'; --��Ʊ����0ר�÷�Ʊ2��ͨ��Ʊ
      GH.ID         := R1.ID; -- ��Ʊ��ˮ
      INSERT INTO INV_GOLDTAX VALUES GH;
      --������ϸ����Ϣ
      FOR R2 IN (SELECT *
                   FROM INV_EINVOICE_DETAIL
                  WHERE IDID = R1.ICID
                  ORDER BY IDID, LINE) LOOP
        GD.IVID      := GH.IVID; --������˰��Ʊ��¼
        GD.LINE      := R2.LINE; --�к�
        GD.GOODSNAME := R2.XMMC; --��Ʒ����������
        GD.TAXITEM   := NULL; --˰Ŀ��4λ���֣���Ʒ�������
        GD.STANDARD  := R2.GGXH; --����ͺ�
        GD.UNIT      := R2.XMDW; --������λ
        GD.NUM       := R2.XMSL; --����
        GD.PRICE     := R2.XMDJ; --����
        GD.AMOUNT    := NVL(R2.XMJE, 0); --���
        GD.PRICEKIND := '1'; --��˰�۱�־��0����˰��1��˰��
        GD.TAXAMOUNT := R2.SE; --˰��
        GD.TAXRATE   := R2.SL; --˰��
        INSERT INTO INV_GOLDTAX_DETAIL VALUES GD;
      END LOOP;
    END LOOP;
  END IF;

END SP_��˰��Ʊ��������;
/

