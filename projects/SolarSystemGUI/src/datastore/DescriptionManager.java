package datastore;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * A utility class for loading star descriptions from a text file.
 *
 * @author Ziyan Hirani
 */
public class DescriptionManager {

	/**
	 * A list to hold the star descriptions read from the file.
	 */
	private static final List<String> descriptions = new ArrayList<>();


	static {

		String filePath = "data/descriptions.txt";
		try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
			String line;
			// Read the file line by line and add each description to the list.
			while ((line = reader.readLine()) != null) {
				descriptions.add(line);
			}
		} catch (IOException e) {
			// If the file can't be found or read, print an error and exit.
			System.err.println("Error loading star descriptions file: " + e.getMessage());
			e.printStackTrace();
		}
	}

	private DescriptionManager() {}

	/**
	 * Retrieves the description for a given celestial body.
	 *
	 * @param ssse The SolarSystemStarEnum constant for the desired star.
	 * @return A String containing the description, or an error message if not found.
	 */
	public static String getDescription(SolarSystemStarEnum ssse) {
		// Use the enum's ordinal value (its position: 0 for SUN, 1 for MERCURY, etc.)
		// to get the description from the corresponding line in the list.
		int index = ssse.ordinal();
		if (index >= 0 && index < descriptions.size()) {
			return descriptions.get(index);
		} else {
			return "Description not found for " + ssse.name();
		}
	}
}
