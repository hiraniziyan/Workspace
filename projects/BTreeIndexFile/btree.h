#include <vector>
#include <set>
#include <iostream>
#include <cstring>
#include <string>
#include <cstdlib>
#include "album.h"
using namespace std;

#ifndef BTREE_H
#define BTREE_H

class Album;
const int ORDER = 5;
typedef Album keyType;
typedef int IndexArray[ORDER];
typedef keyType ValueArray[ORDER-1];

struct BTNode
{
        int currSize;
        ValueArray contents;
        IndexArray child;
};

struct Pair
{
        Album element;
        int loffset;
        int roffset;
        friend bool operator < (const Pair& p1, const Pair& p2)
           { return (p1.element < p2.element);  }
};

class BTree
{
 public:
        BTree();
        void writeHeader (char * fileName);
        void insert (keyType key);
        void reset (char * filename);
        void close ();
        void printTree();
        void inorder();
        void reverse();
        int getHeight();
        bool search (string key);
        keyType retrieve (string key);
        void totalio() const;
        int countLeaves();
 private:
        BTNode root;
        int rootAddr;
        char treeFileName[80];
        fstream treeFile;
        int height;
        void printTree (int recAddr);
        void inorder (int recAddr);
        void reverse (int recAddr);
        int read;
        int write;
        int findAddr (keyType key, BTNode t, int tAddr);
        int findpAddr(keyType key, BTNode t, int tAddr);
	bool insert(keyType key, int nodeAddr, keyType& midKey, int& newChildAddr);
        BTNode getNode (int recAddr);
        void printNode(int recAddr);
        void placeNode (keyType k,int recAddr,int oneAddr,int twoAddr);
        bool isLeaf (int recAddr);
        bool isLeaf(BTNode t);
        int countLeaves(int recAddr);
        void adjRoot (keyType rootElem, int oneAddr, int twoAddr);
	void splitNode (keyType & key, int recAddr, int newLeft, int newRight, int& leftAddr,int& rightAddr);
        bool search (string key, BTNode t, int tAddr);
	int writeNode(BTNode& node);
	bool insertIntoLeaf(int nodeAddr, BTNode& t, const keyType& key, keyType& midKey, int& newChildAddr);
        bool insertIntoInternal(int nodeAddr, BTNode& t, int childIndex, keyType midKey, int newChildAddr, keyType& parentKey, int& rightChild);
	

};

#endif
