create or replace and compile java source named HRBZLS.httppost as
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.List;
import java.util.Map;
import oracle.sql.CLOB;
import java.io.File;
import java.io.FileOutputStream;
import java.io.*;

public class HttpPost {
  /*   *
     * ??? URL ??POST?????
     *
     * @param url
     *            ????? URL
     * @param param
     *            ???????????? name1=value1&name2=value2 ????
     * @return ????????????*/

    public static String sendPost(String url, CLOB  param ) {
        PrintWriter out = null;
        BufferedReader in = null;
        String result = "";
        String PostParam = "";
        String Errmsg = "";

        try {
            URL realUrl = new URL(url);
            URLConnection conn = realUrl.openConnection();
            conn.setRequestProperty("accept", "*/*");
            conn.setRequestProperty("connection", "Keep-Alive");
            conn.setRequestProperty("user-agent",
                    "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1;SV1)");
            //conn.setRequestProperty("Content-Type", "text/html");
            conn.setRequestProperty("Content-Type", "text/plain");
            conn.setConnectTimeout(30000);
/*
   keytool -import -trustcacerts -file C:\fapiao2017.cer  -keystore E:\app\Administrator\product\11.2.0\dbhome_1\javavm\lib\security\cacerts -storepass "changeit";
   keytool -import -keystore "E:\app\Administrator\product\11.2.0\dbhome_1\javavm\lib\security\cacerts"  -storepass changeit  -keypass changeit -alias emailcert -file C:\fapiao2017.cer
*/
            conn.setDoOutput(true);
            conn.setDoInput(true);

            out = new PrintWriter(conn.getOutputStream() );


            PostParam =  param.getSubString(1, (int) param.length());
            //PostParam  = new String(PostParam.toString().getBytes("UTF-8"));
            PostParam  = new String(PostParam.toString().getBytes("GBK"));


            out.print(PostParam);
            out.flush();

            in = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(),"GBK"));
                    //new InputStreamReader(conn.getInputStream(),"UTF-8"));
            String line;
            while ((line = in.readLine()) != null) {
                result += line;
            }
        } catch (Exception e) {
                result =   "EW_ERR??? POST ???????"+e.getMessage();
        } finally{

            try{
                if(out!=null){
                    out.close();
                }
                if(in!=null){
                    in.close();
                }
            }
            catch(IOException ex){
                ex.printStackTrace();
            }


        }

        return  result ;
    }
}
/

