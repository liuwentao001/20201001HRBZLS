create or replace force view vi_zhuiliang as
select a.ciid,a.ciname,a.ciname1,a.ciadr,
				b.mibfid,b.mistid,b.mircode,b.mirecsl,b.miid,
				c.mrscode,c.mrecode,
				'' czbqzz,'' sqzz,'' bnrjt,'' zblb,'' bz 
			from bs_meterinfo b 
			left join bs_custinfo a on b.micode=a.ciid 
			left join bs_meterread c on b.miid = c.mrmid;
comment on table VI_ZHUILIANG is '追量';
comment on column VI_ZHUILIANG.CIID is '用户号';
comment on column VI_ZHUILIANG.CINAME is '用户名';
comment on column VI_ZHUILIANG.CINAME1 is '票据名';
comment on column VI_ZHUILIANG.CIADR is '用水地址';
comment on column VI_ZHUILIANG.MIBFID is '表册';
comment on column VI_ZHUILIANG.MISTID is '用水类别';
comment on column VI_ZHUILIANG.MIRCODE is '上期抄表';
comment on column VI_ZHUILIANG.MIRECSL is '本期抄表';
comment on column VI_ZHUILIANG.MIID is '水表档案编号';
comment on column VI_ZHUILIANG.MRSCODE is '本期指针';
comment on column VI_ZHUILIANG.MRECODE is '应收水量';
comment on column VI_ZHUILIANG.CZBQZZ is '重置本期指针';
comment on column VI_ZHUILIANG.SQZZ is '上期指针';
comment on column VI_ZHUILIANG.BNRJT is '不纳入阶梯';
comment on column VI_ZHUILIANG.ZBLB is '追补类别';
comment on column VI_ZHUILIANG.BZ is '备注';

