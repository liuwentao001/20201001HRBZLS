CREATE OR REPLACE PROCEDURE HRBZLS."SP_ADJUST_201002" is
       p payment%rowtype;
       pl paidlist%rowtype;
       pd paiddetail%rowtype;

       p_znj payment%rowtype;
       pl_znj paidlist%rowtype;
       pd_znj paiddetail%rowtype;

       p_psf payment%rowtype;
       pl_psf paidlist%rowtype;
       pd_psf paiddetail%rowtype;

       v_memo varchar(50);


       CURSOR c_pay IS
      select * from payment
      where  pmonth='2010.02'
      and pdate >=trunc(to_date('2010.02.01','yyyy.mm.dd')) and pdate <trunc(to_date('2010.03.01','yyyy.mm.dd'))
      and pcd='CR' ;
    CURSOR c_pl(vpid varchar2) IS
      select * from paidlist where plpid = vpid and plznj >0;
    CURSOR c_pd(vplid varchar2) IS
      select * from paiddetail where pdid = vplid   and pdpiid in('02','03') and pdznj >0;

begin
      v_memo :='2010.02违约金报成排水费调账';

      if c_pay%isopen then
         close c_pay;
      end if;
      open c_pay;
      loop
        fetch  c_pay into p;
        exit when c_pay%notfound;

        if c_pl%isopen then
         close c_pl;
      end if;

        open c_pl(p.pid);
        loop
          fetch c_pl into pl;
          exit when c_pl%notfound;

            if c_pd%isopen then
               close c_pd;
            end if;

          open  c_pd(pl.plid);
          loop
               fetch c_pd into pd;
               exit when c_pd%notfound;
               --code here;
               -- de 违约金
               --fgetsequence('PAIDLIST') plid
               --fgetsequence('PAYMENT') pid

               p_znj :=p;
               pl_znj := pl;
               pd_znj :=pd;

              pl_znj.plid := fgetsequence('PAIDLIST');
              p_znj.pid:=fgetsequence('PAYMENT');

               pd_znj.pdid:=pl_znj.plid;
               pd_znj.pdje:=0;
               pd_znj.pdsl:=0;
               pd_znj.pdmemo:=v_memo;

               pl_znj.plpid:=p_znj.pid;
               pl_znj.plsl:=0;
               pl_znj.plje:=0;
               pl_znj.plznj:=pd_znj.pdznj;
               --pl_znj.plsavingqc:=0;
               pl_znj.plsavingbq:=0;
               pl_znj.plsavingqm:=pl_znj.plsavingqc;
               pl_znj.plcd:='DE';
               pl_znj.plmemo:=v_memo;

                p_znj.pcd:='DE';
               --p_znj.psavingqc:=0;
               p_znj.psavingbq:=0;
               p_znj.psavingqm:=p_znj.psavingqc;
               p_znj.ppayment:=pd_znj.pdznj;
               p_znj.pifsaving:='N';
               p_znj.pchange:=0;
               p_znj.pmemo:=v_memo;

               insert into payment values p_znj;
               insert into paidlist values pl_znj;
               insert into paiddetail values pd_znj;



               --cr 排水费

               p_psf :=p;
               pl_psf := pl;
               pd_psf :=pd;

              pl_psf.plid := fgetsequence('PAIDLIST');
              p_psf.pid:=fgetsequence('PAYMENT');

               pd_psf.pdid:=pl_psf.plid;
               pd_psf.pdje:=pd.pdznj;
               pd_psf.pdsl:=0;
               pd_psf.pdznj:=0;

               pd_psf.pdmemo:=v_memo;

               pl_psf.plpid:=p_psf.pid;
               pl_psf.plsl:=0;
               pl_psf.plje:=pd.pdznj;
               pl_psf.plznj:=0;
               --pl_psf.plsavingqc:=0;
               pl_psf.plsavingbq:=0;
               pl_psf.plsavingqm:=pl_psf.plsavingqc;
               pl_psf.plcd:='CR';
               pl_psf.plmemo:=v_memo;

               p_psf.pcd:='CR';
               --p_psf.psavingqc:=0;
               p_psf.psavingbq:=0;
               p_psf.psavingqm:=p_psf.psavingqc;
               p_psf.ppayment:=pd.pdznj;
               p_psf.pifsaving:='N';
               p_psf.pchange:=0;
               p_psf.pmemo:=v_memo;

               insert into payment values p_psf;
               insert into paidlist values pl_psf;
               insert into paiddetail values pd_psf;




          end loop;
        end loop;

      end loop;

      commit;

end sp_adjust_201002;
/

