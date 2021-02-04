CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_GRAND" AS

���������·�              VARCHAR2(10);
������������              VARCHAR2(10);
��ʼ�·�                  VARCHAR2(10);
��ֹ�·�                  VARCHAR2(10);
�����������ɱ�־      VARCHAR2(10);  

--��������
  PROCEDURE APPROVE(P_BILLID IN VARCHAR2,
                    P_OPER IN VARCHAR2,
                    P_BMID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2) IS
    O_MRID VARCHAR2(200);
  BEGIN
  IF P_DJLB='r' THEN
     --��������������
    SP_GRANDTRANS(P_DJLB,
                  P_BILLID,
                  P_OPER,
                  'N');
  END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
      -- raise_application_error(errcode,sqlerrm);
  END APPROVE;

--�������������
PROCEDURE SP_GRANDTRANS(P_DJLB IN VARCHAR2,       --�������
                        P_BILLNO IN VARCHAR2,     --���ݺ�
                        P_OPER IN VARCHAR2,     --�����
                        P_COMMIT IN VARCHAR2      --��˱�־
                        ) IS
GH  GRANDBILLHD%ROWTYPE;
GD  GRANDBILLDT%ROWTYPE;
G   GRAND%ROWTYPE;

CURSOR C_GRAND IS 
SELECT * 
FROM GRANDBILLDT
WHERE GBDID=P_BILLNO
ORDER BY GBDROW;


BEGIN
--1��Ч�鵥������
--Ч�鵥ͷ
  BEGIN
    SELECT * INTO GH FROM GRANDBILLHD WHERE GBHID = P_BILLNO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '������ͷ��Ϣ������!');
  END;
--Ч�鵥��
  /*BEGIN
    SELECT * INTO GD FROM GRANDBILLDT WHERE GBDID = P_BILLNO;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '����������Ϣ������!');
  END;*/
--��鵥����Ϣ
  IF GH.GBHSHFLAG = 'Y' THEN
    RAISE_APPLICATION_ERROR(ERRCODE, '�����Ѿ����,�����ظ����!');
  END IF;
  
--2�����ݵ������ݸ����û�����
  OPEN C_GRAND;
  LOOP
    FETCH C_GRAND INTO GD;
    EXIT WHEN C_GRAND%NOTFOUND OR C_GRAND%NOTFOUND IS NULL;
    BEGIN
      SELECT * INTO G FROM GRAND WHERE GMICODE=GD.GBDCODE AND GBQFLAG='Y';
    EXCEPTION
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(ERRCODE, '�������в������û�['||GD.GBDCODE||']��Ϣ������!');
    END;
    --�������������
    IF G.GFLAG = 'Y' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '�û�['||GD.GBDCODE||']����������,�������ݣ�');
    END IF;
    
    --3�������������־����Ϣ
    UPDATE GRAND 
    SET GFLAG='Y',                      --������־
        GDATE=TRUNC(SYSDATE),           --��������
        GRANKID=GD.GBDRANKID,           --�´α�־
        GBILLID=GD.GBDID                --������ˮ��
    WHERE GMICODE=GD.GBDCODE
          AND GBQFLAG='Y';
    IF SQL%ROWCOUNT<=0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '�û�['||GD.GBDCODE||']���±���������ʧ�ܣ�');
    END IF;  
    --4�������û���Ϣ
    UPDATE METERINFO MI
    SET MI.MICOLUMN7 = GD.GBDRANKID
    WHERE MI.MICODE=GD.GBDCODE;
    IF SQL%ROWCOUNT<=0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '�û�['||GD.GBDCODE||']�����û���Ϣ��ʧ�ܣ�');
    END IF;
  END LOOP;
  CLOSE C_GRAND;

  --5�����µ�����Ϣ
  UPDATE GRANDBILLHD
  SET GBHSHDATE=TRUNC(SYSDATE),
      GBHSHPER=P_OPER,
      GBHSHFLAG='Y'
  WHERE GBHID=GH.GBHID;
  
  --�ύ��˱�־
  IF P_COMMIT='Y' THEN
     COMMIT;
  END IF;
  

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
END;


--��������
--P_GRANDID ����ID
/*********��ӳ�����ѣ�Ƿ�ѱ�����Ƿ�ѽ��********/
PROCEDURE SP_GRAND_FUNC(P_GRANDID IN VARCHAR2,  --�������κ�
                        P_SMFID   IN VARCHAR2,  --Ӫҵ��
                        P_BFID    IN VARCHAR2,  --���
                        P_CODE    IN VARCHAR2   --�û���
                        ) IS

