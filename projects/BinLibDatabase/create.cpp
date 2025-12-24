#include<iostream>
#include<fstream>
#include<sstream>
#include<cstring>

using namespace std;


typedef char String[25];
struct BookRec
{
        unsigned int isbn;
        String name;
        String author;
        int onhand;
        float price;
        String type;
};

void processFile(ifstream & file, ofstream & binFile);
bool isValid(BookRec & book, string &line, int lineNum, unsigned int prevIsbn);
void printLibrary();

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
        ofstream binFile("library.out", ios::out | ios::binary);

        // If file does not exist, print error message
        if (!file)
        {
                cout << "The File Name included is not correct" << endl << "Please try again." << endl;
                return 1;
        }
        if (!binFile)
        {
                cout << "Unable to open file: library.out" << endl;
                return 1;
        }

        processFile(file, binFile);	// read in file and store valid book records in binary file
        printLibrary();			// print the output on screen
        return 0;

}

void processFile(ifstream & file, ofstream & binFile)
{
	// Pre: input and output files have been opened  
	// Post: read in records from input file and store valid records in binary file
	
	
        string line;
        int lineNum = 0;
        unsigned int prevIsbn = 0;
        BookRec book;

        while (getline(file, line))	// loop through each line of the file
        {
                lineNum++;	// increment line number
                if (isValid(book, line, lineNum, prevIsbn))		// process the line and check if book record is valid
                {
                        binFile.write((const char *) & book, sizeof(BookRec));	// write the record into the binary file
                        prevIsbn = book.isbn;	// set the previous isbn to current isbn for error checking
                }
        }
	
	// close both files
        file.close();
        binFile.close();

}

bool isValid(BookRec & book, string &line, int lineNum, unsigned int prevIsbn)
{
	// pre: a line has been taken in from the input file
	// post: all fields of the book have been set and checked for errors
	
	bool isValid = true;

        stringstream ss(line);	// create stringstream object to parse through line

        string data;

        getline(ss, data, '|');		// get the first field - isbn

	// check if isbn is valid else print error and return false
	if (stol(data) < 1)
        {
                cerr << "> Illegal isbn number encountered on line " << lineNum << " of data file - record ignored.\n";
                isValid = false;
        }
	else	
	{
		book.isbn = stol(data);		// if isbn is valid set the book's isbn to the isbn
	}

        getline(ss, data, '|');			// get the second field - name
        strcpy(book.name, data.c_str());	// set the book's name to the name

        getline(ss, data, '|');			// get the third field - author
        strcpy(book.author, data.c_str());	// set the book's author to the author

        getline(ss, data, '|');			// get the fourth field - onhand
        book.onhand = stoi(data);		// set the book's onhand to onhand

        getline(ss, data, '|');			// get the fifth field - price
        book.price = stof(data);		// set the book's price to price

        getline(ss, data, '|');			// get the last field - type
        strcpy(book.type, data.c_str());	// set the book's type to type

	// check for correct sequence of isbn, valid onhand, and valid price. print error messages accordingly
        if(book.isbn < prevIsbn)
        {
                cerr << "> Isbn number out of sequence on line " << lineNum << " of data file.\n";
		printf("%010u %25s %25s %10d %10.2f %15s\n", book.isbn, book.name, book.author, book.onhand, book.price, book.type);
        }
        if(book.onhand < 0)
        {
                cerr << "> Negative amount onhand on line " << lineNum << " of data file - record ignored.\n";
		printf("%010u %25s %25s %10d %10.2f %15s\n", book.isbn, book.name, book.author, book.onhand, book.price, book.type);
                isValid = false;	// book is not valid
        }
        if(book.price < 0)
        {
                cerr << "> Negative price on line " << lineNum << " of data file - record ignored.\n";
		printf("%010u %25s %25s %10d %10.2f %15s\n", book.isbn, book.name, book.author, book.onhand, book.price, book.type);
                isValid = false;	// book is not valid
        }
        return isValid;

}

void printLibrary()
{
	// pre: binary file has been completed
	// post: read from binary file of book records and print each record to the screen
	
	cout << "\n\n";		// format spacing

        ifstream binFile("library.out", ios::binary);	// open library.out as binary file for reading

        BookRec book;
        while (binFile.read((char *) & book, sizeof(BookRec))) 	// loop through each record and print it out
        {
                printf("%010u %25s %25s %10d %10.2f %15s\n", book.isbn, book.name, book.author, book.onhand, book.price, book.type);
        }
}
