CREATE OR REPLACE PROCEDURE HRBZLS."SP_INIT_METERTRANSSTATES" is
       mth metertranshd%rowtype;
       mts metertransstates%rowtype;
       cursor c_metertranshd is select * from metertranshd  ;

begin


  if c_metertranshd%isopen then
          CLOSE c_metertranshd;
     end if;
     OPEN c_metertranshd;          --�ж��α��Ƿ��.������˽���رգ�Ȼ���ڴ�

     LOOP
     FETCH c_metertranshd INTO mth;     --ȡֵ
     EXIT WHEN c_metertranshd%NOTFOUND;     --����α�û��ȡ��ֵ���˳�ѭ��.
           --��������ΪN��ֵ��
           mts.mtsno := mth.mthno;
           mts.mtsshdate:=mth.mthcredate;
           mts.mtsshflag:='N';
           mts.mtsshper:=mth.mthcreper;
           mts.mtscredate:=mth.mthcredate;
           insert into metertransstates values mts;

           if mth.mthshflag is not null  and mth.mthshflag <>'N' then
              mts.mtsno := mth.mthno;
              mts.mtsshdate:=mth.mthshdate;
              mts.mtsshflag:=mth.mthshflag;
              mts.mtsshper:=mth.mthshper;
              mts.mtscredate:=mth.mthcredate;
              insert into metertransstates values mts;

           end if;
           commit;


     END LOOP;

end sp_init_metertransstates;
/

