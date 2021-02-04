CREATE OR REPLACE PROCEDURE HRBZLS."SP_CUSTCHANGEPRINTSEARCH" (p_CCDNO      in varchar2,
                                                     p_PRINTTITLE in varchar2,
                                                     p_PRINTER    in varchar2,
                                                     o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  v_sql := 'SELECT t.CCDNO||''-''||t.CCDROWNO 登记单号, ' ||
           't2.cchcredate 登记日期, ' ||
           '''客户代码：''||t1.micode  客户代码, ' ||
           '''产权名：''||t1.ciname 产权名,  ' ||
           '''表地址：''||t1.miadr 表地址, ' ||
           '''水表口径：''||to_char(t1.mdcaliber) 水表口径, ' ||
           '''用水类别：''|| fGetpricetail(t1.MIID) 用水类别, ' ||
           '''缴费方式：''|| fgetsyschargetype(t1.michargetype)  缴费方式, ' ||
           '''业务类别：''|| (select bmname  from billmain tt where bmtype= t2.CCHLB  )          业务类别 ,  ' ||
           'FgetCUSTCHANGESTR(t.CCDNO,t.CCDROWNO  ) 变更明细, ' ||
           '''欠费金额：     元''  欠费金额, ' ||
           '''是否交清：  是    否''  是否缴清, ' ||
           ' FGETBILLMAIN( t2.CCHLB,''BMFLAG1'' )  备注信息, ' ||
           '''原用户： ''  原用户, ' ||
           ' t2.Cchcreper ||''【''|| fGetOperName(t2.Cchcreper)||''】''   受理工号, ' ||
           '''新用户： ''  新用户,' ||
           'fgetsmfname(t1.CISMFID) 受理网点, ' ||
           '''综合价格：''|| FGETZHPRICE(t1.MICODE)||''元/吨''     综合价格, ' ||
           '''表号： ''||t1.MDNO 表号, ' ||
           '''联系人： ''||t1.CICONNECTPER 联系人, ' ||
           '''联系电话： ''||t1.CICONNECTTEL 联系电话, ' ||
           '''申请原因： ''||t1.CCDAPPNOTE 申请原因,' ||
           '''身份证复印件：''||t1.ACCESSORYFLAG09 身份证复印件 ,' ||
           '''水费担保书： ''||t1.ACCESSORYFLAG04 水费担保书 ,' ||
           '''租赁合同复印件： ''||t1.ACCESSORYFLAG05 租赁合同复印件 ,' ||
           '''房产证或购房合同复印件： ''||t1.ACCESSORYFLAG06 房产证或购房合同复印件 ,' ||
           '''企业法人营业执照： ''||t1.ACCESSORYFLAG07 企业法人营业执照,' ||
           '''其他： ''||t1.ACCESSORYFLAG08 其他,' ||
           ' fgetrecqfmoney(t.MIID)  欠费信息'||
           ' FROM CUSTCHANGEDTHIS   t, CUSTCHANGEDT t1, CUSTCHANGEHD t2' ||
           ' where t.CCDNO in (''' || replace( p_CCDNO,',',''',''' ) || ''')' ||
           ' and t.CCDNO=t1.CCDNO and t.CCDNO = t2.CCHNO' ||
           ' and t.CCDROWNO = t1.CCDROWNO' ||
           ' order by t.CCDNO,  t.CCDROWNO';
  open o_base for v_sql;
end;
/

