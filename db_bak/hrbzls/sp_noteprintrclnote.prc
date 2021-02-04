CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTE" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      select
            RLMID,                                                                             --Ë®±íºÅ
            max(ciname)  ciname,                                                               --ÓÃ»§Ãû
            max(ciadr) ciadr,                                                                  --ÓÃ»§µØÖ·
            max(miadr) miadr,                                                                  --±íµØÖ·
            max(micode) micode,                                                                --×ÊÁÏºÅ
            max(mibfid) mibfid,                                                                --±í²áºÅ
            to_char(max(mirorder)) mirorder,                                                            --³­±í´ÎÐò
            max(milb) milb,                                                                    --Ë®±íÀà±ð
            max(MISAFID) MISAFID,                                                              --ÇøÓò
           fGetOperName(max(MICPER))  MICPER ,                                                 --ÊÕ·ÑÔ±
            fGetOperName(max(BFRPER)) BFRPER ,                                                --³­±íÔ±
            to_char(max(case when TOOLS.fgetrecmonth(RLSMFID)=RLMONTH then RDSL else 0 end )) brsl,     --±¾ÔÂÇ··ÑË®Á¿
            tools.fformatnum(sum(case when TOOLS.fgetrecmonth(RLSMFID)=RLMONTH then RDJE else 0 end ),2) brjel,    --±¾ÔÂÇ··Ñ½ð¶î
            to_char(count(distinct rlid))  qfcount,                                           --Ç··ÑÆÚÊý
            tools.fformatnum(sum(RDJE),2)             qfJE   ,                                                     --Ç··Ñ½ð¶î
            c2     ,                                                                           --´òÓ¡Ô±±àºÅ
            fGetOperName(c2)    ,                                                              --´òÓ¡Ô±·­Òë
            c3                 ,                                                               --ÐòºÅ
            'Ô¤Áô×Ö¶Î1'             ,                                                          -- Ô¤Áô×Ö¶Î1
            'Ô¤Áô×Ö¶Î2'             ,                                                          -- Ô¤Áô×Ö¶Î2
            'Ô¤Áô×Ö¶Î3'             ,                                                          -- Ô¤Áô×Ö¶Î3
            'Ô¤Áô×Ö¶Î4'             ,                                                          -- Ô¤Áô×Ö¶Î4
            'Ô¤Áô×Ö¶Î5'             ,                                                          -- Ô¤Áô×Ö¶Î5
            'Ô¤Áô×Ö¶Î6'             ,                                                          -- Ô¤Áô×Ö¶Î6
            'Ô¤Áô×Ö¶Î7'             ,                                                          -- Ô¤Áô×Ö¶Î7
            'Ô¤Áô×Ö¶Î8'             ,                                                          -- Ô¤Áô×Ö¶Î8
            'Ô¤Áô×Ö¶Î9'             ,                                                          -- Ô¤Áô×Ö¶Î9
            'Ô¤Áô×Ö¶Î10'            ,                                                          -- Ô¤Áô×Ö¶Î10
            'Ô¤Áô×Ö¶Î11'            ,                                                          -- Ô¤Áô×Ö¶Î11
            'Ô¤Áô×Ö¶Î12'            ,                                                          -- Ô¤Áô×Ö¶Î12
            'Ô¤Áô×Ö¶Î13'            ,                                                          -- Ô¤Áô×Ö¶Î13
            'Ô¤Áô×Ö¶Î14'            ,                                                          -- Ô¤Áô×Ö¶Î14
            'Ô¤Áô×Ö¶Î15'            ,                                                          -- Ô¤Áô×Ö¶Î15
            'Ô¤Áô×Ö¶Î16'            ,                                                          -- Ô¤Áô×Ö¶Î16
            'Ô¤Áô×Ö¶Î17'            ,                                                          -- Ô¤Áô×Ö¶Î17
            'Ô¤Áô×Ö¶Î18'            ,                                                          -- Ô¤Áô×Ö¶Î18
            'Ô¤Áô×Ö¶Î19'            ,                                                          -- Ô¤Áô×Ö¶Î19
            'Ô¤Áô×Ö¶Î20'                                                                       -- Ô¤Áô×Ö¶Î20
         from reclist ,recdetail , meterinfo , custinfo , bookframe ,pbparmtemp
         where '1'='1' and  rlid=rdid and rlmid=miid and micid=ciid and  mibfid=bfid and  RLMID = c1 and
              RDPAIDFLAG = 'N'   AND RDJE>0 AND RLCD='DE'
              group by
              RLMID     ,
              c2        ,
              c3
          order by c3 ;
end ;
/

