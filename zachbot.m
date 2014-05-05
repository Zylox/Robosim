zachbot.name = "zchb93";

zchb93Angle = 0;

function zeroState = zchb93init(zeroState)
	zeroState.moveCounter = 0;
	
endfunction

function [command, newState] = zchb93Update(oldState, command)
	%disp("zachworked");
	%moveBot(5,6,"zchb93");
	%zchb93Angle = 30;
	
	newState = oldState;
	%disp(newState)

	if(mod(newState.moveCounter,4) == 0)
		command = "move 300";
		newState.output = "moving 23";
		% newState.moveCounter = 0;
		newState.output = "turning 33";
	elseif(mod(newState.moveCounter,4) == 1)
		command = "sense";
		newState.output = "sensor turning 27";
	% elseif(mod(newState.moveCounter,4) == 2)
		% command = "sense";
		% newState.output = "voodoo sensing powers";
	else
		command = "finished";
		
	endif
		
    
	newState.moveCounter +=1;
	
endfunction

