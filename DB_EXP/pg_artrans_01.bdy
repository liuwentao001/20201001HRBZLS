CREATE OR REPLACE PACKAGE BODY Pg_Artrans_01 IS

   
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2) IS
  BEGIN
    IF p_Djlb IN ('O', 'T', '6', 'N', '13', '14', '21', '23') THEN
      Sp_Rectrans(p_Billno, p_Person); --追量
    ELSIF p_Djlb = 'G' THEN 
      RecAdjust(p_Billno, p_Person, '', 'Y'); --调整减免   
    ELSIF p_Djlb = '12' THEN
      Sp_Paidbak(p_Billno, p_Person); --实收冲正 
    END IF;
  END;
  --追量收费 V --保持原有 追量收费
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2) AS
    CURSOR c_Dt IS
      SELECT * FROM Ys_Gd_Aradddt WHERE Bill_Id = p_No FOR UPDATE;
  
    CURSOR c_Ys_Yh_Custinfo(Vcid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Custinfo WHERE Yhid = Vcid;
  
    CURSOR c_Ys_Yh_Sbinfo(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbinfo WHERE Sbid = Vmid FOR UPDATE NOWAIT;
  
    CURSOR c_Ys_Yh_Sbdoc(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Sbdoc WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Yh_Account(Vmid IN VARCHAR2) IS
      SELECT * FROM Ys_Yh_Account WHERE Sbid = Vmid;
  
    CURSOR c_Ys_Bas_Book(Vbook_No IN VARCHAR2) IS
      SELECT * FROM Ys_Bas_Book WHERE Book_No = Vbook_No;
  
    CURSOR c_Picount IS
      SELECT DISTINCT Nvl(t.Item_Type, 1) FROM Bas_Price_Item t;
  
    CURSOR c_Pi(Vpigroup IN NUMBER) IS
      SELECT * FROM Bas_Price_Item t WHERE t.Item_Type = Vpigroup;
    Rth    Ys_Gd_Araddhd%ROWTYPE;
    Rtd    Ys_Gd_Aradddt%ROWTYPE;
    Ci     Ys_Yh_Custinfo%ROWTYPE;
    Mi     Ys_Yh_Sbinfo%ROWTYPE;
    Bf     Ys_Bas_Book%ROWTYPE;
    Md     Ys_Yh_Sbdoc%ROWTYPE;
    Ma     Ys_Yh_Account%ROWTYPE;
    Rl     Ys_Zw_Arlist%ROWTYPE;
    Rl1    Ys_Zw_Arlist%ROWTYPE;
    Rd     Ys_Zw_Ardetail%ROWTYPE;
    p_Piid VARCHAR2(4000);
  
    v_Rlfzcount NUMBER(10);
    v_Rlfirst   NUMBER(10);
    v_Pigroup   Bas_Price_Item.Item_Type%TYPE;
    Rdtab       Pg_Cb_Cost.Rd_Table;
    Pi          Bas_Price_Item%ROWTYPE;
    Mr          Ys_Cb_Mtread%ROWTYPE;
    v_Pv        NUMBER(10);
    v_Count     NUMBER := 0;
    v_Temp      NUMBER := 0;
  BEGIN
  
    BEGIN
      SELECT * INTO Rth FROM Ys_Gd_Araddhd WHERE Bill_No = p_No;
    EXCEPTION
      WHEN OTHERS THEN
        Raise_Application_Error(Errcode, '单据不存在!');
    END;
    --月末最后一天不能进行追量，稽查，补缴，产生应收，避免账务月份跨月
    IF Trunc(SYSDATE) = Last_Day(Trunc(SYSDATE, 'MONTH')) AND
       Rth.Bill_Type IN ('O', '13', '21') THEN
      Raise_Application_Error(Errcode, '当前为出账日，不能做此业务');
    END IF;
    IF Rth.Check_Flag = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已审核');
    END IF;
    IF Rth.Check_Flag = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消');
    END IF;
    IF Rth.Bill_Type = '13' THEN
      SELECT COUNT(*)
        INTO v_Count
        FROM Ys_Cb_Mtread
       WHERE Yhid = Rth.User_No
         AND Cbmrreadok = 'Y'
         AND Nvl(Cbmrifrec, 'N') = 'N'; -- by ralph 20150213 增加补缴审核时对是否抄见未算费的判断
      IF v_Count > 0 THEN
        Raise_Application_Error(Errcode,
                                '此用户存在已抄见未算费记录！不可以补缴审核!');
      END IF;
    END IF;
    --
    OPEN c_Ys_Yh_Custinfo(Rth.User_No);
    FETCH c_Ys_Yh_Custinfo
      INTO Ci;
    IF c_Ys_Yh_Custinfo%NOTFOUND OR c_Ys_Yh_Custinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此用户');
    END IF;
    CLOSE c_Ys_Yh_Custinfo;
  
    OPEN c_Ys_Yh_Sbinfo(Rth.User_No);
    FETCH c_Ys_Yh_Sbinfo
      INTO Mi;
    IF c_Ys_Yh_Sbinfo%NOTFOUND OR c_Ys_Yh_Sbinfo%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此水表');
    END IF;
  
    OPEN c_Ys_Yh_Sbdoc(Rth.User_No);
    FETCH c_Ys_Yh_Sbdoc
      INTO Md;
    IF c_Ys_Yh_Sbdoc%NOTFOUND OR c_Ys_Yh_Sbdoc%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此水表档案');
    END IF;
    CLOSE c_Ys_Yh_Sbdoc;
  
    OPEN c_Ys_Yh_Account(Rth.User_No);
    FETCH c_Ys_Yh_Account
      INTO Ma;
    IF c_Ys_Yh_Account%NOTFOUND OR c_Ys_Yh_Account%NOTFOUND IS NULL THEN
      --raise_application_error(errcode,'无此水表帐务');
      NULL;
    END IF;
    CLOSE c_Ys_Yh_Account;
  
    OPEN c_Ys_Bas_Book(Rth.Book_No);
    FETCH c_Ys_Bas_Book
      INTO Bf;
    IF c_Ys_Bas_Book%NOTFOUND OR c_Ys_Bas_Book%NOTFOUND IS NULL THEN
      Raise_Application_Error(Errcode, '无此表册');
      NULL;
    END IF;
    CLOSE c_Ys_Bas_Book;
  
    /*--byj add 2016.4.5 如果是(稽查补缴 补收 追量),要判断是否有未完结的 换表工单 、用水性质变更工单、撤表退费、销户工单 、预存退费工单  ----------
    if RTH.BILL_TYPE in ('21','13','O' ) then
       --判断是否有未完结的用水性质变更工单
       select count(*) into v_count
         from custchangehd hd,
              custchangedt dt
        where hd.cchno = dt.ccdno and
              hd.cchlb = 'E' and
              dt.YHID = mi.micid and
              hd.CCHSHFLAG = 'N';
       if v_count > 0 then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【水价变更】工单,不能进行审核!');
       end if;
       --判断是否有故障换表
       if mi.mistatus = '24' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【故障换表】工单,不能进行审核!');
       elsif mi.mistatus = '35' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【周期换表】工单,不能进行审核!');
       elsif mi.mistatus = '36' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存退费】工单,不能进行审核!');
       elsif mi.mistatus = '39' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【预存撤表退费】工单,不能进行审核!');
       elsif mi.mistatus = '19' then
          RAISE_APPLICATION_ERROR(ERRCODE, '此用户有未完结的【销户】工单,不能进行审核!');
       end if;
       --如果修改水表指针,要判断审核时的指针是否与建立工单时一致
       if rth.rthecodeflag = 'Y' then
          if rth.rthscode <> mi.mircode then
             RAISE_APPLICATION_ERROR(ERRCODE, '此水表的止码自工单保存后已经变更,请核查!');
          end if;
          \*稽查审核时,如果当月有抄表计划已上传但未算费,提示不能审核!!! (可以算费完成时) *\
          if RTH.rthlb = '21' \*稽查补收*\ then
             begin
               select 1 into v_temp
                 from ys_cb_mtread mr
                where mr.mrmid = mi.SBID and
                      mr.MRREADOK in ('X','Y') and
                      mr.mrifrec = 'N' and
                      rownum < 2;
             exception
               when no_data_found then
                 v_temp := 0;
             end;
             if v_temp > 1 then
                RAISE_APPLICATION_ERROR(ERRCODE, '水表编号【' || mi.micid ||  '】本月已有抄表数据上传但未算费的记录,请核查!');
             end if;
          end if;
       end if;
    end if;*/
    --end!!!
  
    -----单头处理开始
  
    -- 预先赋值
    Rth.Check_Per  := p_Per;
    Rth.Check_Date := Currentdate;
  
    /*******处理追量信息*****/
    IF 1 = 1 THEN
      --是否走算费过程(不走可认为营业外)  
      --插入抄表库
      Pg_Artrans_01.Sp_Insertmr(Rth, TRIM(Rth.Bill_Type), Mi, Rl.Armrid);
    
      IF Rl.Armrid IS NOT NULL THEN
        SELECT * INTO Mr FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        IF Rth.If_Rechis = 'Y' THEN
          IF Rth.Price_Ver IS NULL THEN
            Raise_Application_Error(Errcode, '归档价格版本不能为空！');
          END IF;
          SELECT COUNT(*)
            INTO v_Pv
            FROM Bas_Price_Version
           WHERE Price_Ver = Rth.Price_Ver;
          IF v_Pv = 0 THEN
            Raise_Application_Error(Errcode, '该月份水价未归档！');
          END IF;
          --是否按历史水价算费(选择归档价格版本)
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), TO_CHAR(RTH.PRICEMONTH, 'yyyy.mm'));*/
          Pg_Cb_Cost.Costculate(Rl.Armrid, '0'); -- 无历史归档水价计费过程，先用当前计费过程
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        ELSE
          /*  pg_cb_cost.CALCULATE(MR, TRIM(RTH.RTHLB), '0000.00');*/ -- 无历史归档水价计费过程，先用当前计费过程
          Pg_Cb_Cost.Costculate(Rl.Armrid, '0');
          INSERT INTO Ys_Cb_Mtreadhis
            SELECT * FROM Ys_Cb_Mtread WHERE Id = Rl.Armrid;
        
          DELETE Ys_Cb_Mtread WHERE Id = Rl.Armrid;
          SELECT * INTO Rl FROM Ys_Zw_Arlist WHERE Armrid = Rl.Armrid;
        END IF;
        IF Rth.Ecode_Flag = 'Y' THEN
          UPDATE Ys_Yh_Sbinfo
             SET Sbrcode = Rth.Read_Ecode, Sbrcodechar = Rth.Read_Ecode
          --miface     = mr.mrface,
           WHERE CURRENT OF c_Ys_Yh_Sbinfo;
        
        END IF;
      END IF;
    END IF;
    UPDATE Ys_Gd_Araddhd
       SET Check_Date = Currentdate,
           Check_Per  = p_Per,
           --  CHECK_PER  = rthcreper ,
           Check_Flag = 'Y'
     WHERE Bill_Id = p_No;
  
    --处理起码的问题(由于算费的时候没有考虑到是否更新止码的问题)
    IF Rth.Ecode_Flag = 'N' THEN
      UPDATE Ys_Yh_Sbinfo
         SET Sbrcode     = Rth.Read_Ecode,
             Sbrcodechar = Rth.Read_Ecode,
             Sbnewflag   = 'N'
      --miface     = mr.mrface,
       WHERE CURRENT OF c_Ys_Yh_Sbinfo;
    END IF;
  
    CLOSE c_Ys_Yh_Sbinfo;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      Raise_Application_Error(Errcode, SQLERRM);
  END;
  -----------------------------------
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE) AS
    --抄表流水
    Mr Ys_Cb_Mtread%ROWTYPE; --抄表历史库
  BEGIN
    Mr.Id        := Uuid(); --流水号
    Omrid        := Mr.Id;
    Mr.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --抄表月份
    Mr.Manage_No := Rth.Manage_No; --营销公司
    Mr.Book_No   := Rth.Book_No; --表册
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mr.Cbmrbatch, Mr.Cbmrrper --抄表批次,抄表员
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mr.Cbmrbatch := 1; --抄表批次
        Mr.Cbmrrper  := 'system';
    END;
    Mr.Cbmrrorder := Mi.Sbrorder; --,抄表次序号
    Mr.Yhid       := Mi.Yhid; --用户编号
  
    Mr.Sbid := Mi.Sbid; --水表编号
  
    Mr.Trade_No          := Mi.Trade_No; --行业分类
    Mr.Sbpid             := Mi.Sbpid; --上级水表
    Mr.Cbmrmclass        := Mi.Sbclass; --水表级次
    Mr.Cbmrmflag         := Mi.Sbflag; --末级标志
    Mr.Cbmrcreadate      := SYSDATE; --创建日期
    Mr.Cbmrinputdate     := NULL; --编辑日期
    Mr.Cbmrreadok        := 'Y'; --抄见标志
    Mr.Cbmrrdate         := Rth.Read_Date; --抄表日期
    Mr.Cbmrprdate        := Rth.Pread_Date; --上次抄见日期(取上次有效抄表日期)
    Mr.Cbmrscode         := Rth.Read_Scode; --上期抄见
    Mr.Cbmrscodechar     := Rth.Read_Scode; --上期抄见char
    Mr.Cbmrecode         := Rth.Read_Ecode; --本期抄见
    Mr.Cbmrsl            := Rth.Read_Water; --本期水量
    Mr.Cbmrface          := NULL; --表况
    Mr.Cbmrifsubmit      := 'Y'; --是否提交计费
    Mr.Cbmrifhalt        := 'N'; --系统停算
    Mr.Cbmrdatasource    := 'Z'; --抄表结果来源
    Mr.Cbmrifignoreminsl := 'Y'; --停算最低抄量
    Mr.Cbmrpdardate      := NULL; --抄表机抄表时间
    Mr.Cbmroutflag       := 'N'; --发出到抄表机标志
    Mr.Cbmroutid         := NULL; --发出到抄表机流水号
    Mr.Cbmroutdate       := NULL; --发出到抄表机日期
    Mr.Cbmrinorder       := NULL; --抄表机接收次序
    Mr.Cbmrindate        := NULL; --抄表机接受日期
    Mr.Cbmrrpid          := Mi.Sbrpid; --计件类型
    Mr.Cbmrmemo          := NULL; --抄表备注
    Mr.Cbmrifgu          := 'N'; --估表标志
    Mr.Cbmrifrec         := 'N'; --已计费
    Mr.Cbmrrecdate       := NULL; --计费日期
    Mr.Cbmrrecsl         := NULL; --应收水量
    /*        --取未用余量
    sp_fetchaddingsl(mr.cbmrid , --抄表流水
                     sb.sbid,--水表号
                     v_tempnum,--旧表止度
                     v_tempnum,--新表起度
                     v_addsl ,--余量
                     v_date,--创建日期
                     v_tempstr,--加调事务
                     v_ret  --返回值
                     ) ;
    mr.cbmraddsl         :=   v_addsl ;  --余量   */
    Mr.Cbmraddsl         := 0; --余量
    Mr.Cbmrcarrysl       := NULL; --进位水量
    Mr.Cbmrctrl1         := NULL; --抄表机控制位1
    Mr.Cbmrctrl2         := NULL; --抄表机控制位2
    Mr.Cbmrctrl3         := NULL; --抄表机控制位3
    Mr.Cbmrctrl4         := NULL; --抄表机控制位4
    Mr.Cbmrctrl5         := NULL; --抄表机控制位5
    Mr.Cbmrchkflag       := 'N'; --复核标志
    Mr.Cbmrchkdate       := NULL; --复核日期
    Mr.Cbmrchkper        := NULL; --复核人员
    Mr.Cbmrchkscode      := NULL; --原起数
    Mr.Cbmrchkecode      := NULL; --原止数
    Mr.Cbmrchksl         := NULL; --原水量
    Mr.Cbmrchkaddsl      := NULL; --原余量
    Mr.Cbmrchkcarrysl    := NULL; --原进位水量
    Mr.Cbmrchkrdate      := NULL; --原抄见日期
    Mr.Cbmrchkface       := NULL; --原表况
    Mr.Cbmrchkresult     := NULL; --检查结果类型
    Mr.Cbmrchkresultmemo := NULL; --检查结果说明
    Mr.Cbmrprimid        := Mi.Sbpriid; --合收表主表
    Mr.Cbmrprimflag      := Mi.Sbpriflag; --  合收表标志
    Mr.Cbmrlb            := Mi.Sblb; -- 水表类别
    Mr.Cbmrnewflag       := Mi.Sbnewflag; -- 新表标志
    Mr.Cbmrface2         := NULL; --抄见故障
    Mr.Cbmrface3         := NULL; --非常计量
    Mr.Cbmrface4         := NULL; --表井设施说明
  
    Mr.Cbmrprivilegeflag := 'N'; --特权标志(Y/N)
    Mr.Cbmrprivilegeper  := NULL; --特权操作人
    Mr.Cbmrprivilegememo := NULL; --特权操作备注
    Mr.Area_No           := Mi.Area_No; --管理区域
    Mr.Cbmriftrans       := 'N'; --转单标志
    Mr.Cbmrrequisition   := 0; --通知单打印次数
    Mr.Cbmrifchk         := Mi.Sbifchk; --考核表标志
    Mr.Cbmrinputper      := NULL; --入账人员
    Mr.Price_No          := Mi.Price_No; --用水类别
    --mr.cbmrcaliber       := md.mdcaliber;--口径
    Mr.Cbmrside  := Mi.Sbside; --表位
    Mr.Cbmrmtype := Mi.Sbtype; --表型
  
    Mr.Cbmrplansl   := 0; --计划水量
    Mr.Cbmrplanje01 := 0; --计划水费
    Mr.Cbmrplanje02 := 0; --计划污水处理费
    Mr.Cbmrplanje03 := 0; --计划水资源费
  
    INSERT INTO Ys_Cb_Mtread VALUES Mr;
  EXCEPTION
    WHEN OTHERS THEN
      --OMRID := '';
      Raise_Application_Error(Errcode, '数据库错误!' || SQLERRM);
  END;
