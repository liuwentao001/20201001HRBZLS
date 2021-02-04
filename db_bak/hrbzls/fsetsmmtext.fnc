CREATE OR REPLACE FUNCTION HRBZLS."FSETSMMTEXT" (p_cicode in varchar2,p_type in varchar2, p_modeno in  varchar2 )
RETURN VARCHAR2 AS
  LRET VARCHAR2(200);
  v_mode  varchar2(200);
  v_th varchar2(200);
  v_CINAME varchar2(50);
  v_CIADR varchar2(50);
  v_sl number;
  v_je number;
  v_qfbs number;
  v_retextnumber number;
  v_len varchar2(2);
BEGIN
  --�滻�ͻ�����
  select tmdmd ,TMDLENGTH into v_mode,v_len from tsmssendmode where tmdlb=p_type  and TMDBH=p_modeno  ;
    v_retextnumber :=0;
    select instr(v_mode,'�ǿͻ������',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
       select  REPLACE( v_mode,'�ǿͻ������' ,p_cicode)into v_mode  from dual;
    end if;
     --�滻�ͻ�����
    v_retextnumber :=0;
    select instr(v_mode,'�ǿͻ����Ʃ�',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
      select  CINAME  into v_CINAME  from  custinfo where CICODE=p_cicode;
       select  REPLACE (v_mode,'�ǿͻ����Ʃ�' ,v_CINAME)into v_mode  from dual;
    end if;
    --�滻�ͻ��ͻ���ַ
    v_retextnumber :=0;
    select instr(v_mode,'�ǿͻ���ַ��',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
      select  CIADR  into v_CIADR  from  custinfo where CICODE=p_cicode;
       select  REPLACE (v_mode,'�ǿͻ���ַ��' ,v_CIADR)into v_mode  from dual;
    end if;
    --�滻��ˮ��
    v_retextnumber :=0;
    select  instr(v_mode,'��ˮ����',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
                        select
                        sum(rlsl) rlsl
                        into v_sl
                        from reclist,custinfo
                        where    CICODE=rlccode  and  rlpaidflag <> 'Y' and  CICODE=p_cicode;
       select  REPLACE (v_mode,'��ˮ����' , nvl(v_sl,0))into v_mode  from dual;
    end if;
    --�滻 Ƿ�ѽ��
    v_retextnumber :=0;
    select instr(v_mode,'��Ƿ�ѽ���',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
                        select
                        sum(rlje) rlje
                        into v_qfbs
                        from reclist,custinfo
                        where    CICODE=rlccode  and  rlpaidflag <> 'Y' and  CICODE=p_cicode;
       select  REPLACE (v_mode,'��Ƿ�ѽ���' ,nvl(v_qfbs,0))into v_mode  from dual;
    end if;
     --�滻Ƿ�ѱ���
    v_retextnumber :=0;
    select instr(v_mode,'��Ƿ�ѱ�����',1,1) instring into v_retextnumber  from dual;
    if v_retextnumber>0 then
                              select
                        count(*)
                        into v_qfbs
                        from reclist,custinfo
                        where    CICODE=rlccode  and  rlpaidflag <> 'Y'  and rlje>0  and  CICODE=p_cicode;
       select  REPLACE (v_mode,'��Ƿ�ѱ�����' ,nvl(v_qfbs,0))into v_mode  from dual;
    end if;
    if v_len='Y' then
      select  SUBSTR(v_mode,1 ,64)into v_mode  from dual;
    end if ;
   Return v_mode;
exception when others then
   return  LRET;
END;
/

