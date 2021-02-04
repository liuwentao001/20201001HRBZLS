CREATE OR REPLACE PACKAGE HRBZLS.PG_EWIDE_INTERFACE AS

/*
  oracle 11g FTP访问授权需要sysdba执行以下脚本
  BEGIN
    DBMS_NETWORK_ACL_ADMIN.drop_acl(acl => 'DXHACL.xml');
    --1.创建访问控制列表accessftp.xml，accessftp.xml控制列表拥有connect权限，并把这个权限给了KSZLS用户，
    DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(acl => 'DXHACL.xml', -- ACL的名字，自己定义    
                                      description => 'accessftp ACL', -- ACL的描述
                                      principal => 'DXHZLS', -- 这里是用户名，大写，表示把这个ACL的权限赋给KSZLS用户
                                      is_grant => true, --true：授权 ;false：禁止
                                      privilege => 'connect'); --授予或者禁止的网络权限
    --2.accessftp.xml控制列表添加resolve权限，且赋给B用户
    DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(acl => 'DXHACL.xml',
                                         principal => 'DXHZLS',
                                         is_grant => true,
                                         privilege => 'resolve');
    --3.为控制列表ACL accessftp.xml分配可以connect和resolve的host
    DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(acl => 'DXHACL.xml',
                                      host => '190.211.1.60'); --FTP服务器主机名
  END;
  /
  COMMIT;
  */

-- Public constant declarations
errcode  constant integer := -20013;--错误返回码
----过程提交控制
不提交             constant char(2) := 0;
提交               constant char(2) := 1;
调试               constant char(2) := 2;

-- Public type declarations
/*subtype sl_type is smslog_cache%rowtype;
type sl_table is table of sl_type;*/

-- Public function and procedure declarations
function Ftp################# return integer;
TYPE t_string_table IS TABLE OF VARCHAR2(32767);

FUNCTION login (p_host    IN  VARCHAR2,
                p_port    IN  VARCHAR2,
                p_user    IN  VARCHAR2,
                p_pass    IN  VARCHAR2,
                p_timeout IN  NUMBER := NULL)
  RETURN UTL_TCP.connection;

FUNCTION get_passive (p_conn  IN OUT NOCOPY  UTL_TCP.connection)
  RETURN UTL_TCP.connection;

PROCEDURE logout (p_conn   IN OUT NOCOPY  UTL_TCP.connection,
                  p_reply  IN             BOOLEAN := TRUE);

PROCEDURE send_command (p_conn     IN OUT NOCOPY  UTL_TCP.connection,
                        p_command  IN             VARCHAR2,
                        p_reply    IN             BOOLEAN := TRUE);

PROCEDURE get_reply (p_conn  IN OUT NOCOPY  UTL_TCP.connection);

FUNCTION get_local_ascii_data (p_dir   IN  VARCHAR2,
                               p_file  IN  VARCHAR2)
  RETURN CLOB;

FUNCTION get_local_binary_data (p_dir   IN  VARCHAR2,
                                p_file  IN  VARCHAR2)
  RETURN BLOB;

FUNCTION get_remote_ascii_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                p_file  IN             VARCHAR2)
  RETURN CLOB;

FUNCTION get_remote_binary_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                 p_file  IN             VARCHAR2)
  RETURN BLOB;

PROCEDURE put_local_ascii_data (p_data  IN  CLOB,
                                p_dir   IN  VARCHAR2,
                                p_file  IN  VARCHAR2);

PROCEDURE put_local_binary_data (p_data  IN  BLOB,
                                 p_dir   IN  VARCHAR2,
                                 p_file  IN  VARCHAR2);

PROCEDURE put_remote_ascii_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                 p_file  IN             VARCHAR2,
                                 p_data  IN             CLOB);

PROCEDURE put_remote_binary_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                  p_file  IN             VARCHAR2,
                                  p_data  IN             BLOB);
PROCEDURE cd (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2);
PROCEDURE get (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
               p_from_file  IN             VARCHAR2,
               p_to_dir     IN             VARCHAR2,
               p_to_file    IN             VARCHAR2);

PROCEDURE put (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
               p_from_dir   IN             VARCHAR2,
               p_from_file  IN             VARCHAR2,
               p_to_file    IN             VARCHAR2);

PROCEDURE get_direct (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
                      p_from_file  IN             VARCHAR2,
                      p_to_dir     IN             VARCHAR2,
                      p_to_file    IN             VARCHAR2);

PROCEDURE put_direct (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
                      p_from_dir   IN             VARCHAR2,
                      p_from_file  IN             VARCHAR2,
                      p_to_file    IN             VARCHAR2);

PROCEDURE help (p_conn  IN OUT NOCOPY  UTL_TCP.connection);

PROCEDURE ascii (p_conn  IN OUT NOCOPY  UTL_TCP.connection);

PROCEDURE binary (p_conn  IN OUT NOCOPY  UTL_TCP.connection);

PROCEDURE list (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                p_dir   IN             VARCHAR2,
                p_list  OUT            t_string_table);

PROCEDURE nlst (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                p_dir   IN             VARCHAR2,
                p_list  OUT            t_string_table);

PROCEDURE rename (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                  p_from  IN             VARCHAR2,
                  p_to    IN             VARCHAR2);

PROCEDURE delete (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                  p_file  IN             VARCHAR2);

PROCEDURE mkdir (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2);

PROCEDURE rmdir (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2);

PROCEDURE convert_crlf (p_status  IN  BOOLEAN);
PROCEDURE FtpPutBatchFile(p_bankid   in varchar2,
                            p_chddir   in varchar2,
                            p_batch    in number,
                            p_clob     in clob,
                            p_filename in varchar2,
                            p_commit   in number);
PROCEDURE FtpGetBatchFile(p_bankid   in varchar2,
                            p_chddir   in varchar2,
                            p_filename in varchar2,
                            o_clob     out clob);
PROCEDURE FtpGetBChkFile(p_bankid   in varchar2,
                           p_filename in varchar2,
                           p_date     in date,
                           o_clob     out clob);
PROCEDURE FtpDelFile(p_bankid in varchar2,
                     p_chddir in varchar2,
                     p_filename in varchar2);
Procedure SetFtpIp(p_bankid       in varchar2,
                     p_ftp_ip       out varchar2,
                     p_ftp_port     out varchar2,
                     p_ftp_user     out varchar2,
                     p_ftp_password out varchar2);
FUNCTION Socket############## return integer;
FUNCTION BSocket(iv_bankid            in varchar,
                   iv_sendbuf           in varchar,
                   iv_sendtimeout_value in number,
                   ov_recvbuf           out varchar)
  RETURN integer;
FUNCTION Socket2Webservice##### return integer;
PROCEDURE WSDLSocket(iv_sendbuf           in varchar,
                      iv_sendtimeout_value in number);
PROCEDURE RunSmsPush(p_jobno in number);
--PROCEDURE SmsPush(p_sltab in sl_table);
--PROCEDURE SmsPush(p_phonecode in varchar2 ,p_smscontent in varchar2);
FUNCTION ErrorLog############# return integer;
/*PROCEDURE ErrLog(p_func in varchar2,
                 p_others in varchar2);*/
END PG_EWIDE_INTERFACE;
/

