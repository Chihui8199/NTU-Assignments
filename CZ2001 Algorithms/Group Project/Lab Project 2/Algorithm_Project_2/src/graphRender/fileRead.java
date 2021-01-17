package graphRender;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;
import java.util.stream.Stream;

import org.graphstream.graph.*;
import org.graphstream.graph.implementations.*;

public class fileRead {
	private static Graph graph = new SingleGraph("Custom Graph");
	private static int numNodes = 0;
	private static ArrayList<String> nodeIDList = new ArrayList<>();
	private static HashMap<Node, ArrayList<Node>> adjList = new HashMap<>();
	private static ArrayList<String> hospitalNodes = new ArrayList<>();
	
	public static Graph getGraph() { return graph; }
	public static ArrayList<String> getNodeList() { return nodeIDList; }
	public static HashMap<Node, ArrayList<Node>> getAdjList() { return adjList; }
	public static int getNvalue() { return numNodes; }
	public static ArrayList<String> getHospitals() { return hospitalNodes; }
	
	public static void createGraphFromFile() throws IOException {
		ArrayList<String> allEdges = new ArrayList<>();					// store strings so that you can handle the strings after you read in
		System.setProperty("org.graphstream.ui", "swing");
		try {			// bufferedreader -> faster method of reading in large files
			BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream("CustomGraphNetwork.txt"), StandardCharsets.UTF_8));
			String line;
			while ((line = reader.readLine())!=null) {
				if (line.contains("#")) {
					continue;
				} else {
					allEdges.add(line);				// adds to the storage variable, but no handling
				}
			}
		} catch (FileNotFoundException e) {
			System.out.println("An error had occurred.");
			e.printStackTrace();
		}
		
		for (int i = 0; i < allEdges.size(); i++) {				// handling of string inputs read from files
			String[] temp = allEdges.get(i).split("   ");
			createGraph(temp[0], temp[1]);						// calls method to create the graph
		}
		
		try {
			FileReader hospitalList = new FileReader("CustomHospitalList.txt");			// reads in the hospital nodes from hospital files
			BufferedReader Hreader = new BufferedReader(hospitalList);
			String line;
			while ((line = Hreader.readLine())!=null) {
				if (line.contains("#")) {
					continue;
				} else {
					hospitalNodes.add(line);
				}
			}
			Hreader.close();
		} catch (FileNotFoundException e) {
			System.out.println("An error had occurred.");
			e.printStackTrace();
		}
	}
	
	/*
	 * Given string 		"123 				901"
	 * means that node 123 is connected to 901
	 * if 123 not in nodelist then add to the nodelist and add to graph
	 * 
	 * After creating the node, get the edge between the 2 nodes
	 * if edge present, pass, else add a link
	 * 
	 * add to adjlist for both nodes
	 * 
	 * "123": ["901"....]
	 * "901": ["123"....]
	 */
	
	public static void createGraph(String nodeId1, String nodeId2) {			// creates the graph
		if (!nodeIDList.contains(nodeId1)) {
			numNodes++;
			graph.addNode(nodeId1);
			nodeIDList.add(nodeId1);
		}
		if (!nodeIDList.contains(nodeId2)) {
			numNodes++;
			graph.addNode(nodeId2);
			nodeIDList.add(nodeId2);
		}
		
		Node node1 = graph.getNode(nodeId1);
		Node node2 = graph.getNode(nodeId2);
		if (!node1.hasEdgeToward(node2)) {
			graph.addEdge(node1.getId() + node2.getId(), node1, node2);
		}
		
		if (!adjList.containsKey(node1)) {
			adjList.put(node1, new ArrayList<Node>());
		}
		adjList.get(node1).add(node2);
		
		if (!adjList.containsKey(node2)) {
			adjList.put(node2,  new ArrayList<Node>());
		}
		adjList.get(node2).add(node2);
	}
}
