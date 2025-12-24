package junitTests; 

import org.junit.jupiter.api.RepeatedTest; 
import org.junit.jupiter.api.Test;

import datastore.SolarSystemStarEnum; 

import static org.junit.jupiter.api.Assertions.*;

/**
 * JUnit 5 test class for the SolarSystemStarEnum.
 * This class directly tests the enum's methods for  descriptions,
 * masses, radii, and the random selection method.
 *
 * @author Ziyan Hirani
 */
public class SolarSystemStarEnumTests {

    /**
     * Test case to verify that the description() method of various
     * `SolarSystemStarEnum` entries returns the expected textual description.
     */
    @Test
    void testEnumDescriptions() {
        // Test for the Sun
        assertEquals("The Sun is the star at the center of the Solar System. It is a nearly perfect sphere of hot plasma, heated to incandescence by nuclear fusion reactions in its core.",
                     SolarSystemStarEnum.SUN.description(),
                     "SUN's description should match the expected string.");

        // Test for Earth
        assertEquals("Earth is the third planet from the Sun and the only astronomical object known to harbor life. About 29.2% of Earth's surface is land consisting of continents and islands.",
                     SolarSystemStarEnum.EARTH.description(),
                     "EARTH's description should match the expected string.");

        // Test for Pluto
        assertEquals("Pluto is a dwarf planet in the Kuiper belt, a ring of bodies beyond the orbit of Neptune. It was the first and the largest Kuiper belt object to be discovered.",
                     SolarSystemStarEnum.Pluto.description(),
                     "Pluto's description should match the expected string.");
    }

    /**
     * Test case to verify that the mass() method of 
     * SolarSystemStarEnum entries returns the correct mass.
     */
    @Test
    void testEnumMasses() {
        // Test for the Sun's mass
        assertEquals(1.989e+30, SolarSystemStarEnum.SUN.mass(), 0.001,
                     "SUN's mass should match the expected value.");

        // Test for Earth's mass
        assertEquals(5.976e+24, SolarSystemStarEnum.EARTH.mass(), 0.001,
                     "EARTH's mass should match the expected value.");

        // Test for Jupiter's mass
        assertEquals(1.9e+27, SolarSystemStarEnum.JUPITER.mass(), 0.001,
                     "JUPITER's mass should match the expected value.");
    }


    /**
     * Test case for the static `randomChooseStar()` method.
     * Verifies that the method always returns a valid, non-null
     * SolarSystemStarEnum constant. 
     */
    @RepeatedTest(1) 
    void testRandomChooseStar() {
        SolarSystemStarEnum randomStar = SolarSystemStarEnum.randomChooseStar();

        // Check that the result is not null
        assertNotNull(randomStar, "randomChooseStar() should never return null.");

        // Check that the result is actually one of the enum's defined values
        boolean isValidEnumConstant = false;
        for (SolarSystemStarEnum validStar : SolarSystemStarEnum.values()) {
            if (randomStar == validStar) {
                isValidEnumConstant = true;
                break;
            }
        }
        assertTrue(isValidEnumConstant, "randomChooseStar() returned an invalid enum constant: " + randomStar);
    }
}