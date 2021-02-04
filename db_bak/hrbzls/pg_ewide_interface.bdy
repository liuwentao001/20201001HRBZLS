CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_INTERFACE AS

  g_reply         t_string_table := t_string_table();
  g_binary        BOOLEAN := TRUE;
  g_debug         BOOLEAN := TRUE;
  g_convert_crlf  BOOLEAN := TRUE;

function Ftp################# return integer is
begin
  return 'FTP客户端类方法';
end;
-- --------------------------------------------------------------------------
-- Name         : http://www.oracle-base.com/dba/miscellaneous/ftp.pkb
-- Author       : Tim Hall
-- Description  : Basic FTP API. For usage notes see:
--                  http://www.oracle-base.com/articles/misc/ftp-from-plsql.php
-- Requirements : http://www.oracle-base.com/dba/miscellaneous/ftp.pks
-- Ammedments   :
--   When         Who       What
--   ===========  ========  =================================================
--   14-AUG-2003  Tim Hall  Initial Creation
--   10-MAR-2004  Tim Hall  Add convert_crlf procedure.
--                          Incorporate CRLF conversion functionality into
--                          put_local_ascii_data and put_remote_ascii_data
--                          functions.
--                          Make get_passive function visible.
--                          Added get_direct and put_direct procedures.
--   23-DEC-2004  Tim Hall  The get_reply procedure was altered to deal with
--                          banners starting with 4 white spaces. This fix is
--                          a small variation on the resolution provided by
--                          Gary Mason who spotted the bug.
--   10-NOV-2005  Tim Hall  Addition of get_reply after doing a transfer to
--                          pickup the 226 Transfer complete message. This
--                          allows gets and puts with a single connection.
--                          Issue spotted by Trevor Woolnough.
--   03-OCT-2006  Tim Hall  Add list, rename, delete, mkdir, rmdir procedures.
--   12-JAN-2007  Tim Hall  A final call to get_reply was added to the get_remote%
--                          procedures to allow multiple transfers per connection.
--   15-Jan-2008  Tim Hall  login: Include timeout parameter (suggested by Dmitry Bogomolov).
--   21-Jan-2008  Tim Hall  put_%: "l_pos < l_clob_len" to "l_pos <= l_clob_len" to prevent
--                          potential loss of one character for single-byte files or files
--                          sized 1 byte bigger than a number divisible by the buffer size
--                          (spotted by Michael Surikov).
--   23-Jan-2008  Tim Hall  send_command: Possible solution for ORA-29260 errors included,
--                          but commented out (suggested by Kevin Phillips).
--   12-Feb-2008  Tim Hall  put_local_binary_data and put_direct: Open file with "wb" for
--                          binary writes (spotted by Dwayne Hoban).
--   03-Mar-2008  Tim Hall  list: get_reply call and close of passive connection added
--                          (suggested by Julian, Bavaria).
--   12-Jun-2008  Tim Hall  A final call to get_reply was added to the put_remote%
--                          procedures, but commented out. If uncommented, it may cause the
--                          operation to hang, but it has been reported (morgul) to allow
--                          multiple transfers per connection.
--                          get_reply: Moved to pakage specification.
--   24-Jun-2008  Tim Hall  get_remote% and put_remote%: Exception handler added to close the passive
--                          connection and reraise the error (suggested by Mark Reichman).
--   22-Apr-2009  Tim Hall  get_remote_ascii_data: Remove unnecessary logout (suggested by John Duncan).
--                          get_reply and list: Handle 400 messages as well as 500 messages (suggested by John Duncan).
--                          logout: Added a call to UTL_TCP.close_connection, so not necessary to close
--                          any connections manually (suggested by Victor Munoz).
--                          get_local_*_data: Check for zero length files to prevent exception (suggested by Daniel)
--                          nlst: Added to return list of file names only (suggested by Julian and John Duncan)
--   05-Apr-2011  Tim Hall  put_remote_ascii_data: Added comment on definition of l_amount. Switch to 10000 if you get
--                          ORA-06502 from this line. May give you unexpected result due to conversion. Better to use binary.
--   05-OCt-2013  Tim Hall  list, nlst: Fixed bug where files beginning with '4' or '5' could cause error.
-- --------------------------------------------------------------------------

PROCEDURE debug (p_text  IN  VARCHAR2);

-- --------------------------------------------------------------------------
FUNCTION login (p_host    IN  VARCHAR2,
                p_port    IN  VARCHAR2,
                p_user    IN  VARCHAR2,
                p_pass    IN  VARCHAR2,
                p_timeout IN  NUMBER := NULL)
  RETURN UTL_TCP.connection IS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  g_reply.delete;

  l_conn := UTL_TCP.open_connection(p_host, p_port, tx_timeout => p_timeout);
  get_reply (l_conn);
  send_command(l_conn, 'USER ' || p_user);
  send_command(l_conn, 'PASS ' || p_pass);
  RETURN l_conn;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
FUNCTION get_passive (p_conn  IN OUT NOCOPY  UTL_TCP.connection)
  RETURN UTL_TCP.connection IS
-- --------------------------------------------------------------------------
  l_conn    UTL_TCP.connection;
  l_reply   VARCHAR2(32767);
  l_host    VARCHAR(100);
  l_port1   NUMBER(10);
  l_port2   NUMBER(10);
BEGIN
  send_command(p_conn, 'PASV');
  l_reply := g_reply(g_reply.last);

  l_reply := REPLACE(SUBSTR(l_reply, INSTR(l_reply, '(') + 1, (INSTR(l_reply, ')')) - (INSTR(l_reply, '('))-1), ',', '.');
  l_host  := SUBSTR(l_reply, 1, INSTR(l_reply, '.', 1, 4)-1);

  l_port1 := TO_NUMBER(SUBSTR(l_reply, INSTR(l_reply, '.', 1, 4)+1, (INSTR(l_reply, '.', 1, 5)-1) - (INSTR(l_reply, '.', 1, 4))));
  l_port2 := TO_NUMBER(SUBSTR(l_reply, INSTR(l_reply, '.', 1, 5)+1));

  l_conn := utl_tcp.open_connection(l_host, 256 * l_port1 + l_port2);
  return l_conn;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE logout(p_conn   IN OUT NOCOPY  UTL_TCP.connection,
                 p_reply  IN             BOOLEAN := TRUE) AS
-- --------------------------------------------------------------------------
BEGIN
  send_command(p_conn, 'QUIT', p_reply);
  UTL_TCP.close_connection(p_conn);
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE send_command (p_conn     IN OUT NOCOPY  UTL_TCP.connection,
                        p_command  IN             VARCHAR2,
                        p_reply    IN             BOOLEAN := TRUE) IS
-- --------------------------------------------------------------------------
  l_result  PLS_INTEGER;
