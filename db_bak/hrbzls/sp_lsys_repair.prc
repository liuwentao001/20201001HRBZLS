create or replace procedure hrbzls.sp_lsys_repair(v_mismfid in  varchar2, v_ciname in varchar2, v_miadr in varchar2,v_micode in varchar2,v_miname in varchar2,v_lb in varchar2 ,v_result out varchar2  )  is
v_count int;
v_MIYL3 varchar2(3);
vs_mismfid varchar(10);
begin
  if v_lb='1' then --删除信息
    select count(*) into v_count from RECLIST where RLMID=v_micode;
    if v_count>0 then
      v_result:='有应收账款记录，不许删除!';
      return;
    end if;

    delete from METERACCOUNT where  mamid=v_micode;
    if sqlcode<>0 then 
        v_result:='删除用户银行信息表失败!';
        rollback;
        return;
    end if;
    delete from meterdoc where mdmid=v_micode;
    if sqlcode<>0 then 
        v_result:='删除水表档案失败!';
        rollback;
        return;
    end if;
    delete from meterread where mrcid=v_micode;
     if sqlcode<>0 then 
        v_result:='删除抄表库失败!';
        rollback;
        return;
    end if;
    delete from  meterinfo where miid=v_micode;
    if sqlcode<>0 then 
        v_result:='删除用户信息失败!';
        rollback;
        return;
    end if;
    delete from custinfo where  ciid=v_micode;
    if sqlcode<>0 then 
        v_result:='删除用户信息表失败!';
        rollback;
        return;
    end if;

    v_result:='删除成功!';
    commit;
  else --更新数据
    select MIYL3,mismfid into v_MIYL3,vs_mismfid from meterinfo where miid=v_micode;    
    if sqlcode<>0 then 
        v_result:='查询信息表失败!';
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
            v_result:='更新失败!';
          else
            v_result:='更新成功!';
            commit;
          end if;
     else --营业所信息便更
        if v_MIYL3 is null then
          v_result:='不属于基建变更营业所用户!';
          return;
        else
          select count(*) into v_count from PAYMENT where pcid=v_micode;
          if sqlcode<>0 then 
             v_result:='查询缴费记录表失败!';
             return;
          end if;
          if v_count>0 then
             v_result:='存在缴费记录，不能做变更营业所业务!';
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
        v_result:='更新失败!';
      else
        v_result:='更新成功!';
        commit;
      end if;  
   end if;
   EXCEPTION
  WHEN OTHERS THEN 
     v_result:='操作失败!';
     rollback;
     return;
    RAISE;
end sp_lsys_repair;
/

