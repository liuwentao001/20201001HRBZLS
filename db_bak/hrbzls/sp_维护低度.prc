CREATE OR REPLACE PROCEDURE HRBZLS."SP_Î¬»¤µÍ¶È" (p_miid in varchar2,v_micode varchar2,p_qfh  in number,p_MIINSDATE in date)  is

v_strMIINSDATE varchar2(10);
begin

    if  p_MIINSDATE is null then
         v_strMIINSDATE  :=   to_char(sysdate,'yyyy.mm')   ;
     else
          if     sysdate    >  p_MIINSDATE +  180  then
                   v_strMIINSDATE  :=   to_char(sysdate,'yyyy.mm')   ;
          else
                  v_strMIINSDATE  :=   to_char(  p_MIINSDATE -  180   ,'yyyy.mm')   ;
          end if;
    end if;
 insert into priceadjustlist
 values
   (fgetsequence('PRICEADJUSTLIST'),
    '02',
    '05',
    '',
    v_micode,
    p_miid,
    '',
    '',
    '',
    null,
    1,
    p_qfh,
    v_strMIINSDATE,
    '2080.12',
    'Y',
    '',
    null,
    '',
    sysdate,'','');

exception
   when others then
     insert into wzdz (c1) values (v_micode);
     insert into wzdz (c1) values (p_miid);
end;
/

