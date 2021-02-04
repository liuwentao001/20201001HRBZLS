CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_MMZLS_ZFB_01" is
       --提供水分表外部调用过程
       /*参数： p_MIPID  上级水表编号，
                       p_miid    下级水表编号
                       p_type    水表级别操作类型:
                                       （AZ  新增总表,DZ 删除总表，AF 新增分表,DF,删除分表）
                      p_fttype  水费分摊方式, 在基础字典表里面（syscharlist）
       */
 PROCEDURE sp_mmzls_zfb_set_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2, --下级水表编号
                                                   p_type in varchar2,--水表级别操作类型
                                                   p_fttype in varchar2, --水费分摊方式
                                                   p_msg   out varchar2 --信息返回
                                                    ) is
      cursor c_mi(vmid varchar2) is
      select * from meterinfo where miid = vmid; --被锁直接抛出
      mi      meterinfo%rowtype;
     begin
       if p_type is null then
                 raise_application_error(errcode, '总分表操作类型参数传入有误');
        end if;
          if p_MIPID is not null then
              open c_mi(p_MIPID) ;
              fetch c_mi
              into mi;
               if c_mi%notfound or c_mi%notfound is null then
                raise_application_error(errcode, '无效上级水表信息' || p_MIPID);
               end if;
           else
              raise_application_error(errcode, '上级水表编号参数不能为空' || p_MIPID);
           end if;
                  if c_mi%isopen then
                 close c_mi;
                 end if;
          if p_miid is not null then
                 open c_mi(p_miid) ;
                fetch c_mi
                into mi;
               if c_mi%notfound or c_mi%notfound is null then
                raise_application_error(errcode, '无效下级水表信息' || p_miid);
               end if;
          end if;
                  if c_mi%isopen then
                 close c_mi;
                 end if;
          /*******选择总分表操作类型*********/
        if upper(p_type)='AZ' then
           if upper(mi.MICLASS)='FB' then
               raise_application_error(errcode, mi.miid || '水表现在处于分表状态,请解除关系后再添加总表');
           end if;
           --新增总表
           if p_fttype is null then
              raise_application_error(errcode, '总分表水费分摊方式参数传入有误');
           end if;
          sp_mmzls_zfb_addzb_01(p_MIPID,p_fttype);
        end if;
         if upper(p_type)='DZ' then
         --删除总表
         sp_mmzls_zfb_deletezb_01(p_MIPID);
        end if;
          if upper(p_type)='AF' then
         --新增分表
          sp_mmzls_zfb_addfb_01(p_MIPID,p_miid);
         end if;
         if upper(p_type)='DF' then
         --新增分表
         sp_mmzls_zfb_deletefb_01(p_MIPID,p_miid);
        end if;
          exception
                when others then
                if c_mi%isopen then
                 close c_mi;
                 end if;
                     rollback;
             raise_application_error(errcode,'执行操作'+p_type+'失败');
       end;
           --新增总表
       --参数：p_MIPID  上级水表编号
          --     p_fttype              水费分摊方式
        PROCEDURE sp_mmzls_zfb_addzb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_fttype in varchar2   --水费分摊方式
                                                    )is
         begin
                if upper(p_fttype)='ZS' then
                     update meterinfo mi set  MICLASS=ZB, MIBOX=p_fttype,MIIFCHK='N',MIFLAG='N'   where mi.miid=p_MIPID and  MICLASS=PT;
                else
                      update meterinfo mi set  MICLASS=ZB, MIBOX=p_fttype,MIFLAG='N'  where mi.miid=p_MIPID and  MICLASS=PT;
                end if;

                exception
                   when others then
                      rollback;
         end;
        --删除总表
       --参数：p_MIPID  上级水表编号
        PROCEDURE sp_mmzls_zfb_deletezb_01(
                                                   p_MIPID in varchar2 --上级水表编号
                                                    )is
         begin
                update meterinfo mi set MICLASS=PT, MIBOX=null,MIIFCHK='N'  where mi.miid=p_MIPID and  MICLASS=ZB;
                update meterinfo mi set MICLASS=PT , MIPID=null,MIFLAG='Y'  where mi.MIPID=p_MIPID and MICLASS=FB;
                exception
                   when others then
                      rollback;
         end;
       --新增分表
        --参数:p_MIPID 上级水表编号
         --          p_miid   下级水表编号
         PROCEDURE sp_mmzls_zfb_addfb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2 --水表编号
                                                    )is
         begin
                update meterinfo mi set MIPID=p_MIPID,  MICLASS=FB,MIFLAG='N'  where mi.miid=p_miid and MICLASS=PT;
                exception
                   when others then
                      rollback;
         end;
        --删除分表
        --参数:p_MIPID 上级水表编号
         -- -         p_miid   下级水表编号
        PROCEDURE sp_mmzls_zfb_deletefb_01(
                                                   p_MIPID in varchar2, --上级水表编号
                                                   p_miid in varchar2 --水表编号
                                                    ) is
         begin
                update meterinfo mi set MIPID=null,  MICLASS=PT  where mi.miid=p_miid and MICLASS=FB;
                exception
                   when others then
                      rollback;
         end;
                  --获取水表营业所
         --参数：p_mid 水表编号
         function f_mmzls_getsmfid(p_mid in varchar2)return varchar2
         as
          v_smfid varchar2(10) ;
          begin
            select mismfid into v_smfid from meterinfo mi where mi.miid=p_mid;
              return v_smfid;
              exception
                when others then
                   return null;
          end;

  --外部调用，自动算费
  procedure SUBMIT_ZFB(P_MRPID in varchar2) is
    vlog      clob;
    v_fscount number(10);
  begin
    if P_MRPID is not null then
      SUBMIT_ZFB(P_MRPID, vlog);
    end if;
  exception
    when others then
      raise;
  end;

 --计划内抄表批量提交算费
  procedure SUBMIT_ZFB(P_MRPID in varchar2, log out clob) is
    cursor c_mr(vmrpid in varchar2, vsmfid in varchar2) is
      select mrid,
      miclass,
      miid,
      MRECODE,
      MRSL
        from meterread, meterinfo
       where mrmid = miid
         and (MIPID = vmrpid or  miid=vmrpid)
        -- and mrsmfid = vsmfid
         and mrifrec = 'N'
         /******* 用途：是否算费的条件控制
                    时间：2011-11-10
                   修改人：刘光波
         *****/
         --and FChkMeterNeedCharge(MISTATUS,MIIFCHK,'1')='Y'
         --and mrifsubmit = 'Y'
         --and mrifhalt = 'N'
         and mrreadok = 'Y' --抄见状态
       order by miclass desc,
                (case
                  when mipriflag = 'Y' and mipriid <> micode then
                   1
                  else
                   2
                end) asc;
    --游标中不共享资源，解锁前资源不能被更新并且不等待并抛出异常

    vmrid  meterread.mrid%type;
    vmrpid  meterread.MRMID%type;
    vsmfid meterread.mrsmfid%type;
    vmi     meterinfo%rowtype;
    vmiclass meterinfo.miclass%type;
    vmiid    meterinfo.miid%type;
    vmircode   meterinfo.MIRCODE%type;
    vmirecsl     meterinfo.MIRECSL%type;
    v_fbsl   meterread.mrsl%type;
    v_zbsl   meterread.mrsl%type;
    v_czsl     meterread.mrsl%type;
    v_rec   reclist%rowtype;
    v_recd  recdetail%rowtype;
    v_blsf   reclist.rlje%type;
    v_ftje_bl  reclist.rlje%type;
     v_ftje_pf  reclist.rlje%type;
     v_ftje_zs  reclist.rlje%type;
     v_cnum   number(10);
     vmr meterread%rowtype;
    v_recje  reclist.rlje%type;
    v_readok number(10);
    v_codelist varchar2(4000);
    
  begin
    callogtxt := null;
    PG_EWIDE_METERREAD_01.wlog('提交算费，上级水表编号：' || P_MRPID);
  --  for i in 1 .. tools.FboundPara(P_MRPID) loop
     -- vmrpid  := tools.FGetPara(P_MRPID, i, 1);
     -- vsmfid := tools.FGetPara(P_MRPID, i, 2);
     vmrpid := P_MRPID;
     vsmfid  :=  vsmfid;
      PG_EWIDE_METERREAD_01.wlog('正在算费上级水表编号：' || vmrpid || ' ...');
      
      select  count(*),connstr(mrmid)   into  v_readok  ,v_codelist 
      from meterread mr,meterinfo mi
        where
         mr.mrmid = mi.miid
         and   mi.mipid = vmrpid
         and mr.mrreadok='Y'
          and mi.MiCLASS = '3';
      IF V_READOK>0 THEN
         raise_application_error(errcode, '总分表子表未抄表！子表号:'||v_codelist);
      END IF;
       ---查看总表的信息
       select  *  into  vmi   from meterinfo mi where mi.miid = vmrpid  and mi.miclass='2';
      ---去总表和分表的水量只差：
       select mr.mrsl
         into v_zbsl
         from meterread mr,meterinfo mi
        where mr.mrmid = mi.miid
            and mi.miid=vmrpid
           and  mi.MiCLASS  = '2';
       select sum(mr.mrsl)
         into v_fbsl
         from meterread mr,meterinfo mi
        where
         mr.mrmid = mi.miid
         and   mi.mipid = vmrpid
         and mr.mrsl>=to_number(fsyspara('1092'))
         and mr.mrsl>=0
          and mi.MiCLASS = '3';
       select  count(miid)  into v_cnum   from  meterinfo  mi  where mi.mipid= vmrpid and mi.MICLASS='3' and mi.MISTATUS='1';
        v_czsl  :=v_zbsl-v_fbsl;  --差值水量
        if v_czsl is null or v_czsl <0 then
                v_czsl  :=0;
        end if ;
        v_blsf  := f_mmzls_ftsf(vmrpid,v_czsl);  --差值金额
      open c_mr(vmrpid, vsmfid);
       loop
        fetch c_mr
          into vmrid,vmiclass,vmiid,vmircode,vmirecsl;
        exit when c_mr%notfound or c_mr%notfound is null;
        --单条抄表记录处理
        begin

        if v_blsf> 0 then
         PG_EWIDE_METERREAD_01.Calculate(vmrid);
         else
             if vmiclass='2' then
              select * into vmr from meterread mr where mr.mrid=vmrid;
                      if  vmr.mrdatasource ='1' or vmr.mrdatasource ='5' then
                         update meterinfo
                          set mircode     =   vmr.mrecode ,
                           mirecdate   = vmr.mrrdate,
                           mirecsl     = vmr.mrsl, --取本期水量（抄量）
                            miface      = vmr.mrface,
                            minewflag   = 'N',
                            mircodechar = vmr.mrecodechar
                           where MIID = vmr.mrmid;
                      end if;
          --    update meterinfo mi set mi.mircode=vmircode,mi.mirecsl=vmirecsl where mi.miid=vmiid;
              commit;
             else
                PG_EWIDE_METERREAD_01.Calculate(vmrid);
             end if;
         end if;
         --取应收的信息
         --哈尔滨需求，将抄表不计费用户账务记录到reclistnp
         --select  *  into v_rec   from reclist  rl where rl.rlmrid = vmrid;
         BEGIN
             select  *  into v_rec   from reclist  rl where rl.rlmrid = vmrid;
         exception
          when others then
             select  *  into v_rec   from reclistnp  rl where rl.rlmrid = vmrid;
         end;
        
        
         --yujia  20111111 在数据处理的过程；
         if  v_czsl >0 and v_cnum >0 then  --
           if  vmi.mibox='BF' then -- 比例分摊
             v_ftje_bl :=   round(v_rec.RLREADSL/v_czsl * v_blsf,2);

             --- 更新应收明细数据的金额   v_recje
              update recdetail rd
                 set rd.rdysje = v_ftje_bl, rd.rdje = v_ftje_bl
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
               update recdetailnp rd
                 set rd.rdysje = v_ftje_bl, rd.rdje = v_ftje_bl
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 --- 更新应收明细数据的金额   v_recje
               update reclist rl
                 set rl.rlje = (select sum(rdje)
                                  from recdetail rd
                                 where rd.rdid = v_rec.rlid)
                                 where rl.rlid= v_rec.rlid;
               update reclistnp rl
                 set rl.rlje = (select sum(rdje)
                                  from recdetailnp rd
                                 where rd.rdid = v_rec.rlid)
                                 where rl.rlid= v_rec.rlid;

           else if vmi.mibox='PF' then                         --平均分摊
             v_ftje_pf  :=  round(1/v_cnum * v_blsf,2);
                --- 更新应收明细数据的金额   v_recje
                update recdetail rd
                 set rd.rdysje = v_ftje_pf, rd.rdje = v_ftje_pf
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 
                 update recdetailnp rd
                 set rd.rdysje = v_ftje_pf, rd.rdje = v_ftje_pf
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 
                 --- 更新应收明细数据的金额   v_recje
                 update reclist rl
                   set rl.rlje = (select sum(rdje)
                                    from recdetail rd
                                   where rd.rdid = v_rec.rlid)
                                    where rl.rlid= v_rec.rlid;
                 update reclistnp rl
                   set rl.rlje = (select sum(rdje)
                                    from recdetailnp rd
                                   where rd.rdid = v_rec.rlid)
                                    where rl.rlid= v_rec.rlid;
              else

                  --   v_ftje_zs  :=  round(v_czsl,2) ;
                --- 更新应收明细数据的金额   v_recje
                --总表收费
                if vmiclass=2 then
                update meterread mr set mr.mrrecsl=v_czsl,mr.mrmemo='-' || v_fbsl where mr.mrid=vmrid;

                update recdetail rd
                 set rd.rdysje = round(v_czsl*RDYSDJ,2), rd.rdje = round(v_czsl*RDYSDJ,2),
                      rd.rdsl=v_czsl
               where rd.rdid = v_rec.rlid
                 and rd.RDPIID  in (select PIID from priceitem  t)  ;
                 
                 update recdetailnp rd
                 set rd.rdysje = round(v_czsl*RDYSDJ,2), rd.rdje = round(v_czsl*RDYSDJ,2),
                      rd.rdsl=v_czsl
               where rd.rdid = v_rec.rlid
                 and rd.RDPIID  in (select PIID from priceitem  t)  ;
                 --- 更新应收明细数据的金额   v_recje
              update reclist rl
                 set rl.rlje = (select sum(rdje)
                                  from recdetail rd
                                 where rd.rdid = v_rec.rlid),
                     rl.rlsl=v_czsl,
                     rl.RLINVMEMO='-' || v_fbsl
                                  where rl.rlid= v_rec.rlid;
                                  
               update reclistnp rl
                 set rl.rlje = (select sum(rdje)
                                  from recdetailnp rd
                                 where rd.rdid = v_rec.rlid),
                     rl.rlsl=v_czsl,
                     rl.RLINVMEMO='-' || v_fbsl
                                  where rl.rlid= v_rec.rlid;
                      end if;
                 end if;
           end if ;

         end if ;

          commit;
        exception
          when others then
            rollback;
            PG_EWIDE_METERREAD_01.wlog('抄表记录' || vmrid || '算费失败，已被忽略');
        end;
      end loop;





      close c_mr;
      PG_EWIDE_METERREAD_01.wlog('---------------------------------------------------');
   -- end loop;

    PG_EWIDE_METERREAD_01.wlog('算费过程处理完毕');
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      raise_application_error(errcode, sqlerrm);
  end;

  --取总分表的算费金额
   --参数：p_mid 水表编号
         function f_mmzls_ftsf(p_mpid in varchar2,p_mrsl in number )return number
         as
          v_je  varchar2(10) ;
          v_pfid varchar2(10);
          begin
            select mipfid into v_pfid from meterinfo mi where mi.miid=p_mpid and mi.miclass=2;
              v_je := fgetpricedj(v_pfid) * p_mrsl;
              return v_je;
              exception
                when others then
                   return 1;
          end;

 end;
/

