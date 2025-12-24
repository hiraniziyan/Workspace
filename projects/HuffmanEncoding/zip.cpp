#include<iostream>
#include<fstream>
#include"huffman.h"
using namespace std;

int CountLetters (int Letters[], ifstream & file);
void buildTree (HuffmanTree & tree, const int Letters[]);
void createEncodedFile(HuffmanTree & tree, const int Letters[], string fileName, int letterCount, ifstream & file);
void printHelp();

const int NumLetters = 256;

int main(int argc, char* argv[])
{
	// Check if there is at least 2 words on command line	
	if (argc < 2)
        {
                cout << "        Bad Filename Entered On Command Line -- Now Aborting." << endl;
                return 1;
        }
	
	string help;		// string for help command
	string fileName;	// string for fileName
	
	// if there are 3 arguments and the second one is --t, set help to --t
	if (argc == 3 && string(argv[1]) == "--t")
	{
		help = argv[1];
		fileName = argv[2];
	}
	else if (string(argv[1]) == "--help")
	{
		printHelp();		// if second parameter is --h print table and exit program
		return 0;
	}
	else if(((string)argv[1]).substr(0,2) != "--")		// check if second argument is a help command
	{
		fileName = argv[1];			// if not then set the fileName to the second argument
	}
	else
	{
		cout << "Unknown Command" << endl;	// exit if unknown command
		return 1;	
	}
	
        ifstream file(fileName.c_str());        // Open file

	// file is not open, produce error message 
	if (!file.is_open())
	{
		cout << "        Bad Filename Entered On Command Line -- Now Aborting." << endl;
                return 1;
	}

	HuffmanTree hTree;	// declare tree

	int Letters[NumLetters];	// declare array for character frequencies
	int letterCount = CountLetters(Letters, file);	//count unique letters and store in array with frequencies
	buildTree(hTree, Letters);		// build a huffman tree
	createEncodedFile(hTree, Letters, fileName, letterCount, file);	// create the .zip file with all data in it
	
	//print the table if help == "--t"
	if (help == "--t")
		hTree.PrintTable();
	
	file.close();	// close file

	return 0;
}

int CountLetters (int Letters[], ifstream & file)
{
	// Pre: file has been input in from command line
	// Post: all characters and frequencies in file have been stored in file
	
        char ch;
	int count = 0;
	
	// Initialize all values in array to 0
        for (char ch = char(0);  ch <= char(126);  ch++)
                Letters[ch] = 0;

        // While there is characters in file keep going
        while (file.get(ch))
	{
                Letters[ch] += 1;	// add 1 to where the char appears in array
		if (Letters[ch] == 1)	// if the character == 1 increment unique character count;
			count++;	
       	}
	return count;
}

void buildTree (HuffmanTree & tree, const int Letters[])
{
	// Pre: All characters and frequencies have been stored in array
	// Post: tree is built 
	

	// Go through array of characters
	for (char ch = char(0);  ch <= char(126);  ch++)
		if(Letters[ch] != 0)	// if the frequency of the character in the slot is not 0 insert it into tree
			tree.insert(ch, Letters[ch]);

	tree.build();	// call build method to build tree
}

void createEncodedFile(HuffmanTree & tree, const int Letters[], string fileName, int letterCount, ifstream & file)
{
	// Pre: Tree has been built
	// Post: encoded file created and original file destroyed
	

	ofstream newFile(fileName + ".zip");	// create new file with .zip extension
	
	// print error message if file is not open
	if (!newFile.is_open())
        {
                cout << "        Unable to Open New File  -- Now Aborting." << endl;
                exit(1);
        }

	newFile << letterCount << endl;		// put the amount of unique letters on the first line of the file	

	// go through character array
	for (char ch = char(0); ch <= char(126);  ch++)
	{
		//if the character was in the file add the ascii value and huffman encoding into the file
		if (Letters[ch] >= 1)
		{
			newFile << int(ch) << " " << tree.GetCode(ch) << endl;
		}
	}
	
	//reset pointer by opening file again
	file.close();
    	file.open(fileName.c_str());

    	if (!file.is_open())
    	{
        	cout << "        Bad Filename Entered On Command Line -- Now Aborting." << endl;
        	exit(1);
    	}

	string huffmanEncoding = "";
	char ch;
	double chInSource = 0;
	// get the huffman encoding for the entire file
	while (file.get(ch))
	{
		huffmanEncoding += tree.GetCode(ch);
		chInSource++;
	}
	newFile << huffmanEncoding << endl; 	// add the encoding to the last line of the newFile

	double compressionRatio = (int) ((1 - (huffmanEncoding.length())/(chInSource * 8)) * 10000) / 100.0; //calculate compression ratio and print
	cout << "File Successfully Compressed To " << huffmanEncoding.length() << " Bits (" << compressionRatio << "% Less)." << endl; 
	newFile.close(); // close new file
	remove(fileName.c_str());

}

void printHelp()
{
	// Pre: The --help comand has been input
	// Post: Prints the help commands
	
	cout << "Usage: ZIP [OPTION]... [FILE]..." << endl;
	cout << "Compress a text file using Huffman encoding." << endl;

  	cout << "		--t              Display the Huffman encoding table." << endl;
  	cout << " 		--help           Provide help on command." << endl;

}
