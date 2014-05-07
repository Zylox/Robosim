function [collide, nearest] = circleMapCollision(x,y,radius, map)
	%(x-a)^2 + (y-b)^2 - r^2 = 0
	%printf("%d %d %d\n", x,y, radius);
	
	collide = 0;
	nearest = [-1,-1, Inf];
	% if(x-radius <=0 || x+radius > rows(map.map)+0 || y-radius <=0 || y+radius > columns(map.map)+0)
		% collide = 1;
		% debugDisp("corners info")
		% debugDisp(ceil(y)+radius)
		% debugDisp(columns(map.map))
		% debugDisp(ceil(x)+radius)
		% debugDisp(rows(map.map))
%		debugDisp(cstrcat("x: ",num2str(x)," y: ",num2str(y)));

		% return;
	% endif
	
	
	if(x - radius <1) %hit left wall
		collide =1;
		nearest = [1,y, x];
		return;
	endif
	if(x+radius > rows(map.map)) %hit right wall
		collide = 1;
		nearest = [rows(map.map), y, rows(map.map) - x];
		return;
	endif
	if(y-radius <1) %hit top
		collide = 1;
		nearest = [x, 1, y];
		return;
	endif
	if(y+radius > columns(map.map)) % hit bottom wall
		collide = 1;
		nearest = [x,columns(map.map), columns(map.map) - y];
		return;
	endif
	
	corners = getRegionOfCorners(x-radius, y-radius , x+radius, y+radius, map);
	checkIt = 0;
	
	% for(q = 1:4)
		% checkIt += map.miniMap(corners(q,2),corners(q,1));
	% endfor
	% if(checkIt == 0)
		% collide = 0;
		% return;
	% endif
	
	radiusSq = radius^2;
	collide = 0;
	

	for(i = floor(x)-radius:floor(x)+radius)
		% if(i > map.dims(2))
			% collide = 1;
			% return;	
		% endif
		for(j = floor(y)-radius:floor(y)+radius)
			% if(j > map.dims(1))
					% collide = 1;
					% return;
			% endif
			if(map.map(i,j) == 1)
				if(pixelCircleCollision(i,j,x,y,radius))
					collide = 1;
					checkDist = (x-i)^2 + (y-j)^2;
					if(checkDist < nearest(3))
						nearest = [i,j,checkDist];
					endif
				endif
			endif
		endfor
	endfor
	
endfunction

function angle = angleOfVec(x,y)
	% if(x == 0)
		% if(y > 0)
			% angle = (3*pi)/2;
		% else
			% angle = pi/2;
		% endif
	% else
		angle = atan2(y,x);

	% endif
endfunction

function vecAdj = rCollPMAmt(pos, nearest, movement, radius)
	posX = pos(1);
	posY = pos(2);
	nearX = nearest(1);
	nearY = nearest(2);
	moveX = movement(1);
	moveY = movement(2);

	debugDisp("Movex, movey");
	debugDisp(moveX);
	debugDisp(moveY);
	angle = angleOfVec(moveX,moveY);

	% disp("moveX, moveY");
	% disp(moveX);
	% disp(moveY);
	
	% distX = posX-nearX;
	% distY = posY-nearY;
	
	% A = [distX, distY];
	% B = movement;
	% normB = norm(B);
	
	% (dot(A,B)/norm(B)^2)*B
	% vecAdj = (normB.*(radius)) - ((dot(A,B)/normB^2)*B);
	
	pointOfContact = traceToEdgeOfCirc(nearX,nearY,angle,posX,posY);
	vecAdj = [nearest(1),nearest(2)] .- pointOfContact;
	debugDisp("Moved back By");
	debugDisp(vecAdj);
	
endfunction

function point = traceToEdgeOfCirc(x,y,angle,circX,circY)
	global botRadius;
	
	moveDist = .1;
	
	dx = cos(angle);
	dy = sin(angle);

	
	collide = 1;
	while (collide == 1)
		x += moveDist*dx;
		y += moveDist*dy;
		% dist += moveDist;
		%collide = pixelMapCollision(x,y);
		collide = pixelCircleCollision(x,y, circX, circY, botRadius);
		debugDisp("tracing");
		debugDisp(x);
		debugDisp(y);
		debugDisp(circX);
		debugDisp(circY);
		debugDisp(angle);
	endwhile
	point = [x,y];
	
	
endfunction

function collide = pixelMapCollision(x, y, map)

	if(floor(x) <=1 || floor(x)> rows(map.map) || floor(y) <=1 || floor(y) > columns(map.map))
		collide = 1;
		
		debugDisp("corners info")
		debugDisp(floor(y))
		debugDisp(columns(map.map))
		debugDisp(floor(x))
		debugDisp(rows(map.map))
		
		return;
	endif

	if(map.map(floor(x),floor(y)) == 1)
		collide = 1;
	else
		collide = 0;
	endif
	
endfunction

function collide = pixelCircleCollision(x,y, xc, yc, radius)
	
	distSq = (xc-x)^2 + (yc-y)^2;
	if(distSq < radius^2)
		collide = 1;
	else
		collide = 0;
	endif
	
endfunction

function collided = circleCircleCollision(x1,y1,x2,y2,radius)
	dx = (x2-x1);
	dy = (y2-y1);
	if((dx^2 + dy^2) <= (2*radius)^2)
		collided = 1;
	else 
		collided = 0;
	endif
endfunction

function regOfCorners = getRegionOfCorners(x1, y1 , x2, y2, map)

	
	size = map.blockSize;
	x1 = int32(x1);
	y1 = int32(y1);
	x2 = int32(x2);
	y2 = int32(y2);
	cX1 = ((x1-mod(x1,size))/size) + 1;
	cY1 = ((y1-(mod(y1,size)))/size) + 1;
	cX2 = ((x2-(mod(x2,size)))/size) + 1;
	cY2 = ((y2-(mod(y2,size)))/size) + 1;
	
	if(cX1 == cX2 && cY1 == cY2)
		regOfCorners = [cX1,cY1;cX1,cY1;cX1,cY1;cX1,cY1];
		return;
	endif

	cX3 = ((x1-(mod(x1,map.blockSize)))/50) + 1;
	cY3 = ((y2-(mod(y2,map.blockSize)))/50) + 1;
	cX4 = ((x2-(mod(x2,map.blockSize)))/50) + 1;
	cY4 = ((y1-(mod(y1,map.blockSize)))/50) + 1;
	
	regOfCorners = [cX1,cY1;cX2,cY2;cX3,cY3;cX4,cY4];
endfunction