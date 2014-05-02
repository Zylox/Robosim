import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;

import javax.imageio.ImageIO;



public class PictureVConverter {

	public static final int miniMapBlockSize = 50;
	
	public static void main(String[] args){
		execute(args);
	}
	
	public static void execute(String[] args){
		BufferedImage img = null;
		String bitmapName = args[1];
		String description = bitmapName;
		
		File imgFile = new File("res/" + bitmapName);
		System.out.println(bitmapName);
		
		try {
		   img = ImageIO.read(imgFile);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		int w = img.getWidth()+0;
		int h = img.getHeight()+0;
		int[][] pixels = new int[w][h];
		System.out.println(w + " " + h);
		

		
		PrintWriter writer = null;
		
		//String fileDir = imgFile.getParent(); 
		//String fileDir = "C:\\CygwinScripts";
		String fileName = bitmapName + ".m";
		File f = new File (System.getProperty("user.dir") + "/res",fileName);

		try {
			writer = new PrintWriter (f);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
		

	
		
		writer.println(bitmapName + ".name = \"" +bitmapName + "\";\n");

		
		//insert minimap here
		writer.print(bitmapName + ".blockSize = " + miniMapBlockSize + ";\n\n");
		writer.print(bitmapName + ".miniMap = [");
		
		int blocksWidth = w/miniMapBlockSize;
		int blocksHeight = h/miniMapBlockSize;
		
		int m = 0;
		int n = 0;
		boolean indicator = false;
		for(m = 0; m < blocksHeight+1; m++){
			if(m != 0){
				writer.println();
			}
			for(n = 0; n < blocksWidth+1; n++){
				indicator = false;
				for(int k = 0; k<miniMapBlockSize; k++){
					//if(m == 0 || n == 0 || m == blocksHeight || n == blocksWidth){
						//indicator = true;
					//}
					if(m*miniMapBlockSize + k >= h-2){
						break;
					}
					for(int l = 0; l<miniMapBlockSize ; l++){
						
						if(n*miniMapBlockSize + l >= w-2){
							break;
						}
						
						if(img.getRGB(n*miniMapBlockSize + l, m*miniMapBlockSize + k) != -1){
							indicator = true;
						}
					}
				}
				if(indicator){
					writer.print(" 1");
				}else{
					writer.print(" 0");
				}
			}
		}
		
		writer.print("];\n\n");
		
		writer.print(bitmapName + ".map = [");
		for( int i = 0; i < w-0; i++ ){
			if(i != 0){
				writer.println();
			}
		    for( int j = 0; j < h-0; j++ ){
		        
		        //if(i == 0 || j == 0 || i == w-1 || j == h - 1){
		        	//writer.print(" 1");
		        //}else{
		        	//pixels[i][j] = img.getRGB( i-1, j-1);
		    	//System.out.println(i + " "  + j);
		        	if(img.getRGB(i, j) != -1){
		        		writer.print(" 1");
		        	}else{
		        		writer.print(" 0");
		        	}
		       // }
			}
		}

		writer.print("];");
		writer.close();
		System.out.println("done");
	}
}
