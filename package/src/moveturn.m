%executes move
function [exitCon, bots] = move(x, y, energyCost, names, bots, fid, i, map)
	name = names{i};
	%global bots;
	global botRadius
	
	engReq = energyCost;
	
	if(bots.(name).energy < engReq)
		bots.(name).energy = 0;
		exitCon = 1;
		return;
	endif
	
	bots = adjEnergy(bots, name, -1*engReq);
	
	if(bots.(name).sleep ==1)
		exitCon = 0;
		return;
	endif
	
	
	collided = 0;
	exitCon = 0;

	bots.(name).pos = bots.(name).pos + [x,y];
	nearest = [];
	[collided, nearest] = circleMapCollision(bots.(name).pos(1),bots.(name).pos(2),botRadius, map);
	% if(nearest == [-1,-1,Inf] && collided == 1)
		%handle wall collision here.
	if(length(nearest) == 3 && nearest != [-1,-1, Inf] && collided ==1)

		bots.(name).pos = bots.(name).pos .+ rCollPMAmt(bots.(name).pos, nearest, [x,y], botRadius);
		collided = 0;
		bots.(name).sleep = 1;
	endif
	for(j = 1:nfields(bots))
		if(j != i)
			collided = circleCircleCollision(bots.(names{i}).pos(1), bots.(names{i}).pos(2),bots.(names{j}).pos(1), bots.(names{j}).pos(2), botRadius);
			
		endif
		if(collided ==1)
			distX = bots.(name).pos(1) - bots.(names{j}).pos(1);
			distY = bots.(name).pos(2) - bots.(names{j}).pos(2);
			dirToNear = ([distX,distY] / norm([distX,distY])) .* botRadius;
			dirToNear = dirToNear .+ bots.(names{j}).pos;
			nearest = [dirToNear(1), dirToNear(2), botRadius];
			bots.(name).pos = bots.(name).pos .+ rCollPMAmt(bots.(name).pos,nearest, [x,y], botRadius); 
			bots.(name).sleep = 0;
			collided = 0;
		endif
	endfor
	
	
	if(collided != 0)
		exitCon = 1;
		collided = 0;
	endif 
	

	
	if(exitCon == 1)
		collided = 0;
		increment = .1;
		exitLoop = 1;
		bots.(name).pos = bots.(name).pos - [x,y];

	endif
	
endfunction

function [status, bots] = euclidMove(energyCost, mu, sigma, perStep, bots, names, fid, i, map)
	name = names{i};
	dist = perStep;
	%scale = 2;
	status = "";
	collided = 0;
	
	if(dist > bots.(name).moveCycles)
		dist = bots.(name).moveCycles;
	endif
			
	bots.(name).moveCycles -=dist;
	
	%%dist randomize here
	rnd = 0;
	if(sigma != 0)
		rnd = normrnd (mu, sigma);
	endif
	dist += rnd;
	
	x = dist*cos(toRadians(bots.(name).angle));
	y = dist*sin(toRadians(bots.(name).angle));

	% if(x < .000000001)
		% x = 0;
	% endif
	% if(y < .000000001)
		% y = 0;
	% endif
	
	[collided, bots] = move(x, y, energyCost, names, bots, fid, i, map);
	fputs(fid, cstrcat("move ", name, " ", num2str(bots.(name).pos(1)), " ", num2str(bots.(name).pos(2)), " ", num2str(bots.(name).energy), "\n"));
	
	
	if(collided == 1)
		status = "end";
		return;
	endif

	if(bots.(name).moveCycles <= 0)
		status = "endmove";
		return;
	endif

endfunction

function [bots,status] = turn(energyCost, bots, name, angle)
	engReq = energyCost;
	status = "";
	if(bots.(name).energy < engReq)
		bots.(name).energy = 0;
		status = "endturn";
		return;
	endif
	bots = adjEnergy(bots, name, -1*engReq);
	
	bots.(name).angle += angle;
	badDesignChoices = "";
	[bots, badDesignChoices] = turnSensor(0, bots, name, angle);
	
	if(bots.(name).angle > 360)
		bots.(name).angle -=360;
	elseif(bots.(name).angle <0)
		bots.(name).angle +=360;
	endif
	

	
	if(bots.(name).turnAmount<=0)
		status = "endturn";
	endif
endfunction

function radians = toRadians(degrees)
	radians = degrees * pi/180;
endfunction

function [bots,status] = incrementalTurn(energyCost, mu, sigma, perStep, bots, name, fid)
	increment = perStep;
	if(bots.(name).turnAmount < increment)
		increment = bots.(name).turnAmount;
	endif
	
	bots.(name).turnAmount -= increment;
	
	%%randomize here
	rnd = 0;
	if(sigma != 0)
		rnd = normrnd (mu, sigma);
	endif
	
	status = "";
	[bots, status] = turn(energyCost, bots, name, (increment*bots.(name).turnDir) + rnd);

	fputs(fid, cstrcat("angle ", num2str(name), " ", num2str(bots.(name).angle), " ", num2str(bots.(name).sensorAngle), " ", num2str(bots.(name).energy), "\n"));
endfunction

function bots = initIncTurn(bots, name, angle)
		if(angle < 0)
			bots.(name).turnDir = -1;
		else
			bots.(name).turnDir = 1;
		endif
		
		bots.(name).turnAmount = abs(angle);
endfunction