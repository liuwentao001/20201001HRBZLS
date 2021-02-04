CREATE OR REPLACE PROCEDURE HRBZLS."�����û���Ѳ���" (rl     IN out reclist%rowtype,
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

--���Ǯ�ķ���
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

---ˮ������
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
--���ˮ������
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
--������һ��ˮ��ˮ��
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
  --��������
  NEWRL.RLID       := fgetsequence('RECLIST');
  NEWRL.RLSL       := V_SL1; --Ӧ��ˮ��
  NEWRL.rlje       := V_JE1; --Ӧ�ս��
  NEWRL.Rlpaidje   := 0; --���ʽ��
  NEWRL.Rlpaidflag := 'N'; --���ʱ�־(y:y��n:n��x:x��v:y/n��t:y/x��k:n/x��w:y/n/x)
  NEWRL.RLPAIDPER  := NULL; --������Ա
  NEWRL.RLPAIDDATE := NULL; --��������
  NEWRL.rlmemo     := 'ԭӦ����ˮ��[' || RL.RLID || ']|�����û����ʱ����';
  insert into reclist values NEWRL;
open c_fcrd;
loop
fetch c_fcrd into fcrd ;
exit when c_fcrd%notfound or c_fcrd%notfound is null ;
    NEWRD.RDID           := NEWRL.RLID; --��ˮ��
    NEWRD.rdpmdid        := fcrd.fcrdpmdid ; --�����ˮ����
    NEWRD.rdpiid         := fcrd.fcrdpiid ; --������Ŀ
    NEWRD.RDPFID         := fcrd.fcrdpfid ;--����
    NEWRD.rdpscid        := fcrd.fcrdpscid ; --������ϸ����
    NEWRD.rdclass        := fcrd.fcrdclass ; --���ݼ���
    NEWRD.RDYSDJ         := fcrd.fcrddj1; --Ӧ�յ���
    NEWRD.RDYSSL         := fcrd.fcrdsl1 ; --ʵ��ˮ��
    NEWRD.RDYSJE         := fcrd.fcrdje1 ; --ʵ�ս��
    NEWRD.RDDJ           := fcrd.fcrddj1; --Ӧ�յ���
    NEWRD.RDSL           := fcrd.fcrdsl1 ; --ʵ��ˮ��
    NEWRD.RDJE           := fcrd.fcrdje1 ; --ʵ�ս��
    NEWRD.rdadjdj        := 0; --��������
    NEWRD.rdadjsl        := 0; --����ˮ��
    NEWRD.rdadjje        := 0; --�������
    NEWRD.rdpaidflag     := 'N'; --���ʱ�־
    NEWRD.rdpaiddate     := NULL; --��������
    NEWRD.rdpaidmonth    := NULL; --�����·�
    NEWRD.rdpaidper      := NULL; --������Ա
    NEWRD.RDZNJ          := 0  ; --ΥԼ��
    NEWRD.RDMETHOD       := fcrd.fcrdmethod ; --�Ʒѷ���
    NEWRD.RDPMDSCALE     := fcrd.fcrdpmdscale; --��ϱ���
    NEWRD.RDILID         := fcrd.fcrdilid ; --Ʊ����ˮ
    NEWRD.RDMEMO         := 'ԭӦ����ˮ��[' || RL.RLID || ']|�����û����ʱ����';
    INSERT INTO RECDETAIL VALUES NEWRD;
  END LOOP;
  close c_fcrd;
  --����ԭ��
  rl.rlsl := V_SL2; --Ӧ��ˮ��
  rl.rlje := v_je2; --Ӧ�ս��
  update reclist set rlsl = rl.rlsl, rlje = rl.rlje,
  rlmemo     = '����ֺ����ɵ�Ӧ����ˮ��[' || NEWRD.RDID || ']|�����û����ʱ����'
   where rlid = rl.rlid;

  open c_fcrd;
  loop
  fetch c_fcrd into fcrd ;
  exit when c_fcrd%notfound or c_fcrd%notfound is null ;
    UPDATE RECDETAIL
             SET rdsl = fcrd.fcrdsl2, rdje = fcrd.fcrdje2,
                 RDMEMO = '����ֺ����ɵ�Ӧ����ˮ��[' || NEWRD.RDID || ']|�����û����ʱ����'
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