-----------------------------------------------------------
  --追收插入抄表计划到历史库
  PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE)  AS
    --抄表流水
    Mrhis Ys_Cb_Mtreadhis%ROWTYPE; --抄表历史库
  BEGIN
    Mrhis.Id        := Uuid(); --流水号
    Omrid           := Mrhis.Id;
    Mrhis.Cbmrmonth := Fobtmanapara(Rth.Manage_No, 'READ_MONTH'); --抄表月份
    Mrhis.Manage_No := Rth.Manage_No; --营销公司
    Mrhis.Book_No   := Rth.Book_No; --表册
    BEGIN
      SELECT Read_Batch, Read_Per
        INTO Mrhis.Cbmrbatch, Mrhis.Cbmrrper --抄表批次,抄表员
        FROM Ys_Bas_Book
       WHERE Book_No = Mi.Book_No
         AND Manage_No = Mi.Manage_No;
    EXCEPTION
      WHEN OTHERS THEN
        Mrhis.Cbmrbatch := 1; --抄表批次
        Mrhis.Cbmrrper  := 'system';
    END;
    Mrhis.Cbmrrorder := Mi.Sbrorder; --,抄表次序号
    Mrhis.Yhid       := Mi.Yhid; --用户编号
  
    Mrhis.Sbid := Mi.Sbid; --水表编号
  
    Mrhis.Trade_No          := Mi.Trade_No; --行业分类
    Mrhis.Sbpid             := Mi.Sbpid; --上级水表
    Mrhis.Cbmrmclass        := Mi.Sbclass; --水表级次
    Mrhis.Cbmrmflag         := Mi.Sbflag; --末级标志
    Mrhis.Cbmrcreadate      := SYSDATE; --创建日期
    Mrhis.Cbmrinputdate     := NULL; --编辑日期
    Mrhis.Cbmrreadok        := 'Y'; --抄见标志
    Mrhis.Cbmrrdate         := Rth.Read_Date; --抄表日期
    Mrhis.Cbmrprdate        := Rth.Pread_Date; --上次抄见日期(取上次有效抄表日期)
    Mrhis.Cbmrscode         := Rth.Read_Scode; --上期抄见
    Mrhis.Cbmrscodechar     := Rth.Read_Scode; --上期抄见char
    Mrhis.Cbmrecode         := Rth.Read_Ecode; --本期抄见
    Mrhis.Cbmrsl            := Rth.Read_Water; --本期水量
    Mrhis.Cbmrface          := NULL; --表况
    Mrhis.Cbmrifsubmit      := 'Y'; --是否提交计费
    Mrhis.Cbmrifhalt        := 'N'; --系统停算
    Mrhis.Cbmrdatasource    := 'Z'; --抄表结果来源
    Mrhis.Cbmrifignoreminsl := 'Y'; --停算最低抄量
    Mrhis.Cbmrpdardate      := NULL; --抄表机抄表时间
    Mrhis.Cbmroutflag       := 'N'; --发出到抄表机标志
    Mrhis.Cbmroutid         := NULL; --发出到抄表机流水号
    Mrhis.Cbmroutdate       := NULL; --发出到抄表机日期
    Mrhis.Cbmrinorder       := NULL; --抄表机接收次序
    Mrhis.Cbmrindate        := NULL; --抄表机接受日期
    Mrhis.Cbmrrpid          := Mi.Sbrpid; --计件类型
    Mrhis.Cbmrmemo          := NULL; --抄表备注
    Mrhis.Cbmrifgu          := 'N'; --估表标志
    Mrhis.Cbmrifrec         := 'Y'; --已计费
    Mrhis.Cbmrrecdate       := NULL; --计费日期
    Mrhis.Cbmrrecsl         := NULL; --应收水量
    /*        --取未用余量
    sp_fetchaddingsl(mrHIS.cbmrid , --抄表流水
                     sb.sbid,--水表号
                     v_tempnum,--旧表止度
                     v_tempnum,--新表起度
                     v_addsl ,--余量
                     v_date,--创建日期
                     v_tempstr,--加调事务
                     v_ret  --返回值
                     ) ;
    mrHIS.cbmraddsl         :=   v_addsl ;  --余量   */
    Mrhis.Cbmraddsl         := 0; --余量
    Mrhis.Cbmrcarrysl       := NULL; --进位水量
    Mrhis.Cbmrctrl1         := NULL; --抄表机控制位1
    Mrhis.Cbmrctrl2         := NULL; --抄表机控制位2
    Mrhis.Cbmrctrl3         := NULL; --抄表机控制位3
    Mrhis.Cbmrctrl4         := NULL; --抄表机控制位4
    Mrhis.Cbmrctrl5         := NULL; --抄表机控制位5
    Mrhis.Cbmrchkflag       := 'N'; --复核标志
    Mrhis.Cbmrchkdate       := NULL; --复核日期
    Mrhis.Cbmrchkper        := NULL; --复核人员
    Mrhis.Cbmrchkscode      := NULL; --原起数
    Mrhis.Cbmrchkecode      := NULL; --原止数
    Mrhis.Cbmrchksl         := NULL; --原水量
    Mrhis.Cbmrchkaddsl      := NULL; --原余量
    Mrhis.Cbmrchkcarrysl    := NULL; --原进位水量
    Mrhis.Cbmrchkrdate      := NULL; --原抄见日期
    Mrhis.Cbmrchkface       := NULL; --原表况
    Mrhis.Cbmrchkresult     := NULL; --检查结果类型
    Mrhis.Cbmrchkresultmemo := NULL; --检查结果说明
    Mrhis.Cbmrprimid        := Mi.Sbpriid; --合收表主表
    Mrhis.Cbmrprimflag      := Mi.Sbpriflag; --  合收表标志
    Mrhis.Cbmrlb            := Mi.Sblb; -- 水表类别
    Mrhis.Cbmrnewflag       := Mi.Sbnewflag; -- 新表标志
    Mrhis.Cbmrface2         := NULL; --抄见故障
    Mrhis.Cbmrface3         := NULL; --非常计量
    Mrhis.Cbmrface4         := NULL; --表井设施说明
  
    Mrhis.Cbmrprivilegeflag := 'N'; --特权标志(Y/N)
    Mrhis.Cbmrprivilegeper  := NULL; --特权操作人
    Mrhis.Cbmrprivilegememo := NULL; --特权操作备注
    Mrhis.Area_No           := Mi.Area_No; --管理区域
    Mrhis.Cbmriftrans       := 'N'; --转单标志
    Mrhis.Cbmrrequisition   := 0; --通知单打印次数
    Mrhis.Cbmrifchk         := Mi.Sbifchk; --考核表标志
    Mrhis.Cbmrinputper      := NULL; --入账人员
    Mrhis.Price_No          := Mi.Price_No; --用水类别
    --mrHIS.cbmrcaliber       := md.mdcaliber;--口径
    Mrhis.Cbmrside  := Mi.Sbside; --表位
    Mrhis.Cbmrmtype := Mi.Sbtype; --表型
  
    Mrhis.Cbmrplansl   := 0; --计划水量
    Mrhis.Cbmrplanje01 := 0; --计划水费
    Mrhis.Cbmrplanje02 := 0; --计划污水处理费
    Mrhis.Cbmrplanje03 := 0; --计划水资源费
    INSERT INTO Ys_Cb_Mtreadhis VALUES Mrhis;
  END;

  --调整减免
 --应收调整（包含应收冲正、调高、调低、调差价）
  procedure RecAdjust(p_billno in varchar2, --单据编号
                      p_per    in varchar2, --完结人
                      p_memo   in varchar2, --备注
                      p_commit in varchar --是否提交标志
                     ) as
    cursor c_rah is
    select * from YS_GD_ARADJUSTHD
    where BILL_ID = p_billno
    for update;

    cursor c_rad is
    select * from YS_GD_ARADJUSTDT
    where BILL_ID = p_billno and CHK_FLAG = 'Y'
    order by ID
    for update;

    cursor c_rlsource(vrlid in varchar2) is
    select * from  ys_zw_arlist
    where arid = vrlid
      and arpaidflag='N'
      and arreverseflag='N'
      and arbadflag='N'
      and aroutflag='N';

    cursor c_raddall( vrd_ID in varchar2) is
    select * from YS_GD_ARADJUSTDDT
    where rd_ID = vrd_ID
    order by id
    for update;

    rah   YS_GD_ARADJUSTHD%rowtype;
    rad   YS_GD_ARADJUSTDT%rowtype;
    radd  YS_GD_ARADJUSTDDT%rowtype;
    rlsource ys_zw_arlist%rowtype;
    --
    vrd  parm_append1rd:=parm_append1rd(null,null,null,null,null,null,null,null,null,null);
    vrds parm_append1rd_tab:= parm_append1rd_tab();
    vsumraddje number:=0;--再次校验单头单体金额相符，很重要
  BEGIN
    --单据状态校验
    --检查单是否已完结
    open c_rah;
    fetch c_rah into rah;
    if c_rah%notfound or c_rah%notfound is null then
      raise_application_error(errcode, '单据不存在');
    end if;
    if rah.CHECK_FLAG = 'Y' then
      raise_application_error(errcode, '单据已审核');
    end if;
    if rah.CHECK_FLAG = 'Q' then
      raise_application_error(errcode, '单据已取消');
    end if;

    open c_rad;
    fetch c_rad into rad;
    if c_rad%notfound or c_rad%notfound is null then
      raise_application_error(errcode,'单据中不存在选中的调整记录');
    end if;
    while c_rad%found loop
      open c_rlsource(rad.REC_ID);
      fetch c_rlsource into rlsource;
      if c_rlsource%notfound or c_rlsource%notfound is null then
        raise_application_error(errcode, '待调整应收帐务不存在，或已销、已调、划账处理、代收代扣在途等原因！');
      end if;
      close c_rlsource;
      -------------------------------------------------
      vsumraddje := 0;
      vrds       := null;
      open c_raddall(rad.ID);
      loop
        fetch c_raddall into radd;
        exit when c_raddall%notfound or c_raddall%notfound is null;
        
        vrd.HIRE_CODE  := radd.HIRE_CODE;
        vrd.ardpmdid  := radd.GROUP_NO;
        vrd.ardpfid   := radd.PRICE_NO;
        vrd.ardpscid  := radd.ardpscid; --费率明细方案
        vrd.ardpiid   := radd.PRICE_ITEM;
        vrd.ardclass  := radd.STEP_CLASS;
        vrd.arddj     := radd.ADJUST_PRICE;
       /* vrd.rdsl     := case when rah.rahmemo='减免' then radd.raddyssl
                             when rah.rahmemo='调整' then radd.raddsl
                             else radd.raddsl end;*/
        vrd.ardsl     :=radd.ADJUST_WATER;
        vrd.ardje     := radd.ADJUST_PRICE;
        if vrds is null then
          vrds := parm_append1rd_tab(vrd);
        else
          vrds.extend;
          vrds(vrds.last) := vrd;
        end if;
        vsumraddje := vsumraddje + vrd.ardje;
      end loop;
      close c_raddall;
      if vsumraddje<>rad.CHARGE_AMT then
         raise_application_error(errcode, '单据'||rad.REC_ID||'数据错误，调整后金额'||vsumraddje||'与单体明细合计'||rad.CHARGE_AMT||'不符');
      end if;
      -------------------------------------------------
       pg_paid.RecAdjust(p_rlmid => rad.USER_NO,
                       p_rlcname => rah.USER_NAME,
                       p_rlpfid => rad.PRICE_NO,
                       p_rlrdate => rad.READ_DATE,
                       p_rlscode => rad.READ_SCODE,
                       p_rlecode => rad.READ_ECODE,
                       p_rlsl => rad.WATER,
                       p_rlje => rad.CHARGE_AMT,
                       p_rlznj => 0,
                       p_rltrans => 'X',
                       p_rlmemo => rah.ADJ_MEMO,
                       p_rlid_source => rad.REC_ID,
                       p_parm_append1rds => vrds,
                       p_commit =>0,
                       p_ctl_mircode => case when rah.NCODE_FLAG='Y' then rah.NEXT_CODE else null end,
                       o_rlid_reverse => rad.REC_ID_CR,
                       o_rlid => rad.REC_ID_de);
      ----反馈单体
      update YS_GD_ARADJUSTDT
         set REC_ID_CR = rad.REC_ID_CR,
             REC_ID_de = rad.REC_ID_de
       where current of c_rad; 
      fetch c_rad into rad;
    end loop;
    close c_rad;

    --审核单头
    UPDATE YS_GD_ARADJUSTHD
       SET CHECK_DATE = CURRENTDATE, CHECK_PER = P_PER, CHECK_FLAG = 'Y'
     WHERE CURRENT OF c_rah;
    CLOSE c_rah; 
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;

  exception when others then
    if c_rah%isopen then
      close c_rah;
    end if;
    if c_rad%isopen then
      close c_rad;
    end if;
    if c_raddall%isopen then
      close c_raddall;
    end if;
    if c_rlsource%isopen then
      close c_rlsource;
    end if;
    rollback;
    raise_application_error(errcode, sqlerrm);
  END RecAdjust;
   
  --实收冲正
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2) IS
    Ls_Retstr VARCHAR2(100);
    --单头
    CURSOR c_Hd IS
      SELECT * FROM YS_GD_PAIDADJUSTHD WHERE BILL_ID = p_No FOR UPDATE;
    --单体
    CURSOR c_Dt IS
      SELECT *
        FROM YS_GD_PAIDADJUSTDT
       WHERE BILL_ID = p_No
         FOR UPDATE;
  
    v_Hd   YS_GD_PAIDADJUSTHD%ROWTYPE;
    v_Dt   YS_GD_PAIDADJUSTDT %ROWTYPE;
    v_Temp NUMBER DEFAULT 0;
    p_pid_reverse  VARCHAR2(50);
  BEGIN
    OPEN c_Hd;
    FETCH c_Hd
      INTO v_Hd;
    /*检查处理*/
    IF c_Hd%ROWCOUNT = 0 THEN
      Raise_Application_Error(Errcode,
                              '单据不存在,可能已经由其他操作员操作！');
    END IF;
    IF v_Hd.CHECK_FLAG = 'Y' THEN
      Raise_Application_Error(Errcode, '单据已经审核！');
    END IF;
    IF v_Hd.CHECK_FLAG = 'Q' THEN
      Raise_Application_Error(Errcode, '单据已取消！');
    END IF;
    /*处理单体*/
    OPEN c_Dt;
    LOOP
      FETCH c_Dt
        INTO v_Dt;
      EXIT WHEN c_Dt%NOTFOUND OR c_Dt%NOTFOUND IS NULL;
    
      IF v_Dt.PAID_TRANS = 'H'  THEN
        Raise_Application_Error(Errcode,
                                '缴费批次号' || v_Dt.PAID_BATCH ||
                                '基建调拨实施前缴费,暂时不能冲正!');
      END IF;
       
      --end!!!
      pg_paid.PosReverse(v_Dt.Paid_Id ,
                       p_Per       ,
                       ''        ,
                       0    ,
                       p_pid_reverse );
     
    END LOOP;
    UPDATE YS_GD_PAIDADJUSTHD
       SET CHECK_FLAG = 'Y', CHECK_DATE = SYSDATE, CHECK_PER = p_Per
    --  PAHSHPER = pahcreper
     WHERE CURRENT OF c_Hd;
   
    IF c_Hd%ISOPEN THEN
      CLOSE c_Hd;
    END IF;
    IF c_Dt%ISOPEN THEN
      CLOSE c_Dt;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF c_Hd%ISOPEN THEN
        CLOSE c_Hd;
      END IF;
      IF c_Dt%ISOPEN THEN
        CLOSE c_Dt;
      END IF;
      Raise_Application_Error(Errcode, SQLERRM);
  END; 
END;
/

