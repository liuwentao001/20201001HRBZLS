CREATE OR REPLACE PROCEDURE HRBZLS."SP_SP_TSWSFPRINT_OCX" (p_modelno in varchar2) is
  v_constructhd     varchar2(30000);
  v_constructdt     varchar2(30000);
  v_contentstrorder varchar2(30000);
  v_hd              varchar2(30000);
  v_tempstr         varchar2(30000);
  v_conlen          number(10);
  I                 NUMBER(10);
  V_C1              VARCHAR2(3000);
  V_C2              VARCHAR2(3000);
  V_C3              VARCHAR2(3000);
  V_C4              VARCHAR2(3000);
  V_C5              VARCHAR2(3000);
  V_C6              VARCHAR2(3000);
  V_C7              VARCHAR2(3000);
  V_C8              VARCHAR2(3000);
  V_C9              VARCHAR2(3000);
  V_C10             VARCHAR2(3000);
  V_C11             VARCHAR2(3000);
  V_C12             VARCHAR2(3000);
  V_C13             VARCHAR2(3000);
  V_C14             VARCHAR2(3000);
  V_C15             VARCHAR2(3000);
  V_C16             VARCHAR2(3000);
  V_C17             VARCHAR2(3000);
  V_C18             VARCHAR2(3000);
  V_C19             VARCHAR2(3000);
  V_C20             VARCHAR2(3000);
  V_C21             VARCHAR2(3000);
  V_C22             VARCHAR2(3000);
  V_C23             VARCHAR2(3000);
  V_C24             VARCHAR2(3000);
  V_C25             VARCHAR2(3000);
  V_C26             VARCHAR2(3000);
  V_C27             VARCHAR2(3000);
  V_C28             VARCHAR2(3000);
  V_C29             VARCHAR2(3000);
  V_C30             VARCHAR2(3000);
  V_C31             VARCHAR2(3000);
  V_C32             VARCHAR2(3000);
  V_C33             VARCHAR2(3000);
  V_C34             VARCHAR2(3000);
  V_C35             VARCHAR2(3000);
  V_C36             VARCHAR2(3000);
  V_C37             VARCHAR2(3000);
  V_C38             VARCHAR2(3000);
  V_C39             VARCHAR2(3000);
  V_C40             VARCHAR2(3000);
  V_C41             VARCHAR2(3000);
  V_C42             VARCHAR2(3000);
  V_C43             VARCHAR2(3000);
  V_C44             VARCHAR2(3000);
  V_C45             VARCHAR2(3000);
  V_C46             VARCHAR2(3000);
  V_C47             VARCHAR2(3000);
  V_C48             VARCHAR2(3000);
  V_C49             VARCHAR2(3000);
  V_C50             VARCHAR2(3000);
  V_C51             VARCHAR2(3000);
  V_C52             VARCHAR2(3000);
  V_C53             VARCHAR2(3000);
  V_C54             VARCHAR2(3000);
  V_C55             VARCHAR2(3000);
  V_C56             VARCHAR2(3000);
  V_C57             VARCHAR2(3000);
  V_C58             VARCHAR2(3000);
  V_C59             VARCHAR2(3000);
  V_C60             VARCHAR2(3000);
  cursor c_hd is
    select constructhd, constructdt, contentstrorder
      from (select replace(connstr(trim(t.ptditemno) || '^' ||
                                   trim(round(t.ptdx)) || '^' ||
                                   trim(round(t.ptdy)) || '^' ||
                                   trim(round(t.ptdheight)) || '^' ||
                                   trim(round(t.ptdwidth)) || '^' ||
                                   trim(t.ptdfontname) || '^' ||
                                   trim(t.ptdfontsize * -1) || '^' ||
                                   trim(ftransformaling(t.ptdfontalign)) || '|'),
                           '|/',
                           '|') constructdt,
                   replace(connstr(trim(t.ptditemno)), '/', '^') || '|' contentstrorder
              from printtemplatedt_str t
             where ptdid = p_modelno
            --2
            ) b,
           (select pthpaperheight || '^' || pthpaperwidth || '^' || lastpage || '^' || 1 || '|' constructhd
              from printtemplatehd t1
             where pthid = p_modelno --2
            ) c;

  cursor c_dt is

    select max(etlbatch) C1, --托收批次号
           etlmiuiid C2, --托收凭证号
           max(to_char(eloutdate, 'yyyy')) C3, --年
           max(to_char(eloutdate, 'mm')) C4, --月
           max(to_char(eloutdate, 'dd')) C5, --日
           max(to_char(eloutdate, 'yyyy') || '/' ||
               to_char(eloutdate, 'mm') || '/' || to_char(eloutdate, 'dd')) C6, -- 打印日期,
           to_char(max(t3.rldate), 'yyyy') || '  ' ||
           to_char(max(t3.rldate), 'mm') || '  ' ||
           to_char(max(t3.rldate), 'dd') C7, -- 应收帐日期
           '' C8, --收款方式,
           max(t3.rlmcode) C9, --客户代码
           max(t3.rlcname) C10, --用户名
           max(t3.rlmadr) C11, --水表地址
           max(RLBFID) C12,  --表册
           (case
             when trim(max(rltel)) is not null then
              'tel:' || trim(max(rltel))
             when trim(max(rltel)) is null and trim(max(rlmtel)) is not null then
              'tel:' || trim(max(rlmtel))
             else
              ''
           end) C13, --电话
           max(RLRPER) C14,--抄表员
           fgetopername(max(c2)) C15, --抄表月份标题
           fgetopername(max(c2)) C16, --应收月份
           sp_getdjmx(etlmiuiid, max(etlseqno), 1) C17, --起码标题
           sp_getdjmx(etlmiuiid, max(etlseqno), 2) C18, --起码
           sp_getdjmx(etlmiuiid, max(etlseqno), 3) C19, --止码标题
           '' C20, --止码
           '水量' C21, --水量标题
           max(etlsl) C22, --水量
           '污水处理费' C23, --单价标题
           '' C24, --单价
           '污水处理费' C25, --水费标题
           '' C26, -- max(etlsl *F_GETTSDJ(etlseqno)  )C26,--水费
           '' C27, -- tools.fuppernumber(          max(F_GETTSJE(etlseqno ,etlmiuiid)  ) )C27,--大写
           sum(F_GETTSJE(rlid, null)) C28, --实收
           tools.fuppernumber(sum(F_GETTSJE(rlid, null))) C29, --大写
           -- max(c2) c2,--打印员编号x
           --   max(c3) c3, --顺序号
           fgetopername(max(c2)) C30, --打印员编号
           --     fgetopername( max(c2)) 打印员中文,--打印员中文
           max(etlaccountno) C31, --顺序号
           max(etlbankidname) C32, --备注
           '苏州吴中供水有限公司' C33, --预留2
           '建行苏州吴中经济开发区' C34, --开户账号
           '32201997591050682841' C35, --银行名称
           '' C36, --自来水公司
           fgetopername(max(c2)) C37, --自来水银行名称
           1 C38, --账号
           1 C39, --单位代码
           1 C40, --预留10
           1 C41, 1 C42, 1 C43, 1 C44, 1 C45, 1 C46, 1 C47, 1 C48, 1 C49, 1 C50, 1 C51, 1 C52, 1 C53, 1 C54, 1 C55, 1 C56, 1 C57, 1 C58, 1 C59, 1 C60
      from reclist t3, entrustlist t, entrustlog t1, pbparmtemp t2
     where
    --instr(ETLRLIDPIID, t3.rlid )>0
     t3.rlentrustseqno = etlseqno
     and t1.elbatch = t.etlbatch
     and etlseqno = C5
     and c4 = etlmiuiid
     group by etlmiuiid
     order by to_number(etlmiuiid);

