import java.io.Serializable;

@SuppressWarnings("serial")
abstract class Employee implements Serializable {
	//private instance variables
	private String name;
	private double wage;
	
	//Employee constructor
	protected Employee(String name, double wage){
		this.name = name;
		this.wage = wage;
	}

	//getters and setters for name and wage
	public void setName(String name) {
		this.name = name;
	}

	public void setWage(double wage) {
		this.wage = wage;
	}

	public String getName() {
		return name;
	}

	public double getWage() {
		return wage;
	}

	//increase wage by percent inputted
	public void increaseWage(double percent) {
		wage *= 1 + percent/100;
	}
	
	//abstract computePay to be filled out by child classes
	abstract double computePay(int hours);

	//method for formatting dollars and cents
	public String toDollars(double amount) {
		long roundedAmount = Math.round(amount * 100);
		long dollars = roundedAmount / 100;
		long cents = roundedAmount % 100;

		if (cents <= 9)
			return dollars + ".0" + cents;
		else
			return dollars + "." + cents;
	}
	
	//methods for formatting spaces in toString methods
	public String pad(String str, int n) {
		if (str.length() > n)
			return str.substring(0, n);
		while (str.length() < n)
			str += " ";
		return str;
	}
	
	public String reversePad(String str, int n) {
		if (str.length() > n)
                        return str.substring(0, n);
                while (str.length() < n)
                        str = " " + str;
                return str;
	}
}
