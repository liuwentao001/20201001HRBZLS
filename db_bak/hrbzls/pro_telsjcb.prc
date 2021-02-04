create or replace procedure hrbzls.PRO_telsjcb(MI          IN METERINFO%ROWTYPE, --水表信息
                                        CI          IN CUSTINFO%ROWTYPE, --用户信息
                                        MD          IN METERDOC%ROWTYPE, --水表档案
                                        MA          IN METERACCOUNT%ROWTYPE, --用户银行信息
                                        P_TYPE      IN VARCHAR2, --变更类型
                                        P_CCHCREPER in CUSTCHANGEhd.Cchcreper%type, --申请人
                                        P_MESSAGE   OUT VARCHAR2 --出参
                                        ) is

  chd      CUSTCHANGEhd%rowtype;
  cht      CUSTCHANGEdt%rowtype;
  v_dept   CUSTCHANGEhd.Cchdept%type;
  v_seq    CUSTCHANGEhd.cchno%type;
  V_FID    FLOW_DEFINE.FID%TYPE;
  V_BMID   BILLMAIN.BMID%TYPE;
  V_OANAME OPERACCNT.OANAME%TYPE;
  V_COUNT1  NUMBER;  --是本人申请未审核数
   V_COUNT2  NUMBER;  --不是本人申请未审核数
  V_BMNAME  BILLMAIN.BMNAME%TYPE;
  v_CCHNO CUSTCHANGEhd.Cchno%type;
  type c_cd is ref cursor;
  c_ccht c_cd;  --为防止有多条同一抄表员同一用户未审核记录，需要使用游标
   P_cby  CUSTCHANGEhd.Cchcreper%type  ; --抄表员
begin
  V_COUNT1 := 0;
  V_COUNT2 := 0;
 
   SELECT DISTINCT BMID, bmflag2,BMNAME
    INTO V_BMID, V_FID,V_BMNAME
    FROM billmain
   WHERE BMTYPE = P_TYPE;
   
  SELECT FGETSEQUENCE('SEQ_BILLSEQNO') INTO v_seq FROM DUAL; --获取流水号

 begin 
  select t1.oaid , t1.OANAME ,t2.oaid
    into v_dept, V_OANAME,P_cby
    from OPERACCNT t1,operaccnt_level t2
   where t1.OAID = P_CCHCREPER and t1.oaid=t2.oaid and t2.oapid is not null; --ralph 20150615修改获取部门码
   exception 
     when others then
         P_MESSAGE := P_MESSAGE || '抄表员对应上层关系出错,请检查抄表员对应内勤关系!';
         return ;
    end ;

  SELECT sum(case when CCHCREPER=P_cby then 1 else 0 end ),sum(case when CCHCREPER<>P_cby then 1 else 0 end )
    INTO V_COUNT1,V_COUNT2
    FROM CUSTCHANGEhd, CUSTCHANGEdt
   WHERE CCHNO = CCDNO
     AND CIID = MI.MIID
     AND CCHLB = P_TYPE AND CCHSHFLAG='N';
