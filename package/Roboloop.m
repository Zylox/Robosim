%!C:\cygwin64\bin\octave -qf
%!D:\cygwin64\bin\octave -qf
%!C:\Software\Octave-3.6.4\bin\octave -qf



clear;

%windows execution
% system("octave Roboloop.m -m mizzouboogaloo -b zachbot -b fergbot")

%%%loads helper files
%handles moving and turning of bot
source("src/moveturn.m");
%all collision detection logic
source("src/collision.m");
%handles sensor movement and ray tracing
source("src/sensor.m");

%%%global variables 
%%kept to a minimum
%even these may disappear in the near future
global botRadius;
global debug = 0;


%assinging initial position
%this is a temporary fix
%i = index of player
%map = the map they bots are on
function [pos,angle] = assignPosAndAng(i, map)
	
	global botRadius;
	
	if(i == 1)
		pos = [200+botRadius,70+botRadius];
		angle = 90;

	elseif(i ==	2)
		pos = [rows(map.map)-botRadius - 600, columns(map.map)-botRadius-100];
		angle = 271;
	else
		pos = [0,0];
		angle = 0;
	endif

	
	
endfunction

%%%%%this function does any initialization needed by to execute the player commands
%%it sets the command state to waht the player specified.
%command = command to initilize
%bots = the bots
%name = the name of the currently selected bot
%fid = the file handle the scirpts are writing to
function bots = initCommand(command, bots, name, fid)
	
														%as long as teh command isnt empty
	if(strcmp(command,"") !=1)							%tokenize it
		commandArgs = strsplit(command, " ");
		dontDo = 0;										%and decide what to do based on the first argument
		switch(commandArgs{1})
			case "finished"								%The player can send a command to say they are done
				bots.(name).alive = 0;					%Sets them to !alive. Also known as dead.
				bots.(name).currentCommand = "finished";
		
			case "move"									%move command
				moves = str2num(commandArgs{2});		%sets how far it needs to move
				if(moves == 0)

					return;
				endif
				bots.(name).moveCycles = abs(moves);
				bots.(name).currentCommand = "move";
			
			case "turn"									%turn command
				turns = str2num(commandArgs{2});		%sets how much the bot needs to turn
				if(turns == 0)

					return;
				endif
				bots = initIncTurn(bots, name, turns);
				bots.(name).currentCommand = "turn";

			
			case "turnSensor"							%turn sensor command
				turns = str2num(commandArgs{2});		%turns how much the bot sensor needs to turn, similar to regular turn
				if(turns == 0)
					fputs(fid, cstrcat("sensTurnis0 ", name, "\n"));
					return;
				endif
				bots = initSensorIncTurn(bots, name, turns);
				bots.(name).currentCommand = "turnSensor";

		
			case "sense"								%Sense distance
				bots.(name).currentCommand = "sense";	%sets current state to sensing
			
			otherwise
				bots.(name).currentCommand = "update";	%if no command was given, set state to update to pass 
				dontDo = 1;								%back to player for further instruction.
		endswitch
		
	else
		bots.(name).currentCommand = "update";			%if command was blank, hand back to player with update
	endif	
		
	
endfunction

%%%Contains logic to actually execute commands
%energy: energy cost of each action
%mu: the mean value for the normal random distributions for each action
%sigma: the standard deviation for the normal random distributions for each action
%perStep: the amount each action moves each turn
%bots: the bots
%names: names of the bots
%fid: file handle for file that script is writing to
%i: index of bot
%map: the map
function [bots, executionMessage] = doCommand(energy, mu, sigma, perStep, bots, names, fid, i, map)
	name = names{i};									%get the current bot from the list
	executionMessage = "";								%initialize the passback string

	switch(bots.(name).currentCommand)					%switch based on current state
	
		case "finished"									%if bot is finished, prints out that it is finished if debug is enabled
			
			debugDisp(cstrcat(name ," is finished"))
			
		case "move"										%executes a euclidian incremental move
			[executionMessage, bots] = euclidMove(energy.moveEnergyCost, mu.movementMu, sigma.movementSigma, perStep.move, bots, names, fid, i, map);
			
			debugDisp(name)
			debugDisp(bots.(name).pos)
			debugDisp(bots.(name).moveCycles)
			
		case "turn"										%executes imremental turn
			[bots,executionMessage] = incrementalTurn(energy.turnEnergyCost, mu.turningMu, sigma.turningSigma, perStep.turn, bots, name, fid);
			
			debugDisp(name)
			debugDisp(bots.(name).angle)
			
		case "turnSensor"								%executes the sensor turn
			[bots,executionMessage] = sensorIncrementalTurn(energy.turnSensorEnergyCost, mu.turningSensorMu, sigma.turningSensorSigma, perStep.sensorTurn, bots, name, fid);
			
			debugDisp(name)
			debugDisp(bots.(name).sensorAngle)
			
		case "update"									%executes and update
			command = "";								
			bots.(name).sleep = 0;						%wakes up the bot in case it was sleeping
			[command, bots.(name).dataStruct] = feval(bots.(name).update, bots.(name).dataStruct, command);		%executes the players update function
			bots = initCommand(command, bots, name, fid); %initilizes this command
			if(strcmp(bots.(name).currentCommand, "update") == 1)	%if it returns update again, return now to avoid recursion
					fputs(fid, cstrcat("updateOrNoCommand ", name, "\n"));
					return;
			endif
														%executes the first step of the command immediately if not update
			[bots, executionMessage] = doCommand(energy, mu, sigma, perStep, bots, names, fid, i, map);
			
		case "sense"									%executes a sensor reading
			bots.(name).dataStruct.sensorReading = sense(energy.sensingEnergyCost, mu.sensingMu, sigma.sensingSigma, bots, names, i, map);
			bots.(name).currentCommand = "update";		%sets teh state back to update, sense is a 1 turn action
			fputs(fid, cstrcat("sense ", name, " ", num2str(bots.(name).dataStruct.sensorReading) , "\n"));
			
		case "outofenergy"
			fputs(fid, cstrcat("outofenergy ", name, "\n"));%if bot runs out of energy, their state becaomse outofenergy
			
			debugDisp(cstrcat(name, " Is out of energy"));
		
		otherwise 
			fputs(fid, cstrcat("nothing/wrongCommand ", name, "\n"));	%error hanlding state, although this shouldnt happen
																		%included for completness
			debugDisp(cstrcat(name, " is doing nothing or unrecognized command ", bots.(name).currentCommand));
			
	endswitch

