zachbot.name = "zchb93";

zchb93Angle = 0;

function zeroState = zchb93init(zeroState)
	zeroState.moveCounter = 0;
	zeroState.turnAmt = 0;
	zeroState.turnDirection = 1;
	zeroState.senseTiming = 0;
endfunction

function [command, newState] = zchb93Update(oldState, command)
	%disp("zachworked");
	%moveBot(5,6,"zchb93");
	%zchb93Angle = 30;
	
	newState = oldState;
	%disp(newState)
	
	if(mod(newState.moveCounter,2) == 0)
		command = "turn 2";
		newState.output = "turning 1";
		newState.moveCounter = 0;
	% elseif(mod(newState.moveCounter,4) == 1)
		% command = "move 10";
		% newState.output = "senso";
	% elseif(mod(newState.moveCounter,4) == 2)
		% command = "sense";
		% newState.output = "voodoo sensing powers";
	else
		command = "move 10";

	endif
	newState.moveCounter +=1;
	return;
	
	
endfunction

