import java.util.*;
import java.io.*;

public class Database{
	//class variables for scanner and hitting enter
	private static Scanner input = new Scanner(System.in);
	private static String enter;

	//declare ArrayList
	private static ArrayList<LibraryBook> books = new ArrayList<>();

	public static void main(String[] args) throws IOException{
		clearScreen();		

		//open database
		String fileName = open();

		//initialize and sort arrayList with file
		fill(fileName);

		//display menu and run program
		displayMenu();

	}
	
	private static String open(){
		//Pre: Have ArrayList declared
		//Post: Initialize ArrayList from the file picked by user and display GreatBooks menu

		//display header
		System.out.println("\t\t\tTHE BOOK SEARCH PROGRAM");
		System.out.println("---------------------------------------------------------------------\n");
		System.out.println("\tWhat file is your book data stored in?\n");

		//go until valid file has been entered
		while(true){
			//show files
			System.out.println("\tHere are the files in the current directory: \n");
			System.out.println("\tlibrary.dat play.dat\n");

			//ask for file name
			System.out.print("\tFilename: ");
			String fileName = input.nextLine(); 
			
			//return fileName
			if(fileName.equals("library.dat") || fileName.equals("play.dat")){
				return fileName;
			}

			else {
				//check for invalid input
				System.out.println("\n\t** Can't open input file. Try again. **");
			
			}
		}
	
	}

	private static void fill(String file){
		//Pre: Filename has been inputted by user
		//Post: fills the ArrayList with the file books and prints the number of books

		//fill and sort arrayList with file attributes
		int amtBooks = inputBooks(file);

		//print amount of books in arrayList
                System.out.println("\n\tA total of " + amtBooks + " books have been input & sorted by title.\n");
                System.out.println("\tPlease hit return to continue...");
                enter = input.nextLine();
                clearScreen();
	}

	private static int inputBooks(String inputFile) {
		//Pre: ArrayList declared and user chosen a File to get initialize array with
		//Post: ArrayList is initialized and sorted with LibraryBook objects

		int numBooks = 0;
		try {
			//read in file
			Scanner in = new Scanner(new File(inputFile));
			
			//go until there are no more books in the file
			while(in.hasNext()){
				
				//store information in one category until a semi-colon
				Scanner element = new Scanner(in.nextLine()).useDelimiter(";");
				
				//get all values for a certain book
				String title = element.next();
				String name = element.next();
				int copyright = element.nextInt();
				double price = element.nextDouble();
				String genre = element.next();
				
				//add all information as a LibraryBook object into ArrayList
				books.add(new LibraryBook(title,name,copyright,price,genre));
				numBooks++;
			}
			//sort the books
			sort();

		}
		
		//check if file does not exist
		catch (IOException e) {
			System.out.println(e.getMessage());
		}
		return numBooks;
	}

	private static void sort() {
		//Pre: ArrayList has been initialized with LibraryBook objects
		//Post: LibraryBook objects have been sorted Alphabetically by title through linear Sort

		int currentMinIndex;
		LibraryBook temp;
		
		//selection sort
		for (int i = 0; i < books.size()-1; i++) {
			currentMinIndex = i;
			
			//go through each element 
			for (int j = currentMinIndex + 1; j < books.size(); j++) {

				//check which title comes first alphabetically
				if (books.get(currentMinIndex).getTitle().compareTo(books.get(j).getTitle()) > 0) {
					currentMinIndex = j;
				}
			}
			
			//swap current min book and new min book
			if (currentMinIndex != i) {
				temp = books.get(i);
				books.set(i, books.get(currentMinIndex));
				books.set(currentMinIndex, temp);
			}
		}

	}

