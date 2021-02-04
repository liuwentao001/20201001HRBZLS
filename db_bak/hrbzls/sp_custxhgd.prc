CREATE OR REPLACE PROCEDURE HRBZLS."SP_CUSTXHGD" (p_CCDNO      in varchar2,
                                        p_PRINTTITLE in varchar2,
                                        p_PRINTER    in varchar2,
                                        o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  v_sql := 'SELECT T1.MTHNO  登记单号, ' || 'T1.MTHCREDATE 登记日期, ' ||
           '
           (CASE WHEN (T1.MTHLB)=''A'' THEN ''原居民总表客户代码：''
                 WHEN (T1.MTHLB)=''Q'' THEN ''参考客户代码：''
                 WHEN (T1.MTHLB)=''P'' THEN ''参考客户代码：''
                 ELSE ''客户代码： ''
                 END)

           ||T2.MICODE 客户代码, ' ||
           '''产权名：''||T3.CINAME 产权名,  ' ||
           '''水表地址：''||t2.MIADR 水表地址, ' ||
           '''口径：''||to_char(T4.mdcaliber) 口径, ' ||
           '''用水类别：''|| fGetpricetail(T2.MIID) 用水类别, ' ||
           '''缴费方式：''|| fgetsyschargetype(T2.michargetype)  缴费方式, ' ||
           '''业务类别：''|| (select bmname  from billmain tt where bmtype= t1.MTHLB) 业务类别,  ' ||
           ' FGETBILLMAIN(T1.MTHLB,''BMFLAG1'' ) 备注信息, ' ||
           ' FGETXHGD(T1.MTHNO,T1.MTHLB ) 工单信息, ' ||
           ' T1.MTHCREPER||''【''|| fgetopername(T1.MTHCREPER)||''】'' 受理工号, ' ||
           ' fgetsmfname(T1.MTHSMFID) 受理网点, ' ||
           '''综合价格:''|| FGETZHPRICE(T2.MICODE)||''元/吨'' 综合价格, ' ||
           '''表号:''||T4.MDNO 表号, ' ||
           '''联系人： ''||T.mtdconper 联系人, ' ||
           '''联系电话： ''||T.mtdcontel 联系电话, ' ||
           '''用水地址： ''||T.MTDMADRN 用水地址, ' ||
           '''申请原因： ''||T.MTDAPPNOTE 申请原因 ,' ||
           ' fgetrecqfmoney(t.MTDMID) 欠费信息 ,' ||
           ' (CASE WHEN (T1.MTHLB)=''A'' THEN ''原居民总表客户代码:''
                 ELSE '' ''
                 END)  老客户代码 ' ||
           ' FROM METERTRANSDT  T, METERTRANSHD  T1, METERINFO T2, CUSTINFO T3,METERDOC T4' ||
           ' where T.MTDNO IN  ('''||replace(p_CCDNO,',',''',''')||''')' ||
           ' AND  T1.MTHNO=T.MTDNO AND T.MTDMID = T2.MIID  AND T2.MICID=T3.CIID  AND T2.MIID=T4.MDMID' ||
           ' ORDER BY  T1.MTHNO';
/*   INSERT INTO 测试表(STR1 ) VALUES(v_sql);
   COMMIT;*/
  open o_base for v_sql;
end;
/

