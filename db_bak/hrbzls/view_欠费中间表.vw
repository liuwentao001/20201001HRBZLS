create or replace force view hrbzls.view_Ƿ���м�� as
select  rlsmfid  Ӫ����˾      ,
  rlmonth   �����·�   ,
  rlsl     ˮ��     ,
  rlje     �ܽ��     ,
  michargetype ˮ�����  ,
  case when nvl(rlreverseflag,'N')='Y' THEN '��' ELSE '��' END  ������־,
  case when nvl(rlbadflag,'N')='Y' THEN '��' ELSE '��' END     ���˱�־,
  rltrans     Ӧ������  ,
  rlpfid   ��ˮ����,
  charg1     ˮ��  ,
  charg2    ��ˮ��    ,
  charg3      ���ӷ�  ,
  misaving    Ԥ���� ,
  case when rlbadflag='Y' THEN  rlje ELSE 0 END ���˽��,
   case when rlbadflag='Y' THEN  charg1 ELSE 0 END ����ˮ��,
      case when rlbadflag='Y' THEN  charg2 ELSE 0 END ������ˮ��,
         case when rlbadflag='Y' THEN  charg3 ELSE 0 END ���˸��ӷ�
    from Ƿ���м��;

