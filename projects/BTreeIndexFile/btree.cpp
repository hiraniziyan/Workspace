#include "btree.h"
#include <cstring>
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

//Constructor
BTree::BTree()
{
	// initialize rootAddr, currSize, and child addresses
	rootAddr = -1;				
    	root.currSize = 0;
    	for (int i = 0; i < ORDER; i++)
    	{
        	root.child[i] = -1;
    	}

	// initialize variables for height, read count, and write count
    	height = 0;
    	read = 0;
    	write = 0;
}

void BTree::writeHeader(char* fileName)
{
	// open treeFile
    	fstream treeFile(fileName, ios::out | ios::binary);
	if (!treeFile)
	{
		cout << "Unable to open file : " << fileName << endl;	// error message if unable to open treeFile
		exit(1);
	}

	// create and initalize header node
    	BTNode header;
    	header.currSize = 0;

    	for (int i = 0; i < ORDER; i++)
        	header.child[i] = -1;

    	treeFile.write((const char*)&header, sizeof(BTNode));	// write header node to file
	write++;

    	treeFile.close();
}

void BTree::reset(char* filename)
{
	// open treeFile
    	treeFile.open(filename, ios::in | ios::out | ios::binary);
	if(!treeFile)
	{
		cout << "Unable to open file : " << filename << endl;	// error message if unable to open treeFile
		exit(1);
	}

	// read the header from the beginning of the treeFile
    	BTNode header = getNode(0);

    	rootAddr = header.child[0]; 	// get the root address from header node
}

void BTree::close()
{
    	BTNode header = getNode(0);	// read header node from beginning of file
    	header.child[0] = rootAddr;	// set the root address to new new address after program is over

	// write header back to file
    	treeFile.seekp(0, ios::beg);
    	treeFile.write((const char*)&header, sizeof(BTNode));
	write++;

    	treeFile.close();
}

void BTree::insert(keyType key)
{
    	cout << "Now inserting " << key;

	// create new root if it does not exist
    	if (rootAddr == -1)
    	{
        	root.contents[0] = key;		// write the key to the first slot of the contents array for root
		root.currSize = 1;		// increase currSize to 1
	
        	rootAddr = writeNode(root);	// write the root to the back of the treeFile
	
        	return;
    	}

    	keyType midKey;			
    	int newChildAddr = -1;

	// call the recursive insert method and return true if the recursion gets a split all the way up to the root
    	bool rootSplits = insert(key, rootAddr, midKey, newChildAddr);	

    	if (rootSplits)
        	adjRoot(midKey, rootAddr, newChildAddr);	// if the root splits, adjust the root to make a new root
}

bool BTree::insert(keyType key, int nodeAddr, keyType& midKey, int& newChildAddr)
{
        BTNode t = getNode(nodeAddr);		// get the root node on the first call, then any node during recursive decent of the tree
	
	// if node is a leaf, insert key into the leaf (insertIntoLeaf calls spilt if needed)
        if (isLeaf(t))
                return insertIntoLeaf(nodeAddr, t, key, midKey, newChildAddr);

	int i;
	for (i = t.currSize - 1; i >= 0 && key < t.contents[i]; i--);	// get the location of where to insert

        i++; // increment i because the address to the child is stored in the next slot of the child array

        bool split = insert(key, t.child[i], midKey, newChildAddr);	// recursively call insert to decend the tree

	// if there was a split, insert middle key into parent node (insertIntoInternal calls split if needed)
        if (split) 
                return insertIntoInternal(nodeAddr, t, i, midKey, newChildAddr, midKey, newChildAddr);	
	else
		return false;
       
}
	

