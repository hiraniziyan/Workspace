package gui;

import javax.swing.*;

import datastore.SolarSystemStarEnum;

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * This class assembles the various GUI components
 * into an interactive application framework.
 *
 * @author Ziyan Hirani
 */

public class SolarSystemGUI {

	/**
	 * The main for the application. Lays out all panels
	 */
	public static void main(String[] args) {

		SwingUtilities.invokeLater(() -> {
			// Open a frame and set the border layout
			JFrame frame = new JFrame("Ziyan Hirani's Solar System Explorer");
			frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
			frame.setLayout(new BorderLayout());

			// Icon Image on window
			frame.setIconImage(new ImageIcon("image/MyIcon.jpg").getImage());

			// Create all the panels 
			IconPanel IconPanel = new IconPanel();
			SolarSystemInfoPanel infoPanel = new SolarSystemInfoPanel(IconPanel);
			PickAStarPanel pickAStarPanel = infoPanel.getPickAStarPanel();
			StarPanel starPanel = new StarPanel(infoPanel, IconPanel, pickAStarPanel); 

			// Create and resize the center image 
			ImageIcon solarSystemIcon = new ImageIcon("image/order-of-planets-in-the-solar-system.jpg");
			Image scaledImage = solarSystemIcon.getImage().getScaledInstance(800, -1, Image.SCALE_SMOOTH);
			JLabel solarSystemLabel = new JLabel(new ImageIcon(scaledImage));

			// Layout the panels
			frame.add(solarSystemLabel, BorderLayout.CENTER);
			frame.add(starPanel, BorderLayout.SOUTH);
			frame.add(infoPanel, BorderLayout.EAST);
			frame.add(IconPanel, BorderLayout.WEST);

			frame.pack(); 
			frame.setLocationRelativeTo(null); 
			frame.setVisible(true);

			// Create and start the random star selection timer
			int delay = 10000; 

			RandomStarSelectorActionListener randomSelector = 
					new RandomStarSelectorActionListener(infoPanel, IconPanel, pickAStarPanel);

			Timer randomStarTimer = new Timer(delay, randomSelector);
			randomStarTimer.setRepeats(false); 
			randomStarTimer.start();

		});
	}

	/**
	 * This ActionListener will be triggered by a Timer to randomly select a star
	 * and update all components.
	 */
	private static class RandomStarSelectorActionListener implements ActionListener {
		private SolarSystemInfoPanel infoPanel;
		private IconPanel IconPanel;
		private PickAStarPanel pickAStarPanel;

		public RandomStarSelectorActionListener(SolarSystemInfoPanel infoPanel,
				IconPanel IconPanel, PickAStarPanel pickAStarPanel) {
			this.infoPanel = infoPanel;
			this.IconPanel = IconPanel;
			this.pickAStarPanel = pickAStarPanel;
		}

		@Override
		public void actionPerformed(ActionEvent e) {
			SolarSystemStarEnum randomStar = SolarSystemStarEnum.randomChooseStar();

			// Sync changes across all components

			infoPanel.updateStarInfo(randomStar);
			IconPanel.updateStarIcon(randomStar);
			pickAStarPanel.setIcon(randomStar);

			((Timer)e.getSource()).stop();  // stop the timer after one event
		}
	}
}