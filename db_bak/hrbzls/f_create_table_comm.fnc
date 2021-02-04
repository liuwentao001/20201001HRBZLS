CREATE OR REPLACE FUNCTION HRBZLS."F_CREATE_TABLE_COMM" (P_TBLNAME IN VARCHAR2,p_owner in varchar2) return CHAR is
  Result CHAR;
-- ¸üÐÂ±íµÄPBÖÐÎÄÁÐÃû
  V_TBLNAME VARCHAR2(255);
  CURSOR C1 IS
    select COLUMN_NAME,COMMENTS from all_col_comments where
owner=p_owner AND TABLE_NAME=p_tblname ;
v_comments varchar(255);
v_column_name varchar(100);
v_tab_comm varchar(255);
BEGIN
--  V_TBLNAME := P_TBLNAME;
V_TAB_COMM :=' ';
SELECT NVL(COMMENTS,' ') INTO V_TAB_COMM FROM ALL_TAB_COMMENTS A WHERE A.OWNER=P_OWNER
  AND A.TABLE_NAME=P_TBLNAME;

update pbcattbl set PBT_CMNT=V_TAB_COMM,pbd_fhgt=-9,pbd_ffce='Î¢ÈíÑÅºÚ',pbh_fhgt=-9,pbh_ffce='Î¢ÈíÑÅºÚ',pbl_fhgt=-

9,pbl_ffce='Î¢ÈíÑÅºÚ'
  where pbt_tnam=p_tblname and pbt_ownr=p_owner;
if sql%notfound then
INSERT INTO pbcattbl
  ( pbt_tnam, pbt_ownr, pbd_fhgt, pbd_fwgt, pbd_fitl, pbd_funl, pbd_fchr, pbd_fptc, pbd_ffce, pbh_fhgt,
  pbh_fwgt, pbh_fitl, pbh_funl, pbh_fchr, pbh_fptc, pbh_ffce, pbl_fhgt, pbl_fwgt, pbl_fitl, pbl_funl,
  pbl_fchr, pbl_fptc, pbl_ffce, pbt_cmnt)
  VALUES
  (p_tblname, p_owner, -9, 400, 'N', 'N', 0, 34, 'Î¢ÈíÑÅºÚ', -9, 400, 'N', 'N', 0, 34, 'Î¢ÈíÑÅºÚ', -9, 400,
  'N', 'N', 0, 34, 'ËÎÌå', v_tab_comm) ;
end if;

  OPEN C1 ;
  LOOP
    EXIT WHEN C1%NOTFOUND;
    FETCH C1 INTO v_column_name,v_comments;
    BEGIN
      update pbcatcol set pbc_labl=V_comments,pbc_cmnt=v_comments,pbc_hdr=v_comments where pbc_tnam=p_tblname
        and pbc_ownr=p_owner and pbc_cnam=V_column_name;
      if sql%notfound then
      INSERT INTO pbcatcol
      (pbc_tnam, pbc_ownr, pbc_cnam, pbc_labl, pbc_lpos, pbc_hdr, pbc_hpos, pbc_jtfy, pbc_mask, pbc_case,

pbc_hght, pbc_wdth, pbc_ptrn, pbc_bmap, pbc_init, pbc_edit, pbc_cmnt
      )
      VALUES  (p_tblname, p_owner, v_column_name, v_comments, 23, v_comments, 25, 25, '', 0, 57, 87, '', 'N',

'', '', v_comments) ;


      end if;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
      NULL;
    END;
  END LOOP;
  RETURN '0';
end  ;
/

