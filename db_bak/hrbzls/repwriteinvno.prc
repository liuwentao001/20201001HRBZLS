CREATE OR REPLACE PROCEDURE HRBZLS."REPWRITEINVNO" (
                         P_iffphp      in varchar2, --F��ƱH��Ʊ
                         p_id          in varchar2, --ʵ������
                         p_piid        in varchar2, --������Ŀ 01/02/03
                         p_ISPRINTTYPE in varchar2, --��ӡ��ʽ
                         p_ilstatus    in VARCHAR2, --Ʊ��״̬
                         p_ilsmfid     IN VARCHAR2, --�ֹ�˾
                         p_ISPRINTCD   IN VARCHAR2, --�������
                     p_per    in varchar2, --����Ա
                     p_count in varchar2,--��Ʊ����
                     p_iitype in varchar2, --��Ʊ����
                     p_isbcno    in varchar2, --��Ʊ���κ�
                     p_isno    in number ,--��Ʊ��ˮ��
                     o_msg    out varchar2
                     )   as





    vcount number(10);
    v_msg varchar2(2000);
    V_isid invstock.isid%TYPE;
     v_isno  invstock.isno%TYPE;
    cursor c_it is
      select isid,ISNO

        from invstock t
       where istype = p_iitype
         and t.isper = p_per
         and isbcno=p_isbcno
         and isno>=v_isno
       order by t.isbcno, t.isno;
    it invstock%rowtype;

  begin
NULL;
v_isno :=trim(to_char(p_isno,'00000000'));
    update invstock t set t.isstatus='4'
    where isstatus='0'
    and istype = p_iitype
    and isper = p_per;
    vcount :=0;
      open c_it;
      loop fetch c_it
        into it.isid,IT.ISNO ;
        EXIT WHEN c_it%NOTFOUND OR c_it%NOTFOUND IS NULL ;
        vcount :=vcount + 1;
        IF Vcount=1 then
          V_isid := it.isid;
        end if;
        --����Ϊδʹ��
         pg_EWIDE_invmanage_01.sp_invmang_modifystatus(
         IT.ISNO,
         IT.ISNO,
         p_isbcno,
         p_per,
         0,
         '',
         v_msg);
         if v_msg<>'Y' THEN
           o_msg :='��Ʊ�����쳣1';
           EXIT;
         END IF;
         IF vcount=p_count THEN
           EXIT;
         END IF;
      end loop ;
      close c_it;
      if vcount< p_count then
        o_msg :='��Ʊ���㣬��'||p_count-vcount||'��';
      end if;


  pg_EWIDE_invmanage_01.sp_chargeinv(P_iffphp       , --F��ƱH��Ʊ
                         p_id           , --ʵ������
                         p_piid         , --������Ŀ 01/02/03
                         p_ISPRINTTYPE  , --��ӡ��ʽ
                         p_iitype      , --Ʊ������
                         p_per      , --��ӡԱ
                         p_ilstatus     , --Ʊ��״̬
                         p_ilsmfid      , --�ֹ�˾
                         p_ISPRINTCD    , --�������
                         V_isid           ----��Ʊ��ˮ
                         );



       update invstock t set t.isstatus='0'
    where isstatus='4'
    and istype = p_iitype
    and isper = p_per;
      o_msg :='Y';
  exception
    when others then
      o_msg :='��Ʊ�����쳣';
  end;
/

