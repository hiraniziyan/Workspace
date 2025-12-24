import jpb.*;

public class Sort
{
  public static int[] integers(int[] ar)
  {
	int temp;  int pass = 0;
	boolean anotherPassNeeded = true;
	int currentBottom = ar.length;

	while(anotherPassNeeded)
	{
	  anotherPassNeeded = false;
	  
	  for(int curr=0; curr<(currentBottom-1); curr++)
	  	if(ar[curr+1] < ar[curr])
		{
		  temp = ar[curr];
	 	  ar[curr] = ar[curr+1];
		  ar[curr+1] = temp;

		  anotherPassNeeded = true;
		}
	  currentBottom = currentBottom-1;
	}
	
	return ar;
  }

  public static char[] chars(char[] ar)
  {
	char temp;  int pass = 0;
	boolean anotherPassNeeded = true;
	int currentBottom = ar.length;

	while(anotherPassNeeded)
	{
	  anotherPassNeeded = false;
	  
	  for(int curr=0; curr<(currentBottom-1); curr++)
	  	if(ar[curr+1] < ar[curr])
		{
		  temp = ar[curr];
	 	  ar[curr] = ar[curr+1];
		  ar[curr+1] = temp;

		  anotherPassNeeded = true;
		}
	  currentBottom = currentBottom-1;
	}
	
	return ar;
  }

  public static String[] strings(String[] ar)
  {
	String temp;  int pass = 0;
	boolean anotherPassNeeded = true;
	int currentBottom = ar.length;

	while(anotherPassNeeded)
	{
	  anotherPassNeeded = false;
	  
	  for(int curr=0; curr<(currentBottom-1); curr++)
	  	if((ar[curr].compareTo(ar[curr+1]))<0)
		{
		  temp = ar[curr];
	 	  ar[curr] = ar[curr+1];
		  ar[curr+1] = temp;

		  anotherPassNeeded = true;
		}
	  currentBottom = currentBottom-1;
	}
	
	return ar;
  }
}
