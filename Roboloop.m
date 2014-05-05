#!C:\cygwin64\bin\octave -qf
%!D:\cygwin64\bin\octave -qf
%!C:\Software\Octave-3.6.4\bin\octave -qf



clear;

%windows execution
% system("octave Roboloop.m -m mizzouboogaloo -b zachbot -b fergbot")

source("moveturn.m");
source("collision.m");
source("sensor.m");

global botRadius;
global map;
global time = 0;
global debug = 0;


%assinging initial position
function [pos,angle] = assignPosAndAng(i)
	global map;
	global botRadius;
	
	if(i == 1)
		pos = [200+botRadius,100+botRadius];
		angle = 91;

	elseif(i ==	2)
		pos = [rows(map.map)-botRadius - 350, columns(map.map)-botRadius-400];
		angle = 271;
	else
		pos = [0,0];
		angle = 0;
	endif
	
	
endfunction

function bots = initCommand(command, bots, name, fid)
	if(strcmp(command,"") !=1)
		commandArgs = strsplit(command, " ");
		dontDo = 0;

		if(strcmp(commandArgs(1),"finished"))
			bots.(name).alive = 0;
			bots.(name).currentCommand = "finished";
		
		elseif(strcmp(commandArgs(1),"move"))
			moves = str2num(commandArgs{2});
			if(moves == 0)
				%fputs(fid, cstrcat("moveIs0 ", name, "\n"));
				return;
			endif
			bots.(name).moveCycles = moves;
			bots.(name).currentCommand = "move";
			%fputs(fid, cstrcat("setMove ", name, "\n"));
			
		elseif(strcmp(commandArgs(1),"turn"))
			turns = str2num(commandArgs{2});
			if(turns == 0)
				%fputs(fid, cstrcat("turnIs0 ", name, "\n"));
				return;
			endif
			bots = initIncTurn(bots, name, turns);
			bots.(name).currentCommand = "turn";
			%fputs(fid, cstrcat("setTurn ", name, "\n"));
			
		elseif(strcmp(commandArgs(1),"turnSensor"))
			turns = str2num(commandArgs{2});
			if(turns == 0)
				fputs(fid, cstrcat("sensTurnis0 ", name, "\n"));
				return;
			endif
			bots = initSensorIncTurn(bots, name, turns);
			bots.(name).currentCommand = "turnSensor";
			%fputs(fid, cstrcat("setSensorTurn ", name, "\n"));
		
		elseif(strcmp(commandArgs(1),"sense"))
			%bots.(name).currentCommand = "sense";
			bots.(name).currentCommand = "sense";
			
			
		else
			%fputs(fid, cstrcat("invalid ", name, "\n"));
			bots.(name).currentCommand = "update";
			dontDo = 1;
		endif
		
	else
		%fputs(fid, cstrcat("null ", name, "\n"));
		bots.(name).currentCommand = "update";
	endif	
		
	
endfunction

function [bots, executionMessage] = doCommand(energy, mu, sigma, bots, names, fid, i)
	name = names{i};
	executionMessage = "";

	switch(bots.(name).currentCommand)
	
		case "finished"
			
			debugDisp(cstrcat(name ," is finished"))
			
		case "move"
			[executionMessage, bots] = euclidMove(energy.moveEnergyCost, mu.movementMu, sigma.movementSigma, bots, names, 1, fid, i);
			
			debugDisp(name)
			debugDisp(bots.(name).pos)
			debugDisp(bots.(name).moveCycles)
			
		case "turn"
			[bots,executionMessage] = incrementalTurn(energy.turnEnergyCost, mu.turningMu, sigma.turningSigma, bots, name, fid);
			
			debugDisp(name)
			debugDisp(bots.(name).angle)
			
		case "turnSensor"
			[bots,executionMessage] = sensorIncrementalTurn(energy.turnSensorEnergyCost, mu.turningSensorMu, sigma.turningSensorSigma, bots, name, fid);
			
			debugDisp(name)
			debugDisp(bots.(name).sensorAngle)
			
		case "update"
			command = "";
			bots.(name).sleep = 0;
			[command, bots.(name).dataStruct] = feval(bots.(name).update, bots.(name).dataStruct, command);
			bots = initCommand(command, bots, name, fid);
			if(strcmp(bots.(name).currentCommand, "update") == 1)
					fputs(fid, cstrcat("updateOrNoCommand ", name, "\n"));
					return;
			endif
			
			[bots, executionMessage] = doCommand(energy, mu, sigma, bots, names, fid, i);
			
		case "sense"
			bots.(name).dataStruct.sensorReading = sense(energy.sensingEnergyCost, mu.sensingMu, sigma.sensingSigma, bots, names, i);
			bots.(name).currentCommand = "update";
			fputs(fid, cstrcat("sense ", name, " ", num2str(bots.(name).dataStruct.sensorReading) , "\n"));
			
		case "outofenergy"
			fputs(fid, cstrcat("outofenergy ", name, "\n"));
			
			debugDisp(cstrcat(name, " Is out of energy"));
		
		otherwise 
			fputs(fid, cstrcat("nothing/wrongCommand ", name, "\n"));
			
			debugDisp(cstrcat(name, " is doing nothing or unrecognized command ", bots.(name).currentCommand));
			
	endswitch

endfunction



function bots = adjEnergy(bots, name, energy)
	bots.(name).energy += energy;
endfunction

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

function debugDisp(string)
	global debug;
	if(debug == 1)
		disp(string);
	endif
endfunction

function [configSet, commandArgs] = loadConfig(arguments, i)
	source(strcat(arguments(i), ".m"));
	commandArgs = strsplit(defaultCommandLineArgs, " ");
			
	moreArgs = mat2cell(commandArgs, 1);
	arguments = {arguments{:}, moreArgs{1,1}{:}};
	disp(moreArgs);
	disp(arguments);
	configSet = 1;
	