type cursor_type is ref cursor;
c_rl1 cursor_type;
  
CURSOR C_RL IS
select gmicode,
       count(*),
       sum(rlsl),
       sum(rlje)
  from reclist,GRAND,meterinfo
   where rlmonth>=��ʼ�·�
   and rlmonth<=��ֹ�·�
   and rlpaidflag = 'N'
   and RLREVERSEFLAG='N'
   AND RLJE <> 0
   AND gmicode=rlmcode
   and gmicode=micode
   and GBQFLAG='Y'
   and GFLAG='N'
   --and ((mismfid = P_GRANDID and P_GRANDID is not null) or P_GRANDID is null)
   and ((mismfid = P_SMFID and P_SMFID is not null) or P_SMFID is null)
   and ((mibfid = P_BFID and P_BFID is not null) or P_BFID is null)
   and ((micode = P_CODE and P_CODE is not null) or P_CODE is null)
   
 group by gmicode;
 
V_G GRAND%ROWTYPE;
v_count   number(10);

--������������
v_qfbs    number(10);   --Ƿ�ѱ���
v_qfbsqy  varchar2(10); --Ƿ�ѱ������ñ�־
v_qfje    number(12,3); --Ƿ�ѽ��
v_qfjeqy  varchar2(10); --Ƿ�ѽ������
v_jflag   number(10);   --������־
v_sflag   number(10);   --������־
v_jmemo    varchar2(200);  --������ע
v_smemo    varchar2(200);  --������ע

