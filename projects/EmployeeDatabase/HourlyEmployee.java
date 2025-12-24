import java.io.Serializable;

@SuppressWarnings("serial")
public class HourlyEmployee extends Employee implements Serializable{

	//constructor for Hourly Employee	
	public HourlyEmployee(String name, double wage) {
		super(name,wage);
	}
	
	//compute pay that adds bonus if more hours worked
	public double computePay(int hours) {
		return (hours <= 40) ? 
				hours * getWage() : 
					40 * getWage() + (hours - 40) * 1.5 * getWage();
	}
	
	//prints information
	public String toString() {
		return  pad(getName(),20) + reversePad("$"  + toDollars(getWage()),10) + "/hour";
	}
}
