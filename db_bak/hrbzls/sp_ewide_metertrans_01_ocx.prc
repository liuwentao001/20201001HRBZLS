CREATE OR REPLACE PROCEDURE HRBZLS."SP_EWIDE_METERTRANS_01_OCX" (p_modelno in varchar2) is
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
select  CINAME                                                              c1, --ÓÃ»§Ãû³Æ
           cicode                                                                c2, --ÓÃ»§±àºÅ
           MDCALIBER                                                        c3,--Ë®±í¿Ú¾¶
           MIADR                                                                c4,--Ë®±íµØµã
           to_char(sysdate,'yyyy')                                          c5,--Äê
           to_char(sysdate,'MM')                                           c6,--ÔÂ
           to_char(sysdate,'dd')                                             c7,--ÈÕ
           to_char(sysdate,'hh24')                                          c8,--Ê±
           to_char(sysdate,'mi')                                              c9,--·Ö
           to_char(sysdate,'ss')                                               c10,--Ãë
           CIMTEL                                                                  c11,--ÁªÏµµç»°ÊÖ»ú
           CITEL1                                                                    c12,--ÁªÏµµç»°¹Ì»°1
           MIRCODE                                                                         c13,-- ³­±íÐÐ¶È
           null                                                                         c14,  --³­±íÔ±
           decode(pt.c2,'1','¡Ì1',null)                               c15, --Í¨ÖªÔ­Òò£º1¡¢Ë®±í½Ó¿ÚÂ©Ë®»ò±íÇ°·§»µ
           decode(pt.c2,'2','¡Ì2',null)                               c16, --Í¨ÖªÔ­Òò£º2¡¢¹º±í»ò¹º·§
           decode(pt.c2,'3','¡Ì3',null)                               c17, --Í¨ÖªÔ­Òò£º3¡¢Ïú»§»òÔÝÍ£
           decode(pt.c2,'4','¡Ì4',null)                               c18, --Í¨ÖªÔ­Òò£º4¡¢¹ÊÕÏ±í
           decode(pt.c2,'5','¡Ì5',null)                               c19, --Í¨ÖªÔ­Òò£º6¡¢ÖÜÆÚ»»±í
           decode(pt.c2,'6','¡Ì6',null)                               c20, --Í¨ÖªÔ­Òò£º7¡¢Ç··Ñ²ð±í
           null c21,	--Ô¤Áô×Ö¶Î1
           null c22,	--Ô¤Áô×Ö¶Î2
           null c23,	--Ô¤Áô×Ö¶Î3
           null c24,	--Ô¤Áô×Ö¶Î4
           null c25,	--Ô¤Áô×Ö¶Î5
           null c26,	--Ô¤Áô×Ö¶Î6
           null c27,	--Ô¤Áô×Ö¶Î7
           null c28,	--Ô¤Áô×Ö¶Î8
           null c29,	--Ô¤Áô×Ö¶Î9
           null c30,	--Ô¤Áô×Ö¶Î10
           null c31,	--Ô¤Áô×Ö¶Î11
           null c32,	--Ô¤Áô×Ö¶Î12
           null c33,	--Ô¤Áô×Ö¶Î13
           null c34,	--Ô¤Áô×Ö¶Î14
           null c35,	--Ô¤Áô×Ö¶Î15
           null c36,	--Ô¤Áô×Ö¶Î16
           null c37,	--Ô¤Áô×Ö¶Î17
           null c38,	--Ô¤Áô×Ö¶Î18
           null c39,	--Ô¤Áô×Ö¶Î19
           null c40,	--Ô¤Áô×Ö¶Î20
           null c41,	--Ô¤Áô×Ö¶Î21
           null c42,	--Ô¤Áô×Ö¶Î22
           null c43,	--Ô¤Áô×Ö¶Î23
           null c44,	--Ô¤Áô×Ö¶Î24
           null c45,	--Ô¤Áô×Ö¶Î25
           null c46,	--Ô¤Áô×Ö¶Î26
           null c47,  --Ô¤Áô×Ö¶Î27
           null c48,  --Ô¤Áô×Ö¶Î28
           null c49,  --Ô¤Áô×Ö¶Î29
           null c50,  --Ô¤Áô×Ö¶Î30
           null c51,  --Ô¤Áô×Ö¶Î31
           null c52,  --Ô¤Áô×Ö¶Î32
           null c53,  --Ô¤Áô×Ö¶Î33
           null c54,  --Ô¤Áô×Ö¶Î34
           null c55,  --Ô¤Áô×Ö¶Î35
           null c56,  --Ô¤Áô×Ö¶Î36
           null c57,  --Ô¤Áô×Ö¶Î37
           null c58,  --Ô¤Áô×Ö¶Î38
           null c59,  --Ô¤Áô×Ö¶Î39
           null c60   --Ô¤Áô×Ö¶Î40
from meterinfo mi,meterdoc md,custinfo ci,pbparmtemp pt
where ci.CIID   =  mi.MICID    and
           mi.miid = md.MDMID and
           mi.miid = pt.c1
;
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
                           trim(v_c39) || '^' || trim(v_c40) || '^' ||
                           trim(v_c41) || '^' || trim(v_c42) || '^' ||
                           trim(v_c43) || '^' || trim(v_c44) || '^' ||
                           trim(v_c45) || '^' || trim(v_c46) || '^' ||
                           trim(v_c47) || '^' || trim(v_c48) || '^' ||
                           trim(v_c49) || '^' || trim(v_c50) || '^' ||
                           trim(v_c51) || '^' || trim(v_c52) || '^' ||
                           trim(v_c53) || '^' || trim(v_c54) || '^' ||
                           trim(v_c55) || '^' || trim(v_c56) || '^' ||
                           trim(v_c57) || '^' || trim(v_c58) || '^' ||
                           trim(v_c59) || '^' || trim(v_c60) || '|'),
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