bool BTree::insertIntoLeaf(int nodeAddr, BTNode& t, const keyType& key, keyType& midKey, int& newChildAddr)
{
	// if leaf is not full, insert directly into it
    	if (t.currSize < ORDER - 1)	
    	{		
		// find where to insert key to array
        	int i = t.currSize - 1;	
        	while (i >= 0 && key < t.contents[i])
        	{
            		t.contents[i + 1] = t.contents[i];	// shift everything to right
            		i--;
        	}

        	t.contents[i + 1] = key;		// insert key
        	t.currSize++;				// increment current size of contents array

		// update the node in the file
        	treeFile.seekp(nodeAddr, ios::beg);			
        	treeFile.write((const char*)&t, sizeof(BTNode));
        	write++;

        	return false;	// false since no split was needed
    	}
	else
    	{
		
		int leftAddr, rightAddr;	// addresses for the nodes created by split
    		keyType tempKey = key;		// key copy for holding the middle key to be promoted during split
	
		// split node into two; get the address of new node
    		splitNode(tempKey, nodeAddr, -1, -1, leftAddr, rightAddr);	
	
    		midKey = tempKey;		// set middle key
    		newChildAddr = rightAddr;	// set new node address

    		return true;	// split was needed
	}
}

bool BTree::insertIntoInternal(int nodeAddr, BTNode& t, int childIndex, keyType midKey, int newChildAddr, keyType& parentKey, int& rightChild)
{
	// if internal node has space, insert key and shift elements and child addresses
    	if (t.currSize < ORDER - 1)
    	{
        	for (int i = t.currSize - 1; i >= childIndex; i--)
        	{
            		t.contents[i + 1] = t.contents[i];	// shift contents to right while trying to find space to insert
            		t.child[i + 2] = t.child[i + 1];	// shift child addresses to right
        	}

        	t.contents[childIndex] = midKey;		// insert key
        	t.child[childIndex + 1] = newChildAddr;		// insert the new child address
       	 	t.currSize++;					

		// update node in file
        	treeFile.seekp(nodeAddr, ios::beg);			
       	 	treeFile.write((const char*)&t, sizeof(BTNode));
        	write++;

        	return false;
    	}
	else
	{
    		int leftAddr, rightAddr;	// addresses for the nodes created by split

		// split node into two; get the address of new node
    		splitNode(midKey, nodeAddr, t.child[childIndex], newChildAddr, leftAddr, rightAddr);

    		parentKey = midKey;		// set parent key as the middle key
    		rightChild = rightAddr;		// set new node address

    		return true;
	}
}

void BTree::splitNode(keyType & key, int recAddr, int newLeft, int newRight, int& leftAddr, int& rightAddr)
{
    	cout << "Now Splitting!\n";

    	BTNode t = getNode(recAddr);	// get node to split

    	vector<Pair> pairArr;	// create pair array to hold all pairs in a node
	
	Pair newPair;			// create a newPair for the key to insert
        newPair.element = key;
        newPair.loffset = newLeft;
        newPair.roffset = newRight;
        pairArr.push_back(newPair);		// push it into the array
	
	// go through current node creating pairs for all elements and push them into array
    	for (int i = 0; i < t.currSize; i++)
    	{
        	Pair pair;
        	pair.element = t.contents[i];
        	pair.loffset = t.child[i];
        	pair.roffset = t.child[i + 1];
        	pairArr.push_back(pair);
    	}

    	sort(pairArr.begin(), pairArr.end());	// sort the pair array

    	int mid = (t.currSize + 1) / 2;		
    	key = pairArr[mid].element;	// get the middle element of the pair array to be the one that is promoted during split
	
    	vector<int> childPtrs(t.currSize + 2);		// create an array of child addresses

	// put all the child offsets in the child pointer array
    	childPtrs[0] = pairArr[0].loffset;	
    	for (int k = 0; k < t.currSize + 1; k++)
    	{
        	childPtrs[k + 1] = pairArr[k].roffset;
    	}	

	// create the left node
    	BTNode L;
    	L.currSize = mid;
    	for (int i = 0; i < ORDER; i++) 	// initialize children addresses
		L.child[i] = -1;
    	for (int i = 0; i < mid; i++) 			// go until half the pair array inserting each element
		L.contents[i] = pairArr[i].element;
    	for (int i = 0; i <= mid; i++) 			// go until half the child pointer array putting each child address into node child array
		L.child[i] = childPtrs[i];

	// create right node
    	BTNode R;	
    	R.currSize = t.currSize - mid;	
    	for (int i = 0; i < ORDER; i++) 		// initialize child addresses
		R.child[i] = -1;
    	for (int i = mid + 1, j = 0; i < t.currSize + 1; i++, j++) 	// go through the second half of the pair array inserting each element
		R.contents[j] = pairArr[i].element;
    	for (int i = 0; i <= R.currSize; i++) 				// fill child addresses to child array of right node
		R.child[i] = childPtrs[mid + 1 + i];
	
	// write the left node in the place of the current node
    	treeFile.seekp(recAddr, ios::beg);
    	treeFile.write((const char*)&L, sizeof(BTNode));
    	write++;

    	leftAddr = recAddr;

    	rightAddr = writeNode(R);	// write the right node at the end of file
}

