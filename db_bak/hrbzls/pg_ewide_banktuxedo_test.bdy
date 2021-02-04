CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_BANKTUXEDO_TEST" is
  CurrentDate date := fGetSysDate;


  ----主过程（跟据交易类别调用不同交易函数）
  PROCEDURE sp_main(p_str_in  in varchar2,
                    p_len_in  in number,
                    p_str_out out varchar2,
                    p_len_out out number)  is
    v_tempstr varchar2(32766);
    v_parm    varchar2(32766);
    v_type    varchar2(32766);
  begin
    v_tempstr := p_str_in || '|';
    v_type    := tools.fgetpara2(v_tempstr, 1, 1);

    if upper(v_type) = 'GETUSERDEBT' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      p_str_out := GetUserDebt(v_parm);
      p_len_out := length(p_str_out);
    end if;

    if upper(v_type) = 'WRITEOFF' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      p_str_out := WriteOff(v_parm, CurrentDate, PG_EWIDE_PAY_01.PAYTRANS_DS);
      p_len_out := length(p_str_out);
    end if;
    if upper(v_type) = 'CHECKBALANCE' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
        p_str_out := CheckBalance(v_parm, PG_EWIDE_PAY_01.PAYTRANS_BANKCR);
          p_len_out := length(p_str_out);
    end if;






    --return '1';
      p_str_out :=  nvl(v_type, '?');
       p_len_out := length(p_str_out);

  exception
    when others then
      --return '-1';
       p_str_out :=  nvl(v_type, '?');
      p_len_out := length(p_str_out);
  end;

  --主函数（跟据交易类别调用不同交易函数）
  function main(p_str in varchar2) return varchar2 is
    v_tempstr varchar2(32766);
    v_parm    varchar2(32766);
    v_type    varchar2(32766);
  begin
    v_tempstr := p_str || '|';
    v_type    := fgetpara2(v_tempstr, 1, 1);

    if upper(v_type) = 'GETUSERDEBT' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return GetUserDebt(v_parm);
    end if;

    if upper(v_type) = 'WRITEOFF' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return WriteOff(v_parm, CurrentDate, PG_EWIDE_PAY_01.PAYTRANS_DS);
    end if;

  if upper(v_type) = 'CHECKBALANCE' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return CheckBalance(v_parm, PG_EWIDE_PAY_01.PAYTRANS_BANKCR);
    end if;
    --return '1';
    return nvl(v_type, '?');
  exception
    when others then
      --return '-1';
      return nvl(v_type, '?');
  end;
  ---------------------------------------------------------------------------
  --name:GetUserDebt
  --note: A、缴费申请功能描述：银行向水司前置机发出申请，
  --请求取得用户的欠费记录；
  --水司接收到申请任务后，传出相应用户的欠费记录。
  --author:wy
  --date：2011/12/04
  --input: p_hh 输入参数：hh|备用1|备用2  hh[户号]为Int型
  --return F|描述|户名|地址|欠费笔数|DATA1|DATA2|…|DATAn
  --标志位：F
  --0：操作成功；
  --1：该户号没有欠费或非城区用户；（没有一个DATA数据时）
  --2：该户号不存在；
  --99：系统故障；
  --Data1..Datan为欠费信息,格式为：费用ID|本期抄表日|水费月份|…：
  /* 序号  字段名 字段类型及长度 内容及意义
            1 费用ID  Int 每笔水费的唯一标识（必须有）
            2 本期抄表日 Datetime（10，0）  抄表日期（YYYY-MM-DD）
            3 水费月份  Datetime（7，0） 水费月份(YYYY-MM)
            4 水费金额  Numeric（13，2） 水费金额
            5 违约金 Numeric（13，2） 违约金
            6 水费类型  Numeric（1）  0 水费 2 追收
            7 上期抄度  Numeric（8，0）  上期水表抄见度
            8 本期抄度  Numeric（8，0）  本期水表抄见度
            9 实收水量  Numeric（6，0）  实收水量
            10  主用水性质 Varchar(16) 当存在混合用水时只取主用水性质,否则为单性质
            11  主性质单价 Numeric(7,4)  主用水性质的水价
            12  组成1单价 Numeric(7,4)  基本水价的单价
            13  组成1金额 Numeric(13,2) 基本水价的金额
            14  组成2单价 Numeric(13,2) 排污费的单价
            15  组成2金额 Numeric(13,2) 排污费的金额
            16  票据标志  int 0 打印收据 1 增值发票  2 水费发票
  */
  ---------------------------------------------------------------------------
  function GetUserDebt(p_hh in varchar2) return varchar2 is
    noyh exception; --用户不存在
    noqf exception; --没有欠费
    v_tempstr varchar2(32766); --接收传入字符串
    v_headstr varchar2(32766); --头字符串
    v_retstr  varchar2(32766); --返回字符串
    v_qf      number(12, 2); --欠费金额 指水费 不含滞纳金等
    v_hh      varchar2(32766); --户号
    v_zdj     number(12, 2); --单价
    v_je1     number(12, 2); --金额1
    v_dj1     number(12, 2); --单价1
    v_je2     number(12, 2); --金额2
    v_dj2     number(12, 2); --单价2
    v_qfcount number(10); --欠费笔数



  begin
    -- v_tempstr :=substr( substr(p_hh,2),1,length(p_hh  ) - 2 )   || '|';
    v_tempstr := p_hh || '|';
    v_hh      := tools.fgetpara2(v_tempstr, 1, 1);
    v_retstr :='0|欠费信息|孙国军|浬浦镇五美桂溪坞|1|29389111|2012-01-05|2012-01|28.05|0.00|0|0|17|17|乡镇生活|1.65|1.65|28.05|0.00|0.00|0';
    return v_retstr;

  end;

  ---------------------------------------------------------------------------
  --name:WriteOff
  --note: 功能描述：缴费确认,银行通知水司，某用户已确认缴费。
  --author:wy
  --date：2011/12/04
  --input: p_hh “总行代码|进帐流水号|实收笔数|实收地点|实收款|实收工号|费用ID1...|费用IDn”
  --return  “F|描述|实收款|进帐流水号”
  /*说     明：
             进帐流水号：14位字符，1、2位为银行总行代码（JS—建设），后12位由银行确定，但应保证任何时刻不能有重复流水号；
             实收笔数：实际收了几笔水费；
             实收地点：银行网点代码；
             实收款：总金额为2位小数；
             缴费日期：格式为“YYYY-MM-DD”，10位数组成；
             实收工号：收银员的工号，4位
             费用ID：每笔费用的唯一标识，MIS系统中只需根据费用ID销帐即可；

            标志位：F；
            0：操作成功；
            1：部分水费已销帐；
            2：金额不符
            3：其他错误
            99：操作失败；
  */
  ---------------------------------------------------------------------------
  function WriteOff(p_hh          in varchar2,
                    p_paydatetime in date,
                    p_trans       in varchar2) return varchar2 is
    ---0：操作成功；

    bfxz exception; --1部分水费已销帐
    jebf exception; --2金额不符
    qtqw exception; --3其他错误

    v_tempstr  varchar2(32766); --接收传入字符串
    v_headstr  varchar2(32766); --头字符串
    v_retstr   varchar2(32766); --返回字符串
    v_retmsg   varchar2(32766); --返回结果
    v_fksrje   number(12, 2); --付款剩余金额
    v_jfje     number(12, 2); --缴费金额
    v_znj      number(12, 2); --滞纳金额
    v_sxf      number(12, 2); --手续费
    v_type     varchar2(10); --缴费类型
    v_FKFS     varchar2(10); --缴费类型
    V_IFP      varchar2(100); --是否发票
    V_INVNO    varchar2(100); --发票号码
    V_COMMIT   varchar2(100); --提交
    v_xzcount  number(10); --销帐笔数
    v_hh       varchar2(32766); --户号


    v_总行代码           varchar2(1000);
    v_总行对应管理架构码 varchar2(10);
    v_进帐流水号         varchar2(1000);
    v_实收笔数           number(10);
    v_实收地点           varchar2(1000);
    v_实收款             varchar2(1000);
    v_实收工号           varchar2(1000);
    v_费用ID             varchar2(1000);




  begin

    -- “总行代码|进帐流水号|实收笔数|实收地点|实收款|实收工号|费用ID1...|费用IDn”
    if p_hh is null then
      raise qtqw;
    end if;
    v_tempstr := p_hh || '|';

    v_总行代码 := substr(v_tempstr, 1, instr(v_tempstr, '|') - 1);
    if v_总行代码 is null then
      raise qtqw;
    end if;
    v_总行对应管理架构码 := FBCODE2SMFID(v_总行代码); --
    v_进帐流水号         := trim(substr(v_tempstr,
                                   instr(v_tempstr, '|', 1, 1) + 1,
                                   instr(v_tempstr, '|', 1, 2) -
                                   instr(v_tempstr, '|', 1, 1) - 1));
    if v_进帐流水号 is null then
      raise qtqw;
    end if;
    v_实收笔数 := to_number(trim(substr(v_tempstr,
                                    instr(v_tempstr, '|', 1, 2) + 1,
                                    instr(v_tempstr, '|', 1, 3) -
                                    instr(v_tempstr, '|', 1, 2) - 1)));
    if v_实收笔数 is null or v_实收笔数 < 1 then
      raise qtqw;
    end if;
    v_实收地点 := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 3) + 1,
                          instr(v_tempstr, '|', 1, 4) -
                          instr(v_tempstr, '|', 1, 3) - 1));
    if v_实收地点 is null then
      raise qtqw;
    end if;
    v_实收款 := to_number(trim(substr(v_tempstr,
                                   instr(v_tempstr, '|', 1, 4) + 1,
                                   instr(v_tempstr, '|', 1, 5) -
                                   instr(v_tempstr, '|', 1, 4) - 1)));
    if v_实收款 is null or not (v_实收款 > 0) then
      raise qtqw;
    end if;
    v_实收工号 := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 5) + 1,
                          instr(v_tempstr, '|', 1, 6) -
                          instr(v_tempstr, '|', 1, 5) - 1));
    if v_实收工号 is null then
      raise qtqw;
    end if;
    v_费用ID := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 6) + 1,
                          instr(v_tempstr, '|', 1, 7) -
                          instr(v_tempstr, '|', 1, 6) - 1));
    if v_费用ID is null then
      raise qtqw;
    end if;

      v_retstr  :='0|缴费信息|29|JS111111111112|';

    return v_retstr;

  end;
  ---------------------------------------------------------------------------
  --name:CheckBalance
  --note: 功能描述：银行通知水司对某笔交易进行冲正。
  --author:wy
  --date：2011/12/04
  --input: p_hh  总行代码|实收款|进帐流水号
  --return  F|描述|实收款|进帐流水号
  /*标志位：F；
                  0：操作成功；
                  1：水费未销帐；
                  2：该用户销帐日期小于今天；
                  3：未知的进帐流水号
                  4：金额不符
                  5：该用户已开发票；
                  6：该用户已冲正；
                  7：其他原因
                  99：操作失败；
  */
  ---------------------------------------------------------------------------
  function CheckBalance(p_hh in varchar2, p_trans in varchar2)
    return varchar2 is
    ---0：操作成功；

    sfwx exception; --1：水费未销帐；无
    rqid exception; --2：该用户销帐日期小于今天；
    wzls exception; --3：未知的进帐流水号
    jebf exception; --4：金额不符
    ykp exception; --5：该用户已开发票；暂元
    ycz exception; --6：该用户已冲正；
    qtyy exception; --7：其他原因

    v_tempstr  varchar2(32766); --接收传入字符串
    v_headstr  varchar2(32766); --头字符串
    v_retstr   varchar2(32766); --返回字符串
    v_bs       number(10); --明细笔数



    v_总行代码           varchar2(1000);
    v_总行对应管理架构码 varchar2(10);
    v_进帐流水号         varchar2(1000);
    v_实收款             varchar2(1000);
    v_retmsg             varchar2(100);

  begin

    -- 总行代码|实收款|进帐流水号
    if p_hh is null then
      raise qtyy;

    end if;
    v_tempstr := p_hh || '|';

    v_总行代码 := substr(v_tempstr, 1, instr(v_tempstr, '|') - 1);
    if v_总行代码 is null then
      raise qtyy;
    end if;
    v_总行对应管理架构码 := FBCODE2SMFID(v_总行代码); --
    v_实收款             := to_number(trim(substr(v_tempstr,
                                               instr(v_tempstr, '|', 1, 1) + 1,
                                               instr(v_tempstr, '|', 1, 2) -
                                               instr(v_tempstr, '|', 1, 1) - 1)));
    if v_实收款 is null or not v_实收款 > 0 then
      raise qtyy;
    end if;
    v_进帐流水号 := trim(substr(v_tempstr,
                           instr(v_tempstr, '|', 1, 2) + 1,
                           instr(v_tempstr, '|', 1, 3) -
                           instr(v_tempstr, '|', 1, 2) - 1));
    if v_进帐流水号 is null then
      raise qtyy;
    end if;
    v_retstr  := '0|冲正|29|JS111111111112|';
    return v_retstr;
  end;

