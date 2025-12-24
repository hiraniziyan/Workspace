#include<iostream>
#include"dlist.h"
using namespace std;

void PrintMenu(char &sel);
void HeadInsert(DList<int>& list);
void TailInsert(DList<int>& list);
void AccessItem(DList<int>& list);
void FindAndMove(DList<int>& list, int item);
void Delete(DList<int>& list);
void PrintList(DList<int>& list);
void PrintLength(DList<int>& list);
void SortList(DList<int>& list);
void changeValue(DList<int>& list);

int main()
{
	//declare list
	DList<int> list;
	char sel;	
	
	//repeat until user quits program		
	do
	{
		//prints menu and asks for option
		PrintMenu (sel);
		
		//options
		switch (toupper(sel))
		{
			case 'H' : HeadInsert(list); break;
			case 'T' : TailInsert(list); break;
			case 'E' : list.makeEmpty(); break;
			case 'A' : AccessItem(list); break;
			case 'D' : Delete(list); break;
			case 'P' : PrintList(list); break;
			case 'L' : PrintLength(list); break;
			case 'S' : SortList(list); break;
			case 'C' : changeValue(list); break;
			case 'Q' : cout << "\tExiting Program...\n"; break;
			default : cout << "\tError. Try Again." << endl;
		}
	} while (toupper(sel) != 'Q');
}

void PrintMenu(char &sel)
{
	//Post: print menu and takes in user input for option
	cout << endl;
	cout << "|-----------------------------|" << endl;
	cout << "|------------Menu-------------|" << endl;
	cout << "|-----------------------------|" << endl;
	cout << "|                             |" << endl;
	cout << "| H: Insert item at front     |" << endl;
	cout << "| T: Insert item at back      |" << endl;
	cout << "| A: Access an item in list   |" << endl;
	cout << "| D: Delete an item in list   |" << endl;
	cout << "| P: Print the list           |" << endl;
	cout << "| L: Print the list's length  |" << endl;
	cout << "| S: Sort items in the list   |" << endl;
	cout << "| C: Change Value of an item  |" << endl;
	cout << "| Q: Quit the program         |" << endl;
	cout << "|                             |" << endl;
	cout << "|-----------------------------|" << endl;
	cout << "|                             |" << endl;
	cout << "| Please enter your choice:   |" << endl;
	cin >> sel;
}
void HeadInsert(DList<int>& list)
{
	//Pre: user has selected to H
	//Post: adds an item to beginning of the list
	
	//get user input for item to be added
	int item;
	cout << "\vItem to be Inserted Onto Head of List?" << endl;
	cin >> item;

	//if item is not already in list add it to front otherwise print duplicate message
	if(!list.inList(item))
	{
		list.insertHead(item);
		cout << "Done" << "\n\n";
	}	
	else
		cout << "Item Already Exists in List.  No Duplicates Allowed. \n\n";
	cin.ignore(80, '\n');
}

void TailInsert(DList<int>& list)
{
	//Pre: user has selected T
	//Post: item recieved is added to back of the list
	
	//take user input for item
	int item;
	cout << "\vWhat number would you like to insert at the end of the list?" << endl;
	cin >> item;
	
	//if item is not in list add to back of list else print duplicate message
	if(!list.inList(item))
	{
                list.appendTail(item);
		cout << "Done" << "\n\n";
	}
        else
                cout << "Item Already Exists in List.  No Duplicates Allowed. \n\n";
        cin.ignore(80, '\n');

}

void AccessItem(DList<int>& list)
{
	//Pre: user has selected A
	//Post: item moved to front if it is in list
	
	//if list is empty print message indicating empty list
	if(list.isEmpty())
		cout << "\vThe list is empty. A number must be inserted before it can be accessed." << endl;
	
	else
	{
		//get user input for item to be searched
		int item;
		cout << "\vEnter a Number : ";
		cin >> item;

		//Find and move item to the front
		FindAndMove(list, item);
	}
}

void FindAndMove(DList<int>& list, int item)
{
	//Pre: user has sent in item to be searched
	//Post: item moved to front if it is in list
	
	//if item is in list delete the item from current position and move it in front
	if(list.inList(item)) 
	{
		list.deleteItem(item);
		list.insertHead(item);
		cout << "Item found and successfully moved to the front!" << endl;
	}
	//item not in list
	else
		cout << "Item not in list" << endl;	
        
}

void Delete(DList<int>& list)
{
	//Pre: user has selected D 
	//Post: item taken from user input is deleted
	
	//display message if list is empty
	if(list.isEmpty())
		cout << "\vThe list is empty. You must insert a value before anything can be deleted." << endl;

	else
	{
		//get user input for item to be deleted
		int num;
		cout << "\vWhat number in the list would you like to delete?" << endl;
		cin >> num;
		
		//if item is not in list, print message
		if(!list.inList(num))
			cout << "\vThis number is not in the list";
		
		//delete item
		else
			list.deleteItem(num);
		cout << endl;
	}	

}

void PrintList(DList<int>& list)
{	
	//Pre: user has selected P
	//Post: list is printed if not empty
	
	//display message if list is empty
	if(list.isEmpty())
		cout <<"\vThe list is empty. A number must be inserted before it can be printed." << endl;
	
	//print list using .print() method
	else
	{
		cout << "\vPrinting list..." << endl;
		list.print();
	}
}

void PrintLength(DList<int>& list)
{
	//Pre: User has selected L
	//Post: Length of the list is printed
	
	cout <<"\vThe length of the list is " << list.lengthIs() << endl << endl;
}

void SortList(DList<int>& list)
{
	//Pre: User has selected S
	//Post: List is sorted from least to greatest
	
	//display message if list is empty
	if(list.isEmpty())
		cout << "\vThe list is empty. A number must be inserted before it can be sorted." << endl;

	//sort list using sort() method
	else
	{
		list.sort();
		cout << "\vItems have been succesfully sorted from least to greatest!" << endl;
	}
}

void changeValue(DList<int>& list)
{
	//Pre: User has selected C
	//Post: Value user wants to change has been changed to a new value
	
	if(list.isEmpty())
		cout << "\vThe list is empty. No values to be altered." << endl;
	//get user input for value to be changed an new value
	else
	{
		int num1;
		int num2;
		cout << "\vValue to be changed: ";
		cin >> num1;
		cout << "New Value: ";
		cin >> num2;

		if(list.inList(num2))
			cout << "New Value already exists within list therefore cannot be added." << endl;
	
		//rewrite the old value with new value
		else
			list.rewrite(num1,num2);
	}
}
