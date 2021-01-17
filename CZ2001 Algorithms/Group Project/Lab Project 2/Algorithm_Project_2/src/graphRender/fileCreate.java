package graphRender;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.*;
import org.graphstream.graph.*;

public class fileCreate {
	public static void createFile() {
		try {
			File hospitalNodes = new File("OregonHospitalList4.txt");
			if (hospitalNodes.createNewFile()) {
				System.out.println("File created: " + hospitalNodes.getName());
			} else {
				System.out.println("File already created!");
			}
		} catch (Exception e) {
			System.out.println("An error had occured!");
			e.printStackTrace();
		}
	}
	
	public static void writePathToFile(ArrayList<List<Node>> path) throws IOException {
		FileWriter writePath = new FileWriter("PathToNearestHospital.txt");
		writePath.write("### Paths to the nearest hospitals\n");
		for (List<Node> curr: path) {
			writePath.write("Start node: " + curr.get(0).getId() + "\n");
			writePath.write("First nearest Hospital node: " + curr.get(curr.size()-1).getId() + "\n");
			writePath.write("Path: " + curr.toString() + "\n");
			writePath.write("\n");
		}
		writePath.close();
	}
	
	public static void writePathsToFile(HashMap<Node, ArrayList<List<Node>>> path, int numberOfHospitals) throws IOException {
		FileWriter writePath = new FileWriter("PathToNearestKHospital.txt");
		writePath.write("### Paths to " + Integer.toString(numberOfHospitals) + " nearest hospitals\n");
		writePath.write("\n");
		Iterator it = path.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry pair = (Map.Entry) it.next();
			writePath.write("Start node: " + pair.getKey() + "\n");
			int index = 1;
			for (List<Node> temp: path.get(pair.getKey())) {
				writePath.write("Nearest Hospital number " + Integer.toString(index) + ": " + temp.get(temp.size()-1).getId() + "\n");
				writePath.write("Path " + Integer.toString(index) + ": " + temp.toString() + "\n");
				index++;
				writePath.write("\n");
			}
		}
		writePath.close();
	}
	
	public static void writeToFile(ArrayList<String> hos) throws IOException {
		FileWriter writeNode = new FileWriter("OregonHospitalList4.txt");
		writeNode.write("#" + hos.size() + "\n");
		for (String curr: hos) {
			writeNode.write(curr + "\n");
		}
		writeNode.close();
	}
	
	public static void writeToFile(ArrayList<Node> nodeIDList, HashMap<Node, ArrayList<Node>> edgeIDList) throws IOException {
		FileWriter writeGraph = new FileWriter("CustomGraphNetwork.txt");
		writeGraph.write("#" + nodeIDList.size() + " #" + edgeIDList.size() + "\n");
		for (Node curr: nodeIDList) {
			if (!edgeIDList.containsKey(curr)) {
				continue;
			} else {
				ArrayList<Node> temp = edgeIDList.get(curr);
				for (Node curr2: temp) {
					writeGraph.write(curr.getId() + "   " + curr2.getId() + "\n");
					writeGraph.write(curr2.getId() + "   " + curr.getId() + "\n");
				}
			}
		}
		writeGraph.close();
	}
}
