CREATE OR REPLACE FORCE VIEW VIEW_CHAOBIAO AS
SELECT a.miid,a.MISEQNO,a.mismfid,a.mibfid,a.miadr,b.ciadr,a.mistid,a.mipfid,a.miside,c.MDMODEL,a.miclass,c.MDJIDIANZHUANHUAN,
       b.MICHARGETYPE,a.miface,a.MISTATUS,b.CIIFINV,a.miyl1,a.miyl2,(case a.MISTATUS when '29' then '是'
                            when '30' then '是'
                            else '否' end) as gudingliang,a.mirtid,c.MDCALIBER,a.isallowreading,c.MDBRAND,c.IFDZSB,b.ciname,c.MDNO,substr(a.MIBFID,1,5) as daihao
        from BS_METERINFO a
    left join BS_CUSTINFO b on b.CIID=a.MIID
    left join BS_METERDOC c on a.miid=c.MDID;
comment on table VIEW_CHAOBIAO is '抄表视图';
comment on column VIEW_CHAOBIAO.MIID is '水表档案编号';
comment on column VIEW_CHAOBIAO.MISEQNO is '用户号';
comment on column VIEW_CHAOBIAO.MISMFID is '营业分公司';
comment on column VIEW_CHAOBIAO.MIBFID is '表册';
comment on column VIEW_CHAOBIAO.MIADR is '用水地址';
comment on column VIEW_CHAOBIAO.CIADR is '用户地址';
comment on column VIEW_CHAOBIAO.MISTID is '行业分类';
comment on column VIEW_CHAOBIAO.MIPFID is '用水性质';
comment on column VIEW_CHAOBIAO.MISIDE is '表位';
comment on column VIEW_CHAOBIAO.MDMODEL is '计量方式';
comment on column VIEW_CHAOBIAO.MICLASS is '总分表';
comment on column VIEW_CHAOBIAO.MDJIDIANZHUANHUAN is '基电转换方式';
comment on column VIEW_CHAOBIAO.MICHARGETYPE is '收费方式';
comment on column VIEW_CHAOBIAO.MIFACE is '水表故障';
comment on column VIEW_CHAOBIAO.MISTATUS is '水表状态';
comment on column VIEW_CHAOBIAO.CIIFINV is '是否增值税';
comment on column VIEW_CHAOBIAO.MIYL1 is '等针标识';
comment on column VIEW_CHAOBIAO.MIYL2 is '总表收免';
comment on column VIEW_CHAOBIAO.GUDINGLIANG is '固定量';
comment on column VIEW_CHAOBIAO.MIRTID is '抄表方式';
comment on column VIEW_CHAOBIAO.MDCALIBER is '表口径';
comment on column VIEW_CHAOBIAO.ISALLOWREADING is '手工录入开关';
comment on column VIEW_CHAOBIAO.MDBRAND is '表厂家';
comment on column VIEW_CHAOBIAO.IFDZSB is '水表倒装';
comment on column VIEW_CHAOBIAO.CINAME is '用户名';
comment on column VIEW_CHAOBIAO.MDNO is '表身码';
comment on column VIEW_CHAOBIAO.DAIHAO is '代号';

