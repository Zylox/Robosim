
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;

public class ScriptReader {

	BufferedReader reader;
	
	public ScriptReader(String filePath) throws FileNotFoundException{
		reader = new BufferedReader(new FileReader(filePath));		
	}
	
	public String readScriptLine() throws IOException {
		String line = null;
		line = reader.readLine();
		return line;
	}
}
