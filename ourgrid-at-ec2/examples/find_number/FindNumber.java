import java.io.FileOutputStream;
import java.io.IOException;

/**
 * Simple CPU-bound bag-of-tasks application.
 */
public class FindNumber {
	// 242720316 per second (on amd64)
	// max long = 9223372036854775807;

	public static void main(String[] args) throws IOException {
		long min = Long.parseLong(args[0]);
		long max = Long.parseLong(args[1]);
		long secret = Long.parseLong(args[2]);
		String filename = args[3];
        
		FileOutputStream fos = new FileOutputStream(filename, true);
		for ( ; min <= max; min++) {
			if (min == secret) {
				fos.write(("" + min).getBytes());
				break;
			}
		}
		fos.close();
	}

}
