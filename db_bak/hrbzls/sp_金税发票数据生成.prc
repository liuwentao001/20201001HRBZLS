CREATE OR REPLACE PROCEDURE HRBZLS.SP_金税发票数据生成(P_INVTYPE IN VARCHAR2) IS

  GH INV_GOLDTAX%ROWTYPE;
  GD INV_GOLDTAX_DETAIL%ROWTYPE;

BEGIN

  IF P_INVTYPE = 'P' THEN
    DELETE INV_GOLDTAX;
    DELETE INV_GOLDTAX_DETAIL;
    --电子发票
    FOR R1 IN (SELECT * FROM INV_EINVOICE ORDER BY ICID) LOOP
      --插入表头信息
      GH.IVID       := R1.ICID; --开票记录ID
      GH.CNAME      := R1.GHFMC; --购方名称
      GH.CTAXCODE   := R1.GHFNSRSBH; --购方税号
      GH.CBANKACC   := R1.GHFYHZH; --购方开户行及账号
      GH.CADDRPHONE := R1.GHFDZ || ' ' || R1.GHFGDDH; --购方地址电话
      GH.SNAME      := R1.XHFMC; --销方名称
      GH.STAXCODE   := R1.XHFNSRSBH; --销方税号
      GH.SBANKACC   := R1.XHFYHZH; --销方开户行及账号
      GH.SADDRPHONE := R1.XHFDZ || ' ' || R1.XHFDH; --销方地址电话
      GH.TAXRATE    := NULL; --税率
      GH.NOTES      := R1.BZ; --备注
      GH.INVOICER   := R1.KPY; --开票人
      GH.CHECKER    := R1.FHR; --复核人
      GH.CASHIER    := R1.SKY; --收款人
      GH.ISPCISNO   := R1.ISPCISNO; --发票号
      GH.CREATEDATE := R1.KPRQ; --生成日期
      GH.KIND       := '2'; --发票种类0专用发票2普通发票
      GH.ID         := R1.ID; -- 发票流水
      INSERT INTO INV_GOLDTAX VALUES GH;
      --插入明细行信息
      FOR R2 IN (SELECT *
                   FROM INV_EINVOICE_DETAIL
                  WHERE IDID = R1.ICID
                  ORDER BY IDID, LINE) LOOP
        GD.IVID      := GH.IVID; --关联金税开票记录
        GD.LINE      := R2.LINE; --行号
        GD.GOODSNAME := R2.XMMC; --商品或劳务名称
        GD.TAXITEM   := NULL; --税目，4位数字，商品所属类别
        GD.STANDARD  := R2.GGXH; --规格型号
        GD.UNIT      := R2.XMDW; --计量单位
        GD.NUM       := R2.XMSL; --数量
        GD.PRICE     := R2.XMDJ; --单价
        GD.AMOUNT    := NVL(R2.XMJE, 0); --金额
        GD.PRICEKIND := '1'; --含税价标志，0不含税价1含税价
        GD.TAXAMOUNT := R2.SE; --税额
        GD.TAXRATE   := R2.SL; --税率
        INSERT INTO INV_GOLDTAX_DETAIL VALUES GD;
      END LOOP;
    END LOOP;
  END IF;

END SP_金税发票数据生成;
/

