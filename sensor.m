function [bots,status] = turnSensor(energyCost, bots, name, angle)
	engReq = energyCost;
	status = "";
	if(bots.(name).energy < engReq)
		bots.(name).energy = 0;
		status = "endturn";
		return;
	endif
	bots = adjEnergy(bots, name, -1*engReq);
	
	bots.(name).sensorAngle += angle;
	% if(bots.(name).sensorAngle > 360)
		% bots.(name).sensorAngle -=360;
	% elseif(bots.(name).sensorAngle <0)
		% bots.(name).sensorAngle +=360;
	% endif
	if(bots.(name).sensorTurnAmount<=0)
		status = "endturn";
	endif
endfunction

function [bots,status] = sensorIncrementalTurn(energyCost, mu, sigma, bots, name, fid)
	increment = 1;
	if(bots.(name).sensorTurnAmount < increment)
		increment = bots.(name).sensorTurnAmount;
	endif
	
	bots.(name).sensorTurnAmount -= increment;
	
	%%randomize here
	rnd = 0;
	if(sigma !=0)
		rnd = normrnd (mu, sigma);
	endif
	
	status = "";
	[bots, status] = turnSensor(energyCost, bots, name, (increment*bots.(name).sensorTurnDir) + rnd);

	fputs(fid, cstrcat("sensorangle ", num2str(name), " ", num2str(bots.(name).sensorAngle), " ", num2str(bots.(name).energy), "\n"));
endfunction

function bots = initSensorIncTurn(bots, name, angle)
		if(angle < 0)
			bots.(name).sensorTurnDir = -1;
		else
			bots.(name).sensorTurnDir = 1;
		endif
		
		bots.(name).sensorTurnAmount = abs(angle);
endfunction

function dist = sense(energyCost, mu, sigma, bots, names, i)
	global botRadius;
	name = names{i};
	engReq = energyCost;
	dist = 0;
	if(bots.(name).energy < engReq)
		bots.(name).energy = 0;
		status = "sense";
		return;
	endif
	bots = adjEnergy(bots, name, -1*engReq);
	
	%%randomize
	rnd = 0;
	if(sigma != 0)
		rnd = normrnd (mu, sigma);
	endif
	
	x= bots.(name).pos(1);
	y= bots.(name).pos(2);
	
	moveDist = .5;
	
	dx = cos(toRadians(bots.(name).sensorAngle));
	dy = sin(toRadians(bots.(name).sensorAngle));

	
	collide = 0;
	while (collide == 0)
		x += moveDist*dx;
		y += moveDist*dy;
		dist += moveDist;
		collide = pixelMapCollision(x,y);
		for(j = 1:nfields(bots))
			if(j != i)
				collide += pixelCircleCollision(x,y, bots.(names{j}).pos(1), bots.(names{j}).pos(2), botRadius);
			endif
		endfor
	endwhile
	
endfunction