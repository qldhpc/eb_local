import java.util.Comparator;
public class PackageComparator implements Comparator<Package>{
    public int compare( Package p1, Package p2 ) {
        if ( p1.numDeps() < p2.numDeps() )
            return -1;
        else if ( p1.numDeps() > p2.numDeps() )
            return 1;
        else 
            return p1.name.compareTo(p2.name);
    }
    public boolean equals(PackageComparator pc ) {
        return this.equals(pc);
    }
}
