create or replace procedure hrbzls.SP_���ձ�ά��1(v_miid in varchar2, v_ywbz in char,v_MIPRIID in varchar2)  is
--v_miid �ӱ��
--v_ywbz����ҵ��
--v_MIPRIIDĿ�ĺ��ձ��
   vs_MIPRIFLAG  char;
    ERRCODE CONSTANT INTEGER := -20012;
    v_row number:=0;
    vs_MIPRIID varchar2(10);
    vs_MIIFTAX1 varchar2(10);
    vs_MIIFTAX2 varchar2(10);
    vs_mipfid1 varchar2(10);
    vs_mipfid2 varchar2(10);
begin
  if v_ywbz='Y' THEN  ---�ϻ���־ 
    select MIPRIFLAG,MIPRIID into vs_MIPRIFLAG,vs_MIPRIID from meterinfo where miid=v_miid;
    if vs_MIPRIFLAG='Y' THEN
          RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'�Ǻ����ӱ�,���Ȳ�ֺ��ٺϻ�' );   
    else
        if v_MIPRIID= v_miid then
          RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'�����Լ����Լ��ϻ�' );   
        end if;
    END IF;
    select count(CIID) into v_row from CUSTCHANGEHD,CUSTCHANGEdt WHERE CCHNO=CCDNO and  CCHLB='Y' and nvl(CCHSHFLAG,'N')='N' and
    CIID= v_miid;
    IF v_row>0 THEN 
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'���ں��ձ���,��ȷ�Ϻ��ٽ�����Ӧ��������' );
    END IF;
    select  MIIFTAX,mipfid into vs_MIIFTAX1,vs_mipfid1 from meterinfo where miid=v_miid;
    select  MIIFTAX,mipfid into vs_MIIFTAX2,vs_mipfid2 From  meterinfo where miid=v_MIPRIID;
    if vs_MIIFTAX1<>vs_MIIFTAX2 then  
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'��ϻ���ֵ˰״̬��һ��,��ȷ�Ϻ��ٽ�����Ӧ��������' );
    END IF;
    if vs_mipfid1<>vs_mipfid2 AND vs_MIIFTAX1='Y' AND vs_MIIFTAX2='Y'  then  
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'��ϻ�ˮ�۲�һ��,��ȷ�Ϻ��ٽ�����Ӧ��������' );
    END IF;
    
  --  SELECT COUNT(MIID) INTO v_row from meterinfo  where MIPRIID=v_MIPRIID and MIPRIFLAG='Y' and miid<>MIPRIID;
  --  20141215���� hb �����жϴ���
   SELECT COUNT(MIID) INTO v_row from meterinfo  where miid=v_MIPRIID and MIPRIFLAG='Y' and miid<>MIPRIID;
    if v_row>0  then
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_MIPRIID||'�Ǻ��ձ��ӱ�,������Ϊ������в���' );
    end if;
  END IF;
  if v_ywbz='N' THEN   --��ֱ�־
    select MIPRIFLAG,MIPRIID into vs_MIPRIFLAG,vs_MIPRIID from meterinfo where miid=v_miid;
    if vs_MIPRIFLAG='N' THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'���Ǻ��ձ�״̬' );
    else
       if vs_MIPRIID=v_miid then
         RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'���Ǻ��ձ��ӱ�,���ܽ��д��ֲ��' );
       else
         if vs_MIPRIID<>v_MIPRIID then
            RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'�ĺ�������Ų��Ǵ˺�,���ܽ��д��ֲ��' );
         end if;
       end if;
    END IF;
    select count(CIID) into v_row from CUSTCHANGEHD,CUSTCHANGEdt WHERE CCHNO=CCDNO and  CCHLB='Y' and nvl(CCHSHFLAG,'N')='N' and
    CIID= v_miid;
    IF v_row>0 THEN 
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'���ں��ձ���,��ȷ�Ϻ��ٽ�����Ӧ��������' );
    END IF;
    select count(rlcid) INTO v_row from reclist where rlje>0 and rlcid=v_miid and RLPAIDFLAG='N' AND RLREVERSEFLAG='N';
    IF V_ROW>0 THEN
       RAISE_APPLICATION_ERROR(ERRCODE, '���ݲ��ܱ���,���û�:'||v_miid||'����Ƿ�ɼ�¼,���ܽ��к��ձ���' );
    END IF;
  end if;
end SP_���ձ�ά��1;
/

