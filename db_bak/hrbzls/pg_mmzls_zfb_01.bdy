CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_MMZLS_ZFB_01" is
       --�ṩˮ�ֱ��ⲿ���ù���
       /*������ p_MIPID  �ϼ�ˮ���ţ�
                       p_miid    �¼�ˮ����
                       p_type    ˮ�����������:
                                       ��AZ  �����ܱ�,DZ ɾ���ܱ�AF �����ֱ�,DF,ɾ���ֱ�
                      p_fttype  ˮ�ѷ�̯��ʽ, �ڻ����ֵ�����棨syscharlist��
       */
 PROCEDURE sp_mmzls_zfb_set_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2, --�¼�ˮ����
                                                   p_type in varchar2,--ˮ�����������
                                                   p_fttype in varchar2, --ˮ�ѷ�̯��ʽ
                                                   p_msg   out varchar2 --��Ϣ����
                                                    ) is
      cursor c_mi(vmid varchar2) is
      select * from meterinfo where miid = vmid; --����ֱ���׳�
      mi      meterinfo%rowtype;
     begin
       if p_type is null then
                 raise_application_error(errcode, '�ֱܷ�������Ͳ�����������');
        end if;
          if p_MIPID is not null then
              open c_mi(p_MIPID) ;
              fetch c_mi
              into mi;
               if c_mi%notfound or c_mi%notfound is null then
                raise_application_error(errcode, '��Ч�ϼ�ˮ����Ϣ' || p_MIPID);
               end if;
           else
              raise_application_error(errcode, '�ϼ�ˮ���Ų�������Ϊ��' || p_MIPID);
           end if;
                  if c_mi%isopen then
                 close c_mi;
                 end if;
          if p_miid is not null then
                 open c_mi(p_miid) ;
                fetch c_mi
                into mi;
               if c_mi%notfound or c_mi%notfound is null then
                raise_application_error(errcode, '��Ч�¼�ˮ����Ϣ' || p_miid);
               end if;
          end if;
                  if c_mi%isopen then
                 close c_mi;
                 end if;
          /*******ѡ���ֱܷ��������*********/
        if upper(p_type)='AZ' then
           if upper(mi.MICLASS)='FB' then
               raise_application_error(errcode, mi.miid || 'ˮ�����ڴ��ڷֱ�״̬,������ϵ��������ܱ�');
           end if;
           --�����ܱ�
           if p_fttype is null then
              raise_application_error(errcode, '�ֱܷ�ˮ�ѷ�̯��ʽ������������');
           end if;
          sp_mmzls_zfb_addzb_01(p_MIPID,p_fttype);
        end if;
         if upper(p_type)='DZ' then
         --ɾ���ܱ�
         sp_mmzls_zfb_deletezb_01(p_MIPID);
        end if;
          if upper(p_type)='AF' then
         --�����ֱ�
          sp_mmzls_zfb_addfb_01(p_MIPID,p_miid);
         end if;
         if upper(p_type)='DF' then
         --�����ֱ�
         sp_mmzls_zfb_deletefb_01(p_MIPID,p_miid);
        end if;
          exception
                when others then
                if c_mi%isopen then
                 close c_mi;
                 end if;
                     rollback;
             raise_application_error(errcode,'ִ�в���'+p_type+'ʧ��');
       end;
           --�����ܱ�
       --������p_MIPID  �ϼ�ˮ����
          --     p_fttype              ˮ�ѷ�̯��ʽ
        PROCEDURE sp_mmzls_zfb_addzb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_fttype in varchar2   --ˮ�ѷ�̯��ʽ
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
        --ɾ���ܱ�
       --������p_MIPID  �ϼ�ˮ����
        PROCEDURE sp_mmzls_zfb_deletezb_01(
                                                   p_MIPID in varchar2 --�ϼ�ˮ����
                                                    )is
         begin
                update meterinfo mi set MICLASS=PT, MIBOX=null,MIIFCHK='N'  where mi.miid=p_MIPID and  MICLASS=ZB;
                update meterinfo mi set MICLASS=PT , MIPID=null,MIFLAG='Y'  where mi.MIPID=p_MIPID and MICLASS=FB;
                exception
                   when others then
                      rollback;
         end;
       --�����ֱ�
        --����:p_MIPID �ϼ�ˮ����
         --          p_miid   �¼�ˮ����
         PROCEDURE sp_mmzls_zfb_addfb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2 --ˮ����
                                                    )is
         begin
                update meterinfo mi set MIPID=p_MIPID,  MICLASS=FB,MIFLAG='N'  where mi.miid=p_miid and MICLASS=PT;
                exception
                   when others then
                      rollback;
         end;
        --ɾ���ֱ�
        --����:p_MIPID �ϼ�ˮ����
         -- -         p_miid   �¼�ˮ����
        PROCEDURE sp_mmzls_zfb_deletefb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2 --ˮ����
                                                    ) is
         begin
                update meterinfo mi set MIPID=null,  MICLASS=PT  where mi.miid=p_miid and MICLASS=FB;
                exception
                   when others then
                      rollback;
         end;
                  --��ȡˮ��Ӫҵ��
         --������p_mid ˮ����
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

  --�ⲿ���ã��Զ����
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

 --�ƻ��ڳ��������ύ���
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
         /******* ��;���Ƿ���ѵ���������
                    ʱ�䣺2011-11-10
                   �޸��ˣ����Ⲩ
         *****/
         --and FChkMeterNeedCharge(MISTATUS,MIIFCHK,'1')='Y'
         --and mrifsubmit = 'Y'
         --and mrifhalt = 'N'
         and mrreadok = 'Y' --����״̬
       order by miclass desc,
                (case
                  when mipriflag = 'Y' and mipriid <> micode then
                   1
                  else
                   2
                end) asc;
    --�α��в�������Դ������ǰ��Դ���ܱ����²��Ҳ��ȴ����׳��쳣

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
    PG_EWIDE_METERREAD_01.wlog('�ύ��ѣ��ϼ�ˮ���ţ�' || P_MRPID);
  --  for i in 1 .. tools.FboundPara(P_MRPID) loop
     -- vmrpid  := tools.FGetPara(P_MRPID, i, 1);
     -- vsmfid := tools.FGetPara(P_MRPID, i, 2);
     vmrpid := P_MRPID;
     vsmfid  :=  vsmfid;
      PG_EWIDE_METERREAD_01.wlog('��������ϼ�ˮ���ţ�' || vmrpid || ' ...');
      
      select  count(*),connstr(mrmid)   into  v_readok  ,v_codelist 
      from meterread mr,meterinfo mi
        where
         mr.mrmid = mi.miid
         and   mi.mipid = vmrpid
         and mr.mrreadok='Y'
          and mi.MiCLASS = '3';
      IF V_READOK>0 THEN
         raise_application_error(errcode, '�ֱܷ��ӱ�δ�����ӱ��:'||v_codelist);
      END IF;
       ---�鿴�ܱ����Ϣ
       select  *  into  vmi   from meterinfo mi where mi.miid = vmrpid  and mi.miclass='2';
      ---ȥ�ܱ�ͷֱ��ˮ��ֻ�
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
        v_czsl  :=v_zbsl-v_fbsl;  --��ֵˮ��
        if v_czsl is null or v_czsl <0 then
                v_czsl  :=0;
        end if ;
        v_blsf  := f_mmzls_ftsf(vmrpid,v_czsl);  --��ֵ���
      open c_mr(vmrpid, vsmfid);
       loop
        fetch c_mr
          into vmrid,vmiclass,vmiid,vmircode,vmirecsl;
        exit when c_mr%notfound or c_mr%notfound is null;
        --���������¼����
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
                           mirecsl     = vmr.mrsl, --ȡ����ˮ����������
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
         --ȡӦ�յ���Ϣ
         --���������󣬽������Ʒ��û������¼��reclistnp
         --select  *  into v_rec   from reclist  rl where rl.rlmrid = vmrid;
         BEGIN
             select  *  into v_rec   from reclist  rl where rl.rlmrid = vmrid;
         exception
          when others then
             select  *  into v_rec   from reclistnp  rl where rl.rlmrid = vmrid;
         end;
        
        
         --yujia  20111111 �����ݴ���Ĺ��̣�
         if  v_czsl >0 and v_cnum >0 then  --
           if  vmi.mibox='BF' then -- ������̯
             v_ftje_bl :=   round(v_rec.RLREADSL/v_czsl * v_blsf,2);

             --- ����Ӧ����ϸ���ݵĽ��   v_recje
              update recdetail rd
                 set rd.rdysje = v_ftje_bl, rd.rdje = v_ftje_bl
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
               update recdetailnp rd
                 set rd.rdysje = v_ftje_bl, rd.rdje = v_ftje_bl
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 --- ����Ӧ����ϸ���ݵĽ��   v_recje
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

           else if vmi.mibox='PF' then                         --ƽ����̯
             v_ftje_pf  :=  round(1/v_cnum * v_blsf,2);
                --- ����Ӧ����ϸ���ݵĽ��   v_recje
                update recdetail rd
                 set rd.rdysje = v_ftje_pf, rd.rdje = v_ftje_pf
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 
                 update recdetailnp rd
                 set rd.rdysje = v_ftje_pf, rd.rdje = v_ftje_pf
               where rd.rdid = v_rec.rlid
                 and rd.rdmethod = 'ftf';
                 
                 --- ����Ӧ����ϸ���ݵĽ��   v_recje
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
                --- ����Ӧ����ϸ���ݵĽ��   v_recje
                --�ܱ��շ�
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
                 --- ����Ӧ����ϸ���ݵĽ��   v_recje
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
            PG_EWIDE_METERREAD_01.wlog('�����¼' || vmrid || '���ʧ�ܣ��ѱ�����');
        end;
      end loop;





      close c_mr;
      PG_EWIDE_METERREAD_01.wlog('---------------------------------------------------');
   -- end loop;

    PG_EWIDE_METERREAD_01.wlog('��ѹ��̴������');
    log := callogtxt;
  exception
    when others then
      rollback;
      log := callogtxt;
      raise_application_error(errcode, sqlerrm);
  end;

  --ȡ�ֱܷ����ѽ��
   --������p_mid ˮ����
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

