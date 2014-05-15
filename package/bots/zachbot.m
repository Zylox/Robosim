zachbot.name = "zchb93";

zchb93Angle = 0;

function zeroState = zchb93init(zeroState)
	zeroState.moveCounter = 0;
	zeroState.turnAmt = 0;
	zeroState.turnDirection = 1;
	zeroState.senseTiming = 0;
endfunction

function [command, newState] = zchb93Update(oldState, command)
	
	newState = oldState;
	
	if(mod(newState.moveCounter,2) == 0)
		command = "turn 2";
		newState.output = "turning 2";
		newState.moveCounter = 0;
	else
		command = "move 10";
		newState.output = "moving 10";

	endif
	newState.moveCounter +=1;
	return;
	
	
endfunction