begin
  open c_hd;
  fetch c_hd
    into v_constructhd, v_constructdt, v_contentstrorder;
  null;
  close c_hd;

  I        := 1;
  v_conlen := 0;
  DELETE PRINTLISTTEMP;
  open c_dt;
  loop
    fetch c_dt
      into V_C1,
           V_C2,
           V_C3,
           V_C4,
           V_C5,
           V_C6,
           V_C7,
           V_C8,
           V_C9,
           V_C10,
           V_C11,
           V_C12,
           V_C13,
           V_C14,
           V_C15,
           V_C16,
           V_C17,
           V_C18,
           V_C19,
           V_C20,
           V_C21,
           V_C22,
           V_C23,
           V_C24,
           V_C25,
           V_C26,
           V_C27,
           V_C28,
           V_C29,
           V_C30,
           V_C31,
           V_C32,
           V_C33,
           V_C34,
           V_C35,
           V_C36,
           V_C37,
           V_C38,
           V_C39,
           V_C40,
           V_C41,
           V_C42,
           V_C43,
           V_C44,
           V_C45,
           V_C46,
           V_C47,
           V_C48,
           V_C49,
           V_C50,
           V_C51,
           V_C52,
           V_C53,
           V_C54,
           V_C55,
           V_C56,
           V_C57,
           V_C58,
           V_C59,
           V_C60;
    exit when c_dt%notfound or c_dt%notfound is null;
    select replace(connstr(trim(v_c1) || '^' || trim(v_c2) || '^' ||
                           trim(v_c3) || '^' || trim(v_c4) || '^' ||
                           trim(v_c5) || '^' || trim(v_c6) || '^' ||
                           trim(v_c7) || '^' || trim(v_c8) || '^' ||
                           trim(v_c9) || '^' || trim(v_c10) || '^' ||
                           trim(v_c11) || '^' || trim(v_c12) || '^' ||
                           trim(v_c13) || '^' || trim(v_c14) || '^' ||
                           trim(v_c15) || '^' || trim(v_c16) || '^' ||
                           trim(v_c17) || '^' || trim(v_c18) || '^' ||
                           trim(v_c19) || '^' || trim(v_c20) || '^' ||
                           trim(v_c21) || '^' || trim(v_c22) || '^' ||
                           trim(v_c23) || '^' || trim(v_c24) || '^' ||
                           trim(v_c25) || '^' || trim(v_c26) || '^' ||
                           trim(v_c27) || '^' || trim(v_c28) || '^' ||
                           trim(v_c29) || '^' || trim(v_c30) || '^' ||
                           trim(v_c31) || '^' || trim(v_c32) || '^' ||
                           trim(v_c33) || '^' || trim(v_c34) || '^' ||
                           trim(v_c35) || '^' || trim(v_c36) || '^' ||
                           trim(v_c37) || '^' || trim(v_c38) || '^' ||
                           trim(v_c39) || '^' || trim(v_c40) || '|'),
                   '|/',
                   '|')
      into v_tempstr
      from dual;
    I        := I + 1;
    v_conlen := v_conlen + lengthb(v_tempstr);
    INSERT INTO PRINTLISTTEMP VALUES (I, v_tempstr);
  end loop;
  close c_dt;
  v_hd := trim(to_char(lengthb(v_constructhd || v_constructdt),
                       '0000000000')) ||
          trim(to_char(lengthb(v_contentstrorder) + v_conlen, '0000000000')) ||
          v_constructhd || v_constructdt || v_contentstrorder;
  INSERT INTO PRINTLISTTEMP VALUES (1, v_hd);

end;
/

