CREATE OR REPLACE PACKAGE BODY "PG_RAEDPLAN" IS

  -- 月终
  --TIME 2020-12-22  BY WL
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2, --P_SMFID 营业所,售水公司
                            P_MONTH  IN VARCHAR2, --P_MONTH 当前月份
                            P_COMMIT IN VARCHAR2) IS
    --P_COMMIT 提交标志
    V_TEMPMONTH VARCHAR2(7);
    V_ZZMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := TOOLS.FGETREADMONTH(P_SMFID);
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '月终月份异常,请检查!');
    END IF;
    --更新上期抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_TEMPMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000005';
    --月份加一
    V_ZZMONTH := TO_CHAR(ADD_MONTHS(TO_DATE(V_TEMPMONTH || '.01',
                                            'yyyy.mm.dd'),
                                    1),
                         'yyyy.mm');
    --更新抄表月份
    UPDATE SYSMANAPARA
       SET SMPPVALUE = V_ZZMONTH
     WHERE SMPID = P_SMFID
       AND SMPPID = '000009';
    --将抄表数据转入到历史抄表库
    INSERT INTO BS_METERREAD_HIS
      (SELECT MRID,
              MRMONTH,
              MRSMFID,
              MRBFID,
              MRBATCH,
              MRDAY,
              MRRORDER,
              MRCCODE,
              MRMID,
              MRSTID,
              MRMPID,
              MRMCLASS,
              MRMFLAG,
              MRCREADATE,
              MRINPUTDATE,
              MRREADOK,
              MRRDATE,
              MRRPER,
              MRPRDATE,
              MRSCODE,
              MRECODE,
              MRSL,
              MRFACE,
              MRIFSUBMIT,
              MRIFHALT,
              MRDATASOURCE,
              '' MRPDARDATE,
              '' MROUTFLAG,
              '' MROUTID,
              '' MROUTDATE,
              '' MRINORDER,
              '' MRINDATE,
              MRMEMO,
              MRIFGU,
              MRIFREC,
              MRRECDATE,
              MRRECSL,
              MRADDSL,
              '' MRCTRL1,
              '' MRCTRL2,
              '' MRCTRL3,
              '' MRCTRL4,
              '' MRCTRL5,
              MRCARRYSL,
              MRCHKFLAG,
              MRCHKDATE,
              MRCHKPER,
              '' MRCHKSCODE,
              '' MRCHKECODE,
              '' MRCHKSL,
              '' MRCHKADDSL,
              '' MRCHKRDATE,
              '' MRCHKFACE,
              MRCHKRESULT,
              MRCHKRESULTMEMO,
              MRPRIMID,
              MRPRIMFLAG,
              MRFACE2,
              '' MRSCODECHAR,
              '' MRECODECHAR,
              '' MRIFTRANS,
              MRREQUISITION,
              MRIFCHK,
              MRINPUTPER,
              MRPFID,
              MRCALIBER,
              MRSIDE,
              MRLASTSL,
              MRTHREESL,
              MRYEARSL,
              MRRECJE01,
              MRRECJE02,
              MRRECJE03,
              MRRECJE04,
              MRNULLCONT,
              MRNULLTOTAL,
              MRBFSDATE,
              MRBFEDATE,
              MRBFDAY,
              MRIFMCH,
              MRIFZBSM,
              MRIFYSCZ,
              MRDZSL,
              MRDZFLAG,
              MRDZSYSCODE,
              MRDZCURCODE,
              MRDZTGL,
              MRZKH,
              MRSFFS
         FROM BS_METERREAD T
        WHERE T.MRSMFID = P_SMFID
          AND T.MRMONTH = P_MONTH);
  
    --删除当前抄表库信息
    DELETE BS_METERREAD T
     WHERE T.MRSMFID = P_SMFID
       AND T.MRMONTH = P_MONTH;
  
    /*    --历史均量计算
    UPDATEMRSLHIS(P_SMFID, P_MONTH);*/
    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '月终失败' || SQLERRM);
  END;
END;
/

