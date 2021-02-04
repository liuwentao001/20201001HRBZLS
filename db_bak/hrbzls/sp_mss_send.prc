CREATE OR REPLACE PROCEDURE HRBZLS."SP_MSS_SEND" (p_sende in  varchar2,--发送者
                            p_bilephonenumber in  varchar2, --接收号码
                            p_bilephonetext in  varchar2, --发送内容
                            p_sendtype in  number ,      --模版类别
                            p_modeno in  varchar2   default '0'       --模版编号
                             ) is

 v_id  number ;
 v_c1  varchar2(11);
 v_c2  varchar2(140);
 v_bh  varchar2(6) ;
  cursor c_mn  is
         select c1,c2 from pbparmtemp;
 tr TSMSSENDCACHE%rowtype;
begin
   if p_modeno='0' then
       select TMDBH into v_bh from tsmssendmode where tmdlb=p_sendtype  and TMDTACITLY='Y';
   else
       v_bh :=  p_modeno;
   end if;
  if p_sendtype =101 THEN

        select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --记录编号
        tr.ssender           :=p_sende ;          --发送者标识
        tr.dbegintime        :=SYSDATE();         --请求时间
        tr.ntimingtag        :='0' ;              --定时标志
        tr.dtimingtime       := null;             --定时发送时间
        tr.ncontenttype      := p_sendtype;       --短信类型
        tr.exNumber          := null ;            --扩展号码
        tr.ssendno           :=p_bilephonenumber ;--接收号码
        tr.ssmsmessage       :=p_bilephonetext ;  --发送信息
        tr.cflag             :='N' ;              --处理标志
        tr.RETURNFLAG        :=null ;             --处理结果
        tr.ismgstatus        :=null;              --网管返回值
        tr.statustime        :=null;              --网管响应状态

        insert into TSMSSENDCACHE values  tr ;

 elsif p_sendtype =102 THEN

open c_mn;
fetch c_mn into v_c1 ,v_c2 ;
  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --记录编号
        tr.ssender           :=p_sende ;          --发送者标识
        tr.dbegintime        :=SYSDATE();         --请求时间
        tr.ntimingtag        :='0' ;              --定时标志
        tr.dtimingtime       := null;             --定时发送时间
        tr.ncontenttype      := p_sendtype;       --短信类型
        tr.exNumber          := null ;            --扩展号码
        tr.ssendno           :=v_c1 ;             --接收号码
        tr.ssmsmessage       :=v_c2 ;             --发送信息
        tr.cflag             :='N' ;              --处理标志
        tr.RETURNFLAG        :=null ;             --处理结果
        tr.ismgstatus        :=null;              --网管返回值
        tr.statustime        :=null;              --网管响应状态
        insert into TSMSSENDCACHE values  tr ;
       end loop;
elsif p_sendtype =103 THEN
open c_mn;
  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;

        tr.id                :=v_id ;             --记录编号
        tr.ssender           :=p_sende ;          --发送者标识
        tr.dbegintime        :=SYSDATE();         --请求时间
        tr.ntimingtag        :='0' ;              --定时标志
        tr.dtimingtime       := null;             --定时发送时间
        tr.ncontenttype      := p_sendtype;       --短信类型
        tr.exNumber          := null ;            --扩展号码
        tr.ssendno           :=v_c1 ;             --接收号码
        tr.ssmsmessage       :=p_bilephonetext ;   --发送信息
        tr.cflag             :='N' ;              --处理标志
        tr.RETURNFLAG        :=null ;             --处理结果
        tr.ismgstatus        :=null;              --网管返回值
        tr.statustime        :=null;              --网管响应状态
        insert into TSMSSENDCACHE values  tr ;
       end loop;

 else

open c_mn;

  loop
       fetch c_mn into v_c1 ,v_c2 ;
       exit when c_mn%notFound OR  c_mn%notFound IS NULL;
       select  seq_treceive.nextval into   v_id  from dual;
        tr.id                :=v_id ;             --记录编号
        tr.ssender           :=p_sende ;          --发送者标识
        tr.dbegintime        :=SYSDATE();         --请求时间
        tr.ntimingtag        :='0' ;              --定时标志
        tr.dtimingtime       := null;             --定时发送时间
        tr.ncontenttype      := p_sendtype;       --短信类型
        tr.exNumber          := null ;            --扩展号码
        tr.ssendno           :=v_c2 ;             --接收号码
        tr.ssmsmessage       :=fSetsmmtext(v_c1,p_sendtype,p_modeno) ;  --发送信息
        tr.cflag             :='N' ;              --处理标志
        tr.RETURNFLAG        :=null ;             --处理结果
        tr.ismgstatus        :=null;              --网管返回值
        tr.statustime        :=null;              --网管响应状态
        insert into TSMSSENDCACHE values  tr ;
       end loop;



  --elsif p_sendtype =102 THEN
  end if;
  commit;
  close c_mn;

exception
  when others then
    rollback;
end;
/

