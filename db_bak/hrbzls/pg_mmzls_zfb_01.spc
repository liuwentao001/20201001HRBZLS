CREATE OR REPLACE PACKAGE HRBZLS."PG_MMZLS_ZFB_01" is
       ZB constant varchar2(1) :='2';   --�ܱ�
       FB constant varchar2(1):='3';   --�ֱ�
       PT constant varchar2(1):='1';   --��ͨ
      errcode constant integer := -20012;  --��������
      callogtxt   clob;
       --author:    ���Ⲩ
       --Created: 2011-11-06
       --user      :�ֱܷ��

       --�ṩˮ�ֱ��ⲿ���ù���
       /*������ p_MIPID  �ϼ�ˮ���ţ�
                       p_miid    �¼�ˮ����
                       p_type    ˮ�����������:
                                       ��AZ  �����ܱ�,DZ ɾ���ܱ�AF �����ֱ�,DF,ɾ���ֱ�
               p_fttype  ˮ�ѷ�̯��ʽ, �ڻ����ֵ�����棨syscharlist��
       */
       PROCEDURE sp_mmzls_zfb_set_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2, --�¼�ˮ����
                                                   p_type in varchar2,--ˮ�����������
                                                   p_fttype in varchar2, --ˮ�ѷ�̯��ʽ
                                                    p_msg   out varchar2
                                                    );
       --�����ܱ�
       --������p_MIPID  �ϼ�ˮ����
       --           p_fttype  ˮ�ѷ�̯��ʽ
       PROCEDURE sp_mmzls_zfb_addzb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                    p_fttype in varchar2   --ˮ�ѷ�̯��ʽ
                                                    );
       --ɾ���ܱ�
       --������p_MIPID  �ϼ�ˮ����
       PROCEDURE sp_mmzls_zfb_deletezb_01(
                                                   p_MIPID in varchar2 --�ϼ�ˮ����
                                                    );
        --�����ֱ�
        --����:p_MIPID �ϼ�ˮ����
         --          p_miid   �¼�ˮ����
         PROCEDURE sp_mmzls_zfb_addfb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2 --ˮ����
                                                    );
        --ɾ���ֱ�
        --����:p_MIPID �ϼ�ˮ����
         -- -         p_miid   �¼�ˮ����
        PROCEDURE sp_mmzls_zfb_deletefb_01(
                                                   p_MIPID in varchar2, --�ϼ�ˮ����
                                                   p_miid in varchar2 --ˮ����
                                                    );
          --��ȡӪҵ��
         function f_mmzls_getsmfid(p_mid in varchar2)return varchar2;
         -- �ֱܷ���ѹ���
          procedure SUBMIT_ZFB(P_MRPID in varchar2);
          --  -- �ֱܷ���ѹ���
           procedure SUBMIT_ZFB(P_MRPID in varchar2, log out clob);
           ----�ֱܷ���ѹ��� ����̯ˮ�ѡ�
            function f_mmzls_ftsf(p_mpid in varchar2,p_mrsl in number )return number;
end;
/

