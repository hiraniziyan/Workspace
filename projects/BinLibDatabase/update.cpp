#include "btree.h"
#include <cstring>
#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

// -----------------------------------------------------------------------------
// Constructors & File I/O Helpers
// -----------------------------------------------------------------------------
BTree::BTree()
{
    root.currSize = 0;
    for (int i = 0; i < ORDER; i++)
    {
        root.child[i] = -1;
    }
    rootAddr = -1;
    height = 0;
    read = 0;
    write = 0;
}

void BTree::writeHeader(char* fileName)
{
    strcpy(treeFileName, fileName);
    treeFile.open(treeFileName, ios::out | ios::binary);
    BTNode header;
    header.currSize = 0;
    for (int i = 0; i < ORDER; i++)
    {
        header.child[i] = -1;
    }
    treeFile.write((const char*)&header, sizeof(BTNode));
    treeFile.close();
}

void BTree::reset(char* filename)
{
    strcpy(treeFileName, filename);
    treeFile.open(treeFileName, ios::in | ios::out | ios::binary);
    BTNode header;
    treeFile.seekg(0, ios::beg);
    treeFile.read((char*)&header, sizeof(BTNode));
    read++;
    rootAddr = header.child[0];  // byte-offset of root
}

void BTree::close()
{
    BTNode header = getNode(0);
    header.child[0] = rootAddr;
    treeFile.seekp(0, ios::beg);
    treeFile.write((const char*)&header, sizeof(BTNode));
    treeFile.close();
}

int BTree::writeNode(BTNode& node)
{
    treeFile.seekp(0, ios::end);
    int offset = int(treeFile.tellp());  // raw byte-offset
    treeFile.write((const char*)&node, sizeof(BTNode));
    write++;
    return offset;
}

BTNode BTree::getNode(int byteOffset)
{
    BTNode node;
    treeFile.seekg(byteOffset, ios::beg);
    treeFile.read((char*)&node, sizeof(BTNode));
    read++;
    return node;
}

bool BTree::isLeaf(const BTNode& node)
{
    for (int i = 0; i <= node.currSize; i++)
    {
        if (node.child[i] != -1)
        {
            return false;
        }
    }
    return true;
}

bool BTree::isLeaf(int byteOffset)
{
    BTNode node = getNode(byteOffset);
    return isLeaf(node);
}

// -----------------------------------------------------------------------------
// PUBLIC INSERT (bottom-up recursive)
// -----------------------------------------------------------------------------
void BTree::insert(keyType key)
{
    if (!treeFile.is_open())
    {
        treeFile.open(treeFileName, ios::in | ios::out | ios::binary);
        if (!treeFile)
        {
            cerr << "ERROR opening " << treeFileName << "\n";
            exit(1);
        }
    }
    cout << "Now inserting " << key << "\n";

    if (rootAddr == -1)
    {
        root.currSize = 1;
        root.contents[0] = key;
        for (int i = 0; i < ORDER; i++)
        {
            root.child[i] = -1;
        }
        rootAddr = writeNode(root);

        BTNode header = getNode(0);
        header.child[0] = rootAddr;
        treeFile.seekp(0, ios::beg);
        treeFile.write((const char*)&header, sizeof(BTNode));
        write++;
        return;
    }

    keyType promoKey;
    int promoChild = -1;
    bool splitRoot = insertRec(rootAddr, key, promoKey, promoChild);
    if (splitRoot)
    {
        cout << "Now Adjusting Root!\n";
        adjRoot(promoKey, rootAddr, promoChild);
    }
}

bool BTree::insertRec(int byteOffset,
                      const keyType& key,
                      keyType& promoKey,
                      int& promoChild)
{
    BTNode node = getNode(byteOffset);
    int i = node.currSize - 1;
    while (i >= 0 && key < node.contents[i])
    {
        i--;
    }
    i++;

    if (isLeaf(node))
    {
        if (node.currSize < ORDER - 1)
        {
            for (int j = node.currSize; j > i; j--)
            {
                node.contents[j] = node.contents[j - 1];
            }
            node.contents[i] = key;
            node.currSize++;
            treeFile.seekp(byteOffset, ios::beg);
            treeFile.write((const char*)&node, sizeof(BTNode));
            write++;
            return false;
        }
        else
        {
            int leftOffset;
            int rightOffset;
            splitNode(byteOffset,
                      const_cast<keyType&>(key),
                      /* newLeftOffset */ -1,
                      /* newRightOffset*/ -1,
                      leftOffset,
                      rightOffset);
            promoKey = key;
            promoChild = rightOffset;
            return true;
        }
    }
    else
    {
        bool didSplit = insertRec(node.child[i], key, promoKey, promoChild);
        if (!didSplit)
        {
            return false;
        }

        if (node.currSize < ORDER - 1)
        {
            for (int j = node.currSize; j > i; j--)
            {
                node.contents[j] = node.contents[j - 1];
                node.child[j + 1] = node.child[j];
            }
            node.contents[i] = promoKey;
            node.child[i + 1] = promoChild;
            node.currSize++;
            treeFile.seekp(byteOffset, ios::beg);
            treeFile.write((const char*)&node, sizeof(BTNode));
            write++;
            return false;
        }
        else
        {
            int leftOffset;
            int rightOffset;
            splitNode(byteOffset,
                      promoKey,
                      node.child[i],
                      promoChild,
                      leftOffset,
                      rightOffset);
            promoChild = rightOffset;
            return true;
        }
    }
}

