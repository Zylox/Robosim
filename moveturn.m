%bots need to call this to mov
function [exitCon, bots] = move(x, y, energyCost, names, bots, fid, i, recurse)
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
	[collided, nearest] = circleMapCollision(bots.(name).pos(1),bots.(name).pos(2),botRadius);
	% if(nearest == [-1,-1,Inf] && collided == 1)
		%handle wall collision here.
	if(length(nearest) == 3 && nearest != [-1,-1, Inf] && collided ==1)

		bots.(name).pos = bots.(name).pos .+ rCollPMAmt(bots.(name).pos, nearest, [x,y], botRadius);
		collided = 0;
		bots.(name).sleep = 1;
	endif
	for(j = 1:nfields(bots))
		if(j != i)
			collided += circleCircleCollision(bots.(names{i}).pos(1), bots.(names{i}).pos(2),bots.(names{j}).pos(1), bots.(names{j}).pos(2), botRadius);
		endif
		if(collided ==1)
			distX = bots.(name).pos(1) - bots.(names{j}).pos(1);
			distY = bots.(name).pos(2) - bots.(names{j}).pos(2);
			twoRad = botRadius * 2;
			radDist = norm([x,y]) .* twoRad;
			distToMove = [distX, distY] + radDist;
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
		% do
			% collided = 0;
			% bots.(name).pos = bots.(name).pos - [x*increment,y*increment];
			% printf("x: %f y: %f\n", (x*increment), bots.(name).pos(1));
			% collided = circleMapCollision(bots.(name).pos(1),bots.(name).pos(2),botRadius);
			% for(j = 1:nfields(bots))
				% if(j != i)
					% collided += circleCircleCollision(bots.(names{i}).pos(1), bots.(names{i}).pos(2),bots.(names{j}).pos(1), bots.(names{j}).pos(2), botRadius);
				% endif

			% endfor

			% if(x*increment < .000001)
				
			% endif
			
			% if(collided == 0 || x*increment < .000001 || y*increment < .000001 )
				
				% if( x*increment < .000001 || y*increment < .000001 )
					% exitLoop = 0;
					
				% endif
				% increment /= 10;
			% endif
		% until(exitLoop == 0)
		% if(recurse >10)
			% if(x < 0)
				% x+=.01;
			% else
				% x-=.01;
			% endif
			
			% if(y < 0)
				% y+=.01;
			% else
				% y-=.01;
			% endif
			% [collided, bots] = move(x, y, 0, names, bots, fid, i, recurse+1);
		% endif
	endif
	
endfunction

function [status, bots] = euclidMove(energyCost, mu, sigma, bots, names, dist, fid, i)
	name = names{i};
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
	
	[collided, bots] = move(x, y, energyCost, names, bots, fid, i, 0);
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

function [status, bots] = bresMove(bots, name, fid)
	scale = 2;
	status = "";
	xMove = 0;
	yMove = 0;
	
	collided = 0;
	
	e2 = 2*bots.(name).bresErr(1);
	if(e2 > -1.0 * bots.(name).deltas(2))
		bots.(name).bresErr(1) -= bots.(name).deltas(2);
		xMove = bots.(name).direction(1)/scale;
	endif
	if(e2 < bots.(name).deltas(1))
		bots.(name).bresErr(1) += bots.(name).deltas(1);
		yMove = bots.(name).direction(2)/scale;
	endif
	
	[collided, bots] = move(xMove, yMove, name, bots, fid);
	bots.(name).pos(1) = round(bots.(name).pos(1) * 100) /100;
	bots.(name).pos(2) = round(bots.(name).pos(2) * 100) /100;
	fputs(fid, cstrcat("move ", name, " ", num2str(bots.(name).pos(1)), " ", num2str(bots.(name).pos(2)), "\n"));
	
	if(( bots.(name).pos(1) == bots.(name).moveToPoint(1) && bots.(name).pos(2) == bots.(name).moveToPoint(2)));
		status = "endmove";
		return;
	endif 
	
	if(collided)
		status = "end";
		return;
	endif
	
	
	
endfunction

function bots = bresMoveInit(commandArgs, bots, name)
			scale = 2;
			
			x0 = bots.(name).pos(1);
			y0 = bots.(name).pos(2);
			x1 = x0 + str2num(commandArgs{2});
			y1 = y0 + str2num(commandArgs{3});
		
			bots.(name).moveToPoint = [x1, y1];
		
			dx = abs(x1-x0)*scale;
			dy = abs(y1 - y0)*scale;
			if(x0 < x1)
				bots.(name).direction(1) = 1;
			else
				bots.(name).direction(1) = -1;
			endif
			
			if(y0 < y1)
				bots.(name).direction(2) = 1;
			else
				bots.(name).direction(2) = -1;
			endif			
			
			bots.(name).bresErr(1) = dx - dy;
			bots.(name).deltas(1) = dx;
			bots.(name).deltas(2) = dy;
		
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

function [bots,status] = incrementalTurn(energyCost, mu, sigma, bots, name, fid)
	increment = 1;
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