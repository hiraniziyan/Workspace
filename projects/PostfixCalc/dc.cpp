#include<iostream>
#include<cstring>
#include<cstdlib>
#include<cmath>
#include "stack.h"
using namespace std;

void runCalculator(Stack<int> & dcStack, string inputLine);
void checkCommand(Stack<int> & dcStack, char command);
void printStack(Stack<int> dcStack); 
void reverse(Stack<int> & dcStack); 
void add(Stack<int> & dcStack);
void subtract(Stack<int> & dcStack); 
void multiply(Stack<int> & dcStack);
void divide(Stack<int> & dcStack); 
void remainder(Stack<int> & dcStack); 
void factorial(Stack<int> & dcStack);
void power(Stack<int> & dcStack);

int main()
{
	
	Stack<int> dcStack;	//declare stack
	string inputLine; 	
	
	while(getline(cin, inputLine))		//get input until user stops program
		runCalculator(dcStack, inputLine);	//input values to stack and perform command or operations
		
	return 0;
}

void runCalculator(Stack<int> & dcStack, string inputLine)
{
	//Pre: Input Line is taken from user
	//Post: Inputs integers into stack and performs all operations
	
	int stringLen = inputLine.length();

	for (int i = 0; i < stringLen; i++)			//go through entire string
	{
		try
		{
	
			if (isdigit(inputLine[i]) || (inputLine[i] == '_' && i + 1 < stringLen && isdigit(inputLine[i+1] )))	//check if character is a digit or an underscore
			{
				string numString = "";				//declare string and make it hold current character
				
				numString += inputLine[i];			

				while(i + 1 < stringLen && isdigit(inputLine[i+1])) //keep adding to the string from the input until the  
					numString += inputLine[i++ + 1];	    //next char is not a digit, and increment i
				
				(numString[0] == '_') ?        //check if string contains '_', 		     //if it does then substring out the '_' 
					dcStack.push(atoi(numString.substr(1, numString.length() - 1).c_str()) * -1) //and push the neg value into stack
							:
					dcStack.push(atoi(numString.c_str()));					     //else push the value into stack
			}

			else 							//otherwise check what command has been entered	
				checkCommand(dcStack, inputLine[i]);

		} //end try

                catch(Overflow exc)						//catch exception if it occurs and print error message
                {
                        cout << "Illegal Push -- Stack is Full." << endl;
                }
			
	}

}

void checkCommand(Stack<int> & dcStack, char command)
{
	//Pre: A character that is not a digit has been sent through
	//Post: Runs the command/operation that was sent through if valid
	
	try
	{
		switch (command)	//checks the command and looks at what method to call
		{
			case ' ' :                                      	   //if ' ' char is sent through skip over it
                                break;
                        case 'p' : cout << dcStack.top() << endl;       	   //print the top of the stack
                                break;	
                        case 'n' : cout << dcStack.topAndPop() << "  "; 	   //print and pop top of the stack
                                break;
                        case 'f' : printStack(dcStack);                    	   //print entire stack
                                break;
                        case 'c' : dcStack.makeEmpty();                 	   //clears the stack of all contents
                                break;
                        case 'd' : dcStack.push(dcStack.top());         	   //duplicates the top value of stack by pushing the top in again
                                break;
                        case 'r' : reverse(dcStack);            		   //reverses the first two elements of the stack
                                break;
			case '+' : add(dcStack);				   //adds the two top elements of the stack 
				break;
                        case '-' : subtract(dcStack);				   //subtracts the  top of the stack from second top
				break;
                        case '*' : multiply(dcStack);    	                   //multiplies the top two elements of a stack and pushes
                                break;
                        case '/' : divide(dcStack);          			   //divides top of the stack from second top and pushed quotient to top
                                break;
                        case '%' : remainder(dcStack);        			   //divides top of the stack from second top and pushes remainder to top
                                break;
			case '!' : factorial(dcStack); 				   //takes the factorial of the top element and pushes it to the top
				break;
			case '^' : power(dcStack);				   //raises the second top of the stack to the power of the top of the stack
				break;
			default: throw DataError{}; 				   //throws error if unknown command is entered
		}
	}
	catch(Underflow exc)		//error message for empty stack
	{
		cout << "Illegal Pop -- Stack is Empty." << endl;
	}
	catch(Overflow exc)		//error message for full stack
	{
		cout << "Illegal Push -- Stack is Full." << endl;
	}
	catch(DataError exc)		//error message for unknown expression
        {
                cout << "Exception -- You have entered an invalid expression.  Please re-enter." << endl;
        }
		
}

