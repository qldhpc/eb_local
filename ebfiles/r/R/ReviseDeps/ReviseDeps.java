import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Arrays;
public class ReviseDeps {
    static String EXTS_START = "exts_list = [\n";
    static String EXTS_END = "\n]\n";
    public static void main(String[] args ) {
        try {
            if ( args.length==1 ) {
                File input = new File(args[0]);
                if ( input.exists() ) {
                    byte[] data = new byte[(int)input.length()];
                    FileInputStream fis = new FileInputStream(input);
                    fis.read(data);
                    String content = new String(data);
                    int start = content.indexOf("exts_list = [\n");
                    if ( start != -1 ) {
                        int end = content.indexOf(EXTS_END,start);
                        if ( end != -1 ) {
                            String extList = content.substring(start+EXTS_START.length(),end);
                            String[] lines = extList.split("\n");
                            ArrayList<Package> list = new ArrayList<Package>();
                            for ( int i=0;i<lines.length;i++ ) {
                                String trimmed = lines[i].trim();
                                if ( !(trimmed.startsWith("#")) ) {
                                    Package p = new Package(trimmed);
                                    p.getDeps();
                                    list.add(p);
                                }
                            }
                            Package[] packages = new Package[list.size()];
                            list.toArray(packages);
                            Arrays.sort(packages,new PackageComparator());
                            for ( int i=0;i<packages.length;i++ )
                                System.out.println(packages[i]);
                        }
                        else
                            System.out.println("Couldn't find \""+EXTS_END+"\"");
                    }
                    else
                        System.out.println("Couldn't find \""+EXTS_START+"\"");
                }
                else
                    System.out.println("File "+args[0]+" not found");
            }
            else
                System.out.println("Usage: java ReviseDeps <easyconfig>");
        }
        catch ( Exception e ) {
            e.printStackTrace(System.out);
        }
    }
}