BEGIN
  l_result := UTL_TCP.write_line(p_conn, p_command);
  -- If you get ORA-29260 after the PASV call, replace the above line with the following line.
  -- l_result := UTL_TCP.write_text(p_conn, p_command || utl_tcp.crlf, length(p_command || utl_tcp.crlf));

  IF p_reply THEN
    get_reply(p_conn);
  END IF;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE get_reply (p_conn  IN OUT NOCOPY  UTL_TCP.connection) IS
-- --------------------------------------------------------------------------
  l_reply_code  VARCHAR2(3) := NULL;
BEGIN
  LOOP
    g_reply.extend;
    g_reply(g_reply.last) := UTL_TCP.get_line(p_conn, TRUE);
    debug(g_reply(g_reply.last));
    IF l_reply_code IS NULL THEN
      l_reply_code := SUBSTR(g_reply(g_reply.last), 1, 3);
    END IF;
    IF SUBSTR(l_reply_code, 1, 1) IN ('4', '5') THEN
      RAISE_APPLICATION_ERROR(-20000, g_reply(g_reply.last));
    ELSIF (SUBSTR(g_reply(g_reply.last), 1, 3) = l_reply_code AND
           SUBSTR(g_reply(g_reply.last), 4, 1) = ' ') THEN
      EXIT;
    END IF;
  END LOOP;
EXCEPTION
  WHEN UTL_TCP.END_OF_INPUT THEN
    NULL;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
FUNCTION get_local_ascii_data (p_dir   IN  VARCHAR2,
                               p_file  IN  VARCHAR2)
  RETURN CLOB IS
-- --------------------------------------------------------------------------
  l_bfile   BFILE;
  l_data    CLOB;
BEGIN
  DBMS_LOB.createtemporary (lob_loc => l_data,
                            cache   => TRUE,
                            dur     => DBMS_LOB.call);

  l_bfile := BFILENAME(p_dir, p_file);
  DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);

  IF DBMS_LOB.getlength(l_bfile) > 0 THEN
    DBMS_LOB.loadfromfile(l_data, l_bfile, DBMS_LOB.getlength(l_bfile));
  END IF;

  DBMS_LOB.fileclose(l_bfile);

  RETURN l_data;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
FUNCTION get_local_binary_data (p_dir   IN  VARCHAR2,
                                p_file  IN  VARCHAR2)
  RETURN BLOB IS
-- --------------------------------------------------------------------------
  l_bfile   BFILE;
  l_data    BLOB;
BEGIN
  DBMS_LOB.createtemporary (lob_loc => l_data,
                            cache   => TRUE,
                            dur     => DBMS_LOB.call);

  l_bfile := BFILENAME(p_dir, p_file);
  DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
  IF DBMS_LOB.getlength(l_bfile) > 0 THEN
    DBMS_LOB.loadfromfile(l_data, l_bfile, DBMS_LOB.getlength(l_bfile));
  END IF;
  DBMS_LOB.fileclose(l_bfile);

  RETURN l_data;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
FUNCTION get_remote_ascii_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                p_file  IN             VARCHAR2)
  RETURN CLOB IS
-- --------------------------------------------------------------------------
  l_conn    UTL_TCP.connection;
  l_amount  PLS_INTEGER;
  l_buffer  VARCHAR2(10000);
  l_data    CLOB;
BEGIN
  DBMS_LOB.createtemporary (lob_loc => l_data,
                            cache   => TRUE,
                            dur     => DBMS_LOB.call);

  l_conn := get_passive(p_conn);
  send_command(p_conn, 'RETR ' || p_file, TRUE);
  --logout(l_conn, FALSE);

  BEGIN
    LOOP
      l_amount := UTL_TCP.read_text (l_conn, l_buffer, 10000);
      DBMS_LOB.writeappend(l_data, l_amount, l_buffer);
    END LOOP;
  EXCEPTION
    WHEN UTL_TCP.END_OF_INPUT THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END;
  UTL_TCP.close_connection(l_conn);
  get_reply(p_conn);

  RETURN l_data;

EXCEPTION
  WHEN OTHERS THEN
    UTL_TCP.close_connection(l_conn);
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
FUNCTION get_remote_binary_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                 p_file  IN             VARCHAR2)
  RETURN BLOB IS
-- --------------------------------------------------------------------------
  l_conn    UTL_TCP.connection;
  l_amount  PLS_INTEGER;
  l_buffer  RAW(32767);
  l_data    BLOB;
BEGIN
  DBMS_LOB.createtemporary (lob_loc => l_data,
                            cache   => TRUE,
                            dur     => DBMS_LOB.call);

  l_conn := get_passive(p_conn);
  send_command(p_conn, 'RETR ' || p_file, TRUE);

  BEGIN
    LOOP
      l_amount := UTL_TCP.read_raw (l_conn, l_buffer, 32767);
      DBMS_LOB.writeappend(l_data, l_amount, l_buffer);
    END LOOP;
  EXCEPTION
    WHEN UTL_TCP.END_OF_INPUT THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END;
  UTL_TCP.close_connection(l_conn);
  get_reply(p_conn);

  RETURN l_data;

EXCEPTION
  WHEN OTHERS THEN
    UTL_TCP.close_connection(l_conn);
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put_local_ascii_data (p_data  IN  CLOB,
                                p_dir   IN  VARCHAR2,
                                p_file  IN  VARCHAR2) IS
-- --------------------------------------------------------------------------
  l_out_file  UTL_FILE.file_type;
  l_buffer    VARCHAR2(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_clob_len  INTEGER;
BEGIN
  l_clob_len := DBMS_LOB.getlength(p_data);

  l_out_file := UTL_FILE.fopen(p_dir, p_file, 'w', 32767);

  WHILE l_pos <= l_clob_len LOOP
    DBMS_LOB.read (p_data, l_amount, l_pos, l_buffer);
    IF g_convert_crlf THEN
      l_buffer := REPLACE(l_buffer, CHR(13), NULL);
    END IF;

    UTL_FILE.put(l_out_file, l_buffer);
    UTL_FILE.fflush(l_out_file);
    l_pos := l_pos + l_amount;
  END LOOP;

  UTL_FILE.fclose(l_out_file);
EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(l_out_file) THEN
      UTL_FILE.fclose(l_out_file);
    END IF;
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put_local_binary_data (p_data  IN  BLOB,
                                 p_dir   IN  VARCHAR2,
                                 p_file  IN  VARCHAR2) IS
-- --------------------------------------------------------------------------
  l_out_file  UTL_FILE.file_type;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob_len  INTEGER;
BEGIN
  l_blob_len := DBMS_LOB.getlength(p_data);

  l_out_file := UTL_FILE.fopen(p_dir, p_file, 'wb', 32767);

  WHILE l_pos <= l_blob_len LOOP
    DBMS_LOB.read (p_data, l_amount, l_pos, l_buffer);
    UTL_FILE.put_raw(l_out_file, l_buffer, TRUE);
    UTL_FILE.fflush(l_out_file);
    l_pos := l_pos + l_amount;
  END LOOP;

  UTL_FILE.fclose(l_out_file);
EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(l_out_file) THEN
      UTL_FILE.fclose(l_out_file);
    END IF;
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put_remote_ascii_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                 p_file  IN             VARCHAR2,
                                 p_data  IN             CLOB) IS