/*  IF V_COUNT2>0 THEN
    P_MESSAGE:='该用户已经存在更名或更改用水性质'||V_BMNAME||'单据,不是当前操作员申请的,不能进行业务';
  END IF;*/
  if V_COUNT1>0 then
     open c_ccht for select CCHNO from CUSTCHANGEhd,CUSTCHANGEdt where CCHNO = CCDNO AND CIID = MI.MIID  AND CCHLB = P_TYPE AND CCHSHFLAG='N' and CCHCREPER=P_cby ;
     fetch c_ccht into v_CCHNO;
     while c_ccht%found loop
           delete from CUSTCHANGEhd where CCHNO=v_CCHNO;
           delete from  CUSTCHANGEdt where CCdNO=v_CCHNO;
           fetch c_ccht into v_CCHNO;
     end loop;
     close c_ccht;
  end if;
  if P_MESSAGE is null or trim(P_MESSAGE)='' then
      chd.cchno      := v_seq; --流水单号
      CHD.CCHBH      := v_seq; --流水单号
      chd.cchlb      := P_TYPE;
      chd.cchsource  := '3'; --手机抄表来源 modify hb 20150411
      chd.cchsmfid   := mi.mismfid;
      chd.CCHDEPT    := v_dept; --需要赋值
      chd.CCHCREDATE := sysdate;
      chd.cchcreper  := P_cby;
      chd.CCHSHDATE  := null;
      chd.CCHSHPER   := '';
      chd.cchshflag  := 'N';
      CHD.CCHWFID    := '';
      INSERT INTO CUSTCHANGEhd VALUES CHD;
      if sqlcode <> 0 then
        P_MESSAGE := P_MESSAGE||'插入业务表头失败!';
      end if;
  end if;
  if P_MESSAGE is null or trim(P_MESSAGE)='' then
      cht.CCDNO           := v_seq; --流水单号
      cht.CCDROWNO        := 1; --流水单号
      cht.ciid            := mi.miid; --用户编号
      cht.cicode          := mi.miid;
      cht.ciconid         := ci.ciconid;
      cht.CISMFID         := mi.mismfid;
      cht.cipid           := ci.cipid;
      cht.CICLASS         := ci.Ciclass;
      cht.ciflag          := ci.Ciflag;
      CHT.CINAME          := CI.CINAME;
      CHT.CINAME2         := CI.CINAME2;
      CHT.CIADR           := CI.CIADR;
      CHT.CISTATUS        := CI.CISTATUS;
      CHT.CISTATUSDATE    := CI.CISTATUSDATE;
      cht.cistatustrans   := ci.cistatustrans;
      CHT.CINEWDATE       := CI.CINEWDATE;
      CHT.CIIDENTITYLB    := ci.ciidentitylb;
      cht.ciidentityno    := ci.ciidentityno;
      cht.CIMTEL          := ci.CIMTEL;
      cht.citel1          := ci.citel1;
      cht.citel2          := ci.citel2;
      cht.citel3          := ci.citel3;
      cht.CICONNECTPER    := ci.CICONNECTPER;
      cht.ciconnecttel    := ci.ciconnecttel;
      cht.ciifinv         := ci.ciifinv;
      cht.ciifsms         := ci.ciifsms;
      cht.ciifzn          := ci.ciifzn;
      cht.ciprojno        := ci.ciprojno;
      cht.cifileno        := ci.cifileno;
      cht.cimemo          := ci.cimemo;
      cht.cideptid        := ci.cideptid;
      cht.micid           := mi.micid;
      cht.miid            := mi.miid;
      cht.miadr           := mi.miadr;
      cht.misafid         := mi.misafid;
      cht.micode          := mi.micode;
      cht.mismfid         := mi.mismfid;
      cht.miprmon         := mi.miprmon;
      cht.mirmon          := mi.mirmon;
      cht.mibfid          := mi.mibfid;
      cht.mirorder        := mi.mirorder;
      cht.mipid           := mi.mipid;
      cht.miclass         := mi.miclass;
      cht.miflag          := mi.miflag;
      cht.mirtid          := mi.mirtid;
      cht.miifmp          := mi.miifmp;
      cht.miifsp          := mi.miifsp;
      cht.mistid          := mi.mistid;
      cht.mipfid          := mi.mipfid;
      cht.mistatus        := mi.mistatus;
      cht.mistatusdate    := mi.mistatusdate;
      cht.mistatustrans   := mi.mistatustrans;
      cht.miface          := mi.miface;
      cht.mirpid          := mi.mirpid;
      cht.miside          := mi.miside;
      cht.miposition      := mi.miposition;
      cht.miinscode       := mi.miinscode;
      cht.miinsdate       := mi.miinsdate;
      cht.miinsper        := mi.miinsper;
      cht.mireinscode     := mi.mireinscode;
      cht.mireinsdate     := mi.mireinsdate;
      cht.mireinsper      := mi.mireinsper;
      cht.mitype          := mi.mitype;
      cht.mircode         := mi.mircode;
      cht.mirecdate       := mi.mirecdate;
      cht.mirecsl         := mi.mirecsl;
      cht.miifcharge      := mi.miifcharge;
      cht.miifsl          := mi.miifsl;
      cht.miifchk         := mi.miifchk;
      cht.miifwatch       := mi.miifwatch;
      cht.miicno          := mi.miicno;
      cht.mimemo          := mi.mimemo;
      cht.mipriid         := mi.mipriid;
      cht.mipriflag       := mi.mipriflag;
      cht.miusenum        := mi.miusenum;
      cht.michargetype    := mi.michargetype;
      cht.misaving        := mi.misaving;
      cht.milb            := mi.milb;
      cht.minewflag       := mi.minewflag;
      cht.micper          := mi.micper;
      cht.miiftax         := mi.miiftax;
      cht.mitaxno         := mi.mitaxno;
      CHT.MINAME          := MI.MINAME ;  --20150412 ADD HB
      CHT.MINAME2         := MI.MINAME2 ; --20150412 ADD HB
      cht.pmdcid          := mi.miid;
      cht.pmdmid          := mi.miid;
      cht.pmdid           := '';
      cht.pmdpfid         := mi.mipfid;
      cht.pmdscale        := '';
      cht.mdmid           := md.mdmid;
      cht.mdno            := md.mdno;
      cht.mdcaliber       := md.mdcaliber;
      cht.mdbrand         := md.mdbrand;
      cht.mdmodel         := md.mdmodel;
      cht.mdstatus        := md.mdstatus;
      cht.mdstatusdate    := md.mdstatusdate;
      cht.mamid           := ma.mamid;
      cht.mano            := ma.mano;
      cht.manoname        := ma.manoname;
      cht.mabankid        := ma.mabankid;
      cht.maaccountno     := ma.maaccountno;
      cht.maaccountname   := ma.maaccountname;
      cht.matsbankid      := ma.matsbankid;
      cht.matsbankname    := ma.matsbankname;
      cht.maifxezf        := ma.maifxezf;
      cht.pmdid2          := '';
      cht.pmdpfid2        := '';
      cht.pmdscale2       := '';
      cht.pmdid3          := '';
      cht.pmdpfid3        := '';
      cht.pmdscale3       := '';
      cht.pmdid4          := '';
      cht.pmdpfid4        := '';
      cht.pmdscale4       := '';
      cht.ccdshflag       := 'N';
      cht.ccdshdate       := null;
      cht.ccdshper        := '';
      cht.miifchk         := mi.miifchk;
      cht.migps           := mi.migps;
      cht.miqfh           := mi.miqfh;
      cht.mibox           := mi.mibox;
      cht.ccdappnote      := '';
      cht.ccdfilashnote   := '';
      cht.ccdmemo         := '手机抄表更改资料';
      cht.ACCESSORYFLAG01 := 'N';
      cht.ACCESSORYFLAG02 := 'N';
      cht.ACCESSORYFLAG03 := 'N';
      cht.ACCESSORYFLAG04 := 'N';
      cht.ACCESSORYFLAG05 := 'N';
      cht.ACCESSORYFLAG06 := 'N';
      cht.ACCESSORYFLAG07 := 'N';
      cht.ACCESSORYFLAG08 := 'N';
      cht.ACCESSORYFLAG09 := 'N';
      cht.ACCESSORYFLAG10 := 'N';
      cht.ACCESSORYFLAG11 := 'N';
      cht.ACCESSORYFLAG12 := 'N';
      CHT.MABANKCODE      := ma.MAACCOUNTNO;
      CHT.MABANKNAME      := ma.MABANKID;
      CHT.MISEQNO         := MI.MISEQNO;
      CHT.MIJFKROW        := MI.MIJFKROW;
      CHT.MIUIID          := MI.MIUIID;
      CHT.MICOMMUNITY     := MI.MICOMMUNITY;
      CHT.MIREMOTENO      := MI.MIREMOTENO;
      CHT.MIREMOTEHUBNO   := MI.MIREMOTEHUBNO;
      CHT.MIEMAIL         := MI.MIEMAIL;
      CHT.MIEMAILFLAG     := MI.MIEMAILFLAG;
      CHT.MICOLUMN1       := MI.MICOLUMN1;
      CHT.MICOLUMN2       := MI.MICOLUMN2;
      CHT.MICOLUMN3       := MI.MICOLUMN3;
      CHT.MICOLUMN4       := MI.MICOLUMN4;
      CHT.PMDTYPE         := '';
      CHT.PMDCOLUMN1      := '';
      CHT.PMDCOLUMN2      := '';
      CHT.PMDCOLUMN3      := '';
      CHT.PMDTYPE2        := '';
      CHT.PMDCOLUMN12     := '';
      CHT.PMDCOLUMN22     := '';
      CHT.PMDCOLUMN32     := '';
      CHT.PMDTYPE3        := '';
      CHT.PMDCOLUMN13     := '';
      CHT.PMDCOLUMN23     := '';
      CHT.PMDCOLUMN33     := '';
      CHT.PMDTYPE4        := '';
      CHT.PMDCOLUMN14     := '';
      CHT.PMDCOLUMN24     := '';
      CHT.PMDCOLUMN34     := '';
      CHT.MIPAYMENTID     := MI.MIPAYMENTID;
      CHT.MICOLUMN5       := MI.MICOLUMN5;
      CHT.MICOLUMN6       := MI.MICOLUMN6;
      CHT.MICOLUMN7       := MI.MICOLUMN7;
      CHT.MICOLUMN8       := MI.MICOLUMN8;
      CHT.MICOLUMN9       := MI.MICOLUMN9;
      CHT.MICOLUMN10      := MI.MICOLUMN10;
      CHT.LH              := mi.MILH;
      CHT.DYH             := mi.Midyh;
      CHT.MPH             := mi.MIMPH;
      CHT.SFH             := MD.SFH;
      CHT.DQSFH           := MD.DQSFH;
      CHT.DQGFH           := MD.DQGFH;
      CHT.JCGFH           := MD.JCGFH;
      CHT.QHF             := MD.QFH;
      CHT.MIYHPJ          := MI.MIYHPJ;
      CHT.MIJD            := MI.MIJD;
      CHT.MIFACE2         := MI.MIFACE2;
      CHT.BARCODE         := MD.BARCODE;
      CHT.RFID            := MD.RFID;
      CHT.IFDZSB          := MD.IFDZSB;
      CHT.MIIFZDH         := MI.MIIFZDH;
      CHT.MIDBZJH         := MI.MIDBZJH;
      CHT.MIYL1           := MI.MIYL1;
      CHT.MIYL2           := MI.MIYL2;
      CHT.MIYL3           := MI.MIYL3;
      CHT.MIYL4           := MI.MIYL4;
      CHT.MIYL5           := MI.MIYL5;
      CHT.MIYL6           := MI.MIYL6;
      CHT.MIYL7           := MI.MIYL7;
      CHT.MIYL8           := MI.MIYL8;
      CHT.MIYL9           := MI.MIYL9;
      CHT.MIYL10          := MI.MIYL10;
      CHT.MIYL11          := MI.MIYL11;
      CHT.MIYL12          := MI.MIYL12;
      CHT.MITKZJH         := MI.MITKZJH;
      CHT.MICOLUMN11      := MI.MICOLUMN11;
      INSERT INTO CUSTCHANGEDT VALUES CHT;
      if sqlcode <> 0 then
        P_MESSAGE := P_MESSAGE || '插入业务表体失败!';
      end if;
  end if ;
  if P_MESSAGE is null or trim(P_MESSAGE)='' then
    Flow_next(V_FID, 1, v_seq, P_cby, 2, '抄表员：'||P_CCHCREPER, P_TYPE, V_OANAME, 'N');
    IF SQLCODE <> 0 THEN
      P_MESSAGE := P_MESSAGE || '插入流程失败!';
    END IF;
    COMMIT;
  end if;
end PRO_telsjcb;
/