endfunction


%%adjusts energy
%bots: the bots
%name: name of current bot
%energy: energy to adjust by
function bots = adjEnergy(bots, name, energy)
	bots.(name).energy += energy;
endfunction

%%%function that will run the java simulation
%runs on unix, pc, or mac
function runSim()
	if(isunix())
		unix("java -jar farjar.jar");
	elseif(ispc())
		dos("java -jar farjar.jar");
	elseif(ismac())
		unix("java -jar farjar.jar");
	else
		disp("Operating System not recognized, good job");
	endif 
endfunction

%%%function to display text when debug display is turned on
function debugDisp(string)
	global debug;
	if(debug == 1)
		disp(string);
	endif
endfunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Script start proper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time1 = clock();							%records time when simulation starts

bots = struct();							%initilizes the bot structure		
map = struct();								%initilizes the map
time = 0;									%time variable to be read in
debug = 0;									%debug determines if the debugDisp function works
names = {};									%initialize names, the names of the bots
playercount = 0;							
arguments = argv();							%takes in command line arguments

offset = 1;									%use this variable to offset whether non defualt config was taken in or not
runS = 0;									%variable on whether or not to run the graphics immediately after

if(strcmp(arguments{1}, "-c") || strcmp(arguments{1}, "-config"))	%checks whether or not a config file is included in command line
	source(strcat(arguments(2), ".m"));		
	commandArgs = strsplit(defaultCommandLineArgs, " ");
			
	moreArgs = mat2cell(commandArgs, 1);
	arguments = {arguments{:}, moreArgs{1,1}{:}};
	offset = 3;
else										%if not, uses default
	source("config.m");
	commandArgs = strsplit(defaultCommandLineArgs, " ");
			
	moreArgs = mat2cell(commandArgs, 1);
	arguments = {arguments{:}, moreArgs{1,1}{:}};	%adds default command line arguments from file
	
endif

