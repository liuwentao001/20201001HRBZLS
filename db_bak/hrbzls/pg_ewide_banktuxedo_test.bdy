CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_EWIDE_BANKTUXEDO_TEST" is
  CurrentDate date := fGetSysDate;


  ----�����̣����ݽ��������ò�ͬ���׺�����
  PROCEDURE sp_main(p_str_in  in varchar2,
                    p_len_in  in number,
                    p_str_out out varchar2,
                    p_len_out out number)  is
    v_tempstr varchar2(32766);
    v_parm    varchar2(32766);
    v_type    varchar2(32766);
  begin
    v_tempstr := p_str_in || '|';
    v_type    := tools.fgetpara2(v_tempstr, 1, 1);

    if upper(v_type) = 'GETUSERDEBT' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      p_str_out := GetUserDebt(v_parm);
      p_len_out := length(p_str_out);
    end if;

    if upper(v_type) = 'WRITEOFF' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      p_str_out := WriteOff(v_parm, CurrentDate, PG_EWIDE_PAY_01.PAYTRANS_DS);
      p_len_out := length(p_str_out);
    end if;
    if upper(v_type) = 'CHECKBALANCE' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
        p_str_out := CheckBalance(v_parm, PG_EWIDE_PAY_01.PAYTRANS_BANKCR);
          p_len_out := length(p_str_out);
    end if;






    --return '1';
      p_str_out :=  nvl(v_type, '?');
       p_len_out := length(p_str_out);

  exception
    when others then
      --return '-1';
       p_str_out :=  nvl(v_type, '?');
      p_len_out := length(p_str_out);
  end;

  --�����������ݽ��������ò�ͬ���׺�����
  function main(p_str in varchar2) return varchar2 is
    v_tempstr varchar2(32766);
    v_parm    varchar2(32766);
    v_type    varchar2(32766);
  begin
    v_tempstr := p_str || '|';
    v_type    := fgetpara2(v_tempstr, 1, 1);

    if upper(v_type) = 'GETUSERDEBT' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return GetUserDebt(v_parm);
    end if;

    if upper(v_type) = 'WRITEOFF' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return WriteOff(v_parm, CurrentDate, PG_EWIDE_PAY_01.PAYTRANS_DS);
    end if;

  if upper(v_type) = 'CHECKBALANCE' then
      v_parm := substr(v_tempstr, instr(v_tempstr, '|') + 1);
      return CheckBalance(v_parm, PG_EWIDE_PAY_01.PAYTRANS_BANKCR);
    end if;
    --return '1';
    return nvl(v_type, '?');
  exception
    when others then
      --return '-1';
      return nvl(v_type, '?');
  end;
  ---------------------------------------------------------------------------
  --name:GetUserDebt
  --note: A���ɷ����빦��������������ˮ˾ǰ�û��������룬
  --����ȡ���û���Ƿ�Ѽ�¼��
  --ˮ˾���յ���������󣬴�����Ӧ�û���Ƿ�Ѽ�¼��
  --author:wy
  --date��2011/12/04
  --input: p_hh ���������hh|����1|����2  hh[����]ΪInt��
  --return F|����|����|��ַ|Ƿ�ѱ���|DATA1|DATA2|��|DATAn
  --��־λ��F
  --0�������ɹ���
  --1���û���û��Ƿ�ѻ�ǳ����û�����û��һ��DATA����ʱ��
  --2���û��Ų����ڣ�
  --99��ϵͳ���ϣ�
  --Data1..DatanΪǷ����Ϣ,��ʽΪ������ID|���ڳ�����|ˮ���·�|����
  /* ���  �ֶ��� �ֶ����ͼ����� ���ݼ�����
            1 ����ID  Int ÿ��ˮ�ѵ�Ψһ��ʶ�������У�
            2 ���ڳ����� Datetime��10��0��  �������ڣ�YYYY-MM-DD��
            3 ˮ���·�  Datetime��7��0�� ˮ���·�(YYYY-MM)
            4 ˮ�ѽ��  Numeric��13��2�� ˮ�ѽ��
            5 ΥԼ�� Numeric��13��2�� ΥԼ��
            6 ˮ������  Numeric��1��  0 ˮ�� 2 ׷��
            7 ���ڳ���  Numeric��8��0��  ����ˮ������
            8 ���ڳ���  Numeric��8��0��  ����ˮ������
            9 ʵ��ˮ��  Numeric��6��0��  ʵ��ˮ��
            10  ����ˮ���� Varchar(16) �����ڻ����ˮʱֻȡ����ˮ����,����Ϊ������
            11  �����ʵ��� Numeric(7,4)  ����ˮ���ʵ�ˮ��
            12  ���1���� Numeric(7,4)  ����ˮ�۵ĵ���
            13  ���1��� Numeric(13,2) ����ˮ�۵Ľ��
            14  ���2���� Numeric(13,2) ���۷ѵĵ���
            15  ���2��� Numeric(13,2) ���۷ѵĽ��
            16  Ʊ�ݱ�־  int 0 ��ӡ�վ� 1 ��ֵ��Ʊ  2 ˮ�ѷ�Ʊ
  */
  ---------------------------------------------------------------------------
  function GetUserDebt(p_hh in varchar2) return varchar2 is
    noyh exception; --�û�������
    noqf exception; --û��Ƿ��
    v_tempstr varchar2(32766); --���մ����ַ���
    v_headstr varchar2(32766); --ͷ�ַ���
    v_retstr  varchar2(32766); --�����ַ���
    v_qf      number(12, 2); --Ƿ�ѽ�� ָˮ�� �������ɽ��
    v_hh      varchar2(32766); --����
    v_zdj     number(12, 2); --����
    v_je1     number(12, 2); --���1
    v_dj1     number(12, 2); --����1
    v_je2     number(12, 2); --���2
    v_dj2     number(12, 2); --����2
    v_qfcount number(10); --Ƿ�ѱ���



  begin
    -- v_tempstr :=substr( substr(p_hh,2),1,length(p_hh  ) - 2 )   || '|';
    v_tempstr := p_hh || '|';
    v_hh      := tools.fgetpara2(v_tempstr, 1, 1);
    v_retstr :='0|Ƿ����Ϣ|�����|������������Ϫ��|1|29389111|2012-01-05|2012-01|28.05|0.00|0|0|17|17|��������|1.65|1.65|28.05|0.00|0.00|0';
    return v_retstr;

  end;

  ---------------------------------------------------------------------------
  --name:WriteOff
  --note: �����������ɷ�ȷ��,����֪ͨˮ˾��ĳ�û���ȷ�Ͻɷѡ�
  --author:wy
  --date��2011/12/04
  --input: p_hh �����д���|������ˮ��|ʵ�ձ���|ʵ�յص�|ʵ�տ�|ʵ�չ���|����ID1...|����IDn��
  --return  ��F|����|ʵ�տ�|������ˮ�š�
  /*˵     ����
             ������ˮ�ţ�14λ�ַ���1��2λΪ�������д��루JS�����裩����12λ������ȷ������Ӧ��֤�κ�ʱ�̲������ظ���ˮ�ţ�
             ʵ�ձ�����ʵ�����˼���ˮ�ѣ�
             ʵ�յص㣺����������룻
             ʵ�տ�ܽ��Ϊ2λС����
             �ɷ����ڣ���ʽΪ��YYYY-MM-DD����10λ����ɣ�
             ʵ�չ��ţ�����Ա�Ĺ��ţ�4λ
             ����ID��ÿ�ʷ��õ�Ψһ��ʶ��MISϵͳ��ֻ����ݷ���ID���ʼ��ɣ�

            ��־λ��F��
            0�������ɹ���
            1������ˮ�������ʣ�
            2������
            3����������
            99������ʧ�ܣ�
  */
  ---------------------------------------------------------------------------
  function WriteOff(p_hh          in varchar2,
                    p_paydatetime in date,
                    p_trans       in varchar2) return varchar2 is
    ---0�������ɹ���

    bfxz exception; --1����ˮ��������
    jebf exception; --2����
    qtqw exception; --3��������

    v_tempstr  varchar2(32766); --���մ����ַ���
    v_headstr  varchar2(32766); --ͷ�ַ���
    v_retstr   varchar2(32766); --�����ַ���
    v_retmsg   varchar2(32766); --���ؽ��
    v_fksrje   number(12, 2); --����ʣ����
    v_jfje     number(12, 2); --�ɷѽ��
    v_znj      number(12, 2); --���ɽ��
    v_sxf      number(12, 2); --������
    v_type     varchar2(10); --�ɷ�����
    v_FKFS     varchar2(10); --�ɷ�����
    V_IFP      varchar2(100); --�Ƿ�Ʊ
    V_INVNO    varchar2(100); --��Ʊ����
    V_COMMIT   varchar2(100); --�ύ
    v_xzcount  number(10); --���ʱ���
    v_hh       varchar2(32766); --����


    v_���д���           varchar2(1000);
    v_���ж�Ӧ����ܹ��� varchar2(10);
    v_������ˮ��         varchar2(1000);
    v_ʵ�ձ���           number(10);
    v_ʵ�յص�           varchar2(1000);
    v_ʵ�տ�             varchar2(1000);
    v_ʵ�չ���           varchar2(1000);
    v_����ID             varchar2(1000);




  begin

    -- �����д���|������ˮ��|ʵ�ձ���|ʵ�յص�|ʵ�տ�|ʵ�չ���|����ID1...|����IDn��
    if p_hh is null then
      raise qtqw;
    end if;
    v_tempstr := p_hh || '|';

    v_���д��� := substr(v_tempstr, 1, instr(v_tempstr, '|') - 1);
    if v_���д��� is null then
      raise qtqw;
    end if;
    v_���ж�Ӧ����ܹ��� := FBCODE2SMFID(v_���д���); --
    v_������ˮ��         := trim(substr(v_tempstr,
                                   instr(v_tempstr, '|', 1, 1) + 1,
                                   instr(v_tempstr, '|', 1, 2) -
                                   instr(v_tempstr, '|', 1, 1) - 1));
    if v_������ˮ�� is null then
      raise qtqw;
    end if;
    v_ʵ�ձ��� := to_number(trim(substr(v_tempstr,
                                    instr(v_tempstr, '|', 1, 2) + 1,
                                    instr(v_tempstr, '|', 1, 3) -
                                    instr(v_tempstr, '|', 1, 2) - 1)));
    if v_ʵ�ձ��� is null or v_ʵ�ձ��� < 1 then
      raise qtqw;
    end if;
    v_ʵ�յص� := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 3) + 1,
                          instr(v_tempstr, '|', 1, 4) -
                          instr(v_tempstr, '|', 1, 3) - 1));
    if v_ʵ�յص� is null then
      raise qtqw;
    end if;
    v_ʵ�տ� := to_number(trim(substr(v_tempstr,
                                   instr(v_tempstr, '|', 1, 4) + 1,
                                   instr(v_tempstr, '|', 1, 5) -
                                   instr(v_tempstr, '|', 1, 4) - 1)));
    if v_ʵ�տ� is null or not (v_ʵ�տ� > 0) then
      raise qtqw;
    end if;
    v_ʵ�չ��� := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 5) + 1,
                          instr(v_tempstr, '|', 1, 6) -
                          instr(v_tempstr, '|', 1, 5) - 1));
    if v_ʵ�չ��� is null then
      raise qtqw;
    end if;
    v_����ID := trim(substr(v_tempstr,
                          instr(v_tempstr, '|', 1, 6) + 1,
                          instr(v_tempstr, '|', 1, 7) -
                          instr(v_tempstr, '|', 1, 6) - 1));
    if v_����ID is null then
      raise qtqw;
    end if;

      v_retstr  :='0|�ɷ���Ϣ|29|JS111111111112|';

    return v_retstr;

  end;
  ---------------------------------------------------------------------------
  --name:CheckBalance
  --note: ��������������֪ͨˮ˾��ĳ�ʽ��׽��г�����
  --author:wy
  --date��2011/12/04
  --input: p_hh  ���д���|ʵ�տ�|������ˮ��
  --return  F|����|ʵ�տ�|������ˮ��
  /*��־λ��F��
                  0�������ɹ���
                  1��ˮ��δ���ʣ�
                  2�����û���������С�ڽ��죻
                  3��δ֪�Ľ�����ˮ��
                  4������
                  5�����û��ѿ���Ʊ��
                  6�����û��ѳ�����
                  7������ԭ��
                  99������ʧ�ܣ�
  */
  ---------------------------------------------------------------------------
  function CheckBalance(p_hh in varchar2, p_trans in varchar2)
    return varchar2 is
    ---0�������ɹ���

    sfwx exception; --1��ˮ��δ���ʣ���
    rqid exception; --2�����û���������С�ڽ��죻
    wzls exception; --3��δ֪�Ľ�����ˮ��
    jebf exception; --4������
    ykp exception; --5�����û��ѿ���Ʊ����Ԫ
    ycz exception; --6�����û��ѳ�����
    qtyy exception; --7������ԭ��

    v_tempstr  varchar2(32766); --���մ����ַ���
    v_headstr  varchar2(32766); --ͷ�ַ���
    v_retstr   varchar2(32766); --�����ַ���
    v_bs       number(10); --��ϸ����



    v_���д���           varchar2(1000);
    v_���ж�Ӧ����ܹ��� varchar2(10);
    v_������ˮ��         varchar2(1000);
    v_ʵ�տ�             varchar2(1000);
    v_retmsg             varchar2(100);

  begin

    -- ���д���|ʵ�տ�|������ˮ��
    if p_hh is null then
      raise qtyy;

    end if;
    v_tempstr := p_hh || '|';

    v_���д��� := substr(v_tempstr, 1, instr(v_tempstr, '|') - 1);
    if v_���д��� is null then
      raise qtyy;
    end if;
    v_���ж�Ӧ����ܹ��� := FBCODE2SMFID(v_���д���); --
    v_ʵ�տ�             := to_number(trim(substr(v_tempstr,
                                               instr(v_tempstr, '|', 1, 1) + 1,
                                               instr(v_tempstr, '|', 1, 2) -
                                               instr(v_tempstr, '|', 1, 1) - 1)));
    if v_ʵ�տ� is null or not v_ʵ�տ� > 0 then
      raise qtyy;
    end if;
    v_������ˮ�� := trim(substr(v_tempstr,
                           instr(v_tempstr, '|', 1, 2) + 1,
                           instr(v_tempstr, '|', 1, 3) -
                           instr(v_tempstr, '|', 1, 2) - 1));
    if v_������ˮ�� is null then
      raise qtyy;
    end if;
    v_retstr  := '0|����|29|JS111111111112|';
    return v_retstr;
  end;

