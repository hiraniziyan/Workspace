#include <cstddef> 
#include <iostream>
using namespace std;

template<class ItemType>
struct NodeType
{
	ItemType info;
	NodeType<ItemType>*	next;
	NodeType<ItemType>*	back;
};

template <class ItemType>		
DList<ItemType>::DList()		// Class constructor
{
    length = 0;
    head = NULL;
}

template <class ItemType>
DList<ItemType>::~DList   ()		
{
	// Post: List is empty; All items have been deallocated.
	makeEmpty(); 
}

template <class ItemType>
void DList<ItemType>::makeEmpty()
{
        // Post: List is empty; all items have been deallocated.

	NodeType<ItemType>* currentPtr = head;

	while(head != NULL) 
	{
		currentPtr = head;
		head = head -> next;

		delete currentPtr;
		currentPtr = NULL; 
	}
	length = 0;

}

template <class ItemType>
void DList<ItemType>::deleteItem (ItemType item)	
{
	//  Pre :  item to be deleted is passed in via parameter 
        // Post :  item is deleted if it exists in list
	if (inList(item))
        	deleteLocation(location(item));
}

template <class ItemType>
bool DList<ItemType>::inList (ItemType item) const
{
	//  Pre :  item to be located is passed in via parameter 
        // Post :  function returns bool value if item is found 

	if (head == NULL) 	
                return false;
	
	NodeType<ItemType>* locPtr = head;
        while(locPtr != NULL)	     
        {
        	if (locPtr -> info == item)	
                	return true;

		locPtr = locPtr -> next;         
        }
        return false;	

}

template <class ItemType>
bool DList<ItemType>::isEmpty() const		
{
	// Post : function returns true if list is empty, false otherwise
	return (head == NULL);
	
}

template <class ItemType>
void DList<ItemType>::print() const	
{
	// Pre  : List is not empty 
	// Post : Items in List have been printed to screen

        NodeType<ItemType>* locPtr = head;	
	
	for (int i = 1; i <= length; i++) 	
        {
              	cout << i << ":     " << locPtr -> info << endl;
                locPtr = locPtr -> next;
        }
	cout << "End of List" << endl;

}
	
template <class ItemType>
void DList<ItemType>::insertHead(ItemType item)	
{
	//  Pre : item to be inserted is passed in via parameter
        // Post : item is inserted at head of list;  Former first node is 
        //        linked back to this new one via double link;
        //        Length incremented;  Special case handled if list is empty

        NodeType<ItemType>* newNode = new NodeType<ItemType>;
	newNode -> info = item;
	newNode -> back = NULL;

	if(head == NULL)
	{
		head = newNode;
		newNode -> next = NULL;
	}
	else
	{
		newNode -> next = head;
		head -> back = newNode;
		head = newNode;
	}
	
	
	length++;	
}
	

template <class ItemType>
void DList<ItemType>::appendTail(ItemType item)
{
	//  Pre :  item to be inserted is passed in via parameter
        // Post :  item is added to tail of list; Former last node
        //         is linked to this new one via double link
        
        NodeType<ItemType>* newNode = new NodeType<ItemType>;
	newNode -> info = item;
	newNode -> next = NULL;
	
	if(head == NULL)
	{
		head = newNode;
		newNode -> back = NULL;
	}	
	
	else
	{
		newNode -> back = last();
		newNode -> back -> next = newNode;
	}

	
	length++;

}

template <class ItemType>
int DList<ItemType>::lengthIs() const	
{
	// Post : Function returns current length of list 
	return length;
}

template <class ItemType>
NodeType<ItemType>* DList<ItemType>::location(ItemType item) const	
{
	//  Pre : item to be located is passed in via parameter 
        // Post : function returns address of item being searched for --
        //        if not found, NULL is returned
	
	if (head == NULL)	
		return NULL;
	
	NodeType<ItemType>* locPtr = head;
	while(locPtr != NULL)
	{
		if (locPtr -> info == item)
			return locPtr;
		else
			locPtr = locPtr -> next;
	}

	
	return NULL;	
}

template <class ItemType>
NodeType<ItemType>* DList<ItemType>::last() const	
{
	// Post : Function returns location of current last item in list
	
	
	if (head == NULL)	
                return NULL;

	NodeType<ItemType>* lastNode = head;
        while(lastNode -> next != NULL)
		lastNode = lastNode -> next;

        return lastNode; 

	
}

template <class ItemType>
void DList<ItemType>::deleteLocation (NodeType<ItemType>* delPtr)	
{

	//  Pre : Item to be deleted exits in list and its location
        //        is passed in via parameter
                   
	// Post : Location passed in is removed from list;  Length
        //        is decremented, and location is deallocated 

        // Special Cases Handled for Deleting Only One Item in List,
        // The Head Item of List, and the Tail Item of List
        if (length == 1) 
		head = NULL;
	
	else if (delPtr == head)	
	{
		head = head -> next;
		head -> back = NULL;
	}
	
	else if (delPtr -> next == NULL)
		delPtr -> back -> next = NULL;
	else						
	{
		delPtr -> back -> next = delPtr -> next;
		delPtr -> next -> back = delPtr -> back;
	}
	
	delete delPtr;		
	delPtr = NULL;
	length--;	


}

template <class ItemType>
void DList<ItemType>::sort() 
{
	//Pre: list is initialized
	//Post: list is sorted from least to greatest using bubble sort
	
	NodeType<ItemType>* currLoc;	   
	
	for(int i = 0; i < length; i++) 	
	{	
		currLoc = head -> next; 	

		while (currLoc != NULL)  	
		{
			if (currLoc -> back -> info > currLoc -> info) 	    
			{
				ItemType temp = currLoc -> info;
				currLoc -> info = currLoc -> back -> info;
				currLoc -> back -> info = temp;
			}
			currLoc = currLoc -> next; 	
		}
		
	}

}

template <class ItemType>
void DList<ItemType>::rewrite(ItemType item1, ItemType item2)
{
	//Pre: List is initialized
	//Post: item2 stored in node because item2
	location(item1) -> info = item2;

}
