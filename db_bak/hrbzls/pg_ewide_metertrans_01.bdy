CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_METERTRANS_01" IS

  CurrentDate date := tools.fGetSysDate;

  --ģ��ͻ���ת������
procedure sp_billnew_test  AS
begin

 /* --ת������
��1 billnewhdNOCOMMIT
1������
2���¼�   ���� ������ �����ɵ��ݷ�ʽ
3���ɵ��ݷ�ʽ
4�����η�ʽ
5��˵��
��2  billnewidNOCOMMIT
6��ID
��3
7�����η�Χ billnewoperNOCOMMIT
*/
  null;
--���뵥����Ϣ
insert into billnewidNOCOMMIT (
c1--id
) values('2070955417') ;
--������������Ϣ
insert into billnewoperNOCOMMIT (
c1--id
) values('5455') ;
insert into billnewoperNOCOMMIT (
c1--id
) values('000010');
--���뵥ͷ��Ϣ
insert into billnewhdNOCOMMIT (
c1,--1������
c2,--2���¼�
c3,--3���ɵ��ݷ�ʽ  ������ֱ���ڹ��ܲ����ж��壩
c4,--4�����η�ʽ     ������ֱ���ڹ��ܲ����ж��壩
c5  ,--��ע
c6  --6������Ա
) values('010301','ue_createbill','ÿ��ID����һ����','���ε���','�뻻��','5455' ) ;
 COMMIT;
end;

  --���ɵ��ݹ��̣�����billnewhdNOCOMMIT����Ĵ�������
procedure sp_billbuild_test  AS
  bl billnewhdNOCOMMIT%rowtype;
  ep erpfunctionpara%rowtype;
  ep1 erpfunctionpara%rowtype;
  op operaccnt%rowtype;
  sf sysmanaframe%rowtype;
  dt billnewidNOCOMMIT%rowtype;
  bo billnewoperNOCOMMIT%rowtype;
--��ѯ����
  v_ip varchar2(20);
  v_user varchar2(20);
  v_login_name varCHAR(40);
  v_billno varchar2(10);
  v_id varchar2(20);
--��������ϸ
  cursor c_dt is
  select * from billnewidNOCOMMIT;
  cursor c_bo is
  select * from billnewoperNOCOMMIT;
begin

/* --ת������
��1 billnewhdNOCOMMIT
1������
2���¼�   ���� ������ �����ɵ��ݷ�ʽ
3���ɵ��ݷ�ʽ
4�����η�ʽ
5��˵��
��2  billnewidNOCOMMIT
��ID
��3
�����η�Χ billnewoperNOCOMMIT
6���������ݵ���ʱ�������Ա
7���������ݵ���ʱ���벿��
8���������ݵ���ʱ����Ӫҵ��
*/

--1�����ɵ�ͷ��Ϣ
--2�����ɵ�����Ϣ
--3�����͵���,���͵�����,���ͱ�ע

select * into bl from billnewhdNOCOMMIT where rownum=1;
--1�жϵ������
select * into ep from erpfunctionpara t where efid =  bl.c1
and bl.c2=t.efevent and eftype='�������' and efrow='001';
select * into ep1 from erpfunctionpara t where efid =  bl.c1
and bl.c2=t.efevent and eftype='���ܲ���' and efrow='001' ;

    --��ȡ����Ա�ͻ���ip
select sys_context('userenv','sid'),sys_context('userenv','SESSION_USER')
into v_ip, v_user from dual;
--2��ȡ����Աid
BEGIN
  select login_user into v_login_name from sys_host where ip = v_ip;
  EXCEPTION
    WHEN OTHERS then
       v_login_name:=bl.c6 ;
END ;
--3����
begin
select oadept into op.oadept from  operaccnt where  oaid=v_login_name;
exception when others then
  op.oadept :=bl.c7  ;
  null;
end;
--4Ӫҵ��
begin
  select smfpid into sf.smfpid  from sysmanaframe where smfid=op.oadept;
 exception when others then
  sf.smfpid :=bl.c8;
  null;
end;

--���ù���
--����
if ep.efrunpara='K' then
  --���ɷ�ʽ
  if bl.c3 ='ÿ��ID����һ����' then
    --�α�
    open c_dt;
    loop fetch c_dt into dt;
    exit when c_dt%notfound or c_dt%notfound is null;
    v_billno :='';
    sp_mrmrifsubmit(dt.c1  ,
                            ep.efrunpara  ,
                            '2'  ,
                            sf.smfpid  ,
                            op.oadept  ,
                            v_login_name ,
                            '1' ,
                            v_billno ) ;
    if   v_billno is not null then

        open c_bo;
        loop fetch c_bo into bo;
        exit when c_bo%notfound or c_bo%notfound is null;

     KT_DO_REPORT_COMMITFLAG('1',
                  ep1.efrunpara  ,
                  v_login_name,
                  bo.c1 ,
                  v_billno,
                  bl.c5,
                  'N');



        end loop;
        close c_bo;

    end if;
    end loop;
    close c_dt;
  end if;
end if;




end;