	private static void displayMenu() {
		//Pre: LibraryBooks objects sorted in ArrayList from a file user has chosen
		//Post: displays interactive Menu for user to use database

		while (true) {
			//display menu
			System.out.println("\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
			System.out.println("\t\tTHE GREAT BOOKS SEARCH PROGRAM");
			System.out.println("\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
			System.out.println("\t1) Display all book records");
			System.out.println("\t2) Search for a book");
			System.out.println("\t3) Exit search program");
			System.out.println("\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
			
			//ask for a command
			System.out.print("\tPlease enter your choice > ");
			String command = input.nextLine();
		
			//check if command is display, search, or exit
			switch(command) {
			
			//if display then print each book one by one until no more books or user goes back to menu
			case "1" : displayAllBooks();
			break;
			
			//if search then ask what user wants to search for, search database for book, and display all values of book
			case "2" : searchForBook();
			break;
			
			//if exit then stop program with an exit message
			case "3" : System.out.println("\tHave A Wonderful Day! :)");
				   System.exit(0);
			break;
			
			//if none of the commands, repromt for command
			default : System.out.print("\tYou have made an error. Please try again."
					 + "\n\tPlease Hit Return to Continue...");
				  enter = input.nextLine();
				  clearScreen();
			}
		}

	}

	private static void displayAllBooks(){
		//Pre: ArrayList of books has been initialized and user has chosen to display all books
		//Post: Prints all books one by one
		clearScreen();
                for (int i = 0; i < books.size(); i++) {
			//print current book record
                        printRecord(i);

                       	System.out.print("\n\tPlease Hit Return to Continue or M for Menu...");
			String command = input.nextLine();
			
			//if user chooses to go back to menu
                        if (command.equalsIgnoreCase("M")) {
                                 clearScreen();
                                 break;
                        }
                        clearScreen();
                }
	
	}

	private static void searchForBook(){
		//Pre: User has chosen to search for book
		//Post: prints out attributes of chosen book

		//asks user what they want to search for or if they want to go back to menu
                int search = searchAttribute();
                System.out.print("Hit M to go back to Menu: ");
                int location;
                do {
			//asks user for the search
                        String searchAttribute = input.nextLine();
                        //if user wants to go back to menu
                        if (searchAttribute.equalsIgnoreCase("M")){
				break;
                        }

                        clearScreen();

                        //check if searchAttribute is in the arrayList, if it is print the record for the book, else return -1
                        location = search(searchAttribute, search);

                        //if no book was found
                        if (location == -1) {
                                 System.out.print("\tNot found. Please try again or hit M to return to menu... > ");
                        }

                 } while (location == -1);
		clearScreen();
	
	}

	private static int searchAttribute() {
		//Pre: User has chosen to search for book
		//Post: return how user wants to search and prompts user to search
		clearScreen();

		//display searching menu
		System.out.println("\t1) Search by Title");
		System.out.println("\t2) Search by Author");
		System.out.println("\t3) Search by Year");
		System.out.println("\t4) Search by Budget");
		System.out.println("\t5) Search by Genre\n");
		String search;
		boolean valid = false;
		
		//go until a valid option is inputted
		do {
			System.out.print("\tWhat do you want to search by > ");
			search = input.nextLine();
			
			//check how user wants to search for book
			switch(search) {
			case "1": System.out.print("\tEnter book title. ");
			valid = true;
			return 1;
			case "2": System.out.print("\tEnter Author's name (Last, First). ");
			valid = true;
			return 2;
			case "3": System.out.print("\tEnter Copyright Year. ");
			valid = true;
			return 3;
			case "4": System.out.print("\tEnter Budget. ");
			valid = true;
			return 4;
			case "5": System.out.print("\tEnter Genre. ");
			valid = true;
			return 5;
			default: System.out.println("\tInvalid attribute. Try Again. ");
			break;
			}
		}while (!valid);

		return 0;

	}
	
	private static int search(String searchAttribute, int attribute) {
		//Pre: user has inputted what they are searching for and with, arrayList is sorted
		//Post: prints the records for the users search

		//Linear search
		boolean menu = false; int index = 0; int location = -1;
		while ((!menu) && (index < books.size())){
		
		//check what attribute the user searched for and prints the book/books
		switch (attribute) {
			//case 1,2, and 3 print the specific book which the user searched for or if the search contains the keywords for the title/author
			case 1 :
				 if((books.get(index).getTitle().equalsIgnoreCase(searchAttribute) || books.get(index).getTitle().contains(searchAttribute)) && !isBlank(searchAttribute)) {
					location = index;
					printRecord(location);

					//continue/ back to menu
					System.out.print("\n\tHit return to continue or M for menu...");
					enter = input.nextLine();
					clearScreen();
					if (enter.equalsIgnoreCase("M")){
						menu = true;
					}
				}
			break;
			case 2: 
 				if ((books.get(index).getAuthor().equalsIgnoreCase(searchAttribute) || books.get(index).getAuthor().contains(searchAttribute)) && !isBlank(searchAttribute)) {
 					location = index;
					printRecord(location);
					
					//continue/back to menu
					System.out.print("\n\tHit return to continue or M for menu...");
					enter = input.nextLine();
					clearScreen();
					if (enter.equalsIgnoreCase("M")){
                                                menu = true;
                                        }
				}
			break;
			case 3: 
				try {
					//convert string to int
					int year = Integer.parseInt(searchAttribute);
					if(year == books.get(index).getCopyright()) {
						location = index;
						printRecord(location);
			
						//continue/back to menu
						System.out.print("\n\tHit return to continue or M for menu...");
						enter = input.nextLine();
						clearScreen();
						if (enter.equalsIgnoreCase("M")){
                                                	menu = true;
                                        	}

					}
				}
				//check if input is not a valid year
				catch(NumberFormatException e) {
					System.out.println("\tInvalid Copyright year.");
					return -1;
				}
			break;

			//case 4 and 5 prints all records with inputted attribute
			case 4: 
				try {
					//convert string to int
					double budget = Double.parseDouble(searchAttribute);

					//find any book within user's budget
					if (budget >= books.get(index).getPrice()) {
						location = index;
						printRecord(location);
	
						//continue/back to menu
						System.out.println("\n\tHit return to continue or M for menu...");
						enter = input.nextLine();
						clearScreen();
						if (enter.equalsIgnoreCase("M")){
                                                        menu = true;
                                                }						
					}
				}
				//check if input is not a valid amount
				catch (NumberFormatException e) {
					System.out.println("\tInvalid amount.");
					return -1;
				}
			break;

			case 5: 
				if (searchAttribute.equals(books.get(index).getGenre())) {
					location = index;
					printRecord(location);	
		
					//continue/back to menu
					System.out.println("\n\tHit return to continue or M for menu...");
                                        enter = input.nextLine();
                                        clearScreen();
					if (enter.equalsIgnoreCase("M")){
                                                        menu = true;
                                        }
				}
		}
			index++;
        	}
		return location;
       }
	
	private static void printRecord(int location) {
		//Pre: ArrayList initialized with LibraryBook objects and a location of the Book in the list has been passed in as parameter
		//Post: Prints record of the book

		System.out.println("\tRecord #" + (location + 1) + " :\n");
		System.out.println("\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
		System.out.printf("\t%20s%20s \n", "Title: ", books.get(location).getTitle());
		System.out.printf("\t%20s%20s \n", "Author's Name: ", books.get(location).getAuthor());
		System.out.printf("\t%20s%20d \n", "Copyright: ", books.get(location).getCopyright());
		System.out.printf("\t%20s%20.2f\n", "Price: ",  books.get(location).getPrice());
		System.out.printf("\t%20s%20s\n\n", "Genre: ", books.get(location).getGenre());
       	        System.out.println("\t^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");


	}	
	
	//clears the screen when called
	private static void clearScreen(){
		System.out.println("\u001b[H\u001b[2J");
	}
	
	//checks if string is blank
	private static boolean isBlank(String s){
		String space = "";
		for (int i = 0; i < s.length(); i++){
			space += " ";
		}
		
		if(s.equals(space) || s.equals("\t") || s.equals ("\n")){
			return true;
		}
		return false;
	}	
}

