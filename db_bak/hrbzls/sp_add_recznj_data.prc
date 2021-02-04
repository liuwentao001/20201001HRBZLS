CREATE OR REPLACE PROCEDURE HRBZLS."SP_ADD_RECZNJ_DATA" (p_smonth in varchar2,p_emonth in varchar2) is
       -- p_row payment%rowtype;

        pl_row paidlist%rowtype;
        pd_row paiddetail%rowtype;
        rl_row reclist%rowtype;
        --rd_row recdetail%rowtype;

        v_month varchar2(7);

        cursor c_pl(cpmonth payment.pmonth%type) is select paidlist.* from  paidlist,payment where plpid=pid and pmonth = cpmonth;
        cursor c_pd(cplid paidlist.plid%type) is select * from paiddetail where pdid=cplid;
begin


   --errcode constant integer := -20012;
   if to_date(p_smonth,'yyyy.mm') > to_date(p_emonth,'yyyy.mm') then
     raise_application_error(-20012, '月份参数定义错误: '||sqlerrm);
   end if;



  v_month:=p_smonth;
  while v_month <= p_emonth
    loop

                  if c_pl%isopen then
                    close c_pl;
                  end if;
                  open c_pl(v_month);
                  loop
                    fetch c_pl into pl_row;
                    exit when c_pl%notfound or c_pl%notfound is null;
                    begin
                           begin
                              select * into rl_row from reclist where rlid = pl_row.plrlid;
                              exception when no_data_found then
                                        --raise_application_error(-20012, 'not exist rlid: '|| pl_row.plrlid ||'  ' ||sqlerrm);
                                update paidlist set plrecznj = 0  where plid = pl_row.plid;
                                update paiddetail set pdrecznj = 0  where pdid =pl_row.plid ;
                            end;
                         if rl_row.rlznj = 0 then
                             update paidlist
                             set plrecznj = 0 ,plsmfid=nvl(plsmfid,rl_row.rlsmfid)
                             where plid = pl_row.plid;
                             update paiddetail set pdrecznj = 0  where pdid =pl_row.plid ;
                          else
                              if c_pd%isopen then
                                 close c_pd;
                             end if;
                             open c_pd(pl_row.plid);
                             loop
                               fetch c_pd into pd_row;
                               exit when c_pd%notfound or c_pd%notfound is null;
                               begin
                                 begin
                                   -- sum()用于处理阶梯水价问题
                                    select sum(rdznj) into pd_row.pdrecznj from recdetail where rdid= rl_row.rlid and rdpiid = pd_row.pdpiid;
                                    exception when no_data_found then
                                           pd_row.pdrecznj:=0;
                                 end;
                                 update paiddetail set pdrecznj = nvl(pd_row.pdrecznj,0)
                                 where pdid = pd_row.pdid
                                 and pdpiid = pd_row.pdpiid;

                                 pl_row.plrecznj := nvl(pl_row.plrecznj,0) + pd_row.pdrecznj;
                               end;
                             end loop;
                             update paidlist
                             set plrecznj = nvl(pl_row.plrecznj,0),plsmfid=nvl(plsmfid,rl_row.rlsmfid)
                             where plid = pl_row.plid;




                        end if;

                    end;

             if mod(c_pl%rowcount,1000)=0 then
                commit;
             end if;

        end loop;

        v_month:= to_char(add_months(to_date(v_month,'yyyy.mm'),1),'yyyy.mm');
    end loop;




  commit;
  exception when others then
    rollback;
    raise;

end sp_add_recznj_data;
/