-- --------------------------------------------------------------------------
  l_conn      UTL_TCP.connection;
  l_result    PLS_INTEGER;
  l_buffer    VARCHAR2(32767);
  l_amount    INTEGER:=10000;--BINARY_INTEGER := 4000;--BINARY_INTEGER := 32767; -- Switch to 10000 (or use binary) if you get ORA-06502 from this line.
  l_pos       INTEGER := 1;
  l_clob_len  INTEGER;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'STOR ' || p_file, TRUE);

  l_clob_len := DBMS_LOB.getlength(p_data);

  WHILE l_pos <= l_clob_len LOOP
    DBMS_LOB.READ (p_data, l_amount, l_pos, l_buffer);
    IF g_convert_crlf THEN
      l_buffer := REPLACE(l_buffer, CHR(13), NULL);
    END IF;
    l_result := UTL_TCP.write_text(l_conn, l_buffer, LENGTH(l_buffer));
    UTL_TCP.flush(l_conn);
    l_pos := l_pos + l_amount;
  END LOOP;

  UTL_TCP.close_connection(l_conn);
  -- The following line allows some people to make multiple calls from one connection.
  -- It causes the operation to hang for me, hence it is commented out by default.
  -- get_reply(p_conn);

EXCEPTION
  WHEN OTHERS THEN
    UTL_TCP.close_connection(l_conn);
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put_remote_binary_data (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                                  p_file  IN             VARCHAR2,
                                  p_data  IN             BLOB) IS
-- --------------------------------------------------------------------------
  l_conn      UTL_TCP.connection;
  l_result    PLS_INTEGER;
  l_buffer    RAW(32767);
  l_amount    BINARY_INTEGER := 32767;
  l_pos       INTEGER := 1;
  l_blob_len  INTEGER;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'STOR ' || p_file, TRUE);

  l_blob_len := DBMS_LOB.getlength(p_data);

  WHILE l_pos <= l_blob_len LOOP
    DBMS_LOB.READ (p_data, l_amount, l_pos, l_buffer);
    l_result := UTL_TCP.write_raw(l_conn, l_buffer, l_amount);
    UTL_TCP.flush(l_conn);
    l_pos := l_pos + l_amount;
  END LOOP;

  UTL_TCP.close_connection(l_conn);
  -- The following line allows some people to make multiple calls from one connection.
  -- It causes the operation to hang for me, hence it is commented out by default.
  -- get_reply(p_conn);

EXCEPTION
  WHEN OTHERS THEN
    UTL_TCP.close_connection(l_conn);
    RAISE;
END;
-- --------------------------------------------------------------------------



--进入子目录-----------------------------------------------------------------
PROCEDURE cd (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  if p_dir is not null then
   send_command(p_conn, 'CWD ' || p_dir, TRUE);
  end if;

END cd;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE get (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
               p_from_file  IN             VARCHAR2,
               p_to_dir     IN             VARCHAR2,
               p_to_file    IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
BEGIN
  IF g_binary THEN
    put_local_binary_data(p_data  => get_remote_binary_data (p_conn, p_from_file),
                          p_dir   => p_to_dir,
                          p_file  => p_to_file);
  ELSE
    put_local_ascii_data(p_data  => get_remote_ascii_data (p_conn, p_from_file),
                         p_dir   => p_to_dir,
                         p_file  => p_to_file);
  END IF;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
               p_from_dir   IN             VARCHAR2,
               p_from_file  IN             VARCHAR2,
               p_to_file    IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
BEGIN
  IF g_binary THEN
    put_remote_binary_data(p_conn => p_conn,
                           p_file => p_to_file,
                           p_data => get_local_binary_data(p_from_dir, p_from_file));
  ELSE
    put_remote_ascii_data(p_conn => p_conn,
                          p_file => p_to_file,
                          p_data => get_local_ascii_data(p_from_dir, p_from_file));
  END IF;
  get_reply(p_conn);
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE get_direct (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
                      p_from_file  IN             VARCHAR2,
                      p_to_dir     IN             VARCHAR2,
                      p_to_file    IN             VARCHAR2) IS
-- --------------------------------------------------------------------------
  l_conn        UTL_TCP.connection;
  l_out_file    UTL_FILE.file_type;
  l_amount      PLS_INTEGER;
  l_buffer      VARCHAR2(32767);
  l_raw_buffer  RAW(32767);
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'RETR ' || p_from_file, TRUE);
  IF g_binary THEN
    l_out_file := UTL_FILE.fopen(p_to_dir, p_to_file, 'wb', 32767);
  ELSE
    l_out_file := UTL_FILE.fopen(p_to_dir, p_to_file, 'w', 32767);
  END IF;

  BEGIN
    LOOP
      IF g_binary THEN
        l_amount := UTL_TCP.read_raw (l_conn, l_raw_buffer, 32767);
        UTL_FILE.put_raw(l_out_file, l_raw_buffer, TRUE);
      ELSE
        l_amount := UTL_TCP.read_text (l_conn, l_buffer, 32767);
        IF g_convert_crlf THEN
          l_buffer := REPLACE(l_buffer, CHR(13), NULL);
        END IF;
        UTL_FILE.put(l_out_file, l_buffer);
      END IF;
      UTL_FILE.fflush(l_out_file);
    END LOOP;
  EXCEPTION
    WHEN UTL_TCP.END_OF_INPUT THEN
      NULL;
    WHEN OTHERS THEN
      NULL;
  END;
  UTL_FILE.fclose(l_out_file);
  UTL_TCP.close_connection(l_conn);
EXCEPTION
  WHEN OTHERS THEN
    IF UTL_FILE.is_open(l_out_file) THEN
      UTL_FILE.fclose(l_out_file);
    END IF;
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE put_direct (p_conn       IN OUT NOCOPY  UTL_TCP.connection,
                      p_from_dir   IN             VARCHAR2,
                      p_from_file  IN             VARCHAR2,
                      p_to_file    IN             VARCHAR2) IS
-- --------------------------------------------------------------------------
  l_conn        UTL_TCP.connection;
  l_bfile       BFILE;
  l_result      PLS_INTEGER;
  l_amount      PLS_INTEGER := 32767;
  l_raw_buffer  RAW(32767);
  l_len         NUMBER;
  l_pos         NUMBER := 1;
  ex_ascii      EXCEPTION;
BEGIN
  IF NOT g_binary THEN
    RAISE ex_ascii;
  END IF;

  l_conn := get_passive(p_conn);
  send_command(p_conn, 'STOR ' || p_to_file, TRUE);

  l_bfile := BFILENAME(p_from_dir, p_from_file);

  DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
  l_len := DBMS_LOB.getlength(l_bfile);

  WHILE l_pos <= l_len LOOP
    DBMS_LOB.READ (l_bfile, l_amount, l_pos, l_raw_buffer);
    debug(l_amount);
    l_result := UTL_TCP.write_raw(l_conn, l_raw_buffer, l_amount);
    l_pos := l_pos + l_amount;
  END LOOP;

  DBMS_LOB.fileclose(l_bfile);
  UTL_TCP.close_connection(l_conn);
EXCEPTION
  WHEN ex_ascii THEN
    RAISE_APPLICATION_ERROR(-20000, 'PUT_DIRECT not available in ASCII mode.');
  WHEN OTHERS THEN
    IF DBMS_LOB.fileisopen(l_bfile) = 1 THEN
      DBMS_LOB.fileclose(l_bfile);
    END IF;
    RAISE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE help (p_conn  IN OUT NOCOPY  UTL_TCP.connection) AS
-- --------------------------------------------------------------------------
BEGIN
  send_command(p_conn, 'HELP', TRUE);
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE ascii (p_conn  IN OUT NOCOPY  UTL_TCP.connection) AS
-- --------------------------------------------------------------------------
BEGIN
  send_command(p_conn, 'TYPE A', TRUE);
  g_binary := FALSE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE binary (p_conn  IN OUT NOCOPY  UTL_TCP.connection) AS
-- --------------------------------------------------------------------------
BEGIN
  send_command(p_conn, 'TYPE I', TRUE);
  g_binary := TRUE;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE list (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                p_dir   IN             VARCHAR2,
                p_list  OUT            t_string_table) AS
-- --------------------------------------------------------------------------
  l_conn        UTL_TCP.connection;
  l_list        t_string_table := t_string_table();
  l_reply_code  VARCHAR2(3) := NULL;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'LIST ' || p_dir, TRUE);

  BEGIN
    LOOP
      l_list.extend;
      l_list(l_list.last) := UTL_TCP.get_line(l_conn, TRUE);
      debug(l_list(l_list.last));
      IF l_reply_code IS NULL THEN
        l_reply_code := SUBSTR(l_list(l_list.last), 1, 3);
      END IF;
      IF (SUBSTR(l_reply_code, 1, 1) IN ('4', '5')  AND
          SUBSTR(l_reply_code, 4, 1) = ' ') THEN
        RAISE_APPLICATION_ERROR(-20000, l_list(l_list.last));
      ELSIF (SUBSTR(g_reply(g_reply.last), 1, 3) = l_reply_code AND
             SUBSTR(g_reply(g_reply.last), 4, 1) = ' ') THEN
        EXIT;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN UTL_TCP.END_OF_INPUT THEN
      NULL;
  END;

  l_list.delete(l_list.last);
  p_list := l_list;

  utl_tcp.close_connection(l_conn);
  get_reply (p_conn);
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE nlst (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                p_dir   IN             VARCHAR2,
                 p_list  OUT            t_string_table) AS
