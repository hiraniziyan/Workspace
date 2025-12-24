
@SuppressWarnings("unchecked")
public class Queue implements QueueInterface { // A Queue class built under the hood as a circular linked list.
  private Node lastNode;  // Points to item in rear.  The next field of lastNode always points to front of the queue.
  
  public Queue() {
    lastNode = null;   
  }  // end default constructor
  
  // queue operations:
  public boolean isEmpty() {
        return (lastNode == null);
  }  // end isEmpty

  public void dequeueAll() {
    lastNode = null;
  }  // end dequeueAll

  public void enqueue(Object newItem) {

    // INSERT YOUR CODE HERE to handle 2 cases: when queue is empty and when it is not empty
    //declare new Node   
    Node newNode = new Node(newItem);
    
    //if Queue is empty then make new node circular by setting it to itself
    if(isEmpty()){
	newNode.setNext(newNode);
    }

    //else set newNode to the node after last and setNext of lastNode to newNode
    else{
	newNode.setNext(lastNode.getNext());
	lastNode.setNext(newNode);
    }
    //make lastNode the newNode because it is a queue, so nodes get added to back
    lastNode = newNode;
  }
 

  public Object dequeue() throws QueueException {

     // INSERT YOUR CODE HERE to handle 3 cases: when queue is empty, has one item, and has more than one item
     //if queue is empty, then throw exception
     if(isEmpty()){
	throw new QueueException("QueueException on dequeue: "+
                   "Queue empty");
     }
     //else if queue has one item, make the node null
     else if(lastNode == lastNode.getNext()) {
	Object item = lastNode.getItem();
	lastNode = null;
	return item;
     }
     //else set the lastNode to the one after the first node
     else{
	Object item = lastNode.getNext().getItem();
	lastNode.setNext(lastNode.getNext().getNext());
	return item;
     }
  }
 
  public Object peek() {
    return lastNode.getNext().getItem();
  }

  public Object front() throws QueueException {
    if (!isEmpty()) {
      Node firstNode = lastNode.getNext();
      return firstNode.getItem();
    }
    else {
      throw new QueueException("QueueException on front:"
                             + "queue empty");
    }
  }

  public Object clone() throws CloneNotSupportedException
  {
	boolean copied = false;
        Queue copy = new Queue();
        Node curr = lastNode, prev = null;
        while ( (! copied) && (lastNode != null) )
        {
                Node temp = new Node(curr.getItem());
                if (prev == null)
                        copy.lastNode = temp;
                else
                        prev.setNext(temp);
                prev = temp;
                curr = curr.getNext();
		copied = (lastNode == curr);
        }
	prev.setNext(copy.lastNode);
        return copy;
  }
} // end Queue
