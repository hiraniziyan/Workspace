package gui;

import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Image;
import java.awt.Shape;
import java.awt.geom.RoundRectangle2D;
import java.awt.image.BufferedImage;

import javax.swing.Icon;
import javax.swing.ImageIcon;
import javax.swing.JOptionPane;

import datastore.SolarSystemStarEnum;

/**
 * Implements javax.swing.Icon to draw a star from a composite image.
 */
public class SolarSystemStarIcon implements Icon {
	private SolarSystemStarEnum starCode;
	private int width = 240, height = 245, top, left;
	private Image solarPicture = new ImageIcon(
			"image/solarsystem.jpg").getImage();
	private double ratio = 1;

	private BufferedImage roundCornerImage;

	public SolarSystemStarIcon(SolarSystemStarEnum starCode) {
		this.starCode = starCode;
		setValues();

		int w = (int)(width * ratio);
		int h = (int)(height * ratio);

		BufferedImage roundedImage = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = roundedImage.createGraphics();
		g2d.drawImage(solarPicture, 0, 0, w, h, 
				left, top, left + width, top + height, null);
		g2d.dispose();

		this.roundCornerImage = createRoundedImage(roundedImage, 25);
	}

	/**
	 * Calculates top, left, and ratio based on starCode ordinal and radius.
	 */
	private void setValues() {
		int row = starCode.ordinal() / 4;
		int col = starCode.ordinal() % 4;
		top = 20 + row * height;
		left = 35 + col * width;
		ratio = Math.log10(starCode.radius())/15;
	}

	double getRatio() {
		return ratio;
	}
	//*
	@Override
	public int getIconHeight() {
		// TODO Auto-generated method stub
		return (int)(height * ratio);
	}

	@Override
	public int getIconWidth() {
		// TODO Auto-generated method stub
		return (int)(width * ratio);
	}

	/**
	 * Draws the scaled image at the specified location.
	 * 
	 * @param c The component. @param g The graphics context. @param x The X-coordinate. @param y The Y-coordinate.
	 */
	@Override
	public void paintIcon(Component c, Graphics g, int x, int y) {
		//g.setColor(Color.LIGHT_GRAY);
		//g.fillRect(0, 0, width, height);
		g.drawImage(this.solarPicture, x, y, x+(int)(width * ratio), 
				y+(int)(height * ratio), 
				left, top, left + width, top + height, null);
	}
	//*/
	public void setRatio(double d) {
		ratio = d;
	}

	/**
	 * Creates a new BufferedImage from a source image with specified rounded corners.
	 * @param image The source image. cornerRadius The radius of the corners.
	 * @return A new BufferedImage with rounded corners.
	 */
	public static BufferedImage createRoundedImage(BufferedImage image, int cornerRadius) {
		int width = image.getWidth();
		int height = image.getHeight();

		BufferedImage roundedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = roundedImage.createGraphics();

		// Create a rounded rectangle shape
		Shape roundedRectangle = new RoundRectangle2D.Float(0, 0, width, height, cornerRadius, cornerRadius);
		g2d.setClip(roundedRectangle);

		// Draw the image
		g2d.drawImage(image, 0, 0, null);
		g2d.dispose();

		return roundedImage;
	}

	/**
	 * Main method for standalone testing, demonstrating rounded star and full solar system images.
	 */
	public static void main(String[] args)
	{
		JOptionPane.showMessageDialog(
				null,
				"Hello, Moon!",
				"Message",
				JOptionPane.INFORMATION_MESSAGE,
				new ImageIcon(new SolarSystemStarIcon(SolarSystemStarEnum.JUPITER).roundCornerImage));
		//new SolarSystemStarIcon(SolarSystemStarEnum.JUPITER));
		//*
		Image image = new ImageIcon("image/solarsystem.jpg").getImage();
		int width = image.getWidth(null);
		int height = image.getHeight(null);

		BufferedImage roundedImage = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
		Graphics2D g2d = roundedImage.createGraphics();
		g2d.drawImage(image, 0, 0, null);
		g2d.dispose();

		JOptionPane.showMessageDialog(
				null,
				"Hello, Solar System!",
				"Message",
				JOptionPane.INFORMATION_MESSAGE,
				new ImageIcon(createRoundedImage(roundedImage, 50)));
		//*/
		System.exit(0);
	}

	public BufferedImage getRoundedCornerImage() {
		return this.roundCornerImage;
	}

}