-- --------------------------------------------------------------------------
  l_conn        UTL_TCP.connection;
  l_list        t_string_table := t_string_table();
  l_reply_code  VARCHAR2(3) := NULL;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'NLST ' || p_dir, TRUE);

  BEGIN
    LOOP
      l_list.extend;
      l_list(l_list.last) := UTL_TCP.get_line(l_conn, TRUE);
      debug(l_list(l_list.last));
      IF l_reply_code IS NULL THEN
        l_reply_code := SUBSTR(l_list(l_list.last), 1, 3);
      END IF;
      IF (SUBSTR(l_reply_code, 1, 1) IN ('4', '5')  AND
          SUBSTR(l_reply_code, 4, 1) = ' ') THEN
        RAISE_APPLICATION_ERROR(-20000, l_list(l_list.last));
      ELSIF (SUBSTR(g_reply(g_reply.last), 1, 3) = l_reply_code AND
             SUBSTR(g_reply(g_reply.last), 4, 1) = ' ') THEN
        EXIT;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN UTL_TCP.END_OF_INPUT THEN
      NULL;
  END;

  l_list.delete(l_list.last);
  p_list := l_list;

  utl_tcp.close_connection(l_conn);
  get_reply (p_conn);
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE rename (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                  p_from  IN             VARCHAR2,
                  p_to    IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'RNFR ' || p_from, TRUE);
  send_command(p_conn, 'RNTO ' || p_to, TRUE);
  logout(l_conn, FALSE);
END rename;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE delete (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                  p_file  IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'DELE ' || p_file, TRUE);
  logout(l_conn, FALSE);
END delete;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE mkdir (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'MKD ' || p_dir, TRUE);
  logout(l_conn, FALSE);
END mkdir;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE rmdir (p_conn  IN OUT NOCOPY  UTL_TCP.connection,
                 p_dir   IN             VARCHAR2) AS
-- --------------------------------------------------------------------------
  l_conn  UTL_TCP.connection;
BEGIN
  l_conn := get_passive(p_conn);
  send_command(p_conn, 'RMD ' || p_dir, TRUE);
  logout(l_conn, FALSE);
END rmdir;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE convert_crlf (p_status  IN  BOOLEAN) AS
-- --------------------------------------------------------------------------
BEGIN
  g_convert_crlf := p_status;
END;
-- --------------------------------------------------------------------------



-- --------------------------------------------------------------------------
PROCEDURE debug (p_text  IN  VARCHAR2) IS
-- --------------------------------------------------------------------------
BEGIN
  IF g_debug THEN
    DBMS_OUTPUT.put_line(SUBSTR(p_text, 1, 255));
  END IF;
END;
-- --------------------------------------------------------------------------

