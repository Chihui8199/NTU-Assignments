package graphRender;

import java.io.IOException;
import java.util.*;
import org.graphstream.graph.Edge;
import org.graphstream.graph.Graph;
import org.graphstream.graph.Node;

import graphRender.fileCreate;
//import GraphRender;
import graphRender.fileRead;


public class Breadth_First_Search {
	private static int index = 0;
	private Graph graphCreated;
	private int n;
	private ArrayList<String> listofNode;
	private ArrayList<String> edgesLength;
	private HashMap<Node, ArrayList<Node>> adjList;
	private ArrayList<String> hospitalNodes;
	
	public Breadth_First_Search() throws IOException {				// creates the graph and all the main method set out
		fileRead.createGraphFromFile();
		this.graphCreated = fileRead.getGraph();
		this.n = fileRead.getNvalue();
		this.listofNode = fileRead.getNodeList();
		this.adjList = fileRead.getAdjList();
		this.hospitalNodes = fileRead.getHospitals();
	}
	
	private List<Node> bfs (Node start, ArrayList<String> hosLeft){
		HashMap<Node, Node> parentMapping = new HashMap<>();				// to map "nextNodeInLine" to "currentNode"
		Queue<Node> toTraverse = new LinkedList<>();						// to store and collate adjacent nodes to current node into a list
		HashSet<Node> visited = new HashSet<>();						// to prevent traversing of the same node twice
		toTraverse.add(start);
		
		
		while (!toTraverse.isEmpty()) {
			Node current = toTraverse.poll(); 		// remove the first node from the list
			if (hosLeft.contains(current.getId())) { return constructPath(start, current, parentMapping); }  // if found exit the loop
			if (!adjList.containsKey(current)) {
				continue; 		//There is no more connected edges therefore in the list node it jump to the next nodes
			}
			else {
				ArrayList<Node> adjacentNodes = adjList.get(current); 			
				for (Node adjacent: adjacentNodes) {
					if (!visited.contains(adjacent)) {
						visited.add(adjacent);
						toTraverse.add(adjacent);
						parentMapping.put(adjacent, current);			// churning out the list toTranverse
					}
				}
			}
		}
		return new ArrayList<Node>(); 
}
	
	
	private LinkedList<Node> constructPath(Node start, Node end, HashMap<Node, Node> parentMapping){
		LinkedList<Node> path = new LinkedList<>();
		
		Node current = end;
		while(!current.equals(start)) {
			if (parentMapping.get(current)==null && !current.equals(start)) { return null; }
			path.addFirst(current);
			current = parentMapping.get(current);
		}
		path.addFirst(start);
		
		return path;
	}
	
	public void startSearch() throws IOException {
		System.out.println("All the Hospital Nodes are: " + hospitalNodes.size());
		ArrayList<List<Node>> allPathsTraverse = new ArrayList<>();
		for (String curr: listofNode) {
			Node startNode = graphCreated.getNode(curr);
			ArrayList<String> hospitalsLeft = new ArrayList<>(hospitalNodes);	// copy the current list of hospital to find path that has more than one
			// by removing a hospital from this list, means it have traverse the path before, therefore treating this hospital node as 
			// a normal node, (non-existent hospital)
			List<Node> pathStipulated;
			
// if we are looking at the nearest hospitals only
			pathStipulated = bfs(startNode, hospitalsLeft);			
			System.out.println("Starting node: " + pathStipulated.get(0).getId());
			System.out.println("Ending node: " + pathStipulated.get(pathStipulated.size()-1).getId());
			System.out.println("Path to the nearest hospital number " + Integer.toString(1) + ": " + pathStipulated.toString());
			allPathsTraverse.add(pathStipulated);
		}
		
		//COMPUTING THE SYSTEM RUNTIME
//		long endTime = System.nanoTime();
//		long duration = (endTime - startTime) / 10000;
//		System.out.println("Time taken: " + Long.toString(duration));
//		CreateFile.writePathToFile(allPaths);
		
		
		HashMap<Node, ArrayList<List<Node>>> moreThanOnePaths = new HashMap<>();
		System.out.println("Enter your k-value:");
		Scanner inputforK = new Scanner(System.in);
		int k = inputforK.nextInt();
		
		long startingTime2 = System.nanoTime();
		for (String curr: listofNode) {
			ArrayList<String> hospitalsRemaining = new ArrayList<>(hospitalNodes);
			for (int i = 0; i < k; i++) {
				Node startNode = graphCreated.getNode(curr);
				List<Node> path;
				
				path = bfs(startNode, hospitalsRemaining);
				System.out.println("Starting node: " + path.get(0).getId());
				System.out.println("Ending node: " + path.get(path.size()-1).getId());
				System.out.println("Path to the nearest hospital number " + Integer.toString(i+1) + ": " + path.toString());
				hospitalsRemaining.remove(hospitalsRemaining.indexOf(path.get(path.size()-1).getId()));
				if (!moreThanOnePaths.containsKey(startNode)) {
					ArrayList<List<Node>> temporaryStorage = new ArrayList<>();
					temporaryStorage.add(path);
					moreThanOnePaths.put(startNode, temporaryStorage);
				} else {
					moreThanOnePaths.get(startNode).add(path);
				}
			}
		}
		
		//COMPUTING SYSTEM RUNTIME
//		long endTime2 = System.nanoTime();
//		long duration2 = (endTime2 - startTime2) / 1000000;
//		System.out.println("Time taken: " + Long.toString(duration2));
//		CreateFile.writePathsToFile(moreThanOnePaths, k);
	}
	
	public static void main(String[] args) throws IOException {
		Breadth_First_Search checker = new Breadth_First_Search();
		checker.startSearch();
	}
}

