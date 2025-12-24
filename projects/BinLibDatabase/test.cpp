#include <iostream>
#include <fstream>
#include <cstring>

using namespace std;

typedef char String[25];

struct BookRec {
    	unsigned int isbn;
    	String name;
    	String author;
    	int onhand;
    	float price;
    	String type;
};

enum TransactionType { Add, Delete, ChangeOnhand, ChangePrice };

struct TransactionRec {
    	TransactionType ToDo;
    	BookRec B;
};

int main() {
    	ofstream transFile("extra.out", ios::binary);

    	TransactionRec trans1;
    	trans1.ToDo = Add;
    	trans1.B.isbn = 1234567890;
    	strcpy(trans1.B.name, "Book One");
    	strcpy(trans1.B.author, "Author One");
    	trans1.B.onhand = 10;
    	trans1.B.price = 19.99f;
    	strcpy(trans1.B.type, "fiction");
   	transFile.write((const char*)&trans1, sizeof(TransactionRec));

   	TransactionRec trans2;
    	trans2.ToDo = Add;
    	trans2.B.isbn = 1234567890;
    	strcpy(trans2.B.name, "Book One");
    	strcpy(trans2.B.author, "Author One");
    	trans2.B.onhand = 10;
    	trans2.B.price = 19.99f;
    	strcpy(trans2.B.type, "fiction");
    	transFile.write((const char*)&trans2, sizeof(TransactionRec));

    	TransactionRec trans3;
    	trans3.ToDo = Delete;
    	trans3.B.isbn = 2345678901;
    	strcpy(trans3.B.name, "Book Two");
    	strcpy(trans3.B.author, "Author Two");
    	trans3.B.onhand = 5;
    	trans3.B.price = 29.99f;
    	strcpy(trans3.B.type, "nonfiction");
    	transFile.write((const char*)&trans3, sizeof(TransactionRec));

    	TransactionRec trans4;
    	trans4.ToDo = Delete;
    	trans4.B.isbn = 999999999;
    	strcpy(trans4.B.name, "Book Nine");
    	strcpy(trans4.B.author, "Author Nine");
    	trans4.B.onhand = 0;
    	trans4.B.price = 0.0f;
    	strcpy(trans4.B.type, "fiction");
    	transFile.write((const char*)&trans4, sizeof(TransactionRec));

    	TransactionRec trans5;
    	trans5.ToDo = ChangeOnhand;
   	trans5.B.isbn = 3156789012;
    	strcpy(trans5.B.name, "Book Three");
    	strcpy(trans5.B.author, "Author Three");
    	trans5.B.onhand = 0;
    	trans5.B.price = 9.99f;
    	strcpy(trans5.B.type, "drama");
    	trans5.B.onhand = 5;
    	transFile.write((const char*)&trans5, sizeof(TransactionRec));

   	TransactionRec trans6;
    	trans6.ToDo = ChangeOnhand;
    	trans6.B.isbn = 1567890123;
    	strcpy(trans6.B.name, "Book Four");
    	strcpy(trans6.B.author, "Author Four");
    	trans6.B.onhand = 7;
    	trans6.B.price = 14.99f;
    	strcpy(trans6.B.type, "mystery");
    	trans6.B.onhand = -10;
    	transFile.write((const char*)&trans6, sizeof(TransactionRec));

    	TransactionRec trans7;
    	trans7.ToDo = ChangeOnhand;
    	trans7.B.isbn = 2999999999;
    	strcpy(trans7.B.name, "Book Nine");
    	strcpy(trans7.B.author, "Author Nine");
    	trans7.B.onhand = 0;
    	trans7.B.price = 0.0f;
    	strcpy(trans7.B.type, "fiction");
    	trans7.B.onhand = 5;
    	transFile.write((const char*)&trans7, sizeof(TransactionRec));

    	TransactionRec trans8;
    	trans8.ToDo = ChangePrice;
    	trans8.B.isbn = 2678901234;
    	strcpy(trans8.B.name, "Book Five");
    	strcpy(trans8.B.author, "Author Five");
    	trans8.B.onhand = 2;
    	trans8.B.price = 24.99f;
    	strcpy(trans8.B.type, "fiction");
    	trans8.B.price = 19.99f;
    	transFile.write((const char*)&trans8, sizeof(TransactionRec));

  

    	transFile.close();

    	return 0;
}
