CREATE OR REPLACE PROCEDURE HRBZLS."托收用户算费拆帐" (rl     IN out reclist%rowtype,
                                     P_RLJE IN NUMBER,
                                     rlnew      out reclist%rowtype,
                                     o_rlid out varchar2) IS
  V_SL1      NUMBER(10);
  V_SL2      NUMBER(10);
  V_JE1      NUMBER(12, 2);
  V_JE2      NUMBER(12, 2);
  V_TEMPRDJE NUMBER(12, 2);
  V_TEMPRDSL NUMBER(10);
  V_moreJE NUMBER(12, 2);
  V_moresl NUMBER(12, 2);
  NEWRL      RECLIST%ROWTYPE;
  NEWRD      RECDETAIL%ROWTYPE;
  fcrd       fcrecdetail%ROWTYPE;
  V_NEWZB    NUMBER;

  cursor c_fcrd is
  select * from fcrecdetail;
  cursor c_fcrdsl is
  select fcrdid,
       fcrdpmdid,
       max(fcrdsl),
       max(fcrdsl1)
        from fcrecdetail group by fcrdid,
       fcrdpmdid ;
BEGIN
  NEWRL   := rl;
  V_JE1   := P_RLJE;
  V_NEWZB := (V_JE1 / RL.rlje);
  V_JE2   := RL.RLJE - V_JE1;
  V_SL1   := TRUNC(RL.rlsl * V_NEWZB)  ;
  V_SL2   := RL.RLSL - V_SL1;

---------------------------------------------
DELETE fcrecdetail;
INSERT INTO fcrecdetail
(      fcrdid,
       fcrdpmdid,
       fcrdpiid,
       fcrdpfid,
       fcrdpscid,
       fcRDCLASS,
       fcrddj,
       fcrdsl,
       fcrdje,
       fcrddj1,
       fcrdsl1,
       fcrdje1,
       fcrddj2,
       fcrdsl2,
       fcrdje2,
       FCRDMETHOD,
       FCRDPMDSCALE,
       FCRDILID )
SELECT
       RDid,
       RDpmdid,
       RDpiid,
       RDpfid,
       RDpscid,
       RDCLASS,
       RDdj,
       RDsl,
       RDje,
       RDdj,
       0,
       0,
       RDdj,
       0,
       0,
       RDMETHOD,
       RDPMDSCALE,
       RDILID
 FROM RECDETAIL WHERE RDPAIDFLAG='N' AND  RDID =RL.RLID ;
 V_TEMPRDJE :=0;
open c_fcrd;
loop
fetch c_fcrd into fcrd ;
exit when c_fcrd%notfound or c_fcrd%notfound is null ;
     fcrd.fcrdje1 :=trunc(fcrd.fcrdje*V_NEWZB,2) ;
     V_TEMPRDJE        := V_TEMPRDJE + fcrd.fcrdje1 ;
    IF V_JE1 - V_TEMPRDJE < 0 THEN
      fcrd.fcrdje1   := TOOLS.getmax(fcrd.fcrdje1 - (V_TEMPRDJE - V_JE1), 0);
      update fcrecdetail set fcrdje1=fcrd.fcrdje1
       where fcrd.fcrdid=fcrdid and fcrd.fcrdpmdid=fcrdpmdid and fcrd.fcrdpiid=fcrdpiid
       and fcrd.fcrdpfid=fcrdpfid ;
      EXIT;
    ELSE
    update fcrecdetail set fcrdje1=fcrd.fcrdje1
       where fcrd.fcrdid=fcrdid and fcrd.fcrdpmdid=fcrdpmdid and fcrd.fcrdpiid=fcrdpiid
       and fcrd.fcrdpfid=fcrdpfid ;
    END IF;
end loop;
close c_fcrd;