---ss
 FUNCTION fGetSysDate RETURN DATE
  AS
    xtrq  DATE;
  BEGIN
    select to_date(to_char(sysdate,'YYYYMMDD'),'YYYY/MM/DD') INTO xtrq
	  FROM dual;
	RETURN xtrq;
  END;




   function fgetpara2(p_parastr in clob,rown in integer,coln in integer)
  return varchar2 is
    --一维数组规则：#####|####|####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'数组字符串格式错误'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--一行读完(每行只一列)
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;

       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;

  -------------------------------------------------------------------------
  --name:CheckBack
  --note: 银行对帐文件生成后，则调用FTP文件传输功能，
  --  把对帐的文件传输给水司前置机，调用交易CheckBack通知水司开始对帐；
  --水司对帐完毕，返回对帐结果，最后银行再调用FTP功能取对帐结果文件。
  --author:wy
  --date：2011/12/04
  --input: p_hh  总行代码|清算日|FileName|Length
  /*说     明：清算日：格式为“YYYY-MM-DD”，10位数组成；
  FilenName：对帐文件名(银行编码+加年月日(YYYYMMDD))+’.DZ’；
           对帐文件是一个文本文件，每一行为一条记录，格式：
  以下行为详细对帐所需数据：“进帐流水号|缴费时间|实收笔数|实收地点|实收款|实收工号|费用ID1|...|费用IDn”
  最后一行为总对帐所需数据：“0|清算日|总笔数|总金额|水费笔数”
    Length：对帐文件的长度；*/

  --return  F|描述|清算日|总行代码|错误文件名
  /*说     明：
             清算日：格式为“YYYY-MM-DD hh:mm:ss”，19位数组成；
  标志位：F；
                 0：操作成功；
                 1：对帐有误差，请检查对帐错误文件；
                 2： 对帐文件结果行于内容不符
                 3： 不存在或文件长度不对
                 4： 清算日不正确
                 5:  文件内清算日不正确
                 99：操作失败,请重新对帐；
             错误文件名：若对帐有误差，则生成此文件，文件名格式如下:
             FileName：错误清单文件名(银行编码＋年月日（YYYYMMDD）+’.DZCW’)
  形   式：文本文件，每行一条记录
           对帐错帐文件：“错误号|进帐流水号|清算日”
         最后一行的格式为”-1|错误记录数”,
             错误号：
  01：本条交易日期与清算日不符；
  02：本条交易水司端不存在；
  03：水司端多出的交易；
  04：交易金额不符；
  99：其他错误

  */


end;
/

