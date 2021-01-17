package lab;

//Java program for Naive Pattern Searching 
import java.io.BufferedReader;
import java.io.*;
import java.io.File;
import java.io.FileReader;
import java.util.*;
import java.util.regex.Pattern;

public class bruteForce {

	public static void search(String sequence, String query) 
	{
		int sequence_length = sequence.length();
		int query_length = query.length();
		
		int i = 0;
		
		for (i=0; i <= sequence_length - query_length; i++)
		//i is the index we are currently testing for this loop
		{
			int j;
			
			for (j=0; j < query_length; j++)
			//j is the index of query we are testing
			//if char no longer matches, for loop for j breaks
			{
				if (sequence.charAt(i + j) != query.charAt(j))
					break;
			}
					
			if (j == query_length) //only if all char in query is match then we will print
				System.out.println("Occurence at index " + i); 
		}
	}
	
	public static void main(String[] args) throws Exception
	//allow user to enter sequence and query before running search function
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
		
		search(full, pattern);
		
		long endTime   = System.nanoTime();
		long totalTime = endTime - startTime;
		System.out.println(totalTime);
	}
}
