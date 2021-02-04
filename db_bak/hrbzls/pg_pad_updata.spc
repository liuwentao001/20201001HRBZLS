CREATE OR REPLACE PACKAGE HRBZLS.PG_PAD_UPDATA IS
  /*
  * 功能：上传主函数
  * 创建人:曾海洲
  * 创建时间：2014-06-22
  * 修改人：  
  * 修改时间：
  */
  procedure main(i_trans_code IN varchar2,i_in_trans IN VARCHAR2, o_out_trans OUT VARCHAR2);
  
 /*
  * 功能：8001协议
  * 创建人:曾海洲
  * 创建时间：2014-08-28
  * 修改人：  
  * 修改时间：
  */
  procedure f8001(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
  /*
  * 功能：8001协议
  * 创建人:曾海洲
  * 创建时间：2014-08-28
  * 修改人：  
  * 修改时间：
  */
  procedure f8002(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * 功能：8003协议  
   手机抄表确定（抄表数据给营收） -> 营收 (根据抄表数据进行算费，结果传回手机) -> 手机（接收算费结果） 打印催费通知单
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */              
  procedure f8003(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * 功能：8004协议  
     密码验证返回协议
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */                
  procedure f8004(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
  /*
  * 功能：8005协议  
     参数版本验证返回协议
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */                
  procedure f8005(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
                  
                                    
  /*
  * 功能：8006协议  
    用户点抄表取消协议，抄表注记需退审
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */                
  procedure f8006(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
   /*
  * 功能：8007协议  
    用户巡检资料上传
  * 创建人:贺帮
  * 创建时间：2015-03-12
  * 修改人：  
  * 修改时间：
  */                
  procedure f8007(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);

                  
   /*
  * 功能：8008协议  
    用户图片资料上传
  * 创建人:贺帮
  * 创建时间：2015-07-15
  * 修改人：  
  * 修改时间：
  */   
  procedure f8008(i_in_trans  IN VARCHAR2,
                  i_SEQ       in VARCHAR2,
                  o_out_trans  OUT VARCHAR2);
                  
END;
/