---ss
 FUNCTION fGetSysDate RETURN DATE
  AS
    xtrq  DATE;
  BEGIN
    select to_date(to_char(sysdate,'YYYYMMDD'),'YYYY/MM/DD') INTO xtrq
	  FROM dual;
	RETURN xtrq;
  END;




   function fgetpara2(p_parastr in clob,rown in integer,coln in integer)
  return varchar2 is
    --һά�������#####|####|####|
    vchar nchar(1);
    v     varchar2(10000);
    vstr  varchar2(10000):='';
    r integer:=1;
    c integer:=0;
  begin
    v := trim(p_parastr);
    if length(v)=0 or substr(v,length(v))!='|' then
      raise_application_error(errcode,'�����ַ�����ʽ����'||p_parastr);
    end if;
    for i in 1..length(v) loop
      vchar := substr(v,i,1);
      case vchar
       when '|' then--һ�ж���(ÿ��ֻһ��)
          begin
            c := c+1;
            if r=rown and c=coln then
               return vstr;
            end if;
            r := r+1;
            c := 0;
            vstr := '';
          end;

       else
          begin
            vstr := vstr||vchar;
          end;
      end case;
    end loop;

    return '';
  end;

  -------------------------------------------------------------------------
  --name:CheckBack
  --note: ���ж����ļ����ɺ������FTP�ļ����书�ܣ�
  --  �Ѷ��ʵ��ļ������ˮ˾ǰ�û������ý���CheckBack֪ͨˮ˾��ʼ���ʣ�
  --ˮ˾������ϣ����ض��ʽ������������ٵ���FTP����ȡ���ʽ���ļ���
  --author:wy
  --date��2011/12/04
  --input: p_hh  ���д���|������|FileName|Length
  /*˵     ���������գ���ʽΪ��YYYY-MM-DD����10λ����ɣ�
  FilenName�������ļ���(���б���+��������(YYYYMMDD))+��.DZ����
           �����ļ���һ���ı��ļ���ÿһ��Ϊһ����¼����ʽ��
  ������Ϊ��ϸ�����������ݣ���������ˮ��|�ɷ�ʱ��|ʵ�ձ���|ʵ�յص�|ʵ�տ�|ʵ�չ���|����ID1|...|����IDn��
  ���һ��Ϊ�ܶ����������ݣ���0|������|�ܱ���|�ܽ��|ˮ�ѱ�����
    Length�������ļ��ĳ��ȣ�*/

  --return  F|����|������|���д���|�����ļ���
  /*˵     ����
             �����գ���ʽΪ��YYYY-MM-DD hh:mm:ss����19λ����ɣ�
  ��־λ��F��
                 0�������ɹ���
                 1����������������ʴ����ļ���
                 2�� �����ļ�����������ݲ���
                 3�� �����ڻ��ļ����Ȳ���
                 4�� �����ղ���ȷ
                 5:  �ļ��������ղ���ȷ
                 99������ʧ��,�����¶��ʣ�
             �����ļ��������������������ɴ��ļ����ļ�����ʽ����:
             FileName�������嵥�ļ���(���б��룫�����գ�YYYYMMDD��+��.DZCW��)
  ��   ʽ���ı��ļ���ÿ��һ����¼
           ���ʴ����ļ����������|������ˮ��|�����ա�
         ���һ�еĸ�ʽΪ��-1|�����¼����,
             ����ţ�
  01���������������������ղ�����
  02����������ˮ˾�˲����ڣ�
  03��ˮ˾�˶���Ľ��ף�
  04�����׽�����
  99����������

  */


end;
/

