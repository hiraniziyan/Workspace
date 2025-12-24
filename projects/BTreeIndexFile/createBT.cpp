#include "btree.h"
#include <fstream>
#include <iostream>

using namespace std;

int main(int argc, char* argv[]) 
{
	// invalid args
    	if (argc != 3) 
	{
        	cerr << "Invalid number of arguments." << endl;
        	return 1;
    	}

    	BTree tree;	// create Btree

	// write header and retrieve root address from file (currently -1)
    	tree.writeHeader(argv[2]);
    	tree.reset(argv[2]);

	// open album file
    	ifstream albumFile(argv[1]);
    	if (!albumFile) 
	{
        	cout << "Unable to open album file." << endl;
        	return 1;
    	}

	// read albums from file and insert into tree
    	Album temp;
    	while (albumFile >> temp) 
	{
        	tree.insert(temp);
    	}

	cout << "-------- B-tree of height " << tree.getHeight() << " --------" << endl;

    	tree.printTree();	// print tree

    	albumFile.close();	// close file, write the new root address to header
    	return 0;
}	
