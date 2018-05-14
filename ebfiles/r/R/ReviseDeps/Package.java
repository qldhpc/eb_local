import java.net.*;
import javax.net.ssl.*;
import java.io.*;
import java.util.ArrayList;
public class Package {
    String body;
    String name;
    String version;
    String tail;
    String html;
    ArrayList<String> deps;
    public void getDeps() {
        try
        {
            if ( version != null ) {
                URL cran = new URL("https://cran-r.project.org/web/packages/"+name+"/index.html");
                URLConnection yc = cran.openConnection();
                BufferedReader in = new BufferedReader(new InputStreamReader(
                                     yc.getInputStream()));
                String inputLine;
                StringBuilder sb = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    sb.append(inputLine);
                    sb.append("\n");
                }
                html = sb.toString();
                in.close();
            }
        }
        catch ( Exception e )
        {
            System.out.println("failed to get "+name+" package because "+e.getMessage());
        }
    }
    private String strip( String str, String token ) {
        if ( str.startsWith(token) )
            str = str.substring(token.length());
        if ( str.endsWith(token) )
            str = str.substring(0,str.lastIndexOf(token));
        return str;
    }
    public int numDeps() {
        return deps.size();
    }
    public Package(String line ) throws Exception {
        tail = "";
        deps = new ArrayList<String>();
        if ( line.contains("(")&&line.contains("),") ) {
            body = line.substring(line.indexOf("(")+1,line.lastIndexOf("),"));
        }
        else if ( line.startsWith("'") && line.endsWith("',") ) {
            body = line.substring(0,line.lastIndexOf(","));
        }
        else
            throw new Exception("Invalid package line:"+line);        
        String[] parts = body.split(",");
        if ( parts.length > 0 )
            this.name = strip(parts[0].trim(),"'");
        if ( parts.length > 1 )
            this.version = strip(parts[1].trim(),"'");
        for ( int i=2;i<parts.length;i++ ) {
            if ( tail.length() > 0 )
                tail += ",";
            this.tail += parts[i];
        }
    }
    public String toString() {
        StringBuilder sb = new StringBuilder();
        if ( name != null ){
            sb.append("name: ");
            sb.append(name);
            sb.append(" ");
        }
        if ( version != null ) {
            sb.append("version: ");
            sb.append(version);
            sb.append(" ");
        }
        if ( tail != null && tail.length()>0 ) {
            sb.append("tail: ");
            sb.append(tail);
        }
        return sb.toString();
    }
}
