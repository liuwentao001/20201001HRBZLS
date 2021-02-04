CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECADJUST" (p_CCDNO      in varchar2,
                                         p_PRINTTITLE in varchar2,
                                         p_PRINTER    in varchar2,
                                         o_base       out tools.out_base) is
  v_sql VARCHAR(20000);
begin
  open o_base for
        SELECT fGetsmfname(T2.RAHSMFID) Ӫҵ��,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 1, 4) ��,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 5, 2) ��,
           SUBSTR(to_char(T2.RAHCREDATE, 'YYYYMMDD'), 7, 2) ��,
           T2.RAHCNAME ����,
           T2.RAHMCODE �û�����,
           t2.RAHMADR ��ַ,
           FGETMETERCABILER(T2.RAHMID) �ھ�,
           FGETZHPRICE(T2.rahmcode)||'Ԫ/��' ˮ��,
           fgetmel(T2.RAHMID) �绰,
           tools.fuppernumber(abs(�ϼƽ��)) ��д���,
           fgetsclname('����ԭ��',t2.RAHMEMO) ����ԭ��,
           abs(A.����ˮ��)||'��' ����ˮ��,
           (tools.fformatnum(abs(b.ˮ��),2))||'Ԫ' ���˽��,
           (tools.fformatnum(abs(B.��Դ��),2))||'Ԫ' ��Դ��,
           (tools.fformatnum(abs(B.��ˮ��),2))||'Ԫ' ��ˮ��,
            t2.RAHCREPER||'��'|| fgetopername(t2.RAHCREPER) || '��' ������,
            t2.RAHSHPER||'��'|| fgetopername(t2.RAHSHPER) || '��'   �����Ա,
           abs(nvl(A.���²��Ʒѵ�ˮ��, 0)) || '��' || ', ' ||tools.fformatnum(abs(nvl(A.���²��ƷѵĽ��, 0)),2) || 'Ԫ' ����ˮ��,
           tools.fformatnum(abs(nvl(A.���²��ƷѵĽ��,0)),2) ���½��,
           abs(nvl(A.�ɵ�Ƿ��ˮ��, 0)) || '��' || ', ' ||tools.fformatnum(abs(nvl(A.�ɵ�Ƿ�ѽ��, 0)),2) || 'Ԫ' �ɵ�ˮ��,
           tools.fformatnum(abs(nvl(A.�ɵ�Ƿ�ѽ��,0)),2) �ɵĽ��,
           abs(nvl(A.�˶��ˮ��,0)) || '��' || ', ' ||tools.fformatnum(abs(nvl(A.�˶�ƽ��,0)),2) || 'Ԫ' ���ˮ��,
           tools.fformatnum(abs(A.�˶�ƽ��),2) ��ƽ��,
           abs(nvl(A.�˶���ˮ��,0)) || '��' || ', ' ||tools.fformatnum(abs(nvl(A.�˶��ؽ��,0)),2) || 'Ԫ' ����ˮ��,
           tools.fformatnum(abs(A.�˶��ؽ��),2) ���ؽ��,
           t2.RAHDETAILS ������ϸ,
           '��ΥԼ��'||' : '||tools.fformatnum(abs(nvl(���ɽ�,0)),2) ΥԼ��
      FROM recadjusthd T2,
           (select T.RADNO,
                   sum( T.RADADJSL ) ����ˮ��,
                   sum( T.RADADJje + nvl(RADZNJ,0)) �ϼƽ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJSL
                       end) ���²��Ʒѵ�ˮ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'N' then
                          T.RADADJJE
                       end) ���²��ƷѵĽ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJSL
                       end) �ɵ�Ƿ��ˮ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'N' then
                          T.RADADJJE
                       end) �ɵ�Ƿ�ѽ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'Y' then
                          T.RADADJSL
                       end) �˶��ˮ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) =
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'Y' then
                          T.RADADJJE
                       end) �˶�ƽ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                               t.RADPAIDFLAG = 'Y' then
                          T.RADADJSL
                       end) �˶���ˮ��,
                   sum(case
                         when substr(to_char(t.RADRDATE, 'yyyymmdd'), 1, 6) <>
                              substr(to_char(sysdate, 'yyyymmdd'), 1, 6) and
                                t.RADPAIDFLAG = 'Y' then
                          T.RADADJJE
                       end) �˶��ؽ��,
                   sum(RADZNJ) ���ɽ�
              from RECADJUSTDT T
              WHERE  T.radchkflag='Y'
             GROUP BY T.RADNO) A,
           (select T1.RADDNO,
                   nvl(sum(DECODE(T1.RADDPIID, '01', T1.RADDADJJE)),0) ˮ��,
                    nvl(sum(DECODE(T1.RADDPIID, '02', T1.RADDADJJE)),0) ��ˮ��,
                  nvl(sum(DECODE(T1.RADDPIID, '03', T1.RADDADJJE)),0) ��Դ��
              from RECADJUSTDDT T1,recadjustdt T5 WHERE T1.RADDNO=T5.RADNO AND T1.RADDROWNO=T5.RADROWNO
              AND T5.Radchkflag='Y' AND T1.RADDNO=p_CCDNO
             GROUP BY T1.RADDNO) B
     where T2.RAHNO = p_CCDNO

       and A.RADNO = B.RADDNO
       and B.RADDNO = t2.rahno;
end;
/