argSize = size(arguments(1,:));	%complicated access stuff that i dont fully understand
argSize = argSize(2);			%for some reason this construct is not single dimensional so it has to be accessed like this
for(i = offset:argSize)

	switch(arguments{i})
		case "-norand"						%sets the randomness to 0
			sigma.movementSigma = 0;		%useful for debugging
			sigma.turningSigma = 0;
			sigma.turningSensorSigma = 0;
			sigma.sensingSigma = 0;

			mu.movementMu = 0;
			mu.turningMu = 0;
			mu.turningSensorMu = 0;
			mu.sensingMu = 0;
	
		case "-rps"							%Run Previous Simulation
			runSim();						%will run previously generated script
			exit();							% should be called solely by itself
			
		case "-rs"							%run simulation
			runS = 1;						%will run the graphics when done with simulation
			
		case "-m"							%the map to be read in
			%initalizing map
			i++;
			%disp(ccstrcat(arguments(1,i), ".m"));
			source(cstrcat("maps/",char(arguments(i)), ".m"));
			map.name = eval(strcat(arguments(i),".name"));
			map.map = eval(strcat(arguments(i),".map"));
			map.miniMap = eval(strcat(arguments(i),".miniMap"));
			map.blockSize = eval(strcat(arguments(i),".blockSize"));
			map.dims = [columns(map.map), rows(map.map)];
			disp("map read in");
		
		case "-b"							%reads in a bot
			i++;							%initilizes all the feilds
			playercount++;
			source(cstrcat("bots/",char(arguments(i)), ".m"));
			x = eval(strcat(arguments(i),".name"));
		
			bots.(x).update = strcat(x, "Update");
			zeroState = struct();			%structure that is passed to player for state their state tracking
			zeroState.sensorReading = 0;	%field that the sensor stores results
			zeroState.output = "";			%players can write to this feild to display a string on the screen during graphics
			zeroState.mu = mu;				%provides the current means to the player
			zeroState.sigma = sigma;		%and the sigmas
			zeroState.energy = energy;		%and the energy
			zeroState.perStep = perStep;	%and how much things move
			zeroState.botRadius = botRadius;	%and just for completions sake, the radius of the bot
			bots.(x).dataStruct = feval(strcat(x, "init"),zeroState);
			bots.(x).energy = energy.startingEnergy;	%adds starting energy to feild
			[bots.(x).pos, bots.(x).angle] = assignPosAndAng(playercount, map);	
			bots.(x).turnAmount = 0;		%feilds needed for other actions
			bots.(x).turnDir = 1;
			bots.(x).sensorAngle = bots.(x).angle;
			bots.(x).sensorTurnAmount = 0;
			bots.(x).sensorTurnDir = 1;
			bots.(x).alive = 1;				%tracks if the bot is dead or alive
			bots.(x).sleep = 0;				%tracks if it has been put to sleep for movement

			
			bots.(x).moveCycles = 0;
			bots.(x).currentCommand = "update";	%initilizes first state to update
			names{playercount} = x;
		case "-debug"
			debug = 1;
		otherwise
			%disp("nothing for some reason"); %this should never happen
	endswitch
endfor


disp(bots);	%display initialized bots before simulation
	
filename = "botScript.txt"; 					%file that script will be written to
fid = fopen (filename, "w");					
botOutFile = "botMessages.txt";					%file that the players messages will be written to
botOut = fopen (botOutFile, "w");


disp(names);									%initial info for the simulation, such as
fputs(fid, cstrcat(num2str(botRadius), "\n"));	%botRadius
fputs(fid, cstrcat(map.name, "\n"));			%map
fputs(fid, cstrcat(num2str(time), "\n"));		%time
fputs(fid, cstrcat(num2str(timeStep), "\n"));	%and time step
for(i = 1:length(names))						%bots initial info, names, position, angle, sensorAngle, and energy
	fputs(fid, cstrcat(names{i}, " ", num2str(bots.(names{i}).pos(1)), " ", num2str(bots.(names{i}).pos(2)), " ",num2str(bots.(names{i}).angle), " ",num2str(bots.(names{i}).sensorAngle), " ", num2str(bots.(names{i}).energy)," "));
endfor

fputs(fid, "\n");		

endSim = 0;		
timeOff = 0;	

if(time<=0)				%turns time off if time is less than or equal to zero to begin with
	timeOff = 1;
endif
%%%%%%%%%%%%%%%---------%%%%%%%%%%%%%%
%%%%%%%--------Game Loop--------%%%%%%
while (endSim !=1)
	global botRadius;
	aliveCheck = 0;
	for(i = 1:nfields(bots))		%executes each bot in order
		[bots, commandStatus] = doCommand(energy, mu, sigma, perStep, bots, names, fid, i, map);	%first execute command

		fputs(botOut, cstrcat(names{i}, ": ", bots.(names{i}).dataStruct.output, "\n"));			%writes the player message to botmessages
		
		if(bots.(names{i}).energy == 0)							%if energy has run out, set the state to outofenergy and dead
			bots.(names{i}).currentCommand = "outofenergy";
			bots.(names{i}).alive = 0;
		endif
		
		if(strcmp(commandStatus, "endmove") || strcmp(commandStatus, "endturn"))	%sets state back to update when previous command is done
			bots.(names{i}).currentCommand = "update";
		endif
				
		if(strcmp(commandStatus, "end"))	%placeholder if any end stuff needs to be done.
		
		endif
		aliveCheck += bots.(names{i}).alive; %cehcks how many bots are alive
		
	endfor
	time-=timeStep;		%decrements time left
	debugDisp(cstrcat("time: ", num2str(time)));
	if((time <=0 && timeOff != 1) || aliveCheck == 0)	%if time is out and nothing is alive
		endSim =1;
		break;
	endif
		
endwhile

debugDisp(bots)

fputs(fid, "end");		%ends files
fclose (fid);
fputs(botOut,"end");
fclose (botOut);
disp("time elapsed");
disp(etime(clock(), time1))		%displays time passed for simluation to run
if(runS == 1)					%runs graphics if set at beggining
	runSim();
endif

disp("done");


clear;							%clears octave. probably doesnt do anything but doesnt hurt either.