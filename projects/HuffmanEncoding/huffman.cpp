#include "huffman.h"
#include <iostream>
using namespace std;

HuffmanTree:: HuffmanTree()
	: numChars(0), built(false) {}

void HuffmanTree:: insert(char ch, int weight) {
    HNode newNode = {ch, weight, -1, -1}; 
    built = false;
    nodes.push_back(newNode);
    numChars++;

}

bool HuffmanTree:: inTree(char ch) {
	for (HNode node : nodes)
		if (node.ch == ch)
			return true;
	return false;
	

}

int HuffmanTree:: GetFrequency(char ch) {
	return GetFrequency(lookUp(ch));
}

int HuffmanTree:: GetFrequency(int i) {
	return nodes[i].weight;
}

int HuffmanTree:: lookUp(char ch) {
	int numNodes = nodes.size();
	int index;
 	for (int index = 0; index < numNodes; index++) {
    		if (nodes[index].ch == ch) {
        		return index;
    		}
	}
	return -1;
}

string HuffmanTree:: GetCode(char ch) {
	return GetCode(lookUp(ch));
}


string HuffmanTree:: GetCode(int i) {
	if (nodes[i].parent == 0)
		return "";
	else
		return (GetCode(nodes[i].parent) +
			(char)(nodes[i].childType+'0'));

}

void HuffmanTree::PrintTable() {
    printf("\t++++ ENCODING TABLE ++++\n\n");
    printf("Index  Char   Weight  Parent  ChildType\n");

    int i = 0;
    while(i < numChars) {
        if (nodes[i].ch != '\0') {
            if (nodes[i].ch == ' ') {
                printf("%-6d %-6s %-7d %-7d %-9d\n", i, "sp", nodes[i].weight, nodes[i].parent, nodes[i].childType);
            } else if (nodes[i].ch == '\n') {
                printf("%-6d %-6s %-7d %-7d %-9d\n", i, "nl", nodes[i].weight, nodes[i].parent, nodes[i].childType);
            } else {
                printf("%-6d %-6c %-7d %-7d %-9d\n", i, nodes[i].ch, nodes[i].weight, nodes[i].parent, nodes[i].childType);
            }
        }
	i++;
    }
	for (int j = 1 ; i < numNodes(); i++, j++)
        {
		if (nodes[i].childType != -1)
		{
                	printf("%-6d %s%-5d %-7d %-7d %-9d\n", i, "T",j, nodes[i].weight, nodes[i].parent, nodes[i].childType);
		}
		else
			 printf("%-6d %s%-5d %-7d %-7d %-9s\n", i, "T",j, nodes[i].weight, nodes[i].parent, "N\\A");
        }

	
}


int HuffmanTree:: numNodes() {

	return nodes.size();	
}

void HuffmanTree:: build()
{
        int maxNodes = 2 * numChars - 1;
        int smallestNode1;
	int smallestNode2;

        while (numNodes() < maxNodes) {
            smallestNode1 = smallestFrequency();
            nodes[smallestNode1].parent = numNodes();

            smallestNode2 = smallestFrequency();
            nodes[smallestNode2].parent = numNodes();

            nodes[smallestNode1].childType = 0;
            nodes[smallestNode2].childType = 1;

            combineNodes(nodes[smallestNode1].weight + nodes[smallestNode2].weight);
            built = false;
        }

        nodes[numNodes() - 1].parent = 0;
        built = true;
}
int HuffmanTree:: smallestFrequency() {
        int smallestNode = -1;
        for (int i = 0; i < numNodes(); i++) {
            if (nodes[i].parent == -1) {
                if (smallestNode == -1 || nodes[i].weight < nodes[smallestNode].weight) {
                    smallestNode = i;
                }
            }
        }
        return smallestNode;
}
void HuffmanTree:: combineNodes(int frequency){
	HNode newNode;
	newNode.weight = frequency;
	newNode.parent = -1;
	newNode.childType = -1;
	nodes.push_back(newNode);
}
