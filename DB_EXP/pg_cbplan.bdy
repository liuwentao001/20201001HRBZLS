CREATE OR REPLACE PACKAGE BODY "PG_CBPLAN" is

  /*
  进行生成抄码表
  参数：p_manage_no： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_month: 目标营业所
        p_book_no:  目标表册 
  处理：生成抄表资料
  输出：无
  */
  PROCEDURE createCB(p_HIRE_CODE  in VARCHAR2,
                     p_manage_no in VARCHAR2,
                     p_month   in varchar2,
                     p_book_no    in varchar2) IS
    yh       ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr        ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --存在
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    cursor c_bksb is
      select a.yhid,
             b.sbid, 
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype
        from ys_yh_custinfo a , ys_yh_sbinfo b, ys_yh_sbdoc s , ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and b.manage_no = p_manage_no
         and b.book_no = p_book_no
            --and (to_char(ADD_MONTHS(to_date(MIRMON,'yyyy.mm'),BFRCYC),'yyyy.mm') = p_month or MIRMON is null)
         and d.read_nmonth = p_month
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid, 
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --判断是否存在重复抄表计划
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id     :=  sys_guid(); --流水号
        sbr.hire_code := p_HIRE_CODE;
        sbr.cbmrmonth  := p_month; --抄表月份
        sbr.manage_no  := sb.manage_no; --管辖公司
        sbr.book_no   := p_book_no; --表册
        sbr.cbMRBATCH  := bc.READ_BATCH; --抄表批次
        sbr.cbMRRPER   := bc.READ_PER; --抄表员
        sbr.cbmrrorder := sb.sbrorder; --抄表次序号
        
        sbr.YHID           := yh.yhid; --用户编号
        
        sbr.sbid           := sb.sbid; --水表编号
        
        sbr.TRADE_NO          := sb.TRADE_NO; --行业分类
        sbr.SBPID          := sb.sbpid; --上级水表
        sbr.CBMRMCLASS        := sb.sbclass; --水表级次
        sbr.CBMRMFLAG         := sb.sbflag; --末级标志
        sbr.CBMRCREADATE      := sysdate; --创建日期
        sbr.CBMRINPUTDATE     := null; --编辑日期
        sbr.CBMRREADOK        := 'N'; --抄见标志
        sbr.CBMRRDATE         := null; --抄表日期
        sbr.cbmrprdate        := sb.sbrecdate; --上次抄见日期(取上次有效抄表日期)
        sbr.cbmrscode         := sb.sbrcode; --上期抄见
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --上期抄见char
        sbr.cbmrecode         := null; --本期抄见
        sbr.cbmrsl            := null; --本期水量
        sbr.cbmrface          := null; --表况
        sbr.cbmrifsubmit      := 'Y'; --是否提交计费
        sbr.cbmrifhalt        := 'N'; --系统停算
        sbr.cbmrdatasource    := 1; --抄表结果来源
        sbr.cbmrifignoreminsl := 'Y'; --停算最低抄量
        sbr.cbmrpdardate      := null; --抄表机抄表时间
        sbr.cbmroutflag       := 'N'; --发出到抄表机标志
        sbr.cbmroutid         := null; --发出到抄表机流水号
        sbr.cbmroutdate       := null; --发出到抄表机日期
        sbr.cbmrinorder       := null; --抄表机接收次序
        sbr.cbmrindate        := null; --抄表机接受日期
        sbr.cbmrrpid          := sb.sbrpid; --计件类型
        sbr.CBMRMEMO          := null; --抄表备注
        sbr.cbmrifgu          := 'N'; --估表标志
        sbr.cbmrifrec         := 'N'; --已计费
        sbr.cbmrrecdate       := null; --计费日期
        sbr.cbmrrecsl         := null; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(sbr.cbmrid , --抄表流水
                         sb.sbid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --余量   */
        sbr.cbmraddsl         := 0; --余量
        sbr.cbmrcarrysl       := null; --进位水量
        sbr.cbmrctrl1         := null; --抄表机控制位1
        sbr.cbmrctrl2         := null; --抄表机控制位2
        sbr.cbmrctrl3         := null; --抄表机控制位3
        sbr.cbmrctrl4         := null; --抄表机控制位4
        sbr.cbmrctrl5         := null; --抄表机控制位5
        sbr.cbmrchkflag       := 'N'; --复核标志
        sbr.cbmrchkdate       := null; --复核日期
        sbr.cbmrchkper        := null; --复核人员
        sbr.cbmrchkscode      := null; --原起数
        sbr.cbmrchkecode      := null; --原止数
        sbr.cbmrchksl         := null; --原水量
        sbr.cbmrchkaddsl      := null; --原余量
        sbr.cbmrchkcarrysl    := null; --原进位水量
        sbr.cbmrchkrdate      := null; --原抄见日期
        sbr.cbmrchkface       := null; --原表况
        sbr.cbmrchkresult     := null; --检查结果类型
        sbr.cbmrchkresultmemo := null; --检查结果说明
        sbr.cbmrprimid        := sb.sbpriid; --合收表主表
        sbr.cbmrprimflag      := sb.sbpriflag; --  合收表标志
        sbr.cbmrlb            := sb.sblb; -- 水表类别
        sbr.cbmrnewflag       := sb.sbnewflag; -- 新表标志
        sbr.cbmrface2         :=null ;--抄见故障
        sbr.cbmrface3         :=null ;--非常计量
        sbr.cbmrface4         :=null ;--表井设施说明

        sbr.cbMRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        sbr.cbmrprivilegeper  :=null;--特权操作人
        sbr.cbmrprivilegememo :=null;--特权操作备注
        sbr.AREA_NO         := sb.AREA_NO; --管理区域
        sbr.cbmriftrans       := 'N'; --转单标志
        sbr.cbmrrequisition   := 0; --通知单打印次数
        sbr.cbmrifchk         := sb.sbifchk; --考核表标志
        sbr.cbmrinputper      := null;--入账人员
        sbr.PRICE_NO          := sb.PRICE_NO;--用水类别
        sbr.cbmrcaliber       := md.mdcaliber;--口径
        sbr.cbmrside          := sb.sbside;--表位
        sbr.cbmrmtype         := sb.sbtype;--表型

         sbr.cbmrplansl   := 0;--计划水量
        sbr.cbmrplanje01 := 0;--计划水费
        sbr.CBMRPLANJE02 := 0;--计划污水处理费
        sbr.cbmrplanje03 := 0;--计划水资源费

        --上次水费   至  去年度次均量
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl, 
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);




        insert into ys_cb_mtread VALUES sbr;

        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;

    update ys_bas_book k
       set READ_NMONTH = to_char(add_months(to_date(READ_NMONTH, 'yyyy.mm'),
                                          READ_CYCLE),
                               'yyyy.mm')
     where MANAGE_NO = p_MANAGE_NO
       and BOOK_NO = p_BOOK_NO
       and  hire_code = p_HIRE_CODE;

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END; 
  
   /*
  进行生成抄码表
  参数：p_manage_no： 临时表类型(PBPARMTEMP.c1)，存放调段后目标表册中所有水表编号c1,抄表次序c2
        p_month: 目标营业所
        p_book_no:  目标表册 
  处理：生成抄表资料
  输出：无
  */
  PROCEDURE createCBsb(p_HIRE_CODE  in VARCHAR2,
                        p_month in varchar2 , 
                       p_sbid in VARCHAR2) IS
    yh       ys_yh_custinfo%rowtype;
    sb        ys_yh_sbinfo%rowtype;
    md        ys_yh_sbdoc%rowtype;
    bc        ys_bas_book%rowtype;
    sbr        ys_cb_mtread%rowtype;
    v_tempnum number(10);
    v_addsl   number(10);
    v_tempstr varchar2(10);
    v_ret     varchar2(10);
    v_date    date;
    --存在
    cursor c_cb(vsbid in varchar2) is
      select 1
        from ys_cb_mtread
       where sbid = vsbid
         and CBmrmonth = p_month;
    DUMMY INTEGER;
    FOUND BOOLEAN;
    --计划
    cursor c_bksb is
      select a.yhid,
             b.sbid, 
             b.manage_no,
             b.sbrorder,
             TRADE_NO,
             sbpid,
             sbclass,
             sbflag,
             sbrecdate,
             sbrcode,
             sbrpid,
             sbpriid,
             sbpriflag,
             sblb,
             sbnewflag,
             READ_BATCH,
             READ_PER,
             sbrcodechar,
             b.AREA_NO,
             sbifchk,
             PRICE_NO,
             mdcaliber,
             sbside,
             sbtype,
             b.book_no
        from ys_yh_custinfo a , ys_yh_sbinfo b, ys_yh_sbdoc s , ys_bas_book d
       where a.yhid = b.yhid
         and b.sbid = s.sbid
         and b.manage_no = d.manage_no
         and b.book_no = d.book_no
         and  b.sbid = p_sbid
         and FCHKCBMK(b.sbid) = 'Y';
  BEGIN
    open c_bksb;
    loop
      fetch c_bksb
        into yh.yhid,
             sb.sbid, 
             sb.manage_no,
             sb.sbrorder,
             sb.TRADE_NO,
             sb.sbpid,
             sb.sbclass,
             sb.sbflag,
             sb.sbrecdate,
             sb.sbrcode,
             sb.sbrpid,
             sb.sbpriid,
             sb.sbpriflag,
             sb.sblb,
             sb.sbnewflag,
             bc.READ_BATCH,
             bc.READ_PER,
             sb.sbrcodechar,
             sb.AREA_NO,
             sb.sbifchk,
             sb.PRICE_NO,
             md.mdcaliber,
             sb.sbside,
             sb.sbtype,
             sb.book_no;
      exit when c_bksb%notfound or c_bksb%notfound is null;
      --判断是否存在重复抄表计划
      OPEN c_cb(sb.sbid);
      FETCH c_cb
        INTO DUMMY;
      found := c_cb%FOUND;
      close c_cb;
      if not found then
        sbr.id     :=  sys_guid(); --流水号
        sbr.hire_code := p_HIRE_CODE ;
        sbr.cbmrmonth  := p_month; --抄表月份
        sbr.manage_no  := sb.manage_no; --管辖公司
        sbr.book_no   := sb.book_no; --表册
        sbr.cbMRBATCH  := bc.READ_BATCH; --抄表批次
        sbr.cbMRRPER   := bc.READ_PER; --抄表员
        sbr.cbmrrorder := sb.sbrorder; --抄表次序号
        
        sbr.YHID           := yh.yhid; --用户编号
        
        sbr.sbid           := sb.sbid; --水表编号
        
        sbr.TRADE_NO          := sb.TRADE_NO; --行业分类
        sbr.SBPID          := sb.sbpid; --上级水表
        sbr.CBMRMCLASS        := sb.sbclass; --水表级次
        sbr.CBMRMFLAG         := sb.sbflag; --末级标志
        sbr.CBMRCREADATE      := sysdate; --创建日期
        sbr.CBMRINPUTDATE     := null; --编辑日期
        sbr.CBMRREADOK        := 'N'; --抄见标志
        sbr.CBMRRDATE         := null; --抄表日期
        sbr.cbmrprdate        := sb.sbrecdate; --上次抄见日期(取上次有效抄表日期)
        sbr.cbmrscode         := sb.sbrcode; --上期抄见
        sbr.cbMRSCODECHAR     := sb.sbrcodechar; --上期抄见char
        sbr.cbmrecode         := null; --本期抄见
        sbr.cbmrsl            := null; --本期水量
        sbr.cbmrface          := null; --表况
        sbr.cbmrifsubmit      := 'Y'; --是否提交计费
        sbr.cbmrifhalt        := 'N'; --系统停算
        sbr.cbmrdatasource    := 1; --抄表结果来源
        sbr.cbmrifignoreminsl := 'Y'; --停算最低抄量
        sbr.cbmrpdardate      := null; --抄表机抄表时间
        sbr.cbmroutflag       := 'N'; --发出到抄表机标志
        sbr.cbmroutid         := null; --发出到抄表机流水号
        sbr.cbmroutdate       := null; --发出到抄表机日期
        sbr.cbmrinorder       := null; --抄表机接收次序
        sbr.cbmrindate        := null; --抄表机接受日期
        sbr.cbmrrpid          := sb.sbrpid; --计件类型
        sbr.CBMRMEMO          := null; --抄表备注
        sbr.cbmrifgu          := 'N'; --估表标志
        sbr.cbmrifrec         := 'N'; --已计费
        sbr.cbmrrecdate       := null; --计费日期
        sbr.cbmrrecsl         := null; --应收水量
        /*        --取未用余量
        sp_fetchaddingsl(sbr.cbmrid , --抄表流水
                         sb.sbid,--水表号
                         v_tempnum,--旧表止度
                         v_tempnum,--新表起度
                         v_addsl ,--余量
                         v_date,--创建日期
                         v_tempstr,--加调事务
                         v_ret  --返回值
                         ) ;
        sbr.cbmraddsl         :=   v_addsl ;  --余量   */
        sbr.cbmraddsl         := 0; --余量
        sbr.cbmrcarrysl       := null; --进位水量
        sbr.cbmrctrl1         := null; --抄表机控制位1
        sbr.cbmrctrl2         := null; --抄表机控制位2
        sbr.cbmrctrl3         := null; --抄表机控制位3
        sbr.cbmrctrl4         := null; --抄表机控制位4
        sbr.cbmrctrl5         := null; --抄表机控制位5
        sbr.cbmrchkflag       := 'N'; --复核标志
        sbr.cbmrchkdate       := null; --复核日期
        sbr.cbmrchkper        := null; --复核人员
        sbr.cbmrchkscode      := null; --原起数
        sbr.cbmrchkecode      := null; --原止数
        sbr.cbmrchksl         := null; --原水量
        sbr.cbmrchkaddsl      := null; --原余量
        sbr.cbmrchkcarrysl    := null; --原进位水量
        sbr.cbmrchkrdate      := null; --原抄见日期
        sbr.cbmrchkface       := null; --原表况
        sbr.cbmrchkresult     := null; --检查结果类型
        sbr.cbmrchkresultmemo := null; --检查结果说明
        sbr.cbmrprimid        := sb.sbpriid; --合收表主表
        sbr.cbmrprimflag      := sb.sbpriflag; --  合收表标志
        sbr.cbmrlb            := sb.sblb; -- 水表类别
        sbr.cbmrnewflag       := sb.sbnewflag; -- 新表标志
        sbr.cbmrface2         :=null ;--抄见故障
        sbr.cbmrface3         :=null ;--非常计量
        sbr.cbmrface4         :=null ;--表井设施说明

        sbr.cbMRPRIVILEGEFLAG := 'N'; --特权标志(Y/N)
        sbr.cbmrprivilegeper  :=null;--特权操作人
        sbr.cbmrprivilegememo :=null;--特权操作备注
        sbr.AREA_NO         := sb.AREA_NO; --管理区域
        sbr.cbmriftrans       := 'N'; --转单标志
        sbr.cbmrrequisition   := 0; --通知单打印次数
        sbr.cbmrifchk         := sb.sbifchk; --考核表标志
        sbr.cbmrinputper      := null;--入账人员
        sbr.PRICE_NO          := sb.PRICE_NO;--用水类别
        sbr.cbmrcaliber       := md.mdcaliber;--口径
        sbr.cbmrside          := sb.sbside;--表位
        sbr.cbmrmtype         := sb.sbtype;--表型

         sbr.cbmrplansl   := 0;--计划水量
        sbr.cbmrplanje01 := 0;--计划水费
        sbr.CBMRPLANJE02 := 0;--计划污水处理费
        sbr.cbmrplanje03 := 0;--计划水资源费

        --上次水费   至  去年度次均量
        getmrhis(sbr.id,
                 sbr.cbmrmonth,
                 sbr.cbmrthreesl,
                 sbr.cbmrthreeje01,
                 sbr.cbmrthreeje02,
                 sbr.cbmrthreeje03,
                 sbr.cbmrlastsl,
                 sbr.cbmrlastje01,
                 sbr.cbmrlastje02,
                 sbr.cbmrlastje03,
                 sbr.cbmryearsl, 
                 sbr.cbmryearje01,
                 sbr.cbmryearje02,
                 sbr.cbmryearje03,
                 sbr.cbmrlastyearsl,
                 sbr.cbmrlastyearje01,
                 sbr.cbmrlastyearje02,
                 sbr.cbmrlastyearje03);




        insert into ys_cb_mtread VALUES sbr;

        update ys_yh_sbinfo
           set sbPRMON = sbRMON, sbRMON = p_month
         where sbid = sb.sbid;
      end if;
    end loop;
    close c_bksb;

     

    commit;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END; 
 /*
  均量（费）算法
  1、前n次均量：     从最近抄表水量向历史方向递推12次抄表累计水量（0水量不计次）/递推次数
  2、上次水量：      最近一次抄表水量（包括0水量）
  3、去年同期水量：  去年同抄表月份的抄表水量（包括0水量）
  4、去年度次均量：  去年度的抄表累计水量（0水量不计次）/递推次数

  【meterread/meterreadhis】均量记录结构
  mrthreesl   number(10)    前n次均量
  mrthreeje01 number(13,3)  前n次均水费
  mrthreeje02 number(13,3)  前n次均污水费
  mrthreeje03 number(13,3)  前n次均水资源费

  mrlastsl    number(10)    上次水量
  mrlastje01  number(13,3)  上次水费
  mrlastje02  number(13,3)  上次污水费
  mrlastje03  number(13,3)  上次水资源费

  mryearsl    number(10)    去年同期水量
  mryearje01  number(13,3)  去年同期水费
  mryearje02  number(13,3)  去年同期污水费
  mryearje03  number(13,3)  去年同期水资源费

  mrlastyearsl    number(10)    去年度次均量
  mrlastyearje01  number(13,3)  去年度次均水费
  mrlastyearje02  number(13,3)  去年度次均污水费
  mrlastyearje03  number(13,3)  去年度次均水资源费
  */
  procedure getmrhis(p_sbid   in varchar2,
                     p_month  in varchar2,
                     o_sl_1   out number,
                     o_je01_1 out number,
                     o_je02_1 out number,
                     o_je03_1 out number,
                     o_sl_2   out number,
                     o_je01_2 out number,
                     o_je02_2 out number,
                     o_je03_2 out number,
                     o_sl_3   out number,
                     o_je01_3 out number,
                     o_je02_3 out number,
                     o_je03_3 out number,
                     o_sl_4   out number,
                     o_je01_4 out number,
                     o_je02_4 out number,
                     o_je03_4 out number) is
    cursor c_mrh(v_sbid ys_cb_mtreadhis.sbid%type) is
      select nvl(cbmrsl, 0),
             nvl(cbmrrecje01, 0),
             nvl(cbmrrecje02, 0),
             nvl(cbmrrecje03, 0),
             cbmrmonth
        from ys_cb_mtreadhis
       where sbid = v_sbid
            /*and mrsl > 0*/
         and (cbmrdatasource <> '9' or cbmrdatasource is null)
       order by cbmrrdate desc;

    mrh ys_cb_mtreadhis%rowtype;
    n1  integer := 0;
    n2  integer := 0;
    n3  integer := 0;
    n4  integer := 0;
  begin
    open c_mrh(p_sbid);
    loop
      fetch c_mrh
        into mrh.cbmrsl,
             mrh.cbmrrecje01,
             mrh.cbmrrecje02,
             mrh.cbmrrecje03,
             mrh.cbmrmonth;
      exit when c_mrh%notfound is null or c_mrh%notfound or(n1 > 12 and
                                                            n2 > 1 and
                                                            n3 > 1 and
                                                            n4 > 12);
      if mrh.cbmrsl > 0 and n1 <= 12 then
        n1              := n1 + 1;
        mrh.cbmrthreesl   := nvl(mrh.cbmrthreesl, 0) + mrh.cbmrsl; --前n次均量
        mrh.cbmrthreeje01 := nvl(mrh.cbmrthreeje01, 0) + mrh.cbmrrecje01; --前n次均水费
        mrh.cbmrthreeje02 := nvl(mrh.cbmrthreeje02, 0) + mrh.cbmrrecje02; --前n次均污水费
        mrh.cbmrthreeje03 := nvl(mrh.cbmrthreeje03, 0) + mrh.cbmrrecje03; --前n次均水资源费
      end if;

      if c_mrh%rowcount = 1 then
        n2             := n2 + 1;
        mrh.cbmrlastsl   := nvl(mrh.cbmrlastsl, 0) + mrh.cbmrsl; --上次水量
        mrh.cbmrlastje01 := nvl(mrh.cbmrlastje01, 0) + mrh.cbmrrecje01; --上次水费
        mrh.cbmrlastje02 := nvl(mrh.cbmrlastje02, 0) + mrh.cbmrrecje02; --上次污水费
        mrh.cbmrlastje03 := nvl(mrh.cbmrlastje03, 0) + mrh.cbmrrecje03; --上次水资源费
      end if;

      if mrh.cbmrmonth = to_char(to_number(substr(p_month, 1, 4)) - 1) || '.' ||
         substr(p_month, 6, 2) then
        n3             := n3 + 1;
        mrh.cbmryearsl   := nvl(mrh.cbmryearsl, 0) + mrh.cbmrsl; --去年同期水量
        mrh.cbmryearje01 := nvl(mrh.cbmryearje01, 0) + mrh.cbmrrecje01; --去年同期水费
        mrh.cbmryearje02 := nvl(mrh.cbmryearje02, 0) + mrh.cbmrrecje02; --去年同期污水费
        mrh.cbmryearje03 := nvl(mrh.cbmryearje03, 0) + mrh.cbmrrecje03; --去年同期水资源费
      end if;

      if mrh.cbmrsl > 0 and to_number(substr(mrh.cbmrmonth, 1, 4)) =
         to_number(substr(p_month, 1, 4)) - 1 then
        n4                 := n4 + 1;
        mrh.cbmrlastyearsl   := nvl(mrh.cbmrlastyearsl, 0) + mrh.cbmrsl; --去年度次均量
        mrh.cbmrlastyearje01 := nvl(mrh.cbmrlastyearje01, 0) + mrh.cbmrrecje01; --去年度次均水费
        mrh.cbmrlastyearje02 := nvl(mrh.cbmrlastyearje02, 0) + mrh.cbmrrecje02; --去年度次均污水费
        mrh.cbmrlastyearje03 := nvl(mrh.cbmrlastyearje03, 0) + mrh.cbmrrecje03; --去年度次均水资源费
      end if;
    end loop;

    o_sl_1 := (case
                when n1 = 0 then
                 0
                else
                 round(mrh.cbmrthreesl / n1, 0)
              end);
    o_je01_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje01 / n1, 3)
                end);
    o_je02_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje02 / n1, 3)
                end);
    o_je03_1 := (case
                  when n1 = 0 then
                   0
                  else
                   round(mrh.cbmrthreeje03 / n1, 3)
                end);

    o_sl_2 := (case
                when n2 = 0 then
                 0
                else
                 round(mrh.cbmrlastsl / n2, 0)
              end);
    o_je01_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje01 / n2, 3)
                end);
    o_je02_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje02 / n2, 3)
                end);
    o_je03_2 := (case
                  when n2 = 0 then
                   0
                  else
                   round(mrh.cbmrlastje03 / n2, 3)
                end);

    o_sl_3 := (case
                when n3 = 0 then
                 0
                else
                 round(mrh.cbmryearsl / n3, 0)
              end);
    o_je01_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje01 / n3, 3)
                end);
    o_je02_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje02 / n3, 3)
                end);
    o_je03_3 := (case
                  when n3 = 0 then
                   0
                  else
                   round(mrh.cbmryearje03 / n3, 3)
                end);

    o_sl_4 := (case
                when n4 = 0 then
                 0
                else
                 round(mrh.cbmrlastyearsl / n4, 0)
              end);
    o_je01_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje01 / n4, 3)
                end);
    o_je02_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje02 / n4, 3)
                end);
    o_je03_4 := (case
                  when n4 = 0 then
                   0
                  else
                   round(mrh.cbmrlastyearje03 / n4, 3)
                end);
  exception
    when others then
      if c_mrh%isopen then
        close c_mrh;
      end if;
  end getmrhis;
   
   -- 手工账务月结处理
  --p_smfid 营业所,售水公司
  --p_month 当前月份
  --p_per 操作员
  --p_commit 提交标志
  --o_ret 返回值
  --time 2010-08-20  by yf
  PROCEDURE month_over(p_HIRE_CODE in varchar2,
                         P_ID  IN VARCHAR2,
                         P_MONTH  IN VARCHAR2,
                         P_PER    IN VARCHAR2,
                         P_COMMIT IN VARCHAR2) IS
    V_COUNT     NUMBER;
    V_TEMPMONTH VARCHAR2(7);
    VSCRMONTH   VARCHAR2(7);
    VDESMONTH   VARCHAR2(7);
  BEGIN
    ---START检查是否有漏算情况(在客户端中检查)----------------------------------------------------------
    V_TEMPMONTH := fobtmanapara(P_ID,'READ_MONTH');
    IF V_TEMPMONTH <> P_MONTH THEN
      RAISE_APPLICATION_ERROR(ERRCODE, '手工账务月结月份异常,请检查!');
    END IF;
   
      update  BAS_MANA_PARA 
      set CONTENT = TO_CHAR(ADD_MONTHS(TO_DATE(CONTENT, 'yyyy.mm'), 1),
                               'yyyy.mm')
   WHERE MANAGE_NO = P_ID
     AND PARAMETER_NO = 'READ_MONTH'
     and HIRE_CODE = p_HIRE_CODE  ;
     
     
     INSERT INTO ys_cb_mtreadhis
      (SELECT *
         FROM ys_cb_mtread T
        WHERE T.HIRE_CODE = P_HIRE_CODE
         and  MANAGE_NO = p_id
          AND T.CBMRMONTH = P_MONTH);

    --删除当前抄表库信息
    DELETE ys_cb_mtread T
        WHERE T.HIRE_CODE = P_HIRE_CODE
         and  MANAGE_NO = p_id
          AND T.CBMRMONTH = P_MONTH;
    --
      
    --提交标志
    IF P_COMMIT = 'Y' THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(ERRCODE, '账务月结失败' || SQLERRM);
  END;
end;
/