--多出钱的分配
if V_JE1 - V_TEMPRDJE>0 then
   V_moreJE := V_JE1 - V_TEMPRDJE;
  open c_fcrd;
  loop
  fetch c_fcrd into fcrd ;
  exit when c_fcrd%notfound or c_fcrd%notfound is null ;
       fcrd.fcrdje1 := fcrd.fcrdje1 +  V_moreJE ;
      IF fcrd.fcrdje  < fcrd.fcrdje1 THEN
        V_moreJE :=fcrd.fcrdje1 - fcrd.fcrdje;
        fcrd.fcrdje1   := fcrd.fcrdje ;
        update fcrecdetail set fcrdje1=fcrd.fcrdje1
       where fcrd.fcrdid=fcrdid and fcrd.fcrdpmdid=fcrdpmdid and fcrd.fcrdpiid=fcrdpiid
       and fcrd.fcrdpfid=fcrdpfid ;
      else
        update fcrecdetail set fcrdje1=fcrd.fcrdje1
       where fcrd.fcrdid=fcrdid and fcrd.fcrdpmdid=fcrdpmdid and fcrd.fcrdpiid=fcrdpiid
       and fcrd.fcrdpfid=fcrdpfid ;
        V_moreJE := 0 ;
        exit;
      END IF;
  end loop;
  close c_fcrd;
end if;

---水量分配
 V_TEMPRDSL :=0;
open c_fcrdsl;
loop
fetch c_fcrdsl into fcrd.fcrdid,fcrd.fcrdpmdid,fcrd.fcrdsl,fcrd.fcrdsl1  ;
exit when c_fcrdsl%notfound or c_fcrdsl%notfound is null ;
     fcrd.fcrdsl1 := trunc(fcrd.fcrdsl*V_NEWZB) ;
     V_TEMPRDSL  := V_TEMPRDSL + fcrd.fcrdsl1 ;
    IF V_SL1 - V_TEMPRDSL < 0 THEN
      fcrd.fcrdsl1   := TOOLS.getmax(fcrd.fcrdsl1 - (V_TEMPRDSL - V_SL1), 0);
      update fcrecdetail set fcrdsl1=fcrd.fcrdsl1 where fcrdid=fcrd.fcrdid
      and fcrd.fcrdpmdid=fcrdpmdid ;
      EXIT;
    else
      update fcrecdetail set fcrdsl1=fcrd.fcrdsl1 where fcrdid=fcrd.fcrdid
      and fcrd.fcrdpmdid=fcrdpmdid ;
    END IF;
end loop;
close c_fcrdsl;
--多出水量处理
if V_SL1 - V_TEMPRDSL>0 then
   V_moresl := V_SL1 - V_TEMPRDSL;
  open c_fcrdsl;
  loop
  fetch c_fcrdsl into fcrd.fcrdid,fcrd.fcrdpmdid,fcrd.fcrdsl,fcrd.fcrdsl1  ;
  exit when c_fcrdsl%notfound or c_fcrdsl%notfound is null ;
       fcrd.fcrdsl1 := fcrd.fcrdsl1 +  V_moresl ;
      IF fcrd.fcrdsl  < fcrd.fcrdsl1 THEN
        V_moresl :=fcrd.fcrdsl1 - fcrd.fcrdsl;
        fcrd.fcrdsl1   := fcrd.fcrdsl ;
        update fcrecdetail set fcrdsl1=fcrd.fcrdsl1 where fcrdid=fcrd.fcrdid
        and fcrd.fcrdpmdid=fcrdpmdid ;
      else
        update fcrecdetail set fcrdsl1=fcrd.fcrdsl1 where fcrdid=fcrd.fcrdid
        and fcrd.fcrdpmdid=fcrdpmdid ;
        V_moresl := 0 ;
        exit;
      END IF;
  end loop;
  close c_fcrdsl;
end if;
--分配另一半水费水量
open c_fcrd;
loop
fetch c_fcrd into fcrd ;
exit when c_fcrd%notfound or c_fcrd%notfound is null ;
      update fcrecdetail set fcrdsl2=fcrd.fcrdsl - fcrd.fcrdsl1,
      fcrdje2=fcrd.fcrdje - fcrd.fcrdje1
       where fcrd.fcrdid=fcrdid and fcrd.fcrdpmdid=fcrdpmdid and fcrd.fcrdpiid=fcrdpiid
       and fcrd.fcrdpfid=fcrdpfid ;
