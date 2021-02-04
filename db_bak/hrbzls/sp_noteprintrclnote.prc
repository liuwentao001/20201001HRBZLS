CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTE" (
                  o_base out tools.out_base) is
  begin
    open o_base for
      select
            RLMID,                                                                             --ˮ���
            max(ciname)  ciname,                                                               --�û���
            max(ciadr) ciadr,                                                                  --�û���ַ
            max(miadr) miadr,                                                                  --���ַ
            max(micode) micode,                                                                --���Ϻ�
            max(mibfid) mibfid,                                                                --����
            to_char(max(mirorder)) mirorder,                                                            --�������
            max(milb) milb,                                                                    --ˮ�����
            max(MISAFID) MISAFID,                                                              --����
           fGetOperName(max(MICPER))  MICPER ,                                                 --�շ�Ա
            fGetOperName(max(BFRPER)) BFRPER ,                                                --����Ա
            to_char(max(case when TOOLS.fgetrecmonth(RLSMFID)=RLMONTH then RDSL else 0 end )) brsl,     --����Ƿ��ˮ��
            tools.fformatnum(sum(case when TOOLS.fgetrecmonth(RLSMFID)=RLMONTH then RDJE else 0 end ),2) brjel,    --����Ƿ�ѽ��
            to_char(count(distinct rlid))  qfcount,                                           --Ƿ������
            tools.fformatnum(sum(RDJE),2)             qfJE   ,                                                     --Ƿ�ѽ��
            c2     ,                                                                           --��ӡԱ���
            fGetOperName(c2)    ,                                                              --��ӡԱ����
            c3                 ,                                                               --���
            'Ԥ���ֶ�1'             ,                                                          -- Ԥ���ֶ�1
            'Ԥ���ֶ�2'             ,                                                          -- Ԥ���ֶ�2
            'Ԥ���ֶ�3'             ,                                                          -- Ԥ���ֶ�3
            'Ԥ���ֶ�4'             ,                                                          -- Ԥ���ֶ�4
            'Ԥ���ֶ�5'             ,                                                          -- Ԥ���ֶ�5
            'Ԥ���ֶ�6'             ,                                                          -- Ԥ���ֶ�6
            'Ԥ���ֶ�7'             ,                                                          -- Ԥ���ֶ�7
            'Ԥ���ֶ�8'             ,                                                          -- Ԥ���ֶ�8
            'Ԥ���ֶ�9'             ,                                                          -- Ԥ���ֶ�9
            'Ԥ���ֶ�10'            ,                                                          -- Ԥ���ֶ�10
            'Ԥ���ֶ�11'            ,                                                          -- Ԥ���ֶ�11
            'Ԥ���ֶ�12'            ,                                                          -- Ԥ���ֶ�12
            'Ԥ���ֶ�13'            ,                                                          -- Ԥ���ֶ�13
            'Ԥ���ֶ�14'            ,                                                          -- Ԥ���ֶ�14
            'Ԥ���ֶ�15'            ,                                                          -- Ԥ���ֶ�15
            'Ԥ���ֶ�16'            ,                                                          -- Ԥ���ֶ�16
            'Ԥ���ֶ�17'            ,                                                          -- Ԥ���ֶ�17
            'Ԥ���ֶ�18'            ,                                                          -- Ԥ���ֶ�18
            'Ԥ���ֶ�19'            ,                                                          -- Ԥ���ֶ�19
            'Ԥ���ֶ�20'                                                                       -- Ԥ���ֶ�20
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

