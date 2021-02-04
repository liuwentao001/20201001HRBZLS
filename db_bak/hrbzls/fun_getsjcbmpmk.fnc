create or replace function hrbzls.fun_getsjcbmpmk(i_miid in varchar2, i_month in varchar2) return varchar2 is
  v_mk char(1):='N';
  v_code datadesign.�ֵ�code%type;
    v_�ֵ� datadesign.�ֵ�%type;
  v_��ע datadesign.��ע%type;
  v_month2 varchar2(10) ;
  v_mpmonth varchar2(7) ;
  v_count integer:=0;
  v_bfrcyc bookframe.bfrcyc%type;
  --�ж��ֻ�������ͬһ���������Ƿ����ظ��ϴ�ͼƬ���г������
/*  1.��������̬������ȳ������ڣ�Ŀǰ���ĸ����ڣ�01-03 / 04-06 / 07 - 09  / 10 - 12��
  2.���ֻ������ϴ����ݵ�Ӫ��ʱ�����жϲ����ֻ������Ƿ���Ҫ���գ�
  �������������˹ܿ�ʧЧ.
  ���������Ҫ�������ٽ����жϴ��������Ƿ����ֻ������ϴ�ͼƬ���������ͨ��������
  ������������ٴδ��ֻ��ϴ��������ݣ�ͬʱ����������������ڽ���ϵͳ.*/
begin
  v_month2:= substrb(i_month,6,2) ; 
  
      begin 
           select �ֵ�code   ,c.bfrcyc
           into v_code,v_bfrcyc
        from datadesign a , meterinfo b ,bookframe c where a.��ע=b.mismfid 
         and b.mibfid =c.bfid  and b.miid=i_miid  and �ֵ�����='�Ƿ�����'  ;
         exception when others then
           v_code:='0';
           v_bfrcyc:='0';
      end ;
    if v_code <> '1' or v_bfrcyc <>'3' then  --����ֻ����趨�����ջ������ڲ�Ϊ3����˹ܿز����
        v_mk :='N';
           return(v_mk);
    end if ;
    
    begin
     select �ֵ�code,�ֵ�,��ע 
     into v_code,v_�ֵ�,v_��ע  
     from datadesign where �ֵ�����='�Ƿ������ظ��ϴ�ͼƬ' and v_month2 BETWEEN �ֵ� and ��ע;  --Y  -�����ϴ� N-���ظ��ϴ�
    exception 
      when others then
        v_code:='N';
        v_�ֵ�:='00';
        v_��ע:='00';
     end ;
   IF  trim(v_code)='Y' THEN  --�����ظ��ϴ������ж�����
       
   
        select count(*) into v_count from meterread where MRMID =i_miid and  MRMONTH between to_char(sysdate,'yyyy')||'.'||v_�ֵ� and to_char(sysdate,'yyyy')||'.'||v_��ע  and MRREADOK='Y' and MRDATASOURCE ='9' ;  --�Ѿ����ͨ��
        
        if v_count = 0 then
                select count(*) into v_count from meterreadhis where MRMID =i_miid and  MRMONTH between to_char(sysdate,'yyyy')||'.'||v_�ֵ� and to_char(sysdate,'yyyy')||'.'||v_��ע  and MRREADOK='Y'  and MRDATASOURCE ='9' ;  --�Ѿ����ͨ��
        end if ;
        
        if v_count > 0 then  --���ֻ������ϴ�ͼƬ�����ж�����ϴ�ͼƬ�Ƿ���  
          select  count(*)
          into v_count
          from meterpicture  where mpmiid =i_miid and pmbz='1' and to_char( pmtime,'yyyy.mm') between to_char(sysdate,'yyyy')||'.'||v_�ֵ� and to_char(sysdate,'yyyy')||'.'||v_��ע  ;
          if v_count> 0 then
                     v_mk :='Y';
          else
                     v_mk :='N';
          end if ;
       else
             v_mk :='N'; --�������������û�н����ֻ��������,���Լ����ϴ�ͼƬ
       end if ;
   END IF ;
   return(v_mk);
end fun_getsjcbmpmk;
/

