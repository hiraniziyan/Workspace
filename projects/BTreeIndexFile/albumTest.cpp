#include "album.h"
#include <iostream>
#include <fstream>

using namespace std;

int main(int argc, char* argv[])
{
	// checks for valid command line args
    	if (argc != 2)
    	{
        	cout << "Invalid Arguments" << endl;
        	return 1;
    	}

    	ifstream file(argv[1]);	// opens file

	// prints error if file is not able to open
    	if (!file)
    	{
        	cout << "Error: Could not open file " << argv[1] << endl;
        	return 1;
    	}

    	Album album;
	
    	while (file >> album)	// read each album record from file
    	{
        	cout << album << endl;	// print album record

        	cout << "UPC: " << album.getUPC() << endl;	// print UPC

        	cout << "Record Size: " << album.recordSize() << " bytes" << endl;	// print size of record

		// copy constructor test
        	Album copiedAlbum(album);	// call copy constructor to make copy of album
        	cout << "Copied Album: " << endl;
        	cout << copiedAlbum << endl;		// print record

		// check album comparator
        	if (album < copiedAlbum)
        	{
            		cout << "The current album's UPC is less than the copied album's UPC" << endl;
        	}
		else
		{
			cout << "The current album's UPC is not less than the copied album's UPC" << endl;
		}
		
        	cout << endl;
    	}

    	return 0;
}
