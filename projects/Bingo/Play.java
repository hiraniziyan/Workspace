import java.util.BitSet;

public class Play {

	public static void main(String[] args) {

		int numPlayers = 2;
		int randomNum = 0;
		
		//declare BitSets for each player
		BitSet usedNum1 = new BitSet(75);
		BitSet usedNum2 = new BitSet(75);

		//25 elements for each person
		for (int row = 0; row < 5; row++){
			for (int col = 0; col < 5; col++){
				for (int i = 0; i < numPlayers; i++) {

					//set number range 
					do {
						switch (col){
						case 0: randomNum = (int)(Math.random()*15+1);
						break;
						case 1: randomNum = (int)(Math.random()*15+16);
						break;
						case 2: randomNum = (int)(Math.random()*15+31);
						break;
						case 3: randomNum = (int)(Math.random()*15+46);
						break;
						case 4: randomNum = (int)(Math.random()*15+61);
						break;
						}

					}while (usedNum1.get(randomNum-1) || usedNum2.get(randomNum-1));
					
					//set BitSet for random num to true
					usedNum1.set(randomNum-1);
					usedNum2.set(randomNum-1);

					System.out.print(randomNum + " ");
				}
				System.out.println();
			}
		}
	}
}
