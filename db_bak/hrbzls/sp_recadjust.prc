CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECADJUST" (p_CCDNO      in varchar2,
                                         p_PRINTTITLE in varchar2,
                                         p_PRINTER    in varchar2,
                                         o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  open o_base for
        SELECT fGetsmfname(T2.RAHSMFID) 营业所,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 1, 4) 年,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 5, 2) 月,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 7, 2) 日,
           T2.RAHCNAME 户名,
           T2.RAHMCODE 用户代码,
           t2.RAHMADR 地址,
           FGETMETERCABILER(T2.RAHMID) 口径,
           FGETZHPRICE(T2.rahmcode)||'元/吨' 水价,
           fgetmel(T2.RAHMID) 电话,
           tools.fuppernumber(abs(合计金额)) 大写金额,
           fgetsclname('减退原因',t2.RAHMEMO) 减退原因,
           abs(A.减退水量)||'吨' 减退水量,
           (tools.fformatnum(abs(b.水费),2))||'元' 减退金额,
           (tools.fformatnum(abs(B.资源费),2))||'元' 资源费,
           (tools.fformatnum(abs(B.污水费),2))||'元' 污水费,
            t2.RAHCREPER||'【'|| fgetopername(t2.RAHCREPER) || '】' 经办人,
            t2.RAHSHPER||'【'|| fgetopername(t2.RAHSHPER) || '】'   审核人员,
           abs(nvl(A.本月不计费的水量, 0)) || '吨' || ', ' ||tools.fformatnum(abs(nvl(A.本月不计费的金额, 0)),2) || '元' 本月水量,
           tools.fformatnum(abs(nvl(A.本月不计费的金额,0)),2) 本月金额,
           abs(nvl(A.旧的欠费水量, 0)) || '吨' || ', ' ||tools.fformatnum(abs(nvl(A.旧的欠费金额, 0)),2) || '元' 旧的水量,
           tools.fformatnum(abs(nvl(A.旧的欠费金额,0)),2) 旧的金额,
           abs(nvl(A.退多计水量,0)) || '吨' || ', ' ||tools.fformatnum(abs(nvl(A.退多计金额,0)),2) || '元' 多计水量,
           tools.fformatnum(abs(A.退多计金额),2) 多计金额,
           abs(nvl(A.退多重水量,0)) || '吨' || ', ' ||tools.fformatnum(abs(nvl(A.退多重金额,0)),2) || '元' 多重水量,
           tools.fformatnum(abs(A.退多重金额),2) 多重金额,
           t2.RAHDETAILS 减退明细,
           '退违约金'||' : '||tools.fformatnum(abs(nvl(滞纳金,0)),2) 违约金
      FROM recadjusthd T2,
           (select T.RADNO,
                   sum( T.RADADJSL ) 减退水量,
                   sum( T.RADADJje + nvl(RADZNJ,0)) 合计金额,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJSL
                       end) 本月不计费的水量,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'N' then
                          T.RADADJJE
                       end) 本月不计费的金额,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJSL
                       end) 旧的欠费水量,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJJE
                       end) 旧的欠费金额,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'Y' then
                          T.RADADJSL
                       end) 退多计水量,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'Y' then
                          T.RADADJJE
                       end) 退多计金额,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'Y' then
                          T.RADADJSL
                       end) 退多重水量,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'Y' then
                          T.RADADJJE
                       end) 退多重金额,
                   sum(RADZNJ) 滞纳金
              from RECADJUSTDT T
              WHERE  T.radchkflag='Y'
             GROUP BY T.RADNO) A,
           (select T1.RADDNO,
                   nvl(sum(DECODE(T1.RADDPIID, '01', T1.RADDADJJE)),0) 水费,
                    nvl(sum(DECODE(T1.RADDPIID, '02', T1.RADDADJJE)),0) 污水费,
                  nvl(sum(DECODE(T1.RADDPIID, '03', T1.RADDADJJE)),0) 资源费
              from RECADJUSTDDT T1,recadjustdt T5 WHERE T1.RADDNO=T5.RADNO AND T1.RADDROWNO=T5.RADROWNO
              AND T5.Radchkflag='Y' AND T1.RADDNO=p_CCDNO
             GROUP BY T1.RADDNO) B
     where T2.RAHNO = p_CCDNO

       and A.RADNO = B.RADDNO
       and B.RADDNO = t2.rahno;
end;
/

