create or replace force view hrbzls.vie_δ���俨���û� as
select CISMFID Ӫ��˾,miid �û���,ciname �û��� ,ciadr ��ַ ,cinewdate ����ʱ��,mistatus ˮ��̬
    from meterinfo mi ,custinfo ci
    where  miid=ciid and
     MIBFID not in (select bfid from bookframe);

