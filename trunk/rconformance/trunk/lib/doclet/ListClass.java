import com.sun.javadoc.*;

public class ListClass {
	private static final String DELIMITER = "---IRDelimiter---";

    public static boolean start(RootDoc root) {
		System.out.println(DELIMITER);

        ClassDoc[] classes = root.classes();
        for (int i = 0; i < classes.length; ++i) {
			ClassDoc c = classes[i];

			System.out.println(c.qualifiedName());
			System.out.println(c.commentText());
			System.out.println(DELIMITER);
        }
        return true;
    }
}

