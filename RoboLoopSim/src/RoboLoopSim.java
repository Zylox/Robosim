import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;

import org.newdawn.slick.AppGameContainer;
import org.newdawn.slick.BasicGame;
import org.newdawn.slick.Color;
import org.newdawn.slick.GameContainer;
import org.newdawn.slick.Graphics;
import org.newdawn.slick.Image;
import org.newdawn.slick.SlickException;
import org.newdawn.slick.geom.Circle;
import org.newdawn.slick.geom.Point;
import org.newdawn.slick.geom.Rectangle;

public class RoboLoopSim extends BasicGame {

	public static final int waitTime = 5;

	private Image background;
	private ScriptReader scriptRead;
	private ScriptReader botOut;
	private ArrayList<Robot> bots;
	private int stopWatch;
	private boolean simulating;
	private float time;
	private float timeStep;
	private int counter = 0;
	private ArrayList<Circle> points;
	private boolean readFromBotOut = true;

	public RoboLoopSim(String title) {
		super(title);
	}

	public static void main(String[] args) {

		try {
			// the topmost wrapper for our game.
			AppGameContainer app = new AppGameContainer(new RoboLoopSim(
					"RoboSim"));
			// sets the resolution to your screens resolution, true means to
			// make it fullscreen1
			app.setDisplayMode(801, 601, false);
			app.setAlwaysRender(true);
			app.start();

		} catch (SlickException ex) {
			ex.printStackTrace();
		}

	}

	@Override
	public void init(GameContainer container) throws SlickException {
		// TODO Auto-generated method stub

		stopWatch = 0;

		points = new ArrayList<Circle>();
		bots = new ArrayList<Robot>();

		try {
			scriptRead = new ScriptReader("botscript.txt");
			botOut = new ScriptReader("botMessages.txt");
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		String firstLine = "";
		try {
			firstLine = scriptRead.readScriptLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		int radius;
		radius = Integer.parseInt(firstLine);

		try {
			firstLine = scriptRead.readScriptLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		String backPic = firstLine;

		try {
			firstLine = scriptRead.readScriptLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		time = Float.parseFloat(firstLine);

		try {
			firstLine = scriptRead.readScriptLine();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		timeStep = Float.parseFloat(firstLine);

		// pasing: name posx posy
		String[] firstLineParts = parseLine(scriptRead);

		int knownAttributeNum = 6;
		int i;
		for (i = 0; i < firstLineParts.length - knownAttributeNum + 1; i += knownAttributeNum) {
			bots.add(new Robot(firstLineParts[i], i / knownAttributeNum));
			// System.out.println(firstLineParts[i] + " " + i);
			bots.get(i / knownAttributeNum).initBody(
					Integer.parseInt(firstLineParts[i + 1]),
					Integer.parseInt(firstLineParts[i + 2]), radius,
					Float.parseFloat(firstLineParts[i + 3]),
					Float.parseFloat(firstLineParts[i + 4]));
			bots.get(i / knownAttributeNum).setEnergy(
					Float.parseFloat(firstLineParts[i + 5]));
		}

		background = new Image("res/" + backPic);
		simulating = true;
	}

	@Override
	public void render(GameContainer container, Graphics g)
			throws SlickException {
		// TODO Auto-generated method stub
		background.draw();

		for (Robot b : bots) {
			b.render(container, g);
		}
		// g.fill(new Rectangle(10, 10, 75, 20));

		if (!simulating) {
			g.setColor(Color.red);
			g.fill(new Rectangle(10, 10, 20, 20));
			g.setColor(Color.blue);
		}

		for (Circle p : points) {
			g.draw(p);
		}
		g.setColor(Color.green);
		g.draw(new Point(100, 100));
		float roundOff = (float) Math.round((time / 1000) * 100) / 100;
		g.drawString(Double.toString(roundOff), container.getWidth() - 60,
				container.getHeight() - 20);

		// for(int i = 50; i<=800;i+=50){
		// g.setColor(Color.red);
		// g.draw(new Line(i,0,i,600));
		// g.draw(new Line(0,i,800,i));
		// g.setColor(Color.white);
		// }
	}

	@Override
	public void update(GameContainer container, int delta)
			throws SlickException {
		// TODO Auto-generated method stub

		if (simulating) {
			stopWatch += delta;
			if (stopWatch >= timeStep) {
				for (Robot b : bots) {
					// executescript
					String[] lineParts = parseLine(scriptRead);

					if (readFromBotOut) {
						String output = getFullLine(botOut);
						if (output.equals("end")) {
							readFromBotOut = false;
						} else {
							b.setDisplayString(output);
						}
					}

					if (lineParts[0].equals("end")) {
						simulating = false;
						return;
					}
					if (b.name.equals(lineParts[1])) {
						if (lineParts[0].equals("move")) {
							b.setPosition(Float.parseFloat(lineParts[2]),
									Float.parseFloat(lineParts[3]));
							b.setEnergy(Float.parseFloat(lineParts[4]));
						} else if (lineParts[0].equals("angle")) {
							b.setBotDirection(Float.parseFloat(lineParts[2]));
							b.setSenseDirection(Float.parseFloat(lineParts[3]));
							b.setEnergy(Float.parseFloat(lineParts[4]));
						} else if (lineParts[0].equals("sensorangle")) {
							b.setSenseDirection(Float.parseFloat(lineParts[2]));
							b.setEnergy(Float.parseFloat(lineParts[3]));
						} else if (lineParts[0].equals("sense")) {
							b.setSenseLine(Float.parseFloat(lineParts[2]));
							points.add(b.getEndOfSenseLine());
						} else if (lineParts[0].equals("nothing")) {
							// does about what you would expect
						}
					}

				}
				stopWatch -= waitTime;
				time -= timeStep;
				counter++;
				// System.out.println(time + " " + counter);
			}
		}
	}

	private String[] parseLine(ScriptReader scriptRead) {

		String line = "";

		line = getFullLine(scriptRead);

		if (line.equals("end")) {
			String[] endString = { "end" };
			return endString;
		}

		String[] lineParts = line.split(" ");

		return lineParts;
	}

	private String getFullLine(ScriptReader reader) {

		String line = "";
		try {
			line = reader.readScriptLine();

		} catch (IOException e) {
			// TODO Auto-generated catch block
			line = "end";
		}
		return line;
	}

}