void BTree::adjRoot(keyType rootElem, int oneAddr, int twoAddr)
{
	cout << "Now Adjusting Root!\n";

	// create new root, and initialize it with the promoted key(rootElem)
    	BTNode newRoot;
    	newRoot.currSize = 1;
    	newRoot.contents[0] = rootElem;

    	for (int i = 0; i < ORDER; i++) 	// initialize child addresses
		newRoot.child[i] = -1;

	// set the pointer to the left and right node
    	newRoot.child[0] = oneAddr;	
    	newRoot.child[1] = twoAddr;

    	rootAddr = writeNode(newRoot);	// write the node at the end of file and save rootAddr

    	height++;	// increment height of btree
}

bool BTree::search(string key)
{
	if (rootAddr == -1) 			// don't search if no root
		return false;

    	BTNode t = getNode(rootAddr);		// get the root

    	return search(key, t, rootAddr);	// search recursively from root
}

bool BTree::search(string key, BTNode t, int tAddr)
{
	int i;

    	for (i = 0; i < t.currSize && key > t.contents[i].getUPC(); i++);	// get index of where to descend/find key

    	if (key == t.contents[i].getUPC())	// return true if key is found
		return true;	
	
    	if (isLeaf(t)) 				// return false if key is not found and we are at a leaf
		return false;

    	return search(key, getNode(t.child[i]), t.child[i]);	// search from the child at the index i
}

bool BTree::isLeaf(BTNode node)
{	
	// check if all address of children of the node do not equal -1, if they do the it is a leaf
        for (int i = 0; i <= node.currSize; i++)	
                if (node.child[i] != -1)
                        return false;
        return true;
}

bool BTree::isLeaf(int recAddr)
{
        BTNode node = getNode(recAddr);		// get node at the address
        return isLeaf(node);			// check if node is a leaf
}

void BTree::printTree()
{
    	printTree(rootAddr);		// print tree from root
}

void BTree::printTree(int recAddr)
{
	// pre order printing of tree
    	if (recAddr != -1)
       	{
		// get and print node at address
    		BTNode dummy = getNode(recAddr);	
		printNode(recAddr);

		// descend tree recursively
        	for (int i = 0; i <= dummy.currSize; i++)
            		printTree(dummy.child[i]);
	}
}

void BTree::printNode(int recAddr)
{
	// seek the node at the adress
	treeFile.seekg(recAddr, ios::beg);
	
	BTNode dummy; 
	
	treeFile.read((char*) &dummy, sizeof(BTNode));
	
	read++;
	
	cout << "    *** node of size " << dummy.currSize << " ***\n";

	// print the contents of the node
	for (int i = 0; i < dummy.currSize; i++)
		cout << dummy.contents[i];

}

int BTree::writeNode(BTNode& node)
{
	// go to the end of file, and write the node
        treeFile.seekp(0, ios::end);

        int addr = int(treeFile.tellp());

        treeFile.write((const char*)&node, sizeof(BTNode));

        write++;

        return addr;	// return address the node is written at
}

BTNode BTree::getNode(int recAddr)
{
	// seek the node at the address in file and return it
        BTNode node;			

        treeFile.seekg(recAddr, ios::beg);

        treeFile.read((char*)&node, sizeof(BTNode));

        read++;

        return node;
}

void BTree::totalio() const
{
	// print reads and writes
	cout << "Total Writes: " << write << endl;
	cout << "Total Reads: " << read << endl;
}

int BTree::getHeight()
{	
	// return height of the tree
    	return height;
}

