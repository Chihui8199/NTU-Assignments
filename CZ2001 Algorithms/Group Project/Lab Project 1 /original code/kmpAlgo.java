package lab;

import java.util.*;
import java.io.*;

public class kmpAlgo {
	// Methods to implement KMP algorithm
		public static void KMP(String X, String Y)
		{
			// Base Case 1: Y is null or empty
			if (Y == null || Y.length() == 0)
			{
				System.out.println("Pattern occurs at index 0");
				return;
			}

			// Base Case 2: X is null or X's length is less than that of Y's
			if (X == null || Y.length() > X.length())
			{
				System.out.println("Pattern not found");
				return;
			}

			char[] chars = Y.toCharArray();

			// next[i] stores the index of next best partial match //computing prefix
			int[] next = new int[Y.length() + 1];
			for (int i = 1; i < Y.length(); i++)
			{
				int j = next[i + 1];

				while (j > 0 && chars[j] != chars[i])
					j = next[j];

				if (j > 0 || chars[j] == chars[i])
					next[i + 1] = j + 1;
			}

			for (int i = 0, j = 0; i < X.length(); i++)
			{
				if (j < Y.length() && X.charAt(i) == Y.charAt(j))
				{
					if (++j == Y.length())
					{
						System.out.println("Pattern occurs at index " +
										(i - j + 1));
					}
				}
				else if (j > 0)
				{
					j = next[j];
					i--;	// since i will be incremented in next iteration
				}
			}
		}
		

		public static void main(String[] args) throws Exception
		{
			//Create a new file object and read in the file.
			File VIRUS = new File("/Users/russellleung/Desktop/virus.fna");
			BufferedReader fileReadIn = new BufferedReader(new FileReader(VIRUS));
			
			String text;
			String full ="";
			String pattern = "ATG";
			
			//Concatenate each row of the file DNA sequence into a single string.
			while((text = fileReadIn.readLine()) != null)
			{
				full += text;
			}

			//Close the file stream.
			fileReadIn.close();
			
			long startTime = System.nanoTime();

			KMP(full, pattern);
			
			long endTime   = System.nanoTime();
			long totalTime = endTime - startTime;
			System.out.println(totalTime);
		}
		
}
