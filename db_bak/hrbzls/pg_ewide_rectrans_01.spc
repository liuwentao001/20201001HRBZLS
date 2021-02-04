CREATE OR REPLACE PACKAGE HRBZLS."PG_EWIDE_RECTRANS_01" IS

  -- Author  : ADMINISTRATOR
  -- Created : 2011-10-16
  -- Purpose : WANGYONG

  -- Public type declarations
  CURRENTDATE DATE;

  -- Public constant declarations
  ERRCODE CONSTANT INTEGER := -20012;

  -- Public function and procedure declarations
  --单据提交入口过程
  PROCEDURE APPROVE(P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);
  --追量收费 V --保持原有 追量收费
  PROCEDURE SP_RECTRANS102(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --追量收费 V --保持原有 垃圾费 松滋需求，不变表止码
  PROCEDURE SP_RECTRANS103(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --临时用水水费立账
  PROCEDURE SP_RECTRANS104(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2);

  --追收插入抄表计划到历史库 保持原有
  PROCEDURE SP_INSERTMRHIS(RTH         IN RECTRANSHD%ROWTYPE, --追收头
                           P_MRIFTRANS IN VARCHAR2, --抄表数据事务
                           MI          IN METERINFO%ROWTYPE, --水表信息
                           OMRID       OUT METERREADHIS.MRID%TYPE --抄表流水
                           );
  --追收插入抄表计划  by lgb
  PROCEDURE SP_INSERTMR(RTH         IN RECTRANSHD%ROWTYPE, --追收头
                        P_MRIFTRANS IN VARCHAR2, --抄表数据事务
                        MI          IN METERINFO%ROWTYPE, --水表信息
                        OMRID       OUT METERREAD.MRID%TYPE);
  --应收冲正完结过程 BY WANGYONG DATE 20111014
  --   检查单是否已完结
  --FOR循环处理每一条件冲正明细
  --检查单是否已审核果，
  --如果完结，直接路过
  --如已还已锁帐跳过
  --如果已销帐跳过
  --对没有审核的明细进行审核
  --  调用    sp_reccz_one_01

  --循环结束后更新完结标志
  --判断提交标志，如果为Y提交 COMMIT
  --如果有异常抛出异常
  PROCEDURE SP_RECCZ(P_BILLNO IN VARCHAR2, --单据编号
                     P_PER    IN VARCHAR2, --完结人
                     P_MEMO   IN VARCHAR2, --备注
                     P_COMMIT IN VARCHAR --是否提交标志
                     );

  --插入单负应收   与 应收冲正单条  （sp_reccz_one_01）   配合使用    BY WANGYONG     DATE 20111014

  PROCEDURE SP_RECCZ_INSERT_01(RCCH     IN RECCZHD%ROWTYPE, --RECCZHT 行变量
                               RCCD     IN RECCZDT%ROWTYPE, --RECCZDT 行变量
                               RLDE     IN OUT RECLIST%ROWTYPE, --reclist 应收
                               RLCR     IN OUT RECLIST%ROWTYPE, --reclist 应收
                               P_TRANS  IN RECLIST.RLTRANS%TYPE, --应收事务
                               P_PER    IN VARCHAR2, --完结人
                               P_MEMO   IN VARCHAR2, --备注
                               P_COMMIT IN VARCHAR --是否提交标志
                               )
  --复制正应收部信息，生成对应的负应收

  ;

  PROCEDURE SP_RECCZ_ONE_01(P_RLID     IN RECLIST.RLID%TYPE, --RECCZHT 行变量
                               P_COMMIT IN VARCHAR --是否提交标志
                               );

  function sp_recfzsl(p_rlid in VARCHAR2, --分帐流水
                      p_rlje    in number --分帐金额
                     ) return number ;

  --减量退费
  --1、已销帐：冲实收（退款） +冲应收 +补应收 +销应收
  --2、未销帐：冲应收 +补应收
  PROCEDURE SP_PAIDRECBACK(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  --应收调整（追加/追减）
  PROCEDURE RECADJUST(RAH   IN RECADJUSTHD%ROWTYPE,
                      RAD   IN RECADJUSTDT%ROWTYPE,
                      P_PER IN VARCHAR2,
                      RLCR  OUT RECLIST%ROWTYPE,
                      RLDE  OUT RECLIST%ROWTYPE);

  PROCEDURE RECBACK(P_RLID       IN VARCHAR2,
                    P_RDPIIDLIST IN VARCHAR2,
                    P_TRANS      IN VARCHAR2,
                    P_PER        IN VARCHAR2,
                    P_MEMO       IN VARCHAR2,
                    RLCR         OUT RECLIST%ROWTYPE);

  PROCEDURE SP_拆账单(P_NO IN VARCHAR2, P_PER IN VARCHAR2,P_DJLB IN VARCHAR2);

    /*PROCEDURE SP_RECFZRLID(P_RLID IN VARCHAR2,  --分账流水
                         P_SL   IN NUMBER     --分账水量

                               );*/

  PROCEDURE 构造冲正单据(P_RCHSMFID   IN VARCHAR2, --营业所
                   P_RCHDEPT    IN VARCHAR2, -- 创建部门
                   P_RCHCREPER  IN VARCHAR2, --创建人员
                   P_RCHCREDATE IN VARCHAR2, --创建日期
                   P_RL         RECLIST%ROWTYPE, --应收信息
                   P_RCHNO      IN OUT VARCHAR2, --输出单据号
                   P_COMMIT     IN VARCHAR2 --提交标志
                   );
  PROCEDURE 构造追量单据(P_RTHSMFID   IN VARCHAR2, --营业所
                   P_RTHDEPT    IN VARCHAR2, -- 创建部门
                   P_RTHCREPER  IN VARCHAR2, --创建人员
                   P_RTHCREDATE IN VARCHAR2, --创建日期
                   P_RL         RECLIST%ROWTYPE, --应收信息
                   P_RTHNO      IN OUT VARCHAR2, --输出单据号
                   P_COMMIT     IN VARCHAR2, --提交标志
                   P_MEMO       IN VARCHAR2);
  PROCEDURE SP_减量退费(P_BILLNO IN VARCHAR2, --单据编号
                    P_PER    IN VARCHAR2, --完结人
                    P_MEMO   IN VARCHAR2, --备注
                    P_COMMIT IN VARCHAR --是否提交标志
                    );
  PROCEDURE SP_减差价(P_BILLNO IN VARCHAR2, --单据编号
                   P_PER    IN VARCHAR2, --完结人
                   P_MEMO   IN VARCHAR2, --备注
                   P_COMMIT IN VARCHAR --是否提交标志
                   );
      --add by lgb 2013-09-09
  PROCEDURE SP_减量退费NEW(P_RAHNO  IN VARCHAR2, --单据编号
                       P_PER    IN VARCHAR2, --完结人
                       P_COMMIT IN VARCHAR --是否提交标志
                       );

  ---实收冲正
  PROCEDURE SP_PAIDBAK(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

  PROCEDURE SP_无表户算费;

    --追量收费 V --保持原有 追量收费
  PROCEDURE SP_预存冲正(P_NO IN VARCHAR2, P_PER IN VARCHAR2);

      --追量收费 V --保持原有 追量收费
  PROCEDURE SP_预存退费(P_NO IN VARCHAR2, P_PER IN VARCHAR2);
END;
/

