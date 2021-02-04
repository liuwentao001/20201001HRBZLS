CREATE OR REPLACE PROCEDURE HRBZLS."WX_MHIS" is
    /*mi meterinfo%rowtype;
    ci custinfo%rowtype;*/
    mh meterreadhis%rowtype;
  begin

    delete meterreadhis;

    for i in (select * from reclist) loop
             select SEQ_MHIS.NEXTVAL into mh.mrid from dual; -- ��ˮ��
             mh.mrmonth                      := i.rlmonth; -- �����·�
             mh.mrsmfid                      := '020101'; -- Ӫ����˾
             mh.mrbfid                       := i.rlbfid; -- ���
             mh.mrbatch                      := 1; -- ��������
             mh.mrday                        := null; -- �ƻ�������
             mh.mrrorder                     := null; -- �������
             mh.mrcid                        := i.rlcid; -- �û����
             mh.mrccode                      := i.rlccode; -- �û���
             mh.mrmid                        := i.rlmid; -- ˮ����
             mh.mrmcode                      := i.rlmcode; -- ˮ���ֹ����
             mh.mrstid                       := '01'; -- ��ҵ����      meterinfo
             mh.mrmpid                       := i.rlmpid ; -- �ϼ�ˮ��
             mh.mrmclass                     := i.rlmclass ; -- ˮ����
             mh.mrmflag                      := 'Y'; -- ĩ����־
             mh.mrcreadate                   := null; -- ��������
             mh.mrinputdate                  := null; -- �༭����
             mh.mrreadok                     := 'Y'; -- ������־
             mh.mrrdate                      := i.rldate; -- ��������
             mh.mrrper                       := i.rlrper; -- ����Ա
             mh.mrprdate                     := i.rlprdate ; -- �ϴγ�������
             mh.mrscode                      := i.rlscode ; -- ���ڳ���
             mh.mrecode                      := i.rlecode ; -- ���ڳ���
             mh.mrsl                         := i.rlreadsl ; -- ����ˮ��
             mh.mrface                       := 'N'; -- ˮ�����
             mh.mrifsubmit                   := 'Y'; -- �Ƿ��ύ�Ʒ�
             mh.mrifhalt                     := 'N'; -- ϵͳͣ��
             mh.mrdatasource                 := '1'; -- ��������Դ
             mh.mrifignoreminsl              := null; -- ͣ����ͳ���
             mh.mrpdardate                   := null; -- ���������ʱ��
             mh.mroutflag                    := 'N'; -- �������������־
             mh.mroutid                      := null; -- �������������ˮ��
             mh.mroutdate                    := null; -- ���������������
             mh.mrinorder                    := null; -- ��������մ���
             mh.mrindate                     := null; -- �������������
             mh.mrrpid                       := null; -- �Ƽ�����
             mh.mrmemo                       := i.rlaccountname; -- ����ע
             mh.mrifgu                       := 'N'; -- �����־
             mh.mrifrec                      := 'Y'; -- �ѼƷ�
             mh.mrrecdate                    := i.rldate; -- �Ʒ�����
             mh.mrrecsl                      := i.rlsl; -- Ӧ��ˮ��
             mh.mraddsl                      := null; -- ����
             mh.mrcarrysl                    := null; -- ��λˮ��
             mh.mrctrl1                      := null; -- ���������λ1
             mh.mrctrl2                      := null; -- ���������λ2
             mh.mrctrl3                      := null; -- ���������λ3
             mh.mrctrl4                      := null; -- ���������λ4
             mh.mrctrl5                      := null; -- ���������λ5
             mh.mrchkflag                    := null; -- ���˱�־
             mh.mrchkdate                    := null; -- ��������
             mh.mrchkper                     := null; -- ������Ա
             mh.mrchkscode                   := null; -- ԭ����
             mh.mrchkecode                   := null; -- ԭֹ��
             mh.mrchksl                      := null; -- ԭˮ��
             mh.mrchkaddsl                   := null; -- ԭ����
             mh.mrchkcarrysl                 := null; -- ԭ��λˮ��
             mh.mrchkrdate                   := null; -- ԭ��������
             mh.mrchkface                    := null; -- ԭ���
             mh.mrchkresult                  := null; -- ���������
             mh.mrchkresultmemo              := null; -- �����˵��
             mh.mrprimid                     := i.rlprimcode ; -- ���ձ�����
             mh.mrprimflag                   := i.rlpriflag ; -- ���ձ��־
             mh.mrlb                         := i.rllb; -- ˮ�����
             mh.mrnewflag                    := 'N'; -- �±��־
             mh.mrface2                      := null; -- ��������
             mh.mrface3                      := null; -- �ǳ�����
             mh.mrface4                      := null; -- ����ʩ˵��
             mh.mrscodechar                  := i.rlscodechar ; -- ���ڳ���
             mh.mrecodechar                  := i.rlecodechar ; -- ���ڳ���
             mh.mrprivilegeflag              := 'N'; -- ��Ȩ��־(y/n)
             mh.mrprivilegeper               := null; -- ��Ȩ������
             mh.mrprivilegememo              := null; -- ��Ȩ������ע
             mh.mrprivilegedate              := null; -- ��Ȩ����ʱ��
             mh.mrsafid                      := null; -- ��������
             mh.mriftrans                    := 'N'; -- ת�칤����־
             mh.mrrequisition                := null; -- ֪ͨ����ӡ����
             mh.mrifchk                      := 'N'; -- ���˱�
             mh.mrinputper                   := null; -- ������Ա
             mh.mrpfid                       := i.rlpfid; -- ��ˮ���
             mh.mrcaliber                    := i.rlcaliber; -- �ھ�
             mh.mrside                       := 'O'; -- ��λ
             mh.mrlastsl                     := null; -- �ϴγ���ˮ��
             mh.mrthreesl                    := null; -- ǰ���³���ˮ��
             mh.mryearsl                     := null; -- ȥ��ͬ�ڳ���ˮ��
             mh.mrrecje01                    := null; -- Ӧ�ս�������Ŀ01
             mh.mrrecje02                    := null; -- Ӧ�ս�������Ŀ02
             mh.mrrecje03                    := null; -- Ӧ�ս�������Ŀ03
             mh.mrrecje04                    := null; -- Ӧ�ս�������Ŀ04

    insert into meterreadhis values mh;
    commit;
    end loop;

    exception when others then
    raise_application_error(-20010,sqlerrm||'kkkkkk');
    rollback;

  end;
/

