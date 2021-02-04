CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_INVMANAGE_01" IS

  --票据管理
  ERRCODE CONSTANT INTEGER := -20012;

  ---------------------------------------------------------------------------------------------

  --总仓入库 zhangrong
  PROCEDURE HQINSTORE(P_IITYPE     IN CHAR, --票据类型
                      P_IIRECEIVER IN VARCHAR2, --领取人员
                      P_IISMFID    IN VARCHAR2, --入库单位
                      P_IIBCNO     IN VARCHAR2, --批次
                      P_IISNO      IN VARCHAR2, --起号
                      P_IIENO      IN VARCHAR2 --止号
                      );

  --总仓出库 zhangrong
  PROCEDURE HQOUTSTORE(P_IOTYPE   IN CHAR, --票据类型
                       P_IOSENDER IN VARCHAR2, --出库人员
                       P_IOSMFID  IN VARCHAR2, --出库单位
                       P_IOBCNO   IN VARCHAR2, --批次
                       P_IOSNO    IN VARCHAR2, --起号
                       P_IOENO    IN VARCHAR2 --止号
                       );

  --票据入库
  PROCEDURE INSTORE(P_IITYPE     IN CHAR, --票据类型
                    P_IISENDER   IN VARCHAR2, --派发人员
                    P_IIRECEIVER IN VARCHAR2, --领取人员
                    P_IISMFID    IN VARCHAR2, --入库单位
                    P_IIBCNO     IN VARCHAR2, --批次
                    P_IISNO      IN VARCHAR2, --起号
                    P_IIENO      IN VARCHAR2); --止号

  --票据出库
  PROCEDURE OUTSTORE(P_IOTYPE     IN CHAR, --票据类型
                     P_IOSENDER   IN VARCHAR2, --派发人员
                     P_IORECEIVER IN VARCHAR2, --接收人员
                     P_IOSMFID    IN VARCHAR2, --出库单位
                     P_IOBCNO     IN VARCHAR2, --批次
                     P_IOSNO      IN VARCHAR2, --起号
                     P_IOENO      IN VARCHAR2); --止号

  --记录打印票号
  PROCEDURE RECINVNO(P_ILNO     IN VARCHAR2, --票据号码(###|###|)
                     P_ILRLID   IN VARCHAR2, --应收流水(###|###|)
                     P_ILRDPIID IN VARCHAR2, --费用项目(###|###|)
                     P_ILJE     IN VARCHAR2, --票据金额(###|###|)
                     P_ILTYPE   IN CHAR, --票据类型
                     P_ILCD     IN CHAR, --借贷方向
                     P_ILPER    IN VARCHAR2, --出票人
                     P_ILSTATUS IN CHAR, --票据状态
                     P_ILSMFID  IN VARCHAR2 --分公司
                     );

  --票据日结
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR); --票据类型

  --票据日结_手动执行
  PROCEDURE P_INVDAILYBALANCE(P_INVTYPE CHAR, BALDATE VARCHAR2); --票据类型

  PROCEDURE CANCEL(P_ICPER   IN VARCHAR2, --票据所有人
                   P_ICSMFID IN VARCHAR2, --作废单位
                   P_ICTYPE  IN CHAR, --票据类型
                   P_ICNO    IN VARCHAR2 --票据编号
                   );
  --鄂州自来水
  --取发
  FUNCTION FGETINVNO(P_PER    IN VARCHAR2, --有人
                     P_IITYPE IN VARCHAR2, --发票类型
                     P_SNO    IN NUMBER --发票号码
                     ) RETURN NUMBER;
  --鄂州自来水
  --取发将要使用发票号
  FUNCTION FGETINVNO_STR(P_PER    IN VARCHAR2, --操作员
                         P_IITYPE IN VARCHAR2 --发票类型
                         ) RETURN VARCHAR2;
  --操作操作员票据信息
  FUNCTION FGETHADINV(P_PER IN VARCHAR2 --操作员  p_iitype in varchar2 --发票类型
                      ) RETURN VARCHAR2;
  --操作操作员票据信息[ts]
  FUNCTION FGETHADINVTS(P_PER IN VARCHAR2 --操作员
                        
                        ) RETURN VARCHAR2;

  --鄂州自来水
  --取发将要使用发票号存放在事务会话表里
  FUNCTION FGETINVNO_TEMP(P_PER    IN VARCHAR2, --操作员
                          P_IITYPE IN VARCHAR2, --发票类型
                          P_COUNT  IN NUMBER, --要取发票张数
                          P_SNO    IN NUMBER) RETURN NUMBER;

  --鄂州自来水
  --取会话表里 发票号
  FUNCTION FGETINVNO_FROMTEMP(P_I IN NUMBER --第几张发票
                              
                              ) RETURN NUMBER;
  --鄂州自来水
  --取可用发票号数量
  FUNCTION FGETINVCOUNT(P_PER    IN VARCHAR2, --操作员
                        P_IITYPE IN VARCHAR2 --发票类型
                        ) RETURN NUMBER;
  --记录打印票号 鄂州
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE RECINVNO_EZ(P_ISPRINTTYPE IN VARCHAR2, --打印方式
                        P_ILNO        IN VARCHAR2, --票据号码(###|###|)
                        P_ILRLID      IN VARCHAR2, --应收流水(###|###|)
                        P_ILRDPIID    IN VARCHAR2, --费用项目(###|###|)
                        P_ILJE        IN VARCHAR2, --票据金额(###|###|)
                        P_ILTYPE      IN CHAR, --票据类型
                        P_ILCD        IN CHAR, --借贷方向
                        P_ILPER       IN VARCHAR2, --出票人
                        P_ILSTATUS    IN CHAR, --票据状态
                        P_ILSMFID     IN VARCHAR2, --分公司
                        P_TRANS       IN VARCHAR2, --事务
                        P_ISZZS       IN VARCHAR2 --增值税
                        );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE SP_FCHARGEINVREG(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
                             P_SNO         IN NUMBER --发票流水
                             );
  --鄂州自来水
  --检查发票是否够打
  FUNCTION FCHKINVFULL(P_PER    IN VARCHAR2, --操作员
                       P_IITYPE IN VARCHAR2, --发票类型
                       P_TYPE   IN VARCHAR2, --流水号类别
                       P_ID     IN VARCHAR2 --流水号
                       ) RETURN NUMBER --返回是否差发票数量
  ;
  --发票状态处理
  PROCEDURE SP_CANCEL_HADPRINTNO(P_PER    IN VARCHAR2, --操作员
                                 P_TYPE   IN VARCHAR2, --发票类别
                                 P_STATUS IN VARCHAR2, --处理状态
                                 P_ID     IN VARCHAR2, --流水号
                                 P_MODE   IN VARCHAR2, --流水号类别
                                 O_FLAG   OUT VARCHAR2 --返回值
                                 );
  FUNCTION FGETINVDWDETAILSTR(P_ID IN NUMBER) RETURN VARCHAR2;
  --删除发票
  PROCEDURE SP_INVMANG_DELETE(P_ISNOSTART   VARCHAR2, --发票起号
                              P_ISNOEND     VARCHAR2, --发票止号
                              P_ISBCNO      VARCHAR2, --发票批次
                              P_ISSTATUSPER VARCHAR2, --状态变更人
                              P_MEMO        VARCHAR2, --备注
                              MSG           OUT VARCHAR2);
  --修改发票状态
  PROCEDURE SP_INVMANG_MODIFYSTATUS(P_ISNOSTART   VARCHAR2, --发票起号
                                    P_ISNOEND     VARCHAR2, --发票止号
                                    P_ISBCNO      VARCHAR2, --批次号
                                    P_ISSTATUSPER VARCHAR2, --状态变更人员
                                    P_STATUS      NUMBER, --状态2
                                    P_MEMO        VARCHAR2, --备注
                                    MSG           OUT VARCHAR2);
  --发票转领
  PROCEDURE SP_INVMANG_ZLY(P_ISNOSTART   VARCHAR2, --发票起号
                           P_ISNOEND     VARCHAR2, --发票止号
                           P_ISBCNO      VARCHAR2, --批次号
                           P_ISSTATUSPER VARCHAR2, --领用人员
                           P_STATUS      NUMBER, --状态0
                           P_MEMO        VARCHAR2, --备注
                           MSG           OUT VARCHAR2);

  --修改发票
  PROCEDURE SP_INVMANG_MODIFYINV(P_ISNOSTART   VARCHAR2, --发票起号
                                 P_ISNOEND     VARCHAR2, --发票止号
                                 P_ISBCNO      VARCHAR2, --批次号
                                 P_ISSTATUSPER VARCHAR2, --状态变更人员
                                 P_TYPE        VARCHAR2, --状态2
                                 P_NUM         VARCHAR2, --备注
                                 MSG           OUT VARCHAR2);

  --发票调整                                 
  PROCEDURE SP_SPTZ(P_ISBCNO      IN VARCHAR2, --批次号
                    P_MINSOURCENO IN VARCHAR2,
                    P_MAXSOURCENO IN VARCHAR2,
                    P_MINDESTNO   IN VARCHAR2, --调整目标发票起始号
                    P_MAXDESTNO   IN VARCHAR2, --调整目标原发票终止号
                    P_TYPE        IN VARCHAR2); -- FPDT 发票对调  FPTH 发票调号                                 

  --新增发票
  PROCEDURE SP_INVMANG_NEW(P_ISBCNO    VARCHAR2, --批次号
                           P_ISPER     VARCHAR2, --领票人
                           P_ISTYPE    VARCHAR2, --发票类别
                           P_ISNOSTART VARCHAR2, --发票起号
                           P_ISNOEND   VARCHAR2, --发票止号
                           P_OUTPER    VARCHAR2, --发放票据人
                           MSG         OUT VARCHAR2);

  --发票入库、分发、领用、退还
  PROCEDURE SP_STOCK(P_ISBCNO    VARCHAR2, --批次号
                     P_ISSTOCKDO VARCHAR2, --仓库操作
                     P_ISSMFID   VARCHAR2, --仓库
                     P_ISPER     VARCHAR2, --领票人
                     P_ISTYPE    VARCHAR2, --发票类别
                     P_ISNOSTART VARCHAR2, --发票起号
                     P_ISNOEND   VARCHAR2, --发票止号
                     P_OUTPER    VARCHAR2, --发放票据人
                     MSG         OUT VARCHAR2);

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE SP_CHARGEINV(P_IFFPHP      IN VARCHAR2, --F分票H合票
                         P_ID          IN VARCHAR2, --实收批次
                         P_PIID        IN VARCHAR2, --费用项目 01/02/03
                         P_ISPRINTTYPE IN VARCHAR2, --打印方式
                         P_ILTYPE      IN VARCHAR2, --票据类型
                         P_PRINTER     IN VARCHAR2, --打印员
                         P_ILSTATUS    IN VARCHAR2, --票据状态
                         P_ILSMFID     IN VARCHAR2, --分公司
                         P_ISPRINTCD   IN VARCHAR2, --借代方
                         P_SNO         IN NUMBER --初始化票号
                         );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE SP_CHARGEINV_BAK(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
                             P_SNO         IN NUMBER --发票流水
                             );

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_H_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --初始化票号
                                );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_H_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --初始化票号
                                 );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F(P_IFFPHP      IN VARCHAR2, --F分票H合票
                             P_ID          IN VARCHAR2, --实收批次
                             P_PIID        IN VARCHAR2, --费用项目 01/02/03
                             P_ISPRINTTYPE IN VARCHAR2, --打印方式
                             P_ILTYPE      IN VARCHAR2, --票据类型
                             P_PRINTER     IN VARCHAR2, --打印员
                             P_ILSTATUS    IN VARCHAR2, --票据状态
                             P_ILSMFID     IN VARCHAR2, --分公司
                             P_ISPRINTCD   IN VARCHAR2, --借代方
                             P_SNO         IN NUMBER --初始化票号
                             );

  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F_TS(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
                                );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_F_ZS(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --票据流水
                                );
  --合收打印
  PROCEDURE SP_CHARGEINV_1_F_HSB(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --票据流水
                                 );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_G_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --初始化票号
                                );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_G_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --初始化票号
                                 );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_Z_SF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                P_ID          IN VARCHAR2, --实收批次
                                P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                P_ILTYPE      IN VARCHAR2, --票据类型
                                P_PRINTER     IN VARCHAR2, --打印员
                                P_ILSTATUS    IN VARCHAR2, --票据状态
                                P_ILSMFID     IN VARCHAR2, --分公司
                                P_ISPRINTCD   IN VARCHAR2, --借代方
                                P_SNO         IN NUMBER --初始化票号
                                );
  --缴费记票号(柜台)
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid,7:抄表流水 mrid
  PROCEDURE SP_CHARGEINV_1_Z_WSF(P_IFFPHP      IN VARCHAR2, --F分票H合票
                                 P_ID          IN VARCHAR2, --实收批次
                                 P_PIID        IN VARCHAR2, --费用项目 01/02/03
                                 P_ISPRINTTYPE IN VARCHAR2, --打印方式
                                 P_ILTYPE      IN VARCHAR2, --票据类型
                                 P_PRINTER     IN VARCHAR2, --打印员
                                 P_ILSTATUS    IN VARCHAR2, --票据状态
                                 P_ILSMFID     IN VARCHAR2, --分公司
                                 P_ISPRINTCD   IN VARCHAR2, --借代方
                                 P_SNO         IN NUMBER --初始化票号
                                 );
  --ISPRINTTYPE 打印方式 1:实收打印批次pbatch，2:实收pID3:实收明细:plid，4:实收pdid+pdpiid,5:应收流水rlid,6:实收明细rdid+rdpiid
  PROCEDURE RECINVNO(P_ISPRINTTYPE IN VARCHAR2, --打印方式
                     P_ILNO        IN VARCHAR2, --票据号码(###|###|)
                     P_ILRLID      IN VARCHAR2, --应收流水(###|###|)
                     P_ILRDPIID    IN VARCHAR2, --费用项目(###|###|)
                     P_ILJE        IN VARCHAR2, --票据金额(###|###|)
                     P_ILTYPE      IN CHAR, --票据类型
                     P_ILCD        IN CHAR, --借贷方向
                     P_ILPER       IN VARCHAR2, --出票人
                     P_ILSTATUS    IN CHAR, --票据状态
                     P_ILSMFID     IN VARCHAR2, --分公司
                     P_TRANS       IN VARCHAR2, --事务
                     P_ISZZS       IN VARCHAR2 --增值税
                     );
  --冲正自动作废发票
  PROCEDURE SP_CANCEL(P_PER    IN VARCHAR2, --操作员
                      P_TYPE   IN VARCHAR2, --发票类别
                      P_STATUS IN VARCHAR2, --处理状态
                      P_ID     IN VARCHAR2, --流水号
                      P_MODE   IN VARCHAR2, --流水号类别
                      O_FLAG   OUT VARCHAR2 --返回值
                      );
  --单个发票号码修改
  PROCEDURE SP_SNO_MODEFY_FP(P_OLDISBCO IN VARCHAR2, --原批次
                             P_OLDISNO  IN VARCHAR2, --原号码
                             P_NEWISBCO IN VARCHAR2, --处理状态
                             P_NEWISNO  IN VARCHAR2, --流水号
                             P_TYPE     IN VARCHAR2, --流水号
                             P_OPER     IN VARCHAR2, --流水号类别
                             O_FLAG     OUT VARCHAR2 --返回值
                             );
  --组织发票数据
  PROCEDURE SWAP_TO_INV(P_TYPE   IN VARCHAR2,
                        P_BATCH  IN VARCHAR2,
                        P_PBATCH IN OUT VARCHAR2);

  --判断用户是否为免抄户                      
  FUNCTION fgetmeterstatus(P_CODE IN VARCHAR2 --用户号
                           ) RETURN VARCHAR2;

  --柜台发票打印明细
  FUNCTION fgetinvdeatil_gt(P_BATCH IN VARCHAR2, --批次号
                            P_TYPE  IN VARCHAR2, --类型
                            P_ROW   IN NUMBER --行数  
                            ) RETURN VARCHAR2;

  --走收打印明细函数
  FUNCTION fgetinvdeatil_zs(P_RLIDLIST IN VARCHAR2, --应收流水号
                            P_TYPE     IN VARCHAR2, --类型
                            P_ROW      IN NUMBER --行数  
                            ) RETURN VARCHAR2;
  --获取合收户数                    
  FUNCTION fgethscode(P_MIID IN VARCHAR2 --客户代码  
                      ) RETURN varchar2;

  --获取用户原水账标识号                   
  FUNCTION fgetcltno(P_MIID IN VARCHAR2 --客户代码  
                     ) RETURN VARCHAR2;

  --获取备注信息                  
  FUNCTION fgetinvmemo(P_RLID IN VARCHAR2, --应收流水
                       P_TYPE IN VARCHAR2 --备注类型
                       ) RETURN VARCHAR2;

  --获取用户新账卡号（表册号+册内序号）                   
  FUNCTION fgetnewcardno(P_MIID IN VARCHAR2 --客户代码  
                         ) RETURN VARCHAR2;

  --翻译发票备注rlinvmemo                 
  FUNCTION fgettranslate(P_RLTRANS   IN VARCHAR2, --应收事务
                         P_RLINVMEMO IN VARCHAR2 -- 发票备注
                         ) RETURN VARCHAR2;

  --获取一户多表期末预存余额        
  FUNCTION fgethsqmsaving(P_MIID IN VARCHAR2 --客户代码  
                          ) RETURN VARCHAR2;

  --发票打印明细(一户多表)
  FUNCTION fgethsinvdeatil(P_MIID IN VARCHAR2 --客户代码  
                           ) RETURN VARCHAR2;

  PROCEDURE SP_CHEQUE(P_BATCH    IN VARCHAR2, --收费批次号 
                      P_CODE     IN VARCHAR2, --客户代码
                      P_SMFID    IN VARCHAR2, --营业所
                      P_OPER     IN VARCHAR2, --收费员
                      P_STATUS   IN VARCHAR2, --支票状态
                      P_NO       IN VARCHAR2, --支票号
                      P_BANKNAME IN VARCHAR2, --开户行名
                      P_BANKID   IN VARCHAR2, --行号
                      P_BANKNO   IN VARCHAR2, --开户账号
                      P_CWDH     IN VARCHAR2, --财务单号
                      P_TYPE     IN VARCHAR2 --进账类型
                      );

  PROCEDURE sp_财务到账(P_ID   IN VARCHAR2, --进账单流水
                    P_OPER IN VARCHAR2 --资金来源
                    );

  PROCEDURE sp_财务退票(P_ID    IN VARCHAR2, --进账单流水
                    P_SMFID IN VARCHAR, --营业所
                    P_OPER  IN VARCHAR2 --退票人
                    );

  PROCEDURE SP_UPDATERECOUTFLAG(P_BATCH IN VARCHAR2, --发票批次号
                                P_ISNO  IN VARCHAR2 --发票号
                                );

  PROCEDURE SP_DELETEISPCISNO(P_BATCH  IN VARCHAR2, --发票批次号
                              P_ISNO   IN VARCHAR2, --发票号
                              P_STATUS NUMBER);

end;
/

