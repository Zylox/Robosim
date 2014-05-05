fergbot.name = "ngfnbf";

function zeroState = ngfnbfinit(zeroState)
	zeroState.moveCounter = 0;
	
endfunction


function [command, newState] = ngfnbfUpdate(oldState, command)
	%disp("zachworked");
	%moveBot(5,6,"zchb93");
	%zchb93Angle = 30;
	
	newState = oldState;
	%disp(newState)
	newState.moveCounter +=1;
	if(mod(newState.moveCounter,3) == 0)
		command = "move 10";
		newState.output = "GO GO";
	elseif(mod(newState.moveCounter,3) == 1)
		command = "turn 1";
	else
		command = "";
		newState.output = "";
	endif
	
	
endfunction