--ƴ��sql
v_sql varchar2(4000);
v_where varchar2(500);
BEGIN
  
   
   --1��������ݳ�ʼ��
   select count(*) into v_count 
   from GRAND
   where GBQFLAG='Y';
   if v_count<=0 then
      rollback;
      raise_application_error(-20012, '�������������ݲ�����������������');
   end if;
   select nvl(spisedit,'#'),spvalue into v_qfbsqy,v_qfbs from syspara T where SPID='1107';
   select nvl(spisedit,'#'),spvalue into v_qfjeqy,v_qfje from syspara T where SPID='1108';
   v_sql := 'select gmicode,
       count(*),
       sum(rlsl),
       sum(rlje)
  from reclist,GRAND,meterinfo
   where rlmonth>='''||��ʼ�·�||'''
   and rlmonth<='''||��ֹ�·�||'''
   and rlpaidflag = ''N''
   and RLREVERSEFLAG=''N''
   AND RLJE <> 0
   AND gmicode=rlmcode
   and gmicode=micode
   and GBQFLAG=''Y''
   and GFLAG=''N''
   group by gmicode';
   --2����ѯ�û�Ƿ��������µ�GRAND����
    
   --
   IF P_GRANDID IS NOT NULL THEN
      v_where := v_where || ' AND GBILLID='''||P_GRANDID||'';
   END IF;
   
   --
   IF P_SMFID IS NOT NULL THEN
      v_where := v_where || ' AND MISMFID='''||P_SMFID||'';
   END IF;
   
   --
   IF P_BFID IS NOT NULL THEN
      v_where := v_where || ' AND MIBFID='''||P_BFID||'';
   END IF;
   
   --
   IF P_CODE IS NOT NULL THEN
      v_where := v_where || ' AND GMICODE='''||P_CODE||'';
   END IF;
   
   v_sql := v_sql || v_where;
   
   /*open c_rl;
   LOOP
       FETCH c_rl 
       INTO V_G.GMICODE,
            V_G.GQFBS,
            V_G.GQFSL,
            V_G.GQFJE;
       EXIT WHEN c_rl%NOTFOUND OR c_rl%NOTFOUND IS NULL;
       v_jflag := 0;
       v_sflag := 0;
       v_jmemo := '';
       v_smemo := '';
       --2.1�����±�������������
       update GRAND
       set GQFBS = NVL(V_G.GQFBS,0),
           GQFSL = NVL(V_G.GQFSL,0),
           GQFJE = NVL(V_G.GQFJE,0)
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       --2.2������������������������
       --Ƿ�ѱ��������Ƿ�����
       if v_qfbsqy='Y' and v_qfbs is not null then
          if V_G.GQFBS>=to_number(v_qfbs) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || 'Ƿ�ѳ���'||v_qfbs||'��';
          else
             v_smemo  := v_smemo || '��������'||v_qfbs||'��';
          end if;
       end if;
       if v_jmemo is not null then
          v_jmemo := v_jmemo||'/';
       end if;
       if v_smemo is not null then
          v_smemo := v_smemo||'/';
       end if;
       --Ƿ�ѽ�������Ƿ�����
       if v_qfjeqy='Y' and v_qfje is not null then
          if V_G.GQFJE>=to_number(v_qfje) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || 'Ƿ�ѳ���'||v_qfje||'Ԫ';
          else
             v_smemo  := v_smemo || '����Ƿ�ѵ���'||v_qfje||'Ԫ';
          end if;
       end if;
       
       if v_jflag>0 then
          --�轵��
          --��ǰĬ��ֻ��һ��
          --�ϴμ�������Ϊ��Ĭ��Ϊ3
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GMEMO=v_jmemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       else
          --������
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GMEMO=v_smemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       end if;
       COMMIT;
   end loop;
   close c_rl;*/
   
   open c_rl1 for v_sql;
   LOOP
       FETCH c_rl1 
       INTO V_G.GMICODE,
            V_G.GQFBS,
            V_G.GQFSL,
            V_G.GQFJE;
       EXIT WHEN c_rl1%NOTFOUND OR c_rl1%NOTFOUND IS NULL;
       v_jflag := 0;
       v_sflag := 0;
       v_jmemo := '';
       v_smemo := '';
       --2.1�����±�������������
       update GRAND
       set GQFBS = NVL(V_G.GQFBS,0),
           GQFSL = NVL(V_G.GQFSL,0),
           GQFJE = NVL(V_G.GQFJE,0)
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       --2.2������������������������
       --Ƿ�ѱ��������Ƿ�����
       if v_qfbsqy='Y' and v_qfbs is not null then
          if V_G.GQFBS>=to_number(v_qfbs) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || 'Ƿ�ѳ���'||v_qfbs||'��';
          else
             v_smemo  := v_smemo || '��������'||v_qfbs||'��';
          end if;
       end if;
       if v_jmemo is not null then
          v_jmemo := v_jmemo||'/';
       end if;
       if v_smemo is not null then
          v_smemo := v_smemo||'/';
       end if;
       --Ƿ�ѽ�������Ƿ�����
       if v_qfjeqy='Y' and v_qfje is not null then
          if V_G.GQFJE>=to_number(v_qfje) then
             v_jflag := v_jflag + 1;
             v_jmemo  := v_jmemo || 'Ƿ�ѳ���'||v_qfje||'Ԫ';
          else
             v_smemo  := v_smemo || '����Ƿ�ѵ���'||v_qfje||'Ԫ';
          end if;
       end if;
       
       if v_jflag>0 then
          --�轵��
          --��ǰĬ��ֻ��һ��
          --�ϴμ�������Ϊ��Ĭ��Ϊ3
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))-1,
           GMEMO=v_jmemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       else
          --������
          update GRAND
       set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))+1,
           GMEMO=v_smemo
       where GMICODE=V_G.GMICODE and
             GBQFLAG='Y' and
             GFLAG='N';
       end if;
       COMMIT;
   end loop;
   close c_rl1;
   
   --����δ��������
   update grand
   set GRANKID=TO_NUMBER(NVL(TRIM(GRRANKID),'3')),
       GCOLUMNL1=TO_NUMBER(NVL(TRIM(GRRANKID),'3'))
   where GBQFLAG='Y' and
         GFLAG='N' and
         GRANKID is null;
   commit;
   
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

--������������
PROCEDURE SP_GRAND_CREATE IS
V_G GRAND%ROWTYPE;

