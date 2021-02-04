create or replace procedure hrbzls.sp_lsys_repair(v_mismfid in  varchar2, v_ciname in varchar2, v_miadr in varchar2,v_micode in varchar2,v_miname in varchar2,v_lb in varchar2 ,v_result out varchar2  )  is
v_count int;
v_MIYL3 varchar2(3);
vs_mismfid varchar(10);
begin
  if v_lb='1' then --ɾ����Ϣ
    select count(*) into v_count from RECLIST where RLMID=v_micode;
    if v_count>0 then
      v_result:='��Ӧ���˿��¼������ɾ��!';
      return;
    end if;

    delete from METERACCOUNT where  mamid=v_micode;
    if sqlcode<>0 then 
        v_result:='ɾ���û�������Ϣ��ʧ��!';
        rollback;
        return;
    end if;
    delete from meterdoc where mdmid=v_micode;
    if sqlcode<>0 then 
        v_result:='ɾ��ˮ����ʧ��!';
        rollback;
        return;
    end if;
    delete from meterread where mrcid=v_micode;
     if sqlcode<>0 then 
        v_result:='ɾ�������ʧ��!';
        rollback;
        return;
    end if;
    delete from  meterinfo where miid=v_micode;
    if sqlcode<>0 then 
        v_result:='ɾ���û���Ϣʧ��!';
        rollback;
        return;
    end if;
    delete from custinfo where  ciid=v_micode;
    if sqlcode<>0 then 
        v_result:='ɾ���û���Ϣ��ʧ��!';
        rollback;
        return;
    end if;

    v_result:='ɾ���ɹ�!';
    commit;
  else --��������
    select MIYL3,mismfid into v_MIYL3,vs_mismfid from meterinfo where miid=v_micode;    
    if sqlcode<>0 then 
        v_result:='��ѯ��Ϣ��ʧ��!';
        return;
    end if;
    
    if v_mismfid=vs_mismfid then 
        update meterinfo 
          set miadr=v_miadr,
          miposition=v_miadr,
          mismfid=v_mismfid,
          miname=v_miname
          where miid=v_micode;
        update custinfo
          set ciname=v_ciname,
          ciadr=v_miadr,
          CISMFID=v_mismfid
          where  ciid=v_micode;
          if sqlcode<>0 then 
            v_result:='����ʧ��!';
          else
            v_result:='���³ɹ�!';
            commit;
          end if;
     else --Ӫҵ����Ϣ���
        if v_MIYL3 is null then
          v_result:='�����ڻ������Ӫҵ���û�!';
          return;
        else
          select count(*) into v_count from PAYMENT where pcid=v_micode;
          if sqlcode<>0 then 
             v_result:='��ѯ�ɷѼ�¼��ʧ��!';
             return;
          end if;
          if v_count>0 then
             v_result:='���ڽɷѼ�¼�����������Ӫҵ��ҵ��!';
             return;
          end if;
           update meterinfo 
            set miadr=v_miadr,
            miposition=v_miadr,
            mismfid=v_mismfid,
            miname=v_miname
            where miid=v_micode;
           update custinfo
            set ciname=v_ciname,
           -- ciname2=v_ciname,
            ciadr=v_miadr,
            --ciconnectper=v_ciname,
            CISMFID=v_mismfid
            where  ciid=v_micode;
        end if;
      end if;
      if sqlcode<>0 then 
        v_result:='����ʧ��!';
      else
        v_result:='���³ɹ�!';
        commit;
      end if;  
   end if;
   EXCEPTION
  WHEN OTHERS THEN 
     v_result:='����ʧ��!';
     rollback;
     return;
    RAISE;
end sp_lsys_repair;
/

