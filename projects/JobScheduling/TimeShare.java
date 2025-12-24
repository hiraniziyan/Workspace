
import java.io.*;
import java.util.*;
public class TimeShare{

	private static Queue inputQueue = new Queue();
	private static Queue jobQueue = new Queue();
	private static Queue finishedJobs = new Queue();
	private static int time = 1;

	public static void main(String[] args) throws FileNotFoundException, CloneNotSupportedException{
		//invoke inputFile method from command line args	
		inputFile(args[0]);

		//check if transfer is needed and time == 1;
		transferToJobQueue();
		
		//while all jobs are not completed, do the job in the jobQueue or check if a transfer to Job Queue is needed
		do {
			executeCurrentJob();
		}while(!inputQueue.isEmpty() || !jobQueue.isEmpty());

		//print records
		print();
	}

	private static void inputFile(String fileName) throws FileNotFoundException{
		//Pre: fileName has been obtained from command line
		//Post: all jobs from file have been stored into the inputQueue
		try {
			Scanner in = new Scanner(new File(fileName));
			while(in.hasNext())
			{	
				//read in each item in the file one by one and store it to appropriate variables
				Scanner lsc = new Scanner(in.nextLine());
				String jobName = lsc.next();
				int arrivalTime = lsc.nextInt();
				int runTime = lsc.nextInt();

				//create new Job with the values from file and store it in inputQueue
				inputQueue.enqueue(new Job(jobName, arrivalTime, runTime));
			}
			in.close();
		}
		//throw error message if file does not exist
		catch (IOException e) {
			System.out.println(e.getMessage());
			System.exit(1);
		}
	}
	private static void transferToJobQueue() throws CloneNotSupportedException {
		//Pre: Transfer all jobs to inputQueue from file
		//Post: Transfer job from inputQueue to jobQueue when the job's arrival time has reached

		//if Queue is not empty 
		if(!inputQueue.isEmpty()){
			Job job = (Job) inputQueue.front();

			//if the arrival time of the front job equals the current time move the job to the jobQueue
			if(job.arrivalTime == time) {
				jobQueue.enqueue(inputQueue.dequeue());
			}
		}
	}

	private static void executeCurrentJob() throws CloneNotSupportedException {
		//Pre: program has gone through transferToJobQueue method at least once
		//Post: if there is a job in the jobQueue, it is ran and completed and then transfered to finishedJobs Queue
	
                //if no jobs, increment time and check if transder time for next job has reached
		if(jobQueue.isEmpty()){
                        time++;
                        transferToJobQueue();
			return;
                }

		//set the job's startTime to current time
		Job job = (Job)jobQueue.dequeue();
		job.startTime = time;
			
		//run job until it is completed
		while(job.runTime != time - job.startTime) {
			//increase time and check if transfer time for next job has reached
			time++;
			transferToJobQueue();
		}
			
		//set waitTime and turnTime for the job
		job.waitTime = job.startTime - job.arrivalTime;
		job.turnTime = job.waitTime + job.runTime;
			
		//put job into finishedJobs queue
		finishedJobs.enqueue(job);
		
	}
	private static double averageWaitTime() throws CloneNotSupportedException {
		//Pre: All jobs have been completed and stored with respective time values in finishedJobs queue
		//Post: Average Wait time is returned
		
		//clone finished Jobs Queue
		Queue finished = (Queue) finishedJobs.clone();
		double totalWaitTime = 0;
		int numJobs = 0;
		
		//while cloned queue is not empty, add up the jobs' waitTimes
		while(!finished.isEmpty()) {
			Job job = (Job) finished.dequeue();
			totalWaitTime += job.waitTime;
			numJobs++;
		}
		
		//return avgWait time by dividing totalWaitTime by number of jobs
		return totalWaitTime/numJobs;
	}
	private static double cpuUsage() throws CloneNotSupportedException {
		//Pre: All jobs have been completed and stored with respective time values in finishedJobs queue
		//Post: cpuUsage is returned
		
		//clone finished Jobs Queue                
		Queue finished = (Queue) finishedJobs.clone();
		double cpuUsage = 0;
		
		//while cloned queue is not empty, add up the jobs' runTimes
		while(!finished.isEmpty()) {
			Job job = (Job) finished.dequeue();
			cpuUsage += job.runTime;
		}
		return cpuUsage;
	}


	private static void print() throws CloneNotSupportedException{
		//Pre: All jobs have been completed and all time values for each job has been attained
		//Post: Print Summary Report of all jobs

		clearScreen();

		//header
		System.out.println("\nJob Control Analysis: Summary Report\n");
		System.out.println("job id\tarrival\tstart\trun\twait\tturnaround");
		System.out.println("      \ttime   \ttime \ttime\ttime\ttime");
		System.out.println("------\t-------\t-----\t----\t----\t----------");
		
		//calculate averageWaitTime, cpuUsage, cpuIdle, and cpuUsagePercentage
		double averageWaitTime = averageWaitTime();
		double cpuUsage = cpuUsage();
		double cpuIdle = --time - cpuUsage;
		double cpuUsagePercentage = (cpuUsage / (cpuUsage + cpuIdle))*100;
	
		//invoke the toString() method of the Job class to print all values of each Job
		while(!finishedJobs.isEmpty()) {
                        System.out.println(finishedJobs.dequeue());
                }
		
		//print average values
		System.out.printf("\n Average Wait Time => %.2f\n", averageWaitTime);
		System.out.printf("         CPU Usage => %.2f\n", cpuUsage);
		System.out.printf("          CPU Idle => %.2f\n", cpuIdle);
		System.out.printf("     CPU Usage (%%) => %.2f%%\n\n", cpuUsagePercentage);
	}
	
	//clear screen method
        private static void clearScreen() {
		System.out.println("\u001b[H\u001b[2J");
        } 

}

