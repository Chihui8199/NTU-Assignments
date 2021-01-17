package graphRender;

import org.graphstream.algorithm.generator.Generator;
import org.graphstream.algorithm.generator.RandomGenerator;
import org.graphstream.graph.*;
import org.graphstream.graph.implementations.*;

import java.util.*;
import org.graphstream.graph.*;
import org.graphstream.graph.implementations.*;

public class GraphRender {
	
	public static void main(String args[]) {
		System.setProperty("org.graphstream.ui", "swing");
		
		Graph graph = new SingleGraph("Random");
	    Generator gen = new RandomGenerator(2);
	    gen.addSink(graph);
	    gen.begin();
	    for(int i=0; i<100; i++)
	        gen.nextEvents();
	    gen.end();
	    graph.display();
	}
	
	private Graph graph;
	private final int N = 100;
	private ArrayList<String> nodeIDList;
	private ArrayList<String> edgeList;
	private HashMap<Node, ArrayList<Node>> adjList;
	
	public GraphRender() {
		System.setProperty("org.graphstream.ui", "swing");
		
		graph = new SingleGraph("Random");
		nodeIDList = new ArrayList<>();
		edgeList = new ArrayList<>();
		adjList = new HashMap<>();
		
		String NodeID = null;
		String EdgeID = null;
		
		// create a total of N nodes;
		for (int i = 0; i < N; i++) {
			NodeID = Integer.toString(i); // "1", "2" ... "99"
			nodeIDList.add(NodeID);	// add to list
			graph.addNode(NodeID); 	// plot onto display
		}
		
		Random indexGenerator = new Random();
				
		int index1 = 0;
		int index2 = 0;
		
		for(int i = 0; i < N + N/2; i++) {
			do {
				index1 = indexGenerator.nextInt(N);
				index2 = indexGenerator.nextInt(N);
				String node1 = nodeIDList.get(index1);
				String node2 = nodeIDList.get(index2);
				String EdgeID1 = node1 + node2;			// 1 -> 2 "12"
				String EdgeID2 = node2 + node1;			// 2 -> 1 "21"
				if (edgeList.contains(EdgeID1) || edgeList.contains(EdgeID2) || (EdgeID1.equals(EdgeID2)))
					continue;
				else {
					EdgeID = EdgeID1;
					Node Node1 = graph.getNode(node1);
					Node Node2 = graph.getNode(node2);
					
					// {"23": ["21", "46", "56"]} -> dictionary/HashMap
					
					if (!adjList.containsKey(Node1)) {
						adjList.put(Node1, new ArrayList<>());
					}
					adjList.get(Node1).add(Node2);
					
					if (!adjList.containsKey(Node2)) {
						adjList.put(Node2, new ArrayList<>());
					}
					adjList.get(Node2).add(Node1);
					edgeList.add(EdgeID);
					break;
				}
			} while (true);
			graph.addEdge(EdgeID, nodeIDList.get(index1), nodeIDList.get(index2));		// adding of edge to display
		}
	}
	
	public int getNvalue() { return N; }
	
	public ArrayList<String> getNodeList() { return nodeIDList; }
	
	public List<String> getEdgeLength() { return edgeList; }
	
	public Graph getGraph() { return graph; }
	
	public HashMap<Node, ArrayList<Node>> getAdjList() { return adjList; }
		
	// public static void main(String[] args) {
		//new GraphRender();
	}
	
	/*
	public static void main(String args[]) {
		System.setProperty("org.graphstream.ui", "swing");
		
		Graph graph = new SingleGraph("Random");
	    Generator gen = new RandomGenerator(2);
	    gen.addSink(graph);
	    gen.begin();
	    for(int i=0; i<100; i++)
	        gen.nextEvents();
	    gen.end();
	    graph.display();
	}
 -------
	private Graph graph;
	private final int N = 100;
	private ArrayList<String> nodeIDList;
	private ArrayList<String> edgeList;
	private HashMap<Node, ArrayList<Node>> adjList;
	
	public GraphRender() {
		System.setProperty("org.graphstream.ui", "swing");
		
		graph = new SingleGraph("Random");
		nodeIDList = new ArrayList<>();
		edgeList = new ArrayList<>();
		adjList = new HashMap<>();
		
		String NodeID = null;
		String EdgeID = null;
		
		// create a total of N nodes;
		for (int i = 0; i < N; i++) {
			NodeID = Integer.toString(i); // "1", "2" ... "99"
			nodeIDList.add(NodeID);	// add to list
			graph.addNode(NodeID); 	// plot onto display
		}
		
		Random indexGenerator = new Random();
				
		int index1 = 0;
		int index2 = 0;
		
		for(int i = 0; i < N + N/2; i++) {
			do {
				index1 = indexGenerator.nextInt(N);
				index2 = indexGenerator.nextInt(N);
				String node1 = nodeIDList.get(index1);
				String node2 = nodeIDList.get(index2);
				String EdgeID1 = node1 + node2;			// 1 -> 2 "12"
				String EdgeID2 = node2 + node1;			// 2 -> 1 "21"
				if (edgeList.contains(EdgeID1) || edgeList.contains(EdgeID2) || (EdgeID1.equals(EdgeID2)))
					continue;
				else {
					EdgeID = EdgeID1;
					Node Node1 = graph.getNode(node1);
					Node Node2 = graph.getNode(node2);
					
					// {"23": ["21", "46", "56"]} -> dictionary/HashMap
					
					if (!adjList.containsKey(Node1)) {
						adjList.put(Node1, new ArrayList<>());
					}
					adjList.get(Node1).add(Node2);
					
					if (!adjList.containsKey(Node2)) {
						adjList.put(Node2, new ArrayList<>());
					}
					adjList.get(Node2).add(Node1);
					edgeList.add(EdgeID);
					break;
				}
			} while (true);
			graph.addEdge(EdgeID, nodeIDList.get(index1), nodeIDList.get(index2));		// adding of edge to display
		}
	}
	
	public int getNvalue() { return N; }
	
	public ArrayList<String> getNodeList() { return nodeIDList; }
	
	public List<String> getEdgeLength() { return edgeList; }
	
	public Graph getGraph() { return graph; }
	
	public HashMap<Node, ArrayList<Node>> getAdjList() { return adjList; }
		
	public static void main(String[] args) {
		new GraphRender();
	}
}
	*/
	
