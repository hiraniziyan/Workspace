import java.util.*;
import java.io.*;

public class Personnel{
	//declare Scanner and employee arrayList
	private static Scanner input = new Scanner(System.in);
	private static ArrayList<Employee> employeeList = new ArrayList<>();

	//handles enter for scanner
	private static String enter;

	public static void main(String[] args) {
		//runs the program
		runDatabase();
	}

	private static void displayCommands() {
		//Pre: the database is open 
		//Post: shows user all commands
		System.out.println("-----------------------------------");
		System.out.println("|Command: n - New employee        |");
		System.out.println("|         c - Compute paychecks   |");
		System.out.println("|         r - Raise wages         |");
		System.out.println("|         p - Print records       |");
		System.out.println("|         s - Search for employee |");
		System.out.println("|         d - Download data       |");
		System.out.println("|         u - Upload data         |");
		System.out.println("|         q - Quit                |");
		System.out.println("-----------------------------------");		
	}

	private static void runDatabase() {
		//Pre: ArrayList has been declared
		//Post: User has inputted and dowloaded/uploaded Employees to their database
		char command = 0;

		//loop that goes until user has inputted q-quit
		do {	
			//display all commands
			displayCommands();
		
			//prompt user to enter command
			System.out.print("Enter command: ");	
			command = input.nextLine().charAt(0);
			
			//execute command using switch statement
			switch(command) {
			case 'n':
			case 'N': addEmployee();
			break;
			case 'c':
			case 'C': computePayChecks();
			break;
			case 'r':
			case 'R': raiseWage();
			break;
			case 'p':
			case 'P': 
				for(int location = 0; location < employeeList.size(); location++){
					printRecord(location);
				}
				break;
			case 'd':
			case 'D': downloadData();
			break;
			case 'u':
			case 'U': uploadData();
			break;
			case 's':
			case 'S': searchList();
			break;
			case 'q':
			case 'Q': System.exit(0);
			break;
			default : System.out.println("Command was not recognized; please try again.");
			}
		} while (command != 'q');

	}

	private static void addEmployee() {
		//Pre: User has inputted N/n for new Employee
		//Post: New employee with name/employeeType/pay has been added and sorted in the database

		//prompt user for name of Employee
		System.out.print("Enter name of new employee: ");
		String name = input.nextLine();
		
		//loop that goes until user has inputted valid employeeType
		char employeeType = '0';
		do {
			//prompt user to enter if employee is paid hourly or is salaried
			System.out.print("Hourly (h) or salaried (s): ");
			employeeType = input.nextLine().charAt(0);

			//if type s, make user enter annual salary and add employee to arrayList
			if (employeeType == 's' || employeeType == 'S') {
				System.out.print("Enter annual salary: ");
				double salary = input.nextDouble();
				enter = input.nextLine();
				Employee employee = new SalariedEmployee(name, salary);
				employeeList.add(employee);
				break;
			}
			
			//if type h, make user enter wage and add employee to arrayList
			else if (employeeType == 'h' || employeeType == 'H') {
				System.out.print("Enter hourly wage: ");
				double wage = input.nextDouble();
				enter = input.nextLine();
				Employee employee = new HourlyEmployee(name, wage);
				employeeList.add(employee);
				break;
			}
			
			//error message for employeeType invalid
			else {
				System.out.println("Input was not h or s; please try again.");
			}
		}while (employeeType != 'h' || employeeType != 'H' || employeeType != 's' || employeeType != 'S');

		//sorts the employee in the arrayList
		sortList();


	}

	private static void computePayChecks() {
		//Pre: Employees are in the arrayList and user has entered command C/c
		//Post: computes the employee's payCheck based on the hours worked

		//loop to go through arrayList
		for (int i = 0; i < employeeList.size(); i++) {
			//prompt user for hours worked
			System.out.print("Enter number of hours worked by " + employeeList.get(i).getName() + ": ");
			int hours = input.nextInt();
			enter = input.nextLine();

			//print pay
			System.out.printf("Pay: $%.2f\n", employeeList.get(i).computePay(hours));

		}
	}


	private static void raiseWage() {
		//Pre: Employees have been added to arrayList and user has inputted the command r/R
		//Post: increases the employee's wage/salary and print the information out
		
		//Promt user to enter a percerntage increase
		System.out.print("Enter percentage increase: ");
		double percent = input.nextDouble();
		enter = input.nextLine();
		
		//go through the employee ArrayList increases salary/wage by inputted percent
		for (int i = 0; i < employeeList.size(); i++) {
			employeeList.get(i).increaseWage(percent);
			printRecord(i);
		}

	}

	private static void printRecord(int location) {
		//Pre: Employee location in the arraylist has been passed
		//Post: the employees information is printed
		System.out.println(employeeList.get(location).toString());
	}

	private static void downloadData() {
		//Pre: Employees have been added to arrayList
		//Post: the information gets sent to a binary file for the next time the program is run
		System.out.println("Downloading data...");
		for(int location = 0; location < employeeList.size(); location++){
			printRecord(location);
		}
		String fileName = "Employee.dat";
		try {
			FileOutputStream fileOut = new FileOutputStream(fileName);
			ObjectOutputStream out = new ObjectOutputStream(fileOut);
			out.writeObject(employeeList);
			out.close();
		}
		catch (IOException e) {
			System.out.println(e.getMessage());
		}
	}


	@SuppressWarnings("unchecked")
	private static void uploadData() {
		//Pre: employee(s) have been added to arrayList and downloaded into binary file
		//Post: prints the current records of the employees in the database
		String fileName = "Employee.dat";
		try {
			FileInputStream fileIn = new FileInputStream(fileName);
			ObjectInputStream in = new ObjectInputStream(fileIn);
			employeeList = (ArrayList<Employee>) in.readObject();
			in.close();
		}
		catch (IOException e) {
			System.out.println(e.getMessage());
		}
		catch (ClassNotFoundException e)
		{
			System.out.println(e.getMessage());
		}
		for (int i = 0; i < employeeList.size(); i++)
			System.out.println(employeeList.get(i));

	}
	
	private static void sortList() {
		//Pre: employee has been added to array List
		//Post: employee has been sorted in the arrayList by a bubble sort algorithm
		int currentMinIndex;
		Employee temp;
		for (int i = 0; i < employeeList.size()-1; i++) {
			currentMinIndex = i;
			for (int j = currentMinIndex + 1; j < employeeList.size(); j++) {
			if (employeeList.get(currentMinIndex).getName().compareTo(employeeList.get(j).getName()) > 0) {
					currentMinIndex = j;
				}
			}
			if (currentMinIndex != i) {
				temp = employeeList.get(i);
				employeeList.set(i, employeeList.get(currentMinIndex));
				employeeList.set(currentMinIndex, temp);
			}
		}
	}

	private static void searchList() {
		//Pre: Employee ArrayList has been sorted
		//Post: returns the information of employee user has searched for using binary search algorithm

		//ask user for employee name
		System.out.print("Enter employee name: ");
		String name = input.nextLine();

		//binary search
		int first = 0, last = employeeList.size()-1, middle, location;
		boolean found = false;
		do
		{
			middle = (first + last) / 2;
			if (name.equals(employeeList.get(middle).getName()))
				found = true;
			else if (name.compareTo(employeeList.get(middle).getName()) < 0)
				last = middle - 1;
			else
				first = middle + 1;
		} while ( (! found) && (first <= last) );
		location = middle;

		if (location == -1) {
			System.out.println("Employee not found...");
		}
		else {
			printRecord(location);
		}

	}

}

