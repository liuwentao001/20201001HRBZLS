CREATE OR REPLACE PACKAGE HRBZLS.PG_PAD_DL IS
 /*
  * 功能：下载用户基本信息
  * 创建人:曾海洲
  * 创建时间：2014-07-23
  * @表册信息
  * @抄表员编号
  * @返回游标
  */
  procedure DOWN_DATA(I_BFIDS IN VARCHAR2,
                       I_BFRPER   IN VARCHAR2,
                       i_version  in varchar2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       
 /*
  * 功能：数据初始化
  * 创建人:曾海洲
  * 创建时间：2014-07-23
  * @表册信息
  * @抄表员编号
  * @返回游标
  */
  procedure DATA_INIT(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       

  --抄表审核注记回写手机端
  procedure DOWN_DATA_READCHK(I_BFIDS IN VARCHAR2,
                       I_BFRPER   IN VARCHAR2,
                       O_CURRSOR      OUT SYS_REFCURSOR);
                       
     --抄表审核注记回写手机端
  procedure   DOWN_DATA_PICT(I_MPMIID IN VARCHAR2,
                            I_PMSIZE   IN VARCHAR2,
                            I_PMPATH   IN VARCHAR2,
                            I_PMTIME   IN VARCHAR2,
                            I_PMBZ   IN VARCHAR2,
                            I_PMPER   IN VARCHAR2,
                            I_PMPNAME   IN VARCHAR2,
                            I_ciid   IN VARCHAR2,
                            I_PMFACT_PATH   IN VARCHAR2,
                          O_CURRSOR   OUT  VARCHAR2); 
                                            
  --手机上传图片时第三次进行图片更新
  procedure DOWN_DATA_PICTS(I_BFRPER   IN VARCHAR2,
                      I_CONNECTTYPE VARCHAR2,
                      O_CURRSOR      OUT SYS_REFCURSOR) ;
                       
                       
END;
/