-- 设置水司FTP服务IP及外部网点授权
  --水司测试FTP  192.168.6.29:21
  Procedure SetFtpIp(p_bankid       in varchar2,
                     p_ftp_ip       out varchar2,
                     p_ftp_port     out varchar2,
                     p_ftp_user     out varchar2,
                     p_ftp_password out varchar2) is
  begin
    p_ftp_ip := fgetsysmanapara(p_bankid,'000004');
    p_ftp_port := fgetsysmanapara(p_bankid,'000005');
    p_ftp_user := fgetsysmanapara(p_bankid,'000006');
    p_ftp_password := fgetsysmanapara(p_bankid,'000007');
  exception when others then
    null;
  END SetFtpIp;

  Procedure FtpPutBatchFile(p_bankid   in varchar2,
                            p_chddir   in varchar2,
                            p_batch    in number,
                            p_clob     in clob,
                            p_filename in varchar2,
                            p_commit   in number) IS
    l_conn        UTL_TCP.connection;
    p_ftpip       varchar2(15);
    p_ftpport     varchar2(8);
    p_ftpuser     varchar2(100);
    p_ftppassword varchar2(100);
  BEGIN
    SetFtpIp(p_bankid       => p_bankid,
             p_ftp_ip       => p_ftpip,
             p_ftp_port     => p_ftpport,
             p_ftp_user     => p_ftpuser,
             p_ftp_password => p_ftppassword);

    l_conn := login(p_ftpip, p_ftpport, p_ftpuser, p_ftppassword);
  --  dbms_lock.sleep(1);
    ascii(p_conn => l_conn);
    if p_chddir is not null then
      cd(l_conn,p_chddir);
    end if;

    --dbms_lock.sleep(1);
    put_remote_ascii_data(p_conn => l_conn,
                              p_file => p_filename,
                              p_data => p_clob);
    --dbms_lock.sleep(1);--20150812
    logout(l_conn);
   -- dbms_lock.sleep(1);--20150812
    utl_tcp.close_all_connections;

    /*update am_entrustlog
       set elftppathfilename = p_filename
     where elbatch = p_batch;*/

    --2、提交处理
    begin
      if p_commit = 调试 then
        rollback;
      else
        if p_commit = 提交 then
          commit;
        elsif p_commit = 不提交 then
          null;
        else
          raise_application_error(errcode, '是否提交参数不正确');
        end if;
      end if;
    end;
  exception
    when others then
      rollback;
      raise;
  END FtpPutBatchFile;

  /*读取ftp批扣文件内容
  输入参数说明：
  p_bankid in varchar2：非空,用于访问水司内对某一代收银行部署的FTP服务器
  p_filename in varchar2：可空、非空时以此找到对帐文件,为空时根据对账时间+银行编码+文件名规则定位队长文件
  输出参数说明：
  o_clob out clob：对帐文本内容
  过程说明：
  */
  Procedure FtpGetBatchFile(p_bankid   in varchar2,
                            p_chddir   in varchar2,
                            p_filename in varchar2,
                            o_clob     out clob) is
    l_conn         UTL_TCP.connection;
    p_ftp_ip       varchar2(15);
    p_ftp_port     varchar2(8);
    p_ftp_user     varchar2(100);
    p_ftp_password varchar2(100);
  begin
    SetFtpIp(p_bankid       => p_bankid,
             p_ftp_ip       => p_ftp_ip,
             p_ftp_port     => p_ftp_port,
             p_ftp_user     => p_ftp_user,
             p_ftp_password => p_ftp_password);

    l_conn := login(p_ftp_ip, p_ftp_port, p_ftp_user, p_ftp_password);
   -- dbms_lock.sleep(1);--20150812
    ascii(p_conn => l_conn);
    if p_chddir is not null then
      cd(l_conn,p_chddir);
    end if;
    o_clob := get_remote_ascii_data(p_conn => l_conn,
                                        p_file => p_filename);

   -- dbms_lock.sleep(1);--20150812
    logout(l_conn);
    utl_tcp.close_all_connections;
  exception
    when others then
      raise;
      --dbms_output.put_line(sqlerrm);
  END FtpGetBatchFile;

  /*读取ftp对帐文件内容
  输入参数说明：
  p_bankid in varchar2：非空,用于访问水司内对某一代收银行部署的FTP服务器
  p_filename in varchar2：可空、非空时以此找到对帐文件,为空时根据对账时间+银行编码+文件名规则定位队长文件
  p_bankid in varchar2：p_filename为空时根据对账时间+银行编码+文件名规则定位队长文件
  p_date in date：p_filename为空时根据对账时间+银行编码+文件名规则定位队长文件
  输出参数说明：
  o_clob out clob：对帐文本内容
  过程说明：
  */
  Procedure FtpGetBChkFile(p_bankid   in varchar2,
                           p_filename in varchar2,
                           p_date     in date,
                           o_clob     out clob) is
    l_conn         UTL_TCP.connection;
    p_ftp_ip       varchar2(15);
    p_ftp_port     varchar2(8);
    p_ftp_user     varchar2(100);
    p_ftp_password varchar2(100);

    vfilename varchar2(100);
  begin
    SetFtpIp(p_bankid       => p_bankid,
             p_ftp_ip       => p_ftp_ip,
             p_ftp_port     => p_ftp_port,
             p_ftp_user     => p_ftp_user,
             p_ftp_password => p_ftp_password);

    --确认文件名
    if p_filename is not null then
      vfilename := p_filename;
    else
      vfilename := 'dz' || p_bankid || '_' || to_char(p_date, 'yyyymmdd') ||
                   '.txt';
    end if;
    --读
    l_conn := login(p_ftp_ip, p_ftp_port, p_ftp_user, p_ftp_password);
    --dbms_lock.sleep(1);--20150812
    ascii(p_conn => l_conn);
    o_clob := get_remote_ascii_data(p_conn => l_conn,
                                        p_file => vfilename);
    --dbms_lock.sleep(1);--20150812
    logout(l_conn);
    utl_tcp.close_all_connections;
  exception
    when others then
      rollback;
      raise;
  END FtpGetBChkFile;

  --删除FTP文件（如果有的话,没有不出错）
  procedure FtpDelFile(p_bankid in varchar2,
                        p_chddir in varchar2,
                        p_filename in varchar2) is
    l_conn         UTL_TCP.connection;
    p_ftp_ip       varchar2(15);
    p_ftp_port     varchar2(8);
    p_ftp_user     varchar2(100);
    p_ftp_password varchar2(100);
  begin
    SetFtpIp(p_bankid       => p_bankid,
             p_ftp_ip       => p_ftp_ip,
             p_ftp_port     => p_ftp_port,
             p_ftp_user     => p_ftp_user,
             p_ftp_password => p_ftp_password);

    l_conn := login(p_ftp_ip, p_ftp_port, p_ftp_user, p_ftp_password);

    if p_chddir is not null then
      cd(l_conn,p_chddir);
    end if;

    rename(p_conn => l_conn,
               p_from => p_filename,
               p_to   => substrB(p_filename,1,instr(p_filename,'.')-1)||
                         'DeleteAt'||to_char(sysdate,'yyyy-mm-dd-hh24:mi:ss')||'.bak');
    /*ftp.delete(p_conn => l_conn, p_file => p_filename);*/
    logout(l_conn);
    utl_tcp.close_all_connections;
  exception
    when others then
      null;
  end;

function Socket############## return integer is
begin
  return 'Socket通讯客户端类方法';
end;

