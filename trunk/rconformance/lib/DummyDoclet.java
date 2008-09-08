import com.sun.javadoc.*;

public class DummyDoclet {
	public static RootDoc rootDoc;

    public static boolean start(RootDoc root) {
		rootDoc = root;
        return true;
    }
}

