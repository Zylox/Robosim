%First part of the field must be name of file.
%Name is of your choosing, but be consistent, it needs to be used in the rest of your program
templateBot.name = "temp";

%This will be the function you initialize any values for your robot in that you want to keep track of
%Replace the temp part with your bots name
%zeroState is a octave struct, so you can dynamically define fields as you wish.
%Ex: zeroState.timesUpdated = 0;
%This will create a field called timesUpdated in zeroState and set it to zero.
function zeroState = tempinit(zeroState)
	
endfunction

%This will be the file that gets called to update your bot.
%Put you logic (or a hook to your logic) here.
%Replace temp with your bot name
%
%oldState is the previous state object (initially the zeroState you initialized)
%This state only holds the values you set as well as a reference to useful values
%useful values are:
%	mu: contains the means for each actions randomness
%	sigma: contains the standard deviations for each actions randomness
%	energy: cost of energy for each action as well as starting energy
%	perStep: the amount of movement for each action per step
%	sensorReading: previous sensor reading
%	botRadius: radius of your bot
%Changing these values doesnt change their value in the simulation so it is in your best intrest to leave them alone
%Other feilds of note:
%	output: this is a string that you can write to. It will appear in the graphical output program
%			It will persist until you change it
%
%You will want to keep the line newState = oldState, otherwise you will lose the state
%command is the command you will pass back as a string (ex. "move 10", "sense")
%see README for all commands
function [command, newState] = tempUpdate(oldState, command)
	
	newState = oldState
	
endfunction