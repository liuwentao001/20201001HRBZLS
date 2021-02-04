CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_CHK_METERREAD" as
  --前三月均量
  procedure 前三月均量 as
    /*    insert into chk_meterread
          select seq_chk_meterread.nextval,
                 pfid,
                 'mrthreeje01',
                 50,
                 50,
                 20,
                 20,
                 500,
                 2
            from from priceframe
           where pfflag = 'Y'
             and pfstatus = 'Y';
    */
    cursor c_price is
      select pfid
        from priceframe
       where pfflag = 'Y'
         and pfstatus = 'Y'
       order by pfid;
  
    v_price priceframe%rowtype;
    cm      chk_meterread%rowtype;
  
  begin
    open c_price;
    loop
      fetch c_price
        into v_price.pfid;
      exit when c_price%notfound or c_price%notfound is null;
      cm.id        := seq_chk_meterread.nextval;
      cm.usetype   := v_price.pfid;
      cm.chk_field := 'mrthreesl';
      cm.scale_h   := 50;
      cm.scale_l   := 50;
      cm.use_h     := 20;
      cm.use_l     := 20;
      cm.total_h   := 500;
      cm.total_l   := 2;
    
      insert into chk_meterread values cm;
    
    end loop;
    close c_price;
    commit;
  
  end;

end;
/

