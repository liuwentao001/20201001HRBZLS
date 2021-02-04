CREATE OR REPLACE PROCEDURE HRBZLS.SP_��˰��ƱԤ��(P_INVTYPE IN VARCHAR2) IS

  CURSOR C_GH IS
    SELECT * FROM INV_GOLDTAX;

  CURSOR C_GD(AS_ID IN VARCHAR2) IS
    SELECT * FROM INV_GOLDTAX_DETAIL WHERE IVID = AS_ID;

  GH     INV_GOLDTAX%ROWTYPE;
  GD     INV_GOLDTAX_DETAIL%ROWTYPE;
  INV    INV_GOLDTAX_TEMP%ROWTYPE;
  VROW   NUMBER := 0;
  VDJ    NUMBER;
  VJE    NUMBER(13, 3) := 0;
  VSE    NUMBER(13, 3) := 0;
  VJES   NUMBER(13, 3) := 0;
  VSES   NUMBER(13, 3) := 0;
  G_��˰ BOOLEAN := FALSE;

BEGIN

  OPEN C_GH;
  LOOP
    FETCH C_GH
      INTO GH;
    EXIT WHEN C_GH%NOTFOUND OR C_GH%NOTFOUND IS NULL;

    INV            := NULL;
    VJES           := 0;
    VSES           := 0;
    VROW           := VROW + 1;
    INV.ID         := VROW; -- ���
    INV.CNAME      := GH.CNAME; -- ��������
    INV.CTAXCODE   := GH.CTAXCODE; -- ����˰��
    INV.CADDRPHONE := GH.CADDRPHONE; --������ַ�绰
    INV.CBANKACC   := GH.CBANKACC; -- ���������м��˺�

    OPEN C_GD(GH.IVID);
    LOOP
      FETCH C_GD
        INTO GD;
      EXIT WHEN C_GD%NOTFOUND OR C_GD%NOTFOUND IS NULL;
      VDJ := 0;
      VJE := 0;
      VSE := 0;

      INV.GOODSNAME := INV.GOODSNAME || GD.GOODSNAME || CHR(10); --��Ʒ����������
      INV.STANDARD  := INV.STANDARD || GD.STANDARD || CHR(10); --����ͺ�
      INV.UNIT      := INV.UNIT || GD.UNIT || CHR(10); --������λ
      IF P_INVTYPE = 'P' THEN
        --���ӷ�Ʊ˰�ʴ�����С��
        GD.TAXRATE := GD.TAXRATE * 100;
        G_��˰     := FALSE;
      ELSE
        --רƱ���ĺ�˰����
        GD.TAXRATE := GD.TAXRATE;
        G_��˰     := TRUE;
      END IF;

      IF G_��˰ THEN
        --Ԥ��˰Ʊ��ϸ��ˮ������Ϊ��
        IF NVL(GD.NUM, 0) <> 0 THEN
          INV.NUM := INV.NUM || GD.NUM || CHR(10); --����
          --���㵥��
          VDJ       := ROUND(GD.AMOUNT / ((100 + GD.TAXRATE) / 100) /
                             GD.NUM,
                             10);
          INV.PRICE := INV.PRICE || VDJ || CHR(10); --����
        END IF;
        --������
        VJE         := ROUND(GD.AMOUNT / ((100 + GD.TAXRATE) / 100), 2);
        INV.AMOUNT  := INV.AMOUNT || TOOLS.FFORMATNUM(VJE, 2) || CHR(10); --���
        INV.TAXRATE := INV.TAXRATE || GD.TAXRATE || '%' || CHR(10); --˰��
        --����˰��
        VSE           := GD.AMOUNT - VJE;
        INV.TAXAMOUNT := INV.TAXAMOUNT || TOOLS.FFORMATNUM(VSE, 2) ||
                         CHR(10); --˰��
      ELSE
        INV.NUM       := INV.NUM || GD.NUM || CHR(10); --����
        INV.PRICE     := INV.PRICE || GD.PRICE || CHR(10); --����
        VJE           := GD.AMOUNT;
        INV.AMOUNT    := INV.AMOUNT || TOOLS.FFORMATNUM(VJE, 2) || CHR(10); --���
        INV.TAXRATE   := INV.TAXRATE || GD.TAXRATE || '%' || CHR(10); --˰��
        VSE           := GD.TAXAMOUNT;
        INV.TAXAMOUNT := INV.TAXAMOUNT || TOOLS.FFORMATNUM(VSE, 2) ||
                         CHR(10); --˰��
      END IF;
      VJES := VJES + VJE;
      VSES := VSES + VSE;
    END LOOP;
    CLOSE C_GD;

    INV.JEHJ       := TOOLS.FFORMATNUM(VJES, 2); --�ϼƽ��
    INV.SEHJ       := TOOLS.FFORMATNUM(VSES, 2); --�ϼ�˰��
    INV.JSHJ       := TOOLS.FFORMATNUM(VJES + VSES, 2); --��˰�ϼ�
    INV.SNAME      := GH.SNAME; --��������
    INV.STAXCODE   := GH.STAXCODE; --����˰��
    INV.SADDRPHONE := GH.SADDRPHONE; --������ַ�绰
    INV.SBANKACC   := GH.SBANKACC; --���������м��˺�
    INV.TAXNOTES   := GH.NOTES; --��ע
    INV.INVOICER   := GH.INVOICER; --��Ʊ��
    INV.CHECKER    := GH.CHECKER; --������
    INV.CASHIER    := GH.CASHIER; --�տ���
    IF INSTR(GH.ISPCISNO, 'EWIDE') > 0 THEN
      INV.ISPCISNO := 'EWIDE.' || TO_CHAR(VROW, '00000000');
    ELSE
      INV.ISPCISNO := GH.ISPCISNO; --��Ʊ��
    END IF;
    INV.KIND      := GH.KIND; --��Ʊ����0ר�÷�Ʊ2��ͨ��Ʊ
    INV.INVPRDATE := GH.CREATEDATE; --��Ʊ����

    --�����¼
    INSERT INTO INV_GOLDTAX_TEMP VALUES INV;

  END LOOP;
  CLOSE C_GH;

END SP_��˰��ƱԤ��;
/

