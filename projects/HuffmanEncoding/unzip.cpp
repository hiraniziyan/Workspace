#include<iostream>
#include<string>
#include<map>
#include<fstream>

using namespace std;

void mapValues(map<string, int> & huffmanKey, ifstream & file);
string decode(map<string, int> & huffmanKey, ifstream & file);
void makeFile(string decodedString, string fileName);

int main(int argc, char* argv[])
{	
	// Give error message if there is less than 2 arguments in the command line
	if (argc < 2)
	{
		cout << "        Bad Filename Entered On Command Line -- Now Aborting." << endl;
		return 1;
	}
	
	string fileName = argv[1];		// Get file name which will be the second arg passed in
	ifstream file(fileName.c_str());	// Open file

	// Give error message if file cannot open
	if (!file.is_open())
	{
		cout << "	 Bad Filename Entered On Command Line -- Now Aborting." << endl;
		return 1;
	}

	// Give error message if file name does not end with ".zip"
	if (fileName.substr(fileName.find(".") + 1, 3) != "zip")
	{
		cout << "        File Entered Is Not A Zip File -- Now Aborting." << endl;
		return 1;
	}

	map<string, int> huffmanKey;				// Declare map

	mapValues(huffmanKey, file);				// Call function to map each acii value to its encoding

	string decodedString = decode(huffmanKey, file);	// Function to decode the string to its original string

	file.close();

	makeFile(decodedString, fileName);			// Function which makes a new file with the original text

	cout << "File Successfully Inflated Back To Original." << endl; 

	return 0;

}

void mapValues(map<string, int> & huffmanKey, ifstream & file)
{
	// Get the number of unique characters from the first line of the file
	int uniqueChars;
	file >> uniqueChars;
	
	int ascii;
	string encoding;

	// Loop through each unique character in the file
	for ( ; uniqueChars > 0; uniqueChars--)
	{
		file >> ascii;			// Get the ascii value from file
		file >> encoding;		// Get the encoding from file
		huffmanKey[encoding] = ascii;	// Map the encoding to the ascii value
	}
}

string decode(map<string, int> & huffmanKey, ifstream & file)
{
	// Get the fully encoded string from file
	string fullEncoding;	
	file >> fullEncoding;

	string decodedString = "";
	string mapString = "";
	
	// Loop through the entire encoded string
	for (int index = 0; index < fullEncoding.length(); index++)
	{
		mapString += fullEncoding[index];			// Add the character at the index to the mapString
		if (huffmanKey.find(mapString) != huffmanKey.end())	// Check if the mapString is mapped to any value in the map
		{
			decodedString += huffmanKey[mapString];		// Add on the decodedString the character which the mapString maps to
			mapString = "";					// Reset the mapString
		}
	}
	return decodedString;						// Return the decodedString
}

void makeFile(string decodedString, string fileName)
{
	ofstream newFile(fileName.substr(0, fileName.find(".")));	// Create a new file which does not contain .zip
	
	// If the new file cannot open, print an error Message
	if (!newFile.is_open())	
	{	
		cout << "        Unable to Open New File  -- Now Aborting." << endl;
		exit(1);
	}

	newFile << decodedString;	// Move the decoded string to the new file
	newFile.close();
	
}
