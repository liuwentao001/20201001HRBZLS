CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_SMS_01" IS
  ERRCODE CONSTANT INTEGER := -20012;
  --短信发送过程
  PROCEDURE SEND(P_SENDE           IN VARCHAR2, --发送者
                 P_SENDTYPE        IN VARCHAR2, --发送类别
                 P_MODENO          IN VARCHAR2, --模板编号
                 p_istiming        IN VARCHAR2, --是否定时发送
                 p_datetime        IN VARCHAR2, --是否定时发送
                 P_BILEPHONENUMBER IN VARCHAR2, --接收号码
                 P_BILEPHONETEXT   IN VARCHAR2 --模版内容或或发送内容
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
END ;
/

