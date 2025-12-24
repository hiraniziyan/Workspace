#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <climits>
#include <algorithm>
#include <sstream>
#include "graph.h"
#include "HashTable.h"
#include "queue.h"
#include <cstdlib>

using namespace std;

void readFile(ifstream & file, Graph<string> & graph, vector<string> & vertices, HashTable<string> & hTable);
void QuickSort(vector<string> & vertices, int first, int last);
void split(vector<string>& vertices, int first, int last, int& splitPoint);
void dijkstra(vector<string> & vertices, Graph<string> & graph, Queue<string> & myQ);
void printSummaryTable(string startPt, vector<string> & vertices, Graph<string> & graph, Queue<string> & myQ);
int indexOf(vector<string> vertices, string key);
void printRow(string vertex, string prev, int distance);
bool depthFirstSearchCycle(Graph<string>& graph, vector<string>& vertices, string current, vector<bool>& marked, vector<bool>& inPath, vector<string>& cycle);
void findCycle(Graph<string>& graph, vector<string>& vertices);
void printCycle(vector<string> cycle);

int main(int argc, char* argv[]) 
{

	// Check if there are at least two command line args
	if (argc != 2) 
	{
    		cout << "The command line inputs were not correct." << endl << "Please try again." << endl;
        	return 1;
    	}

	// Get file name and open file
    	string filename = argv[1];
    	ifstream file(filename);
	
	// If file does not exist, print error message
    	if (!file) 
	{
        	cout << "The File Name included is not correct" << endl << "Please try again." << endl;
        	return 1;
    	}	
	
	// Clear screen
	system("clear");
	
	// Declare a Graph, Queue, Hashtable, and vector
    	Graph<string> myGraph(50);
	Queue<string> myQ(50);
	HashTable<string> hTable("", 50);
	vector<string> vertices;
	
	// Read file, make Graph, and store all vertices in the file into the vertices array
	readFile(file, myGraph, vertices, hTable);
	
	// Sort the vertices array
	QuickSort(vertices, 0, vertices.size()-1);

	// Print dijkstra summary table from the starting pt the user selects
	dijkstra(vertices, myGraph, myQ);
	
	// Find and Print a cycle if one exists
        findCycle(myGraph, vertices);
	
	return 0;
}

void readFile(ifstream & file, Graph<string> & graph, vector<string> & vertices, HashTable<string> & hTable)
{	
	// Pre: File has been opened
	// Post: Graph is made and all vertices in file have been stored in vertices array
	
	string line; 
	
	// Read every line one by one from the file
	while (getline(file, line))
	{
		// Make a stringstream object to store delimiters
		string v1, v2, distance;
		stringstream ss(line);
		
		// Get vertex1, vertex2, and distance
		getline(ss, v1, ';');
		getline(ss, v2, ';');
		getline(ss, distance, ';');
	
		// If vertex is not alr in HashTable, insert it into the graph and vertices array
		if (hTable.find(v1) == "")
		{
			hTable.insert(v1);
			graph.AddVertex(v1);
			vertices.push_back(v1);
		}
	
		if (hTable.find(v2) == "")
                {
                        hTable.insert(v2);
                        graph.AddVertex(v2);
                        vertices.push_back(v2);
                }
		
		// Add the edge for the two vertices
		graph.AddEdge(v1, v2, stoi(distance));	

	}
	file.close();	// close file
}
	
void QuickSort(vector<string> & vertices, int first, int last) 
{
	// Pre: vertices array contains all vertices from file
	// Post: the array is sorted
	
    	if (first < last) 
	{
        	int splitPoint;

		// split array
        	split(vertices, first, last, splitPoint);
		
		// Recursively sort the left and right part of array	
        	QuickSort(vertices, first, splitPoint - 1);
        	QuickSort(vertices, splitPoint + 1, last);
    	}
}

