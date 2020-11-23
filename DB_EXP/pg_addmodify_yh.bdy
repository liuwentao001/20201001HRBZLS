CREATE OR REPLACE PACKAGE BODY PG_ADDModify_YH is
  --CurrentDate date := tools.fGetSysDate;

  --msl meter_static_log%rowtype;

  PROCEDURE AUDIT(P_BILLNO IN VARCHAR2,
                  P_PERSON IN VARCHAR2,
                  P_DJLB   IN VARCHAR2) IS
  BEGIN
    IF P_DJLB IN ('LH' ) THEN
      SP_yhadd(P_DJLB, P_BILLNO, P_PERSON, 'N');
    ELSE
      SP_yhModify(P_DJLB, P_BILLNO, P_PERSON, 'N');
    END IF; 
  
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END AUDIT;

  --立户审核（一户一表）
  PROCEDURE SP_yhadd(P_DJLB   IN VARCHAR2, --单据类型
                     P_billno IN VARCHAR2, --单据流水号
                     P_PERSON IN VARCHAR2, --审核人
                     P_COMMIT IN VARCHAR2) AS
    --是否提交
    v_CRHSHFLAG varchar2(10);
    v_yh        ys_yh_custinfo%ROWTYPE;
    v_sb        ys_yh_sbinfo%ROWTYPE;
    V_YHPID     ys_yh_custinfo%ROWTYPE;
    V_SBPID     Ys_Yh_Sbinfo%ROWTYPE;
    v_sd        ys_yh_sbdoc%ROWTYPE;
    v_sa        ys_yh_account%rowtype;
    CURSOR C_YHPID(VYHID IN VARCHAR2) IS
      SELECT *
        FROM ys_yh_custinfo
       WHERE YHID = VYHID
         AND HIRE_CODE = v_HIRE_CODE;
    CURSOR C_SBPID(VSBID IN VARCHAR2) IS
      SELECT *
        FROM Ys_Yh_Sbinfo
       WHERE YHID = VSBID
         AND HIRE_CODE = v_HIRE_CODE;
  begin
    --select  * from  ys_gd_yhsbreghd
    select nvl(max(CHECK_FLAG), '999')
      into v_CRHSHFLAG
      from ys_gd_yhsbreghd
     where bill_id = P_billno
       and HIRE_CODE = v_HIRE_CODE;
    IF v_CRHSHFLAG = '999' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END IF;
    IF v_CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF v_CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    for i in (select *
                from ys_gd_yhsbregdt
               where bill_id = P_billno
                 and HIRE_CODE = v_HIRE_CODE) loop
      v_yh.id        := uuid();
      v_yh.hire_code := v_HIRE_CODE;
      --v_yh.yhid,
      v_yh.yhconid   := i.yhconid;
      v_yh.manage_no := i.manage_no;
      v_yh.yhpid     := i.yhpid;
      --校验上级用户
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_YHPID(i.yhpid);
        FETCH C_YHPID
          INTO V_YHPID;
        IF C_YHPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_yh.yhclass := V_YHPID.yhclass + 1; --
        CLOSE C_YHPID;
      ELSE
        v_yh.yhclass := 1; --
      END IF;
    
      v_yh.yhflag        := 'Y';
      v_yh.yhname        := I.YHNAME;
      v_yh.yhname2       := I.YHNAME2;
      v_yh.yhadr         := I.YHADR;
      v_yh.yhstatus      := I.YHSTATUS;
      v_yh.yhstatusdate  := null;
      v_yh.yhstatustrans := null;
      v_yh.yhnewdate     := i.yhnewdate;
      v_yh.yhidentitylb  := i.yhidentitylb;
      v_yh.yhidentityno  := i.yhidentityno;
      v_yh.yhmtel        := i.yhmtel;
      v_yh.yhtel1        := i.yhtel1;
      v_yh.yhtel2        := i.yhtel2;
      v_yh.yhtel3        := i.yhtel3;
      v_yh.yhconnectper  := i.yhconnectper;
      v_yh.yhconnecttel  := i.yhconnecttel;
      v_yh.yhifinv       := i.yhifinv;
      v_yh.yhifsms       := i.yhifsms;
      v_yh.yhifzn        := i.yhifzn;
      v_yh.yhprojno      := i.yhprojno;
      v_yh.yhfileno      := i.yhfileno;
      v_yh.yhmemo        := i.yhmemo;
      v_yh.yhdeptid      := i.yhdeptid;
      v_yh.yhwxno        := null;
      v_sb.id            := uuid();
    
      v_sb.sbid      := nvl(i.sbid, f_get_sbid);
      v_sb.id        := i.id;
      v_sb.hire_code := i.hire_code;
      v_yh.yhid := nvl(i.yhid , v_sb.sbid );
      v_sb.yhid      := v_yh.yhid;
      -- v_sb.sbid          := i.sbid;
      v_sb.sbadr     := i.sbadr;
      v_sb.area_no   := i.area_no;
      v_sb.manage_no := i.manage_no;
      v_sb.sbprmon   := i.sbprmon;
      v_sb.sbrmon    := i.sbrmon;
      v_sb.book_no   := i.book_no;
      v_sb.sbrorder  := i.sbrorder;
      v_sb.sbpid     := i.sbpid;
      --v_sb.sbclass       := i.sbclass;
      IF v_yh.yhpid IS NOT NULL THEN
        OPEN C_SBPID(i.sbpid);
        FETCH C_SBPID
          INTO V_SBPID;
        IF C_SBPID%NOTFOUND THEN
          RAISE_APPLICATION_ERROR(ERRCODE, P_billno || '无效的上级用户');
        END IF;
        v_sb.sbclass := V_SBPID.SBclass + 1; --
        CLOSE C_SBPID;
      ELSE
        V_SBPID.sbclass := 1; --
      END IF;
      v_sb.sbflag        := i.sbflag;
      v_sb.sbrtid        := i.sbrtid;
      v_sb.sbifmp        := i.sbifmp;
      v_sb.sbifsp        := i.sbifsp;
      v_sb.trade_no      := i.trade_no;
      v_sb.price_no      := i.price_no;
      v_sb.sbstatus      := i.sbstatus;
      v_sb.sbstatusdate  := i.sbstatusdate;
      v_sb.sbstatustrans := i.sbstatustrans;
      v_sb.sbface        := i.sbface;
      v_sb.sbrpid        := i.sbrpid;
      v_sb.sbside        := i.sbside;
      v_sb.sbposition    := i.sbposition;
      v_sb.sbinscode     := i.sbinscode;
      v_sb.sbinsdate     := i.sbinsdate;
      v_sb.sbinsper      := i.sbinsper;
      v_sb.sbreinscode   := i.sbreinscode;
      v_sb.sbreinsdate   := i.sbreinsdate;
      v_sb.sbreinsper    := i.sbreinsper;
      v_sb.sbtype        := i.sbtype;
      v_sb.sbrcode       := i.sbrcode;
      v_sb.sbrecdate     := i.sbrecdate;
      v_sb.sbrecsl       := i.sbrecsl;
      v_sb.sbifcharge    := 'Y';
      v_sb.sbifsl        := i.sbifsl;
      v_sb.sbifchk       := i.sbifchk;
      v_sb.sbifwatch     := i.sbifwatch;
      v_sb.sbicno        := i.sbicno;
      v_sb.sbmemo        := i.sbmemo;
      v_sb.sbpriid       := i.sbpriid;
      v_sb.sbpriflag     := i.sbpriflag;
      v_sb.sbusenum      := i.sbusenum;
      v_sb.sbchargetype  := i.sbchargetype;
      v_sb.sbsaving      := i.sbsaving;
      v_sb.sblb          := i.sblb;
      v_sb.sbnewflag     := i.sbnewflag;
      v_sb.sbcper        := i.sbcper;
      v_sb.sbiftax       := i.sbiftax;
      v_sb.sbtaxno       := i.sbtaxno;
    
      v_sb.sbrcodechar := i.sbrcodechar;
      v_sb.sbifckf     := i.sbifckf;
      v_sb.sbgps       := i.sbgps;
      v_sb.sbqfh       := i.sbqfh;
      v_sb.sbbox       := i.sbbox;
    
      v_sb.sbname  := i.sbname;
      v_sb.sbname2 := i.sbname2;
      -- v_sb.sbseqno       := i.sbseqno;
      v_sb.sbnewdate     := i.YHNEWDATE;
      v_sb.sbuiid        := i.sbuiid;
      v_sb.sbcommunity   := i.sbcommunity;
      v_sb.sbremoteno    := i.sbremoteno;
      v_sb.sbremotehubno := i.sbremotehubno;
      v_sb.sbemail       := i.sbemail;
      v_sb.sbemailflag   := i.sbemailflag;
      v_sb.sbdbjmsl1     := i.sbdbjmsl1;
      v_sb.sbdbyhbz2     := i.sbdbyhbz2;
      v_sb.sbdbjzyf3     := i.sbdbjzyf3;
      v_sb.sbyhxz4       := i.sbyhxz4;
      --v_sb.sbpaymentid   := i.sbpaymentid;
      v_sb.sbgdsl5    := i.sbgdsl5;
      v_sb.sbftsl6    := i.sbftsl6;
      v_sb.sbxjdj7    := i.sbxjdj7;
      v_sb.sbcolumn8  := i.sbcolumn8;
      v_sb.sbyhlb9    := i.sbyhlb9;
      v_sb.sbsfqdht10 := i.sbsfqdht10;
      v_sb.sblh       := i.LH;
      v_sb.sbdyh      := i.dyh;
      v_sb.sbmph      := i.mph;
      v_sb.sbjd       := i.sbjd;
      --v_sb.sbyhpj        := i.sbyhpj;
      v_sb.sbtax := i.YHIFINV;
      --v_sb.sbifzdh       := i.sbifzdh;
      --v_sb.sbdbzjh       := i.sbdbzjh;
      --v_sb.sbdzbz1       := i.sbdzbz1;
      -- v_sb.sbmsbz2       := i.sbmsbz2;
      --v_sb.sbxkzbz3      := i.sbxkzbz3;
      --v_sb.sbsbmm4       := i.sbsbmm4;
      --v_sb.sbmmsz5       := i.sbmmsz5;
      --v_sb.sbxymm6       := i.sbxymm6;
      --v_sb.sbmszdsl7     := i.sbmszdsl7;
      --v_sb.sbyctf8       := i.sbyctf8;
      -- v_sb.sbzdzzs9      := i.sbzdzzs9;
      --v_sb.sbcbshsj10    := i.sbcbshsj10;
      --v_sb.sbjtkssj11    := i.sbjtkssj11;
      --v_sb.sbyl12        := i.sbyl12;
      --v_sb.sbjdh13       := i.sbjdh13;
      v_sb.sbtkbz11 := i.sbtkbz11;
      --v_sb.sbtkzjh       := i.sbtkzjh;
      --v_sb.sbhtbh        := i.sbhtbh;
      --v_sb.sbhtzq        := i.sbhtzq;
      --v_sb.sbrqxz        := i.sbrqxz;
      -- v_sb.htdate        := i.htdate;
      --v_sb.zfdate        := i.zfdate;
      --v_sb.jzdate        := i.jzdate;
      --v_sb.signper       := i.signper;
      --v_sb.signid        := i.signid;
      -- v_sb.pocid         := i.pocid;
      v_sd.MDNO         := i.MDNO; --
      v_sd.sbid         := v_sb.sbid;
      v_sd.id           := uuid();
      v_sd.hire_code    := v_HIRE_CODE;
      v_sd.MDCALIBER    := i.MDCALIBER; --
      v_sd.MDBRAND      := i.MDBRAND; --
      v_sd.MDMODEL      := i.MDMODEL; --
      v_sd.MDSTATUS     := i.MDSTATUS; --
      v_sd.MDSTATUSDATE := NULL; --
      v_sd.MDSTOCKDATE  := sysdate;
    
      --v_sd.BARCODE      := i.BARCODE;
      v_sd.RFID   := i.RFID;
      v_sd.IFDZSB := 'N'; --初装水表默认是正常水表，倒装走水表信息维护
      --条形码自动生成=1位区号+8位年月日+10位客户代码。 
      v_sd.BARCODE := SUBSTR(v_sb.manage_no, 4, 1) ||
                      TO_CHAR(SYSDATE, 'YYYYMMDD') || v_sb.sbid;
      v_sd.DQSFH   := i.DQSFH; --塑封号
      v_sd.DQGFH   := i.DQGFH; --钢封号
      v_sd.JCGFH   := i.JCGFH; --稽查封号
      v_sd.QFH     := i.QHF; --铅封号
    
      v_sa.id             := uuid();
      v_sa.hire_code      := v_HIRE_CODE;
      v_sa.sbid           := v_sb.sbid;
      v_sa.yhano          := i.yhano;
      v_sa.yhanoname      := i.yhanoname;
      v_sa.yhabankid      := i.YHABANKID;
      v_sa.yhaaccountno   := i.yhaaccountno;
      v_sa.yhaaccountname := i.yhaaccountname;
      v_sa.yhatsbankid    := i.yhatsbankid;
      v_sa.yhatsbankname  := i.yhatsbankname;
      v_sa.yhaifxezf      := i.yhaifxezf;
      v_sa.yharegdate     := trunc(sysdate);
      INSERT INTO ys_yh_custinfo VALUES v_yh;
      INSERT INTO ys_yh_sbinfo VALUES v_sb;
      INSERT INTO ys_yh_sbdoc VALUES v_sd;
      INSERT INTO ys_yh_account VALUES v_sa;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_yhadd;
  --立户审核（一户一表）
  PROCEDURE SP_yhModify(P_DJLB   IN VARCHAR2, --单据类型
                        P_billno IN VARCHAR2, --单据流水号
                        P_PERSON IN VARCHAR2, --审核人
                        P_COMMIT IN VARCHAR2) AS
    --是否提交
    v_CRHSHFLAG varchar2(10);
    v_yh        ys_yh_custinfo%ROWTYPE;
    v_sb        ys_yh_sbinfo%ROWTYPE;
    V_YHPID     ys_yh_custinfo%ROWTYPE;
    V_SBPID     Ys_Yh_Sbinfo%ROWTYPE;
    v_sd        ys_yh_sbdoc%ROWTYPE;
    v_sa        ys_yh_account%rowtype;
    CURSOR C_YHPID(VYHID IN VARCHAR2) IS
      SELECT *
        FROM ys_yh_custinfo
       WHERE YHID = VYHID
         AND HIRE_CODE = v_HIRE_CODE;
    CURSOR C_SBPID(VSBID IN VARCHAR2) IS
      SELECT *
        FROM Ys_Yh_Sbinfo
       WHERE YHID = VSBID
         AND HIRE_CODE = v_HIRE_CODE;
  begin
    --select  * from  ys_gd_yhsbreghd
    select nvl(max(CHECK_FLAG), '999')
      into v_CRHSHFLAG
      from ys_gd_yhsbmodifyd
     where bill_id = P_billno
       and HIRE_CODE = v_HIRE_CODE;
    IF v_CRHSHFLAG = '999' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '立户单不存在!');
    END IF;
    IF v_CRHSHFLAG = 'Y' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已审核');
    END IF;
    IF v_CRHSHFLAG = 'Q' THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '单据已取消');
    END IF;
    for i in (select *
                from ys_gd_yhsbmodifyt
               where bill_id = P_billno
                 and HIRE_CODE = v_HIRE_CODE) loop
      --更名           
      if P_DJLB = 'YHXXBG' then
        update ys_yh_custinfo
           set yhname       = i.yhname,
               yhadr        = i.yhadr,
               yhidentitylb = i.yhidentitylb,
               yhidentityno = i.yhidentityno,
               yhmtel       = i.yhmtel,
               yhtel1       = i.yhtel1,
               yhtel2       = i.yhtel2,
               yhtel3       = i.yhtel3,
               yhconnectper = i.yhconnectper,
               yhconnecttel = i.yhconnecttel,
               yhifsms      = i.yhifsms
         where yhid = i.yhid;
        update ys_yh_sbinfo
           set sbadr = i.sbadr, sbname = i.sbname, sbname2 = i.sbname2
         where sbid = i.sbid;
      end if;
    
      --过户          
      if P_DJLB = 'GH' then
        update ys_yh_custinfo
           set yhname       = i.yhname,
               yhadr        = i.yhadr,
               yhidentitylb = i.yhidentitylb,
               yhidentityno = i.yhidentityno,
               yhmtel       = i.yhmtel,
               yhtel1       = i.yhtel1,
               yhtel2       = i.yhtel2,
               yhtel3       = i.yhtel3,
               yhconnectper = i.yhconnectper,
               yhconnecttel = i.yhconnecttel,
               yhifsms      = i.yhifsms,
               yhmemo       = i.yhmemo
         where yhid = i.yhid;
        update ys_yh_sbinfo
           set sbadr = i.sbadr, sbname = i.sbname, sbname2 = i.sbname2
         where sbid = i.sbid
           AND HIRE_CODE = I.HIRE_CODE;
      end if;
    
      --水价变更    
      if P_DJLB = 'SJBG' then
      
        update ys_yh_sbinfo O
          
           set O.PRICE_NO = i.price_no
         where O.sbid = i.sbid
           AND O.HIRE_CODE = I.HIRE_CODE;
        --删除混合  
        DELETE ys_yh_pricegroup P
         WHERE P.SBID = I.SBID
           AND P.HIRE_CODE = I.HIRE_CODE;
      
        IF I.SBIFMP = 'Y' THEN
          if i.price_no1 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               1,
               i.price_no1,
               i.PMDSCALE1,
               i.PMDTYPE,
               null,
               null,
               null);
          
          end if;
           if i.price_no2 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               2,
               i.price_no2,
               i.PMDSCALE2,
               i.PMDTYPE2,
               null,
               null,
               null); 
          end if;
          if i.price_no3 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               3,
               i.price_no3,
               i.PMDSCALE3,
               i.PMDTYPE3,
               null,
               null,
               null); 
          end if;
          if i.price_no4 is not null then
            insert into ys_yh_pricegroup
              (id,
               hire_code,
               yhid,
               sbid,
               grpid,
               price_no,
               grpscale,
               grptype,
               grpcolumn1,
               grpcolumn2,
               grpcolumn3)
            values
              (uuid(),
               f_get_HIRE_CODE(),
               i.yhid,
               i.sbid,
               4,
               i.price_no4,
               i.PMDSCALE4,
               i.PMDTYPE4,
               null,
               null,
               null); 
          end if;
           update ys_yh_sbinfo O
          
           set SBIFMP = 'Y'
         where O.sbid = i.sbid
           AND O.HIRE_CODE = I.HIRE_CODE;
        ELSE
          DELETE ys_yh_pricegroup P
           WHERE P.SBID = I.SBID
             AND P.HIRE_CODE = I.HIRE_CODE;
        END IF;
      end if;
    end loop;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
  END SP_yhModify;
end;
/