-- 设置水司交易中间件转发服务IP及超时
  --水司测试中间件  192.168.6.29:17500
  Procedure SetSocIp(p_bankid            in varchar2,
                     p_soc_ip            out varchar2,
                     p_soc_port          out number,
                     p_soc_timeout       out number,
                     p_soc_timeout_value in number) is
  begin
    p_soc_ip := fgetsysmanapara(p_bankid,'000008');
    p_soc_port := to_number(fgetsysmanapara(p_bankid,'000009'));
    p_soc_timeout := p_soc_timeout_value;
  exception
    when others then
      raise;
  END SetSocIp;



  --所有的包均由以下结构组成:
  --包头(30Byte)+数据包长度(4Byte)+数据包
  function BSocket(iv_bankid            in varchar,
                   iv_sendbuf           in varchar,
                   iv_sendtimeout_value in number,
                   ov_recvbuf           out varchar) return integer is
    Result integer;
    /*与服务器通讯
    参数从表读取*/
    iv_sendip      varchar2(15);
    iv_sendport    number;
    iv_sendtimeout number;
    sHead          varchar2(34); --报文头
    SBuf           varchar2(2048); --数据区
    socket         utl_tcp.connection;
    iLength        number(4);
    sqlerr         number(6);
    iCnt           number(2);
    iRecvLen       number(6);
  begin
    ov_recvbuf := '';
    Result     := 1;
    iCnt       := 0;
    SetSocIp(iv_bankid,
             iv_sendip,
             iv_sendport,
             iv_sendtimeout,
             iv_sendtimeout_value);
    /*连接服务器*/
    socket := utl_tcp.open_connection(iv_sendip,
                                      iv_sendport,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      null,
                                      iv_sendtimeout);
    /*发送数据*/
    if utl_tcp.write_text(socket, iv_sendbuf) <> length(iv_sendbuf) then
      return - 1;
    end if;
    utl_tcp.flush(socket);
    /*接收数据*/
    /*<<nextrecv>>
    if iCnt > 3 then
      return - 1;
    end if;*/
    IF (utl_tcp.available(socket, iv_sendtimeout) > 0) THEN
      /*处理报文头,如果不足包头长度继续接收2次*/
      /*if utl_tcp.read_text(socket, sHead, 34) <> 34 then
        iCnt := iCnt + 1;
        goto nextrecv;
      end if;*/
      --iLength := to_number(substrB(sHead, 31, 4));
      --茂名XML格式，无法确认长度，取2000字符
      /*接收报文体*/
      iRecvLen := utl_tcp.read_text(socket, SBuf, 2000);
      /*if lengthb(sBuf) <> iLength then
        return - 1;
      end if;*/
      ov_recvbuf := /*sHead || */SBuf;
    else
      Result := -1;
    end if;
    /*关闭连接*/
    utl_tcp.close_connection(socket);

    /*记录交易日志*/
    return(Result);
  exception
    when others then
      sqlerr := sqlcode;
      utl_tcp.close_connection(socket);
      return - 1;
  end Bsocket;


function Socket2Webservice##### return integer is
begin
  return '转发类方法';
end;

-- 设置水司SMS中间件转发服务IP及超时
  --水司测试中间件  192.168.6.29:17500
  Procedure SetSocIp(p_soc_ip            out varchar2,
                     p_soc_port          out number,
                     p_soc_timeout       out number,
                     p_soc_timeout_value in number) is
  begin
    p_soc_ip := fsyspara('MSIP');
    p_soc_port := to_number(fsyspara('MSPO'));
    p_soc_timeout := p_soc_timeout_value;
  exception
    when others then
      raise;
  END SetSocIp;

  --所有的包均由以下结构组成:
  --包头(255Byte)+超时ms值(5Byte)+数据包长度(4Byte)+数据包
  --包头：WSDL地址
  --数据包：远程调用方法名CHAR(20)||远程调用方法的参数????^?????^?????
  --例包：
  /*
  014-03-08 11:17:39 Thread-16数据接收完成[http://113.106.94.173:20020/axis/services/SMsg?wsdl                                                                                                                                                                                                            90  init                #CHAR#113.106.94.173^#CHAR#mas2^#CHAR#30020^#CHAR#ceshi4^#CHAR#ceshi4^]
  2014-03-08 11:17:39 Thread-16WebService调用成功,返回值[0]
  2014-03-08 11:17:39 Thread-17WebService调用开始执行
  2014-03-08 11:17:39 Thread-17数据接收完成[http://113.106.94.173:20020/axis/services/SMsg?wsdl                                                                                                                                                                                                            196 sendSM              #CHAR#ceshi4^#CHAR#ceshi4^#CHAR#ceshi4^#ARRAY#13006139624,18986036402^#CHAR#尊敬的卢玉琼(182014008),您于2014-03-08缴纳水费0.35元,如有疑问,请咨询顺德供水服务热线:968300^#LONG#0^]
  2014-03-08 11:17:40 Thread-17WebService调用成功,返回值[0]
  返回0即成功,否则所有问题都向外抛出异常中断,接口供应商错误代码见异常处理
  */
  PROCEDURE WSDLSocket(iv_sendbuf           in varchar,
                       iv_sendtimeout_value in number) is
    /*与服务器通讯
    参数从表读取*/
    ov_recvbuf     varchar2(9999);
    iv_sendip      varchar2(15);
    iv_sendport    number;
    iv_sendtimeout number;
    socket         utl_tcp.connection;
    iLength        number;
    iCnt           number:=0;
  begin
    SetSocIp(iv_sendip,
             iv_sendport,
             iv_sendtimeout,
             iv_sendtimeout_value);
    /*连接服务器*/
    begin
      socket := utl_tcp.open_connection(iv_sendip,
                                        iv_sendport,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        null,
                                        iv_sendtimeout);
    exception when others then
      raise_application_error(errcode,
                              'WSDLSocket-> 连接易维转发中间件错误:'||to_char(sqlcode)||sqlerrm);
    end;
    /*发送数据*/
    begin
      if utl_tcp.write_text(socket, iv_sendbuf) <> length(iv_sendbuf) then
        raise_application_error(errcode,
                                'WSDLSocket-> 写Socket错误');
      end if;
    exception when others then
      raise_application_error(errcode,
                              'WSDLSocket-> 写Socket错误:'||to_char(sqlcode)||sqlerrm);
    end;
    /*清空管道*/
    begin
      utl_tcp.flush(socket);
    exception when others then
      raise_application_error(errcode,
                              'WSDLSocket-> 清Socket错误:'||to_char(sqlcode)||sqlerrm);
    end;
    /*接收数据*/
    begin
      <<nextrecv>>
      IF utl_tcp.available(socket, iv_sendtimeout) > 0 THEN
        begin/*处理报文头,如果不足超时继续接收*/
          iCnt := case when iCnt=0 then 1 else iCnt end;
          iLength := utl_tcp.read_text(socket, ov_recvbuf, 9999);
        exception when others then
          raise_application_error(errcode,
                                  'WSDLSocket-> 第'||to_char(iCnt)||'次读Socket错误:'||to_char(sqlcode)||sqlerrm);
        end;
        if iLength = 0 then
          iCnt := iCnt + 1;
          goto nextrecv;
        end if;
      ELSE
        raise_application_error(errcode,
                                'WSDLSocket-> 第'||to_char(iCnt)||'次读Socket管道超时:'||to_char(iv_sendtimeout));
      END IF;
    exception when others then
      raise_application_error(errcode,
                              'WSDLSocket-> 第'||to_char(iCnt)||'次读Socket后判断超时错误:'||to_char(sqlcode)||sqlerrm);
    end;
    if ov_recvbuf!='0' then
      case ov_recvbuf
       when '-1' then
         ov_recvbuf := ov_recvbuf||'(连接数据库出错)';
       when '-2' then
         ov_recvbuf := ov_recvbuf||'(数据库关闭失败)';
       when '-3' then
         ov_recvbuf := ov_recvbuf||'(数据库插入错误)';
       when '-4' then
         ov_recvbuf := ov_recvbuf||'(数据库删除错误)';
       when '-5' then
         ov_recvbuf := ov_recvbuf||'(数据库查询错误)';
       when '-6' then
         ov_recvbuf := ov_recvbuf||'(参数错误)';
       when '-7' then
         ov_recvbuf := ov_recvbuf||'(API编码非法)';
       when '-8' then
         ov_recvbuf := ov_recvbuf||'(参数超长)';
       when '-9' then
         ov_recvbuf := ov_recvbuf||'(没有初始化或初始化失败)';
       when '-10' then
         ov_recvbuf := ov_recvbuf||'(API接口处于暂停（失效）状态)';
       when '-11' then
         ov_recvbuf := ov_recvbuf||'(短信网关未连接)';
       else ov_recvbuf := ov_recvbuf||'(其它问题,测试时如Read timed out返回有可能成功推送)';
      end case;
      raise_application_error(errcode,
                              'WSDLSocket-> 通讯成功,外部错误,响应失败:'||ov_recvbuf);
    end if;
    /*关闭连接*/
    utl_tcp.close_connection(socket);
  exception when others then
    begin
      utl_tcp.close_connection(socket);
    exception when others then
      null;
    end;
    raise_application_error(errcode,sqlerrm);
  end WSDLSocket;