--����ƻ��������ɹ��ϻ�����
  procedure sp_mrmrifsubmit(p_mrid in varchar2,
                            p_type in varchar2,
                            p_source in varchar2,
                            p_smfid in varchar2,
                            p_dept in varchar2,
                            p_oper in varchar2,
                            p_flag in varchar2,
                            o_billno out varchar2) is
    cursor c_exist is
    select * from metertranshd
    where mthno in (select mtdno from metertransdt
                   where mtdmid=(select mrmid from meterread where mrid=p_mrid)
                   ) and
          mthshflag not in ('Q','Y') and mthlb=p_type
    for update;

    v_billid varchar2(10);
    v_id varchar2(10);
    mr meterread%rowtype;
    ci custinfo%rowtype;
    mi meterinfo%rowtype;
    md meterdoc%rowtype;
    mh metertranshd%rowtype;
    mt metertransdt%rowtype;
  begin
    if p_flag='0' then--ȡ��
      update meterread
      set mrface=null
      where mrid=p_mrid;
    else--���ɹ���(�ظ��������üӼ�ֵ���������ɹ���)
      begin
        select * into mr from meterread where mrid=p_mrid;
      exception when others then
        raise_application_error(errcode, '����ƻ�������!');
      end;
      begin
        select * into ci from custinfo where ciid=mr.mrcid;
      exception when others then
        raise_application_error(errcode, '�ͻ���Ϣ������!');
      end;
      begin
        select * into mi from meterinfo where miid=mr.mrmid;
      exception when others then
        raise_application_error(errcode, 'ˮ����Ϣ��Ϣ������!');
      end;
      begin
        select * into md from meterdoc where meterdoc.mdmid =mr.mrmid;
      exception when others then
        raise_application_error(errcode, 'ˮ������Ϣ��Ϣ������!');
      end;
      begin
        select bmid into v_billid  from billmain  where bmtype=p_type;
      exception when others then
        raise_application_error(errcode, '�������͵���δ����!');
      end;



      open c_exist;
      fetch c_exist into mh;
      if c_exist%notfound or c_exist%notfound is null then
        --���ɹ���
        tools.sp_billseq(v_billid,v_id,'N');
        o_billno :=v_id;

        mh.MTHNO          := v_id   ;--������ˮ��
        mh.MTHBH          := mh.MTHNO   ;--���ݱ��
        mh.MTHLB          := p_type   ;--�������
        mh.MTHSOURCE      := p_source   ;--������Դ
        mh.MTHSMFID       := p_smfid   ;--Ӫ����˾
        mh.MTHDEPT        := p_dept   ;--������
        mh.MTHCREDATE     := SYSDATE   ;--��������
        mh.MTHCREPER      := p_oper   ;--������Ա
        mh.MTHSHFLAG      := 'N'   ;--��˱�־
        mh.MTHSHDATE      := NULL  ;--�������
        mh.MTHSHPER       := NULL  ;--�����Ա
        mh.mthhot         := 1;
        mh.mthmrid        := p_mrid;
        insert into metertranshd values mh;



        mt.MTDNO                := mh.MTHNO  ; --������ˮ
        mt.MTDROWNO             := 1  ; --�к�
        mt.MTDSMFID             := mi.mismfid  ; --Ӫҵ��
        mt.MTDREQUDATE          := sysdate + 7  ; --Ҫ�����ʱ��
        mt.MTDTEL               := ci.CIMTEL  ; --�绰
        mt.MTDCONPER            := ci.CINAME  ; --��ϵ��
        mt.MTDCONTEL            := substr(ci.cimtel||' '||ci.citel1||' '||ci.citel2||' '||ci.ciconnecttel,90); --��ϵ�绰
        mt.MTDSHDATE            := null  ; --�깤¼������
        mt.MTDSHPER             := null  ; --�깤¼����Ա
        mt.MTDSENTDEPT          := null  ; --�ɹ�����
        mt.MTDSENTDATE          := null  ; --�ɹ�ʱ��
        mt.MTDSENTPER           := null  ; --�ɹ���Ա
        mt.MTDFLAG              := 'N'  ; --�깤��־��N����S�ɹ�Y�깤X���ϣ�
        mt.MTDCHKPER            := null  ; --��������
        mt.MTDCHKDATE           := null  ; --��������
        mt.MTDCHKMEMO           := null  ; --���ս��
        mt.MTDMID               := mi.miid  ; --ԭˮ����
        mt.MTDMCODE             := mi.micode  ; --ԭ���Ϻ�
        mt.MTDMDIDO             := MD.MDID  ; --ԭ������
        mt.MTDMDIDN             := MD.MDID  ; --�±�����
        mt.MTDCNAME             := ci.CINAME  ; --ԭ�û���
        mt.MTDMADRO             := mi.miadr  ; --ԭˮ���ַ
        mt.MTDCALIBERO          := md.mdcaliber  ; --ԭ��ھ�
        mt.MTDBRANDO            := md.mdbrand  ; --ԭ����
        mt.MTDMODELO            := md.mdmodel  ; --ԭ���ͺ�
        mt.MTDMNON              := md.mdno ; --�±����
        mt.MTDCALIBERN          := null  ; --�±�ھ�
        mt.MTDBRANDN            := null  ; --�±���
        mt.MTDMODELN            := null  ; --�±��ͺ�
        mt.MTDPOSITIONO         := mi.miposition  ; --ԭ��λ����
        mt.MTDSIDEO             := mi.miside  ; --ԭ��λ
        mt.MTDMNOO              := md.mdno  ; --ԭ�����
        mt.MTDMADRN             := null  ; --�±�
        mt.MTDPOSITIONN         := null  ; --�±�
        mt.MTDSIDEN             := null  ; --�±�
        mt.MTDUNINSPER          := null  ; --���Ա
        mt.MTDUNINSDATE         := null  ; --�������
        mt.MTDSCODE             := mr.mrecode  ; --���ڶ���
        mt.MTDSCODECHAR         := mr.mrecodechar ;
        mt.MTDECODE             := null  ; --������
        mt.MTDADDSL             := null  ; --����
        mt.MTDREINSPER          := null  ; --����Ա
        mt.MTDREINSDATE         := null  ; --��������
        mt.MTDREINSCODE         := null  ; --�±�����
        mt.MTDREINSDATEO        := null  ; --�ع���������
        mt.MTDMSTATUSO          := mi.mistatus  ; --�ع�ˮ��״̬
        mt.MTDAPPNOTE           := null  ; --����˵��
        mt.MTDFILASHNOTE        := null  ; --�쵼���
        mt.MTDMEMO              := '�������ϱ�ת��'; --��ע
        mt.mtdycchkdate         := md.mdcycchkdate;
        mt.mtface1 := mr.mrface;--ˮ�����
        mt.mtface2 := mr.mrface2;--��������
        mt.miface4 := mr.mrface4;--������
        insert into metertransdt values mt;
        --��ǳ���ƻ�ת����־
      update meterread set mriftrans='Y' , MRCHKFLAG='Y'
      , MRIFSUBMIT='N',MRPRIVILEGEPER=v_id   where mrid=p_mrid;

      end if;
      while c_exist%found loop
        update metertranshd set mthhot=nvl(mthhot,0)+1 where current of c_exist;
        fetch c_exist into mh;
      end loop;
      close c_exist;
    end if;
    --commit;
  exception when others then
    if c_exist%isopen then
       close c_exist;
    end if;
    --rollback;
    raise_application_error(errcode,sqlerrm);
  end sp_mrmrifsubmit;



  --��ͷ�������
  PROCEDURE SP_METERTRANS_MAIN(
                          P_MTHNO IN VARCHAR2, --������ˮ
                          P_PER   IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2  --�ύ��־
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and t.mtdflag='N' for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��ͷ��Ϣ������!');
    END;
    --������Ϣ�Ѿ���˲�������
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --�����깤
      SP_METERTRANS_ONE(P_PER, MD,'N');--20131125

    end loop;
    close c_md;
    --���µ�ͷ
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
    --��������
    update kpi_task t set t.do_date=sysdate,t.isfinish='Y' where t.report_id=trim(P_MTHNO);
    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;

 --���������������
  PROCEDURE SP_METERTRANS_BY(
                          P_MTHNO IN VARCHAR2, --������ˮ
                          P_mtdrowno IN VARCHAR2,--�к�
                          P_PER   IN VARCHAR2, --����Ա
                          P_COMMIT IN VARCHAR2  --�ύ��־
                         ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    cursor c_md is
    SELECT *   FROM METERTRANSDT t WHERE MTDNO = P_MTHNO and mtdrowno=P_mtdrowno for update nowait;
  BEGIN
    BEGIN
      SELECT * INTO MH FROM METERTRANSHD WHERE MTHNO = P_MTHNO for update nowait;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '��ͷ��Ϣ������!');
    END;
    if MH.MTHSHFLAG ='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
    end if;

    open c_md;
    loop fetch c_md into md;
    exit when c_md%notfound or c_md%notfound is null;
      --������Ϣ�Ѿ���˲�������
    if MD.Mtdflag='Y' then
      RAISE_APPLICATION_ERROR(ERRCODE, '������ϸ�Ѿ����,�����ظ����!');
    end if;
      --�����깤
      SP_METERTRANS_ONE(P_PER, MD,'N');----20131125
    end loop;
    close c_md;
   /* --���µ�ͷ
    UPDATE METERTRANSHD SET MTHSHDATE= SYSDATE ,MTHSHPER=P_PER ,MTHSHFLAG='Y'  WHERE MTHNO=P_MTHNO ;
*/


    IF P_COMMIT='Y' THEN
       COMMIT;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(errcode,sqlerrm);
  END;


  --�����嵥����ϸ��ˣ���������ֶ�Ϊ����� METERTRANSDT �� MTBK8
  PROCEDURE SP_METERTRANS_ONE(p_per in VARCHAR2,-- ����Ա
                             P_MD   IN METERTRANSDT%ROWTYPE, --�����б��
                             p_commit in varchar2 --�ύ��־
                             ) AS
    MH METERTRANSHD%ROWTYPE;
    MD METERTRANSDT%ROWTYPE;
    MI METERINFO%ROWTYPE;
    CI CUSTINFO%ROWTYPE;
    MC METERDOC%ROWTYPE;
    MA METERADDSL%ROWTYPE;
    MK METERTRANSROLLBACK%ROWTYPE;
    MR METERREAD%ROWTYPE;
    mdsl meteraddsl%ROWTYPE;
    V_COUNT NUMBER(4);
    v_number number(10);
    v_crhno  varchar2(10);
    v_omrid  varchar2(20);
    o_str varchar2(20);

  begin
    MD :=P_MD;
    BEGIN
      SELECT * INTO MI  FROM METERINFO WHERE MIID=P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ�����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO CI  FROM CUSTINFO WHERE  CUSTINFO.CIID  =MI.MICID;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '�û����ϲ�����!');
    END;
    BEGIN
      SELECT * INTO MC  FROM METERDOC WHERE MDMID =P_MD.Mtdmid;
    EXCEPTION WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, 'ˮ������!');
    END;

    if mi.mircode != md.MTDSCODE then
      raise_application_error(errcode,'���ڳ��������仯�����������ڳ���');
    end if;

    --F�������
    if P_MD.MTBK8 = bt������� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;


      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO    ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      --���
      --?????
    --�޸��û�״̬ custinfo
      UPDATE custinfo  t
      set t.cistatus=c���� where CIID= mi.micid ;

    ---- METERINFO ��Ч״̬ --״̬���� --״̬���� ��yujia 20110323��
      update METERINFO
      set MISTATUS =m����,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8,MIUNINSDATE=sysdate
      where MIID=P_MD.Mtdmid;
    -----METERDOC  ��״̬ ��״̬����ʱ��  ��yujia 20110323��

      update METERDOC set MDSTATUS =m����,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;
    elsif P_MD.MTBK8 = bt�ھ���� then
      -- METERINFO ��Ч״̬ --״̬���� --״̬����

      --���ݼ�¼�ع���Ϣ METERTRANSROLLBACK
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      update METERINFO
      set MISTATUS      = m���� ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER, --������
          mitype = p_md.mtdmtypen  --����
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC
      set MDSTATUS =m���� ,
          mdcaliber =P_MD.MTDCALIBERN,
          mdno = p_md.mtdmnon, ---���ͺ�
          MDSTATUSDATE=sysdate,
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;
/*      --METERTRANSDT �ع��������� �ع�ˮ��״̬   ���ݼ�¼�ع���Ϣ METERTRANSROLLBACK �Ѵ���
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE
      WHERE Mtdmid=MI.MIID;*/


      --���
      --?????


    elsif P_MD.MTBK8 = btǷ��ͣˮ then

      --���ݼ�¼�ع���Ϣ
      delete    METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      update METERINFO set MISTATUS =m��ͣ ,MISTATUSDATE=sysdate,MISTATUSTRANS=P_MD.MTBK8
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC set MDSTATUS =m��ͣ ,MDSTATUSDATE=sysdate
      where MDMID=P_MD.Mtdmid;


      --���
      --?????


    elsif P_MD.MTBK8 = btУ�� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO ��Ч״̬ --״̬���� --״̬����
      --�ݲ����±��ڶ���     ,MIRCODE=P_MD.MTDREINSCODE
      update METERINFO
      set MISTATUS      = m���� ,
          MISTATUSDATE  = sysdate,
          MISTATUSTRANS = P_MD.MTBK8,
          MIREINSDATE   = P_MD.MTDREINSDATE
      where MIID=P_MD.Mtdmid;
      --METERDOC  ��״̬ ��״̬����ʱ��
      update METERDOC
      set MDSTATUS     = m���� ,
          MDSTATUSDATE = sysdate,
          MDCYCCHKDATE = P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;


      --���
      --?????
    elsif P_MD.MTBK8 = bt��װ then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;



      --�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS =m���� ,--״̬
          MISTATUSDATE=sysdate,--״̬����
          MISTATUSTRANS=P_MD.MTBK8,--״̬����
          MIADR= P_MD.MTDMADRN,--ˮ���ַ
          MISIDE= P_MD.MTDSIDEN,--��λ
          MIPOSITION = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIREINSCODE = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE =  P_MD.MTDREINSDATE , --��������
          MIREINSPER = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS =m���� ,--״̬
          MDSTATUSDATE=sysdate,--״̬����ʱ��
          MDNO=P_MD.MTDMNON,--�����
          MDCALIBER=P_MD.MTDCALIBERN,--��ھ�
          MDBRAND=P_MD.MTDBRANDN,--����
          MDMODEL=P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE=P_MD.MTDREINSDATE
      where MDMID=P_MD.Mtdmid;



      --���
      --????

    elsif P_MD.MTBK8 = bt���ϻ��� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;
      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

       -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m���� ,--״̬
          MISTATUSDATE  = sysdate,--״̬����
          MISTATUSTRANS = P_MD.MTBK8,--״̬����
          --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
          --MISIDE        = P_MD.MTDSIDEN,--��λ
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIRCODE=P_MD.MTDREINSCODE ,
          MIRCODECHAR =P_MD.MTDREINSCODECHAR,
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS     =m���� ,--״̬
          MDSTATUSDATE =sysdate,--��״̬����ʱ��
          MDNO         =P_MD.MTDMNON,--�����
          MDCALIBER    =P_MD.MTDCALIBERN,--��ھ�
          MDBRAND      =P_MD.MTDBRANDN,--����
          MDMODEL      =P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE =P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;

      --���
      --??????

    elsif P_MD.MTBK8 = bt���ڻ��� then

      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;
      --�������� METERADDSL
      SELECT SEQ_METERADDSL.NEXTVAL INTO MA.MASID FROM DUAL;
     -- MD.MASID           :=     ;--��¼��ˮ��
      MA.MASSCODEO       :=P_MD.MTDSCODE     ;--�ɱ����
      MA.MASECODEN       :=P_MD.MTDECODE     ;--�ɱ�ֹ��
      MA.MASUNINSDATE    :=P_MD.MTDUNINSDATE     ;--�������
      MA.MASUNINSPER     := P_MD.MTDUNINSPER    ;--�����
      MA.MASCREDATE      :=SYSDATE     ;--��������
      MA.MASCID          :=MI.MICID     ;--�û����
      MA.MASMID          :=MI.MIID     ;--ˮ����
      MA.MASSL           :=P_MD.MTDADDSL     ;--����
      MA.MASCREPER       :=p_per     ;--������Ա
      MA.MASTRANS        :=P_MD.MTBK8     ;--�ӵ�����
      MA.MASBILLNO       :=P_MD.MTDNO     ;--������ˮ
      MA.MASSCODEN       :=P_MD.MTDREINSCODE     ;--�±����
      MA.MASINSDATE      :=P_MD.MTDREINSDATE     ;--װ������
      MA.MASINSPER       :=P_MD.MTDREINSPER      ;--װ����
      INSERT INTO   METERADDSL VALUES MA;

      -- METERINFO�ݲ����±��ڶ���  MIRCODE=P_MD.MTDREINSCODE ,
      update METERINFO
      set MISTATUS      = m���� ,--״̬
          MISTATUSDATE  = sysdate,--״̬����
          MISTATUSTRANS = P_MD.MTBK8,--״̬����
          --MIADR         = P_MD.MTDMADRN,--ˮ���ַ
          --MISIDE        = P_MD.MTDSIDEN,--��λ
          --MIPOSITION    = P_MD.MTDPOSITIONN ,--ˮ���ˮ��ַ
          MIREINSCODE   = P_MD.MTDREINSCODE ,--�������
          MIREINSDATE   = P_MD.MTDREINSDATE , --��������
          MIREINSPER    = P_MD.MTDREINSPER --������
      where MIID=P_MD.Mtdmid;
      --METERDOC
      update METERDOC
      set MDSTATUS      = m���� ,--״̬
          MDSTATUSDATE  = sysdate,--��״̬����ʱ��
          MDNO          = P_MD.MTDMNON,--�����
           MDCALIBER     = P_MD.MTDCALIBERN,--��ھ�
          MDBRAND       = P_MD.MTDBRANDN,--����
          MDMODEL      =P_MD.MTDMODELN,--���ͺ�
          MDCYCCHKDATE  = P_MD.MTDREINSDATE--
      where MDMID=P_MD.Mtdmid;
      --���
      --��������

    elsif P_MD.MTBK8 = bt���鹤�� then
      null;
    elsif P_MD.MTBK8 = bt��װ�ܱ� then
       null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
          insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmcode);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
      elsif P_MD.MTBK8 = bt��װ���� then
         null;
      /*if nvl(P_MD.MTDWMCOUNT,0) > 0 then
        tools.SP_BillSeq('100',v_crhno);
        insert into custreghd
        (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
        VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

        v_number := 0;
        loop
           insert into custmeterregdt
          (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
          CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
          CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
          MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
          MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
          MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
          MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
          MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR,mipid)
          VALUES(v_crhno,v_number + 1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
          '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
          P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
          MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
          '1','Y','Y','N','N','X','H',
          MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
          'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
          P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000',p_md.mtdmpid);
          v_number := v_number + 1;
          exit when v_number = P_MD.MTDWMCOUNT;
        end loop;
      end if;*/
    elsif  P_MD.MTBK8 = bt��װ��������� then
       null;
      /*tools.SP_BillSeq('100',v_crhno);

      insert into custreghd
      (CRHNO,CRHBH,CRHLB,CRHSOURCE,CRHSMFID,CRHDEPT,CRHCREDATE,CRHCREPER,CRHSHFLAG)
      VALUES(v_crhno,P_MD.MTDNO,'0',P_MD.MTBK8,P_MD.MTDSMFID,null,SYSDATE,p_per,'N');

      insert into custmeterregdt
      (CMRDNO,CMRDROWNO,CISMFID,CINAME,CINAME2,CIADR,CISTATUS,CISTATUSTRANS,
      CIIDENTITYLB,CIIDENTITYNO,CIMTEL,CITEL1,CITEL2,CITEL3,CICONNECTPER,
      CICONNECTTEL,CIIFINV,CIIFSMS,CIIFZN,MIADR,MISAFID,MISMFID,MIRTID,
      MISTID,MIPFID,MISTATUS,MISTATUSTRANS,MIRPID,MISIDE,MIPOSITION,
      MITYPE,MIIFCHARGE,MIIFSL,MIIFCHK,MIIFWATCH,MICHARGETYPE,MILB,
      MINAME,MINAME2,CICLASS,CIFLAG,MIIFMP,MIIFSP,MIIFCKF,MIUSENUM,MISAVING,
      MIIFTAX,MIINSCODE,MIINSDATE,MIPRIFLAG,MDSTATUS,MAIFXEZF,MIRCODE,MDNO,MDMODEL,
      MDBRAND,MDCALIBER,cmdchkper,MIINSCODECHAR)
      VALUES(v_crhno,1,MI.MISMFID,'���û�','���û�',CI.CIADR,'0',CI.CISTATUSTRANS,
      '1',CI.CIIDENTITYNO,P_MD.Mtdtel,CI.CITEL1,CI.CITEL2,CI.CITEL3,P_MD.Mtdconper,
      P_MD.Mtdcontel,'Y','N','Y',MI.MIADR,MI.MISAFID,MI.MISMFID,MI.MIRTID,
      MI.MISTID,MI.MIPFID,'1',MI.MISTATUSTRANS,MI.MIRPID,P_MD.Mtdsideo,P_MD.Mtdpositiono,
      '1','Y','Y','N','N','X','D',
      MI.MINAME,MI.MINAME2,1,'Y','N','N','N',1,0,
      'N',0,TRUNC(SYSDATE),'N','00','N',P_MD.Mtdreinscode,P_MD.Mtdmnoo,P_MD.Mtdmodelo,
      P_MD.Mtdbrando,P_MD.Mtdcalibero,P_MD.mtdchkper,'00000');*/
     elsif P_MD.MTBK8 = btˮ������ then
        null;
             /*-- METERINFO ��Ч״̬ --״̬���� --״̬����
                 update METERINFO
                         set MISTATUS      = m���� ,
                          MISTATUSDATE  = sysdate,
                          MISTATUSTRANS = P_MD.MTBK8,
                          MIPOSITION = P_MD.Mtdpositionn
                 where MIID=P_MD.Mtdmid;
                 -- meterdoc
                update METERDOC
                 set MDSTATUS     = m���� ,
                  MDSTATUSDATE = sysdate
                where MDMID=P_MD.Mtdmid;
      --METERTRANSDT �ع��������� �ع�ˮ��״̬
      update METERTRANSDT set MTDMSTATUSO =MI.MISTATUS , MTDREINSDATEO=MI.MISTATUSDATE

      WHERE Mtdmid=MI.MIID;
      --���ݼ�¼�ع���Ϣ
      delete METERTRANSROLLBACK where MTRBID=P_MD.MTDNO and MTRBROWNO =P_MD.MTDROWNO;

      MK.MTRBID                  :=P_MD.MTDNO       ;--������ˮ
      MK.MTRBROWNO               :=P_MD.MTDROWNO       ;--�к�
      MK.MTRBDATE                :=SYSDATE       ;--�ع���������
      MK.MTRBSTATUS              :=MI.MISTATUS       ;--״̬
      MK.MTRBSTATUSDATE          :=MI.MISTATUSDATE       ;--״̬����
      MK.MTRBSTATUSTRANS         :=MI.MISTATUSTRANS       ;--״̬����
      MK.MTRBRCODE               :=MI.MIRCODE       ;--���ڶ���
      MK.MTRBADR                 :=MI.MIADR       ;--���ַ
      MK.MTRBSIDE                :=MI.MISIDE       ;--��λ
      MK.MTRBPOSITION            :=MI.MIPOSITION       ;--ˮ���ˮ��ַ
      MK.MTRBINSCODE             :=MI.MIINSCODE       ;--��װ���
      MK.MTRBREINSCODE           :=MI.MIREINSCODE       ;--�������
      MK.MTRBREINSDATE           :=MI.MIREINSDATE       ;--��������
      MK.MTRBREINSPER            :=MI.MIREINSPER       ;--������
      MK.MTRBCSTATUS             :=CI.CISTATUS       ;--�û�״̬
      MK.MTRBCSTATUSDATE         :=CI.CISTATUSDATE       ;--״̬����
      MK.MTRBCSTATUSTRANS        :=CI.CISTATUSTRANS       ;--״̬����
      MK.MTRBNO                  :=MC.MDNO       ;--������
      MK.MTRBCALIBER             :=MC.MDCALIBER       ;--��ھ�
      MK.MTRBBRAND               :=MC.MDBRAND       ;--����
      MK.MTRBMODEL               :=MC.MDMODEL       ;--���ͺ�
      MK.MTRBMSTATUS             :=MC.MDSTATUS        ;--��״̬
      MK.MTRBMSTATUSDATE         :=MC.MDSTATUSDATE        ;--��״̬����ʱ��
      INSERT INTO METERTRANSROLLBACK VALUES MK;

      --�������� METERADDSL
      --���*/
    END IF;

    --��� ��������ѿ����Ѵ򿪣�����������0 ������� �������
 IF FSYSPARA('1102')='Y' THEN
    if P_MD.MTDADDSL >= 0 and P_MD.MTDADDSL is not null then        --��������0 �������
    --��������ӳ����
    v_omrid := to_char(sysdate,'yyyy.mm');
      sp_insertmr(p_per,to_char(sysdate,'yyyy.mm'), P_MD.MTBK8 , P_MD.MTDADDSL,P_MD.MTDSCODE,P_MD.MTDECODE,mi,v_omrid);

      if v_omrid is not null then --������ˮ�����ڿգ���ӳɹ�

           --���
           pg_ewide_meterread_01.Calculate(v_omrid);

          --��֮ǰ���õ�
           PG_ewide_RAEDPLAN_01.sp_useaddingsl(v_omrid, --������ˮ
                        MA.Masid     , --������ˮ
                           o_str     --����ֵ
                           ) ;

           INSERT INTO METERREADHIS
           SELECT * FROM METERREAD WHERE MRID=v_omrid ;
           DELETE METERREAD WHERE  MRID=v_omrid ;


    end if;
      MR :=null;
      --��ѯ����ƻ�������г���ƻ�û�г���Ϳ����޸ı�����ƻ��ڳ���
      BEGIN
      SELECT * INTO MR FROM METERREAD WHERE MRMCODE=mi.micode
      AND MRMONTH= TOOLS.fgetreadmonth(MI.MISMFID) ;
      EXCEPTION WHEN OTHERS THEN
      NULL;
      END;
      if mr.mrid is not null then
         if mr.mrreadok='N' THEN
         BEGIN
            UPDATE METERREAD T SET T.MRSCODE=NVL( MD.MTDREINSCODE,0  ) ,T.MRSCODECHAR=NVL( MD.MTDREINSCODE,0  )
            WHERE MRID=MR.MRID;
            COMMIT;
         EXCEPTION WHEN OTHERS THEN
            NULL;
         END ;
         END IF;
      end if;

    end if;
  END IF;

  --�����깤��־
   UPDATE METERTRANSDT SET MTDFLAG='Y', MTDSHDATE=sysdate,MTDSHPER=P_PER where MTDNO= MD.MTDNO AND MTDROWNO= MD.MTDROWNO ;
  --�ύ��־
  if p_commit='Y' THEN
    COMMIT;
   END IF;
  EXCEPTION WHEN OTHERS THEN
    ROLLBACK;
    raise;
  end;

