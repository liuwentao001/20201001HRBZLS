CREATE OR REPLACE PACKAGE HRBZLS."PG_SMS" IS
  ERRCODE CONSTANT INTEGER := -20012;
  --短信发送过程
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --发送者
                 P_SENDTYPE        IN VARCHAR2, --发送类别
                 P_MODENO          IN VARCHAR2, --模板编号
                 p_istiming        IN VARCHAR2, --是否定时发送
                 p_datetime        IN VARCHAR2, --是否定时发送
                 P_BILEPHONENUMBER IN VARCHAR2, --接收号码
                 P_BILEPHONETEXT   IN VARCHAR2, --模版内容或或发送内容
                 P_BATCH           IN VARCHAR2
                 ) ;
  PROCEDURE spinset(TI TSMSSENDCACHE%ROWTYPE );
  --用户短信号码批量导入提交
  PROCEDURE spimportnumber;
  --短信预览
  PROCEDURE SMSEXCEPT(P_CICODE        IN VARCHAR2,
                       P_number        IN VARCHAR2,
                       P_BILEPHONETEXT IN VARCHAR2,
                       P_typeno           IN VARCHAR2,
                       O_TEXT          OUT VARCHAR2);
 PROCEDURE spnumbertype(P_number       IN VARCHAR2,
                        O_TEXT         OUT VARCHAR2);
  --短信策略调用过程
  PROCEDURE SMSMSSSTRATEGY;
  --模版特殊字段转换
  FUNCTION FSETSMMTEXT(P_CICODE IN VARCHAR2,
                       P_number IN VARCHAR2,
                       P_TYPE   IN VARCHAR2,
                       P_MODENO IN VARCHAR2) RETURN VARCHAR2;
   FUNCTION FSET_HZ(P_NUMBER IN VARCHAR2,P_TEXT IN VARCHAR2) RETURN VARCHAR2;
  --返回手机号码所属公司
  FUNCTION FGET_SJLB(P_NO IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FGET_dxstr_01(p_type      in varchar2, --类别
                      p_mdno      in varchar2, --模板编号
                      P_name        IN VARCHAR2, --成员名称
                      P_hm        IN VARCHAR2, --户名
                      P_hh        IN VARCHAR2, --户号
                      p_dz        in varchar2, --地址
                      P_qfsl      IN VARCHAR2, --欠费水量
                      P_qfje      IN VARCHAR2, --欠费金额
                      P_qfbs      IN VARCHAR2, --欠费笔数
                      P_date      IN VARCHAR2, --日期
                      P_radatemin IN VARCHAR2, --帐务日期
                      P_radatemax IN VARCHAR2, --帐务日期
                      P_str1      IN VARCHAR2, --预留一
                      P_str2      IN VARCHAR2, --预留二
                      P_str3      IN VARCHAR2, --预留三
                      P_MONTH     IN VARCHAR2,  --当前月份
                      P_YR        IN VARCHAR2,      --X月X日
                      P_QS        IN VARCHAR2,   --欠费期数
                      P_WYQF      IN VARCHAR2   --往月欠费
                      ) RETURN VARCHAR2 ;

  PROCEDURE sp_定时发送job;


END PG_SMS;
/

