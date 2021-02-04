CREATE OR REPLACE PROCEDURE HRBZLS."REPCLEARINVNO" (
                         p_id          in varchar2, --实收批次
                         p_ilsmfid     IN VARCHAR2, --分公司
                         p_per    in varchar2, --操作员
                         p_iitype in varchar2, --发票类型
                         o_msg    out varchar2
                     )   as
  begin

      if p_iitype='S' THEN
        UPDATE RECLIST T SET T.RLILID=NULL WHERE RLPBATCH=p_id
        AND RLGROUP IN (1,3) AND RLMIEMAILFLAG='S'  ;
        UPDATE PAYMENT T SET T.PILID=NULL WHERE T.PBATCH=p_id ;
      ELSif p_iitype='W' THEN
         UPDATE RECLIST T SET T.RLILID=NULL WHERE RLPBATCH=p_id
        AND RLGROUP  = 2 AND RLMIEMAILFLAG='W'   ;
      ELSE
        o_msg :='清除发票处理异常';
        RETURN ;
      END IF;
      COMMIT;
      o_msg :='Y';
  exception
    when others then
      ROLLBACK;
      o_msg :='清除发票处理异常';
  end;
/

