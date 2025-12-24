package gui;

import java.awt.BorderLayout;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.image.BufferedImage;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.Timer;

import datastore.SolarSystemStarEnum;

/**
 * A panel that allows a user to select a star either by clicking
 * an animating image or by entering the star's index manually.
 *
 * @author Ziyan Hirani
 */
public class PickAStarPanel extends JPanel {
	private SolarSystemStarEnum star;
	private JTextField starDesc;
	private JLabel starPixLabel;
	private SolarSystemInfoPanel infoPanel;
	private IconPanel iconPanel;

	private Timer timer;
	private int animationIndex;

	/**
	 * Constructs a new PickAStarPanel.
	 * Initializes the panel with a default star, sets up the layout,
	 * creates control components, starts the animation timer, and
	 * makes mouse listeners.
	 *
	 * @param star The initial datastore.SolarSystemStarEnum to display.
	 * @param infoPanel A reference to the gui.SolarSystemInfoPanel for information updates.
	 * @param iconPanel A reference to the gui.IconPanel for main icon updates.
	 */
	public PickAStarPanel(SolarSystemStarEnum star, SolarSystemInfoPanel infoPanel, IconPanel iconPanel) {
		this.star = star;
		this.infoPanel = infoPanel;
		this.iconPanel = iconPanel;
		this.animationIndex = (star.ordinal() + 1) % SolarSystemStarEnum.values().length;

		this.setLayout(new BorderLayout());

		JPanel controlPanel = new JPanel();
		BufferedImage initialIcon = new SolarSystemStarIcon(star).getRoundedCornerImage();
		starPixLabel = new JLabel(new ImageIcon(initialIcon));
		controlPanel.add(starPixLabel);
		this.add(controlPanel);

		JPanel p = createSelectPanel();
		this.add(p, BorderLayout.SOUTH);

		ActionListener timerListener = createTimerListener();
		timer = new Timer(2500, timerListener); // Timer fires every 2.5 seconds
		timer.start();

		starPixLabel.addMouseListener(createMouseListener());
	}

	/**
	 * A public method that allows components like StarPanel
	 * to set the currently displayed star and stop the animation.
	 * @param newStar The datastore.SolarSystemStarEnum to display.
	 */
	public void setIcon(SolarSystemStarEnum newStar) {
		timer.stop(); // Stop the animation
		resetStar(newStar.ordinal()); // Reset to the new star
	}

	/**
	 * Creates and returns an ActionListener for the animation timer.
	 * This listener updates the displayed star icon to the next star in the
	 * SolarSystemStarEnum sequence, creating an animation effect.
	 * @return An ActionListener for the animation timer.
	 */
	private ActionListener createTimerListener() {
		return event -> {
			SolarSystemStarEnum animatingStar = SolarSystemStarEnum.values()[animationIndex];
			BufferedImage animatingIcon = new SolarSystemStarIcon(animatingStar).getRoundedCornerImage();
			starPixLabel.setIcon(new ImageIcon(animatingIcon));
			animationIndex = (animationIndex + 1) % SolarSystemStarEnum.values().length;
		};
	}

	/**
	 * Creates and returns a MouseAdapter for the star image label.
	 * When the animating star image is clicked, the animation stops, and the
	 * current star is selected.
	 * This chosen star's information is then synced across other panels.
	 * @return A MouseAdapter for clicking the star image.
	 */
	private MouseAdapter createMouseListener() {
		return new MouseAdapter() {
			@Override
			public void mouseClicked(MouseEvent e) {
				timer.stop(); // Stop animation on click
				// Calculate the index of the star that was just displayed
				int chosenIndex = (animationIndex == 0) ? SolarSystemStarEnum.values().length - 1 : animationIndex - 1;
				PickAStarPanel.this.star = SolarSystemStarEnum.values()[chosenIndex];
				starDesc.setText(String.valueOf(PickAStarPanel.this.star.ordinal()));

				// update other panels
				infoPanel.updateStarInfo(PickAStarPanel.this.star);
				iconPanel.updateStarIcon(PickAStarPanel.this.star);
			}
		};
	}

	/**
	 * Creates and returns a JPanel containing the "Pick a Star" button
	 * and a text field for entering a star's index. This panel allows manual selection.
	 * @return A JPanel with star selection controls.
	 */
	private JPanel createSelectPanel() {
		JPanel p = new JPanel();
		JButton b = new JButton("Pick a Star");
		p.add(b);
		JLabel l = new JLabel("Star index: ");
		starDesc = new JTextField(6);
		starDesc.setText("" + star.ordinal());
		starDesc.setEditable(true);
		p.add(l);
		p.add(starDesc);

		// ActionListener for the "Pick a Star" button
		b.addActionListener(e -> {
			timer.stop(); // Stop animation on button press
			try {
				int starIndex = Integer.parseInt(starDesc.getText());
				resetStar(starIndex); // Update the displayed star

				// update other panels
				infoPanel.updateStarInfo(getStar());
				iconPanel.updateStarIcon(getStar());

			} catch (NumberFormatException | ArrayIndexOutOfBoundsException ex) {
				starDesc.setText("Invalid!"); // Handle invalid input
			}
		});
		return p;
	}

	/**
	 * Resets the displayed star icon and text field to a specific star index.
	 *
	 * @param starIndex The ordinal index of the SolarSystemStarEnum to display.
	 */
	protected void resetStar(int starIndex) {
		if (starIndex >= 0 && starIndex < SolarSystemStarEnum.values().length) {
			this.star = SolarSystemStarEnum.values()[starIndex];
			BufferedImage rndImgIcon = new SolarSystemStarIcon(this.star).getRoundedCornerImage();
			starPixLabel.setIcon(new ImageIcon(rndImgIcon));
			starDesc.setText("" + starIndex);
		} else {
			throw new ArrayIndexOutOfBoundsException("Invalid star index: " + starIndex);
		}
	}

	/**
	 * Returns the currently selected SolarSystemStarEnum entry.
	 * @return The current SolarSystemStarEnum.
	 */
	public SolarSystemStarEnum getStar() {
		return star;
	}

	/**
	 * Main method for testing
	 */
	public static void main(String[] args) {
		JFrame f = new JFrame("Choose One from List");
		// Create dummy panels as PickAStarPanel requires them
		IconPanel dummySelected = new IconPanel();
		SolarSystemInfoPanel dummyParent = new SolarSystemInfoPanel(dummySelected);
		PickAStarPanel selectPanel = new PickAStarPanel(SolarSystemStarEnum.MARS, dummyParent, dummySelected);
		f.add(selectPanel);
		f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		f.pack();
		f.setLocationRelativeTo(null);
		f.setVisible(true);
	}
}