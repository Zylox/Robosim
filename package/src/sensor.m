%%%functions that turns sensor
%energyCost: cost to turn
%bots: the bots
%name: name of current bot
%angle: angle to turn by
function [bots,status] = turnSensor(energyCost, bots, name, angle)
	engReq = energyCost;
	status = "";
	if(bots.(name).energy < engReq)				%if energy is not enough energy is consumed but action doesnt happen
		bots.(name).energy = 0;
		status = "endturn";
		return;
	endif
	bots = adjEnergy(bots, name, -1*engReq);
	
	bots.(name).sensorAngle += angle;			
	if(bots.(name).sensorAngle > 360)
		bots.(name).sensorAngle -=360;
	elseif(bots.(name).sensorAngle <0)
		bots.(name).sensorAngle +=360;
	endif
	if(bots.(name).sensorTurnAmount<=0)			%if sensor has turned full amount, end
		status = "endturn";
	endif
endfunction

%%%Helper function for turn
%energyCost: energyCost of snesor turn
%mu: mean of movement randomness
%sigma: standard deviation of randomness
%perStep: how much to move a turn
%bots: the bots
%name: the name of the current bot
%fid: file handle of script file
function [bots,status] = sensorIncrementalTurn(energyCost, mu, sigma, perStep, bots, name, fid)
	increment = perStep;
	if(bots.(name).sensorTurnAmount < increment)	%if the amount left to turn is less than amount is left, turn that much
		increment = bots.(name).sensorTurnAmount;	%uses full energy though
	endif
	
	bots.(name).sensorTurnAmount -= increment;		%decrements amount left to turn
	
	%%randomize here
	rnd = 0;
	if(sigma !=0)
		rnd = normrnd (mu, sigma);					%calculate randomness
	endif
	
	status = "";
	[bots, status] = turnSensor(energyCost, bots, name, (increment*bots.(name).sensorTurnDir) + rnd);	%execute the turn

	fputs(fid, cstrcat("sensorangle ", num2str(name), " ", num2str(bots.(name).sensorAngle), " ", num2str(bots.(name).energy), "\n"));	%record new State in file
endfunction

%%%initilization helper function
%bots: the bots
%name: name of current bot
%angle: total angle to turn
function bots = initSensorIncTurn(bots, name, angle)
		if(angle < 0)
			bots.(name).sensorTurnDir = -1; %sets direction
		else
			bots.(name).sensorTurnDir = 1;
		endif
		
		bots.(name).sensorTurnAmount = abs(angle);	%sets absolute value of amount to move
endfunction

%%%actual sense function. Works on raytrace
%energyCost: energy to sense
%mu: mean of randomness
%sigma: standard deviation of randomness
%bots: the bots
%names: the names of the bots
%i: index of the bot
%map: the map
function dist = sense(energyCost, mu, sigma, bots, names, i, map)
	global botRadius;
	name = names{i};
	engReq = energyCost;
	dist = 0;
	if(bots.(name).energy < engReq)			%if energy is insufficient
		bots.(name).energy = 0;				%consume energy and return unexecuted
		return;
	endif
	
	bots = adjEnergy(bots, name, -1*engReq);
	
	%%randomize
	rnd = 0;
	if(sigma != 0)
		rnd = normrnd (mu, sigma);			%generating randomness
	endif
	
	x= bots.(name).pos(1);
	y= bots.(name).pos(2);
	
	moveDist = .5;							%raytrace step amount
											%could be adjusted for greater accuracy
	dx = cos(toRadians(bots.(name).sensorAngle));	%split up step amount into x and y components based on angle
	dy = sin(toRadians(bots.(name).sensorAngle));

	
	collide = 0;
	while (collide == 0)	%ray trace until collision and return value
		x += moveDist*dx;
		y += moveDist*dy;
		dist += moveDist;		%distance traveled
		collide = pixelMapCollision(x,y, map);
		for(j = 1:nfields(bots))
			if(j != i)
				collide += pixelCircleCollision(x,y, bots.(names{j}).pos(1), bots.(names{j}).pos(2), botRadius);
			endif
		endfor
	endwhile
	
	dist += rnd;	%add randomness into the distance found
	
endfunction