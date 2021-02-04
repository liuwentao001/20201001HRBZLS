create or replace force view hrbzls.vie_未分配卡册用户 as
select CISMFID 营公司,miid 用户号,ciname 用户名 ,ciadr 地址 ,cinewdate 立户时间,mistatus 水表态
    from meterinfo mi ,custinfo ci
    where  miid=ciid and
     MIBFID not in (select bfid from bookframe);