CURSOR C_IGRAND IS
SELECT     NULL, --��ˮ�� 
           MI.MICODE,                             --�ͻ����� 
           MI.MICOLUMN7,                          --����id 
           G.GDATE,                               --�ϴ�����ʱ�� 
           NULL,                                  --��������ʱ�� 
           'N',                                   --������־ 
           ��ʼ�·�,                              --��ʼ�·� *
           ��ֹ�·�,                              --��ֹ�·�  *
           MI.MICOLUMN7,                          --�´μ���id  
           'Y',                                   --���ڱ�־(������¸����ڽ�תʱ�ñ�־Ϊn)
           'N',                                   --���ڱ�־(������¸����ڽ�תʱ�ñ�־Ϊy) 
           NULL,                                  --Ƿ�ѱ��� 
           NULL,                                  --Ƿ�ѽ�� 
           NULL,                                  --���ڱ������ 
           NULL,                                  --ΥԼ����� 
           NULL,                                  --ΥԼ�� 
           NULL,                                  --�ɷѱ��� 
           NULL,                                  --�ɷѽ�����ΥԼ�𡢵����³��� 
           NULL,                                  --����Ԥ�� 
           NULL,                                  --���ۿۿ�δ�ɹ����� 
           NULL,                                  --���տۿ�δ�ɹ����� 
           NULL,                                  --��ע 
           NULL,                                  --���ݺ� 
           TRUNC(SYSDATE),                         --�������� 
           NULL,                                   --Ƿ��ˮ��
           GCOLUMNS1,
            GCOLUMNS2,
            GCOLUMNS3,
            GCOLUMNS4,
            GCOLUMNS5,
            GCOLUMNS6,
            GCOLUMNN1,
            GCOLUMNN2,
            GCOLUMNN3,
            GCOLUMNN4,
            GCOLUMNN5,
            MI.MICOLUMN7,
            GCOLUMNL2,
            GCOLUMNL3,
            GCOLUMNL4,
            GCOLUMNL5,
            GCOLUMND1,
            GCOLUMND2

   FROM METERINFO MI LEFT JOIN GRAND G ON (GSQFLAG='Y' AND MI.MICODE=G.GMICODE)
   WHERE MISTATUS='1';
BEGIN

  if �����������ɱ�־='Y' then
     rollback;
     raise_application_error(-20012, '���������Ѿ����ɣ�����ɾ����������');
  end if;  
--1���ϴ��������ݱ�־��ΪN
  UPDATE GRAND
  SET GSQFLAG='N'
  WHERE GSQFLAG='Y';
--2������������־��ΪN���ϴ�������־��ΪY
  UPDATE GRAND
  SET GSQFLAG='Y',
      GBQFLAG='N'
  WHERE GBQFLAG='Y';
--���ɱ�����������
  OPEN C_IGRAND;
  LOOP
       FETCH C_IGRAND INTO V_G;
       EXIT WHEN C_IGRAND%NOTFOUND OR C_IGRAND%NOTFOUND IS NULL;
       SELECT SEQ_GRANDID.NEXTVAL INTO V_G.GID FROM DUAL;
       INSERT INTO GRAND VALUES V_G;
  END LOOP;
  CLOSE C_IGRAND;
  --���±����������ɱ�־ΪY���ñ�־ΪY�����ظ���������
  update syspara
  set spvalue='Y'
  where spid='1109';  
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
    --raise_application_error(-20012, '��ʼ�����ݴ���!,�¼�������PG_EWIDE_GRAND.SP_GRAND_CREATE');
END;

--ɾ����������
PROCEDURE SP_GRAND_DELETE IS

v_count number(10);
BEGIN
      --1����鱾���Ƿ�������������
      select count(*) into v_count 
      from GRAND
      WHERE GFLAG='Y' AND
            GBQFLAG='Y';
      IF v_count>0 THEN
         rollback;
         raise_application_error(-20012, '�������ݲ�����ɾ�����Ѵ�����˵���');
      END IF;     
      --2��ɾ����������
      delete GRAND
      where GBQFLAG='Y';
      --3�����±������ݱ�־ 
      update syspara
      set spvalue='N'
      where spid='1109'; 
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

PROCEDURE SP_GRAND_CARRY IS

BEGIN
--1.�����������ύΪ�ϴ�
update grand
set GSQFLAG='N'
where GSQFLAG='Y';
update grand
set GBQFLAG='N',
    gsqflag='Y'
where GBQFLAG='Y';
--2.���������·�
update syspara
set SPVALUE=��ֹ�·�
where spid='1105';
null;
exception
  when others then
    rollback;
    RAISE_APPLICATION_ERROR(ERRCODE, SQLERRM);
END;

BEGIN
���������·�              := FSYSPARA('1105');
������������              := FSYSPARA('1106');
��ʼ�·�                  := to_char(add_months(to_date(FSYSPARA('1105'),'yyyy.mm'),1),'yyyy.mm');
��ֹ�·�                  := to_char(add_months(to_date(FSYSPARA('1105'),'yyyy.mm'),������������),'yyyy.mm');
�����������ɱ�־          := FSYSPARA('1109');

END PG_EWIDE_GRAND;
/