endfunction



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%Script start proper
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%taking in command line arguments
time1 = clock();
botScripts = argv();

bots = struct();
%debug = 0;
names = {};
playercount = 0;
arguments = argv();

offset = 1;
runS = 0;

if(strcmp(arguments{1}, "-c") || strcmp(arguments{1}, "-config"))
	source(strcat(arguments(2), ".m"));
	commandArgs = strsplit(defaultCommandLineArgs, " ");
			
	moreArgs = mat2cell(commandArgs, 1);
	arguments = {arguments{:}, moreArgs{1,1}{:}};
	offset = 3;
else
	source("config.m");
	commandArgs = strsplit(defaultCommandLineArgs, " ");
			
	moreArgs = mat2cell(commandArgs, 1);
	arguments = {arguments{:}, moreArgs{1,1}{:}};
	
endif

argSize = size(arguments(1,:));
argSize = argSize(2);
for(i = offset:argSize)

	switch(arguments{i})
		case "-norand"
			sigma.movementSigma = 0;
			sigma.turningSigma = 0;
			sigma.turningSensorSigma = 0;
			sigma.sensingSigma = 0;

			mu.movementMu = 0;
			mu.turningMu = 0;
			mu.turningSensorMu = 0;
			mu.sensingMu = 0;
	
		case "-rps"
			runSim();
			exit();
			
		case "-rs"
			runS = 1;
			
		case "-m"
			%initalizing map
			i++;
		
			source(strcat(arguments(i), ".m"));
			map.name = eval(strcat(arguments(i),".name"));
			map.map = eval(strcat(arguments(i),".map"));
			map.miniMap = eval(strcat(arguments(i),".miniMap"));
			map.blockSize = eval(strcat(arguments(i),".blockSize"));
			map.dims = [columns(map.map), rows(map.map)];
			disp("map read in");
		
		case "-b"
			i++;
			disp(i);
			playercount++;
			source(strcat(arguments(i), ".m"));
			x = eval(strcat(arguments(i),".name"));
		
			bots.(x).update = strcat(x, "Update");
			zeroState = struct();
			zeroState.sensorReading = 0;
			zeroState.output = "";
			bots.(x).dataStruct = feval(strcat(x, "init"),zeroState);
			[bots.(x).pos, bots.(x).angle] = assignPosAndAng(playercount);
			bots.(x).turnAmount = 0;
			bots.(x).turnDir = 1;
			bots.(x).sensorAngle = bots.(x).angle;
			bots.(x).sensorTurnAmount = 0;
			bots.(x).sensorTurnDir = 1;
			bots.(x).alive = 1;
			bots.(x).sleep = 0;

			
			bots.(x).moveCycles = 0;
			bots.(x).currentCommand = "update";
			names{playercount} = x;
			disp(bots);
		case "-debug"
			debug = 1;
		otherwise
			%disp("nothing for some reason");
	endswitch
endfor


disp(bots);


for(i = 1:nfields(bots))
	bots.(names{i}).energy = energy.startingEnergy;
endfor
	
filename = "botScript.txt";
fid = fopen (filename, "w");
botOutFile = "botMessages.txt";
botOut = fopen (botOutFile, "w");


disp(names);
disp(bots);
fputs(fid, cstrcat(num2str(botRadius), "\n"));
fputs(fid, cstrcat(map.name, "\n"));
fputs(fid, cstrcat(num2str(time), "\n"));
fputs(fid, cstrcat(num2str(timeStep), "\n"));
for(i = 1:length(names))
	fputs(fid, cstrcat(names{i}, " ", num2str(bots.(names{i}).pos(1)), " ", num2str(bots.(names{i}).pos(2)), " ",num2str(bots.(names{i}).angle), " ",num2str(bots.(names{i}).sensorAngle), " ", num2str(bots.(names{i}).energy)," "));
endfor

fputs(fid, "\n");


%x = eval(strcat(bots(i),".name"));
%b = "ngfnbf";

%bots((x(i))) = strcat(x(i), "Update");
%bots.(b) = strcat(b, "Update");

%disp(bots)
%evaluation loop
collided = 0;
timeOff = 0;

if(time<=0)
	timeOff = 1;
endif

while (collided !=1)
	global botRadius;
	aliveCheck = nfields(bots);
	for(i = 1:nfields(bots))
		%disp(bots.(names{i}).still);
		
		[bots, commandStatus] = doCommand(energy, mu, sigma, bots, names, fid, i);

		fputs(botOut, cstrcat(names{i}, ": ", bots.(names{i}).dataStruct.output, "\n"));
		
		if(bots.(names{i}).energy == 0)
			bots.(names{i}).currentCommand = "outofenergy";
			bots.(names{i}).alive = 0;
		endif
		
		if(strcmp(commandStatus, "endmove") || strcmp(commandStatus, "endturn"))
			bots.(names{i}).currentCommand = "update";
		endif
				
		if(strcmp(commandStatus, "end"))

		endif
		
		if(collided == 1)
			break;
		endif
		aliveCheck += bots.(names{i}).alive;
		
	endfor
	time-=timeStep;
	debugDisp(cstrcat("time: ", num2str(time)));
	if((time <=0 && timeOff != 1) || aliveCheck == 0)
		collided =1;
		break;
	endif
		
endwhile

debugDisp(bots)

fputs(fid, "end");
fclose (fid);
fputs(botOut,"end");
fclose (botOut);
if(runS == 1)
	runSim();
endif

disp("done");
disp("time elapsed");
disp(etime(clock(), time1))

clear;