void split(vector<string>& vertices, int first, int last, int& splitPoint)
{
	// Quicksort split function
	
	// Get pivot and save the its index
        string pivot = vertices[first];		
        int saveFirst = first;
        first++;
	
	// Go while first <= last
        while (first <= last) 
	{
		// Find a vertex greater than pivot
        	while ((vertices[first] <= pivot) && (first <= last))
                	first++;
		// Find a vertex less than pivot
            	while ((vertices[last] >= pivot) && (first <= last))
                	last--;
		// Perform swap if first < last
            	if (first < last) {
                	swap(vertices[first], vertices[last]);
                	first++;
                	last--;
            	}
        }
	
        splitPoint = last;	// Set new splitPt

        swap(vertices[saveFirst], vertices[splitPoint]);	// Swap the positions of the vertices using inbuilt swap
}

void dijkstra(vector<string> & vertices, Graph<string> & graph, Queue<string> & myQ)
{
	// Pre: Graph has been built and vertices array has been sorted
	// Post: A summary table for dijkstra's algorithm is printed
	
	// Heading
	cout << "\t^^^^^^^^^^^^^^^^ DIJKSTRA’S ALGORITHM ^^^^^^^^^^^^^^^^\n\n";
	cout << "\tA Weighted Graph Has Been Built For These " << vertices.size() << " Cities:\n\n";

	// Print all Vertices
	for (int i = 0; i < vertices.size(); i++)
	{
		printf("%20s", vertices[i].c_str());
		if ((i + 1) % 3 == 0)
			cout << endl;
	}
	cout << endl << endl;

	// Get startPt
	string startPt;
	cout << "\tPlease input your starting vertex: ";
	getline(cin, startPt);
	
	// Keep asking while a valid startPt is not entered
	while(indexOf(vertices, startPt) == -1)
	{
		cout << "\tStarting location does not exist...\n";
		cout << "\tPlease input a new starting vertex: " ;
		getline(cin, startPt);	
	}
	
	// Print the Summary Table
	printSummaryTable(startPt, vertices, graph, myQ);
	
}

void printSummaryTable(string startPt, vector<string> & vertices, Graph<string> & graph, Queue<string> & myQ)
{
	// Pre: A valid startPt has been chosen by user
	// Post: A summary table for dijkstra's algorithm has been built
	
	// Header
	cout << "\t------------------------------------------------------------------\n\n";
	printf("%22s%22s%22s\n\n", "Vertex", "Distance", "Previous");

	// get index of the startPt
	int first = indexOf(vertices, startPt);

	// create a vector of all edge weights and initialize it to INT_MAX
        vector<int> lengths(vertices.size(), INT_MAX);
        lengths[first] = 0;

	// create vector of bools to note whether a vertex has been marked and initialize it to false
        vector<bool> isMarked(vertices.size(), false);

	// create a vector for all previous vertices and initialize it to "N/A"
        vector<string> previous(vertices.size(), "N/A");

	for (int i = 0; i < vertices.size(); i++)
	{
		int curr = -1;
		int min = INT_MAX;
	
		// Loop through each vertex
		for (int j = 0; j < vertices.size(); j++)
		{
			// if edge length is less than the curr min and is not marked 
			if (lengths[j] < min && !isMarked[j])
			{
				min = lengths[j];	// assign min to the length of the vertex
				curr = j;		// make the current index j
			}
		}
		
		// Break when done checking all vertices
		if (curr == -1)
			break;

		// print a row in the table 
		printRow(vertices[curr], previous[curr], lengths[curr]);
		
		// Get adj verticies of current vertex
		graph.GetToVertices(vertices[curr], myQ);
		
		// Mark the current vertex
		isMarked[curr] = true;
		
		// go to each adjacent vertex individually
		while(!myQ.isEmpty())
		{
			// get the vertex and its index
			string v2 = myQ.dequeue();
			int index = indexOf(vertices, v2);
			
			// if it is not marked, store info about the vertex
			if(!isMarked[index])
			{
				// get edgeWeight
				int edgeWeight = graph.WeightIs(vertices[curr], v2);

				// if new edgeweight is less than curr edge weight
				if (edgeWeight + lengths[curr] < lengths[index])
				{
					lengths[index] = edgeWeight + lengths[curr]; // replace curr with new edge weight
					previous[index] = vertices[curr];	// update previos vertex
				}	
			}
		}
		
		
	}

	// Find and print any vertices not on path by checking if their length is still INT_MAX
	for (int i = 0; i < vertices.size(); i++)
		if (lengths[i] == INT_MAX)
			printf("%22s%22s%22s\n", vertices[i].c_str(), "Not on Path" , previous[i].c_str());
	
	
        cout << "\t------------------------------------------------------------------\n";

}

