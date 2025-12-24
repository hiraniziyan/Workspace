
using namespace std;

template <class ItemType>
struct NodeType;

template <class ItemType>
class DList 
{
public :
    DList ();		// Constructor
    ~DList   ();  	// Destructor	

    // Public Operations
    void makeEmpty (); 
    void deleteItem (ItemType item);
    bool inList (ItemType item) const;	
    bool isEmpty () const;  
    void print() const; 
    void insertHead (ItemType item); 
    void appendTail (ItemType item); 
    int lengthIs() const;
    void sort();
    void rewrite(ItemType item1, ItemType item2);

private :
    // Private Attributes of a DList Object 
    NodeType<ItemType>* head;
    int length;

    // Functions Called Solely By Public Functions, Not The Client 
    NodeType<ItemType>* location(ItemType item) const;
    NodeType<ItemType>* last() const; 
    void deleteLocation (NodeType<ItemType>* delPtr);
};

#include "dlist.cpp"
