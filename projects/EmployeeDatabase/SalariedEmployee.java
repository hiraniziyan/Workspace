
import java.io.Serializable;

@SuppressWarnings("serial")
public class SalariedEmployee extends Employee implements Serializable{

	//contructor for Salaried Employee	
	public SalariedEmployee(String name, double salary) {
		super(name,salary/(40*52));

	}
	
	//compute pay that returns 1/52 of total salary
	public double computePay(int hours) {
		return getWage()*40 ;
	}
	
	//getters and setter for salary
	public double getSalary() {
		return getWage() * 40 * 52;
	}
	
	public void setSalary(double newSalary) {
		double salary = newSalary;
	}
	
	//prints employee record
	public String toString() {
		return  pad(getName(),20) + reversePad("$" + toDollars(getSalary()),10) + "/year";
	}
	

}
