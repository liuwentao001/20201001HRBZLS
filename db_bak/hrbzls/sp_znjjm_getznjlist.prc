CREATE OR REPLACE PROCEDURE HRBZLS."SP_ZNJJM_GETZNJLIST" (p_code in varchar2,
                                                p_bfid in varchar2,
                                                p_mindate in date,
                                                p_maxdate in date,
                                                o_flag out varchar2) is
     cursor c_rl is
    select rlid,rlmid,rlmcode,rlzndate,rlje,rlgroup,rlsmfid,rldate
      from reclist a
     where ((rlmcode=p_code and rlbfid=p_bfid) or (rlmcode=p_code) or ( rlbfid=p_bfid))
       and (rldate>= p_mindate or p_mindate is null)
       and (rldate<= p_maxdate or p_maxdate is null)
       and RLCD = 'DE'
       AND rlpaidflag in ('N', 'V', 'K', 'W')
       AND RLOUTFLAG = 'N'
       AND RLJE > 0;

v_row number;
v_rl reclist%rowtype;
v_znj number(10,2);
v_zndate varchar2(20);
begin
   --�ͻ����룬��ᶼΪ��
   if p_code is null and p_bfid is null then
      o_flag := 'N';
      return;
   end if;


   --�жϿͻ�������ϵͳ�Ƿ����
   if p_code is not null then
     select count(*) into v_row from  meterinfo where micode=p_code;
     if v_row<=0 then
        o_flag := 'A';
        return;
     end if;
   end if;

  --�жϱ���Ƿ�Ϊ����
  if p_bfid is not null then
     select count(*) into v_row from bookframe where  bfid=p_bfid;
     if v_row<=0  then
        o_flag   := 'B';
        return;
     end if;
  end if;

  --�α��ȡ��Ϣ�����ɽ����0��
  delete pbparmtemp;
  open c_rl;
  loop
    fetch c_rl into v_rl.rlid,v_rl.rlmid,v_rl.rlmcode,v_rl.rlzndate,v_rl.rlje,v_rl.rlgroup,v_rl.rlsmfid,v_rl.rldate;
    exit when c_rl%notfound or c_rl%notfound is null;
       --�������ɽ��㷨����
       v_znj := pg_ewide_pay_01.getznjadj(v_rl.rlid,v_rl.rlje,v_rl.rlgroup,v_rl.rlzndate,v_rl.rlsmfid,sysdate);
       v_zndate := to_char(v_rl.rlzndate,'yyyy-mm-dd');
          insert into pbparmtemp(c1,c2,c3,c4,c5) values(v_rl.rlid,v_rl.rlmcode,v_rl.rlmid,v_zndate,v_znj);
  end loop;
    close c_rl;

  exception
  when others then
       null;
end ;
/