int indexOf(vector<string> vertices, string key)
{
	//Post: return index of the key in the vertices array
	
	// Loop through array
	for (int index = 0; index < vertices.size(); index++)
		if (vertices[index] == key)	// if the current vertex is the key
			return index;		// return the index of the vertex

	return -1;				// else return -1 if not found
}

void printRow(string vertex, string prev, int distance)
{
	// Print row with correct formatting
	printf("%22s%22d%22s\n", vertex.c_str(), distance, prev.c_str());

}

bool depthFirstSearchCycle(Graph<string>& graph, vector<string>& vertices, string current, vector<bool>& marked, vector<bool>& inPath, vector<string>& cycle) {
	// Pre: the graph is made and there is an array of vertices is sorted
	// Post: the cycle array will contain a cycle if one is found
	
	// Find curr index of vertex
    	int currentIndex = indexOf(vertices, current);
    
	// if it is already marked return false
    	if (marked[currentIndex]) 
    		return false;
	 
	// mark the current vertex and add it to the path and cycle
	marked[currentIndex] = true;
    	inPath[currentIndex] = true;
    	cycle.push_back(current);

	// queue to get to adjacent vertices of current vertex
    	Queue<string> Q(50);
    	graph.GetToVertices(current, Q);
	
	// go through each adjacent vertex
	while (!Q.isEmpty()) 
	{
		// get the vertex and its index
        	string adjV = Q.dequeue();
        	int adjIndex = indexOf(vertices, adjV);
        
		// if it is not marked, recursively call dps on that vertex
        	if (!marked[adjIndex]) 
		{
            		if (depthFirstSearchCycle(graph, vertices, adjV, marked, inPath, cycle))
                		return true;
		}
        	// If vertex is alr in path
        	else if (inPath[adjIndex]) 
		{
            		cycle.push_back(adjV);	// add it to the cycle
            		return true;	// there is a cycle
        	}
    	}

	// remove current vertex from cycle and indicate that it is not in Path
    	cycle.pop_back();
    	inPath[currentIndex] = false;

    	return false;	// no cycle
}

void findCycle(Graph<string>& graph, vector<string>& vertices)
{
	// Pre: A graph exists and a vector of all vertices has been sorted
	// Post: A cycle is printed if one exists 
	
	// Create vectors for if the verties have been marked and are inPath and are part of the cycle
    	vector<bool> marked(vertices.size(), false);
    	vector<bool> inPath(vertices.size(), false);
    	vector<string> cycle;

	// Go through each vertex
    	for (string vertex : vertices)
    	{
		// if it is not marked
    		if (!marked[indexOf(vertices, vertex)])
    	    	{	
			// Perform dps
    	        	if (depthFirstSearchCycle(graph, vertices, vertex, marked, inPath, cycle))
    	        	{
				// Print cycle if one exists
    	        		cout << "\t\tThe graph contains a cycle \n\n";
				cout << "\t Extra Credit Printing Of One Cycle: \n";
				printCycle(cycle);
                    		return;
            		}
        	}
    	}

	// No cycle exists
    	cout << "\t\tThe graph does not contain a cycle." << endl;
}

void printCycle(vector<string> cycle)
{
	// Pre: a cycle is in the cylce array
	// Post: prints the cycle in the correct format
	
	int startCycle = 0;
	int numVertex = cycle.size() - 1;
	
	// Get the index where the cycle starts in the Array knowing that start Vertex will always be te same as last Vertex
	while (cycle[startCycle] != cycle[numVertex])
	{
		startCycle++;
	}
	
	// Print the cycle
	printf("%25s%21s\n", "Vertex", "To");
	for ( int i = startCycle; i < numVertex ; i++)
		printf("%25s%12s%13s\n", cycle[i].c_str(), "-->", cycle[i + 1].c_str());
	cout << endl;

}
