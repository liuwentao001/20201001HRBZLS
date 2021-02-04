CREATE OR REPLACE PROCEDURE HRBZLS.SP_金税发票预览(P_INVTYPE IN VARCHAR2) IS

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
  G_含税 BOOLEAN := FALSE;

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
    INV.ID         := VROW; -- 序号
    INV.CNAME      := GH.CNAME; -- 购方名称
    INV.CTAXCODE   := GH.CTAXCODE; -- 购方税号
    INV.CADDRPHONE := GH.CADDRPHONE; --购方地址电话
    INV.CBANKACC   := GH.CBANKACC; -- 购方开户行及账号

    OPEN C_GD(GH.IVID);
    LOOP
      FETCH C_GD
        INTO GD;
      EXIT WHEN C_GD%NOTFOUND OR C_GD%NOTFOUND IS NULL;
      VDJ := 0;
      VJE := 0;
      VSE := 0;

      INV.GOODSNAME := INV.GOODSNAME || GD.GOODSNAME || CHR(10); --商品或劳务名称
      INV.STANDARD  := INV.STANDARD || GD.STANDARD || CHR(10); --规格型号
      INV.UNIT      := INV.UNIT || GD.UNIT || CHR(10); --计量单位
      IF P_INVTYPE = 'P' THEN
        --电子发票税率传的是小数
        GD.TAXRATE := GD.TAXRATE * 100;
        G_含税     := FALSE;
      ELSE
        --专票传的含税数据
        GD.TAXRATE := GD.TAXRATE;
        G_含税     := TRUE;
      END IF;

      IF G_含税 THEN
        --预存税票明细行水量单价为空
        IF NVL(GD.NUM, 0) <> 0 THEN
          INV.NUM := INV.NUM || GD.NUM || CHR(10); --数量
          --计算单价
          VDJ       := ROUND(GD.AMOUNT / ((100 + GD.TAXRATE) / 100) /
                             GD.NUM,
                             10);
          INV.PRICE := INV.PRICE || VDJ || CHR(10); --单价
        END IF;
        --计算金额
        VJE         := ROUND(GD.AMOUNT / ((100 + GD.TAXRATE) / 100), 2);
        INV.AMOUNT  := INV.AMOUNT || TOOLS.FFORMATNUM(VJE, 2) || CHR(10); --金额
        INV.TAXRATE := INV.TAXRATE || GD.TAXRATE || '%' || CHR(10); --税率
        --计算税额
        VSE           := GD.AMOUNT - VJE;
        INV.TAXAMOUNT := INV.TAXAMOUNT || TOOLS.FFORMATNUM(VSE, 2) ||
                         CHR(10); --税额
      ELSE
        INV.NUM       := INV.NUM || GD.NUM || CHR(10); --数量
        INV.PRICE     := INV.PRICE || GD.PRICE || CHR(10); --单价
        VJE           := GD.AMOUNT;
        INV.AMOUNT    := INV.AMOUNT || TOOLS.FFORMATNUM(VJE, 2) || CHR(10); --金额
        INV.TAXRATE   := INV.TAXRATE || GD.TAXRATE || '%' || CHR(10); --税率
        VSE           := GD.TAXAMOUNT;
        INV.TAXAMOUNT := INV.TAXAMOUNT || TOOLS.FFORMATNUM(VSE, 2) ||
                         CHR(10); --税额
      END IF;
      VJES := VJES + VJE;
      VSES := VSES + VSE;
    END LOOP;
    CLOSE C_GD;

    INV.JEHJ       := TOOLS.FFORMATNUM(VJES, 2); --合计金额
    INV.SEHJ       := TOOLS.FFORMATNUM(VSES, 2); --合计税额
    INV.JSHJ       := TOOLS.FFORMATNUM(VJES + VSES, 2); --价税合计
    INV.SNAME      := GH.SNAME; --销方名称
    INV.STAXCODE   := GH.STAXCODE; --销方税号
    INV.SADDRPHONE := GH.SADDRPHONE; --销方地址电话
    INV.SBANKACC   := GH.SBANKACC; --销方开户行及账号
    INV.TAXNOTES   := GH.NOTES; --备注
    INV.INVOICER   := GH.INVOICER; --开票人
    INV.CHECKER    := GH.CHECKER; --复核人
    INV.CASHIER    := GH.CASHIER; --收款人
    IF INSTR(GH.ISPCISNO, 'EWIDE') > 0 THEN
      INV.ISPCISNO := 'EWIDE.' || TO_CHAR(VROW, '00000000');
    ELSE
      INV.ISPCISNO := GH.ISPCISNO; --发票号
    END IF;
    INV.KIND      := GH.KIND; --发票种类0专用发票2普通发票
    INV.INVPRDATE := GH.CREATEDATE; --开票日期

    --插入记录
    INSERT INTO INV_GOLDTAX_TEMP VALUES INV;

  END LOOP;
  CLOSE C_GH;

END SP_金税发票预览;
/

