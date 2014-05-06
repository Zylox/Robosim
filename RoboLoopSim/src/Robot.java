
import org.newdawn.slick.Color;
import org.newdawn.slick.GameContainer;
import org.newdawn.slick.Graphics;
import org.newdawn.slick.SlickException;
import org.newdawn.slick.geom.Circle;
import org.newdawn.slick.geom.Line;
import org.newdawn.slick.geom.Point;
import org.newdawn.slick.geom.Rectangle;


public class Robot {
      
	private int index;
	private Circle body;
	protected String name;
	private Color color;
	private Line direction;
	private Line senseDirection;
	private int radius;
	private float botDir;
	private float senseDir;
	private float energy;
	private Line senseLine;
	private boolean renderSenseLine;
	private String displayString;
	

	public Robot(String name, int index){
		this.name = name;
		this.index = index;
		displayString = "";
		renderSenseLine = false;
	}
	
	public void initBody(int x, int y, int radius, float angle, float senseAng){
		x = x-1;
		y = y-1;
		this.radius = radius;
		body = new Circle(x,y,radius);
		direction = new Line(x, y, (float)(x+radius*Math.cos(angle)), (float)(y+radius*Math.sin(angle)));
		senseDirection = new Line(x, y, (float)(x+radius*Math.cos(senseAng)), (float)(y+radius*Math.sin(senseAng)));
		botDir = angle;
		senseLine = new Line(-1, -1, -1, -1);
		senseDir = senseAng;
	}
	
	public void setPosition(float x, float y){
		x = x-1;
		y = y-1;
		body.setCenterX(x);
		body.setCenterY(y);
		setBotDirection(botDir);
		setSenseDirection(senseDir);
	}
	
	public void setEnergy(float energy){
		this.energy = energy;
	}
	
	public void setBotDirection(float angle){
		float x = body.getCenterX();
		float y = body.getCenterY();
		botDir = angle;
		direction.set(x, y, (float)(x+radius*Math.cos(Math.toRadians(angle))), (float)(y+radius*Math.sin(Math.toRadians(angle))));
	}
	
	public void setSenseDirection(float angle){
		float x = body.getCenterX();
		float y = body.getCenterY();
		senseDir = angle;
		senseDirection.set(x, y, (float)(x+(radius/2)*Math.cos(Math.toRadians(angle))), (float)(y+(radius/2)*Math.sin(Math.toRadians(angle))));
	}
	
	public void setSenseLine(float length){
		float x = body.getCenterX();
		float y = body.getCenterY();
		renderSenseLine = true;
		senseLine.set(x, y, (float)(x+length*Math.cos(Math.toRadians(senseDir))), (float)(y+length*Math.sin(Math.toRadians(senseDir))));
		
	}
	
	public Circle getEndOfSenseLine(){
		return new Circle(senseLine.getEnd().x, senseLine.getEnd().y, 1);
	}
	
	public void render(GameContainer container, Graphics g) throws SlickException {
		g.setColor(Color.green);
		g.fill(body);
		g.setColor(Color.red);
		g.draw(direction);
		g.setColor(Color.black);
		g.draw(senseDirection);
		if(renderSenseLine){
			g.setColor(Color.black);
			g.draw(senseLine);
			renderSenseLine = false;
			g.draw(new Circle(senseLine.getEnd().x,senseLine.getEnd().y, 10));
		}
		
		g.setColor(Color.black);
		String ener = Float.toString(energy);
		g.drawString(ener, body.getCenterX()-(ener.length()*10)/2, body.getCenterY()-radius - 15);
		g.setColor(Color.blue);
		g.drawString(displayString, 5, container.getHeight()-(15*index) -20);
	}
	
	public String getDisplayString() {
		return displayString;
	}
	
	public void setDisplayString(String displayString) {
		this.displayString = displayString;
	}
	
}
