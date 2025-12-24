#include <iostream>
#include <fstream>
#include <cstring>

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

enum TransactionType { Add, Delete, ChangeOnhand, ChangePrice };

struct TransactionRec
{
    	TransactionType ToDo;
    	BookRec B;
};

int main()
{
    	ofstream outFile("test.out", ios::binary);
    	if (!outFile)
    	{
        	cout << "Error: Unable to open file for writing." << endl;
        	return 1;
    	}

    	TransactionRec transaction;

    	// Add transaction 1
    	transaction.ToDo = Add;
    	transaction.B.isbn = 1234567890;
    	strcpy(transaction.B.name, "Duplicate Add Book");
    	strcpy(transaction.B.author, "Author 1");
    	transaction.B.onhand = 5;
    	transaction.B.price = 12.50;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// Add transaction 2
    	transaction.ToDo = Add;
    	transaction.B.isbn = 1111111111;
    	strcpy(transaction.B.name, "New Book 1");
    	strcpy(transaction.B.author, "Author 2");
    	transaction.B.onhand = 10;
    	transaction.B.price = 15.99;
    	strcpy(transaction.B.type, "poetry");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// Add transaction 3
    	transaction.ToDo = Add;
    	transaction.B.isbn = 2222222222;
   	strcpy(transaction.B.name, "New Book 2");
    	strcpy(transaction.B.author, "Author 3");
    	transaction.B.onhand = 7;
    	transaction.B.price = 20.00;
    	strcpy(transaction.B.type, "drama");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));
	
    	// Delete transaction 1
    	transaction.ToDo = Delete;
    	transaction.B.isbn = 333333333;
    	strcpy(transaction.B.name, "Book to Delete");
    	strcpy(transaction.B.author, "Author 4");
    	transaction.B.onhand = 0;
    	transaction.B.price = 0.0;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// Delete transaction 2
    	transaction.ToDo = Delete;
    	transaction.B.isbn = 999999999;
    	strcpy(transaction.B.name, "Nonexistent Book");
    	strcpy(transaction.B.author, "Author 5");
    	transaction.B.onhand = 0;
    	transaction.B.price = 0.0;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// ChangeOnhand transaction 1
    	transaction.ToDo = ChangeOnhand;
   	transaction.B.isbn = 1444444444;
   	strcpy(transaction.B.name, "Change Onhand Book");
    	strcpy(transaction.B.author, "Author 6");
    	transaction.B.onhand = 5;
    	transaction.B.price = 0.0;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// ChangeOnhand transaction 2
    	transaction.ToDo = ChangeOnhand;
    	transaction.B.isbn = 2888888888;
   	strcpy(transaction.B.name, "Nonexistent Book 2");
    	strcpy(transaction.B.author, "Author 7");
    	transaction.B.onhand = -10;
    	transaction.B.price = 0.0;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// ChangePrice transaction 1
    	transaction.ToDo = ChangePrice;
    	transaction.B.isbn = 2555555555;
    	strcpy(transaction.B.name, "Change Price Book");
    	strcpy(transaction.B.author, "Author 8");
    	transaction.B.onhand = 0;
    	transaction.B.price = 25.00;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	// ChangePrice transaction 2
    	transaction.ToDo = ChangePrice;
    	transaction.B.isbn = 3777777777;
    	strcpy(transaction.B.name, "Nonexistent Book 3");
    	strcpy(transaction.B.author, "Author 9");
    	transaction.B.onhand = 0;
    	transaction.B.price = 30.00;
    	strcpy(transaction.B.type, "fiction");
    	outFile.write((const char*)&transaction, sizeof(TransactionRec));

    	cout << "Test transaction file has been successfully generated." << endl;

    	outFile.close();
    	return 0;
}
