import java.util.*;
import java.io.*;

public class Bingo {
	//declare class variables for win type
	public static final int HORIZONTAL = 1;
	public static final int VERTICAL = 2;
	public static final int DIAGONAL = 3;
	//class variables for array size
	public static final int ROWS = 5;
	public static final int COLUMNS = 5;

	public static void main(String[] args) throws IOException{
		//declare array
		int[][] bingoCard1 = new int[ROWS][COLUMNS];
		int[][] bingoCard2 = new int [ROWS][COLUMNS];
		System.out.println();

		//invoke methods to fill, display, play and give results for BINGO
		fillCard(bingoCard1, bingoCard2);
		
		System.out.println("\tPlayer 1 Card: ");
		printCard(bingoCard1);

		System.out.println("\tPlayer 2 Card: ");
		printCard(bingoCard2);

		playGame(bingoCard1, bingoCard2);
	}

	public static void fillCard(int[][] card1, int[][] card2) throws IOException{
		//Pre: File With two rows of input exists
		//Post: Two bingo cards are created using file numbers

		//create file object
		Scanner inFile = new Scanner(new File("myInput"));

		//fill array with file values
		for (int row = 0; row < ROWS; row++){
			for (int col = 0; col < COLUMNS; col++){
				card1[row][col] = inFile.nextInt();
				card2[row][col] = inFile.nextInt();
			}
		}
	}

	public static void printCard(int[][] card){
		//Pre: Card has been initialized
		//Post: Print Card 

		//header
		System.out.println("\tB\tI\tN\tG\tO");
		System.out.print("       -----------------------------------\t");

		//card
		for (int row = 0; row < ROWS; row++){
			for (int col = 0; col < COLUMNS; col++){
				if (col % card[row].length == 0){
					System.out.print("\n\t" + ((card[row][col] !=0) ? card[row][col] : "X") + "\t");
				}
				else{
					System.out.print(((card[row][col] != 0) ? card[row][col] : "X") + "\t");
				}
			}
		}
		System.out.println("\n");
	}

	public static void playGame(int [][] card1, int[][] card2) {
		//Pre: Cards have been initialized
		//Post: Declares winner

		//Declare BitSet to keep track of used picks
		BitSet picks = new BitSet(75);
		
		//declare loop variable and condition
		boolean win = false;
		int numOfDrawings = 0;
		
		//keep playing until someone wins
		System.out.println("\tBINGO NUMBERS PICKED AT RANDOM FROM BIN : ");
		while(!win){

			//generate random number
			int draw = getRandomNum(picks);
			if (numOfDrawings % 10 == 0){
				System.out.printf("\n\t%-2d ", draw);
			}
			else{
				System.out.printf("\t%-2d ", draw);
			}
			numOfDrawings++;

			//check if generated number is in either cards
			numInArray(card1, draw);
			numInArray(card2, draw);

			//check for win
			int player1 = checkForWin(card1);
			int player2 = checkForWin(card2);
			
			//declare winner
			declareWinner(player1, player2, numOfDrawings);
			
			if(player1 != 0 || player2 != 0) {
				printCard(card1);
				printCard(card2);
				win = true;
			}

		}
		System.out.println();
		
	}

	public static int getRandomNum(BitSet numPresent){
		//Pre: BitSet has been initialized 	
		//Post: returns random number not already chosen
	
		int randomNum;
		do{
			//generate random number between 1 and 75
			randomNum = (int)(Math.round((Math.random()*75+1)));

			//check if number was already chosen	
			if (!numPresent.get(randomNum-1)){
				numPresent.set(randomNum-1);
				break;
			}

		} while (true);

		return randomNum;
	}	

	public static void numInArray(int[][] card, int ranNum) {
		//Pre: Card has been initialized and random number has been generated
		//Post: check each column and if random number is found and change value of location to 0
		
		//check if random number is in first column
		if (ranNum <= 15) {
			for (int row = 0; row < ROWS; row++) {
				if (card[row][0] == ranNum) {
					card[row][0] = 0;
					break;
				}															}
		}
														
		//if random number is in second column
		else if (ranNum <= 30) {
			for (int row = 0; row < ROWS; row++) {
				if (card[row][1] == ranNum) {
					card[row][1] = 0;
					break;
				}
			}
		}
														
		//if random number is in third column
		else if (ranNum <= 45) {
			for (int row = 0; row < ROWS; row++) {
				if (card[row][2] == ranNum) {
					card[row][2] = 0;
					break;
				}
			}
		}
		
		//if random number is in fourth column
		else if (ranNum <= 60) {
			for (int row = 0; row < ROWS; row++) {
				if (card[row][3] == ranNum) {
					card[row][3] = 0;
					break;
				}
			}	
		}														
		//if random number is in last column
		else {
			for (int row = 0; row < ROWS; row++) {
				if (card[row][4] == ranNum) {
					card[row][4] = 0;
					break;
				}
			}
		}
	}
	
	public static int checkForWin(int[][] card){
		//Pre: Generated Numbers have been marked off of the Card
		//Post: Returns type of win or not a win

		int sum1 = 0;
		int sum2 = 0;

		//HORIZONTAL WIN or VERTICAL WIN
		for (int row = 0; row < ROWS; row++){
			for (int col = 0; col < COLUMNS; col++){
				sum1 += card[row][col];
				sum2 += card[col][row];
			}
			if(sum1 == 0){
				return HORIZONTAL;
			}
			else if (sum2 == 0){
				return VERTICAL;
			}
			sum1 = 0;
			sum2 = 0;
		}

		//RIGHT or LEFT DIAGONAL WIN
		for (int row = 0; row < ROWS; row++){
			sum1 += card[row][row];
			sum2 += card[row][ROWS - 1 - row];
		}
		if(sum1 == 0 || sum2 == 0){
			return DIAGONAL;
		}

		return 0;
	}
	
	public static void declareWinner(int player1, int player2, int iterations) {
		//Pre: Some card has won the game
		//Post: Checks which card won

		if (player1 == HORIZONTAL || player2 == HORIZONTAL){
			System.out.println("\n\n\t" + ((player1 == 1) ? "Player 1" : "Player 2") + " WINS WITH A HORIZONTAL"
	              				    + " BINGO AFTER " + iterations + " PICKS!");
		}
		else if (player1 == VERTICAL || player2 == VERTICAL){
			System.out.println("\n\n\t" + ((player1 == 2) ? "Player 1" : "Player 2") + " WINS WITH A VERTICAL"
		     			            + " BINGO AFTER " + iterations + " PICKS!");
		}
		else if(player1 == DIAGONAL || player2 == DIAGONAL){
			System.out.println("\n\n\t" + ((player1 == 3) ? "Player 1" : "Player 2") + " WINS WITH A DIAGONAL"
                                                    + " BINGO AFTER " + iterations + " PICKS!");
		}
	}
}
