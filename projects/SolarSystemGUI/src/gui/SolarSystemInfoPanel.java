package gui;

import javax.swing.*;
import javax.swing.table.DefaultTableModel;

import datastore.SolarSystemStarEnum;

import java.awt.Dimension;
import java.text.DecimalFormat;

/**
 * A composite panel designed to display detailed information about celestial bodies.
 * This panel is the EAST region of the main application.
 *
 * @author Ziyan Hirani
 */
public class SolarSystemInfoPanel extends JPanel {

	private JTextArea starDescription;
	private PickAStarPanel pickStarP;
	
	/**
	 * Constructs the SolarSystemInfoPanel and accepts a reference to the left panel.
	 *
	 * @param IconPanel The panel that displays the large selected star icon.
	 */
	public SolarSystemInfoPanel(IconPanel IconPanel) {
		JTable starTable = createStarTable();
		
		starDescription = new JTextArea(10, 40);
		starDescription.setLineWrap(true);
		starDescription.setWrapStyleWord(true);
		String desc = "Select a star to show description...";
		starDescription.setText(desc);
		
		pickStarP = new PickAStarPanel(SolarSystemStarEnum.EARTH, this, IconPanel);
		
		this.setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
		this.add(starTable);
		this.add(new JScrollPane(starDescription));
		this.add(pickStarP);
		this.setPreferredSize(new Dimension(350, 600));

	}

	/**
	 * Updates the description text area with information for a specific star.
	 *
	 * @param star The SolarSystemStarEnum constant whose description should be displayed.
	 */
	public void updateStarInfo(SolarSystemStarEnum star) {
		starDescription.setText(star.description());
		starDescription.setCaretPosition(0);
	}
	
	
	public PickAStarPanel getPickAStarPanel() {
		return pickStarP;
	}

	/**
	 * A method that creates and configures the fact-sheet table.
	 *
	 * @return A JTable instance ready for display.
	 */
	private JTable createStarTable() {
        String[] columns = new String[] { "Star Name", "Mass (KG)", "Radius (M)" };
        Object[][] data = loadData();      		
        DefaultTableModel model = new DefaultTableModel(data, columns) {
			@Override
			public boolean isCellEditable(int row, int column) { 
				return false; 
			}
		};
        return new JTable(model);
	}

	/**
	 * A private helper method that loads and formats the solar system data from the enum.
	 *
	 * @return A 2D Object array containing the formatted data for the JTable.
	 */
	private Object[][] loadData() {
		SolarSystemStarEnum[] stars = SolarSystemStarEnum.values();
		Object[][] data = new Object[stars.length][3];
        DecimalFormat massFormatter = new DecimalFormat("0.###E0");
        DecimalFormat radiusFormatter = new DecimalFormat("#,##0.0");
		for (int i = 0; i < stars.length; i++) {
			data[i][0] = stars[i].name();
			data[i][1] = massFormatter.format(stars[i].mass());
			data[i][2] = radiusFormatter.format(stars[i].radius());
		}
		return data;
	}

	/**
	 * The main method for testing of this panel.
	 */
	public static void main(String[] args) {
		JFrame f = new JFrame("Pick a Star...");
		SolarSystemInfoPanel ssip = new SolarSystemInfoPanel(new IconPanel());
		f.add(ssip);
		f.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		f.pack();
		f.setLocationRelativeTo(null); 
		f.setVisible(true);
	}
}

