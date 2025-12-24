package gui; 

import javax.swing.*;

import datastore.SolarSystemStarEnum;

import java.awt.*;

/**
 * A panel designed to display a large icon of the current star on the left panel of the application.
 *
 * @author Ziyan Hirani
 */
public class IconPanel extends JPanel {
    private JLabel IconLabel;

    /**
     * Constructs the panel and initializes it with a random star icon.
     */
    public IconPanel() {
    	
        this.setLayout(new GridBagLayout());
        
        // Display a random star icon at the beginning
        SolarSystemStarIcon initialIcon = new SolarSystemStarIcon(SolarSystemStarEnum.randomChooseStar());
        initialIcon.setRatio(0.8); 
        
        IconLabel = new JLabel(initialIcon);
        
        this.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
        
        this.add(IconLabel);
    }

    /**
     * A public method that will be used to change the displayed icon.
     * @param star The star whose icon should be displayed.
     */
    public void updateStarIcon(SolarSystemStarEnum star) {
        SolarSystemStarIcon newIcon = new SolarSystemStarIcon(star);
        newIcon.setRatio(0.8); 
        IconLabel.setIcon(newIcon);
    }
}