end loop;
close c_fcrd;
-----------------------------------------------
  --生成新帐
  NEWRL.RLID       := fgetsequence('RECLIST');
  NEWRL.RLSL       := V_SL1; --应收水量
  NEWRL.rlje       := V_JE1; --应收金额
  NEWRL.Rlpaidje   := 0; --销帐金额
  NEWRL.Rlpaidflag := 'N'; --销帐标志(y:y，n:n，x:x，v:y/n，t:y/x，k:n/x，w:y/n/x)
  NEWRL.RLPAIDPER  := NULL; --销帐人员
  NEWRL.RLPAIDDATE := NULL; --销帐日期
  NEWRL.rlmemo     := '原应收流水号[' || RL.RLID || ']|托收用户算费时拆帐';
  insert into reclist values NEWRL;
open c_fcrd;
loop
fetch c_fcrd into fcrd ;
exit when c_fcrd%notfound or c_fcrd%notfound is null ;
    NEWRD.RDID           := NEWRL.RLID; --流水号
    NEWRD.rdpmdid        := fcrd.fcrdpmdid ; --混合用水分组
    NEWRD.rdpiid         := fcrd.fcrdpiid ; --费用项目
    NEWRD.RDPFID         := fcrd.fcrdpfid ;--费率
    NEWRD.rdpscid        := fcrd.fcrdpscid ; --费率明细方案
    NEWRD.rdclass        := fcrd.fcrdclass ; --阶梯级别
    NEWRD.RDYSDJ         := fcrd.fcrddj1; --应收单价
    NEWRD.RDYSSL         := fcrd.fcrdsl1 ; --实收水量
    NEWRD.RDYSJE         := fcrd.fcrdje1 ; --实收金额
    NEWRD.RDDJ           := fcrd.fcrddj1; --应收单价
    NEWRD.RDSL           := fcrd.fcrdsl1 ; --实收水量
    NEWRD.RDJE           := fcrd.fcrdje1 ; --实收金额
    NEWRD.rdadjdj        := 0; --调整单价
    NEWRD.rdadjsl        := 0; --调整水量
    NEWRD.rdadjje        := 0; --调整金额
    NEWRD.rdpaidflag     := 'N'; --销帐标志
    NEWRD.rdpaiddate     := NULL; --销帐日期
    NEWRD.rdpaidmonth    := NULL; --销帐月份
    NEWRD.rdpaidper      := NULL; --销帐人员
    NEWRD.RDZNJ          := 0  ; --违约金
    NEWRD.RDMETHOD       := fcrd.fcrdmethod ; --计费方法
    NEWRD.RDPMDSCALE     := fcrd.fcrdpmdscale; --混合比例
    NEWRD.RDILID         := fcrd.fcrdilid ; --票据流水
    NEWRD.RDMEMO         := '原应收流水号[' || RL.RLID || ']|托收用户算费时拆帐';
    INSERT INTO RECDETAIL VALUES NEWRD;
  END LOOP;
  close c_fcrd;
  --更新原帐
  rl.rlsl := V_SL2; --应收水量
  rl.rlje := v_je2; --应收金额
  update reclist set rlsl = rl.rlsl, rlje = rl.rlje,
  rlmemo     = '被拆分后生成的应收流水号[' || NEWRD.RDID || ']|托收用户算费时拆帐'
   where rlid = rl.rlid;

  open c_fcrd;
  loop
  fetch c_fcrd into fcrd ;
  exit when c_fcrd%notfound or c_fcrd%notfound is null ;
    UPDATE RECDETAIL
             SET rdsl = fcrd.fcrdsl2, rdje = fcrd.fcrdje2,
                 RDMEMO = '被拆分后生成的应收流水号[' || NEWRD.RDID || ']|托收用户算费时拆帐'
           where RDID = rl.rlid
             AND RDPMDID = fcrd.FCRDPMDID
             AND RDPIID = fcrd.FCRDPIID
             AND RDPFID = fcrd.FCRDPFID;
  END LOOP;
  close c_fcrd;
  o_rlid := NEWRL.RLID;
  rlnew := NEWRL;
EXCEPTION
  WHEN OTHERS THEN
   if c_fcrd%isopen then
     close c_fcrd;
   end if;
   if c_fcrdsl%isopen then
     close c_fcrdsl;
   end if;
null;
END;
/

