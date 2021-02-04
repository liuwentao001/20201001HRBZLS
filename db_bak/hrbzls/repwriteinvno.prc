CREATE OR REPLACE PROCEDURE HRBZLS."REPWRITEINVNO" (
                         P_iffphp      in varchar2, --F分票H合票
                         p_id          in varchar2, --实收批次
                         p_piid        in varchar2, --费用项目 01/02/03
                         p_ISPRINTTYPE in varchar2, --打印方式
                         p_ilstatus    in VARCHAR2, --票据状态
                         p_ilsmfid     IN VARCHAR2, --分公司
                         p_ISPRINTCD   IN VARCHAR2, --借代方，
                     p_per    in varchar2, --操作员
                     p_count in varchar2,--发票张数
                     p_iitype in varchar2, --发票类型
                     p_isbcno    in varchar2, --发票批次号
                     p_isno    in number ,--发票流水号
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
        --设置为未使用
         pg_EWIDE_invmanage_01.sp_invmang_modifystatus(
         IT.ISNO,
         IT.ISNO,
         p_isbcno,
         p_per,
         0,
         '',
         v_msg);
         if v_msg<>'Y' THEN
           o_msg :='发票处理异常1';
           EXIT;
         END IF;
         IF vcount=p_count THEN
           EXIT;
         END IF;
      end loop ;
      close c_it;
      if vcount< p_count then
        o_msg :='发票不足，差'||p_count-vcount||'张';
      end if;


  pg_EWIDE_invmanage_01.sp_chargeinv(P_iffphp       , --F分票H合票
                         p_id           , --实收批次
                         p_piid         , --费用项目 01/02/03
                         p_ISPRINTTYPE  , --打印方式
                         p_iitype      , --票据类型
                         p_per      , --打印员
                         p_ilstatus     , --票据状态
                         p_ilsmfid      , --分公司
                         p_ISPRINTCD    , --借代方，
                         V_isid           ----发票流水
                         );



       update invstock t set t.isstatus='0'
    where isstatus='4'
    and istype = p_iitype
    and isper = p_per;
      o_msg :='Y';
  exception
    when others then
      o_msg :='发票处理异常';
  end;
/

