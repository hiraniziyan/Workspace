package datastore;

import java.util.Random;


/**
 * Represents the celestial bodies in our solar system as constants, which
 * holds associated data such as mass and radius. 
 * This enum stores star infor for the solar system. 
 * @author Ziyan Hirani
 */
public enum SolarSystemStarEnum {
	//	Sun, Mercury, Venus, Earth, Mars, Jupiter, Neptune, Saturn, Uranus, Pluto, Moon, Asteroid;
	SUN		(1.989e+30, 6.960e8),
	MERCURY (3.303e+23, 2.4397e6),
	VENUS   (4.869e+24, 6.0518e6),
	EARTH   (5.976e+24, 6.37814e6),
	MARS    (6.421e+23, 3.3972e6),
	JUPITER (1.9e+27,   7.1492e7),
	NEPTUNE (1.024e+26, 2.4746e7),
	SATURN  (5.688e+26, 6.0268e7),
	URANUS  (8.686e+25, 2.5559e7),
	Pluto	(1.2e+22, 1.185e6),
	Moon	(7.346e+22, 1.736e6),
	Asteroid(1.0e+5, 1.0e2);

	private final double mass;   // in kilograms
	private final double radius; // in meters
	
	/**
     * Constructs a new SolarSystemStarEnum constant with its data.
     *
     * @param mass   The mass of the body in kilograms.
     * @param radius The radius of the body in meters.
     */
	SolarSystemStarEnum(double mass, double radius) {
		this.mass = mass;
		this.radius = radius;
	}

	
	public double mass() { 
		return mass; 
	}

	
	public double radius() { 
		return radius; 
	}

	/**
     * Retrieves the description for this celestial body from file.
     *
     * @return A String containing the description.
     */
    public String description() {
        return DescriptionManager.getDescription(this);
    }

	/**
	 * Selects and returns a random SolarSystemStarEnum constant.
	 *
	 * @return A randomly chosen constant from this enum.
	 */
	public static SolarSystemStarEnum randomChooseStar() {
		Random r = new Random(System.currentTimeMillis());
		int index = r.nextInt(SolarSystemStarEnum.values().length);
		return SolarSystemStarEnum.values()[index];
	}
}