void BTree::splitNode(int byteOffset,
                      keyType& key,
                      int newLeftOffset,
                      int newRightOffset,
                      int& leftOffset,
                      int& rightOffset)
{
    cout << "Now Splitting!\n";
    BTNode oldNode = getNode(byteOffset);
    int total = oldNode.currSize + 1;
    vector<Pair> pairs;
    pairs.reserve(total);

    for (int i = 0; i < oldNode.currSize; i++)
    {
        Pair p;
        p.element = oldNode.contents[i];
        p.loffset = oldNode.child[i];
        p.roffset = oldNode.child[i + 1];
        pairs.push_back(p);
    }

    Pair newPair;
    newPair.element = key;
    newPair.loffset = newLeftOffset;
    newPair.roffset = newRightOffset;
    pairs.push_back(newPair);

    sort(pairs.begin(), pairs.end());
    int midIndex = total / 2;
    key = pairs[midIndex].element;

    vector<int> childrenOffsets(total + 1);
    childrenOffsets[0] = pairs[0].loffset;
    for (int k = 0; k < total; k++)
    {
        childrenOffsets[k + 1] = pairs[k].roffset;
    }

    BTNode leftNode;
    leftNode.currSize = midIndex;
    for (int i = 0; i < ORDER; i++)
    {
        leftNode.child[i] = -1;
    }
    for (int i = 0; i < midIndex; i++)
    {
        leftNode.contents[i] = pairs[i].element;
    }
    for (int i = 0; i <= midIndex; i++)
    {
        leftNode.child[i] = childrenOffsets[i];
    }

    int rightSize = total - midIndex - 1;
    BTNode rightNode;
    rightNode.currSize = rightSize;
    for (int i = 0; i < ORDER; i++)
    {
        rightNode.child[i] = -1;
    }
    for (int i = 0; i < rightSize; i++)
    {
        rightNode.contents[i] = pairs[midIndex + 1 + i].element;
    }
    for (int i = 0; i <= rightSize; i++)
    {
        rightNode.child[i] = childrenOffsets[midIndex + 1 + i];
    }

    treeFile.seekp(byteOffset, ios::beg);
    treeFile.write((const char*)&leftNode, sizeof(BTNode));
    write++;
    leftOffset = byteOffset;
    rightOffset = writeNode(rightNode);
}

void BTree::adjRoot(keyType rootElement, int leftOffset, int rightOffset)
{
    BTNode newRoot;
    newRoot.currSize = 1;
    newRoot.contents[0] = rootElement;
    for (int i = 0; i < ORDER; i++)
    {
        newRoot.child[i] = -1;
    }
    newRoot.child[0] = leftOffset;
    newRoot.child[1] = rightOffset;
    rootAddr = writeNode(newRoot);
    height++;
    BTNode header = getNode(0);
    header.child[0] = rootAddr;
    treeFile.seekp(0, ios::beg);
    treeFile.write((const char*)&header, sizeof(BTNode));
    write++;
}

bool BTree::search(string key)
{
    return search(key, getNode(rootAddr), rootAddr);
}

bool BTree::search(string key, BTNode node, int byteOffset)
{
    int i = 0;
    while (i < node.currSize && key > node.contents[i].getUPC())
    {
        i++;
    }
    return (i < node.currSize && key == node.contents[i].getUPC());
}

keyType BTree::retrieve(string key)
{
    int offset = rootAddr;
    while (offset != -1)
    {
        BTNode node = getNode(offset);
        int i = 0;
        while (i < node.currSize && key > node.contents[i].getUPC())
        {
            i++;
        }
        if (i < node.currSize && key == node.contents[i].getUPC())
        {
            return node.contents[i];
        }
        return Album();
    }
    return Album();
}

void BTree::printTree()
{
    printTree(rootAddr);
}

void BTree::printTree(int byteOffset)
{
    if (byteOffset == -1)
    {
        return;
    }
    BTNode node = getNode(byteOffset);
    cout << "    *** Node of size " << node.currSize << " ***\n";
    for (int i = 0; i < node.currSize; i++)
    {
        cout << node.contents[i];
    }
    if (!isLeaf(node))
    {
        for (int i = 0; i <= node.currSize; i++)
        {
            printTree(node.child[i]);
        }
    }
}

void BTree::totalio() const
{
    cout << "Total Reads: " << read << ", Total Writes: " << write << endl;
}

int BTree::countLeaves()
{
    return countLeaves(rootAddr);
}

int BTree::countLeaves(int byteOffset)
{
    if (byteOffset == -1)
    {
        return 0;
    }
    BTNode node = getNode(byteOffset);
    if (isLeaf(node))
    {
        return 1;
    }
    int sum = 0;
    for (int i = 0; i <= node.currSize; i++)
    {
        sum += countLeaves(node.child[i]);
    }
    return sum;
}

int BTree::getHeight()
{
    return height;
}

int BTree::findAddr(keyType, BTNode, int)
{
    return -1;
}

int BTree::findpAddr(keyType, BTNode, int)
{
    return -1;
}

void BTree::placeNode(keyType, int, int, int)
{
    // not implemented
}