void printStack(Stack<int> dcStack)
{
	//Pre: User has inputted 'f'
	//Post: whole stack is printed if not empty
	
	while(!dcStack.isEmpty())	//loop through stack until it is not empty
		cout << dcStack.topAndPop() << endl;	//print and pop the top
}

void reverse(Stack<int> & dcStack)
{
	//Pre: user has inputted r
	//Post: Switches the first two elements in the stack
	
	int num1 = dcStack.topAndPop();		//get top of stack
	int num2 = dcStack.topAndPop();		//get second top

	dcStack.push(num1);			//push the first top in first
	dcStack.push(num2);			//push the second top in next
}

void add(Stack<int> & dcStack)
{
        //Pre: User has inputted '+'
        //Post: adds the two top elements of the stack
        
        int num1 = dcStack.topAndPop();         //get top of the stack and pop
        int num2 = dcStack.topAndPop();         //get new top and pop
        dcStack.push (num2 + num1);             //add the two and push onto top of stack
}
       

void subtract(Stack<int> & dcStack)
{
	//Pre: User has inputted '-'
	//Post: subtracts the  top of the stack from second top
	
        int num1 = dcStack.topAndPop();		//get top of the stack and pop
	int num2 = dcStack.topAndPop();		//get new top and pop
        dcStack.push (num2-num1);		//subtract the second num from first
}

void multiply(Stack<int> & dcStack)
{
	 //Pre: User has inputted '*'
	 //Post: multiplies the top two elements in the stack

	int num1 = dcStack.topAndPop();         //get top of the stack and pop
        int num2 = dcStack.topAndPop();         //get new top and pop
        dcStack.push (num2*num1);		//multiply the two
}

void divide(Stack<int> &  dcStack)
{
	//Pre: the user has inputted '/'
	//Post: pops the two top values and gets quocient and pushes quocient to top, and throws error if stack has less than 2 numbers
	try
	{
		if (dcStack.top() == 0)			//throw a DivisionByZero error if the divisor is 0
			throw DivisionByZero{};

		else					//compute quocient
		{
			int num1 = dcStack.topAndPop();
       			int num2 = dcStack.topAndPop();
			dcStack.push (num2 / num1);
		}
	}//end try
	catch(DivisionByZero exc)			//show error message
	{
		cout << "Division By Zero Exception -- Stack Unchanged." << endl;
	}

}

void remainder(Stack<int> & dcStack)
{
	//Pre: the user has inputted '%'
	//Post: pops the two top values and gets remainder pushes remainder to top, and throws error if stack has less than 2 numbers
	try
	{
		if (dcStack.top() == 0)			//throw a DivisionByZero error if the divisor is 0
                	throw DivisionByZero{};
	
        	else					//compute remainder
        	{	
                	int num1 = dcStack.topAndPop();
                	int num2 = dcStack.topAndPop();
                	dcStack.push (num2 % num1);	
        	}
	}//end try
	catch(DivisionByZero exc)			//show error message
	{
		cout << "Division By Zero Exception -- Stack Unchanged." << endl;
	}
}

void factorial(Stack<int> & dcStack)
{
	//Pre: the user has inputted '!'
	//Post: pops the top value and pushes its factorial to top
	
	int num = dcStack.topAndPop();		//get the top of the stack and pops it

	if (num < 0)		//if num is negative print error message		
		cout << "Cannot take factorial of Negative Number." << endl;
	else if (num == 0)	//0! = 1
		dcStack.push(1);
	else 			//calculate factorial
	{	
		int factorial = 1;
		for (int i = 1; i <= num; i++)	//loop from i = 1 to i = num
			factorial *= i;		//keep multiplying the variable by i

		dcStack.push(factorial);	//push the factoial onto stack
	}
}

void power(Stack<int> & dcStack)
{
	//Pre: user has inputted '^'
	//Post: raises the second top(base) to the top(exponent) and pushes the power into the stack
	
	if (dcStack.top() < 0)	//error message if exponent is negative
	{
		cout << "Calculator only supports Positive Exponents. Stack remains unchanged." << endl;
		return;
	}	

	int exponent = dcStack.topAndPop();	//gets the top of stack and pops it; this number is the exponent
	int base = dcStack.topAndPop();		//gets the new top and pops it; this number is the base

	dcStack.push((int) pow(base, exponent));	//raise the base to the exponent and push it onto the stack
}
