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
	if(mod(newState.moveCounter,2) == 0)
		command = "move 1000";
		newState.output = "GO GO";
	else
		command = "move 10";
		newState.output = "";
	endif
	
	
endfunction