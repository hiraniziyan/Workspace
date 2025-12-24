package gui;

import java.awt.BorderLayout;
import java.util.ArrayList;
import java.util.List;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;

import datastore.SolarSystemStarEnum;

/**
 * A panel that serves as the main control area for the solar system application,
 * displaying a button for each icon.
 *
 * @author Ziyan Hirani
 */
public class StarPanel extends JPanel {
	/** A list to hold references to all the created star JButtons. */
	List<JButton> stars = new ArrayList<>();

	/**
	 * Default constructor for testing. Creates buttons that
	 * provide simple feedback via a dialog box.
	 */
	public StarPanel() {
		SolarSystemStarIcon icon;
		JButton btn;
		for (SolarSystemStarEnum e : SolarSystemStarEnum.values()) {
			icon = new SolarSystemStarIcon(e);
			btn = new JButton(icon);
			btn.setHorizontalAlignment(SwingConstants.CENTER);
			btn.addActionListener(event -> {
				System.out.println("Selected star: " + e.name());
				javax.swing.JOptionPane.showMessageDialog(null, "You selected " + e.name());
			});
			stars.add(btn);
			add(btn);
		}
	}

	/**
	 * Constructs the StarPanel for use in the main application. It accepts
	 * references to all other panels it needs to control.
	 *
	 * @param infoPanel       The panel on the right to update with descriptions.
	 * @param iconPanel   	  The panel on the left to update with the icon.
	 * @param pickAStarPanel  The interactive animation panel inside the infoPanel.
	 */
	public StarPanel(SolarSystemInfoPanel infoPanel, IconPanel iconPanel, PickAStarPanel pickAStarPanel) {
		SolarSystemStarIcon icon;
		JButton btn;
		for (SolarSystemStarEnum e : SolarSystemStarEnum.values()) {
			icon = new SolarSystemStarIcon(e);
			btn = new JButton(icon);
			btn.setHorizontalAlignment(SwingConstants.CENTER);
			
			// updates all other panels when a button is clicked.
			btn.addActionListener(event -> {
				infoPanel.updateStarInfo(e);
				iconPanel.updateStarIcon(e);
				pickAStarPanel.setIcon(e);
			});
			
			stars.add(btn);
			add(btn);
		}
	}

	public static void main(String[] args) {
		JFrame solarSystemFrame = new JFrame("Star World");
		solarSystemFrame.setIconImage(new ImageIcon("image/solar_icon.png").getImage());
		StarPanel schP = new StarPanel();
		solarSystemFrame.add(schP, BorderLayout.SOUTH);

		JLabel solarSystemLabel = new JLabel(new ImageIcon("image/order-of-planets-in-the-solar-system.jpg"));
		solarSystemFrame.add(solarSystemLabel, BorderLayout.CENTER);
		solarSystemFrame.pack();
		solarSystemFrame.setVisible(true);
		solarSystemFrame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}
}