/*
  #CHAR#    String
  #LONG#    Long
  #INTEGER# Integer
  #FLOAT#   Float
  #ARRAY#   Array
*/
  PROCEDURE RemoteCall(p_remote_url in varchar2,
                       p_remote_funcname in varchar2,
                       p_funcpara1 in varchar2 default '',
                       p_funcpara2 in varchar2 default '',
                       p_funcpara3 in varchar2 default '',
                       p_funcpara4 in varchar2 default '',
                       p_funcpara5 in varchar2 default '',
                       p_funcpara6 in varchar2 default '',
                       p_funcpara7 in varchar2 default '',
                       p_funcpara8 in varchar2 default '',
                       p_funcpara9 in varchar2 default '',
                       p_funcpara10 in varchar2 default '',
                       p_timeout in number) is
    pkg      varchar2(10258);
    pkg_head CHAR(260);--255+5
    pkg_url     CHAR(255);
    pkg_timeout CHAR(5);
    pkg_len  CHAR(4);
    pkg_body VARCHAR2(9999);
    vfuncname CHAR(20);
    splitchar CHAR(1):='^';
  begin
    pkg_url     := p_remote_url;
    pkg_timeout := p_timeout;
    pkg_head := pkg_url||pkg_timeout;
    vfuncname := p_remote_funcname;
    pkg_body := vfuncname||
                p_funcpara1||case when p_funcpara1 is null then null else splitchar end||
                p_funcpara2||case when p_funcpara2 is null then null else splitchar end||
                p_funcpara3||case when p_funcpara3 is null then null else splitchar end||
                p_funcpara4||case when p_funcpara4 is null then null else splitchar end||
                p_funcpara5||case when p_funcpara5 is null then null else splitchar end||
                p_funcpara6||case when p_funcpara6 is null then null else splitchar end||
                p_funcpara7||case when p_funcpara7 is null then null else splitchar end||
                p_funcpara8||case when p_funcpara8 is null then null else splitchar end||
                p_funcpara9||case when p_funcpara9 is null then null else splitchar end||
                p_funcpara10;
    pkg_len := lengthB(pkg_body);
    pkg     := pkg_head||pkg_len||pkg_body;
    begin
      WSDLSocket(pkg,p_timeout);
    exception when others then
      raise_application_error(errcode, 'RemoteCall ->'||sqlerrm);
    end;
  exception when others then
    raise;
  end RemoteCall;

  --异步进程执行推送,避免因推送超时阻塞业务进程、或导致业务进程缓慢
  procedure RunSmsPush(p_jobno in number) is
    ret varchar2(10258);
    初始化超时 integer := 10000;--秒,
    推送超时   integer := 10000;--秒,假设6秒执行完成一个短信推送,10万条需要整整一周且日夜不停
    --vsl smslog%rowtype;
    vtimestamp timestamp;
    注册状态 varchar2(100):='0';
    执行过注册 boolean := false;
    首次注册成功 boolean;
    推送成功 boolean;
  begin
    if 注册状态='0' then
      begin
        执行过注册 := true;
        /*113.106.94.173*/
        RemoteCall(p_remote_url => 'http://0.0.0.0:20020/axis/services/SMsg?wsdl  ',
                   p_remote_funcname => 'init',
                   p_funcpara1 => '#CHAR#'||'0.0.0.0',
                   p_funcpara2 => '#CHAR#'||'mas2',
                   p_funcpara3 => '#CHAR#'||'30020',
                   p_funcpara4 => '#CHAR#'||'ceshi4',
                   p_funcpara5 => '#CHAR#'||'ceshi4',
                   p_timeout   => 初始化超时);
        首次注册成功 := true;
      exception when others then
        首次注册成功 := false;
        ret := sqlerrm;
      end;
    end if;
    /*for i in (select * from smslog_cache where sljobno=p_jobno order by slid) loop
      vsl.slpushlog0    := case when vsl.slid is null
                                then (case when not 执行过注册 then null
                                           when 执行过注册 and 首次注册成功 then '首次注册成功'
                                           when 执行过注册 and not 首次注册成功 then '首次注册失败'||ret
                                           else null end)
                                else null end;--借首行记录init的返回
      vsl.slid          := i.slid;
      vsl.slcid         := i.slcid;
      vsl.slmid         := i.slmid;
      vsl.slphonecode   := i.slphonecode;
      vsl.slcontent     := i.slcontent;
      vsl.slcachedate   := i.sldate;
      vsl.slpushtimeout := 推送超时;
      vsl.sljobno       := i.sljobno;
      select systimestamp into vsl.sldate from dual;
      vsl.slpushlog1    := null;
      begin
        RemoteCall(p_remote_url => 'http://0.0.0.0:20020/axis/services/SMsg?wsdl',
                   p_remote_funcname => 'sendSM',
                   p_funcpara1 => '#CHAR#'||'ceshi4',
                   p_funcpara2 => '#CHAR#'||'ceshi4',
                   p_funcpara3 => '#CHAR#'||'ceshi4',
                   p_funcpara4 => '#ARRAY#'||vsl.slphonecode,
                   p_funcpara5 => '#CHAR#'||vsl.slcontent,
                   p_funcpara6 => '#LONG#'||substr(to_char(i.slid),-2),
                   p_timeout   => vsl.slpushtimeout);
        推送成功 := true;
      exception when others then
        推送成功 := false;
        vsl.slpushlog1 := sqlerrm;
      end;
      select systimestamp into vtimestamp from dual;
      select (to_date(substr(to_char(vtimestamp, 'yyyy-mm-dd hh24:mi:ss.ff'), 1, 19),'yyyy-mm-dd hh24:mi:ss') -
              to_date(substr(to_char(vsl.sldate, 'yyyy-mm-dd hh24:mi:ss.ff'), 1, 19),'yyyy-mm-dd hh24:mi:ss')) * 24 * 3600 * 1000
              + to_number(substr(to_char(vtimestamp, 'yyyy-mm-dd hh24:mi:ss.ff'), 21, 3))
              - to_number(substr(to_char(vsl.sldate, 'yyyy-mm-dd hh24:mi:ss.ff'), 21, 3))
      into vsl.slpushtimelong
      from dual;
      --接口协议'0'推送成功
      if 推送成功 then
        insert into smslog values vsl;
      else--否则让job执行结束,转缓存失败记录,待人工干预
        i.slerr := to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||'( '||nvl(to_char(vsl.slpushtimelong),'null')||'ms'||
                   ' ) =>RunSmsPush ->'||nvl(vsl.slpushlog1,'null');
        insert into smslog_cachebak values i;
      end if;
      delete smslog_cache where slid=i.slid;
      commit;
    end loop;*/
    if 首次注册成功 then--init成功才执行
      begin
        RemoteCall(p_remote_url => 'http://0.0.0.0:20020/axis/services/SMsg?wsdl',
                   p_remote_funcname => 'release',
                   p_timeout   => 初始化超时);
      exception when others then
        null;
      end;
    end if;
    commit;
  exception when others then
    rollback;
    --ErrLog(dbms_utility.format_call_stack(),'RunSmsPush,p_jobno:'||to_char(p_jobno));
  end RunSmsPush;

  /*通知服务之 - 短信封装
  根据传入的用户编号、水表编号查找合法手机号,和已组织好的内容参数（本过程避免组织内容而造成的二次查询）,组织统一接口环境参数,调用接口方法（本过程针对短信）
  支持批量、单一模式
  输入参数：p_sltab table(smslog)之下列列值
  slcid  varchar2(20)  y    ：用户编号,slphonecode为空时,根据此参数查找用户合法短信号码
  slmid  varchar2(20)  y    水表编号,slphonecode为空时,根据此参数查找用户合法短信号码
  slphonecode ：直接指定号码发送,为空时,根据slcid、slmid参数查找用户合法短信号码
  slcontent  varchar2(1000)      内容
  输出参数：无（记录错误日志）
  */
  /*procedure SmsPush(p_sltab in sl_table) is PRAGMA AUTONOMOUS_TRANSACTION;
    最大任务数 integer := 10;
    vslcache sl_type;
    vslcacheTab sl_table;
    vjobs number;
  begin
    if p_sltab is not null then
      --批次记录,给job查询,共用seq_smslog不重复就行
      select seq_smslog.nextval into vslcache.sljobno from dual;
      for i in p_sltab.first()..p_sltab.last() loop
        select seq_smslog.nextval into vslcache.slid from dual;
        vslcache.slcid       := p_sltab(i).slcid;
        vslcache.slmid       := p_sltab(i).slmid;
        vslcache.slphonecode := p_sltab(i).slphonecode;
        vslcache.slcontent   := p_sltab(i).slcontent;
        select systimestamp into vslcache.sldate from dual;
        if vslcache.slphonecode is null then
          null;
          vslcache.slphonecode     := '13006139624';
          \*此处写根据cid和mid检索用户有效短信号码
          vslcache.clcid
          vslcache.clmid*\
        end if;
        if vslcacheTab is null then
          vslcacheTab := sl_table(vslcache);
        else
          vslcacheTab.extend;
          vslcacheTab(vslcacheTab.last) := vslcache;
        end if;
      end loop;


      --开job进程处理,要避免进程阻塞造成的job进程数超警戒
      select count(*) into vjobs
        from user_jobs a, dba_jobs_running b
       where a.job=b.job and instr(Lower(a.what), 'pg_ewide_interface.runsmspush')>0;
      if vjobs<最大任务数 then
        --记录缓存队列；一秒后开始执行,且执行一次
        for k in vslcacheTab.first..vslcacheTab.last loop
          insert into smslog_cache values vslcacheTab(k);
        end loop;
        commit;
        job_submit('pg_ewide_interface.runsmspush('||vslcache.sljobno||');',
                   to_char(sysdate+1/86400, 'yyyymmdd hh24:mi:ss'),
                   null);
      else
        --若超过job进程数警戒线,直接记录失败缓存队列,人工干预
        vslcache.slerr := to_char(sysdate,'yyyy-mm-dd hh24:mi:ss')||
                          '(当前runing job数'||vjobs||',超过限制'||最大任务数||')';
        insert into smslog_cachebak values vslcache;
      end if;
    end if;
    commit;
  exception when others then
    rollback;
    ErrLog(dbms_utility.format_call_stack(),'SmsPush,p_cid,p_mid:'||vslcache.slcid||','||vslcache.slmid);
  end SmsPush;
*/
  --单条多号发送简易调用模式
  /*procedure SmsPush(p_phonecode in varchar2 ,p_smscontent in varchar2) is
    vsms sl_type;
  begin
    vsms.slphonecode := p_phonecode;
    vsms.slcontent := '***来自测试系统***'||p_smscontent;
    SmsPush(sl_table(vsms));
  end SmsPush;*/

  function ErrorLog############# return integer is
  begin
    return '日志类方法';
  end;

  --异常日志(如何获取当前过程名：dbms_utility.format_call_stack();)
 /* procedure ErrLog(p_func in varchar2,
                   p_others in varchar2) IS PRAGMA AUTONOMOUS_TRANSACTION;
    v_what varchar2(1000);
  begin
    \*v_what := '['||sqlcode||']'||sqlerrm;
    insert into oracleerror
      (oedatetime, oefunc, oewhat, oeothers)
    values
      (sysdate, p_func, v_what, p_others);*\
    --commit;
    NULL;
  exception when others then
    null;
  end;*/

END PG_EWIDE_INTERFACE;
/

