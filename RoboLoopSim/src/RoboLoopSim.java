
import org.newdawn.slick.AppGameContainer;
import org.newdawn.slick.GameContainer;
import org.newdawn.slick.SlickException;
import org.newdawn.slick.state.StateBasedGame;

public class RoboLoopSim extends StateBasedGame {

	public static final int SIMULATE_ID = 1;
	
	
	public RoboLoopSim(String title) {
		super(title);
		// TODO Auto-generated constructor stub
	}

	
	public static void main(String[] args) {

		//PictureVConverter.execute("starmap.png");
		
		try{
			AppGameContainer app = new AppGameContainer(new RoboLoopSim("Simulation"));

			app.setDisplayMode(800,600, false);
			app.setAlwaysRender(true);
			app.start();

		}catch(SlickException ex){
			ex.printStackTrace();
		}

	}
	
	
	@Override
	public void initStatesList(GameContainer arg0) throws SlickException {
		// TODO Auto-generated method stub
		this.addState(new Simulate(SIMULATE_ID));
	}

	
	
}