procedure sp_insertmr(
                      p_pper in varchar2,--����Ա
                      p_month  in varchar2,--Ӧ���·�
                      p_mrtrans in varchar2,--��������
                      p_rlsl   in number,--Ӧ��ˮ��
                      p_scode  in number,--����
                      p_ecode  in number,--ֹ��
                      mi in meterinfo%rowtype,  --ˮ����Ϣ
                      omrid out meterread.mrid%type --������ˮ
                      ) as
  mrhis meterread%rowtype; --������ʷ��
  ci custinfo%rowtype; --�û���Ϣ
begin
    begin
      select * into ci from custinfo where ciid = mi.micid;
    exception when others then
      raise_application_error(-20010, '�û�������!');
    end;

      mrhis.MRID                       := fgetsequence('METERREAD')                        ; --��ˮ��
      omrid                            := mrhis.MRID         ;
      mrhis.MRMONTH                    := tools.fgetreadmonth(mi.mismfid)               ; --�����·�
      mrhis.MRSMFID                    := fgetmeterinfo(mi.miid,'MISMFID')                  ; --Ӫ����˾
      mrhis.MRBFID                     := mi.mibfid /*rth.RTHBFID*/                                      ; --���
      begin
      select  BFBATCH into mrhis.MRBATCH  from bookframe where bfid=mi.mibfid and bfsmfid=mi.mismfid                                      ;
      exception when others then
      mrhis.MRBATCH                    :=  1 ;     --��������
      end;

      begin
          select mrbsdate
          into  mrhis.MRDAY
          from meterreadbatch
          where mrbsmfid=mi.mismfid and
                mrbmonth=mrhis.MRMONTH and
                mrbbatch= mrhis.MRBATCH ;
        exception when others then
        mrhis.MRDAY                       := sysdate                                    ; --�ƻ�������
     /* if fsyspara('0039')='Y' then--�Ƿ񰴼ƻ������ո���ʵ�ʳ�����
             raise_application_error(ErrCode, 'ȡ�ƻ������մ�������ƻ��������ζ���');
       end if;*/
      end;
      mrhis.MRDAY                       := sysdate                                    ; --�ƻ�������
      mrhis.MRRORDER                   := mi.MIRORDER                                      ; --�������
      mrhis.MRCID                      := CI.CIID                                       ; --�û����
      mrhis.MRCCODE                    := CI.CICODE                                     ; --�û���
      mrhis.MRMID                      := MI.MIID                                       ; --ˮ����
      mrhis.MRMCODE                    := MI.MICODE                                     ; --ˮ���ֹ����
      mrhis.MRSTID                     := mi.MISTID                                        ; --��ҵ����
      mrhis.MRMPID                     := mi.MIPID                                         ; --�ϼ�ˮ��
      mrhis.MRMCLASS                   := mi.MICLASS                                       ; --ˮ����
      mrhis.MRMFLAG                    := mi.MIFLAG                                        ; --ĩ����־
      mrhis.MRCREADATE                 := sysdate                                          ; --��������
      mrhis.MRINPUTDATE                := sysdate                                          ; --�༭����
      mrhis.MRREADOK                   := 'Y'                                              ; --������־
      mrhis.MRRDATE                    := sysdate /*TO_DATE(p_month||'.15','YYYY.MM.DD') */                              ; --��������
     BEGIN
      SELECT MAX( T.BFRPER ) INTO mrhis.MRRPER  FROM BOOKFRAME T WHERE T.BFID=MI.MIBFID AND T.BFSMFID=MI.MISMFID;
     EXCEPTION WHEN OTHERS THEN
       mrhis.MRRPER                     := p_pper                                             ; --Ԥ�� �ճ���Ա
     END;
      mrhis.MRPRDATE                   := null                                             ; --�ϴγ�������
      mrhis.MRSCODE                    := p_scode                                          ; --���ڳ���
      mrhis.MRECODE                    := p_ecode                                          ; --���ڳ���
      mrhis.MRSL                       := p_rlsl                                           ; --����ˮ��
      mrhis.MRFACE                     := NULL                                             ; --ˮ�����
      mrhis.MRIFSUBMIT                 := 'Y'                                              ; --�Ƿ��ύ�Ʒ�
      mrhis.MRIFHALT                   := 'N'                                              ; --ϵͳͣ��
      mrhis.MRDATASOURCE               := p_mrtrans; --��������Դ�����񳭱�
      mrhis.MRIFIGNOREMINSL            := 'N'                                              ; --ͣ����ͳ���
      mrhis.MRPDARDATE                 := NULL                                             ; --���������ʱ��
      mrhis.MROUTFLAG                  := 'N'                                              ; --�������������־
      mrhis.MROUTID                    := NULL                                             ; --�������������ˮ��
      mrhis.MROUTDATE                  := NULL                                             ; --���������������
      mrhis.MRINORDER                  := NULL                                             ; --��������մ���
      mrhis.MRINDATE                   := NULL                                             ; --�������������
      mrhis.MRRPID                     := null                                             ; --�Ƽ�����
      mrhis.MRMEMO                     := '��������Ƿ��'                                     ; --����ע
      mrhis.MRIFGU                     := 'N'                                              ; --�����־
      mrhis.MRIFREC                    := 'N'                                              ; --�ѼƷ�
      mrhis.MRRECDATE                  := SYSDATE                                          ; --�Ʒ�����
      mrhis.MRRECSL                    := p_rlsl                                        ; --Ӧ��ˮ��
      mrhis.MRADDSL                    := 0                                                                                  ; --����
      mrhis.MRCARRYSL                  := 0                                                ; --��λˮ��
      mrhis.MRCTRL1                    := NULL                                             ; --���������λ1
      mrhis.MRCTRL2                    := NULL                                             ; --���������λ2
      mrhis.MRCTRL3                    := NULL                                             ; --���������λ3
      mrhis.MRCTRL4                    := NULL                                             ; --���������λ4
      mrhis.MRCTRL5                    := NULL                                             ; --���������λ5
      mrhis.MRCHKFLAG                  := 'N'                                              ; --���˱�־
      mrhis.MRCHKDATE                  := NULL                                             ; --��������
      mrhis.MRCHKPER                   := NULL                                             ; --������Ա
      mrhis.MRCHKSCODE                 := NULL                                             ; --ԭ����
      mrhis.MRCHKECODE                 := NULL                                             ; --ԭֹ��
      mrhis.MRCHKSL                    := NULL                                             ; --ԭˮ��
      mrhis.MRCHKADDSL                 := NULL                                             ; --ԭ����
      mrhis.MRCHKCARRYSL               := NULL                                             ; --ԭ��λˮ��
      mrhis.MRCHKRDATE                 := NULL                                             ; --ԭ��������
      mrhis.MRCHKFACE                  := NULL                                             ; --ԭ���
      mrhis.MRCHKRESULT                := NULL                                             ; --���������
      mrhis.MRCHKRESULTMEMO            := NULL                                             ; --�����˵��
      mrhis.MRPRIMID                   := mi.mipriid                                      ; --���ձ�����
      mrhis.MRPRIMFLAG                 := mi.mipriflag                                    ; --���ձ��־
      mrhis.MRLB                       := mi.milb                                         ; --ˮ�����
      mrhis.MRNEWFLAG                  := NULL                                             ; --�±��־
      mrhis.MRFACE2                    := NULL                                             ; --��������
      mrhis.MRFACE3                    := NULL                                             ; --�ǳ�����
      mrhis.MRFACE4                    := NULL                                             ; --����ʩ˵��
      mrhis.MRSCODECHAR                := to_char(p_scode)                                 ; --���ڳ���
      mrhis.MRECODECHAR                := to_char(p_ecode)                                ; --���ڳ���
      mrhis.MRPRIVILEGEFLAG            := 'N'                                              ; --��Ȩ��־(Y/N)
      mrhis.MRPRIVILEGEPER             := NULL                                             ; --��Ȩ������
      mrhis.MRPRIVILEGEMEMO            := NULL                                             ; --��Ȩ������ע
      mrhis.MRPRIVILEGEDATE            := NULL                                             ; --��Ȩ����ʱ��
      mrhis.MRSAFID                    := MI.MISAFID                                       ; --��������
      mrhis.MRIFTRANS                  := 'N'                                        ; --��������
      mrhis.MRREQUISITION              := 0                                                ; --֪ͨ����ӡ����
      mrhis.MRIFCHK                    := MI.MIIFCHK                                       ; --���˱�
    insert into meterread values mrhis;
end;

end;
/

