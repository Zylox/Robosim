How To Use:
------------------------------------------
Written by Zachary Higginbotham  


Goal Of this Program:
--------------------
This program is designed to assist students learning techniques in data fusion and information filtering
by providing a simulation of virtual robots which they can program using whatever logic for localization they desire and interfacing
with the simulation using a simple api. Ultimately, the user will have to keep track of what they think their position is and orientation from their limited info on the enviroment gathered through the sensor. Actions, such as moving, turning, reading from a sensor, all take energy, which is a limited resource. Time is also a factor, as there is a limit.
There is a degree of randomness from a normal distribution added to each action which the user must devise methods to overcome. All of these variables can be changed in the config file.
The bot's only view of the world is through its sole sensor placed at its center that can take a reading of the distance to the nearest object in the direction it is facing.
The language the user will be programming the bots in is Octave, a GNU version of MATLAB.

Setup Instructions:
--------------------
You will need to install octave. For windows I would recommend using the cygwin package, but http://octave.sourceforge.net/ also has installers for windows and mac.
For Linux, its a bit more complicated, but can be found by googling.
You will also need to have java runtime environment installed, which many people probably already do.
If you end up getting an error about the java not working and you have it installed, try adding java to your system path.

To run:
-------
If you can run octave from the command line however you installed it, you run it by navigating to this folder and typing
```
    octave Roboloop.m <any command line arguments>
```
If you jsut have the octave console, you can run it by calling
```
    system("XXX")
```
where xxx is the above code.
An example complete exection line might be:
```
    octave Roboloop.m  -m starmap.png -b zachbot -debug -rs -norand
```
Multiple bots can be run at the same time, but there may be an error in this presently. Beware.


Example use:
---------------
To program your own robot, you will want to start with the template robot file, which is provided. See that file for specifics.
The user will initialize values they need to keep track of in the init function.
All update logic takes place in the update function. This is where you will implement the logic of your bot.
Full documentation for this is can be found in the template bot.
After processing your data as you see fit, you will have to decide what to do. 
There is a string variable called command that gets passed to you and passed back at the end.
This is where you fill in your command.
All commands will execute over multiple steps and then control will be handed back to you.



Quick things of note:
---------------------
* Bots are circles. 
* In the state object that gets passed to update, there is a field called output that you can put a string in.
  This string will appear on the graphics program when run. It is a persistent string until you change it, so you don't have to set it every cycle
* Actions have an energy cost, specified in the config file.
* All randomness is from a normal distribution with mu and sigma specified in config file.
  
  
Commands available to you are:
------------------------------
These commands should all be set during the update function of your robot. They are set in a string called command. This string has to returned before it can execute mind you, it isn't magic.
* "move X" - This will execute a command to move your bot in your current direction by X units.
			 Randomness is added at each step.
			 Limitations: only movement forward is allowed currently. Absolute value of X is taken.
* "turn X" - This will turn your bot by X degrees. 
			 Randomness is added at each step.
			 Positive values turn right, negative turn left.
* "turnSensor X" - This will turn your sensor by X degrees. Sensor is located at the center of your bot.
					Randomness is added at each step.
				   Positive values turn right, negative turn left.
* "sense" - This executes a sensor reading. The value is returned to you in your state object under sensorReading
			Randomness is added to the final value found.
* "finished" - this tells the program you are done. Your bot will not update after this command.
* no command or "update" - does nothing this cycle, returns to update next cycle.
  
  
Octave command line arguments:
------------------------------
There are several command line arguments you can use to designate your bots, map, modes, and so forth.
Command line arguments can be added on the command line or in the config file (more on the config file below)
Arguments:
* -config XXX.m - If you are using a config file other than the default one, this is how you specify it.
				  If you are using this, it must be the first argument. Replace XXX with file name.
* -m XXX.m	- Specifies the map you are using. Maps are generated by an included program from a picture format.
			  Map files will usually be called something like map.png.m (generator names them this).
			  Replace XXX with map name.
			  This must be passed in before any bots are.
* -b XXX.m	- Specifies a bot file for the program. Replace XXX with bot's file name
* -debug 	- Turns on debug text. Program will be mostly text silent while running without this command.
			  What it outputs right now is most likely not very useful for your purposes, but this wil be improved.
* -rs		- Runs the graphics program immediately after finishing simulation.
* -rps		- Runs the previously calculated simulation. This command should be called as the only command line argument when using it
* -norand	- Turns off all randomness. Good for debugging without having to change config file.


Config file
-----------
The config file allows you tweak values important to the simulation easily.
These values include:
* starting energy
* energy consumed by various actions
* sigmas for various actions
* mus for various actions
* amount of movement per step for various actions
* in simulation time simulation should run for in milliseconds (not real world time)
* how many milliseconds each step should take in simulation time (not real world time)
* radius of the bot
* a field for default command line arguments, in case you get tired of specifying the map or want to have a fully functional preset setting file.

This file lets you tweak values all in one place, as well as lets the professor specify all simulation settings from one file for say, an assignment.


Helper functions
----------------
There are some functions the simulation uses that you are welcome to use yourself. None of them are difficult to implement yourself but they are there if you want them.
* radians = toRadians(degrees) - converts a degree value to radians. (remember octave uses radians for trig functions)

Notes on Graphics program
-------------------------
* all bots are currently green
* the red line is your bots direction
* the black line is the sensors direction
* the sense line appears for one frame when taking a reading
* little blue circles appear to show where it hit
* hitting q will turn off the background. The sensor circles will stay. Creates a kinda view of what your bot knows about the world
* p pauses the simulation.
* the black number above the bot is your energy
* a red square appears when paused in the top left
* time is in the bottom right
* bottom left is the stuff included in output from the bot state object
