CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_BANKTUXEDO_TEST" is
  errcode constant integer := -20012;
  --主函数（跟据交易类别调用不同交易函数）
FUNCTION fGetSysDate RETURN DATE;

  ----主过程（跟据交易类别调用不同交易函数）
  PROCEDURE sp_main(p_str_in  in varchar2,
                    p_len_in  in number,
                    p_str_out out varchar2,
                    p_len_out out number) ;
  function fgetpara2(p_parastr in clob,rown in integer,coln in integer)
  return varchar2;
  function main(p_str in varchar2) return varchar2;
   function CheckBalance(p_hh in varchar2, p_trans in varchar2)
    return varchar2;
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
  function GetUserDebt(p_hh in varchar2) return varchar2;

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
                    p_trans       in varchar2) return varchar2;

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

end;
/